#pragma semicolon 1

#include <sourcemod>
#include <textstore>

#pragma newdecls required

//#define DEBUG
#define PLUGIN_VERSION	"1.6"

enum struct LastItem
{
	int Item;
	int Count;
	bool Equipped;
}

enum struct LastUnique
{
	char Item[48];
	bool Equipped;
	char Name[48];
	char Data[512];
}

//ConVar CvarBackup;
Database DataBase;
bool IgnoreLoad;
bool InQuery;
int QueryCount;
int CurrentUniverse[MAXPLAYERS+1];
ArrayList LastItems[MAXPLAYERS+1];
ArrayList LastUniques[MAXPLAYERS+1];
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
	delete LastUniques[client];
	
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
			
			Format(data, sizeof(data), "INSERT INTO misc_data (steamid, universe) VALUES ('%d', '%d');", GetSteamAccountID(client), CurrentUniverse[client]);
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
		delete LastUniques[client];
		LastUniques[client] = new ArrayList(sizeof(LastUnique));
		
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
	
	if(DataBase && LastItems[client] && LastUniques[client])
	{
		int id = GetSteamAccountID(client);
		if(!id)
			ThrowError("TextStore_OnClientSave called but GetSteamAccountID is invalid?");
		
		Transaction tr = new Transaction();
		
		static char buffer[1024];
		Format(buffer, sizeof(buffer), "UPDATE misc_data SET cash = %d WHERE steamid = %d AND universe = %d;", TextStore_Cash(client), id, CurrentUniverse[client]);
		tr.AddQuery(buffer);
		
		AddToQueryQueue(tr, Database_Success, Database_Fail);
		
		int amount;
		int uniques;
		int items = TextStore_GetItems(uniques);
		
		{
			tr = new Transaction();
			
			LastItem last;
			ArrayList list = new ArrayList(sizeof(LastItem));
			
			for(int i; i<items; i++)
			{
				bool equipped = TextStore_GetInv(client, i, amount);
				int index = LastItems[client].FindValue(i, LastItem::Item);
				if(index == -1)
				{
					if(amount > 0)
					{
						TextStore_GetItemName(i, buffer, sizeof(buffer));
						DataBase.Format(buffer, sizeof(buffer), "INSERT INTO common_items (steamid, universe, item, count, equip) VALUES ('%d', '%d', '%s', '%d', '%d');", id, CurrentUniverse[client], buffer, amount, equipped);
						
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
		}
		
		if(uniques)
		{
			tr = new Transaction();
			
			LastUnique last;
			ArrayList list = new ArrayList(sizeof(LastUnique));
			int length = LastUniques[client].Length;
			
			uniques = -uniques;
			
			// Remaining "LastUniques" will be deleted
			// New "list" will replace the uniques
			
			//FormatEx(buffer, sizeof(buffer), "DELETE FROM unique_items WHERE steamid = %d AND universe = %d;", id, CurrentUniverse[client]);
			//tr.AddQuery(buffer);
			
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
						
						bool found;
						for(int b; b < length; b++)
						{
							LastUniques[client].GetArray(b, last);
							if(StrEqual(last.Item, item, false) &&
								last.Equipped == equipped &&
								StrEqual(last.Name, name) &&
								StrEqual(last.Data, buffer))
							{
								found = true;
								list.PushArray(last);
								LastUniques[client].Erase(b);
								length--;
								break;
							}
						}
						
						if(found)
							continue;
						
						DataBase.Format(buffer, sizeof(buffer), "INSERT INTO unique_items (steamid, item, name, equip, data, universe) VALUES ('%d', '%s', '%s', '%d', '%s', '%d');", id, item, name, equipped, buffer, CurrentUniverse[client]);
						tr.AddQuery(buffer);
						
						strcopy(last.Item, sizeof(last.Item), item);
						last.Equipped = equipped;
						strcopy(last.Name, sizeof(last.Name), name);
						strcopy(last.Data, sizeof(last.Data), buffer);
						list.PushArray(last);
					}
					else
					{
						LogError("KeyValues.GetSectionName failed with unique item");
					}
				}
			}
			
			for(int i; i < length; i++)
			{
				LastUniques[client].GetArray(i, last);
				
				DataBase.Format(buffer, sizeof(buffer), "DELETE FROM unique_items WHERE steamid = %d AND item = '%s' AND name = '%s' AND equip = %d AND data = '%s' AND universe = %d;", id, last.Item, last.Name, last.Equipped, last.Data, CurrentUniverse[client]);
				tr.AddQuery(buffer);
			}
			
			AddToQueryQueue(tr, Database_Success, Database_Fail);
			
			delete LastUniques[client];
			LastUniques[client] = list;
		}
		
//		if(!CvarBackup.BoolValue)
		return Plugin_Handled;
	}
	return Plugin_Continue;
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
			
			LastItem last;
			last.Item = i;
			last.Count = amount;
			last.Equipped = equipped;
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
			
			LastUnique last;
			strcopy(last.Item, sizeof(last.Item), item);
			last.Equipped = equipped;
			strcopy(last.Name, sizeof(last.Name), name);
			strcopy(last.Data, sizeof(last.Data), data);
			LastUniques[client].PushArray(last);
			break;
		}
	}
}

/*
	https://github.com/alliedmodders/sourcemod/issues/1505
*/

void AddToQueryQueue(Transaction tr, SQLTxnSuccess onSuccess = INVALID_FUNCTION, SQLTxnFailure onError = INVALID_FUNCTION, any data = 0, DBPriority priority = DBPrio_Normal)
{
	QueryCount++;
	
	#if defined DEBUG
	PrintToServer("Timer_QueryQueue -> New Added");
	#endif
	
	DataPack pack;
	CreateDataTimer(0.3, Timer_QueryQueue, pack, TIMER_REPEAT);
	pack.WriteCell(tr);
	pack.WriteFunction(onSuccess);
	pack.WriteFunction(onError);
	pack.WriteCell(data);
	pack.WriteCell(priority);
}

public Action Timer_QueryQueue(Handle timer, DataPack pack)
{
	#if defined DEBUG
	PrintToServer("Timer_QueryQueue -> Pending");
	#endif
	
	if(InQuery)
		return Plugin_Continue;
	
	QueryCount--;
	
	InQuery = true;
	pack.Reset();
	Transaction tr = pack.ReadCell();
	SQLTxnSuccess onSuccess = view_as<any>(pack.ReadFunction());
	SQLTxnFailure onError = view_as<any>(pack.ReadFunction());
	any data = pack.ReadCell();
	
	#if defined DEBUG
	PrintToServer("Timer_QueryQueue -> Started New | %x %d %d", tr, view_as<int>(onSuccess), view_as<int>(onError));
	#endif
	
	DataBase.Execute(tr, onSuccess, onError, data, pack.ReadCell());
	return Plugin_Stop;
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