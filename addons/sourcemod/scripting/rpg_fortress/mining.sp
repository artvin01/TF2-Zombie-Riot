#pragma semicolon 1
#pragma newdecls required

enum struct MineEnum
{
	char Zone[32];
	
	char Model[PLATFORM_MAX_PATH];
	float Pos[3];
	float Ang[3];
	float Scale;
	int Color[4];
	
	char Item[48];
	int Health;
	int Tier;

	int EntRef;
	
	void SetupEnum(KeyValues kv)
	{
		kv.GetString("zone", this.Zone, 32);
		
		kv.GetString("model", this.Model, PLATFORM_MAX_PATH, "models/error.mdl");
		if(!this.Model[0])
			SetFailState("Missing model in mining.cfg");
		
		PrecacheModel(this.Model);
		
		kv.GetVector("pos", this.Pos);
		kv.GetVector("ang", this.Ang);
		kv.GetColor("color", this.Color[0], this.Color[1], this.Color[2], this.Color[3]);
		this.Scale = kv.GetFloat("scale", 1.0);

		kv.GetString("item", this.Item, 48);
		this.Health = kv.GetNum("health");
		this.Tier = kv.GetNum("tier");

		this.EntRef = INVALID_ENT_REFERENCE;
	}
	
	void Despawn()
	{
		if(this.EntRef != INVALID_ENT_REFERENCE)
		{
			int entity = EntRefToEntIndex(this.EntRef);
			if(entity != -1)
				RemoveEntity(entity);
			
			this.EntRef = INVALID_ENT_REFERENCE;
		}
	}
	
	void Spawn()
	{
		if(this.EntRef == INVALID_ENT_REFERENCE)
		{
			int entity = CreateEntityByName("prop_dynamic_override");
			if(IsValidEntity(entity))
			{
				DispatchKeyValue(entity, "targetname", "rpg_fortress");
				DispatchKeyValue(entity, "model", this.Model);
				DispatchKeyValue(entity, "solid", "6");
				
				DispatchSpawn(entity);

				TeleportEntity(entity, this.Pos, this.Ang, NULL_VECTOR);
				/*
				float vector[3];

				vector = this.Pos;
				PrintToChatAll("%f",vector[0]);
				PrintToChatAll("%f",vector[1]);
				PrintToChatAll("%f",vector[2]);
				*/
				SetEntPropFloat(entity, Prop_Send, "m_flModelScale", this.Scale);
				
				SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
				SetEntityRenderColor(entity, this.Color[0], this.Color[1], this.Color[2], this.Color[3]);
				
				this.EntRef = EntIndexToEntRef(entity);
			}
		}
	}
}

static ArrayList MineList;
static int MineDamage[MAXTF2PLAYERS];

void Mining_ConfigSetup(KeyValues map)
{
	KeyValues kv = map;
	if(kv)
	{
		kv.Rewind();
		if(!kv.JumpToKey("Mining"))
			kv = null;
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if(!kv)
	{
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "mining");
		kv = new KeyValues("Mining");
		kv.ImportFromFile(buffer);
	}
	
	delete MineList;
	MineList = new ArrayList(sizeof(MineEnum));

	MineEnum mine;

	kv.GotoFirstSubKey();
	do
	{
		kv.GetSectionName(mine.Zone, sizeof(mine.Zone));

		if(kv.GotoFirstSubKey())
		{
			do
			{
				mine.SetupEnum(kv);
				MineList.PushArray(mine);
			}
			while(kv.GotoNextKey());
			kv.GoBack();
		}
	}
	while(kv.GotoNextKey());

	if(kv != map)
		delete kv;
}

void Mining_EnableZone(const char[] name)
{
	int length = MineList.Length;
	for(int i; i < length; i++)
	{
		static MineEnum mine;
		MineList.GetArray(i, mine);
		if(StrEqual(mine.Zone, name))
		{
			mine.Spawn();
			MineList.SetArray(i, mine);
		}
	}
}

void Mining_DisableZone(const char[] name)
{
	int length = MineList.Length;
	for(int i; i < length; i++)
	{
		static MineEnum mine;
		MineList.GetArray(i, mine);
		if(StrEqual(mine.Zone, name))
		{
			mine.Despawn();
			MineList.SetArray(i, mine);
		}
	}
}

public void Mining_PickaxeM1(int client, int weapon, const char[] classname, bool &result)
{
	Handle tr;
	float forwar[3];
	DoSwingTrace_Custom(tr, client, forwar);

	int target = TR_GetEntityIndex(tr);

	int index = MineList.FindValue(EntIndexToEntRef(target), MineEnum::EntRef);
	if(index != -1)
	{
		static MineEnum mine;
		MineList.GetArray(index, mine);

		int tier = RoundFloat(Attributes_FindOnWeapon(client, weapon, 2017));
		if(tier < mine.Tier)
		{
			ShowGameText(client, "ico_metal", 0, "You need atleast %s tier to mine this!", MiningLevels[mine.Tier]);
		}
		else
		{
			int damage = RoundFloat(Attributes_FindOnWeapon(client, weapon, 2016, true));

			Event event = CreateEvent("npc_hurt", true);
			event.SetInt("entindex", target);
			event.SetInt("attacker_player", GetClientUserId(client));
			event.SetInt("weaponid", weapon);
			event.SetInt("damageamount", damage);
			event.SetInt("health", 999999);
			event.SetBool("crit", false);
			event.FireToClient(client);
			event.Cancel();
			
			MineDamage[client] += damage;
			if(MineDamage[client] >= mine.Health)
			{
				GetClientEyePosition(client, forwar);
				TextStore_DropNamedItem(mine.Item, forwar, 1);
				MineDamage[client] = 0;
			}
		}
	}
}