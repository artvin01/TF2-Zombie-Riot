#pragma semicolon 1

#include <sourcemod>
#include <textstore>

#pragma newdecls required

//#define DEBUG
#define PLUGIN_VERSION	"1.6.1"

enum struct LastItem
{
	int Item;
	int Count;
	bool Equipped;
}

//ConVar CvarBackup;
Database DataBase;
bool IgnoreLoad;
bool InQuery;
int CurrentUniverse[MAXPLAYERS];
ArrayList LastItems[MAXPLAYERS];
GlobalForward UniverseForward;

public Plugin myinfo =
{
	name		=	"The Text Store: SQLite Universe",
	author		=	"Batfoxkid",
	description	=	"A version that saves for multiple of the same ID",
	version		=	PLUGIN_VERSION
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	UniverseForward = new GlobalForward("TextStore_OnUniverse", ET_Single, Param_Cell);
	CreateNative("_textstore_saveaddon", _textstore_saveaddon);
	return APLRes_Success;
}

int GetUniverse(int client)
{
	int universe;
	Call_StartForward(UniverseForward);
	Call_PushCell(client);
	Call_Finish(universe);
	return universe;
}

public any _textstore_saveaddon(Handle plugin, int numParams)
{
	return 0;
}

public void OnPluginStart()
{
/*
	RegServerCmd("sm_textstore_convert", Command_Convert, "Trasnfer all existing TXT files to SQL");
	RegServerCmd("sm_textstore_import", Command_Import, "Import a TXT file to SQL");
	RegServerCmd("sm_textstore_check", Command_Check, "Checks data given a steamid");
	RegServerCmd("sm_textstore_modify", Command_Modify, "Change data given a steamid");

	CvarBackup = CreateConVar("textstore_sql_hybrid", "0", "If to also save text files alongside SQL", _, true, 0.0, true, 1.0);
*/	
	char error[512];
	Database db = SQLite_UseDatabase("textstore", error, sizeof(error));
	if(!db)
		SetFailState(error);
	
	Transaction tr = new Transaction();
	
	tr.AddQuery("CREATE TABLE IF NOT EXISTS misc_data ("
	... "steamid INTEGER NOT NULL, "
	... "cash INTEGER NOT NULL DEFAULT 0, "
	... "universe INTEGER NOT NULL);");
	
	tr.AddQuery("CREATE TABLE IF NOT EXISTS common_items ("
	... "steamid INTEGER NOT NULL, "
	... "item TEXT NOT NULL, "
	... "count INTEGER NOT NULL, "
	... "equip INTEGER NOT NULL, "
	... "universe INTEGER NOT NULL);");
	
	tr.AddQuery("CREATE TABLE IF NOT EXISTS unique_items ("
	... "steamid INTEGER NOT NULL, "
	... "item TEXT NOT NULL, "
	... "name TEXT NOT NULL, "
	... "equip INTEGER NOT NULL, "
	... "data TEXT NOT NULL, "
	... "universe INTEGER NOT NULL);");
	
	tr.AddQuery("CREATE TABLE IF NOT EXISTS unique_backup ("
	... "steamid INTEGER NOT NULL, "
	... "item TEXT NOT NULL, "
	... "name TEXT NOT NULL, "
	... "equip INTEGER NOT NULL, "
	... "data TEXT NOT NULL, "
	... "universe INTEGER NOT NULL);");
	
	db.Execute(tr, Database_SetupSuccess, Database_SetupFail, db);
}

public void Database_SetupSuccess(Database db, any data, int numQueries, DBResultSet[] results, any[] queryData)
{
	#if defined DEBUG
	PrintToServer("Database_SetupSuccess");
	#endif
	
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			if(TextStore_GetClientLoad(client))
				TextStore_ClientSave(client);
		}
	}
	
	DataBase = data;
	
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
			TextStore_ClientReload(client);
	}
}

public void Database_SetupFail(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	SetFailState(error);
}

public Action TextStore_OnClientLoad(int client, char file[PLATFORM_MAX_PATH])
{
	#if defined DEBUG
	PrintToServer("TextStore_OnClientLoad");
	#endif
	
	if(IgnoreLoad)
		return Plugin_Continue;
	
	delete LastItems[client];
	
	if(DataBase)
	{
		int id = GetSteamAccountID(client);
		if(!id)
			ThrowError("TextStore_OnClientLoad called but GetSteamAccountID is invalid?");
		
		CurrentUniverse[client] = GetUniverse(client);
		
		Transaction tr = new Transaction();
		
		char buffer[256];
		FormatEx(buffer, sizeof(buffer), "SELECT * FROM misc_data WHERE steamid = %d AND universe = %d;", id, CurrentUniverse[client]);
		tr.AddQuery(buffer);
		
		AddToQueryQueue(tr, Database_ClientSetup1, Database_Fail, GetClientUserId(client));
	}
//	else if(CvarBackup.BoolValue)
//	{
//		return Plugin_Continue;
//	}
	
	return Plugin_Stop;
}

public void Database_ClientSetup1(Database db, any userid, int numQueries, DBResultSet[] results, any[] queryData)
{
	InQuery = false;
	
	#if defined DEBUG
	PrintToServer("Database_ClientSetup1");
	#endif
	
	int client = GetClientOfUserId(userid);
	if(client)
	{
		delete LastItems[client];
		LastItems[client] = new ArrayList(sizeof(LastItem));
		
		static char data[256];
		if(results[0].FetchRow())
		{
			int cash = results[0].FetchInt(1) - TextStore_Cash(client);
			TextStore_Cash(client, cash);
		}
		else if(!results[0].MoreRows)
		{
			Transaction tr = new Transaction();
			
			Format(data, sizeof(data), "INSERT INTO misc_data (steamid, universe) VALUES ('%d', '%d')", GetSteamAccountID(client), CurrentUniverse[client]);
			tr.AddQuery(data);
			
			AddToQueryQueue(tr, Database_Success, Database_Fail);
			
			IgnoreLoad = true;
			TextStore_ClientReload(client);
			IgnoreLoad = false;
			
			if(TextStore_GetClientLoad(client))
				TextStore_OnClientSave(client, "");
			
			return;
		}
		else
		{
			ThrowError("Unable to fetch first row");
		}
		
		int id = GetSteamAccountID(client);
		if(id)
		{
			Transaction tr = new Transaction();
			
			Format(data, sizeof(data), "SELECT * FROM common_items WHERE steamid = %d AND universe = %d;", id, CurrentUniverse[client]);
			tr.AddQuery(data);
			
			AddToQueryQueue(tr, Database_ClientSetup2, Database_Fail, GetClientUserId(client));
		}
	}
}

public void Database_ClientSetup2(Database db, any userid, int numQueries, DBResultSet[] results, any[] queryData)
{
	InQuery = false;
	
	#if defined DEBUG
	PrintToServer("Database_ClientSetup2");
	#endif
	
	int client = GetClientOfUserId(userid);
	if(client)
	{
		while(results[0].MoreRows)
		{
			if(results[0].FetchRow())
			{
				static char item[48];
				results[0].FetchString(1, item, sizeof(item));
				GiveNamedItem(client, item, results[0].FetchInt(2), view_as<bool>(results[0].FetchInt(3)));
			}
		}
		
		int id = GetSteamAccountID(client);
		if(id)
		{
			Transaction tr = new Transaction();
			
			char buffer[256];
			FormatEx(buffer, sizeof(buffer), "SELECT * FROM unique_items WHERE steamid = %d AND universe = %d;", id, CurrentUniverse[client]);
			tr.AddQuery(buffer);
			
			AddToQueryQueue(tr, Database_ClientSetup3, Database_Fail, GetClientUserId(client));
		}
	}
}

public void Database_ClientSetup3(Database db, any userid, int numQueries, DBResultSet[] results, any[] queryData)
{
	InQuery = false;
	
	#if defined DEBUG
	PrintToServer("Database_ClientSetup3");
	#endif
	
	int client = GetClientOfUserId(userid);
	if(client)
	{
		bool found;
		
		while(results[0].MoreRows)
		{
			if(results[0].FetchRow())
			{
				static char item[48], name[48], data[256];
				results[0].FetchString(1, item, sizeof(item));
				results[0].FetchString(2, name, sizeof(name));
				results[0].FetchString(4, data, sizeof(data));
				
				GiveNamedUnique(client, item, name, view_as<bool>(results[0].FetchInt(3)), data);
				found = true;
			}
		}
		
		if(found)
		{
			TextStore_SetClientLoad(client, true);
		}
		else
		{
			int id = GetSteamAccountID(client);
			if(id)
			{
				Transaction tr = new Transaction();
				
				char buffer[256];
				FormatEx(buffer, sizeof(buffer), "SELECT * FROM unique_backup WHERE steamid = %d AND universe = %d;", id, CurrentUniverse[client]);
				tr.AddQuery(buffer);
				
				AddToQueryQueue(tr, Database_ClientSetup4, Database_Fail, GetClientUserId(client));
			}
		}
	}
}

public void Database_ClientSetup4(Database db, any userid, int numQueries, DBResultSet[] results, any[] queryData)
{
	InQuery = false;
	
	#if defined DEBUG
	PrintToServer("Database_ClientSetup4");
	#endif
	
	int client = GetClientOfUserId(userid);
	if(client)
	{
		while(results[0].MoreRows)
		{
			if(results[0].FetchRow())
			{
				static char item[48], name[48], data[256];
				results[0].FetchString(1, item, sizeof(item));
				results[0].FetchString(2, name, sizeof(name));
				results[0].FetchString(4, data, sizeof(data));
				
				GiveNamedUnique(client, item, name, view_as<bool>(results[0].FetchInt(3)), data);
			}
		}
		
		TextStore_SetClientLoad(client, true);
	}
}

public Action TextStore_OnClientSave(int client, char file[PLATFORM_MAX_PATH])
{
	InQuery = false;
	
	#if defined DEBUG
	PrintToServer("TextStore_OnClientSave");
	#endif
	
	if(DataBase && LastItems[client])
	{
		int id = GetSteamAccountID(client);
		if(!id)
			ThrowError("TextStore_OnClientSave called but GetSteamAccountID is invalid?");
		
		Transaction tr = new Transaction();
		
		static char buffer[1024];
		Format(buffer, sizeof(buffer), "UPDATE misc_data SET cash = %d WHERE steamid = %d AND universe = %d;", TextStore_Cash(client), id, CurrentUniverse[client]);
		tr.AddQuery(buffer);
		
		AddToQueryQueue(tr, Database_Success, Database_Fail);
		
		tr = new Transaction();
		
		LastItem last;
		ArrayList list = new ArrayList(sizeof(LastItem));
		
		int amount;
		int uniques;
		int items = TextStore_GetItems(uniques);
		for(int i; i<items; i++)
		{
			bool equipped = TextStore_GetInv(client, i, amount);
			int index = LastItems[client].FindValue(i, LastItem::Item);
			if(index == -1)
			{
				if(amount > 0)
				{
					TextStore_GetItemName(i, buffer, sizeof(buffer));
					DataBase.Format(buffer, sizeof(buffer), "INSERT INTO common_items (steamid, universe, item, count, equip) VALUES ('%d', '%d', '%s', '%d', '%d')", id, CurrentUniverse[client], buffer, amount, equipped);
					
					tr.AddQuery(buffer);
				}
				else
				{
					continue;
				}
			}
			else if(amount > 0)
			{
				LastItems[client].GetArray(index, last);
				if(last.Count != amount || last.Equipped != equipped)
				{
					TextStore_GetItemName(i, buffer, sizeof(buffer));
					DataBase.Format(buffer, sizeof(buffer), "UPDATE common_items SET count = '%d', equip = '%d' WHERE steamid = %d AND universe = %d AND item = '%s';", amount, equipped, id, CurrentUniverse[client], buffer);
					
					tr.AddQuery(buffer);
				}
			}
			else
			{
				TextStore_GetItemName(i, buffer, sizeof(buffer));
				DataBase.Format(buffer, sizeof(buffer), "DELETE FROM common_items WHERE steamid = %d AND universe = %d AND item = '%s';", id, CurrentUniverse[client], buffer);
				
				tr.AddQuery(buffer);
				continue;
			}
			
			last.Item = i;
			last.Count = amount;
			last.Equipped = equipped;
			list.PushArray(last);
		}
		
		AddToQueryQueue(tr, Database_Success, Database_Fail);
		
		delete LastItems[client];
		LastItems[client] = list;
		
		if(uniques)
		{
			tr = new Transaction();
			
			uniques = -uniques;
			
			FormatEx(buffer, sizeof(buffer), "DELETE FROM unique_items WHERE steamid = %d AND universe = %d;", id, CurrentUniverse[client]);
			tr.AddQuery(buffer);
			
			char item[48], name[48];
			for(int i=-1; i>=uniques; i--)
			{
				bool equipped = TextStore_GetInv(client, i, amount);
				if(amount)
				{
					if(TextStore_GetItemKv(i).GetSectionName(item, sizeof(item)))
					{
						TextStore_GetItemName(i, name, sizeof(name));
						if(StrEqual(name, item, false))
							name[0] = 0;
						
						TextStore_GetItemData(i, buffer, sizeof(buffer));
						
						DataBase.Format(buffer, sizeof(buffer), "INSERT INTO unique_backup (steamid, item, name, equip, data, universe) VALUES ('%d', '%s', '%s', '%d', '%s', '%d')", id, item, name, equipped, buffer, CurrentUniverse[client]);
						tr.AddQuery(buffer);
					}
					else
					{
						LogError("KeyValues.GetSectionName failed with unique item");
					}
				}
			}
			
			DataPack pack = new DataPack();
			Format(buffer, sizeof(buffer), "INSERT INTO unique_items SELECT * FROM unique_backup WHERE steamid = %d AND universe = %d;", id, CurrentUniverse[client]);
			pack.WriteString(buffer);
			pack.WriteCell(id);
			pack.WriteCell(CurrentUniverse[client]);
			AddToQueryQueue(tr, Database_ClientSave1, Database_FailHandle, pack);
		}
		
//		if(!CvarBackup.BoolValue)
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public void Database_ClientSave1(Database db, any pack, int numQueries, DBResultSet[] results, any[] queryData)
{
	InQuery = false;
	
	#if defined DEBUG
	PrintToServer("Database_ClientSave1");
	#endif
	
	static char buffer[1024];
	
	ResetPack(pack);
	ReadPackString(pack, buffer, sizeof(buffer));
	int id = ReadPackCell(pack);
	int universe = ReadPackCell(pack);
	CloseHandle(pack);
	
	Transaction tr = new Transaction();
	tr.AddQuery(buffer);
	
	DataPack pack2 = new DataPack();
	Format(buffer, sizeof(buffer), "DELETE FROM unique_backup WHERE steamid = %d AND universe = %d;", id, universe);
	pack2.WriteString(buffer);
	AddToQueryQueue(tr, Database_ClientSave2, Database_FailHandle, pack2);
}

public void Database_ClientSave2(Database db, any pack, int numQueries, DBResultSet[] results, any[] queryData)
{
	InQuery = false;
	
	#if defined DEBUG
	PrintToServer("Database_ClientSave2");
	#endif
	
	static char buffer[1024];
	
	ResetPack(pack);
	ReadPackString(pack, buffer, sizeof(buffer));
	CloseHandle(pack);
	
	Transaction tr = new Transaction();
	tr.AddQuery(buffer);
	AddToQueryQueue(tr, Database_Success, Database_Fail);
}

public void Database_Success(Database db, any data, int numQueries, DBResultSet[] results, any[] queryData)
{
	InQuery = false;
	
	#if defined DEBUG
	PrintToServer("Database_Success");
	#endif
}

public void Database_Fail(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	InQuery = false;
	
	#if defined DEBUG
	PrintToServer("Database_Fail");
	#endif
	
	LogError(error);
}

public void Database_FailHandle(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	InQuery = false;
	
	#if defined DEBUG
	PrintToServer("Database_FailHandle");
	#endif
	
	CloseHandle(data);
	
	LogError(error);
}

public void Database_FailPrint(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	InQuery = false;
	PrintToServer(error);
}

void GiveNamedItem(int client, const char[] item, int amount, bool equipped)
{
	#if defined DEBUG
	PrintToServer("GiveNamedItem");
	#endif
	
	LastItem last;
	int items = TextStore_GetItems();
	for(int i; i<items; i++)
	{
		static char buffer[48];
		TextStore_GetItemName(i, buffer, sizeof(buffer));
		if(StrEqual(item, buffer, false))
		{
			TextStore_SetInv(client, i, amount, false);
			if(equipped)
				TextStore_UseItem(client, i, true);
			
			last.Item = i;
			last.Count = amount;
			last.Equipped = false;
			LastItems[client].PushArray(last);
			break;
		}
	}
}

void GiveNamedUnique(int client, const char[] item, const char[] name, bool equipped, const char[] data)
{
	#if defined DEBUG
	PrintToServer("GiveNamedUnique");
	#endif
	
	int items = TextStore_GetItems();
	for(int i; i<items; i++)
	{
		static char buffer[48];
		TextStore_GetItemName(i, buffer, sizeof(buffer));
		if(StrEqual(item, buffer, false))
		{
			int id = TextStore_CreateUniqueItem(client, i, data, name, false);
			if(equipped)
				TextStore_UseItem(client, id, true);
			
			break;
		}
	}
}

/*
	https://github.com/alliedmodders/sourcemod/issues/1505
*/

enum struct QueueInfo
{
	Transaction Tr;
	SQLTxnSuccess OnSuccess;
	SQLTxnFailure OnError;
	any Data;
	DBPriority Priority;
}

ArrayList QueueList;
Handle QueueTimer;

void AddToQueryQueue(Transaction tr, SQLTxnSuccess onSuccess = INVALID_FUNCTION, SQLTxnFailure onError = INVALID_FUNCTION, any data = 0, DBPriority priority = DBPrio_Normal)
{
	#if defined DEBUG
	PrintToServer("Timer_QueryQueue -> New Added");
	#endif
	
	if(!QueueList)
		QueueList = new ArrayList(sizeof(QueueInfo));
	
	if(!QueueTimer)
		QueueTimer = CreateTimer(0.2, Timer_QueryQueue, _, TIMER_REPEAT);
	
	static QueueInfo info;
	info.Tr = tr;
	info.OnSuccess = onSuccess;
	info.OnError = onError;
	info.Data = data;
	info.Priority = priority;
	QueueList.PushArray(info);
}

public Action Timer_QueryQueue(Handle timer)
{
	#if defined DEBUG
	PrintToServer("Timer_QueryQueue -> Pending");
	#endif
	
	if(InQuery)
		return Plugin_Continue;
	
	if(!QueueList.Length)
	{
		QueueTimer = null;
		return Plugin_Stop;
	}
	
	static QueueInfo info;
	QueueList.GetArray(0, info);
	QueueList.Erase(0);
	
	InQuery = true;
	
	#if defined DEBUG
	PrintToServer("Timer_QueryQueue -> Started New | %x %d %d", info.Tr, view_as<int>(info.OnSuccess), view_as<int>(info.OnError));
	#endif
	
	DataBase.Execute(info.Tr, info.OnSuccess, info.OnError, info.Data, info.Priority);
	return Plugin_Continue;
}

/*
	https://forums.alliedmods.net/showthread.php?t=60899&page=36
*/

stock bool GetSteam32FromSteam64(const char[] szSteam64Original, int &iSteam32)
{
	char szSteam32[20];
	char szSteam64[20];
	
	// We don't want to actually edit the original string.
	// We make a new string for the editing.
	strcopy(szSteam64, sizeof szSteam64, szSteam64Original);
	
	// Remove the first three numbers
	ReplaceStringEx(szSteam64, sizeof(szSteam64), "765", "");
	
	// Because pawn does not support numbers bigger than 2147483647, we will need to subtract using a combination of numbers.
	// The combination can be
	// 1 number to max integers
	char szSubtractionString[] = "61197960265728";
	
	// First integer is the integer from szSteam64
	// Second is from the subtraction string szSubtractionString
	char szFirstInteger[11], szSecondInteger[11];
	int iFirstInteger, iSecondInteger;
	
	char szResultInt[11];
	
	// Ugly hack
	// Make the strings 00000000000 so when we use StringToInt the zeroes won't affect the result
	// sizeof - 1 because we need the last End of string (0) byte;
	SetStringZeros(szFirstInteger, sizeof(szFirstInteger), sizeof(szFirstInteger) - 1);
	SetStringZeros(szSecondInteger, sizeof(szSecondInteger), sizeof(szSecondInteger) - 1);

	// Start from the end of the string, because subtraction should always start from the first number in the right.
	int iResultInt;
	
	int iSteam64Position = strlen(szSteam64);
	int iIntegerPosition = strlen(szFirstInteger);
	
	int iNumCount;
	int iResultLen;
	char szStringZeroes[11];
	
	while(--iSteam64Position > -1)
	{
		iIntegerPosition -= 1;
		
		++iNumCount;
		szFirstInteger[iIntegerPosition] = szSteam64[iSteam64Position];
		szSecondInteger[iIntegerPosition] = szSubtractionString[iSteam64Position];
		
		iFirstInteger = StringToInt(szFirstInteger);
		iSecondInteger = StringToInt(szSecondInteger);
			
		// Can we subtract without getting a negative number?
		if(iFirstInteger >= iSecondInteger)
		{
			iResultInt = iFirstInteger - iSecondInteger;
			// 69056897
			if(iResultInt)
			{
				IntToString(iResultInt, szResultInt, sizeof szResultInt);
				
				if( iNumCount != (iResultLen  = strlen(szResultInt) ) )
				{
					SetStringZeros(szStringZeroes, sizeof szStringZeroes, iNumCount - iResultLen);
				}
				
				else
				{
					szStringZeroes = "";
				}
			}
			
			else
			{
				szResultInt = "";
				
				SetStringZeros(szStringZeroes, sizeof szStringZeroes, iNumCount);
			}
			
			Format(szSteam32, sizeof szSteam32, "%s%s%s", szStringZeroes, szResultInt, szSteam32);
			
			// Reset our stuff.
			SetStringZeros(szFirstInteger, sizeof(szFirstInteger), sizeof(szFirstInteger) - 1);
			SetStringZeros(szSecondInteger, sizeof(szSecondInteger), sizeof(szSecondInteger) - 1);
			
			iIntegerPosition = strlen(szFirstInteger);
			iNumCount = 0;
		}
		
		if(iIntegerPosition - 1 < 0)
		{
			// We failed, and this calculation can not be done in pawn.
			return false;
		}
		
		// if not, lets add more numbers.
	}
	
	iSteam32 = StringToInt(szSteam32);
	return true;
}

stock void SetStringZeros(char[] szString, int iSize, int iNumZeros)
{
	int i;
	for(i = 0; i < iNumZeros && i < iSize; i++)
	{
		szString[i] = '0';
	}
	
	szString[i] = 0;
}