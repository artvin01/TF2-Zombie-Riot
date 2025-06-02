#pragma semicolon 1
#pragma newdecls required

//static Handle OC_Timer = null;

public void Kritzkrieg_OnMapStart()
{
	HookEvent("player_chargedeployed", OnKritzkriegDeployed);
}

static void OnKritzkriegDeployed(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!IsValidClient(client) || !IsPlayerAlive(client))
		return;

	int medigun;
	bool Continune = false;
	int ie;
	int entity;
	while(TF2_GetItem(client, entity, ie))
	{
		if(i_CustomWeaponEquipLogic[entity] == WEAPON_KRITZKRIEG)
		{
			medigun = entity;
			Continune = true;
		}
	}
	if(!Continune)
		return;

	CreateTimer(0.1, Timer_Kritzkrieg, EntIndexToEntRef(medigun), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	int target = GetHealingTarget(client);
	if(IsValidClient(target) && IsPlayerAlive(target)) 
	{
		GiveArmorViaPercentage(target, 0.5, 1.0,_,_,client);
	}
	GiveArmorViaPercentage(client, 0.5, 1.0,_,_,client);
}

static Action Timer_Kritzkrieg(Handle timer, any medigunid)
{
	int medigun = EntRefToEntIndex(medigunid);
	if(!IsValidEntity(medigun))
		return Plugin_Stop;
	int client = GetEntPropEnt(medigun, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(client))
		return Plugin_Stop;
	int target = GetHealingTarget(client);
	float charge = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");

	if((!IsValidClient(client) && !IsPlayerAlive(client)) || charge <= 0.05)
		return Plugin_Stop;

	if(IsValidClient(target) && IsPlayerAlive(target))
	{
		ApplyStatusEffect(client, target, "Weapon Overclock", 1.0);
		Kritzkrieg_Magical(target, 0.05, true);
	}
	else if(target != INVALID_ENT_REFERENCE && IsEntityAlive(target) && GetTeam(client) == GetTeam(target))
	{
		ApplyStatusEffect(client, target, "Weapon Overclock", 1.0);
	}
	
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		ApplyStatusEffect(client, client, "Weapon Overclock", 1.0);
		Kritzkrieg_Magical(client, 0.05, true);
	}
	return Plugin_Continue;
}

static int GetHealingTarget(int client)
{
	int medigun;
	int ie;
	int entity;
	int ActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	while(TF2_GetItem(client, entity, ie))
	{
		if(b_IsAMedigun[entity] && entity == ActiveWeapon)
		{
			medigun = entity;
		}
	}

	if(IsValidEntity(medigun))
	{
		static char classname[64];
		GetEntityClassname(medigun, classname, sizeof(classname));
		if(StrEqual(classname, "tf_weapon_medigun", false))
		{
			if(GetEntProp(medigun, Prop_Send, "m_bHealing"))
				return GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
		}
	}
	return -1;
}

static void Kritzkrieg_Magical(int client, float Scale, bool apply)
{
	int entity, i;
	bool HasMageWeapon;
	while(TF2_GetItem(client, entity, i))
	{
		if(i_IsWandWeapon[entity])
		{
			HasMageWeapon = true;
			break;
		}
	}
	if(HasMageWeapon)
	{
		if(apply)
		{
			ManaCalculationsBefore(client);
			if(Current_Mana[client] < RoundToCeil(max_mana[client]))
			{
				Current_Mana[client] += RoundToCeil(mana_regen[client] * 20.0 * Scale);
					
				if(Current_Mana[client] > RoundToCeil(max_mana[client])) //Should only apply during actual regen
				{
					Current_Mana[client] = RoundToCeil(max_mana[client]);
				}
			}
		}
	}
}