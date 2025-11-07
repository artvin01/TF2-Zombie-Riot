#pragma semicolon 1
#pragma newdecls required

//static Handle OC_Timer = null;

public void Kritzkrieg_OnMapStart()
{
	PrecacheSound("player/invuln_on_vaccinator.wav");
	PrecacheSound("player/mannpower_invulnerable.wav");
}
public void Kritzkrieg_PluginStart()
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
	GiveMedigunBuffUber(medigun, client, client);
	int target = GetHealingTarget(client);
	if(IsValidAlly(client, target))
	{
		GiveMedigunBuffUber(medigun, client, target);
	}
	if(!Continune)
	{
		if(IsValidEntity(target) && IsValidClient(target))
			EmitSoundToClient(target, "player/invuln_on_vaccinator.wav", target, SNDCHAN_AUTO, 65, _, 0.6);

		EmitSoundToAll("player/invuln_on_vaccinator.wav", client, SNDCHAN_AUTO, 65, _, 0.6);
		return;
	}
	if(IsValidEntity(target) && IsValidClient(target))
		EmitSoundToClient(target, "player/mannpower_invulnerable.wav", target, SNDCHAN_AUTO, 65, _, 0.6);

	EmitSoundToAll("player/mannpower_invulnerable.wav", client, SNDCHAN_AUTO, 65, _, 0.6);

	if(IsValidClient(target) && IsPlayerAlive(target)) 
	{
		GiveArmorViaPercentage(target, 0.5, 1.0,_,_,client);
	}
	GiveArmorViaPercentage(client, 0.5, 1.0,_,_,client);
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

void Kritzkrieg_Magical(int client, float Scale, bool apply)
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