#pragma semicolon 1
#pragma newdecls required

#define MIN_FADE_DISTANCE	9999.9
#define MAX_FADE_DISTANCE	9999.9

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
	Flag_Worker
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

#include "fortress_wars/npc.sp"	// Global NPC List

static bool InSetup;
static bool AlliedPlayer[MAXTF2PLAYERS][MAXTF2PLAYERS];
static bool AllowControl[MAXTF2PLAYERS][MAXTF2PLAYERS];
static int TeamColor[MAXTF2PLAYERS][3];
static float GameSpeed = 0.5;

void RTS_PluginStart()
{
	for(int i; i < sizeof(TeamColor); i++)
	{
		TeamColor[i][0] = 255;
		TeamColor[i][1] = 255;
		TeamColor[i][2] = 255;
	}
}

void RTS_PlayerResupply(int client)
{
	if(!RTS_InSetup())
	{
		TF2_RemoveAllWeapons(client);
		SpawnWeapon(client, "tf_weapon_shotgun_primary", 199, 1, 0, {128, 301, 821, 2}, {1.0, 1.0, 1.0, 0.0}, 4);
		int active = SpawnWeapon(client, "tf_weapon_pistol", 209, 1, 0, {128, 301, 821, 2}, {1.0, 1.0, 1.0, 0.0}, 4);
		SpawnWeapon(client, "tf_weapon_wrench", 197, 1, 0, {128, 821, 2}, {1.0, 1.0, 0.0}, 3);
		int last = SpawnWeapon(client, "tf_weapon_pda_engineer_build", 737, 1, 0, {81}, {0.0}, 1);

		TF2Util_SetPlayerActiveWeapon(client, active);
		SetEntPropEnt(client, Prop_Send, "m_hLastWeapon", last);
	}
}

bool RTS_PlayerRunCmd(int client, int &weapon)
{
	SetEntPropEnt(client, Prop_Send, "m_hLastWeapon", GetPlayerWeaponSlot(client, TFWeaponSlot_Grenade));
	
	if(weapon && weapon != GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary))
	{
		weapon = 0;
		return true;
	}

	return false;
}

bool RTS_InSetup()
{
	return InSetup;
}

float RTS_GameSpeed()
{
	return GameSpeed;
}

bool RTS_IsPlayerAlly(int attacker, int target)
{
	return attacker == target || AlliedPlayer[attacker][target];
}

bool RTS_CanPlayerControl(int attacker, int target)
{
	return attacker == target || AllowControl[attacker][target];
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
		
		int owner = UnitBody_GetOwner(npc.index);
		if(owner < 0 || owner > MaxClients)
			owner = 0;

		static int color[4] = {255, 255, 255, 255};
		color[0] = TeamColor[owner][0];
		color[1] = TeamColor[owner][1];
		color[2] = TeamColor[owner][2];

		textEntity = SpawnFormattedWorldText(display, offset, 17, color, npc.index);
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
