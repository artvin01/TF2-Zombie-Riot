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
	g_particleMissText = PrecacheParticleSystem("miss_text");
#endif
	g_particleCritText = PrecacheParticleSystem("crit_text");
	g_particleMiniCritText = PrecacheParticleSystem("minicrit_text");
}

void NPC_PluginStart()
{
#if defined ZR
	SyncHudRaid = CreateHudSynchronizer();
#endif

	SyncHud = CreateHudSynchronizer();
	
}

#if defined ZR
public void NPC_SpawnNext(bool panzer, bool panzer_warning)
{
	float GameTime = GetGameTime();
	if(f_DelaySpawnsForVariousReasons > GameTime)
	{
		return;
	}
	int limit = 0;
	
	if(CvarNoSpecialZombieSpawn.BoolValue)//PLEASE ASK CRUSTY FOR MODELS
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

		float f_limit = Pow(1.115, float(CountPlayersOnRed()));
	//	float f_limit_alive = Pow(1.115, float(CountPlayersOnRed(2)));

		f_limit *= float(limit);
	//	f_limit_alive *= float(limit);
		
		for(int client=1; client<=MaxClients; client++)
		{
			if(!b_IsPlayerABot[client] && IsClientInGame(client) && GetClientTeam(client)==2 && TeutonType[client] != TEUTON_WAITING && b_HasBeenHereSinceStartOfWave[client])
			{
				if(TeutonType[client] == TEUTON_DEAD || dieingstate[client] > 0)
				{
					GlobalIntencity += 1;
				}
				PlayersInGame += 1;

				if(Level[client] > 7)
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

	//	if(RoundToNearest(f_limit_alive) >= MaxNpcEnemyAllowed())
	//		f_limit_alive = float(MaxNpcEnemyAllowed());
			
		
		if(PlayersAliveScaling >= MaxNpcEnemyAllowed())
			PlayersAliveScaling = MaxNpcEnemyAllowed();

		LimitNpcs = RoundToNearest(f_limit);
	}
	
	if(!b_GameOnGoing) //no spawn if the round is over
	{
		return;
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
				int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount_again_2]);
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
		if(EnemyNpcAlive >= MaxEnemiesAllowedSpawnNext())
		{
			return;
		}
	}

	if(!Spawns_CanSpawnNext(Rogue_Mode()))
		return;
	
	float pos[3], ang[3];

	MiniBoss boss;
	if(panzer && Waves_GetMiniBoss(boss))
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
		}
		else
		{
			PrintToChatAll("SPAWN FAILED (Mini-Boss)");
		}
	}
	else
	{
		Enemy enemy;
		if(Waves_GetNextEnemy(enemy))
		{
			if(Spawns_GetNextPos(pos, ang, enemy.Spawn))
			{
				int entity_Spawner = NPC_CreateById(enemy.Index, -1, pos, ang, enemy.Team, enemy.Data);
				if(entity_Spawner != -1)
				{
					if(GetTeam(entity_Spawner) != TFTeam_Red)
					{
						NpcAddedToZombiesLeftCurrently(entity_Spawner, false);
					}
					if(enemy.Is_Outlined)
					{
						b_thisNpcHasAnOutline[entity_Spawner] = true;
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
					
					CClotBody npcstats = view_as<CClotBody>(entity_Spawner);
					
					npcstats.m_bStaticNPC = enemy.Is_Static;
					if(enemy.Is_Static && enemy.Team != TFTeam_Red)
					{
						AddNpcToAliveList(entity_Spawner, 1);
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
					
					if(enemy.Credits && MultiGlobalEnemy)
						npcstats.m_fCreditsOnKill = enemy.Credits / MultiGlobalEnemy;

					fl_Extra_MeleeArmor[entity_Spawner] 	= enemy.ExtraMeleeRes;
					fl_Extra_RangedArmor[entity_Spawner] 	= enemy.ExtraRangedRes;
					fl_Extra_Speed[entity_Spawner] 			= enemy.ExtraSpeed;
					fl_Extra_Damage[entity_Spawner] 		= enemy.ExtraDamage;
					if(!b_thisNpcIsARaid[entity_Spawner] && XenoExtraLogic(true))
					{
						fl_Extra_Damage[entity_Spawner] *= 1.1;
					}
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

					if(zr_spawnprotectiontime.FloatValue > 0.0)
					{
				
						b_npcspawnprotection[entity_Spawner] = true;
						
						/*
						CClotBody npc = view_as<CClotBody>(entity_Spawner);
						npc.m_iSpawnProtectionEntity = TF2_CreateGlow(npc.index);
				
						SetVariantColor(view_as<int>({0, 255, 0, 100}));
						AcceptEntityInput(npc.m_iSpawnProtectionEntity, "SetGlowColor");
						*/
						
						CreateTimer(zr_spawnprotectiontime.FloatValue, Remove_Spawn_Protection, EntIndexToEntRef(entity_Spawner), TIMER_FLAG_NO_MAPCHANGE);
					}

					if(Waves_InFreeplay())
						Freeplay_SpawnEnemy(entity_Spawner);
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
				if(EnemyNpcAliveStatic >= 1)
				{
					donotprogress = false;
				}
			}
			if(f_DelayNextWaveStartAdvancing < GetGameTime())
			{
				Waves_Progress(donotprogress);
			}
		}
	}
}
#endif	// ZR

public Action Remove_Spawn_Protection(Handle timer, int ref)
{
	int index = EntRefToEntIndex(ref);
	if(IsValidEntity(index) && index>MaxClients)
	{
		CClotBody npc = view_as<CClotBody>(index);
			
		if(IsValidEntity(npc.m_iSpawnProtectionEntity))
			RemoveEntity(npc.m_iSpawnProtectionEntity);
		
		b_npcspawnprotection[index] = false;
	}
	return Plugin_Stop;
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
	
	int entity = NPC_CreateById(index, -1, pos, ang, TFTeam_Blue);
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
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) * healthmulti));
		}
		
		b_NpcForcepowerupspawn[entity] = forcepowerup;

		if(Waves_InFreeplay())
			Freeplay_SpawnEnemy(entity);
	}

	return Plugin_Stop;
}
#endif


void NPC_Ignite(int entity, int attacker, float duration, int weapon)
{
	bool wasBurning = view_as<bool>(IgniteFor[entity]);

	IgniteFor[entity] += RoundToCeil(duration*2.0);
	if(IgniteFor[entity] > 20)
		IgniteFor[entity] = 20;
	
	if(!IgniteTimer[entity])
		IgniteTimer[entity] = CreateTimer(0.5, NPC_TimerIgnite, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	float value = 8.0;
	bool validWeapon = false;

#if !defined RTS
	if(weapon > MaxClients && IsValidEntity(weapon))
	{
		validWeapon = true;
		value *= Attributes_FindOnWeapon(attacker, weapon, 2, true, 1.0);	  //For normal weapons
			
		value *= Attributes_FindOnWeapon(attacker, weapon, 410, true, 1.0); //For wand
					
		value *= Attributes_FindOnWeapon(attacker, weapon, 71, true, 1.0); //For wand
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
		IgniteTargetEffect(entity);
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
	if(entity > MaxClients)
	{
		if(!b_NpcHasDied[entity])
		{
			int attacker = EntRefToEntIndex(IgniteId[entity]);
			if(attacker != INVALID_ENT_REFERENCE)
			{
				IgniteFor[entity]--;
				
				float pos[3], ang[3];
				if(attacker > 0 && attacker <= MaxClients)
					GetClientEyeAngles(attacker, ang);
				
				int weapon = EntRefToEntIndex(IgniteRef[entity]);
				float value = 8.0;
#if !defined RTS
				if(weapon > MaxClients && IsValidEntity(weapon))
				{
					value *= Attributes_FindOnWeapon(attacker, weapon, 2, true, 1.0);	  //For normal weapons
					
					value *= Attributes_FindOnWeapon(attacker, weapon, 1000, true, 1.0); //For any
					
					value *= Attributes_FindOnWeapon(attacker, weapon, 410, true, 1.0); //For wand
					
					value *= Attributes_FindOnWeapon(attacker, weapon, 71, true, 1.0); //For wand

				}
				else
#endif
				{
					weapon = -1;
				}
				
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
				//Burn damage should pierce any resistances because its too hard to keep track off, and its not common.
				SDKHooks_TakeDamage(entity, attacker, attacker, value, DMG_SLASH, weapon, ang, pos, false, (ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED | ZR_DAMAGE_IGNORE_DEATH_PENALTY ));
				
				//Setting burn dmg to slash cus i want it to work with melee!!!
				//Also yes this means burn and bleed are basically the same, excluding that burn doesnt stack.
				//In this case ill buff it so its 2x as good as bleed! or more in the future
				//Also now allows hp gain and other stuff for that reason. pretty cool.
				if(IgniteFor[entity] == 0)
				{
					ExtinguishTarget(entity);
					IgniteTimer[entity] = null;
					IgniteFor[entity] = 0;
					BurnDamage[entity] = 0.0;
					return Plugin_Stop;
				}
				if(f_NpcImmuneToBleed[entity] > GetGameTime())
				{
					ExtinguishTarget(entity);
					IgniteTimer[entity] = null;
					IgniteFor[entity] = 0;
					BurnDamage[entity] = 0.0;
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
				return Plugin_Stop;		
			}
		}
		else
		{
			ExtinguishTarget(entity);
			IgniteTimer[entity] = null;
			IgniteFor[entity] = 0;
			BurnDamage[entity] = 0.0;
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

	if(b_NpcIsInvulnerable[victim])
		return Plugin_Continue;
		
	if((damagetype & (DMG_BLAST))) //make sure any hitscan boom type isnt actually boom
	{
		f_IsThisExplosiveHitscan[attacker] = GetGameTime();
		damagetype |= DMG_BULLET; //add bullet logic
		damagetype &= ~DMG_BLAST; //remove blast logic	
	}
	else
	{
		f_IsThisExplosiveHitscan[attacker] = 0.0;
	}
	
//	if((damagetype & (DMG_BULLET)) || (damagetype & (DMG_BUCKSHOT))) // Needed, other crap for some reason can trigger headshots, so just make sure only bullets can do this.
	int weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
	if(IsValidEntity(weapon))
	{
		f_TraceAttackWasTriggeredSameFrame[victim] = GetGameTime();
		i_HasBeenHeadShotted[victim] = false;
#if defined ZR || defined RPG
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

				damage *= Pow(WeaponDamageFalloff, (distance/1000000.0)); //this is 1000, we use squared for optimisations sake
			}
		}

		if(!i_WeaponCannotHeadshot[weapon])
		{
			bool Blitzed_By_Riot = false;
			if(f_TargetWasBlitzedByRiotShield[victim][weapon] > GetGameTime())
			{
				Blitzed_By_Riot = true;
			}
			if(f_HeadshotDamageMultiNpc[victim] <= 0.0 && hitgroup == HITGROUP_HEAD)
			{
				damage = 0.0;
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
				return Plugin_Handled;
			}
			if((hitgroup == HITGROUP_HEAD && !b_CannotBeHeadshot[victim]) || Blitzed_By_Riot)
			{
#if defined ZR 
				if(b_ThisNpcIsSawrunner[victim])
				{
					damage *= 2.0;
				}
#endif	// ZR

				damage *= f_HeadshotDamageMultiNpc[victim];
				if(i_HeadshotAffinity[attacker] == 1)
				{
					damage *= 2.0;
				}
				else
				{
					damage *= 1.65;
				}

				if(Blitzed_By_Riot) //Extra damage.
				{
					damage *= 1.35;
				}
				else
				{
					i_HasBeenHeadShotted[victim] = true; //shouldnt count as an actual headshot!
				}

				if(i_CurrentEquippedPerk[attacker] == 5) //I guesswe can make it stack.
				{
					damage *= 1.25;
				}
				
				int pitch = GetRandomInt(90, 110);
				int random_case = GetRandomInt(1, 2);
				float volume = 0.7;
				
				if(played_headshotsound_already[attacker] >= GetGameTime())
				{
					random_case = played_headshotsound_already_Case[attacker];
					pitch = played_headshotsound_already_Pitch[attacker];
					volume = 0.15;
				}
				else
				{
					DisplayCritAboveNpc(victim, attacker, Blitzed_By_Riot);
					played_headshotsound_already_Case[attacker] = random_case;
					played_headshotsound_already_Pitch[attacker] = pitch;
				}
				
#if defined ZR 
				if(i_ArsenalBombImplanter[weapon] > 0)
				{
					float damage_save = 50.0;
					damage_save *= Attributes_Get(weapon, 2, 1.0);
					f_BombEntityWeaponDamageApplied[victim][attacker] = damage_save;
					int BombsToInject = i_ArsenalBombImplanter[weapon];
					if(i_CurrentEquippedPerk[attacker] == 5) //I guesswe can make it stack.
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
					i_HowManyBombsOnThisEntity[victim][attacker] += BombsToInject;
					i_HowManyBombsHud[victim] += BombsToInject;
					Apply_Particle_Teroriser_Indicator(victim);
					damage = 0.0;
				}
#endif	// ZR
				played_headshotsound_already[attacker] = GetGameTime();

				if(!Blitzed_By_Riot) //dont play headshot sound if blized.
				{
					switch(random_case)
					{
						case 1:
						{
							for(int client=1; client<=MaxClients; client++)
							{
								if(IsClientInGame(client) && client != attacker)
								{
									EmitCustomToClient(client, "zombiesurvival/headshot1.wav", victim, _, 80, _, volume, pitch);
								}
							}
							EmitCustomToClient(attacker, "zombiesurvival/headshot1.wav", _, _, 90, _, volume, pitch);
						}
						case 2:
						{
							for(int client=1; client<=MaxClients; client++)
							{
								if(IsClientInGame(client) && client != attacker)
								{
									EmitCustomToClient(client, "zombiesurvival/headshot2.wav", victim, _, 80, _, volume, pitch);
								}
							}
							EmitCustomToClient(attacker, "zombiesurvival/headshot2.wav", _, _, 90, _, volume, pitch);
						}
					}
				}
				return Plugin_Changed;
			}
		}
#endif
#if defined ZR
			else
			{
				if(i_ArsenalBombImplanter[weapon] > 0)
				{
					float damage_save = 50.0;
					damage_save *= Attributes_Get(weapon, 2, 1.0);
					f_BombEntityWeaponDamageApplied[victim][attacker] = damage_save;
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
						
					i_HowManyBombsOnThisEntity[victim][attacker] += BombsToInject;
					i_HowManyBombsHud[victim] += BombsToInject;
					Apply_Particle_Teroriser_Indicator(victim);
					damage = 0.0;
				}

				if(i_HeadshotAffinity[attacker] == 1)
				{
					damage *= 0.65;
					return Plugin_Changed;
				}
				return Plugin_Changed;
			}
#endif	// ZR
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
	float damage_Caclulation = damage;
		
	//for some reason it doesnt do it by itself, im baffeled.

	if(Health < 0)
		damage_Caclulation += float(Health);
	
	if(damage_Caclulation > 0.0) //idk i guess my math is off or that singular/10 frames of them being still being there somehow impacts this, cannot go around this, delay is a must
		Damage_dealt_in_total[attacker] += damage_Caclulation;	//otherwise alot of other issues pop up.
	
	Damage_dealt_in_total[attacker] += damage_Caclulation;
#endif
	
	Event event = CreateEvent("npc_hurt");
	if (event) 
	{
		event.SetInt("entindex", victim);
		event.SetInt("health", Health > 0 ? Health : 0);
		event.SetInt("damageamount", RoundToFloor(damage));
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
	float GameTime = GetGameTime();
	b_DoNotDisplayHurtHud[victim] = false;
	//LogEntryInvicibleTest(victim, attacker, damage, 1);
	//sommetimes, the game sets it to 1 somehow, in the future find a better fix for this.
	SetEntProp(victim, Prop_Data, "m_lifeState", 0);
	
#if defined ZR
	if((damagetype & DMG_DROWN) && !b_ThisNpcIsSawrunner[attacker])
#else
	if((damagetype & DMG_DROWN))
#endif
	{
		damage = 5.0;
		Damageaftercalc = 5.0;
		TeleportBackToLastSavePosition(victim);
		return Plugin_Handled;
	}
	//LogEntryInvicibleTest(victim, attacker, damage, 2);
	// if your damage is higher then a million, we give up and let it through, theres multiple reasons why, mainly slaying.
	if(b_NpcIsInvulnerable[victim] && damage < 9999999.9)
	{
		damage = 0.0;
		Damageaftercalc = 0.0;
		return Plugin_Handled;
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
	else if(damage < 9999999.9)
	{
		if(Damage_Modifiy(victim, attacker, inflictor, damage, damage, damagetype, weapon, damageForce, damagePosition, damagecustom))
		{
			return Plugin_Handled;
		}

#if defined ZR
		if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS))
		{
			if(SeargentIdeal_Existant())
			{
				//LogEntryInvicibleTest(victim, attacker, damage, 17);
				SeargentIdeal_Protect(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
				if(damage == 0.0)
				{
					b_DoNotDisplayHurtHud[victim] = true;
					return Plugin_Handled;
				}
				//LogEntryInvicibleTest(victim, attacker, damage, 18);
			}
		}
		//LogEntryInvicibleTest(victim, attacker, damage, 19);
#endif

	}
	//LogEntryInvicibleTest(victim, attacker, damage, 20);

#if defined ZR
	if(inflictor > 0 && inflictor < MaxClients)
	{
		if(f_Data_InBattleHudDisableDelay[inflictor] + 2.0 != 0.0)
		{
			f_InBattleHudDisableDelay[inflictor] = GetGameTime() + f_Data_InBattleHudDisableDelay[inflictor] + 2.0;
		}
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
		else if(damage > (GetEntProp(victim, Prop_Data, "m_iMaxHealth") * 1.5))
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
		return;
		
	int AttackerOverride = EntRefToEntIndex(i_NpcOverrideAttacker[attacker]);
	if(AttackerOverride > 0)
	{
		attacker = AttackerOverride;
	}		
	//LogEntryInvicibleTest(victim, attacker, damage, 26);
#endif
	int health = GetEntProp(victim, Prop_Data, "m_iHealth");
#if defined ZR
	if((Damageaftercalc > 0.0 || b_NpcIsInvulnerable[victim] || (weapon > -1 && i_ArsenalBombImplanter[weapon] > 0)) && !b_DoNotDisplayHurtHud[victim]) //make sure to still show it if they are invinceable!
#else
	if((Damageaftercalc > 0.0 || b_NpcIsInvulnerable[victim]) && !b_DoNotDisplayHurtHud[victim]) //make sure to still show it if they are invinceable!
#endif
	{

#if !defined RTS
	if(inflictor > 0 && inflictor <= MaxClients)
	{
		GiveRageOnDamage(inflictor, Damageaftercalc);
		Calculate_And_Display_hp(inflictor, victim, Damageaftercalc, false);
	}
	else if(attacker > 0 && attacker <= MaxClients)
	{
		GiveRageOnDamage(attacker, Damageaftercalc);
		Calculate_And_Display_hp(attacker, victim, Damageaftercalc, false);	
	}
	OnPostAttackUniqueWeapon(attacker, victim, weapon, i_HexCustomDamageTypes[victim]);
#endif

		Event event = CreateEvent("npc_hurt");
		if(event) 
		{
			event.SetInt("entindex", victim);
			event.SetInt("health", health);
			event.SetInt("damageamount", RoundToFloor(Damageaftercalc));
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

	//LogEntryInvicibleTest(victim, attacker, damage, 27);
	bool SlayNpc = true;
	if(health >= 1)
	{
		SlayNpc = false;
	}
	if(b_NpcIsInvulnerable[victim])
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
	
	//LogEntryInvicibleTest(victim, attacker, damage, 29);
	if(SlayNpc)
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
				f_CooldownForHurtParticle[victim] = GameTime + 0.1;
				if(npcBase.m_iBleedType == BLEEDTYPE_NORMAL)
				{
					TE_ParticleInt(g_particleImpactFlesh, damagePosition);
					TE_SendToAll();
				}
				else if (npcBase.m_iBleedType == BLEEDTYPE_METAL)
				{
					damagePosition[2] -= 40.0;
					TE_ParticleInt(g_particleImpactMetal, damagePosition);
					TE_SendToAll();
				}
				else if (npcBase.m_iBleedType == BLEEDTYPE_RUBBER)
				{
					TE_ParticleInt(g_particleImpactRubber, damagePosition);
					TE_SendToAll();
				}
				else if (npcBase.m_iBleedType == BLEEDTYPE_XENO)
				{
					//If you cant find any good blood effect, use this one and just recolour it.
					TE_BloodSprite(damagePosition, { 0.0, 0.0, 0.0 }, 125, 255, 125, 255, 32);
					TE_SendToAll();
				}
				else if (npcBase.m_iBleedType == BLEEDTYPE_SEABORN)
				{
					//If you cant find any good blood effect, use this one and just recolour it.
					TE_BloodSprite(damagePosition, { 0.0, 0.0, 0.0 }, 65, 65, 255, 255, 32);
					TE_SendToAll();
				}
			}
		}
	}
}

#if !defined RTS
static float f_damageAddedTogether[MAXTF2PLAYERS];
static float f_damageAddedTogetherGametime[MAXTF2PLAYERS];
static int i_HudVictimToDisplay[MAXTF2PLAYERS];
#endif

void CleanAllNpcArray()
{
#if defined ZR
	Zero(played_headshotsound_already);
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

stock bool Calculate_And_Display_HP_Hud(int attacker)
{
	int victim = EntRefToEntIndex(i_HudVictimToDisplay[attacker]);
	if(!IsValidEntity(victim) || !b_ThisWasAnNpc[victim])
	{
		if(!IsValidClient(victim))
			return true;
	}

	if(!c_NpcName[victim][0])
		return true;

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
	int MaxHealth = GetEntProp(victim, Prop_Data, "m_iMaxHealth");
	int red = 255;
	int green = 255;
	int blue = 0;

	if(b_NpcIsInvulnerable[victim])
	{
		red = 255;
		green = 255;
		blue = 255;
	}
	else
	{
#if defined RPG
		if(!b_npcspawnprotection[victim] || !OnTakeDamageRpgPartyLogic(victim, attacker, GetGameTime()))
#else
		if(!b_npcspawnprotection[victim])
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
	char Debuff_Adder_left[64];
	char Debuff_Adder_right[64];
	char Debuff_Adder[64];
	EntityBuffHudShow(victim, attacker, Debuff_Adder_left, Debuff_Adder_right);
	
	float GameTime = GetGameTime();

	
	CClotBody npc = view_as<CClotBody>(victim);
	
	int weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
	bool armor_added = false;
	bool ResAdded = false;
	
	if(b_NpcIsInvulnerable[victim])
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
#endif
		float percentage;
		if(NpcHadArmorType(victim, 2, weapon, attacker) && !b_NpcIsInvulnerable[victim])	
		{
			percentage = npc.m_flMeleeArmor * 100.0;
			percentage *= fl_Extra_MeleeArmor[victim];
			percentage *= fl_TotalArmor[victim];
			int testvalue = 1;
			int DmgType = DMG_CLUB;
			OnTakeDamageResistanceBuffs(victim, testvalue, testvalue, percentage, DmgType, testvalue, GetGameTime());

#if defined ZR
			if(!b_thisNpcIsARaid[victim] && GetTeam(victim) != TFTeam_Red && XenoExtraLogic(true))
			{
				percentage *= 0.85;
			}
#endif

#if defined ZR
			if(weapon > 0 && attacker > 0)
				percentage *= Siccerino_Melee_DmgBonus(victim, attacker, weapon);

			if(!NpcStats_IsEnemySilenced(victim))
			{
				if(Medival_Difficulty_Level != 0.0 && GetTeam(victim) != TFTeam_Red)
				{
					percentage *= Medival_Difficulty_Level;
				}
			}
			if(VausMagicaShieldLogicEnabled(victim))
				percentage *= 0.25;
#endif
		
			
			if(percentage < 10.0)
			{
				Format(Debuff_Adder, sizeof(Debuff_Adder), "%s [☛%.2f%%", Debuff_Adder, percentage);
				ResAdded = true;
			}
			else
			{
				Format(Debuff_Adder, sizeof(Debuff_Adder), "%s [☛%.0f%%", Debuff_Adder, percentage);
				ResAdded = true;
			}
			armor_added = true;
		}
		
		if(NpcHadArmorType(victim, 1) && !b_NpcIsInvulnerable[victim])	
		{
			percentage = npc.m_flRangedArmor * 100.0;
			percentage *= fl_Extra_RangedArmor[victim];
			percentage *= fl_TotalArmor[victim];
			int testvalue = 1;
			int DmgType = DMG_BULLET;
			OnTakeDamageResistanceBuffs(victim, testvalue, testvalue, percentage, DmgType, testvalue, GetGameTime());

#if defined ZR
			if(!b_thisNpcIsARaid[victim] && GetTeam(victim) != TFTeam_Red && XenoExtraLogic(true))
			{
				percentage *= 0.85;
			}
			
			if(!NpcStats_IsEnemySilenced(victim))
			{
				if(Medival_Difficulty_Level != 0.0 && GetTeam(victim) != TFTeam_Red)
				{
					percentage *= Medival_Difficulty_Level;
				}
			}

			if(VausMagicaShieldLogicEnabled(victim))
				percentage *= 0.25;

#endif
			if(ResAdded)
			{
				FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s|", Debuff_Adder);
				if(percentage < 10.0)
				{
					Format(Debuff_Adder, sizeof(Debuff_Adder), "%s➶%.2f%%]", Debuff_Adder, percentage);
				}
				else
				{
					Format(Debuff_Adder, sizeof(Debuff_Adder), "%s➶%.0f%%]", Debuff_Adder, percentage);
				}
			}
			else
			{	
				if(percentage < 10.0)
				{
					Format(Debuff_Adder, sizeof(Debuff_Adder), "%s [➶%.2f%%]", Debuff_Adder, percentage);
				}
				else
				{
					Format(Debuff_Adder, sizeof(Debuff_Adder), "%s [➶%.0f%%]", Debuff_Adder, percentage);
				}
			}
			armor_added = true;
		}
		else
		{
			if(ResAdded)
				FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s]", Debuff_Adder);
		}
	}

	if(armor_added)
	{
		Format(Debuff_Adder, sizeof(Debuff_Adder), "%s%s%s\n", Debuff_Adder_left,Debuff_Adder,Debuff_Adder_right);
	}
	else if(Debuff_Adder_left[0] || Debuff_Adder_right[0])
	{
		if(Debuff_Adder_left[0] && Debuff_Adder_right[0])
			Format(Debuff_Adder, sizeof(Debuff_Adder), "%s | %s\n", Debuff_Adder_left,Debuff_Adder_right);
		else
			Format(Debuff_Adder, sizeof(Debuff_Adder), "%s%s\n", Debuff_Adder_left,Debuff_Adder_right);
	}
#if defined ZR
	if(EntRefToEntIndex(RaidBossActive) != victim)
#endif
	{
		float HudOffset = ZR_DEFAULT_HUD_OFFSET;

#if defined ZR
		if(raidboss_active)
		{
			//there is a raid, then this displays a hud below the raid hud.
			HudOffset = (HudOffset + 0.135);

			int raidboss = EntRefToEntIndex(RaidBossActive);
			//We have to check if the raidboss has any debuffs.
			if(NpcHadArmorType(raidboss, 1) || b_NpcIsInvulnerable[raidboss])
			{
				HudOffset += 0.035;
			}
			else if(NpcHadArmorType(raidboss, 2) || DoesNpcHaveHudDebuffOrBuff(attacker, raidboss, GameTime))	
			{
				HudOffset += 0.035;
			}
		}
#endif
		float HudY = -1.0;

#if defined ZR || defined RPG
		HudY += f_HurtHudOffsetY[attacker];
		HudOffset += f_HurtHudOffsetX[attacker];
#endif	// ZR

		SetHudTextParams(HudY, HudOffset, 1.0, red, green, blue, 255, 0, 0.01, 0.01);
		char ExtraHudHurt[255];

		//add name and health
		//add name and health
		char c_Health[255];
		char c_MaxHealth[255];
		IntToString(Health,c_Health, sizeof(c_Health));
		IntToString(MaxHealth,c_MaxHealth, sizeof(c_MaxHealth));

		int offset = Health < 0 ? 1 : 0;
		ThousandString(c_Health[offset], sizeof(c_Health) - offset);
		offset = MaxHealth < 0 ? 1 : 0;
		ThousandString(c_MaxHealth[offset], sizeof(c_MaxHealth) - offset);
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
#endif
		
		//add debuff
		Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s \n%s", ExtraHudHurt, Debuff_Adder);

		char c_DmgDelt[255];
		IntToString(RoundToNearest(f_damageAddedTogether[attacker]),c_DmgDelt, sizeof(c_DmgDelt));
		offset = RoundToNearest(f_damageAddedTogether[attacker]) < 0 ? 1 : 0;
		ThousandString(c_DmgDelt[offset], sizeof(c_DmgDelt) - offset);

#if defined ZR
		if(!raidboss_active)
#endif
		{
			Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s-%s", ExtraHudHurt, c_DmgDelt);
		}
		ShowSyncHudText(attacker, SyncHud,"%s",ExtraHudHurt);
	}
#if defined ZR
	else
	{
		float Timer_Show = RaidModeTime - GameTime;
	
		if(Timer_Show < 0.0)
			Timer_Show = 0.0;

		if(Timer_Show > 800.0)
			RaidModeTime = 99999999.9;

		float HudOffset = ZR_DEFAULT_HUD_OFFSET;
		float HudY = -1.0;

		HudY += f_HurtHudOffsetY[attacker];
		HudOffset += f_HurtHudOffsetX[attacker];
			
		SetGlobalTransTarget(attacker);
		SetHudTextParams(HudY, HudOffset, 1.0, red, green, blue, 255, 0, 0.01, 0.01);
		//todo: better showcase of timer.
		char ExtraHudHurt[255];


		//what type of boss
		if(b_thisNpcIsARaid[victim])
			Format(ExtraHudHurt, sizeof(ExtraHudHurt), "[%t | %t : ", "Raidboss", "Power");
		else
			Format(ExtraHudHurt, sizeof(ExtraHudHurt), "[%t | %t : ", "Superboss", "Power");

		//time show or not
		if(Timer_Show > 800.0)
			Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s%.1f%%]", ExtraHudHurt, RaidModeScaling * 100.0);
		else
			Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s%.1f%% | %t: %.1f]", ExtraHudHurt, RaidModeScaling * 100.0, "TIME LEFT", Timer_Show);
			
		//add name and health
		char c_Health[255];
		char c_MaxHealth[255];
		IntToString(Health,c_Health, sizeof(c_Health));
		IntToString(MaxHealth,c_MaxHealth, sizeof(c_MaxHealth));

		int offset = Health < 0 ? 1 : 0;
		ThousandString(c_Health[offset], sizeof(c_Health) - offset);
		offset = MaxHealth < 0 ? 1 : 0;
		ThousandString(c_MaxHealth[offset], sizeof(c_MaxHealth) - offset);

		Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s\n%t\n%s / %s",ExtraHudHurt,c_NpcName[victim], c_Health, c_MaxHealth);
		
		//add debuff
		Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s \n%s", ExtraHudHurt, Debuff_Adder);

		char c_DmgDelt[255];
		IntToString(RoundToNearest(f_damageAddedTogether[attacker]),c_DmgDelt, sizeof(c_DmgDelt));
		offset = RoundToNearest(f_damageAddedTogether[attacker]) < 0 ? 1 : 0;
		ThousandString(c_DmgDelt[offset], sizeof(c_DmgDelt) - offset);

		Format(ExtraHudHurt, sizeof(ExtraHudHurt), "%s-%s", ExtraHudHurt, c_DmgDelt);
			
		ShowSyncHudText(attacker, SyncHudRaid,"%s",ExtraHudHurt);	

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

stock bool NpcHadArmorType(int victim, int type, int weapon = 0, int attacker = 0)
{
	if(fl_TotalArmor[victim] != 1.0)
		return true;

#if defined ZR
	if(Medival_Difficulty_Level != 0.0 && !NpcStats_IsEnemySilenced(victim))
		return true;
#endif

#if defined MAX_EXPI_ENERGY_EFFECTS
	if(VausMagicaShieldLogicEnabled(victim))
		return true;
#endif

	if(f_MultiDamageTaken[victim] != 1.0)
	{
		return true;
	}
	if(f_MultiDamageTaken_Flat[victim] != 1.0)
	{
		return true;
	}	
	float DamageTest = 1.0;
	int testvalue = 1;
	int DmgType;
	switch(type)
	{
		case 1:
		{
			DmgType = DMG_BULLET;
		}
		case 2:
		{
			DmgType = DMG_CLUB;
		}
	}
	OnTakeDamageResistanceBuffs(victim, testvalue, testvalue, DamageTest, DmgType, testvalue, GetGameTime());
	if(DamageTest != 1.0)
		return true;

	CClotBody npc = view_as<CClotBody>(victim);
	switch(type)
	{
		case 1:
		{
			if(npc.m_flRangedArmor != 1.0)
				return true;
			
			if(fl_Extra_RangedArmor[victim] != 1.0)
				return true;
		}
		case 2:
		{
			if(npc.m_flMeleeArmor != 1.0)
				return true;
			
			if(fl_Extra_MeleeArmor[victim] != 1.0)
				return true;

#if defined ZR
			if(weapon > 0 && attacker > 0 && Siccerino_Melee_DmgBonus(victim, attacker, weapon) != 1.0)
				return true;
#endif
		}
	}

#if defined ZR
	if(!b_thisNpcIsARaid[victim] && GetTeam(victim) != TFTeam_Red && XenoExtraLogic(true))
	{
		return true;
	}
#endif

	return false;
}

#if !defined RTS
stock void ResetDamageHud(int client)
{
	SetHudTextParams(-1.0, 0.05, 1.0, 0, 0, 0, 255, 0, 0.01, 0.01);
	ShowSyncHudText(client, SyncHud, "");
}

stock void Calculate_And_Display_hp(int attacker, int victim, float damage, bool ignore)
{
	b_DisplayDamageHud[attacker] = true;
	i_HudVictimToDisplay[attacker] = EntIndexToEntRef(victim);
	float GameTime = GetGameTime();
	bool raidboss_active = false;

	if(!b_NpcIsInvulnerable[victim])
	{
		if(RaidbossIgnoreBuildingsLogic())
		{
			raidboss_active = true;
		}
		if(damage > 0.0)
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
#endif

stock bool DoesNpcHaveHudDebuffOrBuff(int client, int npc, float GameTime)
{
	if(f_HighTeslarDebuff[npc] > GameTime)
		return true;
	else if(f_LowTeslarDebuff[npc] > GameTime)
		return true;
	else if(f_FallenWarriorDebuff[npc] > GameTime)
		return true;
	else if(f_LudoDebuff[npc] > GameTime)
		return true;
	else if(f_SpadeLudoDebuff[npc] > GameTime)
		return true;
	else if(BleedAmountCountStack[npc] > 0) //bleed
		return true;
	else if(IgniteFor[npc] > 0) //burn
		return true;
	else if(f_HighIceDebuff[npc] > GameTime)
		return true;
	else if(f_LowIceDebuff[npc] > GameTime)
		return true;
	else if(f_BuildingAntiRaid[npc] > GameTime)
		return true;
	else if (f_VeryLowIceDebuff[npc] > GameTime)
		return true;
	else if(f_WidowsWineDebuff[npc] > GameTime)
		return true;
	else if(f_CrippleDebuff[npc] > GameTime)
		return true;
	else if(f_CudgelDebuff[npc] > GameTime)
		return true;
	else if(f_DuelStatus[npc] > GameTime)
		return true;
	else if(f_MaimDebuff[npc] > GameTime)
		return true;
	else if(NpcStats_IsEnemySilenced(npc))
		return true;
	else if(Increaced_Overall_damage_Low[npc] > GameTime)
		return true;
	else if(Resistance_Overall_Low[npc] > GameTime)
		return true;
	else if(f_EmpowerStateOther[npc] > GameTime)
		return true;
	else if(f_HussarBuff[npc] > GameTime)
		return true;
	else if(f_PernellBuff[npc])
		return true;
	else if(f_PotionShrinkEffect[npc] > GameTime)
		return true;
	else if(f_EnfeebleEffect[npc] > GameTime)
		return true;
	else if(f_LeeMinorEffect[npc] > GameTime)
		return true;
	else if(f_LeeMajorEffect[npc] > GameTime)
		return true;
	else if(f_LeeSuperEffect[npc] > GameTime)
		return true;
	else if(f_GodAlaxiosBuff[npc] > GameTime)
		return true;
	else if(f_Ocean_Buff_Stronk_Buff[npc] > GameTime)
		return true;
	else if(f_Ocean_Buff_Weak_Buff[npc] > GameTime)
		return true;
	else if(f_BattilonsNpcBuff[npc] > GameTime)
		return true;
	else if(f_BuffBannerNpcBuff[npc] > GameTime)
		return true;
	else if(f_AncientBannerNpcBuff[npc] > GameTime)
		return true;
	#if defined RUINA_BASE
	else if(f_Ruina_Defense_Buff[npc] > GameTime)
		return true;
	else if(f_Ruina_Speed_Buff[npc] > GameTime)
		return true;
	else if(f_Ruina_Attack_Buff[npc] > GameTime)
		return true;
	#endif
#if defined RPG
	else if(TrueStrength_StacksOnEntity(client, npc))
		return true;
	else if(BubbleProcStatusLogicCheck(client) != 0)
		return true;
#endif
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
			GiveXP(client, 1);
			Saga_DeadEffects(entity, client, WeaponLastHit);
#endif
			
#if defined RPG
			Stats_SetHasKill(client, c_NpcName[entity]);
			Quests_AddKill(client, entity);
			Spawns_NPCDeath(entity, client, WeaponLastHit);
#endif

			Attributes_OnKill(client, WeaponLastHit);
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
					float flPos[3];
					GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", flPos);
					flPos[2] += 40.0;
					int BomsToBoom = i_HowManyBombsOnThisEntity[entity][client];
					float damage = f_BombEntityWeaponDamageApplied[entity][client] * i_HowManyBombsOnThisEntity[entity][client];
					i_HowManyBombsHud[entity] -= BomsToBoom;
					i_HowManyBombsOnThisEntity[entity][client] = 0;
					f_BombEntityWeaponDamageApplied[entity][client] = 0.0;
					Cause_Terroriser_Explosion(client, entity, damage, flPos);
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
		case WEAPON_CASINO:
		{
			CasinoSalaryPerKill(attacker, weapon);
		}
		case WEAPON_RAPIER:
		{
			RapierEndDuelOnKill(attacker, victim);
		}
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
	return NPC_HARD_LIMIT;
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