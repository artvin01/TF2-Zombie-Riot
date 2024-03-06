#pragma semicolon 1
#pragma newdecls required

static Handle ResourceHud;
static float UpdateMenuIn[MAXTF2PLAYERS];
static bool InMenu[MAXTF2PLAYERS];
static bool HadSelection[MAXTF2PLAYERS];
static int CurrentHelp[MAXTF2PLAYERS];
static int CurrentTip[MAXTF2PLAYERS];
static ArrayList ControlGroups[MAXTF2PLAYERS][9];

void RTSMenu_Update(int client)
{
	UpdateMenuIn[client] = 0.0;
}

void RTSMenu_PluginStart()
{
	ResourceHud = CreateHudSynchronizer();
}

void RTSMenu_ClientDisconnect(int client)
{
	CurrentHelp[client] = 0;
	HadSelection[client] = false;
	UpdateMenuIn[client] = 0.0;

	for(int i; i < sizeof(ControlGroups[]); i++)
	{
		delete ControlGroups[client][i];
	}
}

void RTSMenu_PlayerRunCmd(int client)
{
	if(!InMenu[client] && GetClientMenu(client) != MenuSource_None)
		return;
	
	float gameTime = GetGameTime();
	if(UpdateMenuIn[client] > gameTime)
		return;
	
	UpdateMenuIn[client] = gameTime + 0.5;
	SetGlobalTransTarget(client);
	
	if(RTS_InSetup())
	{

	}
	else
	{
		char display[512], buffer[32];
		strcopy(display, sizeof(display), "Fortress Wars CLOSED ALPHA\n ");
		
		ArrayList selection = RTSCamera_GetSelected(client);
		if(selection)
		{
			HadSelection[client] = true;

			int length = selection.Length;
			if(length == 1)
			{
				int entity = EntRefToEntIndex(selection.Get(0));
				if(entity != -1)
				{
					// Name
					Format(display, sizeof(display), "%s\n%t\n", display, c_NpcName[entity]);

					// Flags
					bool first = true;
					for(int i; i < Flag_MAX; i++)
					{
						if(RTS_HasFlag(entity, i))
						{
							if(first)
							{
								Format(display, sizeof(display), "%s%t", display, FlagName[i]);
								first = false;
							}
							else
							{
								Format(display, sizeof(display), "%s, %t", display, FlagName[i]);
							}
						}
					}

					// Team & Health
					IntToString(TeamNumber[entity], buffer, sizeof(buffer));
					Format(display, sizeof(display), "%s\n%t\n \n%t", display, "Team Of", buffer, "Health Of", GetEntProp(entity, Prop_Data, "m_iHealth"), GetEntProp(entity, Prop_Data, "m_iMaxHealth"));

					if(IsObject(entity))
					{
						int resource = Object_GetResource(entity);
						if(resource != Resource_None)
							Format(display, sizeof(display), "%s\n%t", display, "Resource Of", ResourceName[resource]);
					}
					
					// Armor
					if(Stats[entity].MeleeArmorBonus != 0)
					{
						FormatEx(buffer, sizeof(buffer), "%d (%s%d) / ", Stats[entity].MeleeArmor, Stats[entity].MeleeArmorBonus < 0 ? "" : "+", Stats[entity].MeleeArmorBonus);
					}
					else
					{
						FormatEx(buffer, sizeof(buffer), "%d / ", Stats[entity].MeleeArmor);
					}

					if(Stats[entity].RangeArmorBonus != 0)
					{
						FormatEx(buffer, sizeof(buffer), "%s%d (%s%d)", buffer, Stats[entity].RangeArmor, Stats[entity].RangeArmorBonus < 0 ? "" : "+", Stats[entity].RangeArmorBonus);
					}
					else
					{
						FormatEx(buffer, sizeof(buffer), "%s%d", buffer, Stats[entity].RangeArmor);
					}

					Format(display, sizeof(display), "%s\n%t", display, "Armor Of", buffer);

					if(Stats[entity].Range)
					{
						// Range
						if(Stats[entity].RangeBonus)
						{
							FormatEx(buffer, sizeof(buffer), "%d (%s%d)", Stats[entity].Range, Stats[entity].RangeBonus < 0 ? "" : "+", Stats[entity].RangeBonus);
						}
						else
						{
							IntToString(Stats[entity].RangeBonus, buffer, sizeof(buffer));
						}

						Format(display, sizeof(display), "%s\n%t", display, "Range Of", buffer);
					}

					if(Stats[entity].Damage)
					{
						// Damage
						if(Stats[entity].DamageBonus)
						{
							FormatEx(buffer, sizeof(buffer), "%d (%s%d)", Stats[entity].Damage, Stats[entity].DamageBonus < 0 ? "" : "+", Stats[entity].DamageBonus);
						}
						else
						{
							IntToString(Stats[entity].Damage, buffer, sizeof(buffer));
						}

						Format(display, sizeof(display), "%s\n%t", display, "Damage Of", buffer);
						
						// Damage vs Flag
						for(int i; i < Flag_MAX; i++)
						{
							if(Stats[entity].ExtraDamage[i] || Stats[entity].ExtraDamageBonus[i])
							{
								if(Stats[entity].DamageBonus || Stats[entity].ExtraDamageBonus[i])
								{
									int bonus = Stats[entity].DamageBonus + Stats[entity].ExtraDamageBonus[i];
									FormatEx(buffer, sizeof(buffer), "%d (%s%d)", Stats[entity].Damage + Stats[entity].ExtraDamage[i], bonus < 0 ? "" : "+", bonus);
								}
								else
								{
									IntToString(Stats[entity].Damage + Stats[entity].ExtraDamage[i], buffer, sizeof(buffer));
								}

								Format(display, sizeof(display), "%s\n %t", display, "vs Type of", FlagName[i], buffer);
							}
						}
					}
				}
			}
			else
			{
				StringMap map = new StringMap();
				bool team[MAX_TEAMS];
				int health, maxhealth;

				for(int i; i < length; i++)
				{
					int entity = EntRefToEntIndex(selection.Get(i));
					if(entity != -1)
					{
						team[TeamNumber[entity]] = true;
						health += GetEntProp(entity, Prop_Data, "m_iHealth");
						maxhealth += GetEntProp(entity, Prop_Data, "m_iMaxHealth");

						int count;
						map.GetValue(c_NpcName[entity], count);
						map.SetValue(c_NpcName[entity], count + 1);
					}
				}

				StringMapSnapshot snap = map.Snapshot();
				int length2 = snap.Length;
				for(int i; i < length2; i++)
				{
					int size = snap.KeyBufferSize(i);
					char[] name = new char[size];
					snap.GetKey(i, name, size);
					map.GetValue(name, size);

					Format(display, sizeof(display), "%s\n%d %t", display, size, name);
				}

				delete snap;
				delete map;

				bool first = true;
				for(int i; i < sizeof(team); i++)
				{
					if(team[i])
					{
						if(first)
						{
							IntToString(i, buffer, sizeof(buffer));
							first = false;
						}
						else
						{
							Format(buffer, sizeof(buffer), "%s, %d", buffer, i);
						}
					}
				}

				Format(display, sizeof(display), "%s\n \n%t\n%t", display, "Team Of", buffer, "Health Of", health, maxhealth);
			}

			// Skills
			int found[MAX_SKILLS];
			SkillEnum skill[MAX_SKILLS];
			for(int a; a < length; a++)
			{
				int entity = EntRefToEntIndex(selection.Get(a));
				if(entity != -1 && RTS_CanControl(client, entity))
				{
					for(int b; b < MAX_SKILLS; b++)
					{
						int id = IsObject(entity) ? -i_NpcInternalId[entity] : i_NpcInternalId[entity];
						if(found[b] && found[b] != id)
							continue;
						
						float cooldown = found[b] ? skill[b].Cooldown : FAR_FUTURE;
						int count = skill[b].Count;

						if(RTS_GetSkill(entity, client, b, skill[b]))
						{
							if(skill[b].Cooldown > cooldown || (skill[b].Cooldown == 0.0 && cooldown != FAR_FUTURE))
								skill[b].Cooldown = cooldown;

							skill[b].Count += count;
							found[b] = id;
						}
					}
				}
			}

			bool first = true;
			for(int i; i < MAX_SKILLS; i++)
			{
				if(found[i])
				{
					static const char button[][] = { "@", "Q", "W", "E", "R", "T", "A", "S", "D", "F", "G" };

					if(RTSCamera_HoldingCtrl(client) && skill[i].Desc[0])
					{
						FormatEx(buffer, sizeof(buffer), "(%s) %t", button[skill[i].Auto ? 0 : (i+1)], skill[i].Desc);
					}
					else
					{
						if(skill[i].Formater[0])
						{
							FormatEx(buffer, sizeof(buffer), "(%s) %t", button[skill[i].Auto ? 0 : (i+1)], skill[i].Formater, skill[i].Name);
						}
						else
						{
							FormatEx(buffer, sizeof(buffer), "(%s) %t", button[skill[i].Auto ? 0 : (i+1)], skill[i].Name);
						}

						bool first2 = true;
						for(int b; b < Resource_MAX; b++)
						{
							if(skill[i].Price[b])
							{
								if(first2)
								{
									Format(buffer, sizeof(buffer), "%s [%d%s", buffer, skill[i].Price, ResourceShort[b]);
									first2 = false;
								}
								else
								{
									Format(buffer, sizeof(buffer), "%s %d%s", buffer, skill[i].Price, ResourceShort[b]);
								}
							}
						}

						if(!first2)
							Format(buffer, sizeof(buffer), "%s]", buffer);
						
						if(skill[i].Count > 1 || skill[i].Cooldown > 999.9)
							Format(buffer, sizeof(buffer), "%s x%d", buffer, skill[i].Count);
						
						if(skill[i].Cooldown > 0.0 && skill[i].Cooldown < 999.9)
							Format(buffer, sizeof(buffer), "%s (%ds)", buffer, RoundToCeil(skill[i].Cooldown));
					}

					if(first)
					{
						Format(display, sizeof(display), "%s\n \n%s", display, buffer);
						first = false;
					}
					else
					{
						Format(display, sizeof(display), "%s\n%s", display, buffer);
					}
				}
			}
		}
		else if(CurrentHelp[client] < 2 || !RTS_IsSpectating(client))
		{
			if(HadSelection[client])
			{
				HadSelection[client] = false;
				CurrentHelp[client]++;
				CurrentTip[client] = 1 + (GetURandomInt() % TIP_HINT_COUNT);
			}

			if(CurrentHelp[client] <= HELP_HINT_COUNT)
			{
				if(CurrentHelp[client] < 1)
					CurrentHelp[client] = 1;
				
				FormatEx(buffer, sizeof(buffer), "RTS Help %d", CurrentHelp[client]);
				Format(display, sizeof(display), "%s\n%t", display, buffer);
			}
			else
			{
				if(CurrentTip[client] < 1)
					CurrentTip[client] = 1;
				
				FormatEx(buffer, sizeof(buffer), "RTS Tooltip %d", CurrentTip[client]);
				Format(display, sizeof(display), "%s\n%t", display, buffer);
			}
			
			if(CvarInfiniteCash.BoolValue)
			{
				for(int i = 1; i < Resource_MAX; i++)
				{
					Resource[TeamNumber[client]][i] = 100000;
				}
			}
		}
		
		Menu menu = new Menu(UpdateMenuMainH);
		menu.SetTitle("%s\n ", display);

		if(RTS_IsSpectating(client))
		{
			FormatEx(buffer, sizeof(buffer), "%t", "Spectating");
			menu.AddItem(NULL_STRING, buffer, ITEMDRAW_SPACER);
		}
		else
		{
			int entity = -1;
			for(int a; a < sizeof(ControlGroups[]); a++)
			{
				int length = ControlGroups[client][a] ? ControlGroups[client][a].Length : 0;
				for(int b; b < length; b++)
				{
					entity = EntRefToEntIndex(ControlGroups[client][a].Get(b));
					if(entity == -1 || !RTS_CanControl(client, entity))
					{
						ControlGroups[client][a].Erase(b);
						b--;
						length--;

						if(length == 0)
							delete ControlGroups[client][a];
					}
				}

				if(length > 1)
				{
					FormatEx(buffer, sizeof(buffer), "x%d", length);
				}
				else if(length == 1)
				{
					FormatEx(buffer, sizeof(buffer), "%t", c_NpcName[entity]);
				}
				else
				{
					buffer[0] = 0;
				}
				
				menu.AddItem(NULL_STRING, buffer);
			}
		}

		menu.Pagination = 0;
		menu.ExitButton = true;
		InMenu[client] = menu.Display(client, 1);

		int supplies;
		int free = RTS_CheckSupplies(TeamNumber[client], supplies);
		FormatEx(display, sizeof(display), "Medieval Empire\nTeutons\n \n%t %d / %d", ResourceName[0], supplies - free, supplies);
		for(int i = 1; i < Resource_MAX; i++)
		{
			Format(display, sizeof(display), "%s\n%t %d", display, ResourceName[i], Resource[TeamNumber[client]][i]);
		}

		SetHudTextParams(0.0, 0.0, 0.8, 255, 255, 255, 255);
		ShowSyncHudText(client, ResourceHud, display);
	}
}

static int UpdateMenuMainH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			InMenu[client] = false;

			if(choice == MenuCancel_Exit)
				RTSCamera_ShowMenu(client, 0);
		}
		case MenuAction_Select:
		{
			InMenu[client] = false;

			if(choice >= 0 && choice < sizeof(ControlGroups[]))
			{
				if(RTSCamera_HoldingCtrl(client))
				{
					delete ControlGroups[client][choice];
					ArrayList list = RTSCamera_GetSelected(client);
					if(list)
						ControlGroups[client][choice] = list.Clone();
				}
				else
				{
					ArrayList list = ControlGroups[client][choice];
					if(list)
						list = list.Clone();
					
					RTSCamera_SetSelected(client, list);
				}
			}

			UpdateMenuIn[client] = 0.0;
		}
	}

	return 0;
}