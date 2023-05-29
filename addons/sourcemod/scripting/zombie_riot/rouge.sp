#pragma semicolon 1
#pragma newdecls required

enum struct Curse
{
	char Name[64];
	Function Func;
}

enum struct Artifact
{
	char Name[64];
	int ShopCost;
	int DropChance;
	Function FuncCollect;
	Function FuncAlly;
	Function FuncEnemy;
}

enum struct Floor
{
	char Name[64];
	int RoomCount;

	ArrayList Encounters;
	ArrayList Finals;
}

enum struct Stage
{
	char Skyname[64];
}

static bool InRougeMode;
static ArrayList Voting;
static int VotedFor[MAXTF2PLAYERS];

void Rouge_PluginStart()
{
}

bool Rouge_Mode()	// If Rouge-Like is enabled
{
	return InRougeMode;
}

void Rouge_MapStart()
{
	InRougeMode = false;
}

void Rouge_SetupVote(KeyValues kv)
{
	InRougeMode = true;


}

void Rouge_RevoteCmd(int client)
{
	VotedFor[client] = 0;
	Rouge_CallVote(client);
}

bool Rouge_CallVote(int client)
{
	if(Voting && !VotedFor[client])
	{
		Menu menu = new Menu(Rouge_CallVoteH);
		
		SetGlobalTransTarget(client);
		
		menu.SetTitle("%t:\n ", "Vote for the starting item");
		
		menu.AddItem("", "No Vote");
		
		Vote vote;
		int length = Voting.Length;
		for(int i; i<length; i++)
		{
			Voting.GetArray(i, vote);
			vote.Name[0] = CharToUpper(vote.Name[0]);
			
			if(vote.Level > 0 && LastWaveWas[0] && StrEqual(vote.Config, LastWaveWas))
			{
				Format(vote.Name, sizeof(vote.Name), "%s (Cooldown)", vote.Name);
				menu.AddItem(vote.Config, vote.Name, ITEMDRAW_DISABLED);
			}
			else if(Level[client] < vote.Level)
			{
				Format(vote.Name, sizeof(vote.Name), "%s (Lv %d)", vote.Name, Level[client]);
				menu.AddItem(vote.Config, vote.Name, ITEMDRAW_DISABLED);
			}
			else
			{
				menu.AddItem(vote.Config, vote.Name);
			}
		}
		
		menu.ExitButton = false;
		menu.Display(client, MENU_TIME_FOREVER);
		return true;
	}
	return false;
}