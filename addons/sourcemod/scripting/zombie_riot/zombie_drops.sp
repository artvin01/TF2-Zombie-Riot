#pragma semicolon 1
#pragma newdecls required

bool b_ToggleTransparency[MAXENTITIES];

#define NUKE_MODEL "models/props_trainyard/cart_bomb_separate.mdl"
#define NUKE_SOUND "ambient/explosions/explode_5.wav"

#define AMMO_MODEL "models/items/ammopack_large.mdl"
#define AMMO_SOUND "items/powerup_pickup_regeneration.wav"

#define HEALTH_MODEL "models/items/medkit_medium.mdl"
#define HEALTH_SOUND "items/powerup_pickup_strength.wav"

#define MONEY_MODEL "models/items/currencypack_large.mdl"
#define MONEY_SOUND "items/powerup_pickup_crits.wav"

#define GRIGORI_POWERUP_MODEL "models/props_mvm/mvm_upgrade_sign.mdl"
#define GRIGORI_POWERUP_SOUND "items/powerup_pickup_supernova.wav"

#define PLAYER_DETECT_RANGE_DROPS 4096.0

static int i_KilledThisMany_Nuke = 0;
static bool i_AllowNuke = true;
static float f_KillTheseManyMorePowerup_base_Nuke = 375.0;
static int i_KillTheseManyMorePowerup_Nuke = 375;

static int i_KilledThisMany_Maxammo = 0;
static bool i_AllowMaxammo = true;
static float f_KillTheseManyMorePowerup_base_Maxammo = 360.0;
static int i_KillTheseManyMorePowerup_Maxammo = 360;

static int i_KilledThisMany_Health = 0;
static bool i_AllowHealth = true;
static float f_KillTheseManyMorePowerup_base_Health = 450.0;
static int i_KillTheseManyMorePowerup_Health = 450;

static int i_KilledThisMany_Money = 0;
static bool i_AllowMoney = true;
static float f_KillTheseManyMorePowerup_base_Money = 480.0;
static int i_KillTheseManyMorePowerup_Money = 480;

static int i_KilledThisMany_Grigori = 0;
static bool i_AllowMoney_Grigori = true;
static float f_KillTheseManyMorePowerup_base_Grigori = 480.0;
static int i_KillTheseManyMorePowerup_Grigori = 480;

static bool b_ForceSpawnNextTimeNuke;
static bool b_ForceSpawnNextTimeAmmo;
static bool b_ForceSpawnNextTimeHealth;
static bool b_ForceSpawnNextTimeMoney;
static bool b_ForceSpawnNextTimeGrigori;
static float f_PowerupSpawnMulti;

void Map_Precache_Zombie_Drops()
{
	PrecacheModel(NUKE_MODEL, true);
	PrecacheSound(NUKE_SOUND, true);
	
	PrecacheModel(AMMO_MODEL, true);
	PrecacheSound(AMMO_SOUND, true);

	PrecacheModel(HEALTH_MODEL, true);
	PrecacheSound(HEALTH_SOUND, true);
	
	PrecacheModel(MONEY_MODEL, true);
	PrecacheSound(MONEY_SOUND, true);

	PrecacheModel(GRIGORI_POWERUP_MODEL, true);
	PrecacheSound(GRIGORI_POWERUP_SOUND, true);
}

public void Renable_Powerups()
{
	i_AllowMaxammo = true;
	i_AllowNuke = true;
	i_AllowHealth = true;
	i_AllowMoney = true;
	i_AllowMoney_Grigori = true;
}

public void BalanceDropMinimum(float multi)
{
	f_PowerupSpawnMulti = multi;
	if(VIPBuilding_Active())
		f_PowerupSpawnMulti *= 4.0;
		
	i_KillTheseManyMorePowerup_Nuke = RoundToCeil((f_KillTheseManyMorePowerup_base_Nuke + (Waves_GetRound() * 2)) * (f_PowerupSpawnMulti));
	i_KillTheseManyMorePowerup_Maxammo = RoundToCeil((f_KillTheseManyMorePowerup_base_Maxammo + (Waves_GetRound() * 2)) * (f_PowerupSpawnMulti));
	i_KillTheseManyMorePowerup_Health = RoundToCeil((f_KillTheseManyMorePowerup_base_Health + (Waves_GetRound() * 2)) * (f_PowerupSpawnMulti));
	i_KillTheseManyMorePowerup_Money = RoundToCeil((f_KillTheseManyMorePowerup_base_Money + (Waves_GetRound() * 2)) * (f_PowerupSpawnMulti));
	i_KillTheseManyMorePowerup_Grigori = RoundToCeil((f_KillTheseManyMorePowerup_base_Grigori + (Waves_GetRound() * 2)) * (f_PowerupSpawnMulti));
}


public void DropPowerupChance(int entity)
{
	//dont allow forcing of nuke and grigori selling
	if(b_NpcForcepowerupspawn[entity] == 2)
	{
		switch(GetRandomInt(0,2))
		{
			case 0:
				SpawnMaxAmmo(entity); //Dont care.)

			case 1:
				SpawnHealth(entity); //Dont care.)

			case 2:
				SpawnMoney(entity); //Dont care.)
		}
	}
	if(Rogue_Mode())
	{
		return;
	}
	i_KilledThisMany_Grigori += 1;
	if(IsValidEntity(EntRefToEntIndex(SalesmanAlive)))
	{
		if(i_KilledThisMany_Grigori > i_KillTheseManyMorePowerup_Grigori || b_ForceSpawnNextTimeGrigori)
		{
			if((GetRandomFloat(0.0, 1.0) * f_PowerupSpawnMulti) || b_ForceSpawnNextTimeGrigori)
			{
				if(i_AllowMoney_Grigori)
				{
			//		i_AllowMoney_Grigori = false;
					
					float VecOrigin[3];
					GetEntPropVector(entity, Prop_Data, "m_vecOrigin", VecOrigin);
					VecOrigin[2] += 54.0;
					if(!IsPointHazard(VecOrigin) && !IsPointOutsideMap(VecOrigin)) //Is it valid?
					{
						b_ForceSpawnNextTimeGrigori = false;
						SpawnGrigoriPowerup(entity);
					}
					else //Not a valid position, we must force it! next time we try!
					{
						b_ForceSpawnNextTimeGrigori = true;
					}
					i_KilledThisMany_Grigori = 0;
				}
			}
		}
	}
	i_KilledThisMany_Nuke += 1;
	if(i_KilledThisMany_Nuke > i_KillTheseManyMorePowerup_Nuke || b_ForceSpawnNextTimeNuke)
	{
		if((GetRandomFloat(0.0, 1.0) * f_PowerupSpawnMulti) || b_ForceSpawnNextTimeNuke)
		{
			if(i_AllowNuke)
			{
			//	i_AllowNuke = false;
				
				float VecOrigin[3];
				GetEntPropVector(entity, Prop_Data, "m_vecOrigin", VecOrigin);
				VecOrigin[2] += 54.0;
				if(!IsPointHazard(VecOrigin) && !IsPointOutsideMap(VecOrigin)) //Is it valid?
				{
					b_ForceSpawnNextTimeNuke = false;
					SpawnNuke(entity);
				}
				else //Not a valid position, we must force it! next time we try!
				{
					b_ForceSpawnNextTimeNuke = true;
				}
				i_KilledThisMany_Nuke = 0;
			}
		}
	}
	i_KilledThisMany_Maxammo += 1;
	if(i_KilledThisMany_Maxammo > i_KillTheseManyMorePowerup_Maxammo || b_ForceSpawnNextTimeAmmo)
	{
		if((GetRandomFloat(0.0, 1.0) * f_PowerupSpawnMulti) || b_ForceSpawnNextTimeAmmo)
		{
			if(i_AllowMaxammo)
			{
			//	i_AllowMaxammo = false;
				
				float VecOrigin[3];
				GetEntPropVector(entity, Prop_Data, "m_vecOrigin", VecOrigin);
				VecOrigin[2] += 54.0;
				if(!IsPointHazard(VecOrigin) && !IsPointOutsideMap(VecOrigin)) //Is it valid?
				{
					b_ForceSpawnNextTimeAmmo = false;
					SpawnMaxAmmo(entity);
				}
				else //Not a valid position, we must force it! next time we try!
				{
					b_ForceSpawnNextTimeAmmo = true;
				}
				i_KilledThisMany_Maxammo = 0;
			}
		}
	}
	i_KilledThisMany_Health += 1;
	if(i_KilledThisMany_Health > i_KillTheseManyMorePowerup_Health || b_ForceSpawnNextTimeHealth)
	{
		if((GetRandomFloat(0.0, 1.0) * f_PowerupSpawnMulti) || b_ForceSpawnNextTimeHealth)
		{
			if(i_AllowHealth)
			{
			//	i_AllowHealth = false;
				
				float VecOrigin[3];
				GetEntPropVector(entity, Prop_Data, "m_vecOrigin", VecOrigin);
				VecOrigin[2] += 54.0;
				if(!IsPointHazard(VecOrigin) && !IsPointOutsideMap(VecOrigin)) //Is it valid?
				{
					b_ForceSpawnNextTimeHealth = false;
					SpawnHealth(entity);
				}
				else //Not a valid position, we must force it! next time we try!
				{
					b_ForceSpawnNextTimeHealth = true;
				}
				i_KilledThisMany_Health = 0;
			}
		}
	}
	i_KilledThisMany_Money += 1;
	if(i_KilledThisMany_Money > i_KillTheseManyMorePowerup_Money || b_ForceSpawnNextTimeMoney)
	{
		if((GetRandomFloat(0.0, 1.0) * f_PowerupSpawnMulti) < 0.01 || b_ForceSpawnNextTimeMoney)
		{
			if(i_AllowMoney)
			{
			//	i_AllowMoney = false;
				
				float VecOrigin[3];
				GetEntPropVector(entity, Prop_Data, "m_vecOrigin", VecOrigin);
				VecOrigin[2] += 54.0;
				if(!IsPointHazard(VecOrigin) && !IsPointOutsideMap(VecOrigin)) //Is it valid?
				{
					b_ForceSpawnNextTimeMoney = false;
					SpawnMoney(entity);
				}
				else //Not a valid position, we must force it! next time we try!
				{
					b_ForceSpawnNextTimeMoney = true;
				}
				i_KilledThisMany_Money = 0;
			}
		}
	}
}

public void SpawnNuke(int entity)
{
	float VecOrigin[3];
	float VecAngles[3];
	int prop = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(prop))
	{
		b_ToggleTransparency[prop] = false;
		DispatchKeyValue(prop, "model", NUKE_MODEL);
		DispatchKeyValue(prop, "modelscale", "0.65");
		DispatchKeyValue(prop, "StartDisabled", "false");
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", VecOrigin);
		DispatchKeyValue(prop, "Solid", "0");
		SetEntProp(prop, Prop_Data, "m_nSolidType", 0);
		VecAngles[0] = -31.0;
		VecOrigin[2] += 54.0;
		TeleportEntity(prop, VecOrigin, VecAngles, NULL_VECTOR);
		DispatchSpawn(prop);
		SetEntityCollisionGroup(prop, 1);
		AcceptEntityInput(prop, "DisableShadow");
		AcceptEntityInput(prop, "DisableCollision");
		SetEntityRenderMode(prop, RENDER_TRANSCOLOR);
		SetEntityRenderColor(prop, 125, 255, 125, 200);
		
		int particle = ParticleEffectAt(VecOrigin, "utaunt_arcane_green_lights", 30.0);	
		SetParent(prop, particle);
		
		CreateTimer(0.1, Timer_Detect_Player_Near_Nuke, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(20.0, Timer_Aleart_Despawn, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(30.0, Timer_Despawn_Powerup, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
	}	
}

public Action Timer_Detect_Player_Near_Nuke(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		float powerup_pos[3];
		float client_pos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
		for (int client = 1; client <= MaxClients; client++)
		{
			if (IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == view_as<int>(TFTeam_Red))
			{
				GetClientAbsOrigin(client, client_pos);
				client_pos[2] += 35.0;
				if (GetVectorDistance(powerup_pos, client_pos, true) <= PLAYER_DETECT_RANGE_DROPS)
				{
					int base_boss = -1;
					ParticleEffectAt(powerup_pos, "hightower_explosion", 1.0);
					ParticleEffectAt(powerup_pos, "utaunt_arcane_green_sparkle_start", 1.0);
					EmitSoundToAll(NUKE_SOUND, _, SNDCHAN_STATIC, 100, _);
					EmitSoundToAll(NUKE_SOUND, _, SNDCHAN_STATIC, 100, _);
					while((base_boss=FindEntityByClassname(base_boss, "zr_base_npc")) != -1)
					{
						if(IsValidEntity(base_boss) && base_boss > 0)
						{
							if(GetEntProp(base_boss, Prop_Data, "m_iTeamNum") != view_as<int>(TFTeam_Red))
							{
								CClotBody npcstats = view_as<CClotBody>(base_boss);
								if(!npcstats.m_bThisNpcIsABoss && !b_Map_BaseBoss_No_Layers[base_boss] && !b_ThisNpcIsImmuneToNuke[base_boss] && RaidBossActive != base_boss) //Make sure it doesnt actually kill map base_bosses
								{
									SDKHooks_TakeDamage(base_boss, 0, 0, 99999999.0, DMG_BLAST); //Kill it so it triggers the neccecary shit.
									SDKHooks_TakeDamage(base_boss, 0, 0, 99999999.0, DMG_BLAST); //Kill it so it triggers the neccecary shit.
								}
							}
						}
					}
					for (int client_Hud = 1; client_Hud <= MaxClients; client_Hud++)
					{
						if (IsValidClient(client_Hud) && IsPlayerAlive(client_Hud) && GetClientTeam(client_Hud) == view_as<int>(TFTeam_Red))
						{
							SetHudTextParams(-1.0, 0.30, 3.01, 125, 125, 255, 255);
							SetGlobalTransTarget(client_Hud);
							ShowHudText(client_Hud,  -1, "%t", "Nuke Activated");
						}
					}
					AcceptEntityInput(entity, "KillHierarchy"); 
					return Plugin_Stop;
				}
			}
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}



public void SpawnMaxAmmo(int entity)
{
	float VecOrigin[3];
	float VecAngles[3];
	int prop = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(prop))
	{
		b_ToggleTransparency[prop] = false;
		DispatchKeyValue(prop, "model", AMMO_MODEL);
		DispatchKeyValue(prop, "modelscale", "1.0");
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", VecOrigin);
		DispatchKeyValue(prop, "StartDisabled", "false");
		DispatchKeyValue(prop, "Solid", "0");
		SetEntProp(prop, Prop_Data, "m_nSolidType", 0);
		VecAngles[0] = -31.0;
		VecOrigin[2] += 54.0;
		TeleportEntity(prop, VecOrigin, VecAngles, NULL_VECTOR);
		DispatchSpawn(prop);
		SetEntityCollisionGroup(prop, 1);
		AcceptEntityInput(prop, "DisableShadow");
		AcceptEntityInput(prop, "DisableCollision");
		SetEntityRenderMode(prop, RENDER_TRANSCOLOR);
		SetEntityRenderColor(prop, 125, 255, 125, 200);
		
		int particle = ParticleEffectAt(VecOrigin, "utaunt_arcane_green_lights", 30.0);	
		SetParent(prop, particle);
		
		CreateTimer(0.1, Timer_Detect_Player_Near_Ammo, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(20.0, Timer_Aleart_Despawn, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(30.0, Timer_Despawn_Powerup, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
	}	
}

public Action Timer_Detect_Player_Near_Ammo(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		float powerup_pos[3];
		float client_pos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
		for (int client = 1; client <= MaxClients; client++)
		{
			if (IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == view_as<int>(TFTeam_Red))
			{
				GetClientAbsOrigin(client, client_pos);
				client_pos[2] += 35.0;
				if (GetVectorDistance(powerup_pos, client_pos, true) <= PLAYER_DETECT_RANGE_DROPS)
				{
					ParticleEffectAt(powerup_pos, "utaunt_arcane_green_sparkle_start", 1.0);
					EmitSoundToAll(AMMO_SOUND, _, SNDCHAN_STATIC, 100, _);
					EmitSoundToAll(AMMO_SOUND, _, SNDCHAN_STATIC, 100, _);
					for (int client_Hud = 1; client_Hud <= MaxClients; client_Hud++)
					{
						if (IsValidClient(client_Hud) && IsPlayerAlive(client_Hud) && GetClientTeam(client_Hud) == view_as<int>(TFTeam_Red))
						{
							
							//This gives 35% armor
							GiveArmorViaPercentage(client_Hud, 0.35, 1.0);
							
							int ie, weapon;
							while(TF2_GetItem(client_Hud, weapon, ie))
							{
								if(IsValidEntity(weapon))
								{
									if(i_IsWandWeapon[weapon])
									{
										float max_mana_temp = 800.0;
										float mana_regen_temp = 200.0; //abit extra :)
												
										if(i_CurrentEquippedPerk[client_Hud] == 4)
										{
											mana_regen_temp *= 1.35;
										}
										
										if(Mana_Regen_Level[client_Hud])
										{			
											mana_regen_temp *= Mana_Regen_Level[client_Hud];
											max_mana_temp *= Mana_Regen_Level[client_Hud];	
										}
										/*
										Current_Mana[client] += RoundToCeil(mana_regen[client]);
											
										if(Current_Mana[client] < RoundToCeil(max_mana[client]))
											Current_Mana[client] = RoundToCeil(max_mana[client]);
										*/
										
										if(Current_Mana[client_Hud] < RoundToCeil(max_mana_temp))
										{
											if(Current_Mana[client_Hud] < RoundToCeil(max_mana_temp))
											{
												Current_Mana[client_Hud] += RoundToCeil(mana_regen_temp);
												
												if(Current_Mana[client_Hud] > RoundToCeil(max_mana_temp)) //Should only apply during actual regen
													Current_Mana[client_Hud] = RoundToCeil(max_mana_temp);
											}
											Mana_Hud_Delay[client_Hud] = 0.0;
										}
										
									}
									else
									{
										int Ammo_type = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
										int weaponindex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
										if(weaponindex == 211)
										{
											AddAmmoClient(client_Hud, 21 ,_,4.0);
										}
										else if (weaponindex == 305)
										{
											AddAmmoClient(client_Hud, 21 ,_,4.0);
											AddAmmoClient(client_Hud, 14 ,_,4.0);
											//Yeah extra ammo, do i care ? no.							
										}
										else if(weaponindex == 411)
										{
											AddAmmoClient(client_Hud, 22 ,_,4.0);
										}
										else if(weaponindex == 441 || weaponindex == 35)
										{
											AddAmmoClient(client_Hud, 23 ,_,4.0);	
										}
										else if(weaponindex == 998)
										{
											AddAmmoClient(client_Hud, 3 ,_,4.0);
										}
										else if(Ammo_type != -1 && Ammo_type < Ammo_Hand_Grenade) //Disallow Ammo_Hand_Grenade, that ammo type is regenerative!, dont use jar, tf2 needs jar? idk, wierdshit.
										{
											if(AmmoBlacklist(Ammo_type))
											{
												AddAmmoClient(client_Hud, Ammo_type ,_,4.0);
											}
										}
										else if(Ammo_type > 0 && Ammo_type < Ammo_MAX)
										{
											if(AmmoBlacklist(Ammo_type))
											{
												AddAmmoClient(client_Hud, Ammo_type ,_,4.0);
											}
										}
									}
								}
							}
							for(int i; i<Ammo_MAX; i++)
							{
								CurrentAmmo[client_Hud][i] = GetAmmo(client_Hud, i);
							}
							/*
							Only give ammo to weapons they already have. Otherwise its just op lol, never had ammo issues ever with this, it was funny.
							SetAmmo(client_Hud, Ammo_Metal, GetAmmo(client_Hud, Ammo_Metal)+(AmmoData[Ammo_Metal][1]*4));
							for(int i=Ammo_Jar; i<Ammo_MAX; i++)
							{
								SetAmmo(client_Hud, i, GetAmmo(client_Hud, i)+(AmmoData[i][1]*4));
							}
							for(int i; i<Ammo_MAX; i++)
							{
								CurrentAmmo[client_Hud][i] = GetAmmo(client_Hud, i);
							}
							*/
							SetHudTextParams(-1.0, 0.30, 3.01, 125, 125, 255, 255);
							SetGlobalTransTarget(client_Hud);
							ShowHudText(client_Hud,  -1, "%t", "Max Ammo Activated");
						}
					}
					AcceptEntityInput(entity, "KillHierarchy"); 
					return Plugin_Stop;
				}
			}
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}



public void SpawnHealth(int entity)
{
	float VecOrigin[3];
	float VecAngles[3];
	int prop = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(prop))
	{
		b_ToggleTransparency[prop] = false;
		DispatchKeyValue(prop, "model", HEALTH_MODEL);
		DispatchKeyValue(prop, "modelscale", "1.0");
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", VecOrigin);
		DispatchKeyValue(prop, "StartDisabled", "false");
		DispatchKeyValue(prop, "Solid", "0");
		SetEntProp(prop, Prop_Data, "m_nSolidType", 0);
		VecAngles[0] = -31.0;
		VecOrigin[2] += 54.0;
		TeleportEntity(prop, VecOrigin, VecAngles, NULL_VECTOR);
		DispatchSpawn(prop);
		SetEntityCollisionGroup(prop, 1);
		AcceptEntityInput(prop, "DisableShadow");
		AcceptEntityInput(prop, "DisableCollision");
		SetEntityRenderMode(prop, RENDER_TRANSCOLOR);
		SetEntityRenderColor(prop, 125, 255, 125, 200);
		
		int particle = ParticleEffectAt(VecOrigin, "utaunt_arcane_green_lights", 30.0);	
		SetParent(prop, particle);
		
		CreateTimer(0.1, Timer_Detect_Player_Near_Health, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(20.0, Timer_Aleart_Despawn, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(30.0, Timer_Despawn_Powerup, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
	}	
}

public Action Timer_Detect_Player_Near_Health(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		float powerup_pos[3];
		float client_pos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
		for (int client = 1; client <= MaxClients; client++)
		{
			if (IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == view_as<int>(TFTeam_Red))
			{
				GetClientAbsOrigin(client, client_pos);
				client_pos[2] += 35.0;
				if (GetVectorDistance(powerup_pos, client_pos, true) <= PLAYER_DETECT_RANGE_DROPS)
				{
					ParticleEffectAt(powerup_pos, "utaunt_arcane_green_sparkle_start", 1.0);
					EmitSoundToAll(HEALTH_SOUND, _, SNDCHAN_STATIC, 100, _);
				//	EmitSoundToAll(HEALTH_SOUND, _, SNDCHAN_STATIC, 100, _);
					for (int client_Hud = 1; client_Hud <= MaxClients; client_Hud++)
					{
						if (IsValidClient(client_Hud) && IsPlayerAlive(client_Hud) && GetClientTeam(client_Hud) == view_as<int>(TFTeam_Red))
						{
							int MaxHealth = SDKCall_GetMaxHealth(client_Hud);
							int flHealth = GetEntProp(client_Hud, Prop_Send, "m_iHealth");
							
							flHealth += MaxHealth / 2;

							SetEntProp(client_Hud, Prop_Send, "m_iHealth", flHealth);
							ApplyHealEvent(client_Hud, MaxHealth / 2);	// Show healing number

							//This gives 35% armor
							GiveArmorViaPercentage(client_Hud, 0.35, 1.0);

							SetHudTextParams(-1.0, 0.30, 3.01, 125, 125, 255, 255);
							SetGlobalTransTarget(client_Hud);
							ShowHudText(client_Hud,  -1, "%t", "Max Health Activated");
						}
					}
					AcceptEntityInput(entity, "KillHierarchy"); 
					return Plugin_Stop;
				}
			}
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}



public void SpawnMoney(int entity)
{
	float VecOrigin[3];
	float VecAngles[3];
	int prop = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(prop))
	{
		b_ToggleTransparency[prop] = false;
		DispatchKeyValue(prop, "model", MONEY_MODEL);
		DispatchKeyValue(prop, "modelscale", "1.0");
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", VecOrigin);
		DispatchKeyValue(prop, "StartDisabled", "false");
		DispatchKeyValue(prop, "Solid", "0");
		SetEntProp(prop, Prop_Data, "m_nSolidType", 0);
		VecAngles[0] = -31.0;
		VecOrigin[2] += 54.0;
		TeleportEntity(prop, VecOrigin, VecAngles, NULL_VECTOR);
		DispatchSpawn(prop);
		SetEntityCollisionGroup(prop, 1);
		AcceptEntityInput(prop, "DisableShadow");
		AcceptEntityInput(prop, "DisableCollision");
		SetEntityRenderMode(prop, RENDER_TRANSCOLOR);
		SetEntityRenderColor(prop, 125, 255, 125, 200);
		
		int particle = ParticleEffectAt(VecOrigin, "utaunt_arcane_green_lights", 30.0);	
		SetParent(prop, particle);
		
		CreateTimer(0.1, Timer_Detect_Player_Near_Money, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(20.0, Timer_Aleart_Despawn, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(30.0, Timer_Despawn_Powerup, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
	}	
}

public Action Timer_Detect_Player_Near_Money(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		float powerup_pos[3];
		float client_pos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
		for (int client = 1; client <= MaxClients; client++)
		{
			if (IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == view_as<int>(TFTeam_Red))
			{
				GetClientAbsOrigin(client, client_pos);
				client_pos[2] += 35.0;
				if (GetVectorDistance(powerup_pos, client_pos, true) <= PLAYER_DETECT_RANGE_DROPS)
				{
					ParticleEffectAt(powerup_pos, "utaunt_arcane_green_sparkle_start", 1.0);
					EmitSoundToAll(MONEY_SOUND, _, SNDCHAN_STATIC, 100, _);
					EmitSoundToAll(MONEY_SOUND, _, SNDCHAN_STATIC, 100, _);
					for (int client_Hud = 1; client_Hud <= MaxClients; client_Hud++)
					{
						if (IsValidClient(client_Hud) && IsPlayerAlive(client_Hud) && GetClientTeam(client_Hud) == view_as<int>(TFTeam_Red))
						{
							CashSpent[client_Hud] -= 500;
							CashRecievedNonWave[client_Hud] += 500;
							SetHudTextParams(-1.0, 0.30, 3.01, 125, 125, 255, 255);
							SetGlobalTransTarget(client_Hud);
							ShowHudText(client_Hud,  -1, "%t", "Max Money Activated");
						}
					}
					AcceptEntityInput(entity, "KillHierarchy"); 
					return Plugin_Stop;
				}
			}
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Timer_Aleart_Despawn(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		CreateTimer(1.0, Timer_ToggleTransparrency, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
	return Plugin_Stop;
}

public Action Timer_ToggleTransparrency(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(!b_ToggleTransparency[entity])
		{
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
			SetEntityRenderColor(entity, 125, 255, 125, 100);
			b_ToggleTransparency[entity] = true;
		}
		else
		{
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
			SetEntityRenderColor(entity, 125, 255, 125, 200);
			b_ToggleTransparency[entity] = false;
		}
		return Plugin_Continue;
	}
	return Plugin_Stop;
}


public Action Timer_Despawn_Powerup(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		RemoveEntity(entity);
	}
	return Plugin_Stop;
}


bool IsPointOutsideMap(const float pos1[3])
{
	CNavArea area = TheNavMesh.GetNavArea(pos1, 150.0);
	if(area == NULL_AREA)
		return true;

	int NavAttribs = area.GetAttributes();
	if(NavAttribs & NAV_MESH_AVOID)
	{
		return true;
	}
	return false;
}



public void SpawnGrigoriPowerup(int entity)
{
	float VecOrigin[3];
	float VecAngles[3];
	int prop = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(prop))
	{
		b_ToggleTransparency[prop] = false;
		DispatchKeyValue(prop, "model", GRIGORI_POWERUP_MODEL);
		DispatchKeyValue(prop, "modelscale", "0.65");
		DispatchKeyValue(prop, "StartDisabled", "false");
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", VecOrigin);
		DispatchKeyValue(prop, "Solid", "0");
		SetEntProp(prop, Prop_Data, "m_nSolidType", 0);
		VecAngles[0] = -31.0;
		VecOrigin[2] += 54.0;
		TeleportEntity(prop, VecOrigin, VecAngles, NULL_VECTOR);
		DispatchSpawn(prop);
		SetEntityCollisionGroup(prop, 1);
		AcceptEntityInput(prop, "DisableShadow");
		AcceptEntityInput(prop, "DisableCollision");
		SetEntityRenderMode(prop, RENDER_TRANSCOLOR);
		SetEntityRenderColor(prop, 125, 255, 125, 200);
		
		int particle = ParticleEffectAt(VecOrigin, "utaunt_arcane_green_lights", 30.0);	
		SetParent(prop, particle);
		
		CreateTimer(0.1, Timer_Detect_Player_Near_Grigori, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(20.0, Timer_Aleart_Despawn, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(30.0, Timer_Despawn_Powerup, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
	}	
}

public Action Timer_Detect_Player_Near_Grigori(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		float powerup_pos[3];
		float client_pos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
		for (int client = 1; client <= MaxClients; client++)
		{
			if (IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == view_as<int>(TFTeam_Red))
			{
				GetClientAbsOrigin(client, client_pos);
				client_pos[2] += 35.0;
				if (GetVectorDistance(powerup_pos, client_pos, true) <= PLAYER_DETECT_RANGE_DROPS)
				{
					ParticleEffectAt(powerup_pos, "utaunt_arcane_green_sparkle_start", 1.0);
					EmitSoundToAll(GRIGORI_POWERUP_SOUND, _, SNDCHAN_STATIC, 100, _);
					EmitSoundToAll(GRIGORI_POWERUP_SOUND, _, SNDCHAN_STATIC, 100, _);
					Store_RandomizeNPCStore(false, 1);
					for (int client_Hud = 1; client_Hud <= MaxClients; client_Hud++)
					{
						if (IsValidClient(client_Hud) && IsPlayerAlive(client_Hud) && GetClientTeam(client_Hud) == view_as<int>(TFTeam_Red))
						{
							SetHudTextParams(-1.0, 0.30, 3.01, 125, 125, 255, 255);
							SetGlobalTransTarget(client_Hud);
							ShowHudText(client_Hud,  -1, "%t", "Grigori Shop Extra Activated");
						}
					}
					
					AcceptEntityInput(entity, "KillHierarchy"); 
					return Plugin_Stop;
				}
			}
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
