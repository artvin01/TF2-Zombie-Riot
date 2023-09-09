#pragma semicolon 1
#pragma newdecls required

enum struct KillFeed
{
	int attacker;
	char attacker_name[96];
	int attacker_team;

	int userid;
	char victim_name[96];
	int victim_team;

	int assister;
	//char assister_name[96];
	//int assister_team;

	int weaponid;
	char weapon[32];
	int weapon_def_index;
	int damagebits;
	int inflictor_entindex;
	int customkill;
	bool silent_kill;
}

static const char BuildingName[][] =
{
	"Building",
	"Barricade",
	"Elevation",
	"AmmoBox",
	"Armortable",
	"Perk Machine",
	"Pack-a-Punch",
	"Railgun",
	"Sentry",
	"Mortar",
	"Healing Station",
	"Barracks"
};

static int Bots[2];
static int ForceTeam[MAXTF2PLAYERS];
static char KillIcon[MAXENTITIES][32];
static ArrayList FeedList;
static Handle FeedTimer;

void AdjustBotCount()
{
	int botcount = 0;
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsFakeClient(client))
		{
			botcount += 1;
			if(botcount > 2)
			{
				botcount -= 1;
				KickClient(client);
			}
		}
	}
	for(int loop = 1; loop <= 20; loop++)
	{
		if(botcount < 2)
		{
			SpawnBotCustom("bot1", true);
			botcount++;	
		}
		else
		{
			break;
		}
	}
}
void KillFeed_PluginStart()
{
	FeedList = new ArrayList(sizeof(KillFeed));


	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsFakeClient(client))
		{
			for(int i; i < sizeof(Bots); i++)
			{
				if(!Bots[i])
				{
					Bots[i] = client;
					break;
				}
			}
		}
	}
}

void KillFeed_ClientPutInServer(int client)
{
	if(IsFakeClient(client))
	{
		ForceTeam[client] = 3;
	
		for(int i; i < sizeof(Bots); i++)
		{
			if(!Bots[i])
			{
				Bots[i] = client;
				break;
			}
		}
	}
}

void KillFeed_ClientDisconnect(int client)
{
	for(int i; i < sizeof(Bots); i++)
	{
		if(Bots[i] == client)
		{
			// Shift Array
			for(int a = (i + 1); a < sizeof(Bots); a++)
			{
				Bots[a - 1] = Bots[a];
			}

			// Replace "Bot"
			Bots[sizeof(Bots) - 1] = 0;
			for(int target = 1; target <= MaxClients; target++)
			{
				if(client != target)
				{
					bool found;
					for(int a; a < (sizeof(Bots) - 1); a++)
					{
						if(target == Bots[i])
						{
							found = true;
							break;
						}
					}

					if(!found && IsClientInGame(target) && IsFakeClient(target))
					{
						Bots[sizeof(Bots) - 1] = target;
						break;
					}
				}
			}

			break;
		}
	}
}

void KillFeed_EntityCreated(int entity)
{
	KillIcon[entity][0] = 0;
}

void KillFeed_SetKillIcon(int entity, const char[] icon)
{
	strcopy(KillIcon[entity], sizeof(KillIcon[]), icon);
}

int KillFeed_GetBotTeam(int client)
{
	return ForceTeam[client];
}

void KillFeed_SetBotTeam(int client, int team)
{
	ForceTeam[client] = team;
	ChangeClientTeam(client, team);
}

#if defined ZR
static bool BuildingFullName(int entity, char[] buffer, int length)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
	if(owner < 1 || owner > MaxClients || !IsClientInGame(owner))
		return false;

	int index = i_WhatBuilding[entity];
	if(index >= sizeof(BuildingName))
		index = 0;
	
	Format(buffer, length, "%s (%N)", BuildingName[index], owner);
	return true;
}
#endif

void KillFeed_Show(int victim, int inflictor, int attacker, int lasthit, int weapon, int damagetype, bool silent = false)
{
	int botNum;
	KillFeed feed;

	if(victim <= MaxClients)
	{
		feed.userid = GetClientUserId(victim);
	}
	else if(!b_NpcHasDied[victim])
	{
		if(b_NoKillFeed[victim] || !Bots[botNum])
			return;
		
		feed.userid = GetClientUserId(Bots[botNum]);
		feed.victim_team = GetEntProp(victim, Prop_Send, "m_iTeamNum");
		strcopy(feed.victim_name, sizeof(feed.victim_name), NPC_Names[i_NpcInternalId[victim]]);
		
		botNum++;

#if defined ZR
		if(i_HasBeenHeadShotted[victim])
		{
			feed.customkill = TF_CUSTOM_HEADSHOT;
		}
		else if(i_HasBeenBackstabbed[victim])
		{
			feed.customkill = TF_CUSTOM_BACKSTAB;
		}
#endif

	}
#if defined ZR
	else if(i_IsABuilding[victim])
	{
		if(!Bots[botNum])
			return;
		
		if(!BuildingFullName(victim, feed.victim_name, sizeof(feed.victim_name)))
			return;
		
		feed.userid = GetClientUserId(Bots[botNum]);
		feed.victim_team = GetEntProp(victim, Prop_Send, "m_iTeamNum");
		botNum++;
	}
#endif
	else
	{
		return;
	}
	
	if(attacker < 1 && lasthit > 0)
	{
		// Killed by hazard
		attacker = lasthit;
		lasthit = -69;
	}
	
	if(attacker > 0)
	{
		if(attacker <= MaxClients)
		{
			feed.attacker = GetClientUserId(attacker);
		}
		else if(!b_NpcHasDied[attacker])
		{
			if(!Bots[botNum])
				return;
			
			feed.attacker = GetClientUserId(Bots[botNum]);
			feed.attacker_team = GetEntProp(attacker, Prop_Send, "m_iTeamNum");
			strcopy(feed.attacker_name, sizeof(feed.attacker_name), NPC_Names[i_NpcInternalId[attacker]]);
			
			botNum++;
		}
#if defined ZR
		else if(i_IsABuilding[attacker])
		{
			feed.attacker = -1;
		}
#endif
	}

	if(lasthit > 0)
	{
		if(attacker == lasthit)
		{
			// Self last hit
			feed.assister = -1;
		}
		else
		{
			// Assister
			feed.assister = GetClientUserId(lasthit);
		}
	}
	else if(lasthit == -69)
	{
		// "Finished off"
		feed.assister = -1;

#if defined ZR
		if(i_IsABuilding[victim])
		{
			feed.customkill = TF_CUSTOM_CARRIED_BUILDING;
			strcopy(feed.weapon, sizeof(feed.weapon), "building_carried_destroyed");
		}
		else
#endif
		{
			feed.customkill = TF_CUSTOM_SUICIDE;
		}

		if(!feed.attacker)
			feed.attacker = feed.userid;
	}
	else if(attacker > MaxClients && attacker != victim)
	{
		// NPC did a solo
		feed.assister = -1;
	}
	else if(victim > MaxClients)
	{
		// "Finished off"
		feed.assister = -1;
		feed.customkill = TF_CUSTOM_SUICIDE;
		if(!feed.attacker)
			feed.attacker = feed.userid;
	}

	feed.weaponid = weapon;
	feed.damagebits = damagetype;
	feed.silent_kill = silent;
	
	if(inflictor > MaxClients)
	{
		// NPC/Building's Icon

		feed.inflictor_entindex = inflictor;
		feed.weapon_def_index = -1;

		if(lasthit != -69)
			strcopy(feed.weapon, sizeof(feed.weapon), KillIcon[inflictor]);
	}
	else if(weapon > MaxClients)
	{
		// Weapon's Icon

		feed.inflictor_entindex = weapon;
		feed.weapon_def_index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");

		if(lasthit != -69)
		{
			if(KillIcon[weapon][0])
			{
				strcopy(feed.weapon, sizeof(feed.weapon), KillIcon[weapon]);
			}
			else
			{
				TF2Econ_GetItemDefinitionString(feed.weapon_def_index, "item_iconname", feed.weapon, sizeof(feed.weapon));
			}
		}
	}

	FeedList.PushArray(feed);

	if(!FeedTimer)
		ShowNextFeed();
}

static void ShowNextFeed()
{
	if(FeedList.Length)
	{
		KillFeed feedmain, feed;
		FeedList.GetArray(0, feedmain);
		FeedList.GetArray(0, feed);

		int victim = GetClientOfUserId(feed.userid);
		int attacker = GetClientOfUserId(feed.attacker);

		bool botUsed;
		if(feed.victim_name[0] && victim)
		{
			char buffer[64];
			GetClientName(victim, buffer, sizeof(buffer));
			if(!StrEqual(buffer, feed.victim_name) || GetClientTeam(victim) != feed.victim_team)
			{
				SetClientName(victim, feed.victim_name);
				SetEntPropString(victim, Prop_Data, "m_szNetname", feed.victim_name);
				KillFeed_SetBotTeam(victim, feed.victim_team);
				botUsed = true;
			}
		}

		if(feed.attacker_name[0] && attacker)
		{
			char buffer[64];
			GetClientName(attacker, buffer, sizeof(buffer));
			if(!StrEqual(buffer, feed.attacker_name) || GetClientTeam(attacker) != feed.attacker_team)
			{
				SetClientName(attacker, feed.attacker_name);
				SetEntPropString(attacker, Prop_Data, "m_szNetname", feed.attacker_name);
				KillFeed_SetBotTeam(attacker, feed.attacker_team);
				botUsed = true;
			}
		}

		ArrayList list = new ArrayList();

		do
		{
			FeedList.Erase(0);

			Event event = CreateEvent("player_death", true);

			event.SetInt("attacker", feed.attacker);
			event.SetInt("userid", feed.userid);
			event.SetInt("victim_entindex", victim);
			event.SetInt("assister", feed.assister);
			event.SetInt("weaponid", feed.weaponid);
			event.SetString("weapon", feed.weapon);
			event.SetInt("weapon_def_index", feed.weapon_def_index);
			event.SetInt("damagebits", feed.damagebits);
			event.SetInt("inflictor_entindex", feed.inflictor_entindex);
			event.SetInt("customkill", feed.customkill);
			event.SetBool("silent_kill", feed.silent_kill);

			list.Push(event);

			if(!FeedList.Length)
				break;
			
			// Add anything using the same team/name
			FeedList.GetArray(0, feed);
		}
		while(feed.victim_team == feedmain.victim_team &&
			feed.attacker_team == feedmain.attacker_team &&
			StrEqual(feed.victim_name, feedmain.victim_name) &&
			StrEqual(feed.attacker_name, feedmain.attacker_name));

		// Need time to change the bot's display name
		FeedTimer = CreateTimer(botUsed ? 0.2 : 0.0, KillFeed_ShowTimer, list, TIMER_DATA_HNDL_CLOSE);
	}
}

public Action KillFeed_ShowTimer(Handle timer, ArrayList list)
{
	FeedTimer = null;

	int length = list.Length;
	for(int i; i < length; i++)
	{
		Event event = list.Get(i);

		if(event.GetBool("silent_kill"))
		{
			int victim = GetClientOfUserId(event.GetInt("userid"));
			int attacker = GetClientOfUserId(event.GetInt("attacker"));

			if(victim)
				event.FireToClient(victim);
			
			if(attacker)
				event.FireToClient(attacker);
		}
		else
		{
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client))
					event.FireToClient(client);
			}
		}

		event.Cancel();
	}

	FeedTimer = CreateTimer(0.2, KillFeed_NextTimer);
	return Plugin_Continue;
}

public Action KillFeed_NextTimer(Handle timer)
{
	FeedTimer = null;
	ShowNextFeed();
	return Plugin_Continue;
}