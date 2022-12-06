#pragma semicolon 1
#pragma newdecls required

static KeyValues HashKey;

#define ITEM_XP		"Experience Points"
static int ItemXP = -1;

#define ITEM_TIER	"Elite Promotions"
static int ItemTier = -1;

enum struct StoreEnum
{
	char Tag[16];
	
	char Model[PLATFORM_MAX_PATH];
	char Intro[64];
	char Idle[64];
	float Pos[3];
	float Ang[3];
	float Scale;
	char Enter[64];
	char Talk[64];
	char Leave[64];
	
	char Wear1[PLATFORM_MAX_PATH];
	char Wear2[PLATFORM_MAX_PATH];
	char Wear3[PLATFORM_MAX_PATH];
	
	int EntRef[4];
	
	void SetupEnum(KeyValues kv)
	{
		kv.GetString("tag", this.Tag, 16);
		
		kv.GetString("model", this.Model, PLATFORM_MAX_PATH);
		if(this.Model[0])
		{
			this.Scale = kv.GetFloat("scale", 1.0);
			
			kv.GetString("anim_enter", this.Intro, 64);
			kv.GetString("anim_idle", this.Idle, 64);
			
			kv.GetVector("pos", this.Pos);
			kv.GetVector("ang", this.Ang);
			
			kv.GetString("wear1", this.Wear1, PLATFORM_MAX_PATH);
			if(this.Wear1[0])
				PrecacheModel(this.Wear1);
			
			kv.GetString("wear2", this.Wear2, PLATFORM_MAX_PATH);
			if(this.Wear2[0])
				PrecacheModel(this.Wear2);
			
			kv.GetString("wear3", this.Wear3, PLATFORM_MAX_PATH);
			if(this.Wear3[0])
				PrecacheModel(this.Wear3);
		}
		
		kv.GetString("sound_enter", this.Enter, 64);
		if(this.Enter[0])
			PrecacheScriptSound(this.Enter);
		
		kv.GetString("sound_buy", this.Talk, 64);
		if(this.Talk[0])
			PrecacheScriptSound(this.Talk);
		
		kv.GetString("sound_leave", this.Leave, 64);
		if(this.Leave[0])
			PrecacheScriptSound(this.Leave);
	}
	
	void PlayEnter(int client)
	{
		if(this.Enter[0])
		{
			int entity = client;
			if(this.EntRef != INVALID_ENT_REFERENCE)
				entity = EntRefToEntIndex(this.EntRef);
			
			EmitGameSoundToClient(client, this.Enter, entity);
		}
	}
	
	void PlayBuy(int client)
	{
		if(this.Talk[0])
		{
			int entity = client;
			if(this.EntRef != INVALID_ENT_REFERENCE)
				entity = EntRefToEntIndex(this.EntRef);
			
			EmitGameSoundToClient(client, this.Talk, entity);
		}
	}
	
	void PlayLeave(int client)
	{
		if(this.Leave[0])
		{
			int entity = client;
			if(this.EntRef != INVALID_ENT_REFERENCE)
				entity = EntRefToEntIndex(this.EntRef);
			
			EmitGameSoundToClient(client, this.Leave, entity);
		}
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
		if(this.EntRef == INVALID_ENT_REFERENCE && this.Model[0])
		{
			int entity = CreateEntityByName("prop_dynamic_override");
			if(IsValidEntity(entity))
			{
				DispatchKeyValue(entity, "model", this.Model);
				
				TeleportEntity(entity, this.Pos, this.Ang, NULL_VECTOR);
				
				DispatchSpawn(entity);
				SetEntityCollisionGroup(entity, 2);
				
				if(this.Extra1[0])
					GivePropAttachment(entity, this.Extra1);
				
				if(this.Extra2[0])
					GivePropAttachment(entity, this.Extra2);
				
				if(this.Extra3[0])
					GivePropAttachment(entity, this.Extra3);
				
				SetEntPropFloat(entity, Prop_Send, "m_flModelScale", this.Scale);
				
				SetVariantString(this.Idle);
				AcceptEntityInput(entity, "SetDefaultAnimation", entity, entity);
				
				if(this.Intro[0])
				{
					SetVariantString(this.Intro);
					AcceptEntityInput(entity, "SetAnimation", entity, entity);
				}
				
				this.EntRef = EntIndexToEntRef(entity);
			}
		}
	}
}

static StringMap StoreList;
static char InStore[MAXTF2PLAYERS][16];

static void HashCheck(KeyValues kv)
{
	if(kv != HashKey)
	{
		ItemXP = -1;
		ItemTier = -1;
		HashKey = kv;
	}
}

void TextStore_ConfigSetup((KeyValues map)
{
	KeyValues kv = map;
	if(kv)
	{
		kv.Rewind();
		if(!kv.JumpToKey("Stores"))
			kv = null;
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if(!kv)
	{
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "stores");
		kv = new KeyValues("Stores");
		kv.ImportFromFile(buffer);
	}
	
	delete StoreList;
	StoreList = new StringMap();

	StoreEnum store;
	store.EntRef = INVALID_ENT_REFERENCE;

	kv.GotoFirstSubKey();
	do
	{
		kv.GetSectionName(buffer, sizeof(buffer));
		store.SetupEnum(kv);
		StoreList.SetArray(buffer, store, sizeof(store));
	}
	while(kv.GotoNextKey());

	if(kv != map)
		delete kv;
	
	HashCheck(TextStore_GetItemKv(0));
	for(int client = 1; client <= MaxClients; client++)
	{
		InStore[client][0] = 0;
		if(IsClientInGame(client) && TextStore_GetClientLoad(client))
			LoadItems(client);
	}
}

public ItemResult TextStore_Item(int client, bool equipped, KeyValues item, int index, const char[] name, int &count, bool auto)
{
	HashCheck(item);

	if(equipped)
		return Item_Off;
	
	Store_EquipItem(client, item, index, name, auto);
	return Item_On;
}

public Action TextStore_OnClientLoad(int client, char file[PLATFORM_MAX_PATH])
{
	RequestFrame(TextStore_LoadFrame, GetClientUserId(client));
	return Plugin_Continue;
}

public void TextStore_LoadFrame(int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		if(TextStore_GetClientLoad(client))
		{
			HashCheck(TextStore_GetItemKv(0));
			LoadItems(client);
		}
		else
		{
			RequestFrame(TextStore_LoadFrame, userid);
		}
	}
}

static void LoadItems(int client)
{
	char buffer[48];
	int length = TextStore_GetItems();
	for(int i; i < length; i++)
	{
		TextStore_GetItemName(i, buffer, sizeof(buffer));
		if(StrEqual(buffer, ITEM_XP, false))
		{
			TextStore_GetInv(client, i, XP[client]);
			ItemXP = i;
		}
		else if(StrEqual(buffer, ITEM_TIER, false))
		{
			TextStore_GetInv(client, i, Tier[client]);
			ItemTier = i;
		}
	}

	Level[client] = XpToLevel(XP[client]);
	int cap = GetLevelCap(Tier[client]);
	if(Level[client] > cap)
		Level[client] = cap;
}

void TextStore_AddXP(int client, int xp)
{
	HashCheck(TextStore_GetItemKv(0));
	if(ItemXP != -1)
	{
		TextStore_GetInv(client, ItemXP, XP[client]);
		XP[client] += xp;
		TextStore_SetInv(client, ItemXP, XP[client]);
	}
}

stock void TextStore_AddTier(int client)
{
	HashCheck(TextStore_GetItemKv(0));
	if(ItemTier != -1)
	{
		TextStore_GetInv(client, ItemTier, Tier[client]);
		Tier[client]++;
		TextStore_SetInv(client, ItemTier, Tier[client]);
	}
}

void TextStore_ZoneEnter(int client, const char[] name)
{
	static StoreEnum store;
	if(StoreList.GetArray(name, store, sizeof(store)))
	{
		if(store.EntRef == INVALID_ENT_REFERENCE)
		{
			store.Spawn();
			StoreList.SetArray(name, store, sizeof(store));
		}
		
		store.PlayEnter(client);
		strcopy(InStore[client], sizeof(InStore[]), name);
	}
}

void TextStore_ZoneLeave(int client, const char[] name)
{
	if(InStore[client][0] && StrEqual(name, InStore[client]))
	{
		InStore[client][0] = 0;
	}
}

void TextStore_ZoneAllLeave(const char[] name)
{
	static StoreEnum store;
	if(StoreList.GetArray(name, store, sizeof(store)))
	{
		store.Despawn();
		StoreList.SetArray(name, store, sizeof(store));
	}
}