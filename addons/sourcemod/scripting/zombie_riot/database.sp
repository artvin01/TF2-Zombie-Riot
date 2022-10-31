#pragma semicolon 1
#pragma newdecls required

#define DATABASE			"zr"
#define DATATABLE_LOADOUT		"zr_loadout"
#define DATATABLE_GAMEDATA	"zr_gamedata"

static Database DataBase;

void Database_PluginStart()
{
	if(SQL_CheckConfig(DATABASE))
	{
		Database.Connect(Database_Connected, DATABASE);
	}
	else
	{
		char error[512];
		
		Database db = SQLite_UseDatabase(DATABASE, error, sizeof(error));
		Database_Connected(db, error, 0);
	}
}

bool Database_Escape(char[] buffer, int length, int &bytes)
{
	if(!DataBase)
		return false;
	
	return DataBase.Escape(buffer, buffer, length, bytes);
}

public void Database_Connected(Database db, const char[] error, any data)
{
	if(db)
	{
		Transaction tr = new Transaction();
		
		tr.AddQuery("CREATE TABLE IF NOT EXISTS " ... DATATABLE_LOADOUT ... " ("
		... "steamid INTEGER NOT NULL, "
		... "item TEXT NOT NULL, "
		... "loadout TEXT NOT NULL);");
		
		tr.AddQuery("CREATE TABLE IF NOT EXISTS " ... DATATABLE_GAMEDATA ... " ("
		... "steamid INTEGER NOT NULL, "
		... "item INTEGER NOT NULL, "
		... "level INTEGER NOT NULL, "
		... "scale INTEGER NOT NULL, "
		... "equip INTEGER NOT NULL);");
		
		db.Execute(tr, Database_SetupCallback, Database_FailHandle, db);
	}
	else
	{
		LogError("[Database] %s", error);
	}
}

public void Database_SetupCallback(Database db, any data, int numQueries, DBResultSet[] results, any[] queryData)
{
	DataBase = data;
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientAuthorized(client))
			Database_ClientAuthorized(client);
	}
}

void Database_ClientAuthorized(int client)
{
	if(DataBase && !IsFakeClient(client))
	{
		int id = GetSteamAccountID(client);
		if(id)
		{
			Transaction tr = new Transaction();
			
			char buffer[256];
			FormatEx(buffer, sizeof(buffer), "SELECT loadout FROM " ... DATATABLE_LOADOUT ... " WHERE steamid = %d;", id);
			tr.AddQuery(buffer);
			
			DataBase.Execute(tr, Database_ClientSetup, Database_Fail, GetClientUserId(client));
		}
	}
}

public void Database_ClientSetup(Database db, int userid, int numQueries, DBResultSet[] results, any[] queryData)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		char buffer[32];
		
		delete Loadouts[client];
		Loadouts[client] = new ArrayList(ByteCountToCells(sizeof(buffer)));
		
		PrintToChatAll("Start");
		PrintToServer("Start");
		while(results[0].MoreRows)
		{
			if(results[0].FetchRow())
			{
				results[0].FetchString(0, buffer, sizeof(buffer));
				PrintToChatAll(buffer);
				PrintToServer(buffer);
				if(Loadouts[client].FindString(buffer) == -1)
					Loadouts[client].PushString(buffer);
			}
		}
	}
}

bool Database_SaveGameData(int client)
{
	delete Loadouts[client];
	
	if(DataBase && AreClientCookiesCached(client))
	{
		int id = GetSteamAccountID(client);
		if(id)
		{
			Transaction tr = new Transaction();
			
			char buffer[256];
			FormatEx(buffer, sizeof(buffer), "DELETE FROM " ... DATATABLE_GAMEDATA ... " WHERE steamid = %d;", id);
			tr.AddQuery(buffer);
			
			int owned, scale, equip;
			for(int i; Store_GetNextItem(client, i, owned, scale, equip); i++)
			{
				DataBase.Format(buffer, sizeof(buffer), "INSERT INTO " ... DATATABLE_GAMEDATA ... " (steamid, item, level, scale, equip) VALUES ('%d', '%d', '%d', '%d', '%d')", id, i, owned, scale, equip);
				tr.AddQuery(buffer);
			}
			
			DataBase.Execute(tr, Database_Success, Database_Fail);
			return true;
		}
	}
	
	return false;
}

void Database_LoadGameData(int client)
{
	if(DataBase)
	{
		int id = GetSteamAccountID(client);
		if(id)
		{
			Transaction tr = new Transaction();
			
			char buffer[256];
			FormatEx(buffer, sizeof(buffer), "SELECT * FROM " ... DATATABLE_GAMEDATA ... " WHERE steamid = %d;", id);
			tr.AddQuery(buffer);
			
			DataBase.Execute(tr, Database_OnGameData, Database_Fail, GetClientUserId(client));
		}
	}
}

public void Database_OnGameData(Database db, int userid, int numQueries, DBResultSet[] results, any[] queryData)
{
	int client = GetClientOfUserId(userid);
	if(client && AreClientCookiesCached(client) && results[0].MoreRows)
	{
		char buffer[32];
		CookieCache.Get(client, buffer, sizeof(buffer));
		
		int buffers[2];
		ExplodeStringInt(buffer, ";", buffers, sizeof(buffers));
		CashSpent[client] = buffers[1];
		
		do
		{
			if(results[0].FetchRow())
				Store_SetClientItem(client, results[0].FetchInt(1), results[0].FetchInt(2), results[0].FetchInt(3), results[0].FetchInt(4));
		}
		while(results[0].MoreRows);
		
		SetGlobalTransTarget(client);
		PrintToChat(client, "%t", "Your loadout was updated from your previous state.");
		if(IsPlayerAlive(client))
			TF2_RegeneratePlayer(client);
	}
}

void Database_SaveLoadout(int client, const char[] name)
{
	if(DataBase)
	{
		int id = GetSteamAccountID(client);
		if(id)
		{
			Transaction tr = new Transaction();
			
			char buffer[256];
			DataBase.Format(buffer, sizeof(buffer), "DELETE FROM " ... DATATABLE_LOADOUT ... " WHERE steamid = %d AND loadout = '%s';", id, name);
			tr.AddQuery(buffer);
			
			int owned, scale, equip;
			for(int i; Store_GetNextItem(client, i, owned, scale, equip, buffer, sizeof(buffer)); i++)
			{
				if(owned && equip)
				{
					DataBase.Format(buffer, sizeof(buffer), "INSERT INTO " ... DATATABLE_LOADOUT ... " (steamid, item, loadout) VALUES ('%d', '%s', '%s')", id, buffer, name);
					tr.AddQuery(buffer);
				}
			}
			
			DataBase.Execute(tr, Database_Success, Database_Fail);
		}
	}
}

void Database_DeleteLoadout(int client, const char[] name)
{
	if(DataBase)
	{
		int id = GetSteamAccountID(client);
		if(id)
		{
			Transaction tr = new Transaction();
			
			char buffer[256];
			DataBase.Format(buffer, sizeof(buffer), "DELETE FROM " ... DATATABLE_LOADOUT ... " WHERE steamid = %d AND loadout = '%s';", id, name);
			tr.AddQuery(buffer);
			
			DataBase.Execute(tr, Database_Success, Database_Fail);
		}
	}
}

void Database_LoadLoadout(int client, const char[] name, bool free)
{
	if(DataBase)
	{
		int id = GetSteamAccountID(client);
		if(id)
		{
			Transaction tr = new Transaction();
			
			char buffer[256];
			FormatEx(buffer, sizeof(buffer), "SELECT item FROM " ... DATATABLE_LOADOUT ... " WHERE steamid = %d AND loadout = '%s';", id, name);
			tr.AddQuery(buffer);
			
			DataPack pack = new DataPack();
			pack.WriteCell(GetClientUserId(client));
			pack.WriteCell(free);
			
			DataBase.Execute(tr, Database_OnLoadout, Database_FailHandle, pack);
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

public void Database_Success(Database db, any data, int numQueries, DBResultSet[] results, any[] queryData)
{
}

public void Database_Fail(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	LogError("[Database] %s", error);
}

public void Database_FailHandle(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	LogError("[Database] %s", error);
	CloseHandle(data);
}