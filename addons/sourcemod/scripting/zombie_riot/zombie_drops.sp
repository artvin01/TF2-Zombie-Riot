#pragma semicolon 1
#pragma newdecls required

#define NUKE_MODEL "models/props_trainyard/cart_bomb_separate.mdl"
#define NUKE_SOUND "ambient/explosions/explode_5.wav"

#define AMMO_MODEL "models/items/ammopack_large.mdl"
#define AMMO_SOUND "items/powerup_pickup_regeneration.wav"

static int i_KilledThisMany_Nuke = 0;
static bool i_AllowNuke = true;
static float f_KillTheseManyMorePowerup_base_Nuke = 110.0;
static int i_KillTheseManyMorePowerup_Nuke = 110;

static int i_KilledThisMany_Maxammo = 0;
static bool i_AllowMaxammo = true;
static float f_KillTheseManyMorePowerup_base_Maxammo = 90.0;
static int i_KillTheseManyMorePowerup_Maxammo = 90;

void Map_Precache_Zombie_Drops()
{
	PrecacheModel(NUKE_MODEL, true);
	PrecacheSound(NUKE_SOUND, true);
	
	PrecacheModel(AMMO_MODEL, true);
	PrecacheSound(AMMO_SOUND, true);
}

public void Renable_Powerups()
{
	i_AllowMaxammo = true;
	i_AllowNuke = true;
}

public void BalanceDropMinimum(float multi)
{
	if(EscapeMode)
	{
		i_KillTheseManyMorePowerup_Nuke = RoundToCeil(f_KillTheseManyMorePowerup_base_Nuke * multi);
		i_KillTheseManyMorePowerup_Maxammo = RoundToCeil(f_KillTheseManyMorePowerup_base_Maxammo * multi);
	}
	else
	{
		i_KillTheseManyMorePowerup_Nuke = RoundToCeil((f_KillTheseManyMorePowerup_base_Nuke + (Waves_GetRound() * 2)) * (multi));
		i_KillTheseManyMorePowerup_Maxammo = RoundToCeil((f_KillTheseManyMorePowerup_base_Maxammo + (Waves_GetRound() * 2)) * (multi));
	}
}


public void DropPowerupChance(int entity)
{
	if(b_NpcForcepowerupspawn[entity] == 2)
	{
		SpawnMaxAmmo(entity);
	}
	i_KilledThisMany_Nuke += 1;
	if(i_KilledThisMany_Nuke > i_KillTheseManyMorePowerup_Nuke)
	{
		if(GetRandomFloat(0.0, 1.0) < 0.01)
		{
			if(i_AllowNuke)
			{
				if(!EscapeMode)
				{
					i_AllowNuke = false;
				}
				SpawnNuke(entity);
				i_KilledThisMany_Nuke = 0;
			}
		}
	}
	if(!EscapeMode)
	{
		i_KilledThisMany_Maxammo += 1;
		if(i_KilledThisMany_Maxammo > i_KillTheseManyMorePowerup_Maxammo)
		{
			if(GetRandomFloat(0.0, 1.0) < 0.01)
			{
				if(i_AllowMaxammo)
				{
					if(!EscapeMode)
					{
						i_AllowMaxammo = false;
					}
					SpawnMaxAmmo(entity);
					i_KilledThisMany_Maxammo = 0;
				}
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
		DispatchKeyValue(prop, "model", NUKE_MODEL);
		DispatchKeyValue(prop, "modelscale", "0.65");
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
				if (GetVectorDistance(powerup_pos, client_pos, true) <= Pow(64.0, 2.0))
				{
					int base_boss = -1;
					ParticleEffectAt(powerup_pos, "hightower_explosion", 1.0);
					ParticleEffectAt(powerup_pos, "utaunt_arcane_green_sparkle_start", 1.0);
					EmitSoundToAll(NUKE_SOUND, _, SNDCHAN_STATIC, 100, _);
					EmitSoundToAll(NUKE_SOUND, _, SNDCHAN_STATIC, 100, _);
					while((base_boss=FindEntityByClassname(base_boss, "base_boss")) != -1)
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
				if (GetVectorDistance(powerup_pos, client_pos, true) <= Pow(64.0, 2.0))
				{
					ParticleEffectAt(powerup_pos, "utaunt_arcane_green_sparkle_start", 1.0);
					EmitSoundToAll(AMMO_SOUND, _, SNDCHAN_STATIC, 100, _);
					EmitSoundToAll(AMMO_SOUND, _, SNDCHAN_STATIC, 100, _);
					for (int client_Hud = 1; client_Hud <= MaxClients; client_Hud++)
					{
						if (IsValidClient(client_Hud) && IsPlayerAlive(client_Hud) && GetClientTeam(client_Hud) == view_as<int>(TFTeam_Red))
						{
							int Armor_Max = 150;
							int Extra = 0;
								
							Extra = Armor_Level[client_Hud];
								
							Armor_Max = MaxArmorCalculation(Extra, client, 1.0);
								
							if(Armor_Charge[client_Hud] < Armor_Max)
							{
										
								if(Extra == 50)
									Armor_Charge[client_Hud] += 150;
									
								else if(Extra == 100)
									Armor_Charge[client_Hud] += 200;
									
								else if(Extra == 150)
									Armor_Charge[client_Hud] += 400;
									
								else if(Extra == 200)
									Armor_Charge[client_Hud] += 800;
									
								else
									Armor_Charge[client_Hud] += 50;
											
								if(Armor_Charge[client_Hud] >= Armor_Max)
								{
									Armor_Charge[client_Hud] = Armor_Max;
								}
							}
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
											SetAmmo(client_Hud, 21, GetAmmo(client_Hud, 21)+(AmmoData[21][1]*4));
										}
										else if (weaponindex == 305)
										{
											SetAmmo(client_Hud, 21, GetAmmo(client_Hud, 21)+(AmmoData[21][1]*4));
											SetAmmo(client_Hud, 14, GetAmmo(client_Hud, 14)+(AmmoData[14][1]*4));
											//Yeah extra ammo, do i care ? no.							
										}
										else if(weaponindex == 411)
										{
											SetAmmo(client_Hud, 22, GetAmmo(client_Hud, 22)+(AmmoData[22][1]*4));
										}
										else if(weaponindex == 441 || weaponindex == 35)
										{
											SetAmmo(client_Hud, 23, GetAmmo(client_Hud, 23)+(AmmoData[23][1]*4));	
										}
										else if(weaponindex == 998)
										{
											SetAmmo(client_Hud, 3, GetAmmo(client_Hud, 3)+(AmmoData[3][1]*4));	
										}
										else if(Ammo_type != -1 && Ammo_type < Ammo_Hand_Grenade) //Disallow Ammo_Hand_Grenade, that ammo type is regenerative!, dont use jar, tf2 needs jar? idk, wierdshit.
										{
											SetAmmo(client_Hud, Ammo_type, GetAmmo(client_Hud, Ammo_type)+(AmmoData[Ammo_type][1]*4));
										}
										else if(Ammo_type > 0 && Ammo_type < Ammo_MAX)
										{
											SetAmmo(client_Hud, Ammo_type, GetAmmo(client_Hud, Ammo_type)+(AmmoData[Ammo_type][1]*4));
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

public Action Timer_Aleart_Despawn(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		SetEntityRenderFx(entity, RENDERFX_PULSE_FAST); 
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
