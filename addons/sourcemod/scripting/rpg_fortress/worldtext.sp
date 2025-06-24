#pragma semicolon 1
#pragma newdecls required

enum struct TextEnum
{
	char Zone[32];
	float Pos[3];
	float Ang[3];
	int EntRef;

	char message[256];
	float textsize;
	float textspacingX;
	float textspacingY;
	char color[20];
	int font;
	int orientation;
	int rainbow;

	void SetupKV(KeyValues kv)
	{
		kv.GetSectionName(this.message, sizeof(this.message));
		ExplodeStringFloat(this.message, " ", this.Pos, sizeof(this.Pos));

		kv.GetVector("ang", this.Ang);
		kv.GetString("zone", this.Zone, sizeof(this.Zone));

		kv.GetString("message", this.message, sizeof(this.message));
		ReplaceString(this.message, sizeof(this.message), "\\n", "\n");
		this.textsize = kv.GetFloat("textsize", 10.0);
		this.textsize = kv.GetFloat("textspacingX");
		this.textsize = kv.GetFloat("textspacingY");
		kv.GetString("color", this.color, sizeof(this.color), "255 255 255 255");
		this.font = kv.GetNum("font");
		this.orientation = kv.GetNum("orientation");
		this.rainbow = kv.GetNum("rainbow");
	}
	
	void Despawn()
	{
		if(this.EntRef != -1)
		{
			int entity = EntRefToEntIndex(this.EntRef);
			if(entity != -1)
				RemoveEntity(entity);

			this.EntRef = -1;
		}
	}
	
	void Spawn()
	{
		if(EntRefToEntIndex(this.EntRef) == -1)
		{
			int entity = CreateEntityByName("point_worldtext");
			if(IsValidEntity(entity))
			{
				DispatchKeyValue(entity, "targetname", "rpg_fortress");
				DispatchKeyValue(entity, "message", this.message);
				DispatchKeyValueFloat(entity, "textsize", this.textsize);
				DispatchKeyValueFloat(entity, "textspacingX", this.textspacingX);
				DispatchKeyValueFloat(entity, "textspacingY", this.textspacingY);
				DispatchKeyValue(entity, "color", this.color);
				DispatchKeyValueInt(entity, "font", this.font);
				DispatchKeyValueInt(entity, "orientation", this.orientation);
				DispatchKeyValueInt(entity, "rainbow", this.rainbow);
			//	SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", MIN_FADE_DISTANCE);
			//	SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", MAX_FADE_DISTANCE);
				DispatchSpawn(entity);
				TeleportEntity(entity, this.Pos, this.Ang, NULL_VECTOR, true);

				this.EntRef = EntIndexToEntRef(entity);
			}
		}
	}
}

static ArrayList TextList;

void Worldtext_ConfigSetup()
{
	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "worldtext");
	KeyValues kv = new KeyValues("Worldtext");
	kv.ImportFromFile(buffer);
	
	delete TextList;
	TextList = new ArrayList(sizeof(TextEnum));

	TextEnum text;
	text.EntRef = -1;

	if(kv.GotoFirstSubKey())
	{
		do
		{
			text.SetupKV(kv);
			TextList.PushArray(text);
		}
		while(kv.GotoNextKey());
	}

	delete kv;
}

void Worldtext_EnableZone(const char[] zone)
{
	if(TextList)
	{
		static TextEnum text;
		int length = TextList.Length;
		for(int i; i < length; i++)
		{
			TextList.GetArray(i, text);
			if(StrEqual(text.Zone, zone))
			{
				text.Spawn();
				TextList.SetArray(i, text);
			}
		}
	}
}

void Worldtext_DisableZone(const char[] zone)
{
	if(TextList)
	{
		static TextEnum text;
		int length = TextList.Length;
		for(int i; i < length; i++)
		{
			TextList.GetArray(i, text);
			if(StrEqual(text.Zone, zone))
			{
				text.Despawn();
				TextList.SetArray(i, text);
			}
		}
	}
}

static char CurrentKeyEditing[MAXPLAYERS][64];
static char CurrentSectionEditing[MAXPLAYERS][64];
static char CurrentZoneEditing[MAXPLAYERS][64];

void Worldtext_EditorMenu(int client)
{
	char buffer1[PLATFORM_MAX_PATH], buffer2[64];

	EditMenu menu = new EditMenu();

	if(StrEqual(CurrentKeyEditing[client], "message"))
	{
		RPG_BuildPath(buffer1, sizeof(buffer1), "worldtext");
		KeyValues kv = new KeyValues("Worldtext");
		kv.ImportFromFile(buffer1);
		kv.JumpToKey(CurrentSectionEditing[client]);

		kv.GetString("message", buffer1, sizeof(buffer1));
		ReplaceString(buffer1, sizeof(buffer1), "\\n", "\n");
		menu.SetTitle("%s\n ", buffer1);
		
		FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
		menu.AddItem("", buffer1, ITEMDRAW_DISABLED);

		menu.ExitBackButton = true;
		menu.Display(client, AdjustTextKey);

		delete kv;
	}
	else if(StrEqual(CurrentKeyEditing[client], "zone"))
	{
		menu.SetTitle("Worldtext\n%s\n ", CurrentSectionEditing[client]);
		
		FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
		menu.AddItem("", buffer1);

		Zones_GenerateZoneList(client, menu);

		menu.ExitBackButton = true;
		menu.Display(client, AdjustTextKey);
	}
	else if(StrEqual(CurrentKeyEditing[client], "font"))
	{
		menu.SetTitle("Worldtext\n%s\n ", CurrentSectionEditing[client]);
		
		FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
		menu.AddItem("", buffer1);

		menu.AddItem("0", "TF2 Build");
		menu.AddItem("1", "TF2 Build (no outline/shadow)");
		menu.AddItem("2", "TF2");
		menu.AddItem("3", "TF2 (no outline/shadow)");
		menu.AddItem("4", "Liberation Sans");
		menu.AddItem("5", "Liberation Sans (no outline/shadow)");
		menu.AddItem("6", "TF2 Professor");
		menu.AddItem("7", "TF2 Professor (no outline/shadow)");
		menu.AddItem("8", "Roboto Mono");
		menu.AddItem("9", "Roboto Mono (no outline/shadow)");
		menu.AddItem("10", "Roboto Mono (shadow only)");
		menu.AddItem("11", "Roboto Mono (green glow, soft edges)");
		menu.AddItem("12", "TF2 Build (soft edges)");

		menu.ExitBackButton = true;
		menu.Display(client, AdjustTextKey);
	}
	else if(StrEqual(CurrentKeyEditing[client], "orientation"))
	{
		menu.SetTitle("Worldtext\n%s\n ", CurrentSectionEditing[client]);
		
		FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
		menu.AddItem("", buffer1);

		menu.AddItem("0", "Stationary");
		menu.AddItem("1", "Face player");
		menu.AddItem("2", "Ignore pitch");

		menu.ExitBackButton = true;
		menu.Display(client, AdjustTextKey);
	}
	else if(CurrentKeyEditing[client][0])
	{
		menu.SetTitle("Worldtext\n%s\n ", CurrentSectionEditing[client]);
		
		FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
		menu.AddItem("", buffer1);

		menu.AddItem("", "Set To Default");

		menu.ExitBackButton = true;
		menu.Display(client, AdjustTextKey);
	}
	else if(CurrentSectionEditing[client][0])
	{
		menu.SetTitle("Worldtext\n%s\nClick to set it's value:\n ", CurrentSectionEditing[client]);
		
		RPG_BuildPath(buffer1, sizeof(buffer1), "worldtext");
		KeyValues kv = new KeyValues("Worldtext");
		kv.ImportFromFile(buffer1);
		bool missing = !kv.JumpToKey(CurrentSectionEditing[client]);

		FormatEx(buffer2, sizeof(buffer2), "Edit Dialogue");
		menu.AddItem("message", buffer2);
		
		FormatEx(buffer2, sizeof(buffer2), "Position: %s", CurrentSectionEditing[client]);
		menu.AddItem("pos", buffer2);
		
		float vec[3];
		kv.GetVector("ang", vec);
		FormatEx(buffer2, sizeof(buffer2), "Angle: %.0f %.0f %.0f", vec[0], vec[1], vec[2]);
		menu.AddItem("ang", buffer2);

		kv.GetString("zone", buffer1, sizeof(buffer1), missing ? CurrentZoneEditing[client] : "");
		FormatEx(buffer2, sizeof(buffer2), "Zone: \"%s\"", buffer1);
		menu.AddItem("zone", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Text Size: %.2f", kv.GetFloat("textsize", 10.0));
		menu.AddItem("textsize", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Text Spacing X: %.2f", kv.GetFloat("textspacingX"));
		menu.AddItem("textspacingX", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Text Spacing Y: %.2f", kv.GetFloat("textspacingY"));
		menu.AddItem("textspacingY", buffer2);

		kv.GetString("color", buffer1, sizeof(buffer1), "255 255 255 255");
		FormatEx(buffer2, sizeof(buffer2), "Color: \"%s\"", buffer1);
		menu.AddItem("color", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Font: %d", kv.GetNum("font"));
		menu.AddItem("font", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Orientation: %d", kv.GetNum("orientation"));
		menu.AddItem("orientation", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Rainbow: %s", kv.GetNum("rainbow") ? "On" : "Off");
		menu.AddItem("rainbow", buffer2);

		menu.AddItem("delete", "Delete (Type \"delete\")", ITEMDRAW_DISABLED);

		menu.ExitBackButton = true;
		menu.Display(client, AdjustText);
		
		delete kv;
	}
	else if(CurrentZoneEditing[client][0])
	{
		menu.SetTitle("Worldtext\n%s\nSelect a text:\n ", CurrentZoneEditing[client]);

		RPG_BuildPath(buffer1, sizeof(buffer1), "worldtext");
		KeyValues kv = new KeyValues("Worldtext");
		kv.ImportFromFile(buffer1);
		
		menu.AddItem("", "Create New Text");
		
		if(kv.GotoFirstSubKey())
		{
			do
			{
				kv.GetString("zone", buffer1, sizeof(buffer1));
				if(strlen(CurrentZoneEditing[client]) < 2 || StrEqual(buffer1, CurrentZoneEditing[client]))
				{
					kv.GetString("message", buffer2, sizeof(buffer2));
					kv.GetSectionName(buffer1, sizeof(buffer1));
					menu.AddItem(buffer1, buffer2);
				}
			}
			while(kv.GotoNextKey());
		}

		menu.ExitBackButton = true;
		menu.Display(client, TextPicker);

		delete kv;
	}
	else
	{
		menu.SetTitle("Worldtext\nSelect a zone:\n ");

		menu.AddItem(" ", "All Zones");

		Zones_GenerateZoneList(client, menu);

		menu.ExitBackButton = true;
		menu.Display(client, ZonePicker);
	}
}

static void ZonePicker(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		Editor_MainMenu(client);
		return;
	}

	strcopy(CurrentZoneEditing[client], sizeof(CurrentZoneEditing[]), key);
	Worldtext_EditorMenu(client);
}

static void TextPicker(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentZoneEditing[client][0] = 0;
		Worldtext_EditorMenu(client);
		return;
	}

	if(key[0])
	{
		strcopy(CurrentSectionEditing[client], sizeof(CurrentSectionEditing[]), key);
	}
	else
	{
		float pos[3];
		GetClientAbsOrigin(client, pos);
		FormatEx(CurrentSectionEditing[client], sizeof(CurrentSectionEditing[]), "%.0f %.0f %.0f", pos[0], pos[1], pos[2]);
	}

	Worldtext_EditorMenu(client);
}

static void AdjustText(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentSectionEditing[client][0] = 0;
		Worldtext_EditorMenu(client);
		return;
	}

	char filepath[PLATFORM_MAX_PATH];
	RPG_BuildPath(filepath, sizeof(filepath), "worldtext");
	KeyValues kv = new KeyValues("Worldtext");
	kv.ImportFromFile(filepath);
	
	if(!kv.JumpToKey(CurrentSectionEditing[client]))
	{
		kv.JumpToKey(CurrentSectionEditing[client], true);
		kv.SetString("zone", CurrentZoneEditing[client]);
	}

	if(StrEqual(key, "pos"))
	{
		char buffer[64];
		float pos[3];
		GetClientAbsOrigin(client, pos);
		FormatEx(buffer, sizeof(buffer), "%.0f %.0f %.0f", pos[0], pos[1], pos[2]);
		kv.SetSectionName(buffer);
		strcopy(CurrentSectionEditing[client], sizeof(CurrentSectionEditing[]), buffer);
	}
	else if(StrEqual(key, "ang"))
	{
		float ang[3];
		GetClientEyeAngles(client, ang);
		kv.SetVector(key, ang);
	}
	else if(StrEqual(key, "rainbow"))
	{
		kv.SetNum(key, kv.GetNum(key) ? 0 : 1);
	}
	else if(StrEqual(key, "delete"))
	{
		kv.DeleteThis();
		CurrentSectionEditing[client][0] = 0;
	}
	else
	{
		delete kv;
		
		strcopy(CurrentKeyEditing[client], sizeof(CurrentKeyEditing[]), key);
		Worldtext_EditorMenu(client);
		return;
	}

	kv.Rewind();
	kv.ExportToFile(filepath);
	delete kv;
	
	ReloadKv();
	Worldtext_EditorMenu(client);
}

static void AdjustTextKey(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentKeyEditing[client][0] = 0;
		Worldtext_EditorMenu(client);
		return;
	}

	char filepath[PLATFORM_MAX_PATH];
	RPG_BuildPath(filepath, sizeof(filepath), "worldtext");
	KeyValues kv = new KeyValues("Worldtext");
	kv.ImportFromFile(filepath);
	kv.JumpToKey(CurrentSectionEditing[client], true);

	if(key[0])
	{
		kv.SetString(CurrentKeyEditing[client], key);
	}
	else
	{
		kv.DeleteKey(CurrentKeyEditing[client]);
	}

	CurrentKeyEditing[client][0] = 0;

	kv.Rewind();
	kv.ExportToFile(filepath);
	delete kv;
	
	ReloadKv();
	Worldtext_EditorMenu(client);
}

static void ReloadKv()
{
	static TextEnum text;
	int length = TextList.Length;
	for(int i; i < length; i++)
	{
		TextList.GetArray(i, text);
		text.Despawn();
	}

	Worldtext_ConfigSetup();
	Zones_Rebuild();
}