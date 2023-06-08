#pragma semicolon 1
#pragma newdecls required

// To disable Major Update Traffic Handling, comment out below line
//#define TRAFFIC_TICKET	"Chapter 2 Pass"
#define TRAFFIC_LEVEL	30
#define TRAFFIC_TIME	1800.0	// 30 mins

#if !defined TRAFFIC_TICKET
stock void Traffic_PluginStart() { }
stock void Traffic_LoadItems(int client) { }
#endinput
#endif

static float NextTicket[MAX_PARTY_SIZE];
static ArrayList TicketQueue;
static Handle TicketTimer;

void Traffic_PluginStart()
{
	TicketQueue = new ArrayList();
}

void Traffic_LoadItems(int client)
{
	CreateTimer(60.0, Traffic_LevelCheck, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

public Action Traffic_LevelCheck(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		if(Level[client] < TRAFFIC_LEVEL)
			return Plugin_Continue;
		
		if(Level[client] == TRAFFIC_LEVEL && TextStore_GetItemCount(client, TRAFFIC_TICKET) < 1)
		{
			TicketQueue.Push(userid);
			if(!TicketTimer)
				CheckTickets();
		}
	}
	return Plugin_Stop;
}

public Action Traffic_CheckTickets(Handle timer)
{
	CheckTickets();
	return Plugin_Continue;
}

static void CheckTickets()
{
	delete TicketTimer;

	float gameTime = GetGameTime();
	float lowest = FAR_FUTURE;

	bool found;
	for(int i; i < sizeof(NextTicket); i++)
	{
		if(!found && NextTicket[i] < gameTime)
		{
			found = true;

			while(TicketQueue.Length)
			{
				int client = GetClientOfUserId(TicketQueue.Get(0));
				TicketQueue.Erase(0);

				if(client)
				{
					NextTicket[i] = gameTime + TRAFFIC_TIME;
					ClientCommand(client, "playgamesound ui/system_message_alert.wav");
					TextStore_AddItemCount(client, TRAFFIC_TICKET, 1);
					found = true;
					break;
				}
			}
		}

		float time = NextTicket[i] - gameTime;
		if(time < lowest)
			lowest = time;
	}
		
	if(lowest > 0.0 && lowest != FAR_FUTURE)
		TicketTimer = CreateTimer(lowest, Traffic_CheckTickets);
}