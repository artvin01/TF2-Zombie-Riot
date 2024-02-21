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
	Resource_None = 0,
	Resource_Wood = 1,
	Resource_Gold = 2,
	Resource_Food = 3
}

public const char ResourceName[][] =
{
	"None",
	"Wood",
	"Gold",
	"Food"
};

enum
{
	Command_Idle = 0,
	Command_Move,
	Command_Attack,
	Command_HoldPos,
	Command_Patrol,
	Command_WorkOn
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

int BuildMode[MAXTF2PLAYERS];

#include "fortress_wars/object.sp"
#include "fortress_wars/npc.sp"	// Global NPC List
#include "fortress_wars/menu.sp"

static bool InSetup;
static int AlliedTeams[MAX_TEAMS];
static int AllowControls[MAX_TEAMS];
static bool Defeated[MAX_TEAMS];
static float GameSpeed = 0.5;

void RTS_PluginStart()
{
	Defeated[0] = true;
	
	RegAdminCmd("rts_setspeed", CommandSetSpeed, ADMFLAG_RCON, "Set the game speed");

	LoadTranslations("realtime.unitnames.phrases");

	Object_PluginStart();
}

void RTS_MapStart()
{
	
}

void RTS_PluginEnd()
{
	Object_PluginEnd();
}

void RTS_ClientDisconnect(int client)
{
	RTSMenu_ClientDisconnect(client);

	TeamNumber[client] = 0;
	BuildMode[client] = 0;
}

void RTS_ConfigsSetup()
{
	// DEBUG
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
			TeamNumber[client] = (client % MAX_TEAMS);
	}
	// DEBUG
}

void RTS_PlayerResupply(int client)
{
	// DEBUG
	TeamNumber[client] = (client % MAX_TEAMS);
	// DEBUG
/*
	if(!RTS_InSetup())
	{
		TF2_RemoveAllWeapons(client);
		int active = SpawnWeapon(client, "tf_weapon_pistol", 209, 1, 0, {128, 301, 821, 2}, {1.0, 1.0, 1.0, 0.0}, 4);
		int last = SpawnWeapon(client, "tf_weapon_wrench", 197, 1, 0, {128, 821, 2}, {1.0, 1.0, 0.0}, 3);

		TF2Util_SetPlayerActiveWeapon(client, active);
		SetEntPropEnt(client, Prop_Send, "m_hLastWeapon", last);
	}
*/
}

void RTS_PlayerRunCmd(int client)
{
	RTSMenu_PlayerRunCmd(client);
}

bool RTS_InSetup()
{
	return InSetup;
}

float RTS_GameSpeed()
{
	return GameSpeed;
}

bool RTS_IsSpectating(int client)
{
	if(TeamNumber[client] < 0)
		return true;
	
	return Defeated[TeamNumber[client]];
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
