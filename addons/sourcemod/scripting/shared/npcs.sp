#pragma semicolon 1
#pragma newdecls required

enum //hitgroup_t
{
	HITGROUP_GENERIC,
	HITGROUP_HEAD,
	HITGROUP_CHEST,
	HITGROUP_STOMACH,
	HITGROUP_LEFTARM,
	HITGROUP_RIGHTARM,
	HITGROUP_LEFTLEG,
	HITGROUP_RIGHTLEG,
	
	NUM_HITGROUPS
};

#if defined ZR
static Handle SyncHudRaid;
static float f_DelayNextWaveStartAdvancing;
static float f_DelayGiveOutlineNpc;
#endif

static Handle SyncHud;
static bool b_DoNotDisplayHurtHud[MAXENTITIES];

void Npc_Sp_Precache()
{
#if defined ZR
	f_DelayGiveOutlineNpc = 0.0;
	f_DelayNextWaveStartAdvancing = 0.0;
	f_DelayNextWaveStartAdvancingDeathNpc = 0.0;
#endif
	g_particleMissText = PrecacheParticleSystem("miss_text");
	g_particleCritText = PrecacheParticleSystem("crit_text");
	g_particleMiniCritText = PrecacheParticleSystem("minicrit_text");
	ResetDamageHuds();
}

void NPC_PluginStart()
{
#if defined ZR
	SyncHudRaid = CreateHudSynchronizer();
#endif

	SyncHud = CreateHudSynchronizer();
	
}

#if defined ZR
public bool NPC_SpawnNext(bool panzer, bool panzer_warning, int RND)
{
	float GameTime = GetGameTime();
	if(f_DelaySpawnsForVariousReasons > GameTime)
	{
		return false;
	}
	int limit = 0;
	
	//incase you hate minibosses
	if(CvarNoSpecialZombieSpawn.BoolValue)
	{		
		panzer = false;
		panzer_warning = false;
	}
	
	if(GlobalCheckDelayAntiLagPlayerScale < GameTime)
	{
		AllowSpecialSpawns = false;
		GlobalCheckDelayAntiLagPlayerScale = GameTime + 3.0;//only check every 5 seconds.
		PlayersAliveScaling = 0;
		GlobalIntencity = 0;
		PlayersInGame = 0;
		
		limit = 8; //Minimum should be 8! Do not scale with waves, makes it boring early on.
		limit = RoundToNearest(float(limit) * MaxEnemyMulti());
		
		float ScalingEnemies = ZRStocks_PlayerScalingDynamic(_,true);
		//above 14, dont spawn more, it just is not worth the extra lag it gives.
		
		//max is 14 players.
		if(ScalingEnemies >= 14.0 || BetWar_Mode())
			ScalingEnemies = 14.0;

		ScalingEnemies *= zr_multi_scaling.FloatValue;

		float f_limit = Pow(1.115, ScalingEnemies);

		f_limit *= float(limit);

		//Minimum limit
		if(f_limit <= 8.0)
		{
			f_limit = 8.0;
		}
		
		for(int client=1; client<=MaxClients; client++)
		{
			if(!b_IsPlayerABot[client] && IsClientInGame(client) && GetClientTeam(client)==2 && TeutonType[client] != TEUTON_WAITING && b_HasBeenHereSinceStartOfWave[client])
			{
				if(TeutonType[client] == TEUTON_DEAD || dieingstate[client] > 0)
				{
					GlobalIntencity += 1;
				}
				PlayersInGame += 1;

				if(Level[client] > 9)
					AllowSpecialSpawns = true;
			}
		}
		if(PlayersInGame < 2)
		{
			PlayersInGame = 3;
		}
		
		//This is here to fix the issue of it always playing the zombie instead of human music when 2 people are in.
		//even if both are alive.

		PlayersAliveScaling = RoundToNearest(f_limit);
		
		if(RoundToNearest(f_limit) >= MaxNpcEnemyAllowed())
			f_limit = float(MaxNpcEnemyAllowed());
			
		
		if(PlayersAliveScaling >= MaxNpcEnemyAllowed())
			PlayersAliveScaling = MaxNpcEnemyAllowed();

		LimitNpcs = RoundToNearest(f_limit);
	}
	
	if(!b_GameOnGoing) //no spawn if the round is over
	{
		return false;
	}
	
	if(!AllowSpecialSpawns)
	{
		panzer = false;
		panzer_warning = false;
	}
	
	if(!panzer)
	{
		bool CheckOutline = true;
		if(f_DelayGiveOutlineNpc > GetGameTime())
		{
			CheckOutline = false;
		}
		else
		{
			f_DelayGiveOutlineNpc = GetGameTime() + 0.5;
		}
		if(CheckOutline)
		{
			for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpcTotal; entitycount_again_2++) //Check for npcs
			{
				int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again_2]);
				if(IsValidEntity(entity))
				{
					if(GetTeam(entity) != TFTeam_Red)
					{
						CClotBody npcstats = view_as<CClotBody>(entity);
						if(!npcstats.m_bThisNpcIsABoss && !b_thisNpcHasAnOutline[entity])
						{
							if(Zombies_Currently_Still_Ongoing <= 3 && Zombies_Currently_Still_Ongoing > 0)
								GiveNpcOutLineLastOrBoss(entity, true);
							else
								GiveNpcOutLineLastOrBoss(entity, false);
						}
					}
				}
			}
		}
		//emercency stop. 
		if((EnemyNpcAlive - EnemyNpcAliveStatic) >= MaxEnemiesAllowedSpawnNext())
		{
			return false;
		}
	}

	if(!Spawns_CanSpawnNext())
	{
		return false;
	}
	
	float pos[3], ang[3];

	MiniBoss boss;
	if(panzer && Waves_GetMiniBoss(boss, RND))
	{
		bool isBoss = false;
		int deathforcepowerup = boss.Powerup;
		if(panzer_warning)
		{
			int Text_Int = GetRandomInt(0, 2);
			if(boss.Sound[0])
			{
				for(int panzer_warning_client=1; panzer_warning_client<=MaxClients; panzer_warning_client++)
				{
					if(IsClientInGame(panzer_warning_client))
					{
						if(IsValidClient(panzer_warning_client))
						{
							SetGlobalTransTarget(panzer_warning_client);
							/*
								https://github.com/SteamDatabase/GameTracking-TF2/blob/master/tf/tf2_misc_dir/scripts/mod_textures.txt	
							
							*/
							switch(Text_Int)
							{
								case 0:
								{
									ShowGameText(panzer_warning_client, boss.Icon, 1, "%t", boss.Text_1);
								}
								case 1:
								{
									ShowGameText(panzer_warning_client, boss.Icon, 1, "%t", boss.Text_2);
								}
								case 2:
								{
									ShowGameText(panzer_warning_client, boss.Icon, 1, "%t", boss.Text_3);
								}
							}
						}

						if(boss.SoundCustom)
						{
							EmitCustomToClient(panzer_warning_client, boss.Sound, panzer_warning_client, SNDCHAN_AUTO, 90, _, 2.0);
						}
						else
						{
							EmitSoundToClient(panzer_warning_client, boss.Sound, panzer_warning_client, SNDCHAN_AUTO, 90, _, 1.0);
							EmitSoundToClient(panzer_warning_client, boss.Sound, panzer_warning_client, SNDCHAN_AUTO, 90, _, 1.0);
						}
					}
				}

				Citizen_MiniBossSpawn();
			}
			isBoss = true;
		}
		else
		{
			deathforcepowerup = 0;
		}
		
		if(Spawns_GetNextPos(pos, ang, _, boss.Delay + 2.0))
		{
			DataPack pack;
			CreateDataTimer(boss.Delay, Timer_Delay_BossSpawn, pack, TIMER_FLAG_NO_MAPCHANGE);

			for(int i; i < 3; i++)
			{
				pack.WriteFloat(pos[i]);
				pack.WriteFloat(ang[i]);
			}

			pack.WriteCell(isBoss);
			pack.WriteCell(boss.Index);
			pack.WriteCell(deathforcepowerup);
			pack.WriteFloat(boss.HealthMulti);
			return true;
		}
		else
		{
			PrintToChatAll("SPAWN FAILED (Mini-Boss)");
		}
	}
	else
	{
		static Enemy enemy;
		if(Waves_GetNextEnemy(enemy))
		{
			int SpawnSettingsSee = 0;
			bool result;

			if(enemy.Spawn[0])
			{
				if(ExplodeStringFloat(enemy.Spawn, " ", pos, sizeof(pos)) == 3)
					result = true;
			}

			if(!result)
				result = Spawns_GetNextPos(pos, ang, enemy.Spawn,_,SpawnSettingsSee);

			if(result)
			{
				if(enemy.Is_Boss >= 2)
				{
					WaveStart_SubWaveStart(GetGameTime());
					ReviveAll(true, true);
					RemoveAllDamageAddition();
				}
				int entity_Spawner = NPC_CreateById(enemy.Index, -1, pos, ang, enemy.Team, enemy.Data, true);
				if(entity_Spawner != -1)
				{
					if(GetTeam(entity_Spawner) != TFTeam_Red)
					{
						NpcAddedToZombiesLeftCurrently(entity_Spawner, false);
					}
					if(enemy.Is_Outlined == 1)
					{
						b_thisNpcHasAnOutline[entity_Spawner] = true;
					}
					else if(enemy.Is_Outlined == 2)
					{
						b_NoHealthbar[entity_Spawner] = 1;
					}
					
					if(enemy.Is_Immune_To_Nuke)
					{
						b_ThisNpcIsImmuneToNuke[entity_Spawner] = true;
					}
					
					if(enemy.Health)
					{
						SetEntProp(entity_Spawner, Prop_Data, "m_iMaxHealth", enemy.Health);
						SetEntProp(entity_Spawner, Prop_Data, "m_iHealth", enemy.Health);
					}

					if(enemy.CustomName[0])
					{
						strcopy(c_NpcName[entity_Spawner], sizeof(c_NpcName[]), enemy.CustomName);
					}
					
					CClotBody npcstats = view_as<CClotBody>(entity_Spawner);
					
					npcstats.m_bStaticNPC = enemy.Is_Static;
					if(enemy.Is_Static && enemy.Team != TFTeam_Red)
						AddNpcToAliveList(entity_Spawner, 1);
					/*
					if(!npcstats.m_bStaticNPC)
					{
						if(enemy.Is_Static && enemy.Team != TFTeam_Red)
						{
							npcstats.m_bStaticNPC = enemy.Is_Static;
							AddNpcToAliveList(entity_Spawner, 1);
						}
					}
					*/
					//if its an ally and NOT static, itll teleport to a player!
					if(enemy.Team == TFTeam_Red && !enemy.Is_Static)
					{
						TeleportNpcToRandomPlayer(entity_Spawner);
						RemoveSpawnProtectionLogic(entity_Spawner, true);
					}
					
					if(enemy.Is_Boss > 0)
					{
					//	npcstats.RemovePather(entity_Spawner);
					//	npcstats.CreatePather(16.0, npcstats.GetMaxJumpHeight(), 1000.0, MASK_NPCSOLID, 150.0, 0.1, 1.75); //Global.
						npcstats.m_bThisNpcIsABoss = true; //Set to true!
					}
					else
					{
						npcstats.m_bThisNpcIsABoss = false; //Set to true!
					}
					
					if(enemy.Does_Not_Scale == 0)
					{
						if(enemy.Is_Boss == 0)
						{
							npcstats.m_fCreditsOnKill = enemy.Credits / MultiGlobalEnemy;
						}
						else
						{
							npcstats.m_fCreditsOnKill = enemy.Credits / MultiGlobalEnemyBoss;
						}
					}
					else
					{
						npcstats.m_fCreditsOnKill = enemy.Credits;
					}
					

					fl_Extra_MeleeArmor[entity_Spawner] 	*= enemy.ExtraMeleeRes;
					fl_Extra_RangedArmor[entity_Spawner] 	*= enemy.ExtraRangedRes;
					fl_Extra_Speed[entity_Spawner] 			*= enemy.ExtraSpeed;
					fl_Extra_Damage[entity_Spawner] 		*= enemy.ExtraDamage;
					if(enemy.ExtraThinkSpeed != 0.0 && enemy.ExtraThinkSpeed != 1.0)
						f_AttackSpeedNpcIncrease[entity_Spawner]	*= enemy.ExtraThinkSpeed;
						
					if(enemy.ExtraSize != 1.0)
					{
						float scale = GetEntPropFloat(entity_Spawner, Prop_Send, "m_flModelScale");
						SetEntPropFloat(entity_Spawner, Prop_Send, "m_flModelScale", scale * enemy.ExtraSize);
					}

					if(enemy.Is_Boss || enemy.Is_Outlined)
					{
						GiveNpcOutLineLastOrBoss(entity_Spawner, true);
					}
					else
					{
						GiveNpcOutLineLastOrBoss(entity_Spawner, false);
					}

					if(!DisableSpawnProtection && zr_spawnprotectiontime.FloatValue > 0.0 && SpawnSettingsSee != 1 && i_npcspawnprotection[entity_Spawner] == NPC_SPAWNPROT_INIT)
					{
						
						i_npcspawnprotection[entity_Spawner] = NPC_SPAWNPROT_ON;
						
						/*
						CClotBody npc = view_as<CClotBody>(entity_Spawner);
						npc.m_iSpawnProtectionEntity = TF2_CreateGlow(npc.index);
				
						SetVariantColor(view_as<int>({0, 255, 0, 100}));
						AcceptEntityInput(npc.m_iSpawnProtectionEntity, "SetGlowColor");
						*/
						
						CreateTimer(zr_spawnprotectiontime.FloatValue, Remove_Spawn_Protection, EntIndexToEntRef(entity_Spawner), TIMER_FLAG_NO_MAPCHANGE);
					}

					if(enemy.Is_Boss >= 1 || enemy.Is_Health_Scaled >= 1)
					{		
						//If its any of these, dont scale HP
					}
					else if(GetTeam(entity_Spawner) != 2 && MultiGlobalHealth >= 1.0)
					{
						//if they are an enemy, and the scaling is too high.
						//i put this here instead of in waves.sp as some NPCS dont have an HP defined in the config, resulting in no HP gain.
						ScalingMultiplyEnemyHpGlobalScale(entity_Spawner);
					}
					if(GetTeam(entity_Spawner) == 2)
					{
						Rogue_AllySpawned(entity_Spawner);
						Waves_AllySpawned(entity_Spawner);
					}
					else
					{
						Rogue_EnemySpawned(entity_Spawner);
						Waves_EnemySpawned(entity_Spawner);
						Classic_EnemySpawned(entity_Spawner);
						Construction_EnemySpawned(entity_Spawner);
						Dungeon_EnemySpawned(entity_Spawner);
					}

					if(Waves_InFreeplay())
						Freeplay_SpawnEnemy(entity_Spawner);

					return true;
				}
			}
			else
			{
				PrintToChatAll("SPAWN FAILED (%s)", enemy.Spawn);
			}

			Waves_UpdateMvMStats();
		}
		else if((EnemyNpcAlive - EnemyNpcAliveStatic) <= 0)
		{
			bool donotprogress = false;
			if(f_DelayNextWaveStartAdvancingDeathNpc > GetGameTime())
			{
				donotprogress = true;
				/*
				if(EnemyNpcAliveStatic >= 1)
				{
					donotprogress = false;
				}
				*/
			}
			else
			{
				/*
				if(EnemyNpcAliveStatic >= 1)
				{
					donotprogress = false;
				}
				*/
			}
			if(f_DelayNextWaveStartAdvancing < GetGameTime())
			{
				Waves_Progress(donotprogress);
			}
			return true;
			//we reached limit. stop trying.
		}
	}
	return false;
}
#endif	// ZR

public Action Remove_Spawn_Protection(Handle timer, int ref)
{
	int index = EntRefToEntIndex(ref);
	if(IsValidEntity(index) && index>MaxClients)
	{
		RemoveSpawnProtectionLogic(index, false);
	}
	return Plugin_Stop;
}

stock void RemoveSpawnProtectionLogic(int entity, bool force)
{
#if defined ZR
	bool KeepProtection = false;
	if(!force)
	{
		if(Rogue_Theme() == 1)
		{
			if(f_DomeInsideTest[entity] > GetGameTime())
			{
				KeepProtection = true;
			}
		}
		float PosNpc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", PosNpc);
		if(!KeepProtection)
		{
			if(IsPointOutsideMap(PosNpc))
			{
				KeepProtection = true;
			}
		}
		if(!KeepProtection)
		{
			if(i_InHurtZone[entity])
				KeepProtection = true;
		}
		if(!KeepProtection)
		{
			static float minn[3], maxx[3];
			GetEntPropVector(entity, Prop_Send, "m_vecMins", minn);
			GetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxx);
			if(IsBoxHazard(PosNpc, minn, maxx))
				KeepProtection = true;
		}
	}


	if(KeepProtection)
	{
		//npc is in some type of out of bounds spot probably, keep them safe.
		CreateTimer(0.1, Remove_Spawn_Protection, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		return;
	}
#endif	// ZR
	
	CClotBody npc = view_as<CClotBody>(entity);
		
	if(IsValidEntity(npc.m_iSpawnProtectionEntity))
		RemoveEntity(npc.m_iSpawnProtectionEntity);
	//-1 means none, and dont apply anymore.
	i_npcspawnprotection[entity] = NPC_SPAWNPROT_OFF;
}

#if defined ZR
public Action Timer_Delay_BossSpawn(Handle timer, DataPack pack)
{
	pack.Reset();
	float pos[3], ang[3];
	for(int i; i < 3; i++)
	{
		pos[i] = pack.ReadFloat();
		ang[i] = pack.ReadFloat();
	}
	bool isBoss = pack.ReadCell();
	int index = pack.ReadCell();
	int forcepowerup = pack.ReadCell();
	float healthmulti = pack.ReadFloat();
	
	int entity = NPC_CreateById(index, -1, pos, ang, TFTeam_Blue,_,true);
	if(entity != -1)
	{
		NpcAddedToZombiesLeftCurrently(entity, true);

		CClotBody npcstats = view_as<CClotBody>(entity);
		if(isBoss)
		{
			GiveNpcOutLineLastOrBoss(entity, true);
			npcstats.m_bThisNpcIsABoss = true; //Set to true!
		}
		else
		{
			npcstats.m_bThisNpcIsABoss = false; //Set to true!
		}
		
		if(healthmulti)
		{
			SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * healthmulti));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) * healthmulti));
		}
		
		b_NpcForcepowerupspawn[entity] = forcepowerup;

		if(GetTeam(entity) == 2)
		{
			Rogue_AllySpawned(entity);
			Waves_AllySpawned(entity);
		}
		else
		{
			Rogue_EnemySpawned(entity);
			Waves_EnemySpawned(entity);
			Construction_EnemySpawned(entity);
			Dungeon_EnemySpawned(entity);
		}
		if(Waves_InFreeplay())
			Freeplay_SpawnEnemy(entity);
	}

	return Plugin_Stop;
}
#endif


void NPC_Ignite(int entity, int attacker, float duration, int weapon, float damageoverride = 8.0, bool colored = false)
{
	if(HasSpecificBuff(entity, "Hardened Aura"))
		return;
	
	bool wasBurning = view_as<bool>(IgniteFor[entity]);

	IgniteFor[entity] += RoundToCeil(duration*2.0);
	if(IgniteFor[entity] > 20)
		IgniteFor[entity] = 20;
	
	if(!IgniteTimer[entity])
		IgniteTimer[entity] = CreateTimer(0.5, NPC_TimerIgnite, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	else
	{
		//Players cannot re-ignite.
		/*
		This was blocked for players cus it was too op.
		free true damage.
		hell no.

		*/
		if(attacker > MaxClients)
		{
			int Saveid = IgniteId[entity];
			if(IsValidEntity(weapon))
				BurnDamage[entity] *= Attributes_Get(weapon, 4040, 1.0);

			IgniteId[entity] = EntIndexToEntRef(attacker);

			BurnDamage[entity] *= 0.5;
			//apply burn once for half the damage!
			//Also apply damage for ourselves so we get the credit.
			TriggerTimer(IgniteTimer[entity]);
			BurnDamage[entity] *= 2.0;
			if(IsValidEntity(weapon))
				BurnDamage[entity] *= (1.0 / Attributes_Get(weapon, 4040, 1.0));

			IgniteId[entity] = Saveid;
		}
	}
	
	float value = 8.0;
	value = damageoverride;
	bool validWeapon = false;
	ApplyStatusEffect(attacker, entity, "Burn", 999999.9);

#if !defined RTS
	if(weapon > MaxClients && IsValidEntity(weapon))
	{
		validWeapon = true;
		value *= Attributes_Get(weapon, 2, 1.0);	//For normal weapons
			
		value *= Attributes_Get(weapon, 410, 1.0); //For wand
					
		value *= Attributes_Get(weapon, 71, 1.0); //overall
	}
#endif

	if(wasBurning)
	{
		if(value > BurnDamage[entity]) //Dont override if damage is lower.
		{
			BurnDamage[entity] = value;
			IgniteId[entity] = EntIndexToEntRef(attacker);

			if(validWeapon)
			{
				IgniteRef[entity] = EntIndexToEntRef(weapon);
			}
			else
			{
				IgniteRef[entity] = -1;
			}
		}
	}
	else
	{
		IgniteTargetEffect(entity, .type = colored);

		BurnDamage[entity] = value;
		IgniteId[entity] = EntIndexToEntRef(attacker);
		if(validWeapon)
		{
			IgniteRef[entity] = EntIndexToEntRef(weapon);
		}
		else
		{
			IgniteRef[entity] = -1;
		}
	}
}

public Action NPC_TimerIgnite(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		if((b_ThisWasAnNpc[entity] && !b_NpcHasDied[entity]) || i_IsABuilding[entity] || (entity <= MaxClients))
		{
			int attacker = EntRefToEntIndex(IgniteId[entity]);
			if(!IsValidEntity(attacker))
			{
				attacker = 0;
			}
			IgniteFor[entity]--;
			
			
			int weapon = EntRefToEntIndex(IgniteRef[entity]);
			float value = 8.0;
#if !defined RTS
			if(weapon > MaxClients && IsValidEntity(weapon))
			{
				value *= Attributes_Get(weapon, 2, 1.0);	  //For normal weapons
				
			//	value *= Attributes_Get(weapon, 1000, 1.0); //For any
				
				value *= Attributes_Get(weapon, 410, 1.0); //For wand
				
				value *= Attributes_Get(weapon, 71, 1.0); //For wand

			}
			else
#endif
			{
				weapon = -1;
			}
			float pos[3];
			WorldSpaceCenter(entity, pos);
			
			if(value < 0.2)
			{
				
			}
			else if(value < BurnDamage[entity])
			{
				value = BurnDamage[entity];
			}
			else
			{
				BurnDamage[entity] = value;
			}
			if(NpcStats_ElementalAmp(entity))
			{
				value *= 1.2;
			}
			//Burn damage should pierce any resistances because its too hard to keep track off, and its not common.
			if(i_IsABuilding[entity]) //if enemy was a building, deal 5x damage.
				value *= 5.0;
				
			int DamageTypes = DMG_TRUEDAMAGE | DMG_PREVENT_PHYSICS_FORCE;

			if(GetTeam(entity) != TFTeam_Red)
			{
				DamageTypes &= ~DMG_TRUEDAMAGE;
				DamageTypes |= DMG_BULLET;
			}
			SDKHooks_TakeDamage(entity, attacker, attacker, value, DamageTypes, weapon, {0.0,0.0,0.0}, pos, false, (ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED | ZR_DAMAGE_IGNORE_DEATH_PENALTY ));
			
			//Setting burn dmg to slash cus i want it to work with melee!!!
			//Also yes this means burn and bleed are basically the same, excluding that burn doesnt stack.
			//In this case ill buff it so its 2x as good as bleed! or more in the future
			//Also now allows hp gain and other stuff for that reason. pretty cool.
			if(IgniteFor[entity] <= 0)
			{
				ExtinguishTarget(entity);
				IgniteTimer[entity] = null;
				IgniteFor[entity] = 0;
				BurnDamage[entity] = 0.0;
				RemoveSpecificBuff(entity, "Burn");
				return Plugin_Stop;
			}
			if(HasSpecificBuff(entity, "Hardened Aura"))
			{
				ExtinguishTarget(entity);
				IgniteTimer[entity] = null;
				IgniteFor[entity] = 0;
				BurnDamage[entity] = 0.0;
				RemoveSpecificBuff(entity, "Burn");
				return Plugin_Stop;
			}
			return Plugin_Continue;
		}
		else
		{
			ExtinguishTarget(entity);
			IgniteTimer[entity] = null;
			IgniteFor[entity] = 0;
			BurnDamage[entity] = 0.0;
			RemoveSpecificBuff(entity, "Burn");
			return Plugin_Stop;		
		}
	}
	return Plugin_Stop;
}

public Action NPC_TraceAttack(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
//	PrintToChatAll("ow NPC_TraceAttack");
	if(attacker < 1 || attacker > MaxClients || victim == attacker)
		return Plugin_Continue;
		
	if(inflictor < 1 || inflictor > MaxClients)
		return Plugin_Continue;

	if(IsInvuln(victim, true))
		return Plugin_Continue;
	
	
//	if((damagetype & (DMG_BULLET)) || (damagetype & (DMG_BUCKSHOT))) // Needed, other crap for some reason can trigger headshots, so just make sure only bullets can do this.
	int weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
	if(IsValidEntity(weapon))
	{
		bool WasAlreadyPlayed = false;
		if(f_TraceAttackWasTriggeredSameFrame[victim] == GetGameTime())
		{
			WasAlreadyPlayed = true;
		}
		f_TraceAttackWasTriggeredSameFrame[victim] = GetGameTime();
		i_HasBeenHeadShotted[victim] = false;
#if defined ZR || defined RPG
		bool DoCalcReduceHeadshotFalloff = false;

		if(!i_WeaponCannotHeadshot[weapon])
		{
			//Buff bodyshot damage.
			damage *= 1.4;

#if defined ZR
			bool Blitzed_By_Riot = false;
			if(i_CustomWeaponEquipLogic[weapon] == WEAPON_RIOT_SHIELD && f_TimeFrozenStill[victim] > GetGameTime(victim))
			{
				Blitzed_By_Riot = true;
			}
#endif

			if(f_HeadshotDamageMultiNpc[victim] <= 0.0 && hitgroup == HITGROUP_HEAD)
			{
				damage = 0.0;
				if(!WasAlreadyPlayed)
				{
					float chargerPos[3];
					GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
					if(b_BoundingBoxVariant[victim] == 1)
					{
						chargerPos[2] += 120.0;
					}
					else
					{
						chargerPos[2] += 82.0;
					}
					TE_ParticleInt(g_particleMissText, chargerPos);
					TE_SendToClient(attacker);
					EmitSoundToClient(attacker, "physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(95, 105));
				}
				return Plugin_Handled;
			}

#if defined ZR
			if((hitgroup == HITGROUP_HEAD && !b_CannotBeHeadshot[victim]) || Blitzed_By_Riot)
#else
			if(hitgroup == HITGROUP_HEAD && !b_CannotBeHeadshot[victim])
#endif
			{
				damage *= f_HeadshotDamageMultiNpc[victim];

				//incase it has headshot multi
				damage *= Attributes_Get(weapon, Attrib_HeadshotBonus, 1.0);

				if(i_HeadshotAffinity[attacker] == 1)
				{
					damage *= 1.42;
					DoCalcReduceHeadshotFalloff = true;
				}
				else
					damage *= 1.185;

#if defined ZR
				if(Blitzed_By_Riot) //Extra damage.
				{
					damage *= 1.35;
				}
				else
#endif
				{
					i_HasBeenHeadShotted[victim] = true; //shouldnt count as an actual headshot!
				}

				if(i_CurrentEquippedPerk[attacker] & PERK_MARKSMAN_BEER) //I guesswe can make it stack.
				{
					damage *= 1.25;
				}
				
				int pitch = GetRandomInt(90, 110);
				int random_case = GetRandomInt(1, 2);
				float volume = 0.7;
				/*
				if(played_headshotsound_already[attacker] = GetGameTime())
				{
					random_case = played_headshotsound_already_Case[attacker];
					pitch = played_headshotsound_already_Pitch[attacker];
					volume = 1.0;
					played_headshotsound_already[attacker] = GetGameTime()
				}
				else*/
				if(!WasAlreadyPlayed)
				{
#if defined ZR
					DisplayCritAboveNpc(victim, attacker, Blitzed_By_Riot);
#else
					DisplayCritAboveNpc(victim, attacker, false);
#endif
				//	played_headshotsound_already_Case[attacker] = random_case;
				//	played_headshotsound_already_Pitch[attacker] = pitch;
				}
				
#if defined ZR 
				if(i_ArsenalBombImplanter[weapon] > 0)
				{
					float damage_save = 50.0;
					damage_save *= Attributes_Get(weapon, 2, 1.0);
					int BombsToInject = i_ArsenalBombImplanter[weapon];
					if(i_CurrentEquippedPerk[attacker] & PERK_MARKSMAN_BEER) //I guesswe can make it stack.
					{
						BombsToInject += 1;
					}
					if(i_HeadshotAffinity[attacker] == 1)
					{
						BombsToInject += 1;
					}
					if(f_ChargeTerroriserSniper[weapon] > 149.0)
					{
						BombsToInject *= 2;
					}
					if(i_HowManyBombsOnThisEntity[victim][attacker] + BombsToInject < 200)
					{
						f_BombEntityWeaponDamageApplied[victim][attacker] += damage_save * float(BombsToInject);
						i_HowManyBombsOnThisEntity[victim][attacker] += BombsToInject;
						i_HowManyBombsHud[victim] += BombsToInject;
						Apply_Particle_Teroriser_Indicator(victim);
						damage = 0.0;
					}
				}
#endif	// ZR
			//	played_headshotsound_already[attacker] = GetGameTime();

#if defined ZR
				if(!Blitzed_By_Riot) //dont play headshot sound if blized.
#endif
				{
					switch(random_case)
					{
						case 1:
						{
							if(!EnableSilentMode)
							{
								for(int client=1; client<=MaxClients; client++)
								{
									if(IsClientInGame(client) && client != attacker)
									{
										EmitCustomToClient(client, "zombiesurvival/headshot1.wav", victim, _, 80, _, volume, pitch);
									}
								}
							}
							EmitCustomToClient(attacker, "zombiesurvival/headshot1.wav", _, _, 90, _, volume, pitch);
						}
						case 2:
						{
							if(!EnableSilentMode)
							{
								for(int client=1; client<=MaxClients; client++)
								{
									if(IsClientInGame(client) && client != attacker)
									{
										EmitCustomToClient(client, "zombiesurvival/headshot2.wav", victim, _, 80, _, volume, pitch);
									}
								}
							}
							EmitCustomToClient(attacker, "zombiesurvival/headshot2.wav", _, _, 90, _, volume, pitch);
						}
					}
				}
			}
			else
			{
#if defined ZR
				if(i_ArsenalBombImplanter[weapon] > 0)
				{
					float damage_save = 50.0;
					damage_save *= Attributes_Get(weapon, 2, 1.0);
					int BombsToInject = i_ArsenalBombImplanter[weapon];
					if(i_HeadshotAffinity[attacker] == 1)
					{
						BombsToInject -= 1;
					}
					if(f_ChargeTerroriserSniper[weapon] > 149.0)
					{
						BombsToInject *= 2;
					}

					BombsToInject /= 2;
					if(BombsToInject < 1)
						BombsToInject = 1;
						
					if(i_HowManyBombsOnThisEntity[victim][attacker] + BombsToInject < 200)
					{
						f_BombEntityWeaponDamageApplied[victim][attacker] += damage_save * float(BombsToInject);
						i_HowManyBombsOnThisEntity[victim][attacker] += BombsToInject;
						i_HowManyBombsHud[victim] += BombsToInject;
						Apply_Particle_Teroriser_Indicator(victim);
						damage = 0.0;
					}
				}
#endif

				if(i_HeadshotAffinity[attacker] == 1)
				{
					damage *= 0.65;
				}
			}
		}
		
		if(damagetype & DMG_BULLET)
		{
			if(i_WeaponDamageFalloff[weapon] != 1.0) //dont do calculations if its the default value, meaning no extra or less dmg from more or less range!
			{
				if(b_ProximityAmmo[attacker])
				{
					damage *= 1.15;
				}

				float AttackerPos[3];
				float VictimPos[3];
				
				WorldSpaceCenter(attacker, AttackerPos);
				WorldSpaceCenter(victim, VictimPos);

				float distance = GetVectorDistance(AttackerPos, VictimPos, true);
				
				distance -= 1600.0;// Give 60 units of range cus its not going from their hurt pos

				if(distance < 0.1)
				{
					distance = 0.1;
				}
				float WeaponDamageFalloff = i_WeaponDamageFalloff[weapon];
				if(b_ProximityAmmo[attacker])
				{
					WeaponDamageFalloff *= 0.8;
				}
				if(DoCalcReduceHeadshotFalloff && WeaponDamageFalloff <= 1.0)
				{
					WeaponDamageFalloff *= 1.3;
					if(WeaponDamageFalloff >= 1.0)
						WeaponDamageFalloff = 1.0;
				}
				

				damage *= Pow(WeaponDamageFalloff, (distance/1000000.0)); //this is 1000, we use squared for optimisations sake
			}
		}
#endif
	}
	return Plugin_Changed;
}
		
//Otherwise we get kicks if there is too much hurting going on.

public void Func_Breakable_Post(int victim, int attacker, int inflictor, float damage, int damagetype)
{
	if(attacker < 1 || attacker > MaxClients)
		return;
	
	int Health = GetEntProp(victim, Prop_Data, "m_iHealth");
	
#if defined ZR
/*
	Dont give hurt credit.
	float damage_Caclulation = damage;
		
	//for some reason it doesnt do it by itself, im baffeled.
	
	if(Health < 0)
		damage_Caclulation += float(Health);
	
	if(damage_Caclulation > 0.0) //idk i guess my math is off or that singular/10 frames of them being still being there somehow impacts this, cannot go around this, delay is a must
		Damage_dealt_in_total[attacker] += damage_Caclulation;	//otherwise alot of other issues pop up.
	
	Damage_dealt_in_total[attacker] += damage_Caclulation;
*/
#endif
	
	Event event = CreateEvent("npc_hurt");
	if (event) 
	{
		int display = RoundToFloor(damage);

		event.SetInt("entindex", victim);
		event.SetInt("health", Health > 0 ? Health : 0);
		event.SetInt("damageamount", display);
		event.SetBool("crit", (damagetype & DMG_ACID) == DMG_ACID);

		if (attacker > 0 && attacker <= MaxClients)
		{
			event.SetInt("attacker_player", GetClientUserId(attacker));
			event.SetInt("weaponid", 0);
		}
		else 
		{
			event.SetInt("attacker_player", 0);
			event.SetInt("weaponid", 0);
		}

		event.Fire();
	}
	
	if(f_CooldownForHurtHud[attacker] < GetGameTime())
	{
		f_CooldownForHurtHud[attacker] = GetGameTime() + 0.1;
		
		SetHudTextParams(-1.0, 0.2, 1.0, 255, 200, 200, 255, 0, 0.01, 0.01);
		ShowSyncHudText(attacker, SyncHud, "%d", Health);
	}
}
public void Map_BaseBoss_Damage_Post(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	if(attacker < 1 || attacker > MaxClients)
		return;
	
	int Health = GetEntProp(victim, Prop_Data, "m_iHealth");
	
#if defined ZR
	float damage_Caclulation = damage;
		
	//for some reason it doesnt do it by itself, im baffeled.

	if(Health < 0)
		damage_Caclulation += float(Health);
	
	if(damage_Caclulation > 0.0) //idk i guess my math is off or that singular/10 frames of them being still being there somehow impacts this, cannot go around this, delay is a must
		Damage_dealt_in_total[attacker] += damage_Caclulation;	//otherwise alot of other issues pop up.
	
	Damage_dealt_in_total[attacker] += damage_Caclulation;
#endif
	
	if(f_CooldownForHurtHud[attacker] < GetGameTime())
	{
		f_CooldownForHurtHud[attacker] = GetGameTime() + 0.1;
		
		SetHudTextParams(-1.0, 0.2, 1.0, 255, 200, 200, 255, 0, 0.01, 0.01);
		ShowSyncHudText(attacker, SyncHud, "%d", Health);
	}
}
float Damageaftercalc = 0.0;
public Action NPC_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(i_IsNpcType[victim] == 1)
	{
		//Dont allow crush from these wierd npcs.
		if((damagetype & DMG_CRUSH))
		{
			damage = 0.0;
			return Plugin_Changed;
		}
	}
	if(!CheckInHud() && HasSpecificBuff(victim, "Archo's Posion"))
	{
		if(!(damagetype & (DMG_FALL|DMG_OUTOFBOUNDS|DMG_TRUEDAMAGE)))
		{
			damagetype = DMG_TRUEDAMAGE;
		}
	}

	float GameTime = GetGameTime();
	if(!CheckInHud())
	{
		b_DoNotDisplayHurtHud[victim] = false;
		//LogEntryInvicibleTest(victim, attacker, damage, 1);
		//sommetimes, the game sets it to 1 somehow, in the future find a better fix for this.
		SetEntProp(victim, Prop_Data, "m_lifeState", 0);
	}
	
	//drown is out of p stuff.
	if((damagetype & DMG_OUTOFBOUNDS))
	{
		damage = 5.0;
		Damageaftercalc = 5.0;
		TeleportBackToLastSavePosition(victim);
		return Plugin_Handled;
	}
	//LogEntryInvicibleTest(victim, attacker, damage, 2);
	if(IsInvuln(victim, true)/* && damage < 9999999.9*/)
	{
		damage = 0.0;
		Damageaftercalc = 0.0;
		return Plugin_Changed;
	//	return Plugin_Handled;
	}
	//a triggerhurt can never deal more then 10% of a raids health as damage.
	if(b_IsATriggerHurt[attacker] && b_thisNpcIsARaid[victim])
	{
		if(damage >= float(ReturnEntityMaxHealth(victim)) * 0.1)
		{
			damage = float(ReturnEntityMaxHealth(victim)) * 0.1;
		}
	}
	CClotBody npcBase = view_as<CClotBody>(victim);
	
	//LogEntryInvicibleTest(victim, attacker, damage, 3);
	if((i_HexCustomDamageTypes[victim] & ZR_SLAY_DAMAGE))
	{
		npcBase.m_bGib = true;
		return Plugin_Continue;
	}

	//LogEntryInvicibleTest(victim, attacker, damage, 4);
	if(attacker < 0 || victim == attacker)
	{
		Damageaftercalc = 0.0;
		return Plugin_Handled;
		//nothing happens.
	}
	else/* if(damage < 9999999.9)*/
	{
		if(Damage_Modifiy(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom))
		{
			return Plugin_Handled;
		}

#if defined ZR
		if(!CheckInHud())
		{
			if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS))
			{
				if(SergeantIdeal_Existant())
				{
					//LogEntryInvicibleTest(victim, attacker, damage, 17);
					SergeantIdeal_Protect(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
					if(damage == 0.0)
					{
						b_DoNotDisplayHurtHud[victim] = true;
						return Plugin_Handled;
					}
					//LogEntryInvicibleTest(victim, attacker, damage, 18);
				}
			}
		}
		//LogEntryInvicibleTest(victim, attacker, damage, 19);
#endif

	}
	//LogEntryInvicibleTest(victim, attacker, damage, 20);
	if(CheckInHud())
		return Plugin_Handled;
#if defined ZR
	if(inflictor > 0 && inflictor <= MaxClients)
	{	
		/*
		if(f_Data_InBattleHudDisableDelay[inflictor] + 2.0 != 0.0)
		{
			f_InBattleHudDisableDelay[inflictor] = GetGameTime() + f_Data_InBattleHudDisableDelay[inflictor] + 2.0;
		}
		*/
		f_InBattleDelay[inflictor] = GetGameTime() + 3.0;
	}
#endif
	
	//LogEntryInvicibleTest(victim, attacker, damage, 21);
	OnTakeDamageBleedNpc(victim, attacker, inflictor, damage, damagetype, weapon, damagePosition, GameTime);
	//LogEntryInvicibleTest(victim, attacker, damage, 22);

	npcBase.m_vecpunchforce(damageForce, true);
	if(!npcBase.m_bDissapearOnDeath) //Make sure that if they just vanish, its always false. so their deathsound plays.
	{
		if((damagetype & DMG_BLAST))
		{
			npcBase.m_bGib = true;
		}
		else if((i_HexCustomDamageTypes[victim] & ZR_DAMAGE_GIB_REGARDLESS))
		{
			npcBase.m_bGib = true;
		}
		else if((damage * fl_GibVulnerablity[victim]) > (ReturnEntityMaxHealth(victim) * 1.5))
		{
			npcBase.m_bGib = true;
		}
	}
	//LogEntryInvicibleTest(victim, attacker, damage, 23);
#if defined ZR
	if(RogueFizzyDrink())
	{
		npcBase.m_bGib = true;
	}
	if((i_HexCustomDamageTypes[victim] & ZR_DAMAGE_CANNOTGIB_REGARDLESS))
	{
		npcBase.m_bGib = false;
	}
	//force gibbing.
	if(HasSpecificBuff(victim, "Warped Elemental End"))
		npcBase.m_bGib = true;
#endif
	//LogEntryInvicibleTest(victim, attacker, damage, 24);
	
	if(damage <= 0.0)
	{
		Damageaftercalc = 0.0;
		return Plugin_Changed;
	}
	//LogEntryInvicibleTest(victim, attacker, damage, 25);
	Damageaftercalc = damage;
	return Plugin_Changed;
}

public void NPC_OnTakeDamage_Post(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
#if defined ZR
	if(!b_NpcIsTeamkiller[attacker] && GetTeam(attacker) == GetTeam(victim))
	{
		return;
	}
		
	int AttackerOverride = EntRefToEntIndex(i_NpcOverrideAttacker[attacker]);
	if(AttackerOverride > 0)
	{
		attacker = AttackerOverride;
	}		
	//LogEntryInvicibleTest(victim, attacker, damage, 26);
#endif
	int health = GetEntProp(victim, Prop_Data, "m_iHealth");
	if(i_IsNpcType[victim] == 1)
	{
		health -= RoundToNearest(damage);
		SetEntProp(victim, Prop_Data, "m_iHealth", health);
	}
#if defined ZR
	if((Damageaftercalc >= 0.0 || IsInvuln(victim, true) || (weapon > -1 && i_ArsenalBombImplanter[weapon] > 0)) && !b_DoNotDisplayHurtHud[victim]) //make sure to still show it if they are invinceable!
#else
	if((Damageaftercalc >= 0.0 || IsInvuln(victim, true)) && !b_DoNotDisplayHurtHud[victim]) //make sure to still show it if they are invinceable!
#endif
	{
#if !defined RTS
		if(inflictor > 0 && inflictor <= MaxClients)
		{
			GiveRageOnDamage(inflictor, Damageaftercalc);
#if defined ZR
			GiveMorphineOnDamage(inflictor, victim, Damageaftercalc, damagetype);
#endif
			Calculate_And_Display_hp(inflictor, victim, Damageaftercalc, false);
		}
		else if(attacker > 0 && attacker <= MaxClients)
		{
			GiveRageOnDamage(attacker, Damageaftercalc);
#if defined ZR
			GiveMorphineOnDamage(attacker, victim, Damageaftercalc, damagetype);
#endif
			Calculate_And_Display_hp(attacker, victim, Damageaftercalc, false);	
		}
		else
		{
			float damageCalc = Damageaftercalc;
			int Health = GetEntProp(victim, Prop_Data, "m_iHealth");
			if(Health <= 0)
			{
				damageCalc += Health;
			}
			Damage_dealt_in_total[attacker] += damageCalc;
			Calculate_And_Display_hp(attacker, victim, Damageaftercalc, false);
		}
		OnPostAttackUniqueWeapon(attacker, victim, weapon, i_HexCustomDamageTypes[victim]);
#endif
		//Do not show this event if they are attacked with DOT. Earls bleedin.
		if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
		{
			Event event = CreateEvent("npc_hurt");
			if(event) 
			{
				int display = RoundToNearest(Damageaftercalc);
				event.SetInt("entindex", victim);
				event.SetInt("health", health);
				event.SetInt("damageamount", display);
				event.SetBool("crit", (damagetype & DMG_ACID) == DMG_ACID);

				if(attacker > 0 && attacker <= MaxClients)
				{
					event.SetInt("attacker_player", GetClientUserId(attacker));
					event.SetInt("weaponid", 0);
				}
				else 
				{
					event.SetInt("attacker_player", 0);
					event.SetInt("weaponid", 0);
				}

				event.Fire();
			}
		}
		
	}
	f_InBattleDelay[victim] = GetGameTime() + 6.0;

	//LogEntryInvicibleTest(victim, attacker, damage, 27);
	CClotBody npcBase = view_as<CClotBody>(victim);
	bool SlayNpc = true;
	while(health <= 0 && npcBase.m_iHealthBar >= 1)
	{
		//has health bars!
		health += ReturnEntityMaxHealth(victim);
		SetEntProp(victim, Prop_Data, "m_iHealth", health);
		npcBase.m_iHealthBar--;
	}
	if(health >= 1)
	{
		SlayNpc = false;
	}
	if(IsInvuln(victim, true) || b_NpcUnableToDie[victim])
	{
		if(!(i_HexCustomDamageTypes[victim] & ZR_SLAY_DAMAGE))
		{
			SlayNpc = false;
		}
	}

	//LogEntryInvicibleTest(victim, attacker, damage, 28);
	Function func = func_NPCOnTakeDamagePost[victim];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(victim);
		Call_PushCell(attacker);
		Call_PushCell(inflictor);
		Call_PushFloat(damage);
		Call_PushCell(damagetype);
		Call_PushCell(weapon);
		Call_PushArray(damageForce, sizeof(damageForce));
		Call_PushArray(damagePosition, sizeof(damagePosition));
		Call_PushCell(damagecustom);
		Call_PushCellRef(SlayNpc);
		Call_Finish();
	}
	StatusEffect_OnTakeDamagePostVictim(victim, attacker, damage, damagetype);
	StatusEffect_OnTakeDamagePostAttacker(victim, attacker, damage, damagetype);

#if defined ZR 
	if(inflictor > 0 && inflictor <= MaxClients)
	{
		b_RaptureZombie[victim] = b_RaptureZombie[inflictor];
	}
	else if(attacker > 0 && attacker <= MaxClients)
	{
		b_RaptureZombie[victim] = b_RaptureZombie[attacker];
	}
#endif
	//was health changed?
	health = GetEntProp(victim, Prop_Data, "m_iHealth");
	
	//LogEntryInvicibleTest(victim, attacker, damage, 29);
	
	if(SlayNpc && HasSpecificBuff(victim, "Blessing of Stars"))
	{
		HealEntityGlobal(victim, victim, float(ReturnEntityMaxHealth(victim) / 4), 1.0, 1.0, HEAL_ABSOLUTE);
		SetEntProp(victim, Prop_Data, "m_iHealth", 1);
		ApplyStatusEffect(victim, victim, "Unstoppable Force", 1.0);
		RemoveSpecificBuff(victim, "Blessing of Stars");
		EmitSoundToAll("misc/halloween/spell_overheal.wav", victim, SNDCHAN_STATIC, 80, _, 0.8);
		SlayNpc = false;
	}
	if(SlayNpc && !HasSpecificBuff(victim, "Infinite Will"))
	{
		CBaseCombatCharacter_EventKilledLocal(victim, attacker, inflictor, Damageaftercalc, damagetype, weapon, damageForce, damagePosition);
	}
	else
	{
		if(health <= 0)
			SetEntProp(victim, Prop_Data, "m_iHealth", 1);
	}
	i_HexCustomDamageTypes[victim] = 0;
	//LogEntryInvicibleTest(victim, attacker, damage, 30);
		
	Damageaftercalc = 0.0;
	i_HasBeenHeadShotted[victim] = false;
}

stock void GiveRageOnDamage(int client, float damage)
{
	if(!GetEntProp(client, Prop_Send, "m_bRageDraining"))
	{
		float rage = GetEntPropFloat(client, Prop_Send, "m_flRageMeter") + (damage * 0.05);
		if(rage > 100.0)
			rage = 100.0;
			
		SetEntPropFloat(client, Prop_Send, "m_flRageMeter", rage);
	}
}

stock void Generic_OnTakeDamage(int victim, int attacker)
{
	if(attacker > 0)
	{
		CClotBody npc = view_as<CClotBody>(victim);
		float gameTime = GetGameTime(npc.index);

		if(npc.m_flHeadshotCooldown < gameTime)
		{
			npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
			npc.m_blPlayHurtAnimation = true;
		}
	}
}

void OnTakeDamageBleedNpc(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damagePosition[3], float GameTime)
{
	CClotBody npcBase = view_as<CClotBody>(victim);
	if(damagePosition[0] != 0.0) //If there is no pos, then dont.
	{
		if(!(damagetype & (DMG_SHOCK)))
		{
			if (f_CooldownForHurtParticle[victim] < GameTime)
			{
				if(EnableSilentMode)
					f_CooldownForHurtParticle[victim] = GameTime + 1.0;
				else
					f_CooldownForHurtParticle[victim] = GameTime + 0.25;

				if(npcBase.m_iBleedType == BLEEDTYPE_NORMAL)
				{
					TE_ParticleInt(g_particleImpactFlesh, damagePosition);
					TE_SendToAllInRange(damagePosition, RangeType_Visibility);
				}
				else if (npcBase.m_iBleedType == BLEEDTYPE_METAL)
				{
					damagePosition[2] -= 40.0;
					TE_ParticleInt(g_particleImpactMetal, damagePosition);
					TE_SendToAllInRange(damagePosition, RangeType_Visibility);
				}
				else if (npcBase.m_iBleedType == BLEEDTYPE_RUBBER)
				{
					TE_ParticleInt(g_particleImpactRubber, damagePosition);
					TE_SendToAllInRange(damagePosition, RangeType_Visibility);
				}
				else if (npcBase.m_iBleedType == BLEEDTYPE_XENO)
				{
					//If you cant find any good blood effect, use this one and just recolour it.
					TE_BloodSprite(damagePosition, { 0.0, 0.0, 0.0 }, 125, 255, 125, 255, 32);
					TE_SendToAllInRange(damagePosition, RangeType_Visibility);
				}
				else if (npcBase.m_iBleedType == BLEEDTYPE_SEABORN)
				{
					//If you cant find any good blood effect, use this one and just recolour it.
					TE_BloodSprite(damagePosition, { 0.0, 0.0, 0.0 }, 65, 65, 255, 255, 32);
					TE_SendToAllInRange(damagePosition, RangeType_Visibility);
				}
				else if (npcBase.m_iBleedType == BLEEDTYPE_VOID)
				{
					//If you cant find any good blood effect, use this one and just recolour it.
					TE_BloodSprite(damagePosition, { 0.0, 0.0, 0.0 }, 200, 0, 200, 255, 32);
					TE_SendToAllInRange(damagePosition, RangeType_Visibility);
				}
				else if (npcBase.m_iBleedType == BLEEDTYPE_UMBRAL)
				{
					//If you cant find any good blood effect, use this one and just recolour it.
					TE_BloodSprite(damagePosition, { 0.0, 0.0, 0.0 }, 200, 200, 200, 255, 32);
					TE_SendToAllInRange(damagePosition, RangeType_Visibility);
				}
				else if (npcBase.m_iBleedType == BLEEDTYPE_PORTAL)
				{
					TE_ParticleInt(g_particleImpactPortal, damagePosition);
					TE_SendToAllInRange(damagePosition, RangeType_Visibility);
				}
			}
		}
	}
}

void CleanAllNpcArray()
{
#if defined ZR
//	Zero(played_headshotsound_already);
	Zero(f_CooldownForHurtHud_Ally);
	Zero(f_HudCooldownAntiSpam);
	Zero(f_HudCooldownAntiSpamRaid);
#endif

#if !defined RTS
	Zero(f_CooldownForHurtHud);
	Zero(f_damageAddedTogetherGametime);
#endif
}

#if !defined RTS
stock void RemoveAllDamageAddition()
{
	Zero(f_damageAddedTogether);
	Zero(f_damageAddedTogetherGametime);
}

stock void RemoveHudCooldown(int client)
{
	f_HudCooldownAntiSpam[client] = 0.0;
}

#define ZR_DEFAULT_HUD_OFFSET 0.15

#if defined ZR
float RaidHudOffsetSave[MAXPLAYERS];
#endif

/*
	0 is melee
	1 is ranged
	if true damage, do both.
*/
void ResetDamageHuds()
{
	Zero2(f_ClientDoDamageHud);
	Zero2(f_ClientDoDamageHud_Hurt);
}
void HudDamageIndicator(int client,int damagetype, bool wasattacker)
{
	if(damagetype & DMG_TRUEDAMAGE)
	{
		return;
	}
	else if(damagetype & DMG_OUTOFBOUNDS)
	{
		return;
	}
	else if(damagetype & DMG_CLUB)
	{
		if(wasattacker)
		{
			f_ClientDoDamageHud[client][0] = GetGameTime() + 1.0;
		}
		else
		{
			f_ClientDoDamageHud_Hurt[client][0] = GetGameTime() + 1.0;
		}
	}
	else
	{
		if(wasattacker)
		{
			f_ClientDoDamageHud[client][1] = GetGameTime() + 1.0;
		}
		else
		{
			f_ClientDoDamageHud_Hurt[client][1] = GetGameTime() + 1.0;
		}
	}
}
stock bool Calculate_And_Display_HP_Hud(int attacker, bool ToAlternative = false)
{
	int victim;
	if(!ToAlternative)
		victim = EntRefToEntIndexFast(i_HudVictimToDisplay[attacker]);
	else
		victim = EntRefToEntIndexFast(i_HudVictimToDisplay2[attacker]);
		
	if(!IsValidEntity(victim) || !b_ThisWasAnNpc[victim])
	{
		if(!IsValidClient(victim))
			return true;
	}

	if(!c_NpcName[victim][0])
		return true;

	if(b_NoHealthbar[victim] == 2)
	{
		//hide entirely.
		return true;
	}

#if defined ZR
	bool raidboss_active = false;
	int raid_entity = EntRefToEntIndex(RaidBossActive);
	if(IsValidEntity(raid_entity))
	{
		raidboss_active = true;
	}

	if(raidboss_active)
	{
		if(raid_entity != victim) //If a raid is alive, but the victim is not the raid! we need extra rules.
		{
			if(f_HudCooldownAntiSpam[attacker] >= GetGameTime())
				return false;
			
			f_CooldownForHurtHud_Ally[attacker] = GetGameTime() + 0.4;	
			f_HudCooldownAntiSpam[attacker] = GetGameTime() + 0.2;
		}
		else
		{
			//need a diff timer for raids, otherwise it cant display both huds!!
			if(f_HudCooldownAntiSpamRaid[attacker] >= GetGameTime())
				return false;

			f_HudCooldownAntiSpamRaid[attacker] = GetGameTime() + 0.2;
		}
	}
	else
	{
		if(f_HudCooldownAntiSpam[attacker] >= GetGameTime())
			return false;
		
		f_CooldownForHurtHud_Ally[attacker] = GetGameTime() + 0.4;	
		f_HudCooldownAntiSpam[attacker] = GetGameTime() + 0.2;		
	}
#endif
	SetGlobalTransTarget(attacker);

	int Health = GetEntProp(victim, Prop_Data, "m_iHealth");
	int MaxHealth = ReturnEntityMaxHealth(victim);
	int red = 255;
	int green = 255;
	int blue = 0;

	if(IsInvuln(victim, true))
	{
		red = 255;
		green = 255;
		blue = 255;
	}
	else
	{
#if defined RPG
		if(i_npcspawnprotection[victim] != NPC_SPAWNPROT_ON || !OnTakeDamageRpgPartyLogic(victim, attacker, GetGameTime()))
#else
		if(i_npcspawnprotection[victim] != NPC_SPAWNPROT_ON)
#endif
		{
			DisplayRGBHealthValue(Health, MaxHealth, red, green,blue);
		}
		else
		{
			red = 0;
			green = 0;
			blue = 255;
		}
	}
	if(b_HideHealth[victim])
	{
		red = 0;
		green = 255;
		blue = 0;
	}

	static char Debuff_Adder_left[128], Debuff_Adder_right[128], Debuff_Adder[128];
	EntityBuffHudShow(victim, attacker, Debuff_Adder_left, Debuff_Adder_right, sizeof(Debuff_Adder));
	Debuff_Adder[0] = 0;
	
#if defined ZR
	float GameTime = GetGameTime();
#endif
	
	CClotBody npc = view_as<CClotBody>(victim);
	
	int weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
	bool armor_added = false;
	bool ResAdded = false;
	if(IsInvuln(victim, true))
	{
		Format(Debuff_Adder, sizeof(Debuff_Adder), "%t", "Invulnerable Npc");
		armor_added = true;
	}
	else
	{
#if defined ZR
		if(Elemental_HurtHud(victim, Debuff_Adder))
		{
			armor_added = true;
		}
		float percentageGlobal = 1.0;
#endif
		float percentage_melee = 100.0;
		float percentage_ranged = 100.0;
		int testvalue = 1;
		int attackertestDo = attacker;
		float testvalue1[3];

		if(!IsInvuln(victim, true))
		{
			CheckInHudEnable(1);
			int DmgType = DMG_CLUB;
			if(GetTeam(victim) == GetTeam(attacker))
				attackertestDo = 0;

			NPC_OnTakeDamage(victim, attackertestDo, attackertestDo, percentage_melee, DmgType, weapon, testvalue1, testvalue1,testvalue);
			
			DmgType = DMG_BULLET;
			NPC_OnTakeDamage(victim, attackertestDo, attackertestDo, percentage_ranged, DmgType, weapon, testvalue1, testvalue1,testvalue);
			CheckInHudEnable(0);
			
#if defined ZR
			BarrackBody npc1 = view_as<BarrackBody>(victim);
			int client = GetClientOfUserId(npc1.OwnerUserId);
			if(IsValidClient(client))
			{
				percentageGlobal = Barracks_UnitOnTakeDamage(victim, client, percentageGlobal, false);
			}
			percentage_melee *= percentageGlobal;
			percentage_ranged *= percentageGlobal;
			//show barrak units res
#endif
		}

		if(percentage_melee != 100.0 && !IsInvuln(victim, true))
		{
			char NumberAdd[32];
			ResAdded = true;
			armor_added = true;
			if(percentage_melee < 10.0)
			{
				Format(NumberAdd, sizeof(NumberAdd), "[☛%.2f％", percentage_melee);
			}
			else
			{
				Format(NumberAdd, sizeof(NumberAdd), "[☛%.0f％", percentage_melee);
			}
			if(f_ClientDoDamageHud[attacker][0] > GetGameTime())
				Npcs_AddUnderscoreToText(NumberAdd, sizeof(NumberAdd));

			Format(Debuff_Adder, sizeof(Debuff_Adder), "%s%s", Debuff_Adder, NumberAdd);
		}
		float DamagePercDo = 100.0;
		if(!IsInvuln(victim, true))
		{
			CheckInHudEnable(2);
			StatusEffect_OnTakeDamage_DealNegative(attacker, victim, DamagePercDo, testvalue);
			Damage_NPCAttacker(victim, DamagePercDo, testvalue);
			Damage_AnyAttacker(attacker, victim, victim, DamagePercDo, testvalue);
			CheckInHudEnable(0);
#if defined ZR
			if(GetTeam(victim) != TFTeam_Red)
			{
				if(f_FreeplayDamageExtra != 1.0 && !b_thisNpcIsARaid[victim])
				{
					DamagePercDo *= f_FreeplayDamageExtra;
				}
			}
#endif
		}

		if((DamagePercDo != 100.0) && !IsInvuln(victim, true))	
		{
			if(ResAdded)
			{
				FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s|", Debuff_Adder);
				if(DamagePercDo < 10.0)
				{
					Format(Debuff_Adder, sizeof(Debuff_Adder), "%s☖%.2f％", Debuff_Adder, DamagePercDo);
				}
				else
				{
					Format(Debuff_Adder, sizeof(Debuff_Adder), "%s☖%.0f％", Debuff_Adder, DamagePercDo);
				}
			}
			else
			{	
				if(DamagePercDo < 10.0)
				{
					Format(Debuff_Adder, sizeof(Debuff_Adder), "%s [☖%.2f％", Debuff_Adder, DamagePercDo);
				}
				else
				{
					Format(Debuff_Adder, sizeof(Debuff_Adder), "%s [☖%.0f％", Debuff_Adder, DamagePercDo);
				}
			}
			ResAdded = true;
			armor_added = true;
		}

		if(percentage_ranged != 100.0 && !IsInvuln(victim, true))	
		{
			static char NumberAdd[32];
			if(ResAdded)
			{
				if(percentage_ranged < 10.0)
				{
					Format(NumberAdd, sizeof(NumberAdd), "|➶%.2f％", percentage_ranged);
				}
				else
				{
					Format(NumberAdd, sizeof(NumberAdd), "|➶%.0f％", percentage_ranged);
				}
			}
			else
			{	
				if(percentage_ranged < 10.0)
				{
					Format(NumberAdd, sizeof(NumberAdd), "[➶%.2f％", percentage_ranged);
				}
				else
				{
					Format(NumberAdd, sizeof(NumberAdd), "[➶%.0f％", percentage_ranged);
				}
			}
			if(f_ClientDoDamageHud[attacker][1] > GetGameTime())
				Npcs_AddUnderscoreToText(NumberAdd, sizeof(NumberAdd));

			armor_added = true;
			Format(Debuff_Adder, sizeof(Debuff_Adder), "%s%s", Debuff_Adder, NumberAdd);
			Format(Debuff_Adder, sizeof(Debuff_Adder), "%s]", Debuff_Adder);
		}
		else
		{
			if(ResAdded)
				FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s]", Debuff_Adder);
		}
#if defined ZR
		if(raidboss_active && raid_entity == victim)
		{
			//there is a raid, then this displays a hud below the raid hud.
			RaidHudOffsetSave[attacker] = 0.135;

			if(percentage_melee != 100.0 || percentage_ranged != 100.0 || DamagePercDo != 100.0 || DoesNpcHaveHudDebuffOrBuff(attacker, victim))
			{
				RaidHudOffsetSave[attacker] += 0.035;
			}
		}
#endif
	}

	if(armor_added)
	{
		Format(Debuff_Adder, sizeof(Debuff_Adder), "%s%s%s", Debuff_Adder_left,Debuff_Adder,Debuff_Adder_right);
	}
	else if(Debuff_Adder_left[0] || Debuff_Adder_right[0])
	{
		if(Debuff_Adder_left[0] && Debuff_Adder_right[0])
			Format(Debuff_Adder, sizeof(Debuff_Adder), "%s | %s", Debuff_Adder_left,Debuff_Adder_right);
		else
			Format(Debuff_Adder, sizeof(Debuff_Adder), "%s%s", Debuff_Adder_left,Debuff_Adder_right);
	}
#if defined ZR
	if(EntRefToEntIndex(RaidBossActive) != victim)
#endif
	{
		float HudOffset = ZR_DEFAULT_HUD_OFFSET;
#if defined ZR
		if(raidboss_active)
		{
			HudOffset += RaidHudOffsetSave[attacker];
		}
#endif
		float HudY = -1.0;

#if defined ZR || defined RPG
		HudY += f_HurtHudOffsetY[attacker];
		HudOffset += f_HurtHudOffsetX[attacker];
#endif	// ZR

		SetHudTextParams(HudY, HudOffset, 1.0, red, green, blue, 255, 0, 0.01, 0.01);
		static char ExtraHudHurt[255];
		
#if defined ZR
		if(Rogue_GetChaosLevel() > 0 && !(GetURandomInt() % 4))
			Health = RoundFloat(float(Health) * GetRandomFloat(0.5, 1.5));

		if(Rogue_GetChaosLevel() > 0 && !(GetURandomInt() % 4))
			MaxHealth = RoundFloat(float(MaxHealth) * GetRandomFloat(0.5, 1.5));
#endif

		//add name and health
		//add name and health
		static char c_Health[64];
		static char c_MaxHealth[64];
		IntToString(Health,c_Health, sizeof(c_Health));
		IntToString(MaxHealth,c_MaxHealth, sizeof(c_MaxHealth));

		int offset = Health < 0 ? 1 : 0;
		ThousandString(c_Health[offset], sizeof(c_Health) - offset);
		offset = MaxHealth < 0 ? 1 : 0;
		ThousandString(c_MaxHealth[offset], sizeof(c_MaxHealth) - offset);

		if(npc.m_flArmorCount > 0.0)
		{
			int ArmorInt = RoundToNearest(npc.m_flArmorCount);
			char c_Armor[255];
			IntToString(ArmorInt,c_Armor, sizeof(c_Armor));
			//has armor? Add extra.
			int offsetarm = ArmorInt < 0 ? 1 : 0;
			ThousandString(c_Armor[offsetarm], sizeof(c_Armor) - offsetarm);
			Format(c_Health, sizeof(c_Health), "%s+[%s]", c_Health, c_Armor);
		}
		if(b_HideHealth[victim])
		{
			Format(c_MaxHealth, sizeof(c_MaxHealth), "???");
			Format(c_Health, sizeof(c_Health), "???");
		}
		
#if defined RPG
		Format(ExtraHudHurt, sizeof(ExtraHudHurt), "Level %d", Level[victim]);
		RPGSpawns_UpdateHealthNpc(victim);
		Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s\n%s\n%s / %s",ExtraHudHurt,c_NpcName[victim], c_Health, c_MaxHealth);
#else
		if(!b_NameNoTranslation[npc.index])
		{
			Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%t\n%s / %s",c_NpcName[victim], c_Health, c_MaxHealth);
		}
		else
		{
			Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s\n%s / %s",c_NpcName[victim], c_Health, c_MaxHealth);
		}
		CClotBody npcstats = view_as<CClotBody>(victim);
		if(b_ThisWasAnNpc[victim] && npcstats.m_iHealthBar > 0)
			Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s x%i",ExtraHudHurt, npcstats.m_iHealthBar + 1);
#endif
		
		//add debuff
		if(Debuff_Adder[0])
			Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s \n%s", ExtraHudHurt, Debuff_Adder);

		if(!(b_DamageNumbers[attacker] && b_DisplayDamageHudSettingInvert[attacker])) //hide if dmg numbers on, and setting on
		{
			static char c_DmgDelt[64];
			IntToString(RoundToNearest(f_damageAddedTogether[attacker]),c_DmgDelt, sizeof(c_DmgDelt));
			offset = RoundToNearest(f_damageAddedTogether[attacker]) < 0 ? 1 : 0;
			ThousandString(c_DmgDelt[offset], sizeof(c_DmgDelt) - offset);

#if defined ZR
			if(!raidboss_active)
#endif
			{
				Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s \n-%s", ExtraHudHurt, c_DmgDelt);
			}
		}
		ShowSyncHudText(attacker, SyncHud,"%s",ExtraHudHurt);
	}
#if defined ZR
	else
	{
		float Timer_Show = RaidModeTime - GameTime;
	
		if(Timer_Show < 0.0)
			Timer_Show = 0.0;

		//if raid is on red, dont do timer.
		/*if(Timer_Show > 800.0 || GetTeam(EntRefToEntIndex(RaidBossActive)) == TFTeam_Red)
		{
			RaidModeTime = 99999999.9;
		}*/

		float HudOffset = ZR_DEFAULT_HUD_OFFSET;
		float HudY = -1.0;

		HudY += f_HurtHudOffsetY[attacker];
		HudOffset += f_HurtHudOffsetX[attacker];
			
		SetGlobalTransTarget(attacker);
		SetHudTextParams(HudY, HudOffset, 1.0, red, green, blue, 255, 0, 0.01, 0.01);
		//todo: better showcase of timer.
		static char ExtraHudHurt[168];


		//what type of boss
		if(b_thisNpcIsARaid[victim])
			Format(ExtraHudHurt, sizeof(ExtraHudHurt), "[%t", "Raidboss");
		else
			Format(ExtraHudHurt, sizeof(ExtraHudHurt), "[%t", "Superboss");

		//Does it have power? No power also hides timer showing
		if(RaidModeScaling != 0.0)
		{
			Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s|%t", ExtraHudHurt, "Power");
			//time show or not
			if(Timer_Show > 800.0)
				Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s%.1f％]", ExtraHudHurt, RaidModeScaling * 100.0);
			else
				Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s%.1f％ | %t%.1f]", ExtraHudHurt, RaidModeScaling * 100.0, "TIME LEFT", Timer_Show);
		}
		else
		{
			if(Timer_Show > 800.0)
				Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s]", ExtraHudHurt);
			else
				Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s|%t%.1f]", ExtraHudHurt, "TIME LEFT", Timer_Show);
		}
		
		//add name and health
		static char c_Health[64];
		static char c_MaxHealth[64];
		IntToString(Health,c_Health, sizeof(c_Health));
		IntToString(MaxHealth,c_MaxHealth, sizeof(c_MaxHealth));

		int offset = Health < 0 ? 1 : 0;
		ThousandString(c_Health[offset], sizeof(c_Health) - offset);
		offset = MaxHealth < 0 ? 1 : 0;
		ThousandString(c_MaxHealth[offset], sizeof(c_MaxHealth) - offset);

		if(npc.m_flArmorCount > 0.0)
		{
			int ArmorInt = RoundToNearest(npc.m_flArmorCount);
			static char c_Armor[64];
			IntToString(ArmorInt,c_Armor, sizeof(c_Armor));
			//has armor? Add extra.
			int offsetarm = ArmorInt < 0 ? 1 : 0;
			ThousandString(c_Armor[offsetarm], sizeof(c_Armor) - offsetarm);
			Format(c_Health, sizeof(c_Health), "%s+[%s]", c_Health, c_Armor);
		}
		if(b_HideHealth[victim])
		{
			Format(c_MaxHealth, sizeof(c_MaxHealth), "???");
			Format(c_Health, sizeof(c_Health), "???");
		}
		
		if(!b_NameNoTranslation[victim])
		{
			Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s\n%t\n%s / %s",ExtraHudHurt,c_NpcName[victim], c_Health, c_MaxHealth);
		}
		else
		{
			Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s\n%s\n%s / %s",ExtraHudHurt,c_NpcName[victim], c_Health, c_MaxHealth);
		}
		
		CClotBody npcstats = view_as<CClotBody>(victim);
		if(b_ThisWasAnNpc[victim] && npcstats.m_iHealthBar > 0)
			Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s x%i",ExtraHudHurt, npcstats.m_iHealthBar + 1);

		//add debuff
		if(Debuff_Adder[0])
			Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s \n%s", ExtraHudHurt, Debuff_Adder);

		if(!(b_DamageNumbers[attacker] && b_DisplayDamageHudSettingInvert[attacker])) //hide if dmg numbers on, and setting on
		{
			static char c_DmgDelt[64];
			IntToString(RoundToNearest(f_damageAddedTogether[attacker]),c_DmgDelt, sizeof(c_DmgDelt));
			offset = RoundToNearest(f_damageAddedTogether[attacker]) < 0 ? 1 : 0;
			ThousandString(c_DmgDelt[offset], sizeof(c_DmgDelt) - offset);

			Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s \n-%s", ExtraHudHurt, c_DmgDelt);	
		}
		ShowSyncHudText(attacker, SyncHudRaid, ExtraHudHurt);	

	}
#endif
	return true;
/*
#if defined RPG
	char level[32];
	Format(level, sizeof(level), "Level %d", Level[victim]);

	RPGSpawns_UpdateHealthNpc(victim);

	float HudY = -1.0;
	float HudOffset = 0.05;

	HudY += f_HurtHudOffsetY[attacker];
	HudOffset += f_HurtHudOffsetX[attacker];

	SetHudTextParams(HudY, HudOffset, 1.0, red, green, blue, 255, 0, 0.01, 0.01);
		
	//RPG cannot support translations! due to test and its used everywhere.
	char buffer[64];
	NPC_GetNameById(i_NpcInternalId[victim], buffer, sizeof(buffer));
	ShowSyncHudText(attacker, SyncHud, "%s\n%s\n%d / %d\n%s-%0.f", level, buffer, Health, MaxHealth, Debuff_Adder, f_damageAddedTogether[attacker]);
#endif
*/
}

#if !defined RTS
stock void ResetDamageHud(int client)
{
	SetHudTextParams(-1.0, 0.05, 1.0, 0, 0, 0, 255, 0, 0.01, 0.01);
	ShowSyncHudText(client, SyncHud, "");
}

stock void Calculate_And_Display_hp(int attacker, int victim, float damage, bool ignore, bool DontForward = false, bool ResetClientCooldown = false, bool RaidHudForce = false)
{
	if(b_ThisEntityIgnored[victim])
		return;
	if(attacker <= MaxClients)
	{

		//If a raid hud update happens, it should prefer to update it incase you attack something in the same frame or whaatever.
		if(RaidHudForce)
		{
			i_HudVictimToDisplay2[attacker] = EntIndexToEntRef(victim);
			b_DisplayDamageHud[attacker][1] = true;
		}
		else
		{
			b_DisplayDamageHud[attacker][0] = true;
			i_HudVictimToDisplay[attacker] = EntIndexToEntRef(victim);
		}

		float GameTime = GetGameTime();
		bool raidboss_active = false;

		if(!IsInvuln(victim, true))
		{
			if(RaidbossIgnoreBuildingsLogic())
			{
				raidboss_active = true;
			}
			if(damage > 0.0 && !DontForward)
			{
				float damageCalc = damage;
				int Health = GetEntProp(victim, Prop_Data, "m_iHealth");
				if(Health <= 0)
				{
					damageCalc += Health;
				}
				Damage_dealt_in_total[attacker] += damageCalc;
			}
			if(GameTime > f_damageAddedTogetherGametime[attacker])
			{
				if(!raidboss_active)
				{
					f_damageAddedTogether[attacker] = 0.0; //reset to 0 if raid isnt active.
				}
			}
			if(!ignore) //Cannot be a just show function
			{
				f_damageAddedTogether[attacker] += damage;
			}
			if(damage > 0.0)
			{
				f_damageAddedTogetherGametime[attacker] = GameTime + 0.6;
			}
		}
	}
	if(DontForward)
		return;
		
	if(!HasSpecificBuff(attacker, "Healing Resolve"))
		return;
	//Dont bother with the calcs if he isnt even being healed.

	for (int client = 1; client <= MaxClients; client++)
	{
		if(IsIn_HitDetectionCooldown(attacker, client, SupportDisplayHurtHud)) //if its IN cooldown!
		{
			if(IsValidClient(client))
			{
				if(ResetClientCooldown)
					RemoveHudCooldown(client);
					
				Calculate_And_Display_hp(client, victim, damage, ignore, true);
			}
		}
	}
}
#endif

stock bool DoesNpcHaveHudDebuffOrBuff(int client, int npc)
{
	static char BufferTest1[1];
	static char BufferTest2[1];
	EntityBuffHudShow(npc, client, BufferTest1, BufferTest2, sizeof(BufferTest1));
	if(BufferTest1[0] || BufferTest2[0])
		return true;

	return false;
}

void DoMeleeAnimationFrameLater(DataPack pack)
{
	pack.Reset();
	int viewmodel = EntRefToEntIndex(pack.ReadCell());
	if(viewmodel != INVALID_ENT_REFERENCE)
	{
		int animation = 38;
		switch(pack.ReadCell())
		{
			case 225, 356, 423, 461, 574, 649, 1071, 30758:  //Your Eternal Reward, Conniver's Kunai, Saxxy, Wanga Prick, Big Earner, Spy-cicle, Golden Frying Pan, Prinny Machete
				animation=12;

			case 638:  //Sharp Dresser
				animation=32;
		}
		SetEntProp(viewmodel, Prop_Send, "m_nSequence", animation);
	}
	delete pack;
}
/*
enum PlayerAnimEvent_t
{
0	PLAYERANIMEVENT_ATTACK_PRIMARY, 	
1	PLAYERANIMEVENT_ATTACK_SECONDARY,
2	PLAYERANIMEVENT_ATTACK_GRENADE,
3	PLAYERANIMEVENT_RELOAD,
4	PLAYERANIMEVENT_RELOAD_LOOP,
5	PLAYERANIMEVENT_RELOAD_END,
6	PLAYERANIMEVENT_JUMP,
7	PLAYERANIMEVENT_SWIM,
8	PLAYERANIMEVENT_DIE,
9	PLAYERANIMEVENT_FLINCH_CHEST,
10	PLAYERANIMEVENT_FLINCH_HEAD,
11	PLAYERANIMEVENT_FLINCH_LEFTARM,
12	PLAYERANIMEVENT_FLINCH_RIGHTARM,
13	PLAYERANIMEVENT_FLINCH_LEFTLEG,
14	PLAYERANIMEVENT_FLINCH_RIGHTLEG,
15	PLAYERANIMEVENT_DOUBLEJUMP,

	// Cancel.
16	PLAYERANIMEVENT_CANCEL,
17	PLAYERANIMEVENT_SPAWN,

	// Snap to current yaw exactly
18	PLAYERANIMEVENT_SNAP_YAW,

19	PLAYERANIMEVENT_CUSTOM,				// Used to play specific activities
20	PLAYERANIMEVENT_CUSTOM_GESTURE,
21	PLAYERANIMEVENT_CUSTOM_SEQUENCE,	// Used to play specific sequences
22	PLAYERANIMEVENT_CUSTOM_GESTURE_SEQUENCE,

	// TF Specific. Here until there's a derived game solution to this.
23	PLAYERANIMEVENT_ATTACK_PRE,
24	PLAYERANIMEVENT_ATTACK_POST,
25	PLAYERANIMEVENT_GRENADE1_DRAW,
26	PLAYERANIMEVENT_GRENADE2_DRAW,
27	PLAYERANIMEVENT_GRENADE1_THROW,
28	PLAYERANIMEVENT_GRENADE2_THROW,
29	PLAYERANIMEVENT_VOICE_COMMAND_GESTURE,
30	PLAYERANIMEVENT_DOUBLEJUMP_CROUCH,
31	PLAYERANIMEVENT_STUN_BEGIN,
32	PLAYERANIMEVENT_STUN_MIDDLE,
33	PLAYERANIMEVENT_STUN_END,
34	PLAYERANIMEVENT_PASSTIME_THROW_BEGIN,
35	PLAYERANIMEVENT_PASSTIME_THROW_MIDDLE,
36	PLAYERANIMEVENT_PASSTIME_THROW_END,
37	PLAYERANIMEVENT_PASSTIME_THROW_CANCEL,

38	PLAYERANIMEVENT_ATTACK_PRIMARY_SUPER,

39	PLAYERANIMEVENT_COUNT
};
*/

public void Try_Backstab_Anim_Again(int ref)
{
	int attacker = EntRefToEntIndex(ref);
	if(IsValidClient(attacker) && IsPlayerAlive(attacker))
	{
		if(Animation_Retry[attacker] > 0)
		{
			RequestFrame(Try_Backstab_Anim_Again, ref);
		}

		Animation_Retry[attacker]--;
		TE_Start("PlayerAnimEvent");
		TE_WriteEnt("m_hPlayer", attacker);
		TE_WriteNum("m_iEvent", Animation_Setting[attacker]);
		TE_WriteNum("m_nData", Animation_Index[attacker]);
		TE_SendToAll();
	}
}

void NPC_DeadEffects(int entity)
{

#if defined ZR		
	RemoveNpcFromZombiesLeftCounter(entity);
	if(GetTeam(entity) != TFTeam_Red)
#endif

	{
		
#if defined ZR		
		DropPowerupChance(entity);
		Gift_DropChance(entity);
#endif
		
		int WeaponLastHit = EntRefToEntIndex(LastHitWeaponRef[entity]);
		int client = EntRefToEntIndex(LastHitRef[entity]);
		if(client > 0 && client <= MaxClients)
		{
			
#if defined ZR
			if(!Classic_Mode())
				GiveXP(client, 1);
			
			Saga_DeadEffects(entity, client, WeaponLastHit);
			Native_OnKilledNPC(client, c_NpcName[entity]);
#endif
			
#if defined RPG
			Stats_SetHasKill(client, c_NpcName[entity]);
			Quests_AddKill(client, entity);
			Spawns_NPCDeath(entity, client, WeaponLastHit);
#endif

			Attributes_OnKill(entity, client, WeaponLastHit);
		}
	}
}

#if defined ZR
stock void CleanAllAppliedEffects_BombImplanter(int entity, bool do_boom = false)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if(do_boom)
		{
			//Its 0 for no reason, i only ever set it to 0 here or in the m2 terroiser one
			if(i_HowManyBombsOnThisEntity[entity][client] > 0)
			{
				if(IsValidClient(client))
				{
					Cause_Terroriser_Explosion(client, entity);
				}
			}
		}
		//This is the only time it happens ever
		i_HowManyBombsHud[entity] = 0;
		i_HowManyBombsOnThisEntity[entity][client] = 0;
		f_BombEntityWeaponDamageApplied[entity][client] = 0.0;
	}
}
#endif

void BackstabNpcInternalModifExtra(int weapon, int attacker, int victim, float multi)
{
#if defined ZR
	if(dieingstate[attacker] > 0)
		return;

#endif
	float HealTime = f_BackstabHealOverThisDuration[weapon];
	float HealTotal = f_BackstabHealTotal[weapon];
	if(HealTotal <= 0.0)
		return;
	//If against raids, heal more and damage more.
	if(b_thisNpcIsARaid[victim])
	{
		HealTotal *= 2.0;
	}
	HealTotal *= multi;
#if defined ZR
	if(b_FaceStabber[attacker])
	{
		HealTotal *= 0.25;
	}
#endif
	HealEntityGlobal(attacker, attacker, HealTotal, 1.0, HealTime, HEAL_SELFHEAL);
}

#if defined ZR
void OnKillUniqueWeapon(int attacker, int weapon, int victim)
{
	if(!IsValidEntity(weapon))
		return;

	if(!IsValidClient(attacker))
		return;
		
	if(i_HasBeenBackstabbed[victim])
	{
		BackstabNpcInternalModifExtra(weapon, attacker, victim, 1.0);
	}

	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_MLYNAR:
		{
			MlynarReduceDamageOnKill(attacker);
		}
		case WEAPON_MLYNAR_PAP:
		{
			MlynarReduceDamageOnKill(attacker, 1);
		}
		case WEAPON_MLYNAR_PAP_2:
		{
			MlynarReduceDamageOnKill(attacker, 2);
		}
		case WEAPON_CASINO:
		{
			CasinoSalaryPerKill(attacker, weapon);
		}
		case WEAPON_RAPIER:
		{
			RapierEndDuelOnKill(attacker, victim);
		}
		case WEAPON_MAGNESIS:
		{
			Magnesis_OnKill(victim);
		}
		case WEAPON_WRATHFUL_BLADE:
		{
			WrathfulBlade_OnKill(attacker, victim);
		}
		case WEAPON_CASTLEBREAKER:
		{
			CastleBreakerCashOnKill(attacker);
		}
		case WEAPON_RAIGEKI:
		{
			Raigeki_OnKill(attacker, victim);
		}
		default:Weapon_AddonsCustom_OnKill(attacker);
	}
}
#endif

stock void OnPostAttackUniqueWeapon(int attacker, int victim, int weapon, int damage_custom_zr)
{
	if(!IsValidEntity(weapon))
		return;

	if(!IsValidClient(attacker))
		return;

#if defined ZR
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_MLYNAR:
		{
			if(b_thisNpcIsARaid[victim] && (!(damage_custom_zr & ZR_DAMAGE_REFLECT_LOGIC))) //do not reduce damage if the damage type was a reflect.
				MlynarTakeDamagePostRaid(attacker);
		}
		case WEAPON_MLYNAR_PAP:
		{
			if(b_thisNpcIsARaid[victim] && (!(damage_custom_zr & ZR_DAMAGE_REFLECT_LOGIC))) //do not reduce damage if the damage type was a reflect.
				MlynarTakeDamagePostRaid(attacker, 1);
		}
		case WEAPON_MLYNAR_PAP_2:
		{
			if(b_thisNpcIsARaid[victim] && (!(damage_custom_zr & ZR_DAMAGE_REFLECT_LOGIC))) //do not reduce damage if the damage type was a reflect.
				MlynarTakeDamagePostRaid(attacker, 2);
		}
	}
#endif
}

stock void DisplayRGBHealthValue(int Health_init, int Maxhealth_init, int &red, int &green, int &blue)
{
	int Health = Health_init;
	int MaxHealth = Maxhealth_init;

	if(MaxHealth > 1000000) //the numbers are too great! it breaks the limits of numbers
	{
		Health /= 1000;
		MaxHealth /= 1000;
	}
	red = (Health + 1) * 255  / (MaxHealth + 1);
	//	blue = GetEntProp(entity, Prop_Send, "m_iHealth") * 255  / Building_Max_Health[entity];
	green = (Health + 1) * 255  / (MaxHealth + 1);
				
	red = 255 - red;
			
	if(Health <= 0)
	{
		red = 255;
		green = 0;
		blue = 0;
	}
	else if(Health >= MaxHealth)
	{
		red = 0;
		green = 255;
		blue = 0;				
	}
}

#if defined ZR
void GiveProgressDelay(float Time)
{
	f_DelayNextWaveStartAdvancing = GetGameTime() + Time;
}
#endif

#if defined ZR
int MaxNpcEnemyAllowed()
{
	return RoundToNearest(float(NPC_HARD_LIMIT) * zr_multi_maxenemiesalive_cap.FloatValue);
}

float MaxEnemyMulti()
{
/*	if(VIPBuilding_Active())
	{
		if(Waves_GetWave() + 1 >= 100)
		{
			return 1.0;
		}
		else
		{
			return 1.5;
		}
	}*/
	return 1.0;
}

int MaxEnemiesAllowedSpawnNext(int ExtraRules = 0)
{
	int maxenemies = LimitNpcs;
	if(KamikazeEventHappening())
	{
		maxenemies /= 2;
	}
	switch(ExtraRules)
	{
		case 1:
		{
			maxenemies = RoundToCeil(float(maxenemies) * 1.25);
		}
	}
	maxenemies = RoundToCeil(float(maxenemies) * ZRModifs_MaxSpawnsAlive());
	return maxenemies;
}
#endif

stock void ThousandString(char[] buffer, int length)
{
	char[] buffer2 = new char[length];

	int i;
	int size = strlen(buffer);
	int when = size%3;
	if(size <= 3)
	{
		return;
	}
	for(int a; i<length && a<size; a++)
	{
		if(i && a%3 == when)
		{
			buffer2[i] = ',';
			i++;
		}

		if(i < length)
		{
			buffer2[i] = buffer[a];
			i++;
		}
	}

	strcopy(buffer, length, buffer2);
}

void Npcs_AddUnderscoreToText(char[] buffer, int lengthstring)
{
	static char AddUnderscore[4];
	/*
		hmmm....
		it seems i cant underline in sp...
		whis!
		get the cringe code!
	*/
	if(!AddUnderscore[0])
	{
		//Init the wierd letter
		Format(AddUnderscore, sizeof(AddUnderscore), "%s", "A͟");
		ReplaceString(AddUnderscore, sizeof(AddUnderscore), "A", "");
	}
	int length = strlen(buffer);
	char ExportChar[255];
	for(int a; a<length; a++)
	{
		static char CharTemp[8];
		//Do the letter

		//Last two Letters
		//Subtract one as it overflows to the right a bit.
		if(a >= length - 3)
		{
			Format(CharTemp, sizeof(CharTemp), "%c", buffer[a]);
		}
		else
		{
			if(!IsCharMB(buffer[a]))
			{
				//Its a multi byte character
		//		PrintToChatAll("Im a single byte");
				//Its a single byte character
				Format(CharTemp, sizeof(CharTemp), "%c%s", buffer[a], AddUnderscore);
			}
			else
			{
				static char CharAdd[4];
				/*
					Well multibyte is VERY special.
					Cant use %c%c It just breaks it. beacuse screw you, i guess...
				*/

		//		PrintToChatAll("Im a Multibyte");
				Format(CharAdd, sizeof(CharAdd), "%s", buffer[a]);
				Format(CharTemp, sizeof(CharTemp), "%s%s", CharAdd, AddUnderscore);
				a++;
				a++;
				//We cant skip 3 for some reason, idk, it just works, idc.
			}
		}

		//Add letter to master
		Format(ExportChar, sizeof(ExportChar), "%s%s", ExportChar, CharTemp);
	}
	//Send back into main string
	Format(buffer, lengthstring, "%s", ExportChar);
}
/*
stock int StrLenMB(const char[] str)
{
	int len = strlen(str);
	int count;
	for(int i; i < len; i++)
	{
		count += ((str[i] & 0xc0) != 0x80) ? 1 : 0;
	}
	return count;
}  
*/