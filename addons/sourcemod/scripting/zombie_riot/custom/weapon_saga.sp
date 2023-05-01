#define SAGA_ABILITY_1	"items/samurai/tf_samurai_noisemaker_setb_01.wav"
#define SAGA_ABILITY_2	"items/samurai/tf_samurai_noisemaker_setb_02.wav"
#define SAGA_ABILITY_3	"items/samurai/tf_samurai_noisemaker_setb_03.wav"

static Handle WeaponTimer[MAXTF2PLAYERS];
static int WeaponRef[MAXTF2PLAYERS];
static int WeaponCharge[MAXTF2PLAYERS];
static float SagaCrippled[MAXENTITIES + 1];

void Saga_MapStart()
{
	PrecacheSound(SAGA_ABILITY_1);
	PrecacheSound(SAGA_ABILITY_2);
	PrecacheSound(SAGA_ABILITY_3);
	Zero(SagaCrippled);
	Zero(WeaponCharge);
}

void Saga_EntityCreated(int entity)
{
	SagaCrippled[entity] = 0.0;
}

void Saga_DeadEffects(int victim, int attacker, int weapon)
{
	if(SagaCrippled[victim])
		Saga_ChargeReduction(attacker, weapon, SagaCrippled[victim]);
}

void Saga_ChargeReduction(int client, int weapon, float time)
{
	Passanger_ChargeReduced(client, time);

	if(WeaponTimer[client] && EntRefToEntIndex(WeaponRef[client]) == weapon)
	{
		WeaponCharge[client] += RoundFloat(time) - 1;
		TriggerTimer(WeaponTimer[client], false);
	}
	
	for(int i = 1; i < 4; i++)
	{
		float cooldown = Ability_Check_Cooldown(client, i, weapon);
		if(cooldown > 0.0)
		{
			Ability_Apply_Cooldown(client, i, cooldown - time, weapon);
			break;
		}
	}
}

void Saga_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == 19)
	{
		WeaponRef[client] = EntIndexToEntRef(weapon);
		delete WeaponTimer[client];

		Address address = TF2Attrib_GetByDefIndex(weapon, 861);
		if(address == Address_Null)
		{
			// Elite 0 Special 1
			WeaponTimer[client] = CreateTimer(3.5, Saga_Timer1, client, TIMER_REPEAT);
		}
		else if(!TF2Attrib_GetValue(address))
		{
			// Elite 1 Special 2
			WeaponTimer[client] = CreateTimer(1.0, Saga_Timer2, client, TIMER_REPEAT);
		}
		else
		{
			// Elite 1 Special 3
			WeaponTimer[client] = CreateTimer(1.0, Saga_Timer3, client, TIMER_REPEAT);
		}
	}
}

public Action Saga_Timer1(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		int weapon = EntRefToEntIndex(WeaponRef[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			if(weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
			{
				int amount = 1 + (WeaponCharge[client] * 7 / 2);
				if(amount > 1)
					WeaponCharge[client] -= amount + 1;
				
				CashRecievedNonWave[client] += amount;
				CashSpent[client] -= amount;
			}
			
			return Plugin_Continue;
		}
	}

	WeaponTimer[client] = null;
	return Plugin_Stop;
}

public Action Saga_Timer2(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		int weapon = EntRefToEntIndex(WeaponRef[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			if(weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
			{
				if(++WeaponCharge[client] > 32)
					WeaponCharge[client] = 32;
				
				PrintHintText(client, "Cleansing Evil [%d / 2] {%ds}", WeaponCharge[client] / 16, 16 - (WeaponCharge[client] % 16));
				StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			}

			return Plugin_Continue;
		}
	}

	WeaponTimer[client] = null;
	return Plugin_Stop;
}

public Action Saga_Timer3(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		int weapon = EntRefToEntIndex(WeaponRef[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			if(weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
			{
				if(++WeaponCharge[client] > 39)
					WeaponCharge[client] = 39;
				
				PrintHintText(client, "Cleansing Evil [%d / 3] {%ds}", WeaponCharge[client] / 13, 13 - (WeaponCharge[client] % 13));
				StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			}

			return Plugin_Continue;
		}
	}

	WeaponTimer[client] = null;
	return Plugin_Stop;
}

public void Weapon_SagaE1_M2(int client, int weapon, bool crit, int slot)
{
	Weapon_Saga_M2(client, weapon, false);
}

public void Weapon_SagaE2_M2(int client, int weapon, bool crit, int slot)
{
	Weapon_Saga_M2(client, weapon, true);
}

static void Weapon_Saga_M2(int client, int weapon, bool mastery)
{
	int cost = mastery ? 13 : 16;
	if(WeaponCharge[client] < cost)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", float(cost - WeaponCharge[client]));
	}
	else
	{
		WeaponCharge[client] -= cost + 1;
		CashRecievedNonWave[client] += 4;
		CashSpent[client] -= 4;
		
		float damage = mastery ? 260.0 : 208.0;	// 400%, 320%
		Address	address = TF2Attrib_GetByDefIndex(weapon, 2);
		if(address != Address_Null)
			damage *= TF2Attrib_GetValue(address);
		
		int value = i_ExplosiveProjectileHexArray[client];
		i_ExplosiveProjectileHexArray[client] = EP_DEALS_CLUB_DAMAGE;
		
		Explode_Logic_Custom(damage, client, client, weapon, _, 400.0, 1.0, 0.0, false, 6);
		
		i_ExplosiveProjectileHexArray[client] = value;

		CreateTimer(0.8, Saga_DelayedExplode, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);

		int rand = GetURandomInt() % 3;
		EmitSoundToAll(rand == 0 ? SAGA_ABILITY_1 : (rand == 1 ? SAGA_ABILITY_2 : SAGA_ABILITY_3), client, SNDCHAN_AUTO, 75);

		TriggerTimer(WeaponTimer[client], true);
	}
}

public Action Saga_DelayedExplode(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		int weapon = EntRefToEntIndex(WeaponRef[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			float damage = 0.1;
			Address	address = TF2Attrib_GetByDefIndex(weapon, 2);
			if(address != Address_Null)
				damage *= TF2Attrib_GetValue(address);
			
			int value = i_ExplosiveProjectileHexArray[client];
			i_ExplosiveProjectileHexArray[client] = EP_DEALS_SLASH_DAMAGE;
			
			Explode_Logic_Custom(damage, client, client, weapon, _, 400.0, 1.0, 0.0, false, 99);
			
			i_ExplosiveProjectileHexArray[client] = value;
		}
	}
	return Plugin_Continue;
}

void Saga_OnTakeDamage(int victim, int &attacker, float &damage, int &weapon)
{
	if(SagaCrippled[victim])
	{
		damage = 0.0;
	}
	else if(RoundToFloor(damage) >= GetEntProp(victim, Prop_Data, "m_iHealth"))
	{
		damage = 0.0;
		SetEntProp(victim, Prop_Data, "m_iHealth", 1);
		SagaCrippled[victim] = TF2Attrib_GetByDefIndex(weapon, 861) == Address_Null ? 1.0 : 2.0;
		CreateTimer(10.0, Saga_ExcuteTarget, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE);
		FreezeNpcInTime(victim, 10.2);
	}
}

public Action Saga_ExcuteTarget(Handle timer, int ref)
{
	int entity = EntIndexToEntRef(ref);
	if(entity != INVALID_ENT_REFERENCE)
		SDKHooks_TakeDamage(entity, 0, 0, 9999.9, DMG_DROWN);
	
	return Plugin_Continue;
}
