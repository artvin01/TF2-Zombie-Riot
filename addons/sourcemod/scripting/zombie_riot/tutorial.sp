bool b_IsInTutorialMode[MAXTF2PLAYERS];
int i_TutorialStep[MAXTF2PLAYERS];
float f_TutorialUpdateStep[MAXTF2PLAYERS];

static Cookie TutorialCheck;
static Handle SyncHud;


public void Tutorial_PluginStart()
{
	TutorialCheck = new Cookie("zr_tutorial_check", "Has the player done the tutorial?", CookieAccess_Protected);
	SyncHud = CreateHudSynchronizer();
}


public void Tutorial_LoadCookies(int client)
{
	char buffer[12];
	TutorialCheck.Get(client, buffer, sizeof(buffer));
	
	f_TutorialUpdateStep[client] = 0.0;
	
	if(StringToInt(buffer) != 2)
	{
	 	StartTutorial(client);
	}
	else
	{
		SetClientTutorialStep(client, 0);
		b_IsInTutorialMode[client] = false;
	}
}

		
/*
	float chargerPos[3];
	GetClientEyePosition(client, chargerPos);
	ShowAnnotationToPlayer(client, chargerPos, "Press Tab to open the store!", 5.0, client);
*/

public void StartTutorial(int client)
{
	SetClientTutorialMode(client, true);
	SetClientTutorialStep(client, 1);
}

public void SetTutorialUpdateTime(int client, float time)
{
	f_TutorialUpdateStep[client] = time;
}

public bool IsClientInTutorial(int client)
{
	return b_IsInTutorialMode[client];
}

public int ClientTutorialStep(int client)
{
	return i_TutorialStep[client];
}

public void SetClientTutorialMode(int client, bool set_tutorial)
{
	b_IsInTutorialMode[client] = set_tutorial;
}

public void SetClientTutorialStep(int client, int stepcount)
{
	i_TutorialStep[client] = stepcount;
}


public void Tutorial_MakeClientNotMove(int client)
{
	if(IsClientInTutorial(client) && TeutonType[client] != TEUTON_WAITING)
	{
		DoTutorialStep(client, true);
	}
}


public void DoTutorialStep(int client, bool obeycooldown)
{
	if(IsClientInTutorial(client) && ClientTutorialStep(client) != 0 && TeutonType[client] != TEUTON_WAITING)
	{
		if(f_TutorialUpdateStep[client] < GetGameTime() || !obeycooldown)
		{
			f_TutorialUpdateStep[client] = GetGameTime() + 1.0;
			
			/*TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, {0.0,0.0,0.0});
			
			float vecSwingStart[3];
			float ang[3];
			GetClientEyePosition(client, vecSwingStart);
			GetClientEyeAngles(client, ang);
					
			float vecSwingForward[3];
			GetAngleVectors(ang, vecSwingForward, NULL_VECTOR, NULL_VECTOR);
					
			float vecSwingEnd[3];
			vecSwingEnd[0] = vecSwingStart[0] + vecSwingForward[0] * 30.0;
			vecSwingEnd[1] = vecSwingStart[1] + vecSwingForward[1] * 30.0;
			vecSwingEnd[2] = vecSwingStart[2] + vecSwingForward[2] * 30.0;
			
			char TutorialText[256];*/
			switch(i_TutorialStep[client])
			{
				case 1:
				{
					SetGlobalTransTarget(client);
					SetHudTextParams(-1.0, -1.0, 1.5, 255, 0, 0, 255);
					ShowSyncHudText(client, SyncHud, "%t", "tutorial_1");
					//"This is the short Tutorial. Open chat and type /store to open the store!"
					
					//ShowAnnotationToPlayer(client, vecSwingEnd, TutorialText, 5.0, -1);
				}
				case 2:
				{
					SetGlobalTransTarget(client);
					SetHudTextParams(-1.0, -1.0, 1.5, 255, 0, 0, 255);
					ShowSyncHudText(client, SyncHud, "%t", "tutorial_2");
					//ShowAnnotationToPlayer(client, vecSwingEnd, TutorialText, 5.0, -1);
					//"Good! You can also Open the store with TAB when the tutorial is done.\nNow Navigate to weapons and buy any weapon you want."
				}
				case 3:
				{
					SetGlobalTransTarget(client);
					SetHudTextParams(-1.0, -1.0, 8.0, 255, 0, 0, 255);
					ShowSyncHudText(client, SyncHud, "%t", "tutorial_3");
					f_TutorialUpdateStep[client] = GetGameTime() + 8.0;
					//ShowAnnotationToPlayer(client, vecSwingEnd, TutorialText, 8.0, -1);
					//"Now that you have a weapon you're prepared.\nBuy better guns and upgrades in later waves and survive to the end!\nFurther help can be found in the store under ''help?''\nTeamwork is the key to victory!"
				
					//two means done.
					
					TutorialCheck.Set(client, "2");
	
					CreateTimer(8.0, TimerTutorial_End, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}
}

public Action TimerTutorial_End(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client))
	{
		SetClientTutorialMode(client, false);
		SetClientTutorialStep(client, 0);
		
		/*float pos[3], ang[3];
		GetEntPropVector(client, Prop_Data, "m_vecOrigin", pos);
		GetEntPropVector(client, Prop_Data, "m_angRotation", ang);
		DHook_RespawnPlayer(client);
		
		SetEntProp(client, Prop_Send, "m_bDucked", true);
		SetEntityFlags(client, GetEntityFlags(client)|FL_DUCKING);
		if (TeutonType[client] == TEUTON_NONE) 
		{
			CClotBody npc = view_as<CClotBody>(client);
			npc.m_bThisEntityIgnored = false;
		}
		TeleportEntity(client, pos, ang, NULL_VECTOR);
					
		TF2_RemoveCondition(client, TFCond_FreezeInput); //make it 1 second long, incase anything breaks, that itll kill itself eventually.
		TF2_AddCondition(client, TFCond_UberchargedCanteen, 5.0); //Give 5 seconds of uber so they dont get instamurdered.*/
	}
	return Plugin_Handled;
}

