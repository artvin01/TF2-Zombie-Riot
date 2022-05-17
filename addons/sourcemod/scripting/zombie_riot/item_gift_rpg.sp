
#define GIFT_MODEL "models/items/tf_gift.mdl"

#define GIFT_CHANCE 0.0025 //Extra rare cus alot of zobies

#define SOUND_BEEP			"buttons/button17.wav"

static const char Drops[][] =
{
	""
};

int g_BeamIndex = -1;

public void Map_Precache_Zombie_Drops_Gift()
{
	PrecacheModel(GIFT_MODEL, true);
	PrecacheSound(SOUND_BEEP);
	g_BeamIndex = PrecacheModel("materials/sprites/laserbeam.vmt", true);
}

public void Gift_DropChance(int entity)
{
	if(IsValidEntity(entity))
	{
		if(GetRandomFloat(0.0, 1.0) < (GIFT_CHANCE / MultiGlobal + 0.00001)) //Never let it divide by 0
		{
			float VecOrigin[3];
			GetEntPropVector(entity, Prop_Data, "m_vecOrigin", VecOrigin);
			for (int client = 1; client <= MaxClients; client++)
			{
				if (IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == view_as<int>(TFTeam_Red))
				{
					Stock_SpawnGift(VecOrigin, GIFT_MODEL, 45.0, client);
				}
			}
		}		
	}
}

float f_RingDelayGift[MAXENTITIES];

public Action Timer_Detect_Player_Near_Gift(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int glow = EntRefToEntIndex(pack.ReadCell());
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(IsValidClient(client))
		{
			float powerup_pos[3];
			float client_pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
			if(f_RingDelayGift[entity] < GetGameTime())
			{
				f_RingDelayGift[entity] = GetGameTime() + 1.0;
				EmitSoundToClient(client, SOUND_BEEP, entity, _, 90, _, 1.0);
				TE_SetupBeamRingPoint(powerup_pos, 10.0, 300.0, g_BeamIndex, -1, 0, 30, 1.0, 10.0, 1.0, {255, 255, 255, 255}, 0, 0);
	   			TE_SendToClient(client);
   			}
			if (IsPlayerAlive(client) && GetClientTeam(client) == view_as<int>(TFTeam_Red))
			{
				GetClientAbsOrigin(client, client_pos);
				if (GetVectorDistance(powerup_pos, client_pos, true) <= 4096)
				{
					if (IsValidEntity(glow))
					{
						RemoveEntity(glow);
					}
					RemoveEntity(entity);
					
					if(GetFeatureStatus(FeatureType_Native, "TextStore_GetItems") == FeatureStatus_Available)
					{
						int length = TextStore_GetItems();
						for(int i; i<length; i++)
						{
							static char buffer[64];
							TextStore_GetItemName(i, buffer, sizeof(buffer));
							for(int a; a<sizeof(Drops); a++)
							{
								if(StrEqual(buffer, Drops[a], false))
								{
									int amount;
									TextStore_GetInv(client, i, amount);
									if(!amount)
									{
										TextStore_SetInv(client, i, amount + 1);
										length = 0;
									}
									
									break;
								}
							}
						}
					}
					return Plugin_Stop;
				}
			}
		}
		else
		{
			if (IsValidEntity(glow))
			{
				RemoveEntity(glow);
			}
			RemoveEntity(entity);
			return Plugin_Stop;			
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

stock void Stock_SpawnGift(float position[3], const char[] model, float lifetime, int client)
{
	int m_iGift = CreateEntityByName("prop_physics_override")
	if(m_iGift != -1)
	{
		char targetname[100];

		Format(targetname, sizeof(targetname), "gift_%i", m_iGift);

		DispatchKeyValue(m_iGift, "model", model);
		DispatchKeyValue(m_iGift, "targetname", targetname);
		DispatchKeyValue(m_iGift, "physicsmode", "2");
		DispatchKeyValue(m_iGift, "massScale", "1.0");
		DispatchSpawn(m_iGift);
		
		SetEntProp(m_iGift, Prop_Send, "m_usSolidFlags", 8);
		SetEntityCollisionGroup(m_iGift, 1);
	
		TeleportEntity(m_iGift, position, NULL_VECTOR, NULL_VECTOR);
		
		int glow = TF2_CreateGlow(m_iGift);
		
		SetVariantColor(view_as<int>({255, 255, 255, 255}));
		AcceptEntityInput(glow, "SetGlowColor");
		
		SetEntPropEnt(glow, Prop_Send, "m_hOwnerEntity", client);
		SetEntPropEnt(m_iGift, Prop_Send, "m_hOwnerEntity", client);
			
	//	i_DyingParticleIndication[victim] = EntIndexToEntRef(entity);
		
		DataPack pack;
		CreateDataTimer(0.1, Timer_Detect_Player_Near_Gift, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack.WriteCell(EntIndexToEntRef(m_iGift));
		pack.WriteCell(EntIndexToEntRef(glow));	
		pack.WriteCell(GetClientUserId(client));
		
		
		DataPack pack_2;
		CreateDataTimer(lifetime, Timer_Despawn_Gift, pack_2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack_2.WriteCell(EntIndexToEntRef(m_iGift));
		pack_2.WriteCell(EntIndexToEntRef(glow));	
		
	//	SDKHook(entity, SDKHook_SetTransmit, GiftTransmit);
		SDKHook(m_iGift, SDKHook_SetTransmit, GiftTransmit);
	}
}


public Action Timer_Despawn_Gift(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int glow = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if (IsValidEntity(glow))
		{
			RemoveEntity(glow);
		}
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}

public Action GiftTransmit(int entity, int target)
{
	if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == target)
		return Plugin_Continue;

	return Plugin_Handled;
}