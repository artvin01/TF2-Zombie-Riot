#pragma semicolon 1
#pragma newdecls required

static Handle h_HeartBroken_Timer[MAXPLAYERS] = {null, ...};
static float f_HeartBroken_HUDDelay[MAXPLAYERS];
static int ref_CoffinEntity[MAXPLAYERS];
static int ref_MeleeWeapon[MAXPLAYERS];

#define COFFIN_MODEL "models/props_manor/coffin_02.mdl"
#define HEARTBREAK_DASH "doors/door_metal_large_chamber_close1.wav"
#define HEARTBREAK_DASHHIT "ambient/materials/cartrap_explode_impact1.wav"
#define HEARTBREAK_HORSE_MODEL "models/props_c17/statue_horse.mdl"

static char g_ShootHorseSound[][] = {
	"misc/halloween/spell_athletic.wav",
};
public void HeartBroken_OnMapStart()
{
	PrecacheSoundArray(g_ShootHorseSound);
	Zero(f_HeartBroken_HUDDelay);
	PrecacheModel(COFFIN_MODEL);
	PrecacheModel(HEARTBREAK_HORSE_MODEL);
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
	ref_MeleeWeapon[client] = EntIndexToEntRef(weapon);
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
			Ability_Apply_Cooldown(attacker, 3, Ability_Check_Cooldown(attacker, 3, weapon) - 8.0, weapon, true);
		}
		EmitSoundToAll(HEARTBREAK_DASHHIT, attacker, _, 70, _, 1.0, 100);
		SensalCauseKnockback(attacker, victim, 0.5, false);
		RemoveSpecificBuff(weapon, "Decapitate");
	}
	if(HasSpecificBuff(weapon, "Memorial Possession"))
	{
		if(StatusEffects_MemorialDebuffMaxStacks(weapon))
		{
			MemorialPossession_ActivateAbility(attacker, victim, weapon);
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
		for(int i=0; i<4; i++)
		{
			Heartbroken_ShootHorseProjectile(victim, attacker, 1.0 , 1.5);
		}
		float CounterDamage = 65.0;
		CounterDamage *= WeaponDamageAttributeMultipliers(equipped_weapon,_,victim);
		CounterDamage *= 3.0;
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


public void Heartbroken_SwitchToMeleeWeapon(int client, int weapon, bool crit, int slot)
{
	int MeleeWeapon = EntRefToEntIndex(ref_MeleeWeapon[client]);
	if(!IsValidEntity(MeleeWeapon))
		return;

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
	Heartbroken_SwitchToMeleeWeapon(client, weapon, crit, slot);
	
	int MeleeWeapon = EntRefToEntIndex(ref_MeleeWeapon[client]);
	if(!IsValidEntity(MeleeWeapon))
		return;

	ApplyStatusEffect(MeleeWeapon, MeleeWeapon, "Memorial Possession", 3.0);
	Rogue_OnAbilityUse(client, MeleeWeapon);
	Ability_Apply_Cooldown(client, slot, 15.0);
	EmitSoundToAll(HEARTBREAK_DASH, client, _, 70, _, 1.0, 80);
	EmitSoundToAll(HEARTBREAK_DASH, client, _, 70, _, 1.0, 80);
}
public void Heartbroken_Counter(int client, int weapon, bool crit, int slot)
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
	
	float damage = 50.0;

	HeartBrokenAction(client, damage, -1, 2);
}



void MemorialPossession_ActivateAbility(int attacker, int victim, int weapon)
{
	float damage = 50.0;

	HeartBrokenAction(attacker, damage, victim, 1);
}


#define HEARTBROKEN_BOUNDS_VIEW_EFFECT 25.0
#define HEARTBROKEN_MAXRANGE_VIEW_EFFECT 150.0

static int HeartBrokenAction(int client, float DamageBase, int target, int which)
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
	ApplyStatusEffect(client, client, "Very Defensive Backup", duration);

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
	Initiate_HomingProjectile(projectile,
	projectile,
		40.0,			// float lockonAngleMax,
		10.0 * speedmodif,				//float homingaSec,
		false,				// bool LockOnlyOnce,
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
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
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
	f_WandDamage[entity] *= 0.75;
	switch(GetRandomInt(1,4)) 
	{
		case 1:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
		case 2:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
		case 3:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
		
		case 4:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
	}
	
}