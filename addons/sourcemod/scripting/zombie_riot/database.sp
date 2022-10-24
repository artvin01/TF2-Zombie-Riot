#pragma semicolon 1
#pragma newdecls required

#define DATABASE			"zr"
#define DATATABLE_LOADOUT		"zr_loadout"
#define DATATABLE_GAMEDATA	"zr_gamedata"

static Database DataBase;
static ArrayList Loadouts[MAXTF2PLAYERS];

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
		
		while(results[0].MoreRows)
		{
			if(results[0].FetchRow())
			{
				results[0].FetchString(0, buffer, sizeof(buffer));
				Loadouts[client].PushString(buffer);
			}
		}
	}
}

public void Database_ClientRetry(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	int client = GetClientOfUserId(data);
	if(client)
		Database_ClientAuthorized(client);
}

void Database_SaveGameData(int client)
{
	if(DataBase && Loadouts[client])
	{
		int id = GetSteamAccountID(client);
		if(id)
		{
			Transaction tr = new Transaction();
			
			FormatEx(buffer, sizeof(buffer), "DELETE FROM " ... DATATABLE_GAMEDATA ... " WHERE steamid = %d;", id);
			tr.AddQuery(buffer);
			
			int owned, scale, equip;
			for(int i; Store_GetNextItem(client, i, owned, scale, equip); i++)
			{
				DataBase.Format(buffer, sizeof(buffer), "INSERT INTO " ... DATATABLE_GAMEDATA ... " (steamid, item, owned, scale, equip) VALUES ('%d', '%d', '%d', '%d', '%d')", id, item, owned, scale, equip);
				tr.AddQuery(buffer);
			}
			
			DataBase.Execute(tr, Database_Success, Database_Fail);
		}
	}
	
	delete Loadouts[client];
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