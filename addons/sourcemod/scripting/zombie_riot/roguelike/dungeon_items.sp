#pragma semicolon 1
#pragma newdecls required

static StringMap ItemsGiven;
static StringMap MatGiven;
static Handle StuffTimer;

void ItemMessage(const char[] string, int amount)
{
	if(!ItemsGiven)
		ItemsGiven = new StringMap();

	if(StuffTimer)
		delete StuffTimer;
	
	StuffTimer = CreateTimer(1.0, Timer_StuffGive);

	int total;
	ItemsGiven.GetValue(string, total);
	total += amount;
	ItemsGiven.SetValue(string, total);
}

void MaterialDelay(const char[] string, int amount)
{
	if(!MatGiven)
		MatGiven = new StringMap();

	if(StuffTimer)
		delete StuffTimer;
	
	StuffTimer = CreateTimer(1.0, Timer_StuffGive);

	int total;
	MatGiven.GetValue(string, total);
	total += amount;
	MatGiven.SetValue(string, total);
}

static Action Timer_StuffGive(Handle timer)
{
	StuffTimer = null;

	if(ItemsGiven)
	{
		StringMapSnapshot snap = ItemsGiven.Snapshot();

		int length = snap.Length;
		for(int i; i < length; i++)
		{
			int amount = snap.KeyBufferSize(i) + 1;
			char[] name = new char[amount];
			snap.GetKey(i, name, amount);

			ItemsGiven.GetValue(name, amount);
			CPrintToChatAll("%t", name, amount);
		}

		delete ItemsGiven;
	}

	if(MatGiven)
	{
		StringMapSnapshot snap = MatGiven.Snapshot();

		int length = snap.Length;
		for(int i; i < length; i++)
		{
			int amount = snap.KeyBufferSize(i) + 1;
			char[] name = new char[amount];
			snap.GetKey(i, name, amount);

			MatGiven.GetValue(name, amount);
			Construction_AddMaterial(name, amount);
		}

		delete MatGiven;
	}

	EmitSoundToAll("ui/itemcrate_smash_common.wav");
	return Plugin_Continue;
}

public void Dungeon_EasyMode_Enemy(int entity)
{
	float stats = 0.85;

	fl_Extra_Damage[entity] *= stats;
	SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * stats));
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(ReturnEntityMaxHealth(entity) * stats));
}

public void Dungeon_Crate_Ammo()
{
	int amount = GetRandomInt(1, 3);
	Ammo_Count_Ready += amount;
	ItemMessage("Gained Ammo Supplies", amount);
}

public void Dungeon_Crate_Wood()
{
	int amount = GetRandomInt(1, 3);
	MaterialDelay("wood", amount);
}

public void Dungeon_Crate_Iron()
{
	int amount = GetRandomInt(4, 6);
	MaterialDelay("iron", amount);
}

public void Dungeon_Crate_Copper()
{
	int amount = GetRandomInt(4, 6);
	MaterialDelay("copper", amount);
}

public void Dungeon_Crate_Crystal()
{
	MaterialDelay("crystal", 1);
}

public void Dungeon_Crate_Crystal2()
{
	int amount = GetRandomInt(1, 3);
	MaterialDelay("crystal", amount);
}

public void Dungeon_Crate_BonusCash25()
{
	// 50
	int amount = GetRandomInt(30, 70);
	GlobalExtraCash += amount;
	ItemMessage("Gained Extra Cash", amount);
}

public void Dungeon_Crate_BonusCash100()
{
	int amount = GetRandomInt(50, 150);
	GlobalExtraCash += amount;
	ItemMessage("Gained Extra Cash", amount);
}

public void Dungeon_Crate_InscriptionFragment()
{
	Rogue_GiveNamedArtifact("Compass Fragment");
}

public void Dungeon_Crate_InscriptionWhole()
{
	Rogue_GiveNamedArtifact("Dungeon Compass");
}

public void Dungeon_Crate_KeyFragment()
{
	Rogue_GiveNamedArtifact("Key Fragment");
}

public void Dungeon_ShipEnding_Collect()
{
	if(Dungeon_Mode() && Dungeon_InSetup())
	{
		Dungeon_SetRandomMusic();
		CreateTimer(4.0, Timer_DialogueNewEnd, 0, TIMER_FLAG_NO_MAPCHANGE);
	}
}
static Action Timer_DialogueNewEnd(Handle timer, int part)
{
	switch(part)
	{
		case 0:
		{
			CPrintToChatAll("{gray}You hear radio chatter, it doesnt sound familiar to you, but the device {pink}Reila {gray}gave you blinks up, translating for you...");
		}
		case 1:
		{
			CPrintToChatAll("{violet}???{default}: Ruanian Magic is just fancy tech, it looks just like ours, its insane.");
		}
		case 2:
		{
			CPrintToChatAll("{mediumvioletred}???{default}: Well it barely worked, most of this is still our shit, its as if ruanians hate tech or something.");
		}
		case 3:
		{
			CPrintToChatAll("{mediumvioletred}???{default}: These crystals sure do have a lot of power from the curtain, CEO was right afterall.");
		}
		case 4:
		{
			CPrintToChatAll("{violet}???{default}: Isnt it unethical, like, there are people in those crystals and we just use that...");
		}
		case 5:
		{
			CPrintToChatAll("{mediumvioletred}???{default}: What? People? They arent sentient, Its a simulation remember, to keep us up incase someone invades?");
		}
		case 6:
		{
			CPrintToChatAll("{mediumvioletred}???{default}: Why the CEO would put up fake enemies is still beyond me, But money is money.");
		}
		case 7:
		{
			CPrintToChatAll("{gray}Some buttons can be heard being pressed, some loud engines...");
		}
		case 8:
		{
			CPrintToChatAll("{violet}???{default}: If its fake, then why are we trying to escape? Something's fishy.");
		}
		case 9:
		{
			CPrintToChatAll("{violet}???{default}: hey what are you doi-");
			CPrintToChatAll("{gray}Two loud gunshots can be heard, both bodies falling to the floor.");
		}
		case 10:
		{
			CPrintToChatAll("{gray}???{crimson}: Good employee's don't ask or question, don't break company policy.");
		}
		case 11:
		{
			CPrintToChatAll("{gray}???{crimson}: I know you have been listening in, we aren't idiots.");
		}
		case 12:
		{
			CPrintToChatAll("{gray}???{crimson}: You closed those gates on us, {red}i will end your life.");
		}
		case 13:
		{
			CPrintToChatAll("{gray}You hear some sounds you never heard before, then it shuts off.");
		}
		case 14:
		{
			CPrintToChatAll("{crimson}Someone found you, someone is after you, they arent going easy on you no more.");
		}
		default:
		{
			return Plugin_Continue;
		}
	}

	CreateTimer(4.0, Timer_DialogueNewEnd, part + 1, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}