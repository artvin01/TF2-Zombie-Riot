#pragma semicolon 1
#pragma newdecls required

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
					if(!IsObject(entity))
					{
						bool first = true;
						for(int i; i < Flag_MAX; i++)
						{
							if(UnitBody_HasFlag(entity, i))
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
					}

					// Team & Health
					IntToString(TeamNumber[entity], buffer, sizeof(buffer));
					Format(display, sizeof(display), "%s\n%t\n \n%t", display, "Team Of", buffer, "Health Of", GetEntProp(entity, Prop_Data, "m_iHealth"), GetEntProp(entity, Prop_Data, "m_iMaxHealth"));

					if(IsObject(entity))
					{
						Format(display, sizeof(display), "%s\n%t", display, "Resource Of", ResourceName[Object_GetResource(entity)]);
					}
					else
					{
						StatEnum stat;
						UnitBody_GetStats(entity, stat);

						// Armor
						if(stat.MeleeArmorBonus != 0)
						{
							FormatEx(buffer, sizeof(buffer), "%d (%s%d) / ", stat.MeleeArmor, stat.MeleeArmorBonus < 0 ? "" : "+", stat.MeleeArmorBonus);
						}
						else
						{
							FormatEx(buffer, sizeof(buffer), "%d / ", stat.MeleeArmor);
						}

						if(stat.RangeArmorBonus != 0)
						{
							FormatEx(buffer, sizeof(buffer), "%s%d (%s%d)", buffer, stat.RangeArmor, stat.RangeArmorBonus < 0 ? "" : "+", stat.RangeArmorBonus);
						}
						else
						{
							FormatEx(buffer, sizeof(buffer), "%s%d", buffer, stat.RangeArmor);
						}

						Format(display, sizeof(display), "%s\n%t", display, "Armor Of", buffer);

						if(stat.Damage)
						{
							// Damage
							if(stat.DamageBonus)
							{
								FormatEx(buffer, sizeof(buffer), "%d (%s%d)", stat.Damage, stat.DamageBonus < 0 ? "" : "+", stat.DamageBonus);
							}
							else
							{
								IntToString(stat.Damage, buffer, sizeof(buffer));
							}

							Format(display, sizeof(display), "%s\n%t", display, "Damage Of", buffer);
							
							// Damage vs Flag
							for(int i; i < Flag_MAX; i++)
							{
								if(stat.ExtraDamage[i] || stat.ExtraDamageBonus[i])
								{
									if(stat.DamageBonus || stat.ExtraDamageBonus[i])
									{
										int bonus = stat.DamageBonus + stat.ExtraDamageBonus[i];
										FormatEx(buffer, sizeof(buffer), "%d (%s%d)", stat.Damage + stat.ExtraDamage[i], bonus < 0 ? "" : "+", bonus);
									}
									else
									{
										IntToString(stat.Damage + stat.ExtraDamage[i], buffer, sizeof(buffer));
									}

									Format(display, sizeof(display), "%s\n %t", display, "vs Type of", FlagName[i], buffer);
								}
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
				if(entity != -1 && UnitBody_CanControl(client, entity))
				{
					for(int b; b < MAX_SKILLS; b++)
					{
						if(found[b] && found[b] != i_NpcInternalId[entity])
							continue;
						
						float cooldown = found[b] ? skill[b].Cooldown : FAR_FUTURE;
						int count = skill[b].Count;

						if(UnitBody_GetSkill(entity, client, b, skill[b]))
						{
							if(skill[b].Cooldown > cooldown || (skill[b].Cooldown == 0.0 && cooldown != FAR_FUTURE))
								skill[b].Cooldown = cooldown;

							skill[b].Count += count;
							found[b] = i_NpcInternalId[entity];
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

					FormatEx(buffer, sizeof(buffer), "(%s) %t", button[skill[i].Auto ? 0 : (i+1)], skill[i].Name);

					if(skill[i].Count > 1 || skill[i].Cooldown > 999.9)
						Format(buffer, sizeof(buffer), "%s x%d", buffer, skill[i].Count);
					
					if(skill[i].Cooldown > 0.0 && skill[i].Cooldown < 999.9)
						Format(buffer, sizeof(buffer), "%s (%ds)", buffer, RoundToCeil(skill[i].Cooldown));
					
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
					if(entity == -1 || !UnitBody_CanControl(client, entity))
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