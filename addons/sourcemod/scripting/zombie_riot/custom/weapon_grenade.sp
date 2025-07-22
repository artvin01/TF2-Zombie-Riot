#pragma semicolon 1
#pragma newdecls required

static int weapon_id[MAXPLAYERS+1]={8, ...};
static const float nullVec[] = {0.0,0.0,0.0};
static Handle Give_bomb_back[MAXPLAYERS+1];
static bool Handle_on[MAXPLAYERS+1]={false, ...};
static int g_ProjectileModel;
static int g_ProjectileModelPipe;
Handle TimerHudGrenade[MAXPLAYERS+1] = {null, ...};
static float f_GrenadeHudCD[MAXPLAYERS+1];
static float OriginalSize[MAXENTITIES];


public bool ClientHasUseableGrenadeOrDrink(int client)
{
	if(TimerHudGrenade[client] != null)
		return true;

	return false;
}

public void GrenadeApplyCooldownHud(int client, float cooldown)
{
	f_GrenadeHudCD[client] = GetGameTime() + cooldown;
}

float GrenadeApplyCooldownReturn(int client)
{
	return f_GrenadeHudCD[client];
}

public void Enable_Management_GrenadeHud(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (TimerHudGrenade[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_GRENADEHUD || i_CustomWeaponEquipLogic[weapon] == WEAPON_ZEALOT_POTION)
		{
			delete TimerHudGrenade[client];
			TimerHudGrenade[client] = null;
			DataPack pack;
			TimerHudGrenade[client] = CreateDataTimer(0.5, TimerHudGrenade_Manager, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
			OriginalSize[weapon] = f_WeaponSizeOverride[weapon];
			UpdateWeaponVisibleGrenade(weapon, client);
			return;
		}
	}

	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_GRENADEHUD || i_CustomWeaponEquipLogic[weapon] == WEAPON_ZEALOT_POTION)
	{	
		DataPack pack;
		TimerHudGrenade[client] = CreateDataTimer(0.5, TimerHudGrenade_Manager, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		OriginalSize[weapon] = f_WeaponSizeOverride[weapon];
		UpdateWeaponVisibleGrenade(weapon, client);
	}
}
public Action TimerHudGrenade_Manager(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		TimerHudGrenade[client] = null;
		return Plugin_Stop;
	}	
	int weapon_active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	UpdateWeaponVisibleGrenade(weapon, client, (weapon_active == weapon));
	return Plugin_Continue;
}

void UpdateWeaponVisibleGrenade(int weapon, int client, bool Update = false)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_ZEALOT_POTION)
	{
		if (Ability_Check_Cooldown(client, 2, weapon) > 0.0)
		{
			f_WeaponSizeOverride[weapon] = 0.0;
			f_WeaponSizeOverrideViewmodel[weapon] = 0.0;
		}
		else
		{
			f_WeaponSizeOverride[weapon] = OriginalSize[weapon];
			f_WeaponSizeOverrideViewmodel[weapon] = OriginalSize[weapon];
		}
	}
	else
	{
		if(CurrentAmmo[client][Ammo_Hand_Grenade] == 0)
		{
			f_WeaponSizeOverride[weapon] = 0.0;
			f_WeaponSizeOverrideViewmodel[weapon] = 0.0;
		}
		else
		{
			f_WeaponSizeOverride[weapon] = OriginalSize[weapon];
			f_WeaponSizeOverrideViewmodel[weapon] = OriginalSize[weapon];
		}
	}
	if(Update)
		HidePlayerWeaponModel(client, weapon);
}
public void Grenade_Custom_Precache()
{
	Zero(Handle_on);
	Zero(f_GrenadeHudCD);

	PrecacheSound("mvm/giant_demoman/giant_demoman_grenade_shoot.wav");
	
	g_ProjectileModel = PrecacheModel("models/workshop/weapons/c_models/c_quadball/w_quadball_grenade.mdl");
	g_ProjectileModelPipe = PrecacheModel("models/weapons/w_grenade.mdl");
}

public void Weapon_Grenade(int client, int weapon, const char[] classname, bool &result)
{
	if(weapon >= MaxClients)
	{
		weapon_id[client] = weapon;
		Give_bomb_back[client] = CreateTimer(15.0 * CooldownReductionAmount(client), Give_Back_Grenade, client, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(15.0 * CooldownReductionAmount(client), Give_Back_Magic_Restore_Ammo, client, TIMER_FLAG_NO_MAPCHANGE);
	//	CreateTimer(14.5, ResetWeaponAmmoStatus, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE);
		GrenadeApplyCooldownHud(client, 15.0 * CooldownReductionAmount(client));
		if(Handle_on[client])
		{
			delete Give_bomb_back[client];
		}
	//	SetDefaultHudPosition(client);
	//	SetGlobalTransTarget(client);
	//	ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Threw Grenade");
		Handle_on[client] = true;
		SetAmmo(client, Ammo_Hand_Grenade, 0); //Give ammo back that they just spend like an idiot
		CurrentAmmo[client][Ammo_Hand_Grenade] = 0;
		UpdateWeaponVisibleGrenade(weapon, client, true);
	}
}

void Reset_stats_Grenade_Singular(int client)
{
	Handle_on[client] = false;
}

static Action Give_Back_Grenade(Handle cut_timer, int client)
{
	if (IsValidClient(client))
	{
		//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
		//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
		SetAmmo(client, Ammo_Hand_Grenade, 1); //Give ammo back that they just spend like an idiot
		CurrentAmmo[client][Ammo_Hand_Grenade] = 1;
	//	ClientCommand(client, "playgamesound items/gunpickup2.wav");
	//	SetHudTextParams(-1.0, 0.45, 3.01, 34, 139, 34, 255);
	//	SetGlobalTransTarget(client);
	//	ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Grenade Is Back");
		Handle_on[client] = false;
	}
	return Plugin_Handled;
}

public void Weapon_Pipebomb(int client, int weapon, const char[] classname, bool &result)
{
	if(weapon >= MaxClients)
	{
		weapon_id[client] = weapon;
		float DefaultCooldownAlly = 15.0;
		DefaultCooldownAlly *= CooldownReductionAmount(client);
		DefaultCooldownAlly *= Attributes_Get(weapon, 97, 1.0);
		Give_bomb_back[client] = CreateTimer(DefaultCooldownAlly, Give_Back_Pipebomb, client, TIMER_FLAG_NO_MAPCHANGE);
	//	CreateTimer(14.5, ResetWeaponAmmoStatus, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE);
		GrenadeApplyCooldownHud(client, DefaultCooldownAlly);
		if(Handle_on[client])
		{
			delete Give_bomb_back[client];
		}
	//	SetDefaultHudPosition(client);
	//	SetGlobalTransTarget(client);
	//	ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Threw Pipebomb");
		SetAmmo(client, Ammo_Hand_Grenade, 0); //Give ammo back that they just spend like an idiot
		CurrentAmmo[client][Ammo_Hand_Grenade] = 0;
		Handle_on[client] = true;
		UpdateWeaponVisibleGrenade(weapon, client, true);
	}
}

public void Weapon_Pipebomb_Flash(int client, int weapon, const char[] classname, bool &result)
{
	if(weapon >= MaxClients)
	{
		weapon_id[client] = weapon;
		float DefaultCooldownAlly = 15.0;
		if(RaidbossIgnoreBuildingsLogic())
			DefaultCooldownAlly *= 3.0;
		DefaultCooldownAlly *= CooldownReductionAmount(client);
		DefaultCooldownAlly *= Attributes_Get(weapon, 97, 1.0);
		Give_bomb_back[client] = CreateTimer(DefaultCooldownAlly, Give_Back_Pipebomb, client, TIMER_FLAG_NO_MAPCHANGE);
	//	CreateTimer(14.5, ResetWeaponAmmoStatus, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE);
		GrenadeApplyCooldownHud(client, DefaultCooldownAlly);
		if(Handle_on[client])
		{
			delete Give_bomb_back[client];
		}
	//	SetDefaultHudPosition(client);
	//	SetGlobalTransTarget(client);
	//	ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Threw Pipebomb");
		SetAmmo(client, Ammo_Hand_Grenade, 0); //Give ammo back that they just spend like an idiot
		CurrentAmmo[client][Ammo_Hand_Grenade] = 0;
		Handle_on[client] = true;
		UpdateWeaponVisibleGrenade(weapon, client, true);
	}
}

void Is_Pipebomb(int entity)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (owner > 0 && owner <= MaxClients)
	{
		if (!IsClientInGame(owner))
		{
			return;
		}

		int weapon_active = GetEntPropEnt(owner, Prop_Send, "m_hActiveWeapon");
		int weaponindex = GetEntProp(weapon_active, Prop_Send, "m_iItemDefinitionIndex");
			
		if(weaponindex == 1083)
		{
			for(int i; i<4; i++)
			{
				SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelPipe, _, i);
			}
			SetEntPropVector(entity, Prop_Send, "m_vecMins", nullVec);
			SetEntPropVector(entity, Prop_Send, "m_vecMaxs", nullVec);
		}
	}	
}

static Action Give_Back_Pipebomb(Handle cut_timer, int client)
{
	if (IsValidClient(client))
	{
		//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
		//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
		SetAmmo(client, Ammo_Hand_Grenade, 1); //Give ammo back that they just spend like an idiot
		CurrentAmmo[client][Ammo_Hand_Grenade] = 1;
	//	ClientCommand(client, "playgamesound items/gunpickup2.wav");
	//	SetDefaultHudPosition(client);
	//	SetGlobalTransTarget(client);
	//	ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Pipebomb Is Back");
		Handle_on[client] = false;
	}
	return Plugin_Handled;
}

public void Weapon_ShotgunGrenadeLauncher(int client, int weapon, const char[] classname, bool &result)
{
	if(weapon >= MaxClients)
	{
		if(!TF2_IsPlayerInCondition(client, TFCond_RuneHaste))
		{
			static float anglesB[3];
			GetClientEyeAngles(client, anglesB);
			static float velocity[3];
			GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(velocity, -350.0);
			if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
				velocity[2] = fmax(velocity[2], 250.0);
			else
				velocity[2] += 100.0; // a little boost to alleviate arcing issues
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
		}
		
		EmitSoundToAll("mvm/giant_demoman/giant_demoman_grenade_shoot.wav", client, SNDCHAN_STATIC, 80, _, 0.8);
		Client_Shake(client, 0, 35.0, 20.0, 0.8);
		
		float speed = 1500.0;
		float damage = 100.0;
			
		damage *= Attributes_Get(weapon, 1, 1.0);

		damage *= Attributes_Get(weapon, 2, 1.0);
			
		speed *= Attributes_Get(weapon, 103, 1.0);
		
		speed *= Attributes_Get(weapon, 104, 1.0);
		
		speed *= Attributes_Get(weapon, 475, 1.0);
			
		float extra_accuracy = 5.0;
		
		extra_accuracy *= Attributes_Get(weapon, 106, 1.0);
			
		int team = GetClientTeam(client);
			
		for (int repeat = 1; repeat <= 4; repeat++)
		{
		
			int entity = CreateEntityByName("tf_projectile_pipe");
			if(IsValidEntity(entity))
			{
					static float pos[3], ang[3], vel_2[3];
					GetClientEyeAngles(client, ang);
					GetClientEyePosition(client, pos);	
					
					switch(repeat)
					{
						case 1:
						{
							ang[0] += -extra_accuracy;
							ang[1] += extra_accuracy;
						}
						case 2:
						{
							ang[0] += extra_accuracy;
							ang[1] += extra_accuracy;
						}
						case 3:
						{
							ang[0] += extra_accuracy;
							ang[1] += -extra_accuracy;
						}
						case 4:
						{
							ang[0] += -extra_accuracy;
							ang[1] += -extra_accuracy;
						}
					}
	
					ang[0] -= 8.0;
	
					vel_2[0] = Cosine(DegToRad(ang[0]))*Cosine(DegToRad(ang[1]))*speed;
					vel_2[1] = Cosine(DegToRad(ang[0]))*Sine(DegToRad(ang[1]))*speed;
					vel_2[2] = Sine(DegToRad(ang[0]))*speed;
					vel_2[2] *= -1;
					
					SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
					SetEntProp(entity, Prop_Send, "m_iTeamNum", team, 1);
					SetEntProp(entity, Prop_Send, "m_nSkin", (team-2));
					SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
					SetEntPropEnt(entity, Prop_Send, "m_hThrower", client);
					SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher",weapon);
					for(int i; i<4; i++)
					{
						SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModel, _, i);
					}
					
					SetVariantInt(team);
					AcceptEntityInput(entity, "TeamNum", -1, -1, 0);
					SetVariantInt(team);
					AcceptEntityInput(entity, "SetTeam", -1, -1, 0); 
					
					SetEntPropEnt(entity, Prop_Send, "m_hLauncher", weapon);
	
					DispatchSpawn(entity);
					TeleportEntity(entity, pos, ang, vel_2);
					IsCustomTfGrenadeProjectile(entity, damage);
			}
		}
	}
}


public void Weapon_ShotgunGrenadeLauncher_PAP(int client, int weapon, const char[] classname, bool &result)
{
	if(weapon >= MaxClients)
	{
		if(!TF2_IsPlayerInCondition(client, TFCond_RuneHaste))
		{
			static float anglesB[3];
			GetClientEyeAngles(client, anglesB);
			static float velocity[3];
			GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(velocity, -350.0);
			if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
				velocity[2] = fmax(velocity[2], 250.0);
			else
				velocity[2] += 100.0; // a little boost to alleviate arcing issues
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
		}
		
		EmitSoundToAll("mvm/giant_demoman/giant_demoman_grenade_shoot.wav", client, SNDCHAN_STATIC, 80, _, 0.8, 80);
		Client_Shake(client, 0, 35.0, 20.0, 0.8);
		
		float speed = 1500.0;
		float damage = 100.0;
			
		damage *= Attributes_Get(weapon, 1, 1.0);

		damage *= Attributes_Get(weapon, 2, 1.0);
			
		speed *= Attributes_Get(weapon, 103, 1.0);
		
		speed *= Attributes_Get(weapon, 104, 1.0);
		
		speed *= Attributes_Get(weapon, 475, 1.0);
			
		float extra_accuracy = 3.5;
		
		extra_accuracy *= Attributes_Get(weapon, 106, 1.0);
			
		int team = GetClientTeam(client);
			
		for (int repeat = 1; repeat <= 10; repeat++)
		{
		
			int entity = CreateEntityByName("tf_projectile_pipe");
			if(IsValidEntity(entity))
			{
					static float pos[3], ang[3], vel_2[3];
					GetClientEyeAngles(client, ang);
					GetClientEyePosition(client, pos);	
					
					switch(repeat)
					{
						case 1:
						{
							ang[0] += -extra_accuracy;
							ang[1] += extra_accuracy;
						}
						case 2:
						{
							ang[0] += extra_accuracy;
							ang[1] += extra_accuracy;
						}
						case 3:
						{
							ang[0] += extra_accuracy;
							ang[1] += -extra_accuracy;
						}
						case 4:
						{
							ang[0] += -extra_accuracy;
							ang[1] += -extra_accuracy;
						}
						case 5:
						{
							ang[0] += -extra_accuracy;
							ang[1] += extra_accuracy * 2.0;
						}
						case 6:
						{
							ang[0] += extra_accuracy;
							ang[1] += extra_accuracy * 2.0;
						}
						case 7:
						{
							ang[0] += extra_accuracy;
							ang[1] += -(extra_accuracy * 2.0);
						}
						case 8:
						{
							ang[0] += -extra_accuracy;
							ang[1] += -(extra_accuracy * 2.0);
						}
						case 9:
						{
							ang[0] += extra_accuracy;
						}
						case 10:
						{
							ang[0] += -extra_accuracy;
						}
					}
	
					ang[0] -= 8.0;
	
					vel_2[0] = Cosine(DegToRad(ang[0]))*Cosine(DegToRad(ang[1]))*speed;
					vel_2[1] = Cosine(DegToRad(ang[0]))*Sine(DegToRad(ang[1]))*speed;
					vel_2[2] = Sine(DegToRad(ang[0]))*speed;
					vel_2[2] *= -1;
					
					SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
					SetEntProp(entity, Prop_Send, "m_iTeamNum", team, 1);
					SetEntProp(entity, Prop_Send, "m_nSkin", (team-2));
					SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
					SetEntPropEnt(entity, Prop_Send, "m_hThrower", client);
					SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher",weapon);
					for(int i; i<4; i++)
					{
						SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModel, _, i);
					}
					
					SetVariantInt(team);
					AcceptEntityInput(entity, "TeamNum", -1, -1, 0);
					SetVariantInt(team);
					AcceptEntityInput(entity, "SetTeam", -1, -1, 0); 
					
					SetEntPropEnt(entity, Prop_Send, "m_hLauncher", weapon);
	
					DispatchSpawn(entity);
					TeleportEntity(entity, pos, ang, vel_2);
					IsCustomTfGrenadeProjectile(entity, damage);
			}
		}
	}
}