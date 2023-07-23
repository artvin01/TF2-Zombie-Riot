#pragma semicolon 1
#pragma newdecls required

static int weapon_id[MAXPLAYERS+1]={8, ...};
static Handle Give_bomb_back[MAXPLAYERS+1];
static bool Handle_on[MAXPLAYERS+1]={false, ...};
static int g_ProjectileModel;

public void Grenade_Custom_Precache()
{
	PrecacheSound("mvm/giant_demoman/giant_demoman_grenade_shoot.wav");
	static char model[PLATFORM_MAX_PATH];
	model = "models/workshop/weapons/c_models/c_quadball/w_quadball_grenade.mdl";
	g_ProjectileModel = PrecacheModel(model);
}

public void Weapon_Grenade(int client, int weapon, const char[] classname, bool &result)
{
	if(weapon >= MaxClients)
	{
		weapon_id[client] = weapon;
		Give_bomb_back[client] = CreateTimer(15.0, Give_Back_Grenade, client, TIMER_FLAG_NO_MAPCHANGE);
		if(Handle_on[client])
		{
			KillTimer(Give_bomb_back[client]);
		}
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Threw Grenade");
		Handle_on[client] = true;
		SetAmmo(client, Ammo_Hand_Grenade, 0); //Give ammo back that they just spend like an idiot
		CurrentAmmo[client][Ammo_Hand_Grenade] = GetAmmo(client, Ammo_Hand_Grenade);
	}
}


public Action Give_Back_Grenade(Handle cut_timer, int client)
{
	if (IsValidClient(client))
	{
		//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
		//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
		SetAmmo(client, Ammo_Hand_Grenade, 1); //Give ammo back that they just spend like an idiot
		CurrentAmmo[client][Ammo_Hand_Grenade] = GetAmmo(client, Ammo_Hand_Grenade);
		ClientCommand(client, "playgamesound items/gunpickup2.wav");
		SetHudTextParams(-1.0, 0.45, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Grenade Is Back");
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