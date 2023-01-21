#pragma semicolon 1
#pragma newdecls required

static int weapon_id[MAXPLAYERS+1]={8, ...};
static const float nullVec[] = {0.0,0.0,0.0};
static int g_ProjectileModel;
static Handle Give_bomb_back[MAXPLAYERS+1];
static bool Handle_on[MAXPLAYERS+1]={false, ...};

public void Weapon_Pipebomb(int client, int weapon, const char[] classname, bool &result)
{
	if(weapon >= MaxClients)
	{
		weapon_id[client] = weapon;
		Give_bomb_back[client] = CreateTimer(15.0, Give_Back_Pipebomb, client, TIMER_FLAG_NO_MAPCHANGE);
		if(Handle_on[client])
		{
			KillTimer(Give_bomb_back[client]);
		}
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Threw Pipebomb");
		SetAmmo(client, Ammo_Hand_Grenade, 0); //Give ammo back that they just spend like an idiot
		CurrentAmmo[client][Ammo_Hand_Grenade] = GetAmmo(client, Ammo_Hand_Grenade);
		Handle_on[client] = true;
	}
}

public void Pipebomb_MapStart()
{
	static char model[PLATFORM_MAX_PATH];
	model = "models/workshop/weapons/c_models/c_caber/c_caber.mdl";
	g_ProjectileModel = PrecacheModel(model);
}

public void Is_Pipebomb(int entity)
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
				SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModel, _, i);
			}
			SetEntPropVector(entity, Prop_Send, "m_vecMins", nullVec);
			SetEntPropVector(entity, Prop_Send, "m_vecMaxs", nullVec);
		}
	}	
}

public Action Give_Back_Pipebomb(Handle cut_timer, int client)
{
	if (IsValidClient(client))
	{
		//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
		//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
		SetAmmo(client, Ammo_Hand_Grenade, 1); //Give ammo back that they just spend like an idiot
		CurrentAmmo[client][Ammo_Hand_Grenade] = GetAmmo(client, Ammo_Hand_Grenade);
		ClientCommand(client, "playgamesound items/gunpickup2.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Pipebomb Is Back");
		Handle_on[client] = false;
	}
	return Plugin_Handled;
}
