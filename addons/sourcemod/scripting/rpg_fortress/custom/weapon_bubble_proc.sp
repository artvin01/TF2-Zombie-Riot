#pragma semicolon 1
#pragma newdecls required

#define BUBBLE_INIT_SOUND "player/invuln_on_vaccinator.wav"
#define RANGE_BUBBLE_PROC 220.0

static float f_HealAmount[MAXPLAYERS];


void Wand_BubbleProctection_Map_Precache()
{
	PrecacheSound(BUBBLE_INIT_SOUND);
	Zero(f_HealAmount);
}

public float AbilityBubbleProctection(int client, int index, char name[48])
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(!kv)
	{
		return 0.0;
	}

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!IsValidEntity(weapon))
	{
		return 0.0;
	}

	static char classname[36];
	GetEntityClassname(weapon, classname, sizeof(classname));
	if (TF2_GetClassnameSlot(classname, weapon) == TFWeaponSlot_Melee || i_IsWandWeapon[weapon])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Ranged Weapon.");
		return 0.0;
	}
	if(Stats_Intelligence(client) < 150)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "You do not have enough Intelligence [150]");
		return 0.0;
	}

	int StatsForCalcMultiAdd;
	Stats_Precision(client, StatsForCalcMultiAdd);
	StatsForCalcMultiAdd /= 4;
	//get base endurance for cost
	if(i_CurrentStamina[client] < StatsForCalcMultiAdd)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%s", "Not Enough Stamina");
		return 0.0;
	}

	int StatsForCalcMultiAdd_Capacity;

	StatsForCalcMultiAdd_Capacity = StatsForCalcMultiAdd * 2;

	if(Current_Mana[client] < StatsForCalcMultiAdd_Capacity)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%s", "Not Enough Mana");
		return 0.0;
	}

	
	int StatsForCalcMultiAdd_dmg;
	StatsForCalcMultiAdd_dmg = Stats_Precision(client);

	if(StatsForCalcMultiAdd_dmg < 3000)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%s", "Not Enough Precision [3000]");
		return 0.0;
	}

	Weapon_BubbleProctectionInit(client, weapon, 1);
	float time = 30.0;
	return (GetGameTime() + time);
}

stock void Weapon_BubbleProctectionInit(int client, int weapon, int level)
{
	int entity;		
	entity = CreateEntityByName("tf_projectile_pipe_remote");

	if(IsValidEntity(entity))
	{
		b_StickyIsSticking[entity] = true; //Make them not stick to npcs.
		static float pos[3], ang[3], vel_2[3];
		GetClientEyeAngles(client, ang);
		GetClientEyePosition(client, pos);	
	
		ang[0] -= 8.0;
		
		float speed = 1500.0;
		
		vel_2[0] = Cosine(DegToRad(ang[0]))*Cosine(DegToRad(ang[1]))*speed;
		vel_2[1] = Cosine(DegToRad(ang[0]))*Sine(DegToRad(ang[1]))*speed;
		vel_2[2] = Sine(DegToRad(ang[0]))*speed;
		vel_2[2] *= -1;
		
		int team = GetClientTeam(client);
			
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(entity, Prop_Send, "m_iTeamNum", team, 1);
		SetEntProp(entity, Prop_Send, "m_nSkin", (team-2));
		SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
		SetEntPropEnt(entity, Prop_Send, "m_hThrower", client);
		SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", 0);
		SetEntProp(entity, Prop_Send, "m_iType", 1);
		
		SetVariantInt(team);
		AcceptEntityInput(entity, "TeamNum", -1, -1, 0);
		SetVariantInt(team);	
		AcceptEntityInput(entity, "SetTeam", -1, -1, 0); 
		
		SetEntPropEnt(entity, Prop_Send, "m_hLauncher", EntRefToEntIndex(i_StickyAccessoryLogicItem[client]));
		//Make them barely bounce at all.
		DispatchSpawn(entity);
		TeleportEntity(entity, pos, ang, vel_2);
		
		IsCustomTfGrenadeProjectile(entity, 9999999.0);
		CClotBody npc = view_as<CClotBody>(entity);
		npc.m_bThisEntityIgnored = true;
		
		SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
			
		DataPack pack;
		CreateDataTimer(0.2, TimerBubbleProctection, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		int shieldModel = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,_,_,0.0, true);
		SetVariantString("2.2");
		AcceptEntityInput(shieldModel, "SetModelScale");
		SetEntProp(shieldModel, Prop_Send, "m_nSkin", 1);
		pack.WriteCell(EntIndexToEntRef(entity));
		pack.WriteCell(EntIndexToEntRef(shieldModel));
		pack.WriteFloat(GetGameTime() + 10.0);	
		pack.WriteCell(GetClientUserId(client));
		EmitSoundToAll(BUBBLE_INIT_SOUND, entity, SNDCHAN_STATIC, 80, _, 0.85);
	}
}

public Action TimerBubbleProctection(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int shieldModel = EntRefToEntIndex(pack.ReadCell());
	float TimeUntillOver = pack.ReadFloat();
	int client = GetClientOfUserId(pack.ReadCell());
	if(!IsValidEntity(entity))
	{
		if(IsValidEntity(shieldModel))
			RemoveEntity(shieldModel);

		return Plugin_Stop;
	}

	if(!IsValidClient(client))
	{
		RemoveEntity(entity);
		if(IsValidEntity(shieldModel))
			RemoveEntity(shieldModel);
		return Plugin_Stop;
	}

	if(TimeUntillOver < GetGameTime())
	{
		RemoveEntity(entity);
		if(IsValidEntity(shieldModel))
			RemoveEntity(shieldModel);
		return Plugin_Stop;
	}
	
	float ProjectilePos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectilePos);
	BubbleProcAffectEnemy(client, RANGE_BUBBLE_PROC, ProjectilePos);
	if(IsValidEntity(shieldModel))
	{
		ProjectilePos[2] -= 100.0;
		Custom_SDKCall_SetLocalOrigin(shieldModel, ProjectilePos);
	}
	
   	return Plugin_Continue;
}


void BubbleProcAffectEnemy(int client, float radius, float VectorPos[3])
{
	b_NpcIsTeamkiller[client] = true;
	b_AllowSelfTarget[client] = true;
	Explode_Logic_Custom(-1.0,
	client,
	client,
	-1,
	VectorPos,
	radius,
	1.0,
	1.0,
	false,
	99,
	false,
	_,
	BubbleProcAffectEnemyInternal);
	b_NpcIsTeamkiller[client] = false;
	b_AllowSelfTarget[client] = false;
}


void BubbleProcAffectEnemyInternal(int entity, int victim, float damage, int weapon)
{
	bool Updateclient = false;
	if (GetTeam(victim) == GetTeam(entity) && !RPGCore_PlayerCanPVP(entity, victim))
	{
		
		if(victim <= MaxClients && f_BubbleProcStatus[victim][0] < GetGameTime())
		{
			SDKUnhook(victim, SDKHook_PostThink, PostThink_BubbleProc);
			SDKHook(victim, SDKHook_PostThink, PostThink_BubbleProc);
			Updateclient = true;
		}
		f_BubbleProcStatus[victim][0] = GetGameTime() + 0.5;
	}
	else
	{
		if(victim <= MaxClients && f_BubbleProcStatus[victim][1] < GetGameTime())
		{
			SDKUnhook(victim, SDKHook_PostThink, PostThink_BubbleProc);
			SDKHook(victim, SDKHook_PostThink, PostThink_BubbleProc);
			Updateclient = true;
		}
		f_BubbleProcStatus[victim][1] = GetGameTime() + 0.5;
	}
	if(Updateclient)
	{
		f_HealAmount[victim] = GetGameTime() + 0.25;
		Store_ApplyAttribs(victim);
	}
}
void PostThink_BubbleProc(int client)
{
	if(f_HealAmount[client] > GetGameTime())
		return;

	f_HealAmount[client] =  GetGameTime() + 0.2;

	int FullyResetBoth = 2;
	if(f_BubbleProcStatus[client][0] < GetGameTime())
	{
		FullyResetBoth--;
	}
	if(f_BubbleProcStatus[client][1] < GetGameTime())
	{
		FullyResetBoth--;
	}
	if(FullyResetBoth == 0)
	{
		SDKUnhook(client, SDKHook_PostThink, PostThink_GoldenAgility);
		Store_ApplyAttribs(client);
		return;
	}
	Store_ApplyAttribs(client);
	
}

int BubbleProcStatusLogicCheck(int client)
{
	int ReturnNumber = 0;
	//Bad Effect
	if(f_BubbleProcStatus[client][0] > GetGameTime())
		ReturnNumber -= 1;

	if(f_BubbleProcStatus[client][1] > GetGameTime())
		ReturnNumber += 1;

	return ReturnNumber;
}