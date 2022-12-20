#pragma semicolon 1
#pragma newdecls required

#define ITEM_CASH	"Credits"
#define ITEM_XP		"XP"
#define ITEM_TIER	"Elite Promotion"

int Tier[MAXTF2PLAYERS];
int Level[MAXENTITIES];
int XP[MAXENTITIES];

char StoreWeapon[MAXENTITIES][48];
int i_TagColor[MAXTF2PLAYERS][4];
char c_TagName[MAXTF2PLAYERS][64];
int b_BrushToOwner[MAXENTITIES];
int b_OwnerToBrush[MAXENTITIES];

bool b_NpcIsInADungeon[MAXENTITIES];

float f_HealingPotionDuration[MAXTF2PLAYERS];
int f_HealingPotionEffect[MAXTF2PLAYERS];

#include "rpg_fortress/npc.sp"	// Global NPC List

#include "rpg_fortress/ammo.sp"
#include "rpg_fortress/crafting.sp"
#include "rpg_fortress/fishing.sp"
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

#include "rpg_fortress/custom/wand/weapon_default_wand.sp"
#include "rpg_fortress/custom/wand/weapon_fire_wand.sp"
#include "rpg_fortress/custom/wand/weapon_lightning_wand.sp"
#include "rpg_fortress/custom/wand/weapon_wand_fire_ball.sp"
#include "rpg_fortress/custom/potion_healing_effects.sp"
#include "rpg_fortress/custom/ranged_mortar_strike.sp"
#include "rpg_fortress/custom/ground_pound_melee.sp"

void RPG_PluginStart()
{
	LoadTranslations("rpgfortress.phrases.enemynames");
	
	Ammo_PluginStart();
	Fishing_PluginStart();
	Store_Reset();
	Levels_PluginStart();
	Party_PluginStart();
	Stats_PluginStart();
	TextStore_PluginStart();
	Zones_PluginStart();

	CountPlayersOnRed();
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
}

void RPG_MapEnd()
{
	Spawns_MapEnd();
}

void RPG_PutInServer()
{
	CountPlayersOnRed();
}

void RPG_ClientCookiesCached(int client)
{
	Ammo_ClientCookiesCached(client);
}

void RPG_ClientDisconnect(int client)
{
	UpdateLevelAbovePlayerText(client, true);
	Ammo_ClientDisconnect(client);
	Fishing_ClientDisconnect(client);
	Party_ClientDisconnect(client);
}

void RPG_ClientDisconnect_Post()
{
	CountPlayersOnRed();
}

void RPG_EntityCreated(int entity)
{
	b_NpcIsInADungeon[entity] = false;
	StoreWeapon[entity][0] = 0;
	Stats_ClearCustomStats(entity);
}