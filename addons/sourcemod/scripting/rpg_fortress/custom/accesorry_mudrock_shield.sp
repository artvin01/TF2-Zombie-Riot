
static Handle MudrockShieldHandle[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
static bool MudrockShield[MAXPLAYERS+1] = {false, ...};
static int MudrockShieldCounter[MAXPLAYERS+1] = {0, ...};

public void MudrockShieldUnequip(int client)
{
	MudrockShieldCounter[client] = 0;
	MudrockShield[client] = false;
	TF2_RemoveCondition(client, TFCond_UberFireResist);
	
	if (MudrockShieldHandle[client] == INVALID_HANDLE)
		return;

	KillTimer(MudrockShieldHandle[client]);
	MudrockShieldHandle[client] = INVALID_HANDLE;
}

public void MudrockShieldDisconnect(int client)
{
	MudrockShieldCounter[client] = 0;
	MudrockShield[client] = false;
	MudrockShieldHandle[client] = INVALID_HANDLE;
}

public void MudrockShieldEquip(int client, int weapon, int index)
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		if (MudrockShieldHandle[client] != INVALID_HANDLE)
			return;

		MudrockShieldCounter[client] = 60;
		MudrockShield[client] = true;		
		MudrockShieldHandle[client] = CreateTimer(0.5, MudrockShieldTimer, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

void Abiltity_Mudrock_Shield_Shield_PluginStart()
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

bool Ability_Mudrock_Shield_OnTakeDamage(int victim)
{
	if (MudrockShield[victim])
	{
		if(MudrockShieldCounter[victim] > 60)
		{
			MudrockShieldCounter[victim] = 0;
			TF2_RemoveCondition(victim, TFCond_UberFireResist);

			switch(GetRandomInt(1,4))
			{
				case 1:
				{
					EmitSoundToAll("player/resistance_heavy1.wav", victim,_,70);
					EmitSoundToAll("player/resistance_heavy1.wav", victim,_,70);
				}
				case 2:
				{
					EmitSoundToAll("player/resistance_heavy2.wav", victim,_,70);
					EmitSoundToAll("player/resistance_heavy2.wav", victim,_,70);
				}
				case 3:
				{
					EmitSoundToAll("player/resistance_heavy3.wav", victim,_,70);
					EmitSoundToAll("player/resistance_heavy3.wav", victim,_,70);
				}
				case 4:
				{
					EmitSoundToAll("player/resistance_heavy4.wav", victim,_,70);
					EmitSoundToAll("player/resistance_heavy4.wav", victim,_,70);
				}
			}

			int MaxHealth = SDKCall_GetMaxHealth(victim);
			int Health = GetEntProp(victim, Prop_Send, "m_iHealth");

			float PercentageHeal = 0.15;
			
			if(Stats_Strength(victim) > 40) //Give melee more
			{
				PercentageHeal = 0.20;
			}
			else if(Stats_Strength(victim) > 60) //Give melee more
			{
				PercentageHeal = 0.25;
			}

			int NewHealth = Health + RoundToCeil(float(MaxHealth) * PercentageHeal);

			if(NewHealth > MaxHealth)
			{
				NewHealth = MaxHealth;
			}
			TF2_AddCondition(victim, TFCond_MegaHeal, 1.0);
			float pos[3];
			GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
			pos[2] += 45.0;
			TE_Particle("peejar_impact_cloud_milk", pos, NULL_VECTOR, NULL_VECTOR, victim, _, _, _, _, _, _, _, _, _, 0.0);
			SetEntProp(victim, Prop_Send, "m_iHealth", NewHealth);
			return true;
		}
	}
	return false;
}

static Action MudrockShieldTimer(Handle dashHud, int ref)
{
	int client = EntRefToEntIndex(ref);
	if (IsValidClient(client))
	{
		if(!IsPlayerAlive(client))
			return Plugin_Continue;

		if(MudrockShieldCounter[client] > 60)
			return Plugin_Continue;

		MudrockShieldCounter[client] += 1;
		if(MudrockShieldCounter[client] > 59)
		{
			EmitSoundToAll("weapons/medi_shield_deploy.wav",client,_,70,_,0.4);
			TF2_AddCondition(client, TFCond_MegaHeal, 0.5, client);
			MudrockShieldCounter[client] = 61;
			TF2_AddCondition(client, TFCond_UberFireResist, -1.0, client);
		}
		return Plugin_Continue;
	}
	else
	{
		return Plugin_Stop;
	}
}