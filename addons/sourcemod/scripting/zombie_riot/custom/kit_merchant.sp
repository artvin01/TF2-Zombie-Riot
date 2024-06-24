#pragma semicolon 1
#pragma newdecls required

// Metal drain per second
#define MERCHANT_METAL_DRAIN	10

enum
{
	Merchant_Jaye = 0,
	Merchant_Nothing,
	Merchant_Lee,
	Merchant_Swire
}

static const int SupportBuildings[] = { 2, 5, 9, 14, 14, 15 };
static int MerchantLevel[MAXTF2PLAYERS] = {-1, ...};
static int i_AdditionalSupportBuildings[MAXTF2PLAYERS] = {0, ...};

static int MerchantWeaponRef[MAXTF2PLAYERS] = {-1, ...};
static int MerchantAbilitySlot[MAXTF2PLAYERS];
static int MerchantEffect[MAXTF2PLAYERS];
static float MerchantLeftAt[MAXTF2PLAYERS];
static ArrayList MerchantAttribs[MAXTF2PLAYERS];

static int ParticleRef[MAXTF2PLAYERS] = {-1, ...};
static int MerchantStyle[MAXTF2PLAYERS] = {-1, ...};
static Handle EffectTimer[MAXTF2PLAYERS];

void Merchant_RoundStart()
{
	Zero(i_AdditionalSupportBuildings);

	for(int i; i < sizeof(MerchantStyle); i++)
	{
		MerchantStyle[i] = -1;
	}
}

int Merchant_Additional_SupportBuildings(int client)
{
	return i_AdditionalSupportBuildings[client];
}

bool Merchant_IsAMerchant(int client)
{
	return view_as<bool>(EffectTimer[client]);
}

void Merchant_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MERCHANT)
	{
		MerchantLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));

		if(MerchantLevel[client] >= sizeof(SupportBuildings))
			MerchantLevel[client] = sizeof(SupportBuildings) - 1;

		if(!EffectTimer[client])
			EffectTimer[client] = CreateTimer(0.5, TimerEffect, client, TIMER_REPEAT);

		i_AdditionalSupportBuildings[client] = SupportBuildings[MerchantLevel[client]];
	}
}

static Action TimerEffect(Handle timer, int client)
{
	if(IsClientInGame(client) && MerchantLevel[client] > -1)
	{
		if(!dieingstate[client] && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE && i_HealthBeforeSuit[client] == 0)
		{
			if(MerchantWeaponRef[client] != -1)
			{
				int weapon = EntRefToEntIndex(MerchantWeaponRef[client]);
				if(weapon != -1)
				{
					if(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon)
					{
						b_IsCannibal[client] = true;

						if(!Waves_InSetup())
						{
							int ammo = GetAmmo(client, Ammo_Metal);
							int cost = MERCHANT_METAL_DRAIN / 2;
							if(cost < ammo)
							{
								MerchantWeaponRef[client] = -1;
								return TimerEffect(null, client);
							}
							
							MerchantThink(client, cost);
							SetAmmo(client, Ammo_Metal, ammo - cost);
						}

						return Plugin_Continue;
					}
				}

				MerchantWeaponRef[client] = -1;
			}

			if(MerchantWeaponRef[client] == -1)
			{
				int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
				if(weapon != -1)
				{
					if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MERCHANT)
					{
						if(ParticleRef[client] != -1)
						{
							int entity = EntRefToEntIndex(ParticleRef[client]);
							if(entity > MaxClients)
							{
								TeleportEntity(entity, OFF_THE_MAP);
								RemoveEntity(entity);
							}

							ParticleRef[client] = -1;
						}

						return Plugin_Continue;
					}
				}
			}
		}
		else
		{
			MerchantWeaponRef[client] = -1;

			if(ParticleRef[client] != -1)
			{
				int entity = EntRefToEntIndex(ParticleRef[client]);
				if(entity > MaxClients)
				{
					TeleportEntity(entity, OFF_THE_MAP);
					RemoveEntity(entity);
				}

				ParticleRef[client] = -1;
			}

			return Plugin_Continue;
		}
	}

	MerchantLevel[client] = -1;
	MerchantWeaponRef[client] = -1;
		
	if(ParticleRef[client] != -1)
	{
		int entity = EntRefToEntIndex(ParticleRef[client]);
		if(entity > MaxClients)
		{
			TeleportEntity(entity, OFF_THE_MAP);
			RemoveEntity(entity);
		}
		
		ParticleRef[client] = -1;
	}
	i_AdditionalSupportBuildings[client] = 0;
	EffectTimer[client] = null;
	return Plugin_Stop;
}

public void Weapon_MerchantSecondary_M2(int client, int weapon, bool crit, int slot)
{
	if(MerchantStyle[client] < 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Reload to Interact");
	}

	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	MerchantStart(client, slot);
}

public void Weapon_MerchantSecondary_R(int client, int weapon, bool crit, int slot)
{
	Menu menu = new Menu(MerchantMenuH);

	menu.SetTitle("Select Merchant Style:\n ");

	switch(MerchantLevel[client])
	{
		case -1:
		{
		}
		case 0:
		{
			menu.AddItem("0", "Fish Market");
			menu.AddItem("-1", "Martial Artist (Upgrade Needed)", ITEMDRAW_DISABLED);
			menu.AddItem("-1", "The Investigator (Upgrade Needed)", ITEMDRAW_DISABLED);
			menu.AddItem("-1", "Wine Market (Upgrade Needed)", ITEMDRAW_DISABLED);
		}
		case 1:
		{
			menu.AddItem("0", "Fish Market (Anti-Seaborn)");
			menu.AddItem("1", "Martial Artist (Retreats)");
			menu.AddItem("-1", "The Investigator (Upgrade Needed)", ITEMDRAW_DISABLED);
			menu.AddItem("-1", "Wine Market (Upgrade Needed)", ITEMDRAW_DISABLED);
		}
		case 2:
		{
			menu.AddItem("0", "Fish Market (Anti-Seaborn)");
			menu.AddItem("1", "Martial Artist (Retreats, Stuns)");
			menu.AddItem("2", "The Investigator (Steal Attack Speed)");
			menu.AddItem("-1", "Wine Market (Upgrade Needed)", ITEMDRAW_DISABLED);
		}
		default:
		{
			menu.AddItem("0", "Fish Market (Anti-Seaborn)");
			menu.AddItem("1", "Martial Artist (Retreats, Stuns)");
			menu.AddItem("2", "The Investigator (Steal Attack Speed, Anti-Stun)");
			menu.AddItem("3", "Wine Market (Ranged, Self Revive)");
		}
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

static int MerchantMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char buffer[6];
			menu.GetItem(choice, buffer, sizeof(buffer));

			MerchantStyle[client] = StringToInt(buffer);
		}
	}
	return 0;
}

static void MerchantStart(int client, int slot)
{
	if(MerchantWeaponRef[client] != -1)
	{
		MerchantEnd(client);
		return;
	}

	float fcost;
	switch(MerchantStyle[client])
	{
		case Merchant_Jaye:
		{
			MerchantEffect[client] = 0;

			if(MerchantLevel[client] > 2)
			{
				int buttons = GetClientButtons(client);
				if(buttons & IN_JUMP)
				{
				}
				else if((buttons & IN_DUCK) || (GetURandomInt() % 2))
				{
					MerchantEffect[client] = 1;
				}
			}

			if(MerchantEffect[client])
			{
				// Healing
				switch(MerchantLevel[client])
				{
					case 2:
						fcost = 17.0;
					
					case 3:
						fcost = 11.666667;
					
					case 4:
						fcost = 11.0;
					
					case 5:
						fcost = 10.333333;
				}
			}
			else
			{
				// Silence
				switch(MerchantLevel[client])
				{
					case 0:
						fcost = 13.0;
					
					case 1, 2:	// E0 S4 P0, E1 S7 P1
						fcost = 12.0;
					
					case 3:	// Pot 5
						fcost = 10.0;
					
					case 4:	// Module
						fcost = 8.333333;
					
					case 5:
						fcost = 7.666667;
				}
			}
		}
		case Merchant_Nothing:
		{
			if((MerchantLeftAt[client] + 10.0) > GetGameTime())
			{
				// Redeploy has a discount
				if(MerchantLevel[client] > 4)
				{
					fcost = 3.333333;
				}
				else
				{
					fcost = 5.0;
				}
			}
			else
			{
				switch(MerchantLevel[client])
				{
					case 1:
						fcost = 6.0;
					
					case 2:
						fcost = 13.0;
					
					case 3:	// Pot 1
						fcost = 12.0;
					
					case 4, 5:	// Module
						fcost = 10.333333;
				}
			}
		}
		case Merchant_Lee:
		{
			switch(MerchantLevel[client])
			{
				case 2:
					fcost = 19.0;
				
				case 3:
					fcost = 18.0;
				
				case 4:
					fcost = 17.0;
				
				case 5:	// Module
					fcost = 13.666667;
			}
		}
		case Merchant_Swire:
		{
			fcost = 9.0;
		}
	}

	int ammo = GetAmmo(client, Ammo_Metal);
	int cost = RoundFloat(MERCHANT_METAL_DRAIN * fcost);
	if(ammo < (cost * 2))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "No Ammo Supplies");
		Ability_Apply_Cooldown(client, slot, 1.0);
		return;
	}

	int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if(weapon != -1)
	{
		Rogue_OnAbilityUse(weapon);

		MerchantAbilitySlot[client] = slot;
		MerchantWeaponRef[client] = EntIndexToEntRef(weapon);
		SetAmmo(client, Ammo_Metal, ammo - cost);

		float damage = 2.0;
		float speed = 0.5;

		switch(MerchantStyle[client])
		{
			case Merchant_Jaye:
			{
				if(MerchantEffect[client])
				{
					// Healing
					switch(MerchantLevel[client])
					{
						case 2:
							damage *= 1.4;
						
						case 3:
							damage *= 1.5;
						
						case 4:
							damage *= 1.55;
						
						case 5:
							damage *= 1.6;
					}
				}
				else
				{
					// Silence
					switch(MerchantLevel[client])
					{
						case 0:
							damage *= 1.15;
						
						case 1:
							damage *= 1.3;
						
						case 2:
							damage *= 1.45;
						
						case 3:
							damage *= 1.5;
						
						case 4:
							damage *= 1.6;
						
						case 5:
							damage *= 1.7;
					}
				}
			}
		}

		MerchantAddAttrib(client, 2, damage);
		MerchantAddAttrib(client, 6, speed);
	}
}

static void MerchantAddAttrib(int client, int attrib, float value)
{
	int weapon = EntRefToEntIndex(MerchantWeaponRef[client]);
	if(weapon != -1)
	{
		any array[2];
		if(!MerchantAttribs[client])
			MerchantAttribs[client] = new ArrayList(2);
		
		Attributes_SetMulti(weapon, attrib, value);

		array[0] = view_as<any>(attrib);
		array[1] = view_as<any>(value);
		MerchantAttribs[client].PushArray(array);
	}
}

static void MerchantEnd(int client)
{
	if(MerchantWeaponRef[client] == -1)
	{
		return;
	}

	int weapon = EntRefToEntIndex(MerchantWeaponRef[client]);
	if(weapon != -1)
	{
		if(MerchantAttribs[client])
		{
			any array[2];
			int length = MerchantAttribs[client].Length;
			for(int i; i < length; i++)
			{
				MerchantAttribs[client].GetArray(i, array);
				Attributes_SetMulti(weapon, view_as<int>(array[0]), view_as<float>(array[1]));
			}
		}
	}

	weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if(weapon != -1)
	{
		float cooldown = 25.0;

		switch(MerchantStyle[client])
		{
			case Merchant_Jaye:
			{
				if(MerchantLevel[client] > 2)
					cooldown -= 3.0;
			}
			case Merchant_Nothing:
			{
				cooldown = 5.0;
			}
		}

		Ability_Apply_Cooldown(client, MerchantAbilitySlot[client], cooldown, weapon);
	}

	MerchantWeaponRef[client] = -1;
	MerchantLeftAt[client] = GetGameTime();
	delete MerchantAttribs[client];
}

static void MerchantThink(int client, int &cost)
{
	switch(MerchantStyle[client])
	{
		case Merchant_Jaye:
		{
			if(MerchantLevel[client] > 3)
				cost = cost * 2 / 3;
		}
		case Merchant_Nothing:
		{
			if(MerchantLevel[client] > 4)
				cost = cost * 2 / 3;
		}
		case Merchant_Lee:
		{
			if(MerchantLevel[client] > 5)
				cost = cost * 2 / 3;
		}
		case Merchant_Swire:
		{
			
		}
	}
}