#pragma semicolon 1
#pragma newdecls required

static void AdjustDifficulty(bool hard)
{
	char name[64];
	
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(IsValidEntity(i_ObjectsSpawners[i]))
		{
			GetEntPropString(i_ObjectsSpawners[i], Prop_Data, "m_iName", name, sizeof(name));
			
			if(!StrContains(name, "start_normal"))
			{
				SetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_bDisabled", hard);
			}
			else if(!StrContains(name, "start_hard"))
			{
				SetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_bDisabled", !hard);
			}
			else if(!StrContains(name, "spawn_a") || !StrContains(name, "spawn_b"))
			{
				if(hard)
				{
					if(StrContains(name, "_noraid") == -1)
					{
						Format(name, sizeof(name), "%s_noraid", name);
						SetEntPropString(i_ObjectsSpawners[i], Prop_Data, "m_iName", name);
					}
				}
				else if(StrContains(name, "_noraid") != -1)
				{
					ReplaceString(name, sizeof(name), "_noraid", "");
					SetEntPropString(i_ObjectsSpawners[i], Prop_Data, "m_iName", name);
				}
			}
			else if(!StrContains(name, "spawn_c"))
			{
				if(!hard)
				{
					if(StrContains(name, "_noraid") == -1)
					{
						Format(name, sizeof(name), "%s_noraid", name);
						SetEntPropString(i_ObjectsSpawners[i], Prop_Data, "m_iName", name);
					}
				}
				else if(StrContains(name, "_noraid") != -1)
				{
					ReplaceString(name, sizeof(name), "_noraid", "");
					SetEntPropString(i_ObjectsSpawners[i], Prop_Data, "m_iName", name);
				}
			}
		}
	}

	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			Vehicle_Exit(client, false, false);
			TF2_RespawnPlayer(client);
		}
	}
}

public void Construction_RiftNormal_Collect()
{
	AdjustDifficulty(false);
}

public void Construction_RiftCreep_Collect()
{
	AdjustDifficulty(true);
}

public void Construction_RiftHard_Collect()
{
	Modifier_Collect_ChaosIntrusion();
	Construction_VoidStart_Collect();
	AdjustDifficulty(false);
}

public void Construction_RiftHardCreep_Collect()
{
	Modifier_Collect_ChaosIntrusion();
	Construction_VoidStart_Collect();
	AdjustDifficulty(true);
}

public void Construction_RiftHard_Remove()
{
	Modifier_Remove_ChaosIntrusion();
	Construction_HardMode_Remove();
}
