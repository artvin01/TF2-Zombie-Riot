

#define SUPPLIES_MODEL_RANDOM "models/items/ammopack_large.mdl"
#define PICKUP_SOUND "playgamesound items/gunpickup2.wav"
#define DELAY_BETWEEN_PICKUPS 45.0
#define MAX_PICKUPS_ALLOWED 8


static float DelayBetweenSpawns;

void RandomPickup_OnMapStart()
{
	DelayBetweenSpawns = 0.0;
	PrecacheModel(SUPPLIES_MODEL_RANDOM);
	CreateTimer(5.0, RandomPickup_DelayBetweenSpawns, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}
void RandomPickup_ResetTimer()
{
	DelayBetweenSpawns = 0.0;
}
bool RandomPickup_BlockSpawn()
{
	if(!Waves_Started())
		return true;
	if(Dungeon_Mode() || Construction_Mode())
		return true;

	return Waves_InSetup();
}

public Action RandomPickup_DelayBetweenSpawns(Handle timer)
{
	if(RandomPickup_BlockSpawn())
		return Plugin_Continue;
		
	if(DelayBetweenSpawns > GetGameTime())
		return Plugin_Continue;

	int RandomClient = RandomPickup_GetRandomPlayer();
	if(!IsValidClient(RandomClient))
		return Plugin_Continue;

	float VectorSave[3];
	VectorSave[1] = 1.0;
	int Decicion = TeleportDiversioToRandLocation(RandomClient, true, 4000.0, 1500.0, true, false, VectorSave);
	switch(Decicion)
	{
		case 2:
		{
			Decicion = TeleportDiversioToRandLocation(RandomClient, true, 1500.0, 500.0, true, false, VectorSave);
			if(Decicion == 2)
			{
				//fail, try again later.
				return Plugin_Continue;
			}
		}
	}
	RandomPickup_SpawnPickup(VectorSave);
	//spawn a pickup at this location.
	float RandomPickupTime = DELAY_BETWEEN_PICKUPS; 
	if(ZR_Get_Modifier() == KITERS_DREAM)
	{
		RandomPickupTime *= 0.5;
	}
	DelayBetweenSpawns = GetGameTime() + RandomPickupTime;
	return Plugin_Continue;
}

bool RandomPickup_SpawnPickup(float VectorGoal[3])
{
	static float hullcheckmaxs_Player[3];
	static float hullcheckmins_Player[3];
	hullcheckmaxs_Player = view_as<float>( { 12.0, 12.0, 12.0 } );
	hullcheckmins_Player = view_as<float>( { -12.0, -12.0, -12.0 } );	
	float AbsOrigin_after[3];
	AbsOrigin_after = VectorGoal;
	AbsOrigin_after[2] -= 1000.0;
	VectorGoal[2] += 24.0;
	TR_TraceHullFilter(VectorGoal, AbsOrigin_after, hullcheckmins_Player, hullcheckmaxs_Player, MASK_PLAYERSOLID_BRUSHONLY, TraceRayHitWorldOnly);
	if(TR_DidHit())
	{
		TR_GetEndPosition(VectorGoal);
	}

	int prop = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(prop))
	{
		b_ToggleTransparency[prop] = false;
		DispatchKeyValue(prop, "model", SUPPLIES_MODEL_RANDOM);
		DispatchKeyValue(prop, "StartDisabled", "false");
		DispatchKeyValue(prop, "Solid", "2");
		
		TeleportEntity(prop, VectorGoal, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(prop);
		SetVariantString("idle");
		AcceptEntityInput(prop, "SetAnimation");
		DispatchKeyValueFloat(prop, "playbackrate", 1.0);
		SetEntProp(prop, Prop_Send, "m_usSolidFlags", 12); 
		SetEntityCollisionGroup(prop, 27);
		SDKHook(prop, SDKHook_Touch, RandomPickup_TouchPickup);
		i_WandIdNumber[prop] = 999;
		float RandomPickupTime = DELAY_BETWEEN_PICKUPS; 
		int MaxPickups = MAX_PICKUPS_ALLOWED; 
		if(ZR_Get_Modifier() == KITERS_DREAM)
		{
			MaxPickups *= 2;
		}
		CreateTimer(RandomPickupTime * MaxPickups, Timer_RemoveEntity, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
	}	
	return true;
}

public void RandomPickup_TouchPickup(int entity, int other)
{
	if (!(other > 0 && other <= MaxClients))	
		return;
	if(TeutonType[other] != TEUTON_NONE || dieingstate[other] != 0)
	{
		return;
	}
	
	TF2_AddCondition(other, TFCond_SpeedBuffAlly, 1.0);
	GiveArmorViaPercentage(other, 0.25, 1.0, false);
	HealEntityGlobal(other, other, float(ReturnEntityMaxHealth(other)) / 4, 1.0, 2.0, HEAL_SELFHEAL);
	ClientCommand(other, PICKUP_SOUND);


	int ie, weapon;
	while(TF2_GetItem(other, weapon, ie))
	{
		if(IsValidEntity(weapon))
		{
			if(i_IsWandWeapon[weapon])
			{
				ManaCalculationsBefore(other);
				
				if(Current_Mana[other] < RoundToCeil(max_mana[other] * 2.0))
				{
					if(Current_Mana[other] < RoundToCeil(max_mana[other] * 2.0))
					{
						Current_Mana[other] += RoundToCeil(mana_regen[other] * 2.0);
						
						if(Current_Mana[other] > RoundToCeil(max_mana[other] * 2.0)) //Should only apply during actual regen
							Current_Mana[other] = RoundToCeil(max_mana[other] * 2.0);
					}
					Mana_Hud_Delay[other] = 0.0;
				}
				
			}
			else
			{
				int Ammo_type = GetAmmoType_WeaponPrimary(weapon);
				int weaponindex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
				if (i_WeaponAmmoAdjustable[weapon])
				{
					AddAmmoClient(other, i_WeaponAmmoAdjustable[weapon] ,_,4.0);
				}
				else if(weaponindex == 441 || weaponindex == 35)
				{
					AddAmmoClient(other, 23 ,_,4.0);	
				}
				else if(Ammo_type != -1 && Ammo_type < Ammo_Hand_Grenade) //Disallow Ammo_Hand_Grenade, that ammo type is regenerative!, dont use jar, tf2 needs jar? idk, wierdshit.
				{
					if(AmmoBlacklist(Ammo_type))
					{
						AddAmmoClient(other, Ammo_type ,_,4.0);
					}
				}
				else if(Ammo_type > 0 && Ammo_type < Ammo_MAX)
				{
					if(AmmoBlacklist(Ammo_type))
					{
						AddAmmoClient(other, Ammo_type ,_,4.0);
					}
				}
			}
		}
	}
	for(int i; i<Ammo_MAX; i++)
	{
		CurrentAmmo[other][i] = GetAmmo(other, i);
	}
	RemoveEntity(entity);	
}

static int RandomPickup_GetRandomPlayer()
{
	int Getclient = -1;

	int victims;
	int[] victim = new int[MaxClients];

	for(int client_check = 1; client_check <= MaxClients; client_check++)
	{
		if(!IsValidClient(client_check))
			continue;

		if(TeutonType[client_check] != TEUTON_NONE)
			continue;

		if(dieingstate[client_check] > 0)
			continue;

		victim[victims++] = client_check;
	}
	
	if(victims)
	{
		int winner = victim[GetURandomInt() % victims];
		Getclient = winner;
	}

	return Getclient;
}