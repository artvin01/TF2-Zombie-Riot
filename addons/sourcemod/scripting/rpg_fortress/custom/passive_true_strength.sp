static Handle TrueStrengthHandle[MAXENTITIES] = {INVALID_HANDLE, ...};
static bool TrueStrength[MAXPLAYERS+1] = {false, ...};
static bool TrueStrength_Rage[MAXPLAYERS+1] = {false, ...};
static int TrueStrengthShieldCounter[MAXPLAYERS+1] = {0, ...};
static int i_BleedStackLogic[MAXENTITIES][MAXPLAYERS+1];

public void TrueStrengthShieldUnequip(int client)
{
	TrueStrengthShield[client] = false;
	
	delete TrueStrengthHandle[client];
}

public void TrueStrengthShieldDisconnect(int client)
{
	TrueStrengthShield[client] = false;
	TrueStrengthHandle[client] = INVALID_HANDLE;
}

public void TrueStrengthShieldEquip(int client, int weapon, int index)
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		if (TrueStrengthHandle[client] != INVALID_HANDLE)
			return;

		TrueStrengthShield[client] = true;		
		TrueStrengthHandle[client] = CreateTimer(0.5, TrueStrengthShieldTimer, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

void Abiltity_TrueStrength_Shield_Shield_PluginStart()
{
	PrecacheSound("player/resistance_light1.wav", true);
	PrecacheSound("player/resistance_light2.wav", true);
	PrecacheSound("player/resistance_light3.wav", true);
	PrecacheSound("player/resistance_light4.wav", true);
	PrecacheSound("player/resistance_medium1.wav", true);
	PrecacheSound("player/resistance_medium2.wav", true);
	PrecacheSound("player/resistance_medium3.wav", true);
	PrecacheSound("player/resistance_medium4.wav", true);
	PrecacheSound("player/resistance_heavy1.wav", true);
	PrecacheSound("player/resistance_heavy2.wav", true);
	PrecacheSound("player/resistance_heavy3.wav", true);
	PrecacheSound("player/resistance_heavy4.wav", true);
	PrecacheSound("weapons/medi_shield_deploy.wav", true);
	PrecacheSound("weapons/medi_shield_retract.wav", true);
}

bool NPC_Ability_TrueStrength_Shield_OnTakeDamage(int victim)
{
	if (TrueStrengthShield[victim])
	{

	}
	return false;
}

static Action TrueStrengthShieldTimer(Handle dashHud, int ref)
{
	int client = EntRefToEntIndex(ref);
	if (IsValidClient(client))
	{
		if(!IsPlayerAlive(client))
			return Plugin_Continue;

		return Plugin_Continue;
	}
	else
	{
		return Plugin_Stop;
	}
}

int TrueStrength_StacksOnEntity(int entity, int client)
{
	return i_BleedStackLogic[entity][client];
}

int TrueStrength_Reset(int entity)
{
	for(int client; client <= MaxClients; client++)
	{
		i_BleedStackLogic[entity][client] = 0;
	}
	delete TrueStrengthHandle[entity];
}


int TrueStrength_Reset(int entity)
{

}