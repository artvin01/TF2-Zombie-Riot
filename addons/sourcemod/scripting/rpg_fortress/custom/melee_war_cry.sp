#define WARCRY_MIN_DURATION 5.0
#define WARCRY_ATTACKSPEED_BUFF_MIN 0.9
#define WARCRY_ATTACKSPEED_BUFF_MAX 0.85
#define WARCRY_RESISTANCE_MIN 0.95
#define WARCRY_RESISTANCE_MAX 0.9

static float WarCry_Duration[MAXPLAYERS+1] = {0.0, ...};
static float WarCry_DamageTaken[MAXPLAYERS+1] = {0.0, ...};

static float WarCryBuff_Duration[MAXPLAYERS+1] = {0.0, ...};
static float WarCryBuff_Amount[MAXENTITIES] = {1.0, ...};
static float WarCryBuff_Resistance[MAXPLAYERS+1] = {1.0, ...};
static Handle h_WarcryTimerBuff[MAXENTITIES];

//prevent switching weapons
static int i_MeleeWeaponRef[MAXPLAYERS+1] = {0, ...};

static Handle h_WarcryTimer[MAXPLAYERS+1];

void WarCryOnMapStart()
{
	PrecacheSound("items/powerup_pickup_base.wav");
}

void OnEntityCreatedMeleeWarcry(int entity)
{
	//1.0 means it has no attributes, reset it.
	WarCryBuff_Amount[entity] = 1.0;
	if(h_WarcryTimerBuff[entity] != INVALID_HANDLE)
		delete h_WarcryTimerBuff[entity];
}


public float AbilityMeleeWarcry(int client, int index, char name[48])
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(!kv)
	{
		return 0.0;
	}

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!IsValidEntity(weapon))
	{
		return 0.0;
	}

	static char classname[36];
	GetEntityClassname(weapon, classname, sizeof(classname));
	if (TF2_GetClassnameSlot(classname, weapon) != TFWeaponSlot_Melee || i_IsWandWeapon[weapon])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Melee Weapon.");
		return 0.0;
	}

	if(Stats_Intelligence(client) < 150)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "You do not have enough Intelligence [150]");
		return 0.0;
	}
	if(h_WarcryTimerBuff[client] != INVALID_HANDLE)
		delete h_WarcryTimer[client];

	WarCry_Duration[client] = GetGameTime() + 5.0;
	WarCry_DamageTaken[client] = 0.0;
	i_MeleeWeaponRef[client] = EntIndexToEntRef(weapon);
	DataPack pack;
	h_WarcryTimer[client] = CreateDataTimer(5.0, Timer_MeleeWarCry, pack, _);
	pack.WriteCell(EntIndexToEntRef(client));	
	EmitSoundToAll("items/powerup_pickup_base.wav", client, SNDCHAN_STATIC, 80, _, 0.45);

	return (GetGameTime() + 50.0);
}

void Player_Ability_Warcry_OnTakeDamage(int victim, float &damage)
{
	//Not in ability. Cancel.
	if (WarCry_Duration[victim] < GetGameTime())
		return;

	int weapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
	if (EntRefToEntIndex(i_MeleeWeaponRef[victim]) != weapon)
	{
		//they changed weapons and got hurt, punish them for it.
		WarCry_Duration[victim] = 0.0;
		delete h_WarcryTimer[victim];
		return;
	}

	float damage_Blocked = damage;
	damage_Blocked *= 0.25;

	damage -= damage_Blocked;
	WarCry_DamageTaken[victim] += damage_Blocked;
}

static Action Timer_MeleeWarCry(Handle dashHud, DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	if (!IsValidClient(client))
	{
		return Plugin_Stop;
	}
	if (!IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	int r = 200;
	int g = 200;
	int b = 255;
	int a = 200;
	EmitSoundToAll("mvm/mvm_tank_horn.wav", client, SNDCHAN_STATIC, 80, _, 0.45);
	
	spawnRing(client, 50.0 * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.5, 6.0, 6.1, 1);
	spawnRing(client, 50.0 * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.4, 6.0, 6.1, 1);
	spawnRing(client, 50.0 * 2.0, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.3, 6.0, 6.1, 1);
	spawnRing(client, 50.0 * 2.0, 0.0, 0.0, 65.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.2, 6.0, 6.1, 1);
	spawnRing(client, 50.0 * 2.0, 0.0, 0.0, 85.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.1, 6.0, 6.1, 1);
	//loop all clients blah blah.
	float DmgTaken = WarCry_DamageTaken[client];
	DmgTaken += 0.001;
	float MaxHealth = float(SDKCall_GetMaxHealth(client));
	MaxHealth *= 0.1;
	float RatioMax = DmgTaken / MaxHealth;
	RatioMax += 1.0;

	float WC_Duration = WARCRY_MIN_DURATION;
	WC_Duration *= RatioMax;

	RatioMax -= 1.0;
	float minval = WARCRY_ATTACKSPEED_BUFF_MAX;
	float maxval = WARCRY_ATTACKSPEED_BUFF_MIN;
	float SetVal;
	
	if(RatioMax > 1.0)
		SetVal = WARCRY_ATTACKSPEED_BUFF_MAX;
	else
		SetVal = (minval + ((maxval - minval) * RatioMax));
	

	float WC_Attackspeed = SetVal;

	minval = WARCRY_RESISTANCE_MAX;
	maxval = WARCRY_RESISTANCE_MIN;
	
	if(RatioMax > 1.0)
		SetVal = WARCRY_ATTACKSPEED_BUFF_MAX;
	else
		SetVal = (minval + ((maxval - minval) * RatioMax));
	
	float WC_Resis = SetVal;

	float HealByThis = (DmgTaken * 0.5);
	HealEntityGlobal(client, client, HealByThis, 1.0, 2.0, HEAL_SELFHEAL);

	float BannerPos[3];
	float targPos[3];
	GetClientAbsOrigin(client, BannerPos);
	for(int ally=1; ally<=MaxClients; ally++)
	{
		if(IsClientInGame(ally) && IsPlayerAlive(ally))
		{
			GetClientAbsOrigin(ally, targPos);
			if (GetVectorDistance(BannerPos, targPos, true) <= (650.0 * 650.0)) // 650.0
			{
				if(!RPGCore_PlayerCanPVP(client, ally))
				{
					if(WarCryBuff_Duration[client] < GetGameTime() + WC_Duration)
						WarCryBuff_Duration[client] = GetGameTime() + WC_Duration;

					if(WarCryBuff_Amount[client] > WC_Attackspeed)
						WarCryBuff_Amount[client] = WC_Attackspeed;

					if(WarCryBuff_Resistance[client] > WC_Resis)
						WarCryBuff_Resistance[client] = WC_Resis;
						
					delete h_WarcryTimerBuff[client];
					DataPack pack1;
					h_WarcryTimerBuff[client] = CreateDataTimer(0.25, Timer_MeleeWarCryBuffWeapons, pack1, TIMER_REPEAT);
					pack1.WriteCell(client);	
					pack1.WriteCell(EntIndexToEntRef(client));	
				}
			}
		}
	}
	return Plugin_Continue;
}

static Action Timer_MeleeWarCryBuffWeapons(Handle dashHud, DataPack pack)
{
	pack.Reset();
	int o_client = pack.ReadCell();
	int client = EntRefToEntIndex(pack.ReadCell());
	//This belongs to a client.
	if(o_client <= MaxClients)
	{
		if (!IsValidClient(client))
		{
			h_WarcryTimerBuff[o_client] = INVALID_HANDLE;
			return Plugin_Stop;
		}
		if (!IsPlayerAlive(client))
		{
			WarCryBuff_Duration[o_client] = 0.0;
			h_WarcryTimerBuff[o_client] = INVALID_HANDLE;
			return Plugin_Stop;
		}
		if (WarCryBuff_Duration[client] < GetGameTime())
		{
			h_WarcryTimerBuff[o_client] = INVALID_HANDLE;
			return Plugin_Stop;
		}
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(!IsValidEntity(weapon))
			return Plugin_Continue;

		//Everything exists,  do code.

		//The stats dont match up anymore, reset back and then add the new stats.
		bool GrantStats = false;
		if(WarCryBuff_Amount[weapon] != WarCryBuff_Amount[client])
		{
			if(Attributes_Has(weapon, 6))
				Attributes_SetMulti(weapon, 6, 1.0 / WarCryBuff_Amount[weapon]);
				
			if(Attributes_Has(weapon, 97))
				Attributes_SetMulti(weapon, 97, 1.0 / WarCryBuff_Amount[weapon]);
			
			if(Attributes_Has(weapon, 4004))
				Attributes_SetMulti(weapon, 4004, 1.0 / WarCryBuff_Amount[weapon]);
			
			if(Attributes_Has(weapon, 4003))
				Attributes_SetMulti(weapon, 4003, 1.0 / WarCryBuff_Amount[weapon]);

			WarCryBuff_Amount[weapon] = 1.0;
			GrantStats = true;
		}
		//The weapon has no timer, this means their stats have not been set, set them.
		if(GrantStats || h_WarcryTimerBuff[weapon] == INVALID_HANDLE)
		{
			if(Attributes_Has(weapon, 6))
				Attributes_SetMulti(weapon, 6, WarCryBuff_Amount[client]);
				
			if(Attributes_Has(weapon, 97))
				Attributes_SetMulti(weapon, 97, WarCryBuff_Amount[client]);
			
			if(Attributes_Has(weapon, 4004))
				Attributes_SetMulti(weapon, 4004, WarCryBuff_Amount[client]);
			
			if(Attributes_Has(weapon, 4003))
				Attributes_SetMulti(weapon, 4003, WarCryBuff_Amount[client]);

			WarCryBuff_Amount[weapon] = WarCryBuff_Amount[client];

			//We apply it onto the weapon they are holding now.
			if(h_WarcryTimerBuff[weapon] == INVALID_HANDLE)
			{
				DataPack pack1;
				h_WarcryTimerBuff[weapon] = CreateDataTimer(0.25, Timer_MeleeWarCryBuffWeapons, pack1, TIMER_REPEAT);
				pack1.WriteCell(weapon);	
				pack1.WriteCell(EntIndexToEntRef(weapon));	
			}
		}
	}
	else
	{
		//This belongs to a weapon or entity.
		//This code is only emergency, dont use it much.
		//only for weapons to reset their stats once the owner runs out of timer.
		if (!IsValidEntity(o_client))
		{
			h_WarcryTimerBuff[o_client] = INVALID_HANDLE;
			return Plugin_Stop;
		}
		int owner = GetEntPropEnt(client, Prop_Send, "m_hOwnerEntity");
		if (!IsValidClient(owner))
		{
			h_WarcryTimerBuff[o_client] = INVALID_HANDLE;
			return Plugin_Stop;
		}
		//Client is valid, weapon is valid.
		int weapon = o_client;
		//The owner has no more timer, reset weapon stats and reset their timer.
		if(h_WarcryTimerBuff[owner] == INVALID_HANDLE)
		{
			if(Attributes_Has(weapon, 6))
				Attributes_SetMulti(weapon, 6, 1.0 / WarCryBuff_Amount[weapon]);
				
			if(Attributes_Has(weapon, 97))
				Attributes_SetMulti(weapon, 97, 1.0 / WarCryBuff_Amount[weapon]);
			
			if(Attributes_Has(weapon, 4004))
				Attributes_SetMulti(weapon, 4004, 1.0 / WarCryBuff_Amount[weapon]);
			
			if(Attributes_Has(weapon, 4003))
				Attributes_SetMulti(weapon, 4003, 1.0 / WarCryBuff_Amount[weapon]);

			h_WarcryTimerBuff[o_client] = INVALID_HANDLE;
			WarCryBuff_Amount[weapon] = 1.0;
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

bool WarCry_Enabled(int client)
{
	if(WarCry_Duration[client] > GetGameTime())
		return true;

	return false;
}

bool WarCry_Enabled_Buff(int client)
{
	if(WarCryBuff_Duration[client] > GetGameTime())
		return true;

	return false;
}

float WarCry_ResistanceBuff(int client)
{
	return WarCryBuff_Resistance[client];
}