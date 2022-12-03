static int Carrying[MAXTF2PLAYERS] = {INVALID_ENT_REFERENCE, ...};
static bool Waiting;

void Escape_RoundStart()
{
	Waiting = true;
}


void Escape_RoundEnd()
{
	//Just delete, dont wanna risk anything staying and that causing the server to lag like in the case of serious sam.
//	RequestFrames(Remove_All, 300);
	CreateTimer(5.0, Remove_All, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Remove_All(Handle Timer_Handle, any Null)
{
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "npc_maker")) != -1)
	{
		if(IsValidEntity(entity))
		{
			if(entity != 0)
			{
				RemoveEntity(entity);
			}
		}
	}
	entity = -1;
	while((entity=FindEntityByClassname(entity, "base_npc")) != -1)
	{
		if(IsValidEntity(entity))
		{
			if(entity != 0)
			{
				if(!b_Map_BaseBoss_No_Layers[entity]) //Make sure map base_bosses dont get killed like this, might cause problems.
				{
					SDKHooks_TakeDamage(entity, 0, 0, 999999999.0, DMG_GENERIC); //Kill it so it triggers the neccecary shit.
					SDKHooks_TakeDamage(entity, 0, 0, 999999999.0, DMG_GENERIC); //Kill it so it triggers the neccecary shit.
					SDKHooks_TakeDamage(entity, 0, 0, 999999999.0, DMG_GENERIC); //Kill it so it triggers the neccecary shit.
					SDKHooks_TakeDamage(entity, 0, 0, 999999999.0, DMG_GENERIC); //Kill it so it triggers the neccecary shit.
				}
			//	RemoveEntity(entity); Dont remove, cause infinite damage so all the hooks unhook properly.
			}
		}
	}
	return Plugin_Handled;
}

void Escape_SetupEnd()
{
	if(Waiting)
	{
		int amount = CountPlayersOnRed();
		
		float multi = amount*0.25;
		
		if(multi < 0.25) //Have a minimum for 50% as i cant really balance bob, and escape maps alone are really hard anyways.
			multi = 0.25;
		
		Waiting = false;
		int entity = -1;
		char buffer[64];
		while((entity=FindEntityByClassname(entity, "npc_maker")) != -1)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
			if(!StrContains(buffer, "zr_", false))
			{
				amount = GetEntProp(entity, Prop_Data, "m_nMaxNumNPCs");
				if(amount)
				{
					amount = RoundToFloor(float(amount) * multi);
					if(amount < 1)
						amount = 1;
					
					SetVariantInt(amount);
					AcceptEntityInput(entity, "SetMaxChildren");
				}
				
				float time = GetEntPropFloat(entity, Prop_Data, "m_flSpawnFrequency");
				if(time)
				{
					time *= (1.25 - (multi / 4));
					
					SetVariantFloat(time);
					AcceptEntityInput(entity, "SetSpawnFrequency");
				}
			}
		}
	}
}

bool Escape_Interact(int client, int entity)
{
	char buffer[64];
	GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
	if(!StrContains(buffer, "szf_carry", false) || !StrContains(buffer, "szf_pick", false) || StrEqual(buffer, "gascan", false))
	{
		Carrying[client] = EntIndexToEntRef(entity);
		AcceptEntityInput(entity, "DisableMotion");
		SetEntProp(entity, Prop_Send, "m_nSolidType", 0);
		
		EmitSoundToClient(client, "ui/item_paint_can_pickup.wav");
		AcceptEntityInput(entity, "FireUser1", client, client);
		return true;
	}
	return false;
}

void Escape_PlayerRunCmd(int client)
{
	if(Carrying[client] != INVALID_ENT_REFERENCE)
	{
		int entity = EntRefToEntIndex(Carrying[client]);
		if(entity > MaxClients)
		{
			static float pos[3], ang[3], vel[3];
			GetClientEyePosition(client, pos);
			GetClientEyeAngles(client, ang);
			
			pos[2] -= 20.0;
			
			ang[0] = 5.0;
			ang[2] += 35.0;
			
			AnglesToVelocity(ang, vel, 60.0);
			AddVectors(pos, vel, pos);
			TeleportEntity(entity, pos, ang, NULL_VECTOR);
		}
		else
		{
			Carrying[client] = INVALID_ENT_REFERENCE;
		}
	}
}

void Escape_DropItem(int client, bool teleport=true)
{
	if(Carrying[client] != INVALID_ENT_REFERENCE)
	{
		int entity = EntRefToEntIndex(Carrying[client]);
		if(entity > MaxClients)
		{
			SetEntProp(entity, Prop_Send, "m_nSolidType", 6);
			AcceptEntityInput(entity, "EnableMotion");
			AcceptEntityInput(entity, "FireUser2", client, client);

			if(teleport)
			{
				static float pos[3];
				GetClientEyePosition(client, pos);
				if(!IsEntityStuck(entity) && !ObstactleBetweenEntities(client, entity))
				{
					pos[0] += 20.0;
					pos[2] -= 30.0;
				}

				TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
			}
		}

		Carrying[client] = INVALID_ENT_REFERENCE;
	}
}