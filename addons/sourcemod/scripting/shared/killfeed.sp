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

static int Bots[2];
static int ForceTeam[MAXPLAYERS];
static char KillIcon[MAXENTITIES][32];
static ArrayList LowList;
static ArrayList HighList;
static Handle FeedTimer;

void AdjustBotCount()
{
	int CurrentPlayersActive = 0;
	//We are a real player
	for(int clientl = 1; clientl <= MaxClients; clientl++)
	{
		if(IsClientInGame(clientl) && !IsClientSourceTV(clientl))
			CurrentPlayersActive++; //includes bot, doesnt include sourcetv
	}
	if((MaxClients - 2) <= CurrentPlayersActive)
	{
		for(int botcheck = 1; botcheck <= MaxClients; botcheck++)
		{
			if(IsClientInGame(botcheck) && IsFakeClient(botcheck) && !IsClientSourceTV(botcheck))
			{
				//Kick all bots	
				KickClient(botcheck);
			}
		}
	}
	return;
}

void KillFeed_PluginStart()
{
	LowList = new ArrayList(sizeof(KillFeed));
	HighList = new ArrayList(sizeof(KillFeed));

	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
			KillFeed_ClientPutInServer(client);
	}
}

void KillFeed_ClientPutInServer(int client)
{
	if(IsFakeClient(client))
	{
		ForceTeam[client] = IsClientSourceTV(client) ? TFTeam_Spectator : TFTeam_Blue;
	
		for(int i; i < sizeof(Bots); i++)
		{
			if(!Bots[i] || IsClientSourceTV(Bots[i]))
			{
				Bots[i] = client;
				break;
			}
		}
	}
}

/*
#if defined ZR
void MoveBotToSpectator(int client)
{
	if(FeedTimer == null && GetTeam(client) == TFTeam_Red)
	{
		f_ClientMusicVolume[client] = 1.0;
		f_ZombieVolumeSetting[client] = 0.0;
		SetTeam(client, TFTeam_Spectator);
		b_IsPlayerABot[client] = true;
	}
}
#endif
*/

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

stock void KillFeed_SetKillIcon(int entity, const char[] icon)
{
	strcopy(KillIcon[entity], sizeof(KillIcon[]), icon);
}

int KillFeed_GetBotTeam(int client)
{
	return ForceTeam[client];
}

stock void KillFeed_ForceClear()
{
	LowList.Clear();
	HighList.Clear();
}

void KillFeed_SetBotTeam(int client, int team)
{
	if(IsClientSourceTV(client))
		return;
	
	int teamSet = team;

	if(teamSet < TFTeam_Unassigned)
		teamSet = TFTeam_Unassigned;
	if(teamSet > TFTeam_Blue)
		teamSet = TFTeam_Blue;
	ForceTeam[client] = teamSet;
	
	SetTeam(client, teamSet);
}

#if defined ZR
static bool BuildingFullName(int entity, char[] buffer, int length)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(owner < 1 || owner > MaxClients || !IsClientInGame(owner))
		return false;

	Format(buffer, length, "%s (%N)", c_NpcName[owner], owner);
	return true;
}
#endif

void KillFeed_Show(int victim, int inflictor, int attacker, int lasthit, int weapon, int damagetype, bool silent = false)
{
	int botNum;
	bool priority, players;
	KillFeed feed;

	if(victim <= MaxClients)
	{
		feed.userid = GetClientUserId(victim);

		priority = true;
		players = true;
	}
	else if(!b_NpcHasDied[victim])
	{
		if(b_NoKillFeed[victim] || !Bots[botNum])
			return;
		
		feed.userid = GetClientUserId(Bots[botNum]);
		feed.victim_team = GetTeam(victim);
		strcopy(feed.victim_name, sizeof(feed.victim_name), c_NpcName[victim]);
		
		botNum++;

#if defined ZR
		priority = feed.victim_team != TFTeam_Blue;
		
		if(b_thisNpcIsABoss[victim] || b_thisNpcIsARaid[victim])
			priority = true;

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
		feed.victim_team = GetTeam(victim);
		botNum++;

		priority = true;
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
			players = true;
		}
		else if(!b_NpcHasDied[attacker])
		{
			if(Bots[botNum])
			{
				feed.attacker = GetClientUserId(Bots[botNum]);
				feed.attacker_team = GetTeam(attacker);
				strcopy(feed.attacker_name, sizeof(feed.attacker_name), c_NpcName[attacker]);
				
				botNum++;
			}
			else
			{
				feed.attacker = -1;
			}
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
			players = true;
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

	// Don't show a kill feed that nobody is going to see
	if(!priority && !players)
		return;

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
	else if(weapon > MaxClients && i_CustomWeaponEquipLogic[weapon] != -1)
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

	if(priority)
	{
		HighList.PushArray(feed);
	}
	else
	{
		if(LowList.PushArray(feed) > 49)
			LowList.Erase(0);	// Too much queued, kill oldest
	}

	if(!FeedTimer)
		ShowNextFeed();
}

static void ShowNextFeed()
{
	int lowLength = LowList.Length;
	int highLength = HighList.Length;
	if(lowLength || highLength)
	{
		bool priority;

		KillFeed feedmain, feed;
		if(highLength)
		{
			HighList.GetArray(0, feed);
			feedmain = feed;
			priority = true;
		}
		else
		{
			LowList.GetArray(0, feed);
			feedmain = feed;
		}

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
		else
		{
			priority = true;
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
			if(HighList.Length)
			{
				HighList.Erase(0);
			}
			else
			{
				LowList.Erase(0);
			}

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
			event.SetBool("silent_kill", (!priority || feed.silent_kill));

			list.Push(event);

			// Add anything using the same team/name
			if(!HighList.Length)
			{
				if(!LowList.Length)
				{
					break;
				}
				else
				{
					LowList.GetArray(0, feed);
				}
			}
			else
			{
				HighList.GetArray(0, feed);
			}
		}
		while((!feed.victim_name[0] || (feed.victim_team == feedmain.victim_team && StrEqual(feed.victim_name, feedmain.victim_name))) &&
			(!feed.attacker_name[0] || (feed.attacker_team == feedmain.attacker_team && StrEqual(feed.attacker_name, feedmain.attacker_name))));

		// Need time to change the bot's display name
		FeedTimer = CreateTimer(botUsed ? 0.3 : 0.0, KillFeed_ShowTimer, list, TIMER_DATA_HNDL_CLOSE);
	}
}

public Action KillFeed_ShowTimer(Handle timer, ArrayList list)
{
	FeedTimer = null;

	int length = list.Length;
	for(int i; i < length; i++)
	{
		Event event = list.Get(i);
		int victim = GetClientOfUserId(event.GetInt("userid"));
		int attacker = GetClientOfUserId(event.GetInt("attacker"));
		int assister = GetClientOfUserId(event.GetInt("assister"));

		if(event.GetBool("silent_kill"))
		{
			event.SetBool("silent_kill", false);

#if defined RPG
			bool hasVictim = IsValidClient(victim) && !IsFakeClient(victim);
			bool hasAttacker = IsValidClient(attacker) && !IsFakeClient(attacker);
			bool hasAssister = IsValidClient(assister) && !IsFakeClient(assister);
			for(int target = 1; target <= MaxClients; target++)
			{
				if(target == victim || target == attacker || target == assister ||
				  (hasVictim && Party_IsClientMember(target, victim)) ||
				  (hasAttacker && Party_IsClientMember(target, attacker)) ||
				  (hasAssister && Party_IsClientMember(target, assister)))
				{
					event.FireToClient(target);
				}
			}
#else
			if(victim)
				event.FireToClient(victim);
			
			if(attacker)
				event.FireToClient(attacker);
			
			if(assister)
				event.FireToClient(assister);
#endif
		}
		else
		{
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client))
					event.FireToClient(client);
			}
		}

		if(IsValidClient(victim) && IsFakeClient(victim))
			KillFeed_SetBotTeam(victim, TFTeam_Blue);
		
		if(IsValidClient(attacker) && IsFakeClient(attacker))
			KillFeed_SetBotTeam(attacker, TFTeam_Blue);
		
		if(IsValidClient(assister) && IsFakeClient(assister))
			KillFeed_SetBotTeam(assister, TFTeam_Blue);

		event.Cancel();
	}
	
	FeedTimer = CreateTimer(0.3, KillFeed_NextTimer);
	return Plugin_Continue;
}

public Action KillFeed_NextTimer(Handle timer)
{
	FeedTimer = null;
	ShowNextFeed();
	return Plugin_Continue;
}