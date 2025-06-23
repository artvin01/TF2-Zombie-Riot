
static Handle TrueStrengthShieldHandle[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
static bool TrueStrengthShield[MAXPLAYERS+1] = {false, ...};
static int TrueStrengthShieldCounter[MAXPLAYERS+1] = {0, ...};

static bool BobsPureRage[MAXPLAYERS+1] = {false, ...};
static bool BobsPocketPhone[MAXPLAYERS+1] = {false, ...};
static bool FlowerItem[MAXPLAYERS+1] = {false, ...};
static bool BobsWetstone[MAXPLAYERS+1] = {false, ...};

#define SOUND_CRIT_DEAL_BOB		"weapons/rescue_ranger_charge_01.wav"
public void TrueStrengthShieldUnequip(int client)
{
	TrueStrengthShieldCounter[client] = 0;
	TrueStrengthShield[client] = false;
	BobsPureRage[client] = false;
	BobsPocketPhone[client] = false;
	FlowerItem[client] = false;
	BobsWetstone[client] = false;
	TF2_RemoveCondition(client, TFCond_UberFireResist);

	if (TrueStrengthShieldHandle[client] != INVALID_HANDLE)
		delete TrueStrengthShieldHandle[client];
}

public void TrueStrengthShieldDisconnect(int client)
{
	TrueStrengthShieldCounter[client] = 0;
	TrueStrengthShield[client] = false;
	TrueStrengthShieldHandle[client] = INVALID_HANDLE;
	BobsPureRage[client] = false;
	BobsPocketPhone[client] = false;
	BobsWetstone[client] = false;
}

public void TrueStrengthShieldEquip(int client, int weapon, int index)
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		if (TrueStrengthShieldHandle[client] != INVALID_HANDLE)
			return;

		TrueStrengthShieldCounter[client] = 80;
		TrueStrengthShield[client] = true;		
		TrueStrengthShieldHandle[client] = CreateTimer(0.5, TrueStrengthShieldTimer, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

void Abiltity_TrueStrength_Shield_Shield_MapStart()
{
	PrecacheSound("player/resistance_light1.wav");
	PrecacheSound("player/resistance_light2.wav");
	PrecacheSound("player/resistance_light3.wav");
	PrecacheSound("player/resistance_light4.wav");
	PrecacheSound("player/resistance_medium1.wav");
	PrecacheSound("player/resistance_medium2.wav");
	PrecacheSound("player/resistance_medium3.wav");
	PrecacheSound("player/resistance_medium4.wav");
	PrecacheSound("player/resistance_heavy1.wav");
	PrecacheSound("player/resistance_heavy2.wav");
	PrecacheSound("player/resistance_heavy3.wav");
	PrecacheSound("player/resistance_heavy4.wav");
	PrecacheSound("weapons/medi_shield_deploy.wav");
	PrecacheSound("weapons/medi_shield_retract.wav");
	PrecacheSound(SOUND_CRIT_DEAL_BOB);
}

bool Ability_TrueStrength_Shield_OnTakeDamage(int victim)
{
	if (TrueStrengthShield[victim])
	{
		if(TrueStrengthShieldCounter[victim] > 80)
		{
			if(!CheckInHud())
			{
				TrueStrengthShieldCounter[victim] = 0;
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

				float PercentageHeal = 0.1;
				
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
			}
			return true;
		}
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

		if(TrueStrengthShieldCounter[client] > 80)
			return Plugin_Continue;

		TrueStrengthShieldCounter[client] += 1;
		if(TrueStrengthShieldCounter[client] > 79)
		{
			EmitSoundToAll("weapons/medi_shield_deploy.wav",client,_,70,_,0.4);
			TF2_AddCondition(client, TFCond_MegaHeal, 0.5, client);
			TrueStrengthShieldCounter[client] = 81;
			TF2_AddCondition(client, TFCond_UberFireResist, -1.0, client);
		}
		return Plugin_Continue;
	}
	else
	{
		return Plugin_Stop;
	}
}


//bobs Strength


public void RPG_BobsPureRageEquip(int client, int weapon, int index)
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		BobsPureRage[client] = true;
	}
}


bool RPG_BobsPureRage(int victim, int attacker, float &damage)
{
	bool ReturnVal;
	if(IsValidClient(attacker) && BobsPureRage[attacker])
	{
		int MaxHealth = SDKCall_GetMaxHealth(attacker);
		int Health = GetEntProp(attacker, Prop_Send, "m_iHealth");

		float Ratio = float(Health) / float(MaxHealth);
		if(Ratio <= 0.75)
		{
			damage *= 1.25;
			ReturnVal = true;
		}
	}
	if(IsValidClient(victim) && BobsPureRage[victim])
	{
		int MaxHealth = SDKCall_GetMaxHealth(victim);
		int Health = GetEntProp(victim, Prop_Send, "m_iHealth");

		float Ratio = float(Health) / float(MaxHealth);
		if(Ratio <= 0.75)
		{
			damage *= 0.85;
			ReturnVal = true;
		}
	}
	return ReturnVal;
}


public void RPG_PocketPhone(int client, int weapon, int index)
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		BobsPocketPhone[client] = true;
	}
}

bool BobsPhoneReduceCooldown(int client)
{
	return BobsPocketPhone[client];
}
public void FlowerCooldownReduction(int client, int weapon, int index)
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		FlowerItem[client] = true;
	}
}
bool FlowerReduceCooldown(int client)
{
	return FlowerItem[client];
}

public void RPG_BobWetstone(int client, int weapon, int index)
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		BobsWetstone[client] = true;
	}
}

int CurrentHitBobWetstone[MAXPLAYERS];

public float RPG_BobWetstoneTakeDamage(int attacker, int victim, float damagePosition[3])
{
	if(attacker > MaxClients)
		return 1.0;

	if(!BobsWetstone[attacker])
		return 1.0;

	if(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED)
		return 1.0;


	CurrentHitBobWetstone[attacker]++;

	if(CurrentHitBobWetstone[attacker] >= 6)
	{
		CurrentHitBobWetstone[attacker] = 0;
		DisplayHitEnemyTarget(attacker, damagePosition, false);
		EmitSoundToClient(attacker, SOUND_CRIT_DEAL_BOB, attacker,_,70,_,0.65);
		return 3.0;
	}
	return 1.0;
}