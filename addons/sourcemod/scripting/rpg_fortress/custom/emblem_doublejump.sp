static bool AllowDoublejump[MAXPLAYERS+1]={false, ...};
static int g_fLastButtons[MAXPLAYERS+1]={0, ...};
static int g_fLastFlags[MAXPLAYERS+1]={0, ...};
static int g_iJumps[MAXPLAYERS+1]={0, ...};
int g_iJumpMax = 1;

// ported and adjusted from https://forums.alliedmods.net/showthread.php?p=895212
void DoubleJumpGameFrame()
{
	for (int i = 1; i <= MaxClients; i++) 
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && AllowDoublejump[i]) 
		{
			DoubleJump(i)
		}
	}
}

stock DoubleJump(int client) 
{
	int fCurFlags1	= GetEntityFlags(client);		// current flags
	int fCurButtons	= GetClientButtons(client);		// current buttons
	
	if (g_fLastFlags[client] & FL_ONGROUND) 
	{
		if (!(fCurFlags1 & FL_ONGROUND) && !(g_fLastButtons[client] & IN_JUMP) && fCurButtons & IN_JUMP) 
		{
			OriginalJump(client);				
		}
	} 
	else if (fCurFlags1 & FL_ONGROUND) 
	{
		Landed(client);				
	} 
	else if (!(g_fLastButtons[client] & IN_JUMP) &&fCurButtons & IN_JUMP) 
	{
		ReJump(client);							
	}
	
	g_fLastFlags[client]	= fCurFlags1			
	g_fLastButtons[client]	= fCurButtons			
}

stock OriginalJump(int client) 
{
	g_iJumps[client]++	// increment jump count
}

stock Landed(int  client) 
{
	g_iJumps[client] = 0	// reset jumps count
}

stock ReJump(int  client) {
	if ( 1 <= g_iJumps[client] <= g_iJumpMax) 
	{	
		// has jumped at least once but hasn't exceeded max re-jumps
		g_iJumps[client]++											// increment jump count
		float vVel[3]
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel)	// get current speeds
		
		vVel[2] = 250.0;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel)		// boost player
	}
}

public void FishingEmblemDoubleJumpUnequip(int client)
{
	AllowDoublejump[client] = false;
}

public void FishingEmblemDoubleJump(int client, int weapon, int index)
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		AllowDoublejump[client] = true;		
	}
}
