#pragma semicolon 1
#pragma newdecls required

static Handle h_HeartBroken_Timer[MAXPLAYERS] = {null, ...};
static float f_HeartBroken_HUDDelay[MAXPLAYERS];
static int ref_CoffinEntity[MAXPLAYERS];

#define COFFIN_MODEL "models/props_manor/coffin_02.mdl"
#define HEARTBREAK_DASH "doors/door_metal_large_chamber_close1.wav"
#define HEARTBREAK_DASHHIT "ambient/materials/cartrap_explode_impact1.wav"
public void HeartBroken_OnMapStart()
{
	Zero(f_HeartBroken_HUDDelay);
	PrecacheModel(COFFIN_MODEL);
	PrecacheSound(HEARTBREAK_DASH);
	PrecacheSound(HEARTBREAK_DASHHIT);
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
		Heartbroken_ApplyCoffinBack(clientindx, true);
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


public void HeartBroken_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int zr_custom_damage)
{
	if(CheckInHud())
		return;
	if(zr_custom_damage & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED)
		return;
	//dont do anything.

	if(HasSpecificBuff(weapon, "Decapitate"))
	{	
		if(!StatusEffects_SinkingDebuffMaxStacks(victim))
		{
			Ability_Apply_Cooldown(attacker, 2, Ability_Check_Cooldown(attacker, 3, weapon) - 8.0, weapon, true);
		}
		EmitSoundToAll(HEARTBREAK_DASHHIT, attacker, _, 70, _, 1.0, 100);
		SensalCauseKnockback(attacker, victim, 0.5, false);
		RemoveSpecificBuff(weapon, "Decapitate");
	}
	ApplyStatusEffect(attacker, victim, "Sinking", 10.0);
	StatusEffects_SinkingDebuffAdd(victim, 1);
}

public void Heartbroken_Decapitate(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) > 0.0)
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);

		if (Ability_CD <= 0.0)
			Ability_CD = 0.0;

		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		return;
	}
	Handle swingTrace;
	b_LagCompNPC_No_Layers = true;
	float vecSwingForward[3];
	StartLagCompensation_Base_Boss(client);
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 250.0, false, 35.0, true); //infinite range, and ignore walls!
	FinishLagCompensation_Base_boss();

	int target = TR_GetEntityIndex(swingTrace);	
	delete swingTrace;
	if(!IsValidEnemy(client, target, true))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	
	ApplyStatusEffect(weapon, weapon, "Decapitate", 2.0);
	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 15.0);
	EmitSoundToAll(HEARTBREAK_DASH, client, _, 70, _, 1.0, 80);
	EmitSoundToAll(HEARTBREAK_DASH, client, _, 70, _, 1.0, 80);
	TF2_AddCondition(client, TFCond_LostFooting, 0.35);
	TF2_AddCondition(client, TFCond_AirCurrent, 0.35);
	
	int trail = Trail_Attach(client, ARROW_TRAIL_RED, 255, 0.45, 60.0, 3.0, 5);
	SetEntityRenderColor(trail, 65, 0, 255, 255);
	SDKCall_SetLocalOrigin(trail, {0.0,0.0,50.0});
	CreateTimer(0.45, Timer_RemoveEntityParent, EntIndexToEntRef(trail), TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(trail), TIMER_FLAG_NO_MAPCHANGE);

	float MePos[3];
	WorldSpaceCenter(client, MePos);
	float TargPos[3];
	WorldSpaceCenter(target, TargPos);
	float flPos[3];
	MakeVectorFromPoints(MePos, TargPos, flPos);
	GetVectorAngles(flPos, flPos);
	static float velocity[3];
	GetAngleVectors(flPos, velocity, NULL_VECTOR, NULL_VECTOR);
	float knockback = 900.0;
	ScaleVector(velocity, knockback);
	velocity[2] += 150.0;    // a little boost to alleviate arcing issues

	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
}
public Action Timer_RemoveEntityParent(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity))
	{
		AcceptEntityInput(entity, "ClearParent");
		Custom_SetAbsVelocity(entity, {0.0,0.0,0.0});
	}
	return Plugin_Stop;
}