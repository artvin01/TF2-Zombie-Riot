#pragma semicolon 1
#pragma newdecls required

static Handle ResourceHud;
static float UpdateMenuIn[MAXTF2PLAYERS];
static bool InMenu[MAXTF2PLAYERS];
static bool HadSelection[MAXTF2PLAYERS];
static int CurrentHelp[MAXTF2PLAYERS];
static int CurrentTip[MAXTF2PLAYERS];
static int ResourceText[MAXTF2PLAYERS] = {INVALID_ENT_REFERENCE, ...};
static int SkillText[MAXTF2PLAYERS][MAX_SKILLS + 1];
static int SkillSprite[MAXTF2PLAYERS][MAX_SKILLS];
static int SkillSpritePos[MAXTF2PLAYERS];
static int UnitText[MAXTF2PLAYERS][3];
static int UnitSprite[MAXTF2PLAYERS] = {INVALID_ENT_REFERENCE, ...};
static ArrayList ControlGroups[MAXTF2PLAYERS][9];

void RTSMenu_Update(int client)
{
	UpdateMenuIn[client] = 0.0;
}

void RTSMenu_FormatUpdate(int client)
{
	ClearTexts(client);
}

static void ClearTexts(int client)
{
	DeleteRef(ResourceText[client]);
	DeleteRef(UnitSprite[client]);

	for(int i; i < sizeof(SkillText[]); i++)
	{
		DeleteRef(SkillText[client][i]);
	}

	for(int i; i < sizeof(SkillSprite[]); i++)
	{
		DeleteRef(SkillSprite[client][i]);
	}

	for(int i; i < sizeof(UnitText[]); i++)
	{
		DeleteRef(UnitText[client][i]);
	}
}

void RTSMenu_PluginStart()
{
	ResourceHud = CreateHudSynchronizer();

	for(int a; a < MAXTF2PLAYERS; a++)
	{
		for(int b; b < sizeof(SkillText[]); b++)
		{
			SkillText[a][b] = -1;
		}

		for(int b; b < sizeof(SkillSprite[]); b++)
		{
			SkillSprite[a][b] = -1;
		}

		for(int b; b < sizeof(UnitText[]); b++)
		{
			UnitText[a][b] = -1;
		}
	}
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

	ClearTexts(client);
}

void RTSMenu_PlayerRunCmd(int client)
{
	float gameTime = GetGameTime();
	if(UpdateMenuIn[client] > gameTime)
		return;
	
	UpdateMenuIn[client] = gameTime + 0.2;
	SetGlobalTransTarget(client);
	
	if(RTS_InSetup())
	{
		ClearTexts(client);
	}
	else
	{
		char buffer[48];
		
		if(RTSCamera_InCamera(client))
		{
			// Note: Aspect Ratio with text/sprite method
			// Instead requires shifting objects to the right
			// I don't know why this is the case but alright
			// Instead of what would be dividing by apsect ratio

			float mouse[2];
			float pos[2];
			float aspectRatio = RTSCamera_GetAspectRatio(client);
			RTSCamera_GetMousePos(client, mouse);

			float shiftRight = (1.777777 - aspectRatio) * 0.28;
			float shiftDown = (1.777777 - aspectRatio) * 0.033333;

			char display[512];
			
			/*
				Resources
			*/
			int supplies;
			int free = RTS_CheckSupplies(TeamNumber[client], supplies);
			FormatEx(display, sizeof(display), "%t %d / %d        ", ResourceName[0], supplies - free, supplies);
			for(int i = 1; i < Resource_MAX; i++)
			{
				//Resource[TeamNumber[client]][i]
				Format(display, sizeof(display), "%s\n%t %d", display, ResourceName[i], GetURandomInt() / 1000);
			}

			if(shiftRight > 0.2)
			{
				pos[0] = 0.42 + shiftRight;
				pos[1] = 0.31 + shiftDown;
			}
			else if(shiftRight > 0.1)
			{
				pos[0] = 0.61 + shiftRight;
				pos[1] = 0.54 + shiftDown;
			}
			else
			{
				pos[0] = 0.8 + shiftRight;
				pos[1] = 0.77 + shiftDown;
			}

			CreateScreenText(ResourceText[client], client, pos);
			DisplayScreenText(ResourceText[client], display);
			
			/*
				Selection
			*/
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
						// Name, Health, Team
						IntToString(TeamNumber[entity], buffer, sizeof(buffer));
						FormatEx(display, sizeof(display), "%s\n \n \n \n \n%d / %d\n%t", NpcStats_ReturnNpcName(entity), GetEntProp(entity, Prop_Data, "m_iHealth"), ReturnEntityMaxHealth(entity), "Team Of", buffer);

						pos[0] = 0.42 + shiftRight;
						pos[1] = 0.77 + shiftDown;
						CreateScreenText(UnitText[client][0], client, pos);
						DisplayScreenText(UnitText[client][0], display);

						// Icon
						pos[1] += 0.067;
						CreateScreenSprite(UnitSprite[client], client, "materials/test_sprite_sniper2.vmt", pos, 100.0);
						pos[1] -= 0.067;

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

						FormatEx(display, sizeof(display), "%t", "Armor Of", buffer);

						if(Stats[entity].Range)
						{
							// Range
							if(Stats[entity].RangeBonus)
							{
								FormatEx(buffer, sizeof(buffer), "%d (%s%d)", Stats[entity].Range, Stats[entity].RangeBonus < 0 ? "" : "+", Stats[entity].RangeBonus);
							}
							else
							{
								IntToString(Stats[entity].Range, buffer, sizeof(buffer));
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

						if(IsObject(entity))
						{
							int resource = Object_GetResource(entity);
							if(resource != Resource_None)
								Format(display, sizeof(display), "%s\n%t", display, "Resource Of", ResourceName[resource]);
						}

						// Flags
						bool first = true;
						for(int i; i < Flag_MAX; i++)
						{
							if(RTS_HasFlag(entity, i))
							{
								if(first)
								{
									Format(display, sizeof(display), "%s\n \n%t", display, FlagName[i]);
									first = false;
								}
								else
								{
									Format(display, sizeof(display), "%s, %t", display, FlagName[i]);
								}
							}
						}

						if(shiftRight > 0.2)
						{
							pos[0] = 0.42 + shiftRight;
							pos[1] = 0.54 + shiftDown;
						}
						else
						{
							pos[0] = 0.62 + shiftRight;
							pos[1] = 0.77 + shiftDown;
						}

						CreateScreenText(UnitText[client][1], client, pos);
						DisplayScreenText(UnitText[client][1], display);
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
							maxhealth += ReturnEntityMaxHealth(entity);

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

						if(i == 0)
						{
							FormatEx(display, sizeof(display), "%d %t", size, name);
						}
						else
						{
							Format(display, sizeof(display), "%s\n%d %t", display, size, name);
						}
					}

					delete snap;
					delete map;

					pos[0] = 0.42 + shiftRight;
					pos[1] = 0.77 + shiftDown;
					CreateScreenText(UnitText[client][0], client, pos);
					DisplayScreenText(UnitText[client][0], display);

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

					FormatEx(display, sizeof(display), "%t\n%t", "Team Of", buffer, "Health Of", health, maxhealth);

					if(shiftRight > 0.2)
					{
						pos[0] = 0.42 + shiftRight;
						pos[1] = 0.54 + shiftDown;
					}
					else
					{
						pos[0] = 0.62 + shiftRight;
						pos[1] = 0.77 + shiftDown;
					}

					CreateScreenText(UnitText[client][1], client, pos);
					DisplayScreenText(UnitText[client][1], display);

					DeleteRef(UnitSprite[client]);
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

				PrintCenterText(client, "%f %f", mouse[0], mouse[1]);
				
				bool hasDesc;
				float hitbox[2];
				float offset[2];
				for(int i; i < MAX_SKILLS; i++)
				{
					static const float StartHeight = 0.8;
					static const float SpriteSize = 0.11;
					static const float SpriteSizeHalf = 0.055;	// Half of SpriteSize
					static const float SpriteShift = 0.061;
					static const float IconCenterHitbox = 0.115555;	// Center of first icon

					if((i % 5) == 0)
					{
						offset[0] = SpriteShift + shiftRight;
						hitbox[0] = IconCenterHitbox / aspectRatio;

						offset[1] = StartHeight + ((i / 5) * SpriteSize) + shiftDown;
						hitbox[1] = StartHeight + ((i / 5) * SpriteSize);
					}
					else
					{
						offset[0] += SpriteShift;
						hitbox[0] += SpriteSize / aspectRatio;
					}

					if(found[i])
					{
						static const char button[][] = { "@", "Q", "W", "E", "R", "T", "A", "S", "D", "F", "G" };

						if(fabs(mouse[0] - hitbox[0]) < (SpriteSizeHalf / aspectRatio) &&
							fabs(mouse[1] - hitbox[1]) < SpriteSizeHalf)
						{
							// Hovering over icon
							hasDesc = true;

							if(SkillSpritePos[client] != i)
							{
								// Reset text position
								DeleteRef(SkillText[client][MAX_SKILLS]);
								SkillSpritePos[client] = i;
							}

							if(skill[i].Formater[0])
							{
								FormatEx(display, sizeof(display), "(%s) %t", button[skill[i].Auto ? 0 : (i+1)], skill[i].Formater, skill[i].Name);
							}
							else
							{
								FormatEx(display, sizeof(display), "(%s) %t", button[skill[i].Auto ? 0 : (i+1)], skill[i].Name);
							}

							bool first2 = true;
							for(int b; b < Resource_MAX; b++)
							{
								if(skill[i].Price[b])
								{
									if(first2)
									{
										Format(display, sizeof(display), "%s [%d%t", display, skill[i].Price[b], ResourceShort[b]);
										first2 = false;
									}
									else
									{
										Format(display, sizeof(display), "%s %d%t", display, skill[i].Price[b], ResourceShort[b]);
									}
								}
							}

							if(!first2)
								Format(display, sizeof(display), "%s]", display);
							
							if(skill[i].Count > 1 || skill[i].Cooldown > 999.9)
								Format(display, sizeof(display), "%s x%d", display, skill[i].Count);
							
							if(skill[i].Cooldown > 0.0 && skill[i].Cooldown < 999.9)
								Format(display, sizeof(display), "%s (%ds)", display, RoundToCeil(skill[i].Cooldown / RTS_GameSpeed()));
							
							Format(display, sizeof(display), "%s\n%t", display, skill[i].Desc);

							pos[0] = 0.18 + shiftRight;
							pos[1] = 0.5 + shiftDown;
							CreateScreenText(SkillText[client][MAX_SKILLS], client, pos);
							DisplayScreenText(SkillText[client][MAX_SKILLS], display);
						}

						int info;

						if(skill[i].Auto)
						{
							strcopy(display, sizeof(display), "  ");
						}
						else
						{
							info++;
							strcopy(display, sizeof(display), button[i + 1]);
						}

						if(skill[i].Count > 1 || skill[i].Cooldown > 999.9)
						{
							info++;
							Format(display, sizeof(display), "%s   x%d", display, skill[i].Count);
						}
						
						if(info < 2 && skill[i].Cooldown > 0.0 && skill[i].Cooldown < 999.9)
						{
							info++;
							Format(display, sizeof(display), "%s   %ds", display, RoundToCeil(skill[i].Cooldown / RTS_GameSpeed()));
						}

						if(info)
						{
							if(info == 1)
							{
								Format(display, sizeof(display), "%s         ", display);
							}

							pos[0] = offset[0];
							pos[1] = offset[1] - 0.02;
							CreateScreenText(SkillText[client][i], client, pos);
							DisplayScreenText(SkillText[client][i], display);
						}
						
						CreateScreenSprite(SkillSprite[client][i], client, "materials/test_sprite_sniper2.vmt", offset, 100.0);
						
					}
					else
					{
						CreateScreenSprite(SkillSprite[client][i], client, "materials/test_sprite_sniper2.vmt", offset, 100.0);
						//DeleteRef(SkillSprite[client][i]);
						DeleteRef(SkillText[client][i]);
					}
				}

				if(!hasDesc)
				{
					DeleteRef(SkillText[client][MAX_SKILLS]);
				}
			}
			else
			{
				if(CurrentHelp[client] < 2 || !RTS_IsSpectating(client))
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
						FormatEx(display, sizeof(display), "%t", buffer);
					}
					else
					{
						if(CurrentTip[client] < 1)
							CurrentTip[client] = 1;
						
						FormatEx(buffer, sizeof(buffer), "RTS Tooltip %d", CurrentTip[client]);
						FormatEx(display, sizeof(display), "%t", buffer);
					}

					pos[0] = 0.42 + shiftRight;
					pos[1] = 0.77 + shiftDown;
					CreateScreenText(UnitText[client][0], client, pos);
					DisplayScreenText(UnitText[client][0], display);
					
					if(CvarInfiniteCash.BoolValue)
					{
						for(int i = 1; i < Resource_MAX; i++)
						{
							Resource[TeamNumber[client]][i] = 100000;
						}
					}
				}
				else
				{
					DeleteRef(UnitText[client][0]);
				}

				DeleteRef(UnitText[client][1]);
				DeleteRef(UnitSprite[client]);
				
				for(int i; i < sizeof(SkillText[]); i++)
				{
					DeleteRef(SkillText[client][i]);
				}
				
				for(int i; i < sizeof(SkillSprite[]); i++)
				{
					DeleteRef(SkillSprite[client][i]);
				}
			}
		}
		else
		{
			ClearTexts(client);
		}
		
		if(InMenu[client] && SkillText[client][MAX_SKILLS] != -1)
		{
			CancelClientMenu(client);
			ClientCommand(client, "slot10");
			InMenu[client] = false;
		}
		else if((InMenu[client] || GetClientMenu(client) == MenuSource_None) && SkillText[client][MAX_SKILLS] == -1)
		{
			Menu menu = new Menu(UpdateMenuMainH);
			menu.SetTitle("Fortress Wars: Closed Alpha\n ");

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

			FormatEx(buffer, sizeof(buffer), "%t", "Settings");
			menu.AddItem(NULL_STRING, buffer);

			menu.Pagination = 0;
			InMenu[client] = menu.Display(client, 1);
		}
	}
}

static int IntToSpacedString(int value, int space, char[] buffer, int length)
{
	int size = IntToString(value, buffer, length);

	for(int i = size; i < space; i++)
	{
		buffer[size++] = ' ';
		buffer[size++] = ' ';
	}

	buffer[size] = '\0';
	return size;
}

static void CreateScreenText(int &ref, int client, const float pos[2], float scale = 225.0, const int color[4] = {255, 255, 255, 255}, bool rainbow = false)
{
	if(EntRefToEntIndex(ref) != -1)
		return;
	
	int camera = RTSCamera_GetCamera(client);
	if(camera != -1)
	{
		float vec[3];
		RTSCamera_GetVector(client, vec);

		GetCursorVector(client, vec, pos, vec);

		ScaleVector(vec, scale); // Higher = less text size

		ref = SpawnFormattedWorldText("ABC\n123", vec, 10, color, camera, rainbow);
		if(ref != -1)
		{
			DispatchKeyValueInt(ref, "font", 5);
			SetEntPropEnt(ref, Prop_Send, "m_hOwnerEntity", client);
			SDKHook(ref, SDKHook_SetTransmit, SetTransmit_Owner);
			ref = EntIndexToEntRef(ref);
		}
	}
	else
	{
		ref = -1;
	}
}

static void DisplayScreenText(int ref, const char[] message)
{
	if(ref != -1)
		DispatchKeyValue(ref, "message", message);
}

static void CreateScreenSprite(int &ref, int client, const char[] material, const float pos[2], float scale = 100.0)
{
	if(EntRefToEntIndex(ref) != -1)
		return;
	
	int camera = RTSCamera_GetCamera(client);
	if(camera != -1)
	{
		float vec[3], ang[3];
		RTSCamera_GetVector(client, vec);
		GetVectorAngles(vec, ang);

		GetCursorVector(client, vec, pos, vec);

		ScaleVector(vec, scale); // Higher = less text size

		ref = CreateEntityByName("env_sprite_oriented");
		if(ref != -1)
		{
			DispatchKeyValue(ref, "model", material);
			
			DispatchSpawn(ref);
			SetEdictFlags(ref, (GetEdictFlags(ref) & ~FL_EDICT_ALWAYS));

			float pos2[3];
			GetAbsOrigin(camera, pos2);
			
			pos2[0] += vec[0];
			pos2[1] += vec[1];
			pos2[2] += vec[2];

			TeleportEntity(ref, pos2, ang, NULL_VECTOR);
			SetParent(camera, ref, "", vec);

			AcceptEntityInput(ref, "ShowSprite");
			
			SetEntPropEnt(ref, Prop_Send, "m_hOwnerEntity", client);
			SDKHook(ref, SDKHook_SetTransmit, SetTransmit_Owner);
			ref = EntIndexToEntRef(ref);
		}
	}
	else
	{
		ref = -1;
	}
}

static Action SetTransmit_Owner(int entity, int client)
{
	SetEdictFlags(entity, (GetEdictFlags(entity) & ~FL_EDICT_ALWAYS));
	return GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity") == client ? Plugin_Continue : Plugin_Handled;
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

				UpdateMenuIn[client] = 0.0;
			}
			else
			{
				RTSCamera_ShowMenu(client, 0);
			}
		}
	}

	return 0;
}

static void DeleteRef(int &ref)
{
	if(ref != -1)
	{
		int entity = EntRefToEntIndex(ref);
		if(entity != -1)
			RemoveEntity(ref);
		
		ref = -1;
	}
}
