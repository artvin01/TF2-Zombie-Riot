#pragma semicolon 1
#pragma newdecls required

#define ITEM_CASH	"Credits"
#define ITEM_XP		"XP"
#define ITEM_TIER	"Elite Promotion"

bool DisabledDownloads[MAXTF2PLAYERS];

int Tier[MAXTF2PLAYERS];
int Level[MAXENTITIES];
int XP[MAXENTITIES];

char StoreWeapon[MAXENTITIES][48];
int i_TagColor[MAXTF2PLAYERS][4];
char c_TagName[MAXTF2PLAYERS][64];
int b_BrushToOwner[MAXENTITIES];
int b_OwnerToBrush[MAXENTITIES];
float Animal_Happy[MAXTF2PLAYERS][10][3];

bool b_NpcIsInADungeon[MAXENTITIES];
int i_NpcFightOwner[MAXENTITIES];
float f_NpcFightTime[MAXENTITIES];
float f_SingerBuffedFor[MAXENTITIES];

float f_HealingPotionDuration[MAXTF2PLAYERS];
int f_HealingPotionEffect[MAXTF2PLAYERS];

//CC CONTRACT DIFFICULTIES!
bool b_DungeonContracts_LongerCooldown[MAXTF2PLAYERS];
bool b_DungeonContracts_SlowerAttackspeed[MAXTF2PLAYERS];
bool b_DungeonContracts_SlowerMovespeed[MAXTF2PLAYERS];
//bool b_DungeonContracts_BleedOnHit[MAXTF2PLAYERS]; Global inside core.sp

#include "rpg_fortress/npc.sp"	// Global NPC List

#include "rpg_fortress/ammo.sp"
#include "rpg_fortress/crafting.sp"
#include "rpg_fortress/dungeon.sp"
#include "rpg_fortress/fishing.sp"
#include "rpg_fortress/games.sp"
#include "rpg_fortress/garden.sp"
#include "rpg_fortress/levels.sp"
#include "rpg_fortress/mining.sp"
#include "rpg_fortress/music.sp"
#include "rpg_fortress/party.sp"
#include "rpg_fortress/quests.sp"
#include "rpg_fortress/spawns.sp"
#include "rpg_fortress/stats.sp"
#include "rpg_fortress/textstore.sp"
#include "rpg_fortress/tinker.sp"
#include "rpg_fortress/zones.sp"
#include "rpg_fortress/npc_despawn_zone.sp"

#include "rpg_fortress/custom/wand/weapon_default_wand.sp"
#include "rpg_fortress/custom/wand/weapon_fire_wand.sp"
#include "rpg_fortress/custom/wand/weapon_lightning_wand.sp"
#include "rpg_fortress/custom/wand/weapon_wand_fire_ball.sp"
#include "rpg_fortress/custom/potion_healing_effects.sp"
#include "rpg_fortress/custom/ranged_mortar_strike.sp"
#include "rpg_fortress/custom/ground_pound_melee.sp"
#include "rpg_fortress/custom/weapon_boom_stick.sp"
#include "rpg_fortress/custom/accesorry_mudrock_shield.sp"
#include "shared/custom/joke_medigun_mod_drain_health.sp"
#include "rpg_fortress/custom/wand/weapon_arts_wand.sp"

void RPG_PluginStart()
{
	Ammo_PluginStart();
	Dungeon_PluginStart();
	Fishing_PluginStart();
	Games_PluginStart();
	Store_Reset();
	Levels_PluginStart();
	Party_PluginStart();
	Spawns_PluginStart();
	Stats_PluginStart();
	TextStore_PluginStart();
	Zones_PluginStart();

	CountPlayersOnRed();
	Medigun_PluginStart();
}

void RPG_PluginEnd()
{
	char buffer[64];
	for(int i=MAXENTITIES; i>MaxClients; i--)
	{
		if(IsValidEntity(i) && GetEntityClassname(i, buffer, sizeof(buffer)))
		{
			if(StrEqual(buffer, "base_boss"))
			{
				NPC_Despawn(i);
				continue;
			}
			else if(!StrContains(buffer, "prop_dynamic") || !StrContains(buffer, "point_worldtext") || !StrContains(buffer, "info_particle_system"))
			{
				GetEntPropString(i, Prop_Data, "m_iName", buffer, sizeof(buffer));
				if(!StrEqual(buffer, "rpg_fortress"))
					continue;
			}
			else if(!StrContains(buffer, "prop_physics"))
			{
				GetEntPropString(i, Prop_Data, "m_iName", buffer, sizeof(buffer));
				if(StrContains(buffer, "rpg_item"))
					continue;
			}
			else
			{
				continue;
			}

			RemoveEntity(i);
		}
	}
}

void RPG_MapStart()
{
	HealingPotion_Map_Start();
	Fishing_OnMapStart();
	Zero2(f3_SpawnPosition);
	Wand_Map_Precache();
	Wand_Fire_Map_Precache();
	Wand_Lightning_Map_Precache();
	GroundSlam_Map_Precache();
	Wand_FireBall_Map_Precache();
	Mortar_MapStart();
	BoomStick_MapPrecache();
	Medigun_PersonOnMapStart();
	Abiltity_Mudrock_Shield_Shield_PluginStart();
	Wand_Arts_MapStart();
}

void RPG_MapEnd()
{
	Spawns_MapEnd();
}

void RPG_PutInServer(int client)
{
	CountPlayersOnRed();

	int userid = GetClientUserId(client);
	QueryClientConVar(client, "cl_allowdownload", OnQueryFinished, userid);
	QueryClientConVar(client, "cl_downloadfilter", OnQueryFinished, userid);
}

public void OnQueryFinished(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, int userid)
{
	if(result == ConVarQuery_Okay && GetClientOfUserId(userid) == client)
	{
		if(StrEqual(cvarName, "cl_allowdownload"))
		{
			if(!StringToInt(cvarValue))
				DisabledDownloads[client] = true;
		}
		else if(StrEqual(cvarName, "cl_downloadfilter"))
		{
			if(StrContains("all", cvarValue) == -1)
				DisabledDownloads[client] = true;
		}
	}
}

void RPG_ClientCookiesCached(int client)
{
	Ammo_ClientCookiesCached(client);
	Stats_ClientCookiesCached(client);
}

void RPG_ClientDisconnect(int client)
{
	for(int loop1; loop1 < sizeof(Animal_Happy[]); loop1++)
	{
		for(int loop2; loop2 < sizeof(Animal_Happy[][]); loop2++)
		{
			Animal_Happy[client][loop1][loop2] = 0.0;
		}
	}

	DisabledDownloads[client] = false;

	UpdateLevelAbovePlayerText(client, true);
	Ammo_ClientDisconnect(client);
	Dungeon_ClientDisconnect(client);
	Fishing_ClientDisconnect(client);
	Music_ClientDisconnect(client);
	Party_ClientDisconnect(client);
	Stats_ClientDisconnect(client);
	TextStore_ClientDisconnect(client);
	MudrockShieldDisconnect(client);
}

void RPG_ClientDisconnect_Post()
{
	CountPlayersOnRed();
}

void RPG_EntityCreated(int entity, const char[] classname)
{
	b_NpcIsInADungeon[entity] = false;
	i_NpcFightOwner[entity] = false;
	f_SingerBuffedFor[entity] = 0.0;
	StoreWeapon[entity][0] = 0;
	Dungeon_ResetEntity(entity);
	Stats_ClearCustomStats(entity);
	Zones_EntityCreated(entity, classname);
}

void RPG_PlayerRunCmdPost(int client)
{
	TextStore_PlayerRunCmd(client);
	Fishing_PlayerRunCmd(client);
	Garden_PlayerRunCmd(client);
	Music_PlayerRunCmd(client);
}

void RPG_UpdateHud(int client)
{
	Stats_UpdateHud(client);
}

public void CheckAlivePlayersforward(int killed)
{
	CheckAlivePlayers(killed);
}

void CheckAlivePlayers(int killed = 0)
{
	Dungeon_CheckAlivePlayers(killed);
}