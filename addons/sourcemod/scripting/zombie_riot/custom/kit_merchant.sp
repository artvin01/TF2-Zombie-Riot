#pragma semicolon 1
#pragma newdecls required

enum
{
	Merchant_Fish = 0,
	Merchant_MartialArt,
	Merchant_Agency,
	Merchant_Wine
}

static const int SupportBuildings[] = { 2, 5, 9, 14, 14, 15 };
static int MerchantLevel[MAXTF2PLAYERS] = {-1, ...};
static int i_AdditionalSupportBuildings[MAXTF2PLAYERS] = {0, ...};
static bool MerchantActive[MAXTF2PLAYERS];

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
			int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
			if(weapon != -1)
			{
				if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MERCHANT)
				{
					if(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon)
					{
//						if(!Waves_InSetup())
//							SetAmmo(client, Ammo_Metal, GetAmmo(client, Ammo_Metal) - MetalGain[MerchantLevel[client]]);

						if(ParticleRef[client] == -1)
						{
							float pos[3]; GetClientAbsOrigin(client, pos);
							pos[2] += 1.0;

							int entity = ParticleEffectAt(pos, "utaunt_hellpit_firering", -1.0);
							if(entity > MaxClients)
							{
								SetParent(client, entity);
								ParticleRef[client] = EntIndexToEntRef(entity);
							}
						}
					}

					MerchantActive[client] = false;
					return Plugin_Continue;
				}
			}
		}
		else
		{
			MerchantActive[client] = false;

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
	MerchantActive[client] = false;
		
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
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	Rogue_OnAbilityUse(weapon);
	Ability_Apply_Cooldown(client, slot, 30.0);

	ClientCommand(client, "playgamesound weapons/gunslinger_three_hit.wav");

	ApplyTempAttrib(weapon, 2, 2.0, 2.0);
	ApplyTempAttrib(weapon, 6, 0.25, 2.0);
}

public void Weapon_MerchantSecondary_R(int client, int weapon, bool crit, int slot)
{
	Menu menu = new Menu(MerchantMenuH);

	menu.SetTitle("Select Merchant Style:\n ");

	switch(MerchantLevel[client])
	{
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
