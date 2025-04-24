#pragma semicolon 1
#pragma newdecls required

#define SOUND_START	"ui/duel_challenge.wav"
#define SOUND_WIN	"ui/duel_challenge_accepted_with_restriction.wav"
#define SOUND_LOST	"ui/duel_challenge_rejected_with_restriction.wav"
#define SOUND_BET	"ui/duel_score_behind.wav"
#define SOUND_MATCH	"mvm/mvm_money_pickup.wav"
#define SOUND_EVENT	"ui/quest_alert.wav"
#define ITEM_CHIP	"Casino Chips"

enum
{
	Suit_Heart = 0,
	Suit_Club,
	Suit_Diamond,
	Suit_Clover,
	Suit_MAX
}

static const char SuitIcon[][] =
{
	"♥️",
	"♠️",
	"♦️",
	"♣️"
};

enum
{
	Card_MIN = 2,
	Card_Jack = 11,
	Card_Queen = 12,
	Card_King = 13,
	Card_Ace = 14,
	Card_MAX
}

static const char NumberIcon[][] =
{
	"ERROR",
	"ERROR",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"10",
	"J",
	"Q",
	"K",
	"A"
};

enum
{
	Poker_HighCard = 0,
	Poker_OnePair,
	Poker_TwoPair,
	Poker_ThreeKind,
	Poker_Straight,
	Poker_Flush,
	Poker_FullHouse,
	Poker_FourKind,
	Poker_StraightFlush
}

public const char RankNames[][] =
{
	"High Card",
	"One Pair",
	"Two Pair",
	"Three of a Kind",
	"Straight",
	"Flush",
	"Full House",
	"Four of a Kind",
	"Straight Flush"
};

#include "games/poker.sp"
#include "games/blackjack.sp"
#include "games/texas.sp"
#include "games/roulette.sp"
#include "games/crimson.sp"

static StringMap GameList;

void Games_PluginStart()
{
	RegAdminCmd("rpg_testgame", Games_Command, ADMFLAG_ROOT);
}

public Action Games_Command(int client, int args)
{
	char buffer[32];
	GetCmdArg(1, buffer, sizeof(buffer));
	StartGame(client, buffer);
	return Plugin_Handled;
}

void Games_ConfigSetup()
{
	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "games");
	KeyValues kv = new KeyValues("Games");
	kv.ImportFromFile(buffer);
	
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

	delete kv;
}

void Games_ClientEnter(int client, const char[] name)
{
	static char buffer[64];
	if(GameList && GameList.GetString(name, buffer, sizeof(buffer)))
		StartGame(client, buffer);
}

static void StartGame(int client, const char[] game)
{
	if(Editor_MenuFunc(client) != INVALID_FUNCTION)
		return;
	
	int index = StringToInt(game);
	switch(index)
	{
		case 1:
		{
			Games_Poker(client);
		}
		case 2:
		{
			Games_Blackjack(client);
		}
		case 3:
		{
			Games_Texas(client);
		}
		case 4:
		{
			Games_Roulette(client);
		}
		case 5:
		{
			Games_Crimson(client);
		}
		default:
		{
			FakeClientCommand(client, game);
		}
	}
}

char[] Games_GetCardIcon(int card)
{
	char buffer[6];
	if(card)
	{
		FormatEx(buffer, sizeof(buffer), "%s%s ", NumberIcon[card % 100], SuitIcon[card / 100]);
	}
	else
	{
		strcopy(buffer, sizeof(buffer), "? ");
	}
	return buffer;
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

int Games_GetCardRank(const int[] card, int cardcount)
{
	bool failed[Card_MAX - 5];	// 2 to 10 as a start
	for(int i = Card_MIN; i < Card_MAX; i++)
	{
		// Find if we have that number in the hand
		bool found;
		for(int a; a < cardcount; a++)
		{
			int number = card[a] % 100;
			if(number == i)
			{
				found = true;
				break;
			}
		}

		// If not, go down up to 5 numbers and consider them failed as they don't have 5 numbers in a row
		if(!found)
		{
			int start = i - Card_MIN;
			int end = start - 5;

			if(start >= sizeof(failed))
				start = sizeof(failed) - 1;
			
			if(end < -1)
				end = -1;
			
			for(; start > end; start--)
			{
				failed[start] = true;
			}
		}
	}

	bool straight;
	for(int i; i < sizeof(failed); i++)
	{
		// If one of these didn't fail, we have a proper match
		if(!failed[i])
		{
			straight = true;
			break;
		}
	}

	int suits[Suit_MAX];
	for(int i; i < cardcount; i++)
	{
		suits[card[i] / 100]++;
	}

	bool flush;
	for(int i; i < sizeof(suits); i++)
	{
		// Found more then 4 of the same suit?
		if(suits[i] > 4)
		{
			flush = true;
			break;
		}
	}

	if(straight && flush)
		return Poker_StraightFlush;
	
	// We're assuming more numbers then cards in any case
	int[] count = new int[cardcount - 1];
	ResetToZero(count, cardcount - 1);
	for(int i = 1; i < cardcount; i++)
	{
		int number = card[i] % 100;
		for(int a; a < i; a++)
		{
			if(number == card[a] % 100)
			{
				count[a]++;
				break;
			}
		}
	}
	
	bool three;
	int two;
	for(int i; i < (cardcount - 1); i++)
	{
		if(count[i] == 3)
			return Poker_FourKind;
		
		if(count[i] == 2)
			three = true;
		
		if(count[i])
			two++;
	}

	if(three && two == 2)
		return Poker_FullHouse;

	if(flush)
		return Poker_Flush;

	if(straight)
		return Poker_Straight;

	if(three)
		return Poker_ThreeKind;

	if(two == 2)
		return Poker_TwoPair;

	if(two)
		return Poker_OnePair;
	
	return Poker_HighCard;
}