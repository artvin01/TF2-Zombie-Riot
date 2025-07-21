#pragma semicolon 1
#pragma newdecls required

enum
{
	Mode_None = -1,
	Mode_NPCIndex = 0,
	Mode_SpawnRate,
	Mode_SpawnHealth,
	Mode_MeleeRes,
	Mode_RangeRes,
	Mode_Speed,
	Mode_Damage
}

static int MenuPos[MAXPLAYERS] = {Mode_None, ...};

void DevSpawner_MapStart()
{
	PrecacheModel("models/class_menu/random_class_icon.mdl");
}

methodmap DevSpawner < CClotBody
{
	public DevSpawner(float vecPos[3], float vecAng[3], int ally)
	{
		DevSpawner npc = view_as<DevSpawner>(CClotBody(vecPos, vecAng, "models/class_menu/random_class_icon.mdl", "1.0", "100", ally, true));

		npc.SetActivity("idle", true);

		SetEntProp(npc.index, Prop_Send, "m_nSkin", ally ? 1 : 0);

		i_NpcInternalId[npc.index] = DEV_SPAWNER;
		i_NpcWeight[npc.index] = 999;
		i_NpcIsABuilding[npc.index] = true;
		b_NpcIsInvulnerable[npc.index] = true;

		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = 0;
		npc.m_bDissapearOnDeath = true;
		npc.m_bThisEntityIgnored = true;
		npc.m_bStaticNPC = true;
		AddNpcToAliveList(npc.index, 1);
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		npc.m_iNPCIndex = -1;
		npc.m_bActive = false;
		npc.m_flSpawnRate = 0.0;
		npc.m_flNextSpawnAt = 0.0;
		npc.m_bWaveSpawn = false;
		npc.m_iSpawnHealth = 0;
		
		SDKHook(npc.index, SDKHook_Think, DevSpawner_ClotThink);
		return npc;
	}
	property int m_iNPCIndex
	{
		public get()
		{
			return this.m_iMedkitAnnoyance;
		}
		public set(int value)
		{
			this.m_iMedkitAnnoyance = value;
		}
	}
	property bool m_bActive
	{
		public get()
		{
			return this.m_Anger;
		}
		public set(int value)
		{
			this.m_Anger = value;
		}
	}
	property bool m_bWaveSpawn
	{
		public get()
		{
			return this.m_fbRangedSpecialOn;
		}
		public set(int value)
		{
			this.m_fbRangedSpecialOn = value;
		}
	}
	property float m_flSpawnRate
	{
		public get()
		{
			return this.m_flNextTeleport;
		}
		public set(int value)
		{
			this.m_flNextTeleport = value;
		}
	}
	property float m_flNextSpawnAt
	{
		public get()
		{
			return this.m_flNextRangedSpecialAttack;
		}
		public set(int value)
		{
			this.m_flNextRangedSpecialAttack = value;
		}
	}
	property int m_iSpawnHealth
	{
		public get()
		{
			return this.g_TimesSummoned;
		}
		public set(int value)
		{
			this.g_TimesSummoned = value;
		}
	}
}

public void DevSpawner_ClotThink(int iNPC)
{
	DevSpawner npc = view_as<DevSpawner>(iNPC);

	if(npc.m_bActive)
	{
		float gameTime = GetGameTime(npc.index);
		if(npc.m_flNextDelayTime < gameTime)
		{
			npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
			npc.Update();
		}
		
		if(npc.m_flNextSpawnAt < gameTime)
		{
			npc.m_flNextSpawnAt = gameTime + npc.m_flSpawnRate;

			if(npc.m_bWaveSpawn)
			{
				Enemy enemy;

				enemy.Index = npc.m_iNPCIndex;
				GetEntPropString(npc.index, Prop_Data, "m_iName", enemy.Data, sizeof(enemy.Data));
				
				enemy.Health = npc.m_iSpawnHealth;
				enemy.ExtraMeleeRes = fl_Extra_MeleeArmor[npc.index];
				enemy.ExtraRangedRes = fl_Extra_RangedArmor[npc.index];
				enemy.ExtraSpeed = fl_Extra_Speed[npc.index];
				enemy.ExtraDamage = fl_Extra_Damage[npc.index];	
				enemy.Team = GetTeam(npc.index);
				
				Waves_AddNextEnemy(enemy);
			}
			else
			{
				char data[64];
				GetEntPropString(npc.index, Prop_Data, "m_iName", data, sizeof(data));

				float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
				float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
				
				int entity = NPC_CreateById(npc.m_iNPCIndex, -1, pos, ang, GetTeam(npc.index), data);
				if(entity > MaxClients)
				{
					if(GetTeam(npc.index) != TFTeam_Red)
						Zombies_Currently_Still_Ongoing++;
					
					if(npc.m_iSpawnHealth > 0)
					{
						SetEntProp(entity, Prop_Data, "m_iHealth", npc.m_iSpawnHealth);
						SetEntProp(entity, Prop_Data, "m_iMaxHealth", npc.m_iSpawnHealth);
					}

					fl_Extra_MeleeArmor[entity] = fl_Extra_MeleeArmor[npc.index];
					fl_Extra_RangedArmor[entity] = fl_Extra_RangedArmor[npc.index];
					fl_Extra_Speed[entity] = fl_Extra_Speed[npc.index];
					fl_Extra_Damage[entity] = fl_Extra_Damage[npc.index];
				}

			}
		}
	}
}

bool DevSpawner_Interact(int client, int entity)
{
	if(i_NpcInternalId[entity] == DEV_SPAWNER)
	{
		if(CheckCommandAccess(client, "sm_spawn_npc", ADMFLAG_ROOT))
		{
			OpenMenu(client, EntIndexToEntRef(entity));
			return true;
		}
	}
	return false;
}

static void OpenMenu(int client, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity != -1)
	{
		DevSpawner npc = view_as<DevSpawner>(entity);
		
		Menu menu = new Menu(DevSpawner_MenuH);

		if(MenuPos[client] == Mode_None)
		{
			menu.SetTitle("DevSpawner %d / %d", entity, ref);
		}
		else
		{
			menu.SetTitle("Type in chat to enter value for the whited out variable");
		}

		char data[16];
		IntToString(ref, data, sizeof(data));
		
		char buffer[64];
		if(npc.m_iNPCIndex > 0 && npc.m_iNPCIndex < sizeof(NPC_Names))
		{
			FormatEx(buffer, sizeof(buffer), "'%s' #%d", NPC_Names[npc.m_iNPCIndex], npc.m_iNPCIndex);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "'' #%d", npc.m_iNPCIndex);
		}
		
		menu.AddItem(data, buffer, MenuPos[client] == Mode_NPCIndex ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		
		FormatEx(buffer, sizeof(buffer), "Spawn Rate: %fs", npc.m_flSpawnRate);
		menu.AddItem(data, buffer, MenuPos[client] == Mode_SpawnRate ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		
		FormatEx(buffer, sizeof(buffer), "Health: %d", npc.m_iSpawnHealth);
		menu.AddItem(data, buffer, MenuPos[client] == Mode_SpawnHealth ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		
		FormatEx(buffer, sizeof(buffer), "Melee Vuln: %f％", fl_Extra_MeleeArmor[npc.index] * 100.0);
		menu.AddItem(data, buffer, MenuPos[client] == Mode_MeleeRes ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		
		FormatEx(buffer, sizeof(buffer), "Ranged Vuln: %f％", fl_Extra_RangedArmor[npc.index] * 100.0);
		menu.AddItem(data, buffer, MenuPos[client] == Mode_RangeRes ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		
		FormatEx(buffer, sizeof(buffer), "Speed Multi: %f％", fl_Extra_Speed[npc.index] * 100.0);
		menu.AddItem(data, buffer, MenuPos[client] == Mode_Speed ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		
		FormatEx(buffer, sizeof(buffer), "Damage Multi: %f％", fl_Extra_Damage[npc.index] * 100.0);
		menu.AddItem(data, buffer, MenuPos[client] == Mode_Damage ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

		menu.AddItem(data, npc.m_bWaveSpawn ? "Spawn via Waves: true" : "Spawn via Waves: false");
		menu.AddItem(data, npc.m_bActive ? "Enabled: true" : "Enabled: false");

		menu.Pagination = 0;
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
}

public int DevSpawner_MenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			MenuPos[client] = Mode_None;
		}
		case MenuAction_Select:
		{
			char data[16];
			menu.GetItem(choice, data, sizeof(data));
			int ref = StringToInt(buffer);

			switch(choice)
			{
				case 8:
				{
					int entity = EntRefToEntIndex(ref);
					if(entity != -1)
					{
						DevSpawner npc = view_as<DevSpawner>(entity);
						npc.m_bWaveSpawn = !npc.m_bWaveSpawn;
					}
				}
				case 9:
				{
					int entity = EntRefToEntIndex(ref);
					if(entity != -1)
					{
						DevSpawner npc = view_as<DevSpawner>(entity);
						npc.m_bActive = !npc.m_bActive;
						// TODO: Resets spawn rate timer
					}
				}
				default:
				{
					MenuPos[client] = choice;
				}
			}

			OpenMenu(client, ref);
		}
	}
	return 0;
}

void DevSpawner_NPCDeath(int entity)
{
	SDKUnhook(entity, SDKHook_Think, DevSpawner_ClotThink);
}