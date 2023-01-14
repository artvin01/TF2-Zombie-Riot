#pragma semicolon 1
#pragma newdecls required

enum
{
	Suit_Heart = 0,
	Suit_Club,
	Suit_Diamond,
	Suit_Clover,
	Suit_MAX
}

enum
{
	Card_MIN = 2,
	Card_Jack = 11,
	Card_Queen = 12,
	Card_King = 13,
	Card_Ace = 14,
	Card_MAX
}

#include "rpg_fortress/games/poker.sp"

static StringMap GameList;

void Games_ConfigSetup(KeyValues map)
{
	KeyValues kv = map;
	if(kv)
	{
		kv.Rewind();
		if(!kv.JumpToKey("Games"))
			kv = null;
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if(!kv)
	{
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "games");
		kv = new KeyValues("Games");
		kv.ImportFromFile(buffer);
	}
	
	delete GameList;
	GameList = new StringMap();

	char buffer2[32];
	kv.GotoFirstSubKey(false);
	do
	{
		kv.GetSectionName(buffer2, sizeof(buffer2));
		kv.GetString(NULL_STRING, buffer, sizeof(buffer));
		GameList.SetString(buffer2, buffer);
	}
	while(kv.GotoNextKey(false));

	if(kv != map)
		delete kv;
}

void Games_ClientEnter(int client, const char[] name)
{
	static char buffer[64];
	if(GameList && GameList.GetString(name, buffer, sizeof(buffer)))
		StartGame(client, name, buffer);
}

static void StartGame(int client, const char[] zone, const char[] game)
{
	int index = StringToInt(game);
	switch(index)
	{
		case 1:
		{
			Games_Poker(client, zone);
		}
		default:
		{
			FakeClientCommand(client, game);
		}
	}
}

ArrayList Games_GenerateNewDeck()
{
	ArrayList list = new ArrayList();

	for(int s; s < Suit_MAX; s++)
	{
		for(int c = Card_MIN; c < Card_MAX; c++)
		{
			list.Push((s * 100) + c);
		}
	}

	list.Sort(Sort_Random, Sort_Integer);
	return list;
}