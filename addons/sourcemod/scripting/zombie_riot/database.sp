#pragma semicolon 1
#pragma newdecls required

#define DATABASE_LOCAL		"zr_local"
#define DATATABLE_MAIN		"zr_timestamp"
#define DATATABLE_AMMO		"zr_ammo"
#define DATATABLE_GAMEDATA	"zr_gamedata"

#define DATABASE_GLOBAL		"zr_global"
#define DATATABLE_LOADOUT	"zr_loadout"
#define DATATABLE_MISC		"zr_misc"
#define DATATABLE_SETTINGS	"zr_settings"

static Database Local;
static Database Global;
static bool Cached[MAXTF2PLAYERS];

void Database_PluginStart()
{
	char error[512];

	Database db = SQLite_UseDatabase(DATABASE_LOCAL, error, sizeof(error));
	Database_LocalConnected(db, error);
	
	Database.Connect(Database_GlobalConnected, DATABASE_GLOBAL);
}

bool Database_Escape(char[] buffer, int length, int &bytes)
{
	if(!Global)
		return false;
	
	bytes = Global.Format(buffer, length, "%s", buffer);
	return true;
}

public void Database_LocalSetup(Database db, any data, int numQueries, DBResultSet[] results, any[] queryData)
{
	Local = data;
	if(Global)
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientAuthorized(client))
				Database_ClientAuthorized(client);
		}
	}
}

public void Database_GlobalSetup(Database db, any data, int numQueries, DBResultSet[] results, any[] queryData)
{
	Global = data;
	if(Local)
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientAuthorized(client))
				Database_ClientAuthorized(client);
		}
	}
}

void Database_ClientAuthorized(int client)
{
	if(!IsFakeClient(client))
	{
		int id = GetSteamAccountID(client);
		if(id)
		{
			int userid = GetClientUserId(client);
			
			GlobalClientAuthorized(id, userid);
			LocalClientAuthorized(id, userid);
		}
	}
}

/*
	Global Database
*/

public void Database_GlobalConnected(Database db, const char[] error, any data)
{
	if(db)
	{
		Transaction tr = new Transaction();
		
		tr.AddQuery("CREATE TABLE IF NOT EXISTS " ... DATATABLE_LOADOUT ... " ("
		... "steamid INTEGER NOT NULL, "
		... "item TEXT NOT NULL, "
		... "loadout TEXT NOT NULL);");
		
		tr.AddQuery("CREATE TABLE IF NOT EXISTS " ... DATATABLE_MISC ... " ("
		... "steamid INTEGER NOT NULL, "
		... "xp INTEGER NOT NULL, "
		... "streak INTEGER NOT NULL, "
		... "scrap INTEGER NOT NULL, "
		... "tutorial INTEGER NOT NULL);");
		
		tr.AddQuery("CREATE TABLE IF NOT EXISTS " ... DATATABLE_SETTINGS ... " ("
		... "steamid INTEGER NOT NULL, "
		... "niko INTEGER NOT NULL DEFAULT 0, "
		... "armorx FLOAT NOT NULL DEFAULT -0.085, "
		... "armory FLOAT NOT NULL DEFAULT 0.0, "
		... "hurtx FLOAT NOT NULL DEFAULT 0.0, "
		... "hurty FLOAT NOT NULL DEFAULT 0.0, "
		... "weaponx FLOAT NOT NULL DEFAULT 0.0, "
		... "weapony FLOAT NOT NULL DEFAULT 0.0, "
		... "notifx FLOAT NOT NULL DEFAULT 0.0, "
		... "notify FLOAT NOT NULL DEFAULT 0.0, "
		... "screenshake INTEGER NOT NULL DEFAULT 1, "
		... "lowhealthshake INTEGER NOT NULL DEFAULT 1, "
		... "hitmarker INTEGER NOT NULL DEFAULT 1, "
		... "tp INTEGER NOT NULL DEFAULT 0);");
		
		db.Execute(tr, Database_GlobalSetup, Database_FailHandle, db);
	}
	else
	{
		LogError("[Database_GlobalConnected] %s", error);
	}
}

bool Database_IsCached(int client)
{
	return Cached[client];
}

void Database_GlobalSetInt(int client, const char[] table, const char[] type, int value)
{
	if(Cached[client])
	{
		int id = GetSteamAccountID(client);
		if(id)
		{
			char buffer[128];

			Transaction tr = new Transaction();
			Global.Format(buffer, sizeof(buffer), "UPDATE %s SET %s = %d WHERE steamid = %d;", table, type, value, id);
			
			tr.AddQuery(buffer);
			Global.Execute(tr, Database_Success, Database_Fail, DBPrio_Low);
		}
	}
}

static void GlobalClientAuthorized(int id, int userid)
{
	if(Global)
	{
		Transaction tr = new Transaction();
		
		char buffer[256];
		FormatEx(buffer, sizeof(buffer), "SELECT loadout FROM " ... DATATABLE_LOADOUT ... " WHERE steamid = %d;", id);
		tr.AddQuery(buffer);

		FormatEx(buffer, sizeof(buffer), "SELECT * FROM " ... DATATABLE_MISC ... " WHERE steamid = %d;", id);
		tr.AddQuery(buffer);

		FormatEx(buffer, sizeof(buffer), "SELECT * FROM " ... DATATABLE_SETTINGS ... " WHERE steamid = %d;", id);
		tr.AddQuery(buffer);
		
		Global.Execute(tr, Database_GlobalClientSetup, Database_Fail, userid);
	}
}

public void Database_GlobalClientSetup(Database db, int userid, int numQueries, DBResultSet[] results, any[] queryData)
{
	int client = GetClientOfUserId(userid);
	if(client && !Cached[client])
	{
		Cached[client] = true;

		char buffer[512];
		
		delete Loadouts[client];
		Loadouts[client] = new ArrayList(ByteCountToCells(sizeof(buffer)));
		
		while(results[0].MoreRows)
		{
			if(results[0].FetchRow())
			{
				results[0].FetchString(0, buffer, sizeof(buffer));
				if(Loadouts[client].FindString(buffer) == -1)
					Loadouts[client].PushString(buffer);
			}
		}

		int tutorial;

		Transaction tr;
		if(results[1].FetchRow())
		{
			XP[client] = results[1].FetchInt(1);
			PlayStreak[client] = results[1].FetchInt(2);
			Scrap[client] = results[1].FetchInt(3);
			tutorial = results[1].FetchInt(4);
			Level[client] = XpToLevel(XP[client]);
		}
		else if(!results[1].MoreRows)
		{
			CookieXP.Get(client, buffer, sizeof(buffer));
			XP[client] = StringToInt(buffer);
			Level[client] = XpToLevel(XP[client]);

			CookieScrap.Get(client, buffer, sizeof(buffer));
			Scrap[client] = StringToInt(buffer);

			tr = new Transaction();
			
			FormatEx(buffer, sizeof(buffer), "INSERT INTO " ... DATATABLE_MISC ... " (steamid, xp, streak, scrap, tutorial) VALUES (%d, %d, 0, %d, 0)", GetSteamAccountID(client), XP[client], Scrap[client]);
			tr.AddQuery(buffer);
		}

		Tutorial_ClientSetup(client, tutorial);
		
		if(results[2].FetchRow())
		{
			b_IsPlayerNiko[client] = view_as<bool>(results[2].FetchInt(1));
			f_ArmorHudOffsetX[client] = results[2].FetchFloat(2);
			f_ArmorHudOffsetY[client] = results[2].FetchFloat(3);
			f_HurtHudOffsetX[client] = results[2].FetchFloat(4);
			f_HurtHudOffsetY[client] = results[2].FetchFloat(5);
			f_WeaponHudOffsetX[client] = results[2].FetchFloat(6);
			f_WeaponHudOffsetY[client] = results[2].FetchFloat(7);
			f_NotifHudOffsetX[client] = results[2].FetchFloat(8);
			f_NotifHudOffsetY[client] = results[2].FetchFloat(9);
			b_HudScreenShake[client] = view_as<bool>(results[2].FetchInt(10));
			b_HudLowHealthShake[client] = view_as<bool>(results[2].FetchInt(11));
			b_HudHitMarker[client] = view_as<bool>(results[2].FetchInt(12));
			thirdperson[client] = view_as<bool>(results[2].FetchInt(13));
			f_ZombieVolumeSetting[client] = results[2].FetchFloat(14);
		}
		else if(!results[2].MoreRows)
		{
			if(!tr)
				tr = new Transaction();

			FormatEx(buffer, sizeof(buffer), "INSERT INTO " ... DATATABLE_SETTINGS ... " (steamid) VALUES (%d)", GetSteamAccountID(client));
			tr.AddQuery(buffer);
		}

		if(tr)
			Global.Execute(tr, Database_Success, Database_Fail, DBPrio_High);
	}
}

void DataBase_ClientDisconnect(int client)
{
	if(Cached[client])
	{
		Cached[client] = false;

		int id = GetSteamAccountID(client);
		if(id)
		{
			Transaction tr = new Transaction();
			
			char buffer[256];
			FormatEx(buffer, sizeof(buffer), "UPDATE " ... DATATABLE_MISC ... " SET "
			... "xp = %d, "
			... "streak = %d, "
			... "scrap = %d "
			... "WHERE steamid = %d;",
			XP[client],
			PlayStreak[client],
			Scrap[client],
			id);

			tr.AddQuery(buffer);

			FormatEx(buffer, sizeof(buffer), "UPDATE " ... DATATABLE_SETTINGS ... " SET "
			... "niko = %d, "
			... "armorx = %.3f, "
			... "armory = %.3f, "
			... "hurtx = %.3f, "
			... "hurty = %.3f, "
			... "weaponx = %.3f, "
			... "weapony = %.3f, "
			... "notifx = %.3f, "
			... "notify = %.3f, "
			... "screenshake = %d, "
			... "lowhealthshake = %d, "
			... "hitmarker = %d, "
			... "tp = %d, "
			... "zomvol = %.1f, "
			... "WHERE steamid = %d;",
			b_IsPlayerNiko[client],
			f_ArmorHudOffsetX[client],
			f_ArmorHudOffsetY[client],
			f_HurtHudOffsetX[client],
			f_HurtHudOffsetY[client],
			f_WeaponHudOffsetX[client],
			f_WeaponHudOffsetY[client],
			f_NotifHudOffsetX[client],
			f_NotifHudOffsetY[client],
			b_HudScreenShake[client],
			b_HudLowHealthShake[client],
			b_HudHitMarker[client],
			thirdperson[client],
			f_ZombieVolumeSetting[client],
			id);

			tr.AddQuery(buffer);

			Global.Execute(tr, Database_Success, Database_Fail, DBPrio_High);
		}
	}

	delete Loadouts[client];
}

void Database_SaveLoadout(int client, const char[] name)
{
	if(Global)
	{
		int id = GetSteamAccountID(client);
		if(id)
		{
			Transaction tr = new Transaction();
			
			char buffer[256];
			Global.Format(buffer, sizeof(buffer), "DELETE FROM " ... DATATABLE_LOADOUT ... " WHERE steamid = %d AND loadout = '%s';", id, name);
			tr.AddQuery(buffer);
			
			int owned, scale, equip, sell, hidden;
			for(int i; Store_GetNextItem(client, i, owned, scale, equip, sell, buffer, sizeof(buffer), hidden); i++)
			{
				if(owned/* && equip*/&& !hidden)
				{
					Global.Format(buffer, sizeof(buffer), "INSERT INTO " ... DATATABLE_LOADOUT ... " (steamid, item, loadout) VALUES ('%d', '%s', '%s')", id, buffer, name);
					tr.AddQuery(buffer);
				}
			}
			
			Global.Execute(tr, Database_Success, Database_Fail);
		}
	}
}

void Database_DeleteLoadout(int client, const char[] name)
{
	if(Global)
	{
		int id = GetSteamAccountID(client);
		if(id)
		{
			Transaction tr = new Transaction();
			
			char buffer[256];
			Global.Format(buffer, sizeof(buffer), "DELETE FROM " ... DATATABLE_LOADOUT ... " WHERE steamid = %d AND loadout = '%s';", id, name);
			tr.AddQuery(buffer);
			
			Global.Execute(tr, Database_Success, Database_Fail);
		}
	}
}

void Database_LoadLoadout(int client, const char[] name, bool free)
{
	if(Global)
	{
		int id = GetSteamAccountID(client);
		if(id)
		{
			Transaction tr = new Transaction();
			
			char buffer[256];
			Global.Format(buffer, sizeof(buffer), "SELECT item FROM " ... DATATABLE_LOADOUT ... " WHERE steamid = %d AND loadout = '%s';", id, name);
			tr.AddQuery(buffer);
			
			DataPack pack = new DataPack();
			pack.WriteCell(GetClientUserId(client));
			pack.WriteCell(free);
			
			Global.Execute(tr, Database_OnLoadout, Database_FailHandle, pack);
		}
	}
}

public void Database_OnLoadout(Database db, DataPack pack, int numQueries, DBResultSet[] results, any[] queryData)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if(client && results[0].MoreRows)
	{
		bool free = pack.ReadCell();
		char buffer[64];
		
		do
		{
			if(results[0].FetchRow())
			{
				results[0].FetchString(0, buffer, sizeof(buffer));
				Store_BuyNamedItem(client, buffer, free);
			}
		}
		while(results[0].MoreRows);
		
		Store_ApplyAttribs(client);
		Store_GiveAll(client, GetClientHealth(client));
		Store_Menu(client);
	}
	
	delete pack;
}

/*
	Local Database
*/

static void Database_LocalConnected(Database db, const char[] error)
{
	if(db)
	{
		Transaction tr = new Transaction();
		
		tr.AddQuery("CREATE TABLE IF NOT EXISTS " ... DATATABLE_MAIN ... " ("
		... "steamid INTEGER NOT NULL, "
		... "time INTEGER NOT NULL DEFAULT 0, "
		... "spent INTEGER NOT NULL DEFAULT 0, "
		... "total INTEGER NOT NULL DEFAULT 0, "
		... "ammo INTEGER NOT NULL DEFAULT 0, "
		... "leftfordead FLOAT NOT NULL DEFAULT 0.0);");
		
		tr.AddQuery("CREATE TABLE IF NOT EXISTS " ... DATATABLE_AMMO ... " ("
		... "steamid INTEGER NOT NULL, "
		... "type INTEGER NOT NULL, "
		... "amount INTEGER NOT NULL);");
		
		tr.AddQuery("CREATE TABLE IF NOT EXISTS " ... DATATABLE_GAMEDATA ... " ("
		... "steamid INTEGER NOT NULL, "
		... "item INTEGER NOT NULL, "
		... "level INTEGER NOT NULL, "
		... "scale INTEGER NOT NULL, "
		... "equip INTEGER NOT NULL, "
		... "sell INTEGER NOT NULL);");
		
		db.Execute(tr, Database_LocalSetup, Database_FailHandle, db);
	}
	else
	{
		LogError("[Database_LocalConnected] %s", error);
	}
}

static void LocalClientAuthorized(int id, int userid)
{
	if(Local && CurrentGame != -1)
	{
		Transaction tr = new Transaction();
		
		char buffer[256];
		FormatEx(buffer, sizeof(buffer), "SELECT * FROM " ... DATATABLE_MAIN ... " WHERE steamid = %d;", id);
		tr.AddQuery(buffer);
		
		Local.Execute(tr, Database_LocalClientSetup, Database_Fail, userid);
	}
}

public void Database_LocalClientSetup(Database db, int userid, int numQueries, DBResultSet[] results, any[] queryData)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		if(results[0].FetchRow())
		{
			if(results[0].FetchInt(1) == CurrentGame)
			{
				int id = results[0].FetchInt(0);
				CashSpent[client] = results[0].FetchInt(2);
				CashSpentTotal[client] = results[0].FetchInt(3);
				Ammo_Count_Used[client] = results[0].FetchInt(4);
				f_LeftForDead_Cooldown[client] = results[0].FetchFloat(5);

				Transaction tr = new Transaction();
					
				char buffer[512];
				FormatEx(buffer, sizeof(buffer), "SELECT * FROM " ... DATATABLE_GAMEDATA ... " WHERE steamid = %d;", id);
				tr.AddQuery(buffer);
				
				FormatEx(buffer, sizeof(buffer), "SELECT * FROM " ... DATATABLE_AMMO ... " WHERE steamid = %d;", id);
				tr.AddQuery(buffer);
				
				Local.Execute(tr, Database_LocalGamedata, Database_Fail, userid);
			}
		}
		else if(!results[0].MoreRows)
		{
			Transaction tr = new Transaction();

			char buffer[256];
			FormatEx(buffer, sizeof(buffer), "INSERT INTO " ... DATATABLE_MAIN ... " (steamid) VALUES (%d)", GetSteamAccountID(client));
			tr.AddQuery(buffer);
			
			Local.Execute(tr, Database_Success, Database_Fail, userid);
		}
	}
}

public void Database_LocalGamedata(Database db, int userid, int numQueries, DBResultSet[] results, any[] queryData)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		while(results[0].MoreRows)
		{
			if(results[0].FetchRow())
				Store_SetClientItem(client, results[0].FetchInt(1), results[0].FetchInt(2), results[0].FetchInt(3), results[0].FetchInt(4), results[0].FetchInt(5));
		}

		while(results[1].MoreRows)
		{
			if(results[1].FetchRow())
				CurrentAmmo[client][results[1].FetchInt(1)] = results[1].FetchInt(2);
		}
		
		if(IsClientInGame(client))
		{
			SetGlobalTransTarget(client);
			PrintToChat(client, "%t", "Your loadout was updated from your previous state.");
			if(IsPlayerAlive(client))
				TF2_RegeneratePlayer(client);
		}
	}
}

void Database_SaveGameData(int client)
{
	if(Local && CurrentGame != -1)
	{
		int id = GetSteamAccountID(client);
		if(id)
		{
			Transaction tr = new Transaction();
			
			char buffer[512];
			FormatEx(buffer, sizeof(buffer), "DELETE FROM " ... DATATABLE_GAMEDATA ... " WHERE steamid = %d;", id);
			tr.AddQuery(buffer);
			
			int owned, scale, equip, sell, hidden;
			for(int i; Store_GetNextItem(client, i, owned, scale, equip, sell,_,_, hidden); i++)
			{
				if(!hidden)
				{
					Local.Format(buffer, sizeof(buffer), "INSERT INTO " ... DATATABLE_GAMEDATA ... " (steamid, item, level, scale, equip, sell) VALUES ('%d', '%d', '%d', '%d', '%d', '%d')", id, i, owned, scale, equip, sell);
					tr.AddQuery(buffer);
				}
			}

			FormatEx(buffer, sizeof(buffer), "DELETE FROM " ... DATATABLE_AMMO ... " WHERE steamid = %d;", id);
			tr.AddQuery(buffer);

			for(int i = Ammo_Metal; i < Ammo_MAX; i++)
			{
				if(i >= Ammo_Pistol || i == Ammo_Metal || i == Ammo_Jar)
				{
					Local.Format(buffer, sizeof(buffer), "INSERT INTO " ... DATATABLE_AMMO ... " (steamid, type, amount) VALUES ('%d', '%d', '%d')", id, i, CurrentAmmo[client][i]);
					tr.AddQuery(buffer);
				}
			}
			
			FormatEx(buffer, sizeof(buffer), "UPDATE " ... DATATABLE_MAIN ... " SET "
			... "time = %d, "
			... "spent = %d, "
			... "total = %d, "
			... "ammo = %d, "
			... "leftfordead = %.1f "
			... "WHERE steamid = %d;",
			CurrentGame,
			CashSpent[client],
			CashSpentTotal[client],
			Ammo_Count_Used[client],
			f_LeftForDead_Cooldown[client] + 30.0,
			id);
			

			tr.AddQuery(buffer);
			
			Local.Execute(tr, Database_Success, Database_Fail, DBPrio_High);
		}
	}
}

/*
	Shared
*/

public void Database_Success(Database db, any data, int numQueries, DBResultSet[] results, any[] queryData)
{
}

public void Database_Fail(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	LogError("[Database_Fail] %s", error);
}

public void Database_FailHandle(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	LogError("[Database_FailHandle] %s", error);
	CloseHandle(data);
}