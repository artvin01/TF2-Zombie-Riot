#pragma semicolon 1
#pragma newdecls required

static Handle h_HeartBroken_Timer[MAXPLAYERS] = {null, ...};
static float f_HeartBroken_HUDDelay[MAXPLAYERS];
static int ref_CoffinEntity[MAXPLAYERS];

#define COFFIN_MODEL "models/props_manor/coffin_02.mdl"
public void HeartBroken_OnMapStart()
{
	Zero(f_HeartBroken_HUDDelay);
	PrecacheModel(COFFIN_MODEL);
	PrecacheModel("models/flag/briefcase.mdl");
}

public void Enable_HeartBroken(int client, int weapon)
{
	DataPack pack = new DataPack();
	if(h_HeartBroken_Timer[client] != null)
	{
		if(IsValidHandle(h_HeartBroken_Timer[client]))
			delete h_HeartBroken_Timer[client];
		h_HeartBroken_Timer[client] = null;
	}

	h_HeartBroken_Timer[client] = CreateDataTimer(0.1, Timer_HeartBroken, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(client);
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteCell(EntIndexToEntRef(client));

	Heartbroken_ApplyCoffinBack(client, false);
}

static Action Timer_HeartBroken(Handle timer, DataPack pack)
{
	pack.Reset();
	int clientindx = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell());
	
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Heartbroken_ApplyCoffinBack(client, true);
		h_HeartBroken_Timer[clientindx] = null;
		return Plugin_Stop;
	}

	HeartBroken_HUD(client);
	return Plugin_Continue;
}
static void HeartBroken_HUD(int client)
{
	//char weapon_hint[50];
	if(f_HeartBroken_HUDDelay[client] < GetGameTime())
	{
		PrintHintText(client,"Heartbroken Hud");
		f_HeartBroken_HUDDelay[client] = GetGameTime() + 0.5;
	}
}

void Heartbroken_ApplyCoffinBack(int client, bool RemoveOnly)
{
	int CoffinEntity = EntRefToEntIndex(ref_CoffinEntity[client]);
	if(IsValidEntity(CoffinEntity))
		RemoveEntity(CoffinEntity);

	if(RemoveOnly)
		return;
	

	int Wearable;
	Wearable = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(!IsValidEntity(Wearable))
		return;

	CoffinEntity = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(CoffinEntity))
	{
		DispatchKeyValue(CoffinEntity, "model", "models/flag/briefcase.mdl");
		DispatchKeyValue(CoffinEntity, "solid", "0");
		SetEntityCollisionGroup(CoffinEntity, 24); //our savior
		SetEntPropEnt(CoffinEntity, Prop_Send, "m_hOwnerEntity", client);			
		DispatchSpawn(CoffinEntity);

		SetEntProp(CoffinEntity, Prop_Send, "m_fEffects", EF_PARENT_ANIMATES| EF_NOSHADOW);
		
		SetParent(Wearable, CoffinEntity, "flag",_);
		SDKCall_SetLocalAngles(CoffinEntity, {0.0,90.0,0.0});
		SetEntPropFloat(CoffinEntity, Prop_Send, "m_flModelScale", 0.5);
	}

	ref_CoffinEntity[client] = EntIndexToEntRef(CoffinEntity);
	CoffinToggleVisiblity(client, true);
	
}

void CoffinToggleVisiblity(int owner, bool Display)
{
	int CoffinEntity = EntRefToEntIndex(ref_CoffinEntity[owner]);
	if(!IsValidEntity(CoffinEntity))
		return;
	SetEntityRenderMode(CoffinEntity, RENDER_NONE);
	SetEntityModel(CoffinEntity, "models/flag/briefcase.mdl");

	if(!Display)
		return;

	CreateTimer(0.1, Timer_HeartBroken_CoffinHack, EntIndexToEntRef(CoffinEntity), TIMER_FLAG_NO_MAPCHANGE);
}
public Action Timer_HeartBroken_CoffinHack(Handle timer, any entid)
{
	int CoffinEntity = EntRefToEntIndex(entid);
	if(IsValidEntity(CoffinEntity))
	{
		SetEntityRenderMode(CoffinEntity, RENDER_NORMAL);
		SetEntityModel(CoffinEntity, "models/props_manor/coffin_02.mdl");
	}
	return Plugin_Stop;
}