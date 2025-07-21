static int Carrying[MAXPLAYERS] = {INVALID_ENT_REFERENCE, ...};
void Escape_RoundStart()
{
	DeleteAndRemoveAllNpcs = 5.0;
	mp_bonusroundtime.IntValue = 15;
}

void Escape_RoundEnd()
{
	//Just delete, dont wanna risk anything staying and that causing the server to lag like in the case of serious sam.
//	RequestFrames(Remove_All, 300);
	CreateTimer(DeleteAndRemoveAllNpcs, Remove_All, _, TIMER_FLAG_NO_MAPCHANGE);
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
	int a;
	while((entity = FindEntityByNPC(a)) != -1)
	{
		if(IsValidEntity(entity))
		{
			if(entity != 0)
			{
				b_DissapearOnDeath[entity] = true;
				b_DoGibThisNpc[entity] = true;
				SmiteNpcToDeath(entity);
				SmiteNpcToDeath(entity);
				SmiteNpcToDeath(entity);
				SmiteNpcToDeath(entity);
			}
		}
	}
	entity = -1;
	while((entity=FindEntityByClassname(entity, "zr_base_stationary")) != -1)
	{
		if(IsValidEntity(entity))
		{
			if(entity != 0)
			{
				b_DissapearOnDeath[entity] = true;
				b_DoGibThisNpc[entity] = true;
				SmiteNpcToDeath(entity);
				SmiteNpcToDeath(entity);
				SmiteNpcToDeath(entity);
				SmiteNpcToDeath(entity);
			}
		}
	}
	DeleteAndRemoveAllNpcs = 5.0;
	mp_bonusroundtime.IntValue = 15;
	return Plugin_Handled;
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