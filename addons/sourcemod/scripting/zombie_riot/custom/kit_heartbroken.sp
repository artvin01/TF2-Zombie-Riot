#pragma semicolon 1
#pragma newdecls required

static Handle h_HeartBroken_Timer[MAXPLAYERS] = {null, ...};
static float f_HeartBroken_HUDDelay[MAXPLAYERS];
static int ref_CoffinEntity[MAXPLAYERS];
static int ref_MeleeWeapon[MAXPLAYERS];
static float Smite_ChargeTime = 0.99;
static float Smite_ChargeSpan = 0.33;
static float Smite_Radius = 250.0;
static float CoffinCharge[MAXPLAYERS];
static int WeaponLevel[MAXPLAYERS];
static float CoffinLoseCD[MAXPLAYERS];
static float RecentSwitch[MAXPLAYERS];

#define MAX_COFFINS 10
#define COFFIN_MODEL "models/props_manor/coffin_02.mdl"
#define HEARTBREAK_DASH "doors/door_metal_large_chamber_close1.wav"
#define HEARTBREAK_DASHHIT "ambient/materials/cartrap_explode_impact1.wav"
#define HEARTBREAK_HORSE_MODEL "models/props_c17/statue_horse.mdl"
#define CHAIN_BEAM "effects/workshop/timeghosts/chainrope.vmt"

static char g_ShootHorseSound[][] = {
	"misc/halloween/spell_athletic.wav",
};
static char g_CoffinThrow[][] = {
	"weapons/grappling_hook_shoot.wav",
};
static char g_CoffinReel[][] = {
	"weapons/grappling_hook_reel_start.wav",
};
static char g_CoffinClaim[][] = {
	"player/souls_receive1.wav",
	"player/souls_receive2.wav",
	"player/souls_receive3.wav",
};
static char g_CoffinClaim2[][] = {
	"player/taunt_luxury_lounge_chair_creak.wav",
};
static char g_CoffinRevive[][] = {
	"ui/halloween_boss_chosen_it.wav",
};
bool Precached = false;
public void HeartBroken_OnMapStart()
{
	PrecacheSoundArray(g_CoffinClaim);
	PrecacheSoundArray(g_CoffinClaim2);
	PrecacheSoundArray(g_ShootHorseSound);
	PrecacheSoundArray(g_CoffinThrow);
	PrecacheSoundArray(g_CoffinReel);
	PrecacheSoundArray(g_CoffinRevive);
	Zero(f_HeartBroken_HUDDelay);
	Zero(RecentSwitch);
	Zero(CoffinLoseCD);
	PrecacheModel(COFFIN_MODEL);
	PrecacheModel(HEARTBREAK_HORSE_MODEL);
	PrecacheModel(CHAIN_BEAM);
	PrecacheSound(HEARTBREAK_DASH);
	PrecacheSound(HEARTBREAK_DASHHIT);
	PrecacheModel("models/flag/briefcase.mdl");
	Zero(CoffinCharge);
	Precached = false;
}

void PrecacheHeartbrokenMusic()
{
	if(!Precached)
	{
		PrecacheSoundCustom("#zombiesurvival/heatbroken_lastman.mp3",_,1);
		Precached = true;
	}
}
bool IsHeartBroken(int client)
{
	if(h_HeartBroken_Timer[client] != null)
		return true;

	return false;
}
void HeartBrokenMassRevive(int client)
{
	CreateTimer(10.0, Timer_ReviveHeartBroken, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
}
public Action Timer_ReviveHeartBroken(Handle timer, any entid)
{
	int client = EntRefToEntIndex(entid);
	if(IsValidClient(client))
	{
		for(int i=0; i<4; i++)
		{
			Heartbroken_WildHunt(client, true);
		}
	}
	return Plugin_Stop;
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
	WeaponLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));
	ref_MeleeWeapon[client] = EntIndexToEntRef(weapon);
	h_HeartBroken_Timer[client] = CreateDataTimer(0.1, Timer_HeartBroken, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(client);
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteCell(EntIndexToEntRef(client));
	PrecacheHeartbrokenMusic();
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

	b_IsCannibal[client] = true;
	HeartBroken_HUD(client);
	return Plugin_Continue;
}
static void HeartBroken_HUD(int client)
{
	//char weapon_hint[50];
	if(WeaponLevel[client] < 5)
		return;

	if(CoffinLoseCD[client] < GetGameTime() && !Waves_InSetup())
	{
		CoffinLoseCD[client] = GetGameTime() + 120.0;

		CoffinCharge[client] -= 0.1;
		if(CoffinCharge[client] <= 0.0)
		{
			CoffinCharge[client] = 0.0;
			CoffinLoseCD[client] = GetGameTime() + 240.0;
		}

	}
	if(f_HeartBroken_HUDDelay[client] < GetGameTime())
	{
		
		if(WeaponLevel[client] >= 6)
			PrintHintText(client,"Coffins [%i/%i]", RoundToFloor(CoffinCharge[client] * float(MAX_COFFINS)), MAX_COFFINS);
		else
			PrintHintText(client,"Coffins [%i/%i]", RoundToFloor(CoffinCharge[client] * float(MAX_COFFINS)), MAX_COFFINS / 2);
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
		b_ThisEntityIgnored[CoffinEntity] = true;
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
	CreateTimer(0.1, Timer_HeartBroken_CoffinHack, EntIndexToEntRef(CoffinEntity), TIMER_FLAG_NO_MAPCHANGE);
	
}

void CoffinToggleVisiblity(int owner, bool Display)
{
	Heartbroken_ApplyCoffinBack(owner, !Display);
	/*
	int CoffinEntity = EntRefToEntIndex(ref_CoffinEntity[owner]);
	if(!IsValidEntity(CoffinEntity))
		return;
	SetEntityRenderMode(CoffinEntity, RENDER_NONE);
	SetEntityModel(CoffinEntity, "models/flag/briefcase.mdl");

	if(!Display)
		return;

	CreateTimer(0.1, Timer_HeartBroken_CoffinHack, EntIndexToEntRef(CoffinEntity), TIMER_FLAG_NO_MAPCHANGE);
	*/
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

	if(WeaponLevel[attacker] >= 5)
	{

		GiveCoffinOnDamage(attacker, victim, damage);

		
		//more coffins means more damage, 0.2 is the dmg multiplier
		damage *= (1.0 + (CoffinCharge[attacker] * 0.2));
	}

	if(zr_custom_damage & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED)
		return;
	//dont do anything.

	if(HasSpecificBuff(weapon, "Decapitate"))
	{	
		if(!StatusEffects_SinkingDebuffMaxStacks(victim))
		{
			Ability_Apply_Cooldown(attacker, 3, Ability_Check_Cooldown(attacker, 3, weapon) - 6.5, weapon, true);
		}
		EmitSoundToAll(HEARTBREAK_DASHHIT, attacker, _, 70, _, 1.0, 100);
		SensalCauseKnockback(attacker, victim, 0.5, false);
		RemoveSpecificBuff(weapon, "Decapitate");
	}
	if(HasSpecificBuff(weapon, "Memorial Possession"))
	{
		if(StatusEffects_MemorialDebuffMaxStacks(weapon))
		{
			MemorialPossession_ActivateAbility(attacker, victim);
			RemoveSpecificBuff(weapon, "Memorial Possession");
		}
		else
			StatusEffects_MemorialDebuffAdd(weapon, 1);
	}
	ApplyStatusEffect(attacker, victim, "Sinking", 10.0);
	StatusEffects_SinkingDebuffAdd(victim, 1);
}
public void HeartBroken_OnTakeDamage_Take(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, int equipped_weapon, float damagePosition[3], int zr_custom_damage)
{
	if(CheckInHud())
		return;
	if(zr_custom_damage & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED)
		return;
		
	if(HasSpecificBuff(victim, "HB In Parry"))
	{
		LookAtTarget(victim, attacker);
		RemoveSpecificBuff(victim, "HB In Parry");
		ApplyStatusEffect(victim, victim, "HB Parried", 10.0);
		SensalCauseKnockback(victim, attacker, 0.75, true);
		if(WeaponLevel[victim] >= 2)
		{
			for(int i=0; i<4; i++)
			{
				Heartbroken_ShootHorseProjectile(victim, attacker, 0.5 , 1.5);
			}
		}
		float CounterDamage = 65.0;
		CounterDamage *= WeaponDamageAttributeMultipliers(equipped_weapon,_,victim);
		CounterDamage *= 2.5;
		static float angles[3];
		GetEntPropVector(victim, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(attacker, Entity_Position );
		float ReflectPosVec[3]; CalculateDamageForce(vecForward, 10000.0, ReflectPosVec);
		DataPack pack = new DataPack();
		pack.WriteCell(EntIndexToEntRef(attacker));
		pack.WriteCell(EntIndexToEntRef(victim));
		pack.WriteCell(EntIndexToEntRef(victim));
		pack.WriteFloat(CounterDamage);
		pack.WriteCell(DMG_CLUB);
		pack.WriteCell(EntIndexToEntRef(equipped_weapon));
		pack.WriteFloat(ReflectPosVec[0]);
		pack.WriteFloat(ReflectPosVec[1]);
		pack.WriteFloat(ReflectPosVec[2]);
		pack.WriteFloat(Entity_Position[0]);
		pack.WriteFloat(Entity_Position[1]);
		pack.WriteFloat(Entity_Position[2]);
		pack.WriteCell(ZR_DAMAGE_REFLECT_LOGIC);
		RequestFrame(CauseDamageLaterSDKHooks_Takedamage, pack);
		damage *= 0.25;
	}
}
public void Heartbroken_Decapitate(int client, int weapon, bool crit, int slot)
{
	if(RecentSwitch[client] > GetGameTime())
		return;
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
	if(HasSpecificBuff(weapon, "Memorial Possession"))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
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
	
	ApplyStatusEffect(weapon, weapon, "Decapitate", 1.5);
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


public void Heartbroken_SwitchToMeleeWeapon(int client, int weapon, bool crit, int slot)
{
	int MeleeWeapon = EntRefToEntIndex(ref_MeleeWeapon[client]);
	if(!IsValidEntity(MeleeWeapon))
		return;
	RecentSwitch[client] = GetGameTime() + 0.25;
	SetPlayerActiveWeapon(client, MeleeWeapon);
}

public void Heartbroken_Memorial_Possesion(int client, int weapon, bool crit, int slot)
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
	int MeleeWeapon = EntRefToEntIndex(ref_MeleeWeapon[client]);
	if(!IsValidEntity(MeleeWeapon))
		return;
	if(HasSpecificBuff(MeleeWeapon, "Decapitate"))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	Heartbroken_SwitchToMeleeWeapon(client, weapon, crit, slot);
	

	ApplyStatusEffect(MeleeWeapon, MeleeWeapon, "Memorial Possession", 3.0);
	Rogue_OnAbilityUse(client, MeleeWeapon);
	Ability_Apply_Cooldown(client, slot, 20.0, weapon);
	EmitSoundToAll(HEARTBREAK_DASH, client, _, 70, _, 1.0, 80);
	EmitSoundToAll(HEARTBREAK_DASH, client, _, 70, _, 1.0, 80);
}
public void Heartbroken_Counter(int client, int weapon, bool crit, int slot)
{
	if(RecentSwitch[client] > GetGameTime())
		return;
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
	if(HasSpecificBuff(weapon, "Memorial Possession") || HasSpecificBuff(weapon, "Decapitate"))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	
	Ability_Apply_Cooldown(client, slot, 15.0, weapon);
	HeartBrokenAction(client, -1, 2);
}



void MemorialPossession_ActivateAbility(int attacker, int victim)
{
	HeartBrokenAction(attacker, victim, 1);
}


#define HEARTBROKEN_BOUNDS_VIEW_EFFECT 25.0
#define HEARTBROKEN_MAXRANGE_VIEW_EFFECT 150.0

static int HeartBrokenAction(int client, int target, int which)
{
	//Reduce the damage they take
	char animation[255];
	float duration = 1.0;

	CoffinToggleVisiblity(client, false);
	switch(which)
	{
		case 1:
		{
			Format(animation, sizeof(animation), "memorial_possession");
			duration = 1.25;
		}
		case 2:
		{
			Format(animation, sizeof(animation), "o_dohhulan_parry");
			duration = 2.0;
		}
	}
	ApplyStatusEffect(client, client, "HeartBroken Animation", duration);

	float vAngles[3];
	float vOrigin[3];
	
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	float vecSwingForward[3];
	float vecSwingEnd[3];
	GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);
	vecSwingEnd[0] = vOrigin[0] + vecSwingForward[0] * HEARTBROKEN_MAXRANGE_VIEW_EFFECT * 0.25;
	vecSwingEnd[1] = vOrigin[1] + vecSwingForward[1] * HEARTBROKEN_MAXRANGE_VIEW_EFFECT * 0.25;
	vecSwingEnd[2] = vOrigin[2] + vecSwingForward[2] * HEARTBROKEN_MAXRANGE_VIEW_EFFECT * 0.25;
	vecSwingEnd[2] -= 20.0;
	
	//always from upwards somewhere.
	vAngles[0] = GetRandomFloat(-10.0 , -5.0);
	switch(GetRandomInt(0,1))
	{
		case 0:
		{
			vAngles[1] += GetRandomFloat(150.0 , 160.0);
		}
		case 1:
		{
			vAngles[1] -= GetRandomFloat(150.0 , 160.0);
		}
	}

	float LeperViewAnglesMins[3];
	float LeperViewAnglesMaxs[3];
	LeperViewAnglesMins = view_as<float>({-HEARTBROKEN_BOUNDS_VIEW_EFFECT, -HEARTBROKEN_BOUNDS_VIEW_EFFECT, -HEARTBROKEN_BOUNDS_VIEW_EFFECT});
	LeperViewAnglesMaxs = view_as<float>({HEARTBROKEN_BOUNDS_VIEW_EFFECT, HEARTBROKEN_BOUNDS_VIEW_EFFECT, HEARTBROKEN_BOUNDS_VIEW_EFFECT});

	GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);

	vecSwingEnd[0] = vOrigin[0] + vecSwingForward[0] * HEARTBROKEN_MAXRANGE_VIEW_EFFECT;
	vecSwingEnd[1] = vOrigin[1] + vecSwingForward[1] * HEARTBROKEN_MAXRANGE_VIEW_EFFECT;
	vecSwingEnd[2] = vOrigin[2] + vecSwingForward[2] * HEARTBROKEN_MAXRANGE_VIEW_EFFECT;

	Handle trace = TR_TraceHullFilterEx( vOrigin, vecSwingEnd, LeperViewAnglesMins, LeperViewAnglesMaxs, ( MASK_SOLID ), TraceRayHitWorldOnly, client );
	if ( TR_GetFraction(trace) < 1.0)
	{
		//we hit something, uh oh!
		TR_GetEndPosition(vecSwingEnd, trace);
	}
	GetClientEyeAngles(client, vAngles);
	vAngles[0] = 0.0;
	GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);

	delete trace;

	float vecSwingEndMiddle[3];
	vecSwingEndMiddle[0] = vOrigin[0] + vecSwingForward[0] * HEARTBROKEN_MAXRANGE_VIEW_EFFECT;
	vecSwingEndMiddle[1] = vOrigin[1] + vecSwingForward[1] * HEARTBROKEN_MAXRANGE_VIEW_EFFECT;
	vecSwingEndMiddle[2] = vOrigin[2] + vecSwingForward[2] * HEARTBROKEN_MAXRANGE_VIEW_EFFECT;
	trace = TR_TraceHullFilterEx( vOrigin, vecSwingEndMiddle, LeperViewAnglesMins, LeperViewAnglesMaxs, ( MASK_SOLID ), TraceRayHitWorldOnly, client );
	if ( TR_GetFraction(trace) < 1.0)
	{
		//we hit something, uh oh!
		TR_GetEndPosition(vecSwingEndMiddle, trace);
	}
	delete trace;
	float vAngleCamera[3];
	float MiddleAngle[3];
	MiddleAngle[0] = (vecSwingEndMiddle[0] + vOrigin[0]) / 2.0;
	MiddleAngle[1] = (vecSwingEndMiddle[1] + vOrigin[1]) / 2.0;
	MiddleAngle[2] = (vecSwingEndMiddle[2] + vOrigin[2]) / 2.0;
	
//	int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
//	TE_SetupBeamPoints(MiddleAngle, vecSwingEnd, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 5.0, 5.0, 5.0, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
//	TE_SendToAll();
	int viewcontrol = CreateEntityByName("prop_dynamic");
	if (IsValidEntity(viewcontrol))
	{
		b_ThisEntityIgnored[viewcontrol] = true;
		GetVectorAnglesTwoPoints(vecSwingEnd, MiddleAngle, vAngleCamera);
		SetEntityModel(viewcontrol, "models/empty.mdl");
		DispatchKeyValueVector(viewcontrol, "origin", vecSwingEnd);
		DispatchKeyValueVector(viewcontrol, "angles", vAngleCamera);
		DispatchSpawn(viewcontrol);	
		SetClientViewEntity(client, viewcontrol);
	}
	float vabsAngles[3];
	float vabsOrigin[3];
	GetClientAbsOrigin(client, vabsOrigin);
	GetClientEyeAngles(client, vabsAngles);
	vabsAngles[0] = 0.0;
	SetVariantInt(0);
	AcceptEntityInput(client, "SetForcedTauntCam");	

	int spawn_index = NPC_CreateByName("npc_allied_heartbroken_visualiser", client, vabsOrigin, vabsAngles, target, animation);

	CClotBody npc = view_as<CClotBody>(spawn_index);
	npc.m_iWearable9 = viewcontrol;
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);

	
	TF2_AddCondition(client, TFCond_FreezeInput, -1.0);

	SetEntityMoveType(client, MOVETYPE_NONE);
	SetEntProp(client, Prop_Send, "m_bIsPlayerSimulated", 0);
	SetEntProp(client, Prop_Send, "m_bSimulatedEveryTick", 0);
//	SetEntProp(client, Prop_Send, "m_bAnimatedEveryTick", 0);
	SetEntProp(client, Prop_Send, "m_bClientSideAnimation", 0);
	SetEntProp(client, Prop_Send, "m_bClientSideFrameReset", 1);
	SetEntProp(client, Prop_Send, "m_bForceLocalPlayerDraw", 1);
	int entity, i;
	while(TF2U_GetWearable(client, entity, i))
	{
		SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") | EF_NODRAW);
	}

	return spawn_index;
}


#define HEARTBROKEN_HORSE_BEHIND 150.0

void Heartbroken_ShootHorseProjectile(int client, int target, float dmgmotif = 1.0, float speedmodif = 1.0)
{
	int MeleeWeapon = EntRefToEntIndex(ref_MeleeWeapon[client]);
	if(!IsValidEntity(MeleeWeapon))
		return;
	float damage = 65.0;
	damage *= WeaponDamageAttributeMultipliers(MeleeWeapon,_,client);
	damage *= dmgmotif;
	float speed = 700.0;
	float time = 2.0;
	speed *= speedmodif;


	float vAngles[3];
	float vOrigin[3];
	
	GetClientEyePosition(client, vOrigin);
	vOrigin[2] -= 30.0;

	GetClientEyeAngles(client, vAngles);
	vAngles[0] = 0.0;
	vAngles[0] += GetRandomFloat(-15.0,15.0);
	vAngles[1] += GetRandomFloat(-15.0,15.0);
	fClamp(vAngles[1], -20.0, 20.0);
	float vecSwingForward[3];
	float vecSwingEnd[3];
	GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);
	vecSwingEnd[0] = vOrigin[0] - vecSwingForward[0] * HEARTBROKEN_HORSE_BEHIND;
	vecSwingEnd[1] = vOrigin[1] - vecSwingForward[1] * HEARTBROKEN_HORSE_BEHIND;
	vecSwingEnd[2] = vOrigin[2] - vecSwingForward[2] * HEARTBROKEN_HORSE_BEHIND;
	
	
	//This spawns the projectile, this is a return int, if you want, you can do extra stuff with it, otherwise, it can be used as a void.
	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, -1/*Default wand*/, -1, "",_,_,vecSwingEnd);
	b_ProjectileCollideIgnoreWorld[projectile] = true;
	SetEntityMoveType(projectile, MOVETYPE_NOCLIP);
	WandProjectile_ApplyFunctionToEntity(projectile, Horse_Projectile_Hit);
	
	float fAng[3];
	GetClientEyeAngles(client, fAng);
	if(!IsEntityAlive(target))
		target = -1;
	Initiate_HomingProjectile(projectile,
	projectile,
		60.0 * speedmodif,			// float lockonAngleMax,
		10.0 * speedmodif,				//float homingaSec,
		true,				// bool LockOnlyOnce,
		true,				// bool changeAngles,
		fAng,
		target);			// float AnglesInitiate[3]);
	int trail = Trail_Attach(projectile, ARROW_TRAIL_RED, 255, 0.45, 30.0, 3.0, 5);
	SetEntityRenderColor(trail, 65, 0, 255, 255);
	SDKCall_SetLocalOrigin(trail, {0.0,0.0,25.0});
	CreateTimer(1.5, Timer_RemoveEntityParent, EntIndexToEntRef(trail), TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(2.0, Timer_RemoveEntity, EntIndexToEntRef(trail), TIMER_FLAG_NO_MAPCHANGE);
	i_WandParticle[projectile] = EntIndexToEntRef(trail);
	int horse = ApplyCustomModelToWandProjectile(projectile, HEARTBREAK_HORSE_MODEL, 0.45, "", _ , false);
	SetEntityRenderMode(horse, RENDER_TRANSALPHA);
	SetEntityRenderColor(horse, 125, 0, 255, 200);
	SDKCall_SetLocalAngles(horse, {-60.0,-180.0,0.0});
	CreateTimer(1.45, Prop_Gib_FadeSet, EntIndexToEntRef(horse), TIMER_FLAG_NO_MAPCHANGE);
	EmitSoundToAll(g_ShootHorseSound[GetRandomInt(0, sizeof(g_ShootHorseSound) - 1)], horse, SNDCHAN_AUTO, 80, _, 0.9, 110, .soundtime = GetGameTime() - 1.0);
}


public void Horse_Projectile_Hit(int entity, int target)
{
	if (target <= 0)	
		return;

	if(IsIn_HitDetectionCooldown(entity,target))
	{
		return;
	}
	Set_HitDetectionCooldown(entity,target, FAR_FUTURE);

	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	if (!IsValidClient(owner))	
		return;

	//Code to do damage position and ragdolls
	static float angles[3];
	GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
	float vecForward[3];
	GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
	static float Entity_Position[3];
	WorldSpaceCenter(target, Entity_Position);

	float Wand_Dmg = f_WandDamage[entity];
	

	float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
	SDKHooks_TakeDamage(target, entity, owner, Wand_Dmg, DMG_CLUB, -1, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?
	f_WandDamage[entity] *= 0.5;
}



public void Heartbroken_Reqieum(int client, int weapon, bool crit, int slot)
{
	int buttons = GetClientButtons(client);
	bool crouch = (buttons & IN_DUCK) != 0;
	if(crouch)
	{
		Heartbroken_WildHunt(client);
		return;
	}
	int MeleeWeapon = EntRefToEntIndex(ref_MeleeWeapon[client]);
	if(!IsValidEntity(MeleeWeapon))
		return;
	if(HasSpecificBuff(MeleeWeapon, "Memorial Possession") || HasSpecificBuff(MeleeWeapon, "Decapitate"))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
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
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 350.0, false, 35.0, true); //infinite range, and ignore walls!
	FinishLagCompensation_Base_boss();

	int target = TR_GetEntityIndex(swingTrace);	
	delete swingTrace;
	if(!IsValidEnemy(client, target, true))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	if(HasSpecificBuff(target, "Coffin Target"))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	Ability_Apply_Cooldown(client, slot, 45.0, weapon);

	Heartbroken_SwitchToMeleeWeapon(client, weapon, crit, slot);

	Heartbroken_ShootCoffinProjectile(client, target);
}

void Heartbroken_ShootCoffinProjectile(int client, int target)
{
	int MeleeWeapon = EntRefToEntIndex(ref_MeleeWeapon[client]);
	if(!IsValidEntity(MeleeWeapon))
		return;
	ApplyStatusEffect(client, target, "Coffin Target", 7.0);
	
	if(IsInvuln(target) ||
	 b_thisNpcIsABoss[target] ||
	  b_thisNpcIsARaid[target] ||
	   b_StaticNPC[target] ||
	   i_IsABuilding[target] ||
	   i_NpcIsABuilding[target] ||
	    GetTeam(target) == TFTeam_Stalkers)
		{

		}
		else
		{
			ApplyStatusEffect(target, target, "Infinite Will", 2.0);
		}
	CoffinToggleVisiblity(client, false);
	float damage = 65.0;
	damage *= 3.0;
	damage *= WeaponDamageAttributeMultipliers(MeleeWeapon,_,client);

	float speed = 900.0;
	float time = 5.0;

	EmitSoundToAll(g_CoffinThrow[GetRandomInt(0, sizeof(g_CoffinThrow) - 1)], client, SNDCHAN_AUTO, 80, _, 0.9, 90);

	
	
	//This spawns the projectile, this is a return int, if you want, you can do extra stuff with it, otherwise, it can be used as a void.
	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, -1/*Default wand*/, -1, "");
	b_ProjectileCollideIgnoreWorld[projectile] = true;
	SetEntityMoveType(projectile, MOVETYPE_NOCLIP);
	CClotBody npc = view_as<CClotBody>(projectile);
	npc.m_iTarget = target;
	WandProjectile_ApplyFunctionToEntity(projectile, Coffin_Projectile_Hit);
	
	float fAng[3];
	GetClientEyeAngles(client, fAng);
	Initiate_HomingProjectile(projectile,
	projectile,
		180.0,			// float lockonAngleMax,
		180.0,				//float homingaSec,
		true,				// bool LockOnlyOnce,
		true,				// bool changeAngles,
		fAng,
		target);			// float AnglesInitiate[3]);
		
	ApplyCustomModelToWandProjectile(projectile, COFFIN_MODEL, 0.5, "", _ , false);
	int laser = ConnectWithBeam(client, projectile, 125, 0, 255, 8.0, 8.0, 0.0, CHAIN_BEAM, _,_,"effect_hand_l");
	i_WandParticle[projectile] = EntIndexToEntRef(laser);

	b_NpcIsTeamkiller[projectile] = true; //allows self hitting
}

public void Coffin_Projectile_Hit(int entity, int target)
{
	if (target <= 0)	
		return;

	CClotBody npc = view_as<CClotBody>(entity);
	if(target != npc.m_iTarget)
		return;

	if(IsIn_HitDetectionCooldown(entity,target))
	{
		return;
	}
	Set_HitDetectionCooldown(entity,target, FAR_FUTURE);

	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	if (!IsValidClient(owner))	
		return;

	if(IsInvuln(target) ||
	 b_thisNpcIsABoss[target] ||
	  b_thisNpcIsARaid[target] ||
	   b_StaticNPC[target] ||
	   i_IsABuilding[target] ||
	   i_NpcIsABuilding[target] ||
	    GetTeam(target) == TFTeam_Stalkers)
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);

		float Wand_Dmg = f_WandDamage[entity];
		

		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, entity, owner, Wand_Dmg, DMG_CLUB, -1, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?

		EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_INTRO, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, Entity_Position);
		EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_INTRO, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, Entity_Position);
		
		GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", Entity_Position);	
		Entity_Position[2] += 10.0;
		for(int i; i <4 ; i++)
		{
			float VecSave[3];
			VecSave[0] = Entity_Position[0] + GetRandomFloat(-150.0, 150.0);
			VecSave[1] = Entity_Position[1] + GetRandomFloat(-150.0, 150.0);
			VecSave[2] = Entity_Position[2];
			Handle pack;
			CreateDataTimer(Smite_ChargeSpan, HeartBroken_Smite_Timer, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			WritePackCell(pack, GetClientUserId(owner));
			WritePackFloat(pack, 0.0);
			WritePackFloat(pack, VecSave[0]);
			WritePackFloat(pack, VecSave[1]);
			WritePackFloat(pack, VecSave[2]);
			WritePackFloat(pack, Wand_Dmg * 0.25);

			spawnRing_Vectors(VecSave, Smite_Radius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 125, 0, 255, 200, 1, Smite_ChargeTime, 3.0, 0.1, 1, 1.0);
		}
		RemoveSpecificBuff(target, "Coffin Target");
	}
	else
	{
		npc.m_iTargetWalkTo = target;
		SetEntityCollisionGroup(target, 1);
	}
	
	EmitSoundToAll(g_CoffinReel[GetRandomInt(0, sizeof(g_CoffinReel) - 1)], owner, SNDCHAN_AUTO, 80, _, 0.9, 90);
	float ang[3];
	GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
	Initiate_HomingProjectile(entity, 
	owner, 
	180.0, 
	180.0, 
	true, 
	true, 
	ang, 
	owner);
	TriggerTimerHoming(entity);
	func_NPCThink[entity] = Coffin_Carry_Back;
	WandProjectile_ApplyFunctionToEntity(entity, Coffin_Projectile_ReturnOwner);
	npc.m_iTarget = owner;
}
public void Coffin_Carry_Back(int entity)
{

	CClotBody npc = view_as<CClotBody>(entity);
	if(IsValidEntity(npc.m_iTargetWalkTo))
	{
		float Pos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", Pos); 
		b_NoGravity[npc.m_iTargetWalkTo] = true;
		b_DoNotUnStuck[npc.m_iTargetWalkTo] = true;
		ApplyStatusEffect(npc.m_iTargetWalkTo, npc.m_iTargetWalkTo, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.m_iTargetWalkTo, npc.m_iTargetWalkTo, "Infinite Will", 3.0);
		float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		angles[0] -= 90.0;
		SDKCall_SetLocalAngles(npc.m_iTargetWalkTo, angles);
		SDKCall_SetLocalOrigin(npc.m_iTargetWalkTo, Pos); //keep teleporting just incase.
		FreezeNpcInTime(npc.m_iTargetWalkTo, 0.09);
	}
}
public void Coffin_Projectile_ReturnOwner(int entity, int target)
{
	if (target <= 0)	
		return;

	CClotBody npc = view_as<CClotBody>(entity);
	if(target != npc.m_iTarget)
		return;
	if(IsIn_HitDetectionCooldown(entity,target))
	{
		return;
	}
	Set_HitDetectionCooldown(entity,target, FAR_FUTURE);

	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	StopSound(owner, SNDCHAN_AUTO,g_CoffinReel[GetRandomInt(0, sizeof(g_CoffinReel) - 1)]);
	if(IsValidEntity(npc.m_iTargetWalkTo))
	{
		CClotBody Tnpc = view_as<CClotBody>(npc.m_iTargetWalkTo);
		Tnpc.m_iHealthBar = 0;
		SetEntityHealth(npc.m_iTargetWalkTo, 1);
		b_DissapearOnDeath[npc.m_iTargetWalkTo] = true;
		RemoveSpecificBuff(npc.m_iTargetWalkTo, "Infinite Will");
		SDKHooks_TakeDamage(npc.m_iTargetWalkTo, owner, owner, GetRandomFloat(99999.0,9999999.0), DMG_BLAST, -1, {0.1,0.1,0.1}, _, _, ZR_SLAY_DAMAGE); // 2048 is DMG_NOGIB?
		
		float PosMe[3];
		GetEntPropVector(owner, Prop_Data, "m_vecAbsOrigin", PosMe);
		PosMe[2] += 45.0;
		TE_Particle("halloween_boss_death_cloud", PosMe, NULL_VECTOR, NULL_VECTOR, owner, _, _, _, _, _, _, _, _, _, 0.0);

		int SoundDo = GetRandomInt(0, sizeof(g_CoffinClaim) - 1);
		EmitSoundToAll(g_CoffinClaim[SoundDo], owner, SNDCHAN_AUTO, 80, _, 0.9, 90);
		EmitSoundToAll(g_CoffinClaim2[GetRandomInt(0, sizeof(g_CoffinClaim2) - 1)], owner, SNDCHAN_AUTO, 80, _, 0.9, 90);
		EmitSoundToAll(g_CoffinClaim2[GetRandomInt(0, sizeof(g_CoffinClaim2) - 1)], owner, SNDCHAN_AUTO, 80, _, 0.9, 90);
		CoffinCharge[owner] += (1.0 / float(MAX_COFFINS));
		if(WeaponLevel[owner] >= 6)
		{
			if(CoffinCharge[owner] >= 1.0)
				CoffinCharge[owner] = 1.0;
		}
		else
		{
			if(CoffinCharge[owner] >= 0.5)
				CoffinCharge[owner] = 0.5;
		}
	}
	CoffinToggleVisiblity(owner, true);
	RemoveEntity(entity);
}





public Action HeartBroken_Smite_Timer(Handle Smite_Logic, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	
	if (!IsValidClient(client))
	{
		return Plugin_Stop;
	}
		
	float NumLoops = ReadPackFloat(pack);
	float spawnLoc[3];
	for (int GetVector = 0; GetVector < 3; GetVector++)
	{
		spawnLoc[GetVector] = ReadPackFloat(pack);
	}
	
	float damage = ReadPackFloat(pack);
	
	if (NumLoops >= Smite_ChargeTime)
	{
		float secondLoc[3];
		for (int replace = 0; replace < 3; replace++)
		{
			secondLoc[replace] = spawnLoc[replace];
		}
		
		for (int sequential = 1; sequential <= 2; sequential++)
		{
			spawnRing_Vectors(secondLoc, 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 125, 0, 255, 120, 1, 0.33, 4.0, 0.4, 1, (Smite_Radius * 5.0)/float(sequential));
			secondLoc[2] += 150.0 + (float(sequential) * 20.0);
		}
		
		secondLoc[2] = 9999.0;
		
		spawnBeam(0.8, 125, 0, 255, 255, "materials/sprites/laserbeam.vmt", 8.0, 8.2, _, 5.0, secondLoc, spawnLoc);	
		spawnBeam(0.8, 125, 0, 255, 200, "materials/sprites/lgtning.vmt", 5.0, 5.2, _, 5.0, secondLoc, spawnLoc);	
		
		EmitAmbientSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE, spawnLoc, _, 75, _ , 0.5);
		
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(spawnLoc[0]);
		pack_boom.WriteFloat(spawnLoc[1]);
		pack_boom.WriteFloat(spawnLoc[2]);
		pack_boom.WriteCell(1);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		
		int MeleeWeapon = EntRefToEntIndex(ref_MeleeWeapon[client]);
		Explode_Logic_Custom(damage, client, client, MeleeWeapon, spawnLoc, Smite_Radius,_,_,false, 4);
		
		return Plugin_Stop;
	}
	else
	{
		spawnRing_Vectors(spawnLoc, Smite_Radius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 125, 0, 255, 120, 1, 0.33, 3.0, 0.1, 1, 1.0);
		EmitAmbientSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_CHARGE, spawnLoc, _, 60, _, 0.7, GetRandomInt(80, 110));
		
		ResetPack(pack);
		WritePackCell(pack, GetClientUserId(client));
		WritePackFloat(pack, NumLoops + Smite_ChargeSpan);
		WritePackFloat(pack, spawnLoc[0]);
		WritePackFloat(pack, spawnLoc[1]);
		WritePackFloat(pack, spawnLoc[2]);
		WritePackFloat(pack, damage);
	}
	
	return Plugin_Continue;
}
static void spawnBeam(float beamTiming, int r, int g, int b, int a, char sprite[PLATFORM_MAX_PATH], float width=2.0, float endwidth=2.0, int fadelength=1, float amp=15.0, float startLoc[3] = {0.0, 0.0, 0.0}, float endLoc[3] = {0.0, 0.0, 0.0})
{
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = a;
		
	int SPRITE_INT = PrecacheModel(sprite, false);

	TE_SetupBeamPoints(startLoc, endLoc, SPRITE_INT, 0, 0, 0, beamTiming, width, endwidth, fadelength, amp, color, 0);
	
	TE_SendToAll();
}



stock void GiveCoffinOnDamage(int client, int victim, float damage)
{
	int MinCashMaxGain = CurrentCash;
	if(MinCashMaxGain <= 1000)
		MinCashMaxGain = 1000;

	damage *= (1.0 / float(MAX_COFFINS));

	MinCashMaxGain -= 250;

	if(MinCashMaxGain >= 200000)
	{
		MinCashMaxGain = 200000;
	}
	
	float DamageForMaxCharge = (Pow(2.0 * MinCashMaxGain, 1.2) + MinCashMaxGain * 3.0);
	
	DamageForMaxCharge *= 0.75;


	CoffinCharge[client] += (damage / DamageForMaxCharge);
	if(CoffinCharge[client] >= 1.0)
		CoffinCharge[client] = 1.0;
	//Has to be atleast 3k.
}


void Heartbroken_WildHunt(int client, bool ForceRevive = false)
{
	if(b_IsAloneOnServer)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%T", "You cant use this ability if youre alone", client);
		return;
	}
	float ReviveCost = 0.5;
	if(LastMann)
		ReviveCost = 0.3;
	
	if(!ForceRevive && CoffinCharge[client] < ReviveCost)
	{
		SetDefaultHudPosition(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%T", "Not Enough Coffins", client, RoundToFloor(ReviveCost * float(MAX_COFFINS)));
		return;
	}
	
	int MaxCashScale = CurrentCash;
	if(MaxCashScale > 60000)
		MaxCashScale = 60000;
	//taken from reinforce
	bool DeadPlayer;
	for(int client_check=1; client_check<=MaxClients; client_check++)
	{
		if(!IsValidClient(client_check))
			continue;
		if(TeutonType[client_check] == TEUTON_NONE)
			continue;
		if(!b_AntiLateSpawn_Allow[client_check])
			continue;
		if(client==client_check || GetTeam(client_check) != TFTeam_Red)
			continue;
		if(!WasHereSinceStartOfWave(client_check))
			continue;
		if(f_PlayerLastKeyDetected[client_check] < GetGameTime())
			continue;
		if(HasSpecificBuff(client_check, "Vuntulum Bomb EMP Death"))
			continue;

		int CashSpendScale = CashSpentTotal[client_check];

		if(CashSpendScale <= 500)
			CashSpendScale = 500;

		if((CashSpendScale * 3) < (MaxCashScale))
			continue;

		DeadPlayer=true;
	}

	if(!DeadPlayer)
	{
		if(ForceRevive)
			return;
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%T", "Player not detected", client);
		return;
	}

	
	int RandomWildHunted = GetRandomDeathPlayer(client);
	if(!IsValidClient(RandomWildHunted))
		return;

	if(!ForceRevive)
		CoffinCharge[client] -= ReviveCost;

	TeutonType[RandomWildHunted] = TEUTON_NONE;
	dieingstate[RandomWildHunted] = 0;

	float PosMe[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", PosMe);
	DHook_RespawnPlayer(RandomWildHunted);
	ForcePlayerCrouch(RandomWildHunted, false);
	DataPack pack;
	CreateDataTimer(0.2, Timer_DelayTele, pack, TIMER_FLAG_NO_MAPCHANGE);
	//Music_EndLastmann(true);
	//LastMann = false;
	//applied_lastmann_buffs_once = false;
	//SDKHooks_UpdateMarkForDeath(RandomHELLDIVER, true);
	//SDKHooks_UpdateMarkForDeath(RandomHELLDIVER, false);
	//More time!!!
	pack.WriteCell(GetClientUserId(RandomWildHunted));
	pack.WriteFloat(PosMe[0]);
	pack.WriteFloat(PosMe[1]);
	pack.WriteFloat(PosMe[2]);

	EmitSoundToAll(g_CoffinRevive[GetRandomInt(0, sizeof(g_CoffinRevive) - 1)], RandomWildHunted, SNDCHAN_STATIC, 80, _, 1.0, 80);
	switch(GetRandomInt(1,3))
	{
		case 1:
			CPrintToChat(client, "{purple}You have commanded the loyalty of %N{purple}.",RandomWildHunted);
		
		case 2:
			CPrintToChat(client, "{yellow}%N{purple} is now a part of the Wild Hunt.",RandomWildHunted);

		case 3:
			CPrintToChat(client, "{purple}Your influence has brought %N{purple} back." ,RandomWildHunted);
	}
	switch(GetRandomInt(1,3))
	{
		case 1:
			CPrintToChat(RandomWildHunted, "{yellow}%N's{purple} procession of the Wild Hunt continues.",client);
		case 2:
			CPrintToChat(RandomWildHunted, "{yellow}%N's{purple} banquet is nearing full preparation. Aid them.",client);
		case 3:
			CPrintToChat(RandomWildHunted, "{purple}Complete {yellow}%N's{purple} vengeance. Leave regret behind.",client);
	}
	PosMe[2] += 45.0;
	TE_Particle("halloween_boss_death_cloud", PosMe, NULL_VECTOR, NULL_VECTOR, RandomWildHunted, _, _, _, _, _, _, _, _, _, 0.0);
	GiveCompleteInvul(RandomWildHunted, 2.0);
	TF2_AddCondition(RandomWildHunted, TFCond_SpeedBuffAlly, 2.0);
	float Duration = 32.0;
	if(ForceRevive)
		Duration *= 2.0;

	ApplyStatusEffect(client, RandomWildHunted, "Call of the Heartbroken", Duration);
	ApplyStatusEffect(client, RandomWildHunted,	"Call of the Heartbroken Internal", Duration + 1.0);
}