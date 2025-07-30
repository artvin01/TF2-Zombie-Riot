#pragma semicolon 1
#pragma newdecls required

bool b_IsInTutorialMode[MAXPLAYERS];
int i_TutorialStep[MAXPLAYERS];
bool b_GrantFreeItemsOnce[MAXPLAYERS];

static Handle SyncHud;
float CDDisplayHint_LoadoutStore[MAXPLAYERS];

void Tutorial_PluginStart()
{
	SyncHud = CreateHudSynchronizer();
}
void Tutorial_MapStart()
{
	Zero(CDDisplayHint_LoadoutStore);
}

void Tutorial_ClientSetup(int client, int value)
{
	if(CvarInfiniteCash.BoolValue)
	{
		TutorialEndFully(client);
		return;
	}
	f_TutorialUpdateStep[client] = 0.0;

	if(value != 6)
	{
	 	StartTutorial(client);
		//in tutorial mode, give enough so they can build both at once and enough metal too.
		b_GrantFreeItemsOnce[client] = true;
	}
	else
	{
		//reset tutorial to start if they didnt buy anything.
		if(value <= 3)
			value = 0;
		b_GrantFreeItemsOnce[client] = true;
		SetClientTutorialStep(client, 0);
		b_IsInTutorialMode[client] = false;
	}
}

		
/*
	float chargerPos[3];
	GetClientEyePosition(client, chargerPos);
	ShowAnnotationToPlayer(client, chargerPos, "Press Tab to open the store!", 5.0, client);
*/

void StartTutorial(int client)
{
	SetClientTutorialMode(client, true);
	SetClientTutorialStep(client, 1);
}

void SetTutorialUpdateTime(int client, float time)
{
	f_TutorialUpdateStep[client] = time;
}

bool IsClientInTutorial(int client)
{
	return b_IsInTutorialMode[client];
}

int ClientTutorialStep(int client)
{
	return i_TutorialStep[client];
}

void SetClientTutorialMode(int client, bool set_tutorial)
{
	b_IsInTutorialMode[client] = set_tutorial;
}

void SetClientTutorialStep(int client, int stepcount)
{
	i_TutorialStep[client] = stepcount;
}


void Tutorial_MakeClientNotMove(int client)
{
	if(IsClientInTutorial(client) && TeutonType[client] != TEUTON_WAITING)
	{
		DoTutorialStep(client, true);
	}
}

void DoTutorialStep(int client, bool obeycooldown)
{
	if(i_TutorialStep[client] >= 4 || i_TutorialStep[client] == 0)
	{
		if(StarterCashMode[client])
		{
			if(CDDisplayHint_LoadoutStore[client] < GetGameTime())
			{
				CDDisplayHint_LoadoutStore[client] = GetGameTime() + 1.0;
				SetHudTextParams(-1.0, 0.7, 1.1, 255, 255, 255, 255);
				ShowSyncHudText(client, SyncHud, "%T", "Loadout In Store", client);
				//try!
			}
			return;
		}
	}

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
			static int UniqueIdDo;
			switch(i_TutorialStep[client])
			{
				case 1:
				{
					SetGlobalTransTarget(client);
					SetHudTextParams(-1.0, 0.4, 1.5, 255, 255, 255, 255);
					ShowSyncHudText(client, SyncHud, "%t", "tutorial_1");
					//"This is the short Tutorial. Open chat and type /store to open the store!"
					
					//ShowAnnotationToPlayer(client, vecSwingEnd, TutorialText, 5.0, -1);
				}
				case 2:
				{
					SetGlobalTransTarget(client);
					SetHudTextParams(-1.0, 0.4, 1.5, 255, 255, 255, 255);
					ShowSyncHudText(client, SyncHud, "%t", "tutorial_2");
					//ShowAnnotationToPlayer(client, vecSwingEnd, TutorialText, 5.0, -1);
					//"Good! You can also Open the store with TAB when the tutorial is done.\nNow Navigate to weapons and buy any weapon you want."
				}
				case 3:
				{
					SetGlobalTransTarget(client);
					SetHudTextParams(-1.0, 0.4, 10.0, 255, 255, 255, 255);
					ShowSyncHudText(client, SyncHud, "%t", "tutorial_3");
					SPrintToChat(client,"%t","tutorial_3");
					f_TutorialUpdateStep[client] = GetGameTime() + 10.0;
					SetClientTutorialStep(client, 4);
					//ShowAnnotationToPlayer(client, vecSwingEnd, TutorialText, 8.0, -1);
					//"Now that you have a weapon you're prepared.\nBuy better guns and upgrades in later waves and survive to the end!\nFurther help can be found in the store under ''help?''\nTeamwork is the key to victory!"
				}
				case 4:
				{
					if(TeutonType[client] == TEUTON_NONE)
					{
						if(b_GrantFreeItemsOnce[client] && Level[client] < 5)
						{
							b_GrantFreeItemsOnce[client] = false;
							Store_GiveSpecificItem(client, "Construction Novice");
							SetAmmo(client, Ammo_Metal, 2500);
							CurrentAmmo[client][3] = GetAmmo(client, 3);
						}
						SetGlobalTransTarget(client);

						int entity = MaxClients + 1;
						char buffer[255];
						bool FoundOne = false;
						while((entity = FindEntityByClassname(entity, "obj_building")) != -1)
						{
							NPC_GetPluginById(i_NpcInternalId[entity], buffer, sizeof(buffer));
							if(!StrContains(buffer, "obj_perkmachine"))
							{
								float vecTarget[3];
								vecTarget[2] += 60.0;
								
								SetGlobalTransTarget(client);
								Format(buffer, sizeof(buffer), "%t", "Tutorial Show Hint Perk Machine");
								Event event = CreateEvent("show_annotation");
								FoundOne = true;
								if(event)
								{
									event.SetFloat("worldNormalX", vecTarget[0]);
									event.SetFloat("worldNormalY", vecTarget[1]);
									event.SetFloat("worldNormalZ", vecTarget[2]);
									event.SetInt("follow_entindex", entity);
									event.SetFloat("lifetime", 10.0);
									event.SetString("text", buffer);
									event.SetString("play_sound", "vo/null.mp3");
									KillMostCurrentIDAnnotation(client, i_CurrentIdBeforeAnnoation[client]);
									UniqueIdDo++;
									event.SetInt("id", UniqueIdDo);
									i_CurrentIdBeforeAnnoation[client] = UniqueIdDo;
									event.FireToClient(client);
								}
								break;
							}
						}
						if(!FoundOne)
							SPrintToChat(client,"%t","Tutorial Show Hint Perk Machine Build One");
						f_TutorialUpdateStep[client] = GetGameTime() + 20.0;
					}
				}
				case 5:
				{
					if(TeutonType[client] == TEUTON_NONE)
					{
						if(b_GrantFreeItemsOnce[client])
						{
							b_GrantFreeItemsOnce[client] = false;
							Store_GiveSpecificItem(client, "Construction Novice");
							SetAmmo(client, Ammo_Metal, 2500);
							CurrentAmmo[client][3] = GetAmmo(client, 3);
						}
						bool FoundOne = false;
						int entity = MaxClients + 1;
						char buffer[255];
						while((entity = FindEntityByClassname(entity, "obj_building")) != -1)
						{
							NPC_GetPluginById(i_NpcInternalId[entity], buffer, sizeof(buffer));
							if(!StrContains(buffer, "obj_packapunch"))
							{
								float vecTarget[3];
								vecTarget[2] += 60.0;

								SetGlobalTransTarget(client);
								Format(buffer, sizeof(buffer), "%t", "Tutorial Show Hint Pack a Punch");
								Event event = CreateEvent("show_annotation");
								FoundOne = true;
								if(event)
								{
									event.SetFloat("worldNormalX", vecTarget[0]);
									event.SetFloat("worldNormalY", vecTarget[1]);
									event.SetFloat("worldNormalZ", vecTarget[2]);
									event.SetInt("follow_entindex", entity);
									event.SetFloat("lifetime", 10.0);
									event.SetString("text", buffer);
									event.SetString("play_sound", "vo/null.mp3");
									KillMostCurrentIDAnnotation(client, i_CurrentIdBeforeAnnoation[client]);
									UniqueIdDo++;
									event.SetInt("id", UniqueIdDo);
									i_CurrentIdBeforeAnnoation[client] = UniqueIdDo;
									event.FireToClient(client);
								}
								break;
							}
						}
						if(!FoundOne)
							SPrintToChat(client,"%t","Tutorial Show Hint Pack a Punch Build One");

						f_TutorialUpdateStep[client] = GetGameTime() + 20.0;
					}
				}
				case 6:
				{
					
					SetGlobalTransTarget(client);
					SetHudTextParams(-1.0, 0.4, 10.0, 255, 255, 255, 255);
					ShowSyncHudText(client, SyncHud, "%t", "tutorial_4");
					f_TutorialUpdateStep[client] = GetGameTime() + 20.0;
					SetClientTutorialStep(client, 7);
				}
				case 7:
				{
					
					SetGlobalTransTarget(client);
					SetHudTextParams(-1.0, 0.4, 10.0, 255, 255, 255, 255);
					ShowSyncHudText(client, SyncHud, "%t", "tutorial_5");
					TutorialEndFully(client);
				}
			}
		}
	}
}

void KillMostCurrentIDAnnotation(int client, int id)
{
	Event event = CreateEvent("hide_annotation");
	if(event)
	{
		event.SetInt("id", id);
		event.FireToClient(client);
	}
}


void TutorialEndFully(int client)
{
	Database_GlobalSetInt(client, DATATABLE_MISC, "tutorial", 6);
	SetClientTutorialMode(client, false);
}