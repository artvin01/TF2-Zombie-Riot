#pragma semicolon 1
#pragma newdecls required

#define ARRAY_SIZE	Ammo_MAX - Ammo_Jar
#define COOKIE_SIZE	(ARRAY_SIZE) * 13

static Cookie CookieAmmo;

void Ammo_PluginStart()
{
	CookieAmmo = new Cookie("rpg_ammo", "Reserve ammo", CookieAccess_Protected);
}

void Ammo_ClientCookiesCached(int client)
{
	static char buffer[COOKIE_SIZE];
	CookieAmmo.Get(client, buffer, sizeof(buffer));
	
	int ammo[ARRAY_SIZE];
	ExplodeStringInt(buffer, ";", ammo, sizeof(ammo));

	CurrentAmmo[client][Ammo_Metal] = ammo[0];
	for(int i = 1; i < sizeof(ammo); i++)
	{
		CurrentAmmo[client][i + Ammo_Jar] = ammo[i];
	}
}

void Ammo_ClientDisconnect(int client)
{
	if(AreClientCookiesCached(client))
	{
		static int ammo[ARRAY_SIZE];
		ammo[0] = CurrentAmmo[client][Ammo_Metal];
		for(int i = 1; i < sizeof(ammo); i++)
		{
			ammo[i] = CurrentAmmo[client][i + Ammo_Jar];
		}

		static char buffer[COOKIE_SIZE];
		MergeStringInt(ammo, sizeof(ammo), ";", buffer, sizeof(buffer));
		CookieAmmo.Set(client, buffer);
	}
}

void Ammo_DescItem(KeyValues kv, char[] desc)
{
	static char buffer[16];
	kv.GetString("type", buffer, sizeof(buffer));
	if(StrEqual(buffer, "healing"))
	{
		int amount = kv.GetNum("amount");
		Format(desc, 512, "%s\nHealing Amount: %d HP over %.1f seconds", desc, amount * kv.GetNum("healing"), amount * kv.GetFloat("interval"));
		if(!kv.GetNum("consume", 1))
			Format(desc, 512, "%s\nItem Not Consumed On Use", desc);
	}
}

public float Ammo_HealingSpell(int client, int index, char name[48])
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		StartHealingTimer(client, kv.GetFloat("interval"), kv.GetFloat("healing"), kv.GetNum("amount"), !kv.GetNum("overheal"));

		if(kv.GetNum("consume", 1))
		{
			int amount;
			TextStore_GetInv(client, index, amount);
			TextStore_SetInv(client, index, amount - 1, amount < 2 ? 0 : -1);
			if(amount < 2)
				name[0] = 0;

			kv.GetString("return", name, sizeof(name));
			if(name[0])
				TextStore_AddItemCount(client, name, 1);
		}
		else
		{
			kv.GetString("return", name, sizeof(name));
		}

		static char buffer[PLATFORM_MAX_PATH];
		kv.GetString("sound", buffer, sizeof(buffer));
		if(buffer[0])
			ClientCommand(client, "playgamesound %s", buffer);
	}
	return FAR_FUTURE;
}

public void Ammo_TagDeploy(int client, int weapon, int index)
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		kv.GetString("tagsforplayer", c_TagName[client],sizeof(c_TagName[]), "Newbie");
		kv.GetColor4("tagsforplayercolor", i_TagColor[client]);
		if(i_TagColor[client][3] == 0)
		{
			i_TagColor[client] =	{255,255,255,255};
		}
	}
}