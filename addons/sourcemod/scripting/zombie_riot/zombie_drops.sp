#pragma semicolon 1
#pragma newdecls required

bool b_ToggleTransparency[MAXENTITIES];

#define NUKE_MODEL "models/props_trainyard/cart_bomb_separate.mdl"
#define NUKE_SOUND "weapons/icicle_freeze_victim_01.wav"

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

static bool SpawnedExtraCashThisWave;

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
void ZombieDrops_AllowExtraCash()
{
	SpawnedExtraCashThisWave = false;
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
		
	i_KillTheseManyMorePowerup_Nuke = RoundToCeil((f_KillTheseManyMorePowerup_base_Nuke + (Waves_GetRoundScale() * 2)) * (f_PowerupSpawnMulti));
	i_KillTheseManyMorePowerup_Maxammo = RoundToCeil((f_KillTheseManyMorePowerup_base_Maxammo + (Waves_GetRoundScale() * 2)) * (f_PowerupSpawnMulti));
	i_KillTheseManyMorePowerup_Health = RoundToCeil((f_KillTheseManyMorePowerup_base_Health + (Waves_GetRoundScale() * 2)) * (f_PowerupSpawnMulti));
	i_KillTheseManyMorePowerup_Money = RoundToCeil((f_KillTheseManyMorePowerup_base_Money + (Waves_GetRoundScale() * 2)) * (f_PowerupSpawnMulti));
	i_KillTheseManyMorePowerup_Grigori = RoundToCeil((f_KillTheseManyMorePowerup_base_Grigori + (Waves_GetRoundScale() * 2)) * (f_PowerupSpawnMulti));
}

void Drops_ResetChances()
{
	i_KilledThisMany_Money = 0;
	i_KilledThisMany_Grigori = 0;
	i_KilledThisMany_Health = 0;
	i_KilledThisMany_Maxammo = 0;
	i_KilledThisMany_Nuke = 0;
}

public void DropPowerupChance(int entity)
{
	//dont allow forcing of nuke and grigori selling
	if(b_NpcForcepowerupspawn[entity] == 2)
	{
		switch(GetRandomInt(0,2))
		{
			case 0:
				SpawnMaxAmmo(entity, true); //Dont care.)

			case 1:
				SpawnHealth(entity, true); //Dont care.)

			case 2:
				SpawnMoney(entity, true); //Dont care.)
		}
	}
	if(Rogue_Mode())
	{
		return;
	}
	if(IsValidEntity(EntRefToEntIndex(SalesmanAlive)))
	{
		i_KilledThisMany_Grigori += 1;
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
	if(!Dungeon_Mode())
	{
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
	if(!SpawnedExtraCashThisWave && i_KilledThisMany_Money > i_KillTheseManyMorePowerup_Money || b_ForceSpawnNextTimeMoney)
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
					SpawnedExtraCashThisWave = true;
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
					ParticleEffectAt(powerup_pos, "utaunt_snowring_space_parent", 1.0);
					ParticleEffectAt(powerup_pos, "utaunt_arcane_green_sparkle_start", 1.0);
					EmitSoundToAll(NUKE_SOUND, _, SNDCHAN_STATIC, 100, _);
					
					int a, ienemy;
					while((ienemy = FindEntityByNPC(a)) != -1)
					{
						if(GetTeam(ienemy) != TFTeam_Red)
						{
							Cryo_FreezeZombie(client, ienemy, 3);
						}
					}
					for (int client_Hud = 1; client_Hud <= MaxClients; client_Hud++)
					{
						if (IsValidClient(client_Hud) && IsPlayerAlive(client_Hud) && GetClientTeam(client_Hud) == view_as<int>(TFTeam_Red))
						{
							SetHudTextParams(-1.0, 0.30, 3.01, 125, 125, 255, 255);
							SetGlobalTransTarget(client_Hud);
							ShowHudText(client_Hud,  -1, "%t", "Freeze Bomb Activated");
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



void SpawnMaxAmmo(int entity, bool MenacinglyFlyToPlayer = false)
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
		if(MenacinglyFlyToPlayer)
		{
			CreateTimer(0.1, Timer_FlyToClosestPlayer, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
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
					if(!Rogue_Mode())
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
										ManaCalculationsBefore(client);
										
										if(Current_Mana[client_Hud] < RoundToCeil(max_mana[client] * 2.0))
										{
											if(Current_Mana[client_Hud] < RoundToCeil(max_mana[client] * 2.0))
											{
												Current_Mana[client_Hud] += RoundToCeil(mana_regen[client] * 2.0);
												
												if(Current_Mana[client_Hud] > RoundToCeil(max_mana[client] * 2.0)) //Should only apply during actual regen
													Current_Mana[client_Hud] = RoundToCeil(max_mana[client] * 2.0);
											}
											Mana_Hud_Delay[client_Hud] = 0.0;
										}
										
									}
									else
									{
										int Ammo_type = GetAmmoType_WeaponPrimary(weapon);
										int weaponindex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
										if (i_WeaponAmmoAdjustable[weapon])
										{
											AddAmmoClient(client_Hud, i_WeaponAmmoAdjustable[weapon] ,_,4.0);
										}
										else if(weaponindex == 441 || weaponindex == 35)
										{
											AddAmmoClient(client_Hud, 23 ,_,4.0);	
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
							SetHudTextParams(-1.0, 0.30, 3.01, 125, 125, 255, 255);
							SetGlobalTransTarget(client_Hud);
							ShowHudText(client_Hud,  -1, "%t", "Max Ammo Activated");
							Barracks_TryRegenIfBuilding(client_Hud, 4.0);
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



void SpawnHealth(int entity, bool MenacinglyFlyToPlayer = false)
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
		if(MenacinglyFlyToPlayer)
		{
			CreateTimer(0.1, Timer_FlyToClosestPlayer, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
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
					if(!Rogue_Mode())
						EmitSoundToAll(HEALTH_SOUND, _, SNDCHAN_STATIC, 100, _,0.65);
					for (int client_Hud = 1; client_Hud <= MaxClients; client_Hud++)
					{
						if (IsValidClient(client_Hud) && IsPlayerAlive(client_Hud) && GetClientTeam(client_Hud) == view_as<int>(TFTeam_Red))
						{
							
							if(dieingstate[client_Hud] == 0 && TeutonType[client_Hud] == TEUTON_NONE)
							{
								int MaxHealth = SDKCall_GetMaxHealth(client_Hud);
								HealEntityGlobal(client_Hud, client_Hud, float(MaxHealth / 2), 1.0, 0.0, HEAL_ABSOLUTE);

								//This gives 35% armor
							}
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



void SpawnMoney(int entity, bool MenacinglyFlyToPlayer = false)
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
		if(MenacinglyFlyToPlayer)
		{
			CreateTimer(0.1, Timer_FlyToClosestPlayer, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
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
					GlobalExtraCash += 500;
					ParticleEffectAt(powerup_pos, "utaunt_arcane_green_sparkle_start", 1.0);
					EmitSoundToAll(MONEY_SOUND, _, SNDCHAN_STATIC, 100, _);
					for (int client_Hud = 1; client_Hud <= MaxClients; client_Hud++)
					{
						if (IsValidClient(client_Hud) && IsPlayerAlive(client_Hud) && GetClientTeam(client_Hud) == view_as<int>(TFTeam_Red))
						{
							CashSpent[client_Hud] -= 500;
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
					Store_RandomizeNPCStore(ZR_STORE_DEFAULT_SALE, 1);
					
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



public Action Timer_FlyToClosestPlayer(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		float powerup_pos[3];
		WorldSpaceCenter(entity, powerup_pos);
		float TargetDistance = 0.0; 
		int ClosestTarget = 0; 
		for( int i = 1; i <= MaxClients; i++ ) 
		{
			if (IsValidClient(i))
			{
				if (GetTeam(i)== TFTeam_Red && IsEntityAlive(i))
				{
					float TargetLocation[3]; 
					WorldSpaceCenter(i, TargetLocation);
					
					
					float distance = GetVectorDistance( powerup_pos, TargetLocation, true ); 
					if( TargetDistance ) 
					{
						if( distance < TargetDistance ) 
						{
							ClosestTarget = i; 
							TargetDistance = distance;		  
						}
					} 
					else 
					{
						ClosestTarget = i; 
						TargetDistance = distance;
					}		
				}
			}
		}
		if(ClosestTarget > 0)
		{
			MoveToClosestPlayer(entity, ClosestTarget); //Terror.
		}	
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}


//This is probably the silliest thing ever.
public void MoveToClosestPlayer(int Gift, int client)
{
	float Jump_1_frame[3];
	GetEntPropVector(Gift, Prop_Data, "m_vecOrigin", Jump_1_frame);
	float Jump_1_frame_Client[3];
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", Jump_1_frame_Client);
	Jump_1_frame_Client[2] += 30.0;
	
	float vAngles[3];
	float vecSwingForward[3];
	float vecSwingEnd[3];	
	MakeVectorFromPoints(Jump_1_frame, Jump_1_frame_Client, vAngles);
	GetVectorAngles(vAngles, vAngles);

	GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);

	vecSwingEnd[0] = Jump_1_frame[0] + vecSwingForward[0] * 10.0;
	vecSwingEnd[1] = Jump_1_frame[1] + vecSwingForward[1] * 10.0;
	vecSwingEnd[2] = Jump_1_frame[2] + vecSwingForward[2] * 10.0;

	TeleportEntity(Gift, vecSwingEnd, NULL_VECTOR, NULL_VECTOR);
}

