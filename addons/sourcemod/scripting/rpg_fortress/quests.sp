#pragma semicolon 1
#pragma newdecls required

static KeyValues QuestKv;
static KeyValues SaveKv;
static char CurrentNPC[MAXTF2PLAYERS][64];
static char CurrentQuest[MAXTF2PLAYERS][64];

void Quests_ConfigSetup(KeyValues map)
{
	delete QuestKv;
	delete SaveKv;

	if(map)
	{
		map.Rewind();
		if(map.JumpToKey("Quests"))
			QuestKv = map.Import();
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if(!QuestKv)
	{
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "quests");
		QuestKv = new KeyValues("Quests");
		QuestKv.ImportFromFile(buffer);
	}

	QuestKv.GotoFirstSubKey();
	do
	{
		QuestKv.GetString("model", buffer, sizeof(buffer));
		if(!buffer[0])
			SetFailState("Missing model in quests.cfg");
		
		PrecacheModel(buffer);

		QuestKv.GetString("wear1", buffer, sizeof(buffer));
		if(buffer[0])
			PrecacheModel(buffer);

		QuestKv.GetString("wear2", buffer, sizeof(buffer));
		if(buffer[0])
			PrecacheModel(buffer);

		QuestKv.GetString("wear3", buffer, sizeof(buffer));
		if(buffer[0])
			PrecacheModel(buffer);
		
		QuestKv.GetString("sound_talk", buffer, sizeof(buffer));
		if(buffer[0])
			PrecacheScriptSound(buffer);
		
		QuestKv.GetString("sound_leave", buffer, sizeof(buffer));
		if(buffer[0])
			PrecacheScriptSound(buffer);
		
		if(QuestKv.GotoFirstSubKey())
		{
			do
			{
				QuestKv.GetString("sound_start", buffer, sizeof(buffer));
				if(buffer[0])
					PrecacheScriptSound(buffer);
				
				QuestKv.GetString("sound_turnin", buffer, sizeof(buffer));
				if(buffer[0])
					PrecacheScriptSound(buffer);
			}
			while(QuestKv.GotoNextKey());

			QuestKv.GoBack();
		}
	}
	while(QuestKv.GotoNextKey());

	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "quests_savedata");
	SaveKv = new KeyValues("SaveData");
	SaveKv.ImportFromFile(buffer);
}

void Quests_EnableZone(const char[] name)
{
	QuestKv.Rewind();
	QuestKv.GotoFirstSubKey();
	do
	{
		static char buffer[PLATFORM_MAX_PATH];
		QuestKv.GetString("zone", buffer, sizeof(buffer));
		if(StrEqual(buffer, name, false))
		{
			int entity = EntRefToEntIndex(QuestKv.GetNum("_entref", INVALID_ENT_REFERENCE));
			if(entity == INVALID_ENT_REFERENCE)
			{
				entity = CreateEntityByName("prop_dynamic_override");
				if(IsValidEntity(entity))
				{
					static float pos[3], ang[3];
					
					DispatchKeyValue(entity, "targetname", "rpg_fortress");

					QuestKv.GetString("model", buffer, sizeof(buffer));
					DispatchKeyValue(entity, "model", buffer);
					
					QuestKv.GetVector("pos", pos);
					QuestKv.GetVector("ang", ang);
					TeleportEntity(entity, pos, ang, NULL_VECTOR);
					
					DispatchSpawn(entity);
					SetEntityCollisionGroup(entity, 2);
					
					QuestKv.GetString("wear1", buffer, sizeof(buffer));
					if(buffer[0])
						GivePropAttachment(entity, buffer);
					
					QuestKv.GetString("wear2", buffer, sizeof(buffer));
					if(buffer[0])
						GivePropAttachment(entity, buffer);
					
					QuestKv.GetString("wear3", buffer, sizeof(buffer));
					if(buffer[0])
						GivePropAttachment(entity, buffer);
					
					SetEntPropFloat(entity, Prop_Send, "m_flModelScale", QuestKv.GetFloat("scale", 1.0));
					
					QuestKv.GetString("anim_idle", buffer, sizeof(buffer));
					SetVariantString(buffer);
					AcceptEntityInput(entity, "SetDefaultAnimation", entity, entity);
					
					QuestKv.SetNum("_entref", EntIndexToEntRef(entity));
				}
			}
		}
	}
	while(QuestKv.GotoNextKey());
}

void Quests_DisableZone(const char[] name)
{
	QuestKv.Rewind();
	QuestKv.GotoFirstSubKey();
	do
	{
		static char buffer[32];
		QuestKv.GetString("zone", buffer, sizeof(buffer));
		if(StrEqual(buffer, name, false))
		{
			int entity = EntRefToEntIndex(QuestKv.GetNum("_entref", INVALID_ENT_REFERENCE));
			if(entity != INVALID_ENT_REFERENCE)
				RemoveEntity(entity);
			
			QuestKv.SetNum("_entref", INVALID_ENT_REFERENCE);
		}
	}
	while(QuestKv.GotoNextKey());
}

bool Quests_Interact(int client, int entity)
{
	QuestKv.Rewind();
	QuestKv.GotoFirstSubKey();
	do
	{
		if(EntRefToEntIndex(QuestKv.GetNum("_entref", INVALID_ENT_REFERENCE)) == entity)
		{
			QuestKv.GetSectionName(CurrentNPC[client], sizeof(CurrentNPC[]));
			MainMenu(client);
			return true;
		}
	}
	while(QuestKv.GotoNextKey());
	return false;
}

void Quests_MainMenu(int client, const char[] name)
{
	QuestKv.Rewind();
	if(QuestKv.JumpToKey(name))
	{
		strcopy(CurrentNPC[client], sizeof(CurrentNPC[]));
		MainMenu(client);
	}
}

static void MainMenu(int client)
{
	SaveKv.Rewind();
	SaveKv.JumpToKey(CurrentNPC[client], true);
	
	Menu menu = new Menu(Quests_MenuHandle);
	menu.SetTitle("%s\n ", CurrentNPC[client]);

	static char steamid[64], buffer[256];
	if(GetClientAuthId(client, AuthId_Steam3, steamid, sizeof(steamid)))
	{
		QuestKv.GotoFirstSubKey();
		do
		{
			QuestKv.GetSectionName(buffer, sizeof(buffer));
			SaveKv.JumpToKey(buffer, true);
			menu.AddItem(NULL_STRING, buffer);
		}
		while(QuestKv.GotoNextKey());
	}
}

public int Quests_MenuHandle(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
		}
	}
	return 0;
}