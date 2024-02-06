#pragma semicolon 1
#pragma newdecls required

#define MIN_FADE_DISTANCE	9999.9
#define MAX_FADE_DISTANCE	9999.9

#define HELP_HINT_COUNT	4
#define TIP_HINT_COUNT	8

#define MAX_TEAMS	17
#define MAX_SKILLS	10

enum
{
	Flag_Light = 0,
	Flag_Heavy,
	Flag_Biological,
	Flag_Mechanical,
	Flag_Structure,
	Flag_Unique,
	Flag_Heroic,
	Flag_Summoned,
	Flag_Worker,

	Flag_MAX
}

public const char FlagName[][] =
{
	"Light",
	"Heavy",
	"Biological",
	"Mechanical",
	"Structure",
	"Unique",
	"Heroic",
	"Summoned",
	"Worker"
};

enum
{
	Command_Idle = 0,
	Command_Move,
	Command_Attack,
	Command_HoldPos,
	Command_Patrol
}

enum
{
	Sound_Select,
	Sound_Move,
	Sound_Attack,
	Sound_CombatAlert,
	
	Sound_MAX
}

public const int TeamColor[][] =
{
	{255, 255, 255, 255},	// 0 = White
	{0, 0, 255, 255},	// 1 = Blue
	{255, 0, 0, 255},	// 2 = Red
	{0, 255, 0, 255},	// 3 = Green
	{255, 255, 0, 255},	// 4 = Yellow
	{0, 255, 255, 255},	// 5 = Cyan
	{255, 0, 255, 255},	// 6 = Pink
	{127, 127, 127, 255},	// 7 = Gray
	{255, 127, 0, 255},	// 8 = Orange
	{127, 255, 0, 255},	// 9 = Lime
	{127, 0, 255, 255},	// 10 = Purple
	{0, 127, 255, 255},	// 11 = Light Blue
	{255, 0, 127, 255},	// 12 = Light Pink
	{0, 255, 127, 255},	// 13 = Light Green
	{255, 127, 127, 255},	// 14
	{127, 255, 127, 255},	// 15
	{127, 127, 255, 255},	// 16
};

enum struct StatEnum
{
	int RangeArmor;
	int RangeArmorBonus;
	int MeleeArmor;
	int MeleeArmorBonus;
	int Damage;
	int DamageBonus;
	int ExtraDamage[Flag_MAX];
	int ExtraDamageBonus[Flag_MAX];
}

enum struct SkillEnum
{
	char Name[32];
	float Cooldown;
	int Count;
	bool Auto;
}

int TeamNumber[MAXENTITIES];
int BuildMode[MAXTF2PLAYERS];

#include "fortress_wars/npc.sp"	// Global NPC List

static bool InSetup;
static int AlliedTeams[MAX_TEAMS];
static int AllowControls[MAX_TEAMS];
static float UpdateMenuIn[MAXTF2PLAYERS];
static bool InMenu[MAXTF2PLAYERS];
static bool HadSelection[MAXTF2PLAYERS];
static int CurrentHelp[MAXTF2PLAYERS];
static int CurrentTip[MAXTF2PLAYERS];
static ArrayList ControlGroups[MAXTF2PLAYERS][9];
static float GameSpeed = 0.5;

void RTS_PluginStart()
{
	RegAdminCmd("rts_setspeed", CommandSetSpeed, ADMFLAG_RCON, "Set the game speed");

	LoadTranslations("realtime.unitnames.phrases");
}

void RTS_ClientDisconnect(int client)
{
	CurrentHelp[client] = 0;
	HadSelection[client] = false;
	UpdateMenuIn[client] = 0.0;
	TeamNumber[client] = 0;
	BuildMode[client] = 0;

	for(int i; i < sizeof(ControlGroups[]); i++)
	{
		delete ControlGroups[client][i];
	}
}

void RTS_ConfigsSetup()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
			TeamNumber[client] = (client % MAX_TEAMS);
	}
}

void RTS_PlayerResupply(int client)
{
	// DEBUG
	TeamNumber[client] = (client % MAX_TEAMS);
	// DEBUG

	if(!RTS_InSetup())
	{
		TF2_RemoveAllWeapons(client);
		int active = SpawnWeapon(client, "tf_weapon_pistol", 209, 1, 0, {128, 301, 821, 2}, {1.0, 1.0, 1.0, 0.0}, 4);
		int last = SpawnWeapon(client, "tf_weapon_wrench", 197, 1, 0, {128, 821, 2}, {1.0, 1.0, 0.0}, 3);

		TF2Util_SetPlayerActiveWeapon(client, active);
		SetEntPropEnt(client, Prop_Send, "m_hLastWeapon", last);
	}
}

void RTS_PlayerRunCmd(int client)
{
	UpdateMenu(client);
}

void RTS_UpdateMenu(int client)
{
	UpdateMenuIn[client] = 0.0;
}

static void UpdateMenu(int client)
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
					Format(display, sizeof(display), "%s\n%t\n", display, NPC_Names[i_NpcInternalId[entity]]);

					// Flags
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

					// Team & Health
					IntToString(TeamNumber[entity], buffer, sizeof(buffer));
					Format(display, sizeof(display), "%s\n%t\n \n%t", display, "Team Of", buffer, "Health Of", GetEntProp(entity, Prop_Data, "m_iHealth"), GetEntProp(entity, Prop_Data, "m_iMaxHealth"));

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
			else
			{
				bool team[MAX_TEAMS];
				int count[MAX_NPC_TYPES];
				int health, maxhealth;

				for(int i; i < length; i++)
				{
					int entity = EntRefToEntIndex(selection.Get(i));
					if(entity != -1)
					{
						count[i_NpcInternalId[entity]]++;
						team[TeamNumber[entity]] = true;
						health += GetEntProp(entity, Prop_Data, "m_iHealth");
						maxhealth += GetEntProp(entity, Prop_Data, "m_iMaxHealth");
					}
				}

				for(int i; i < sizeof(count); i++)
				{
					if(count[i])
						Format(display, sizeof(display), "%s\n%d %t", display, count[i], NPC_Names[i]);
				}

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
		else
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
				FormatEx(buffer, sizeof(buffer), "%t", NPC_Names[i_NpcInternalId[entity]]);
			}
			else
			{
				buffer[0] = 0;
			}
			
			menu.AddItem(NULL_STRING, buffer);
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
			UpdateMenu(client);
		}
	}

	return 0;
}

bool RTS_InSetup()
{
	return InSetup;
}

float RTS_GameSpeed()
{
	return GameSpeed;
}

bool RTS_IsTeamAlly(int team1, int team2)
{
	return team1 == team2 || (AlliedTeams[team1] & (1 << team2));
}

bool RTS_CanTeamControl(int team1, int team2)
{
	return team1 == team2 || (AllowControls[team1] & (1 << team2));
}

void RTS_NPCHealthBar(CClotBody npc)
{
	int textEntity = npc.m_iTextEntity5;
	if(b_IsEntityNeverTranmitted[npc.index])
	{
		if(IsValidEntity(textEntity))
			RemoveEntity(textEntity);
		
		return;	
	}

	char display[32];

	static const int HealthBarDivide = 10;

	int maxBars = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / HealthBarDivide;
	int bars = GetEntProp(npc.index, Prop_Data, "m_iHealth") / HealthBarDivide;

	if(maxBars > sizeof(display))
	{
		maxBars = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / sizeof(display);
		bars = GetEntProp(npc.index, Prop_Data, "m_iHealth") / sizeof(display);
	}

	for(int i; i < maxBars; i++)
	{
		if(bars < i)
		{
			Format(display, sizeof(display), "%s%s", display, ".");
		}
		else
		{
			Format(display, sizeof(display), "%s%s", display, "|");
		}
	}

	if(IsValidEntity(textEntity))
	{
		DispatchKeyValue(textEntity, "message", display);
	}
	else
	{
		float offset[3];
		offset[2] += 95.0 * GetEntPropFloat(npc.index, Prop_Send, "m_flModelScale");
		
		textEntity = SpawnFormattedWorldText(display, offset, 34, TeamColor[TeamNumber[npc.index]], npc.index);
		DispatchKeyValue(textEntity, "font", "1");
		SetEntPropEnt(textEntity, Prop_Send, "m_hOwnerEntity", npc.index);
		SDKHook(textEntity, SDKHook_SetTransmit, HealthBarTransmit);
		npc.m_iTextEntity5 = textEntity;
	}
}

static Action HealthBarTransmit(int entity, int client)
{
	if(client > 0 && client <= MaxClients)
	{
		if(!RTSCamera_IsUnitSelectedBy(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"), client))
			return Plugin_Stop;
	}

	return Plugin_Continue;
}

static Action CommandSetSpeed(int client, int args)
{
	if(args == 1)
	{
		GameSpeed = GetCmdArgFloat(1);
		ReplyToCommand(client, "Set the game speed to %.2f", GameSpeed);
	}
	else
	{
		ReplyToCommand(client, "[SM] Usage: rts_setspeed <timescale>");
	}

	return Plugin_Handled;
}
