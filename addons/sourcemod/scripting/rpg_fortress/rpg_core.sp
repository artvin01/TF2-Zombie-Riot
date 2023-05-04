#pragma semicolon 1
#pragma newdecls required

#define ITEM_CASH	"Credits"
#define ITEM_XP		"XP"
#define ITEM_TIER	"Elite Promotion"
#define MIN_FADE_DISTANCE 3000.0
#define MAX_FADE_DISTANCE 3700.0

enum
{
	WEAPON_STUNSTICK = 1,
	WEAPON_SILENCESTICK = 2
}

bool DisabledDownloads[MAXTF2PLAYERS];

int Tier[MAXTF2PLAYERS];
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

Cookie Niko_Cookies;
Cookie HudSettings_Cookies;
Cookie HudSettingsExtra_Cookies;

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
#include "rpg_fortress/traffic.sp"
#include "rpg_fortress/zones.sp"
#include "rpg_fortress/npc_despawn_zone.sp"

#include "rpg_fortress/custom/wand/weapon_default_wand.sp"
#include "rpg_fortress/custom/wand/weapon_fire_wand.sp"
#include "rpg_fortress/custom/wand/weapon_lightning_wand.sp"
#include "rpg_fortress/custom/wand/weapon_wand_fire_ball.sp"
#include "rpg_fortress/custom/wand/weapon_short_teleport.sp"
#include "rpg_fortress/custom/wand/weapon_icicles.sp"
#include "rpg_fortress/custom/potion_healing_effects.sp"
#include "rpg_fortress/custom/ranged_mortar_strike.sp"
#include "rpg_fortress/custom/ground_beserkhealtharmor.sp"	
#include "rpg_fortress/custom/ground_aircutter.sp"	
#include "rpg_fortress/custom/ranged_quick_reflex.sp"
#include "rpg_fortress/custom/ranged_sentrythrow.sp"
#include "rpg_fortress/custom/ground_pound_melee.sp"
#include "rpg_fortress/custom/weapon_boom_stick.sp"
#include "rpg_fortress/custom/accesorry_mudrock_shield.sp"
#include "shared/custom/joke_medigun_mod_drain_health.sp"
#include "rpg_fortress/custom/wand/weapon_arts_wand.sp"
#include "rpg_fortress/custom/weapon_semi_auto.sp"
#include "rpg_fortress/custom/wand/weapon_sword_wand.sp"

void RPG_PluginStart()
{
	HudSettings_Cookies = new Cookie("zr_hudsetting", "hud settings", CookieAccess_Protected);
	HudSettingsExtra_Cookies = new Cookie("zr_hudsettingextra", "hud settings Extra", CookieAccess_Protected);
	Niko_Cookies = new Cookie("zr_niko", "Are you a niko", CookieAccess_Protected);

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
	Traffic_PluginStart();
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

	Party_PluginEnd();
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
	Wand_Short_Teleport_Map_Precache();
	Mortar_MapStart();
	BoomStick_MapPrecache();
	Medigun_PersonOnMapStart();
	Abiltity_Mudrock_Shield_Shield_PluginStart();
	Wand_Arts_MapStart();

	RpgPluginStart_Store();
	Wand_IcicleShard_Map_Precache();
	SentryThrow_MapStart();
	QuickReflex_MapStart();
	BeserkerRageGain_Map_Precache();
	AirCutter_Map_Precache();

	
	CreateTimer(2.0, CheckClientConvars, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

void RPG_MapEnd()
{
	Spawns_MapEnd();
}

void RPG_PutInServer(int client)
{
	CountPlayersOnRed();
	AdjustBotCount();

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
	HudSettings_ClientCookiesCached(client);
	Stats_ClientCookiesCached(client);
	ThirdPerson_OnClientCookiesCached(client);

	char buffer[4];
	Niko_Cookies.Get(client, buffer, sizeof(buffer));
	if(StringToInt(buffer) == 1)
	{
	 	b_IsPlayerNiko[client] = true;
	}
	else
	{
		b_IsPlayerNiko[client] = false;
	}
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

	int niko_int = 0;
		
	if(b_IsPlayerNiko[client])
		niko_int = 1;

	char buffer[128];		
	IntToString(niko_int, buffer, sizeof(buffer));
	Niko_Cookies.Set(client, buffer);

	FormatEx(buffer, sizeof(buffer), "%.3f;%.3f;%.3f;%.3f;%.3f;%.3f;%.3f;%.3f", f_ArmorHudOffsetX[client], f_ArmorHudOffsetY[client], f_HurtHudOffsetX[client], f_HurtHudOffsetY[client], f_WeaponHudOffsetX[client], f_WeaponHudOffsetY[client], f_NotifHudOffsetX[client], f_NotifHudOffsetY[client]);
	HudSettings_Cookies.Set(client, buffer);

	FormatEx(buffer, sizeof(buffer), "%b;%b;%b", b_HudScreenShake[client], b_HudLowHealthShake[client], b_HudHitMarker[client]);
	HudSettingsExtra_Cookies.Set(client, buffer);

	UpdateLevelAbovePlayerText(client, true);
	Ammo_ClientDisconnect(client);
	Dungeon_ClientDisconnect(client);
	Fishing_ClientDisconnect(client);
	Music_ClientDisconnect(client);
	Party_ClientDisconnect(client);
	Stats_ClientDisconnect(client);
	TextStore_ClientDisconnect(client);
	MudrockShieldDisconnect(client);
	BeserkHealthArmorDisconnect(client);
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


public Action CheckClientConvars(Handle timer)
{
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			if(IsPlayerAlive(client) && GetClientTeam(client)==3)
			{
				if(IsFakeClient(client))
				{
					KickClient(client);	
				}
				else
				{
					ClientCommand(client, "retry");
				}
			}
			else if(!IsFakeClient(client))
			{
				QueryClientConVar(client, "snd_musicvolume", ConVarCallback); //snd_musicvolume
				QueryClientConVar(client, "snd_ducktovolume", ConVarCallbackDuckToVolume); //snd_ducktovolume
			}
		}
	}
	return Plugin_Continue;
}

static void HudSettings_ClientCookiesCached(int client)
{
	char buffer[128];
	HudSettings_Cookies.Get(client, buffer, sizeof(buffer));
	if(buffer[0])
	{
		// Cookie has stuff, get values
		float buffers[8];
		ExplodeStringFloat(buffer, ";", buffers, sizeof(buffers));

		f_ArmorHudOffsetX[client] = buffers[0];
		f_ArmorHudOffsetY[client] = buffers[1];
		f_HurtHudOffsetX[client] = buffers[2];
		f_HurtHudOffsetY[client] = buffers[3];
		f_WeaponHudOffsetX[client] = buffers[4];
		f_WeaponHudOffsetY[client] = buffers[5];
		f_NotifHudOffsetX[client] = buffers[6];
		f_NotifHudOffsetY[client] = buffers[7];
	}
	else
	{
		// Cookie empty, get our own
		f_ArmorHudOffsetX[client] = -0.085;
		f_ArmorHudOffsetY[client] = 0.0;
		f_HurtHudOffsetX[client] = 0.0;
		f_HurtHudOffsetY[client] = 0.0;
		f_WeaponHudOffsetX[client] = 0.0;
		f_WeaponHudOffsetY[client] = 0.0;
		f_NotifHudOffsetX[client] = 0.0;
		f_NotifHudOffsetY[client] = 0.0;
	}
	HudSettingsExtra_Cookies.Get(client, buffer, sizeof(buffer));
	if(buffer[0])
	{
		// Cookie has stuff, get values
		bool buffers[3];
		ExplodeStringInt(buffer, ";", buffers, sizeof(buffers));
		b_HudScreenShake[client] = buffers[0];
		b_HudLowHealthShake[client] = buffers[1];
		b_HudHitMarker[client] = buffers[2];
	}
	else
	{
		// Cookie empty, get our own
		b_HudScreenShake[client] = true;
		b_HudLowHealthShake[client] = true;
		b_HudHitMarker[client] = true;
	}
}