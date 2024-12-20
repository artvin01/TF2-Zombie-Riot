#pragma semicolon 1
#pragma newdecls required

#define LEPER_NORMAL_HIT	"weapons/halloween_boss/knight_axe_hit.wav"
#define LEPER_AOE_SWING_HIT	"ambient/rottenburg/barrier_smash.wav"
#define LEPER_SOLEMNY	"misc/halloween/spell_overheal.wav"

#define LEPER_SOLEMNY_MAX		2
#define LEPER_SOLEMNY_MAX_HITS	10
#define LEPER_SOLEMNY_MAX_INCREACE	5


#define LEPER_NORMAL_SWING 0
#define LEPER_AOE_HEW 1

int LeperSwingType[MAXPLAYERS+1];
bool LeperSwingEffect[MAXPLAYERS+1];
Handle Timer_Leper_Management[MAXPLAYERS+1] = {null, ...};
float Leper_HudDelay[MAXPLAYERS+1];
int Leper_SolemnyUses[MAXPLAYERS+1];
int Leper_SolemnyCharge[MAXPLAYERS+1];
float Leper_SolemnyChargeCD[MAXPLAYERS+1];
float Leper_InAnimation[MAXPLAYERS+1];

void OnMapStartLeper()
{
	PrecacheSound(LEPER_NORMAL_HIT);
	PrecacheSound(LEPER_AOE_SWING_HIT);
	PrecacheSound(LEPER_SOLEMNY);
	Zero(LeperSwingEffect);
	Zero(LeperSwingType);
	Zero(Timer_Leper_Management);
	Zero(Leper_SolemnyChargeCD);
	Zero(Leper_HudDelay);
	Zero(Leper_InAnimation);
}

int LeperEnemyAoeHit(int client)
{
	switch(LeperSwingType[client])
	{
		case LEPER_NORMAL_SWING:
			return 1;

		case LEPER_AOE_HEW:
			return 5;
	}
	return 1;
}

int MaxCurrentHitsNeededSolemnity(int client)
{
	if(Leper_SolemnyUses[client] < LEPER_SOLEMNY_MAX)
	{
		return LEPER_SOLEMNY_MAX_HITS;
	}
	else
	{
		return (LEPER_SOLEMNY_MAX_HITS + ((Leper_SolemnyUses[client] - 1) * LEPER_SOLEMNY_MAX_INCREACE));
	}
}

bool IsLeperInAnimation(int client)
{
	if(Leper_InAnimation[client] > GetGameTime())
		return true;
	
	return false;
}
void PlayCustomSoundLeper(int client, int victim)
{
	switch(LeperSwingType[client])
	{
		case LEPER_NORMAL_SWING:
		{
			int pitch = GetRandomInt(95,100);
			EmitSoundToAll(LEPER_NORMAL_HIT, client, SNDCHAN_AUTO, 75,_,0.8,pitch);			
		}
		case LEPER_AOE_HEW:
		{
			LeperStunEnemy(victim, client);
			LeperOnSuperHitEffect(client);		
		}
	}
}
void LeperStunEnemy(int victim, int client)
{
	int Weight = i_NpcWeight[victim];
	if(Weight >= 6)
		return;
	
	float ReduceKnockback = 1.0;

	switch(Weight)
	{
		case 1:
		{
			ReduceKnockback = 1.0;
		}
		case 2:
		{
			ReduceKnockback = 0.8;
		}
		case 3:
		{
			ReduceKnockback = 0.65;
		}
		case 4:
		{
			ReduceKnockback = 0.6;
		}
		case 5:
		{
			ReduceKnockback = 0.4;
		}
	}
	FreezeNpcInTime(victim, 1.0 * ReduceKnockback);
	Custom_Knockback(client, victim, 750.0 * ReduceKnockback, true, true, true);
}
public void Weapon_LeperHewCharge(int client, int weapon, bool &result, int slot)
{
	float cooldown = Ability_Check_Cooldown(client, slot);
	if(cooldown < 0.0)
	{
		switch(LeperSwingType[client])
		{
			case LEPER_NORMAL_SWING:
				LeperSwingType[client] = LEPER_AOE_HEW;

			case LEPER_AOE_HEW:
				LeperSwingType[client] = LEPER_NORMAL_SWING;
		}
		Leper_Hud_Logic(client, weapon, true);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);	
	}
}
public void Weapon_LeperSolemny(int client, int weapon, bool &result, int slot)
{
	if (Leper_InAnimation[client] > GetGameTime())
		return;
	
	float cooldown = Ability_Check_Cooldown(client, slot);
	if(cooldown < 0.0)
	{
		Leper_Hud_Logic(client, weapon, true);
		if(!CvarInfiniteCash.BoolValue)
		{
			if(Leper_SolemnyCharge[client] < MaxCurrentHitsNeededSolemnity(client))
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				return;
			}
		}

		Leper_SolemnyCharge[client] = 0;
		Leper_SolemnyUses[client]++;

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
		int ModelToDelete = 0;
		int CameraDelete = SetCameraEffectLeperSolemny(client, ModelToDelete);
		DataPack pack;
		switch(i_CustomWeaponEquipLogic[weapon])
		{
			case WEAPON_LEPER_MELEE:
			{
				HealEntityGlobal(client, client, float(SDKCall_GetMaxHealth(client)) * 0.33, _, 1.8,HEAL_SELFHEAL);
				GiveArmorViaPercentage(client, 0.33, 1.0);
			}
			case WEAPON_LEPER_MELEE_PAP:
			{
				HealEntityGlobal(client, client, float(SDKCall_GetMaxHealth(client)) * 0.5, _, 1.8,HEAL_SELFHEAL);
				GiveArmorViaPercentage(client, 0.5, 1.0);
			}
		}
		/*
		Grant 50% health and armor.
		*/
		Leper_InAnimation[client] = GetGameTime() + 1.85;
		CreateDataTimer(1.85, Leper_SuperHitInitital_After, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(GetClientUserId(client));
		pack.WriteCell(EntIndexToEntRef(CameraDelete));
		pack.WriteCell(EntIndexToEntRef(ModelToDelete));
		pack.WriteCell(0);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);	
	}
}
//Freeze in place and cause effect.
void RemoveSuperSwingLeper(int client)
{
	LeperSwingType[client] = LEPER_NORMAL_SWING;
	Ability_Apply_Cooldown(client, 3, 15.0);
}
void LeperOnSuperHitEffect(int client)
{
	if(LeperSwingEffect[client])
		return;
	
	//Ref doesnt matter as its a fixed array.
	RequestFrame(RemoveSuperSwingLeper, client);

	LeperSwingEffect[client] = true;
	int ModelToDelete = 0;
	int CameraDelete = SetCameraEffectLeperHew(client, ModelToDelete);
	DataPack pack;
	Leper_InAnimation[client] = GetGameTime() + 0.8;
	CreateDataTimer(0.8, Leper_SuperHitInitital_After, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(client);
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(EntIndexToEntRef(CameraDelete));
	pack.WriteCell(EntIndexToEntRef(ModelToDelete));
	pack.WriteCell(0);


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
}

public Action Leper_SuperHitInitital_After(Handle timer, DataPack pack)
{
	pack.Reset();
	int clientindex = pack.ReadCell();
	int client = GetClientOfUserId(pack.ReadCell());
	int camreadelete = EntRefToEntIndex(pack.ReadCell());
	int DeleteKillEntity = EntRefToEntIndex(pack.ReadCell());
	int ExtraLogic = pack.ReadCell();
	LeperSwingEffect[clientindex] = false;

	if(camreadelete != -1)
		RemoveEntity(camreadelete);

	if(DeleteKillEntity != -1)
	{
		SmiteNpcToDeath(DeleteKillEntity);
	}

	if(!client)
		return Plugin_Stop;
		
	if(dieingstate[client] == 0)
		b_ThisEntityIgnored[client] = false;
		
	SetClientViewEntity(client, client);
	TF2_RemoveCondition(client, TFCond_FreezeInput);
	SetEntProp(client, Prop_Send, "m_bIsPlayerSimulated", 1);
//	SetEntProp(client, Prop_Send, "m_bAnimatedEveryTick", 1);
	SetEntProp(client, Prop_Send, "m_bSimulatedEveryTick", 1);
	SetEntProp(client, Prop_Send, "m_bClientSideAnimation", 1);
	SetEntProp(client, Prop_Send, "m_bClientSideFrameReset", 0);	
	SetEntProp(client, Prop_Send, "m_bForceLocalPlayerDraw", 0);
//its too offset, clientside prediction makes this impossible
	if(!b_HideCosmeticsPlayer[client])
	{
		int entity, i;
		while(TF2U_GetWearable(client, entity, i))
		{
			SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") &~ EF_NODRAW);
		}
	}
	else
	{
		int entity, i;
		while(TF2U_GetWearable(client, entity, i))
		{
			if(Viewchanges_NotAWearable(client, entity))
				SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") &~ EF_NODRAW);
		}
	}
	SetEntityMoveType(client, MOVETYPE_WALK);
	if (thirdperson[client])
	{
		SetVariantInt(1);
		AcceptEntityInput(client, "SetForcedTauntCam");
	}
	if(ExtraLogic == 1)
	{
		ClientCommand(client, "playgamesound weapons/air_burster_explode3.wav");
		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		float knockback = -325.0;
		// knockback is the overall force with which you be pushed, don't touch other stuff
		ScaleVector(velocity, knockback);
		if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			velocity[2] = fmax(velocity[2], 300.0);
		else
			velocity[2] += 150.0;    // a little boost to alleviate arcing issues

		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
		//knockback target
	}
	return Plugin_Stop;
}

#define LEPER_BOUNDS_VIEW_EFFECT 25.0
#define LEPER_MAXRANGE_VIEW_EFFECT 125.0

int SetCameraEffectLeperHew(int client, int &ModelToDelete)
{
	int pitch = GetRandomInt(95,100);	
	for(int clientloop=1; clientloop<=MaxClients; clientloop++)
	{
		if(clientloop != client && !b_IsPlayerABot[clientloop] && IsClientInGame(clientloop))
		{
			EmitSoundToClient(clientloop, LEPER_AOE_SWING_HIT, client, SNDCHAN_AUTO, 90,_,0.8,pitch);	
		}
	}
	ClientCommand(client,"playgamesound ambient/rottenburg/barrier_smash.wav");
//	EmitSoundToClient(client, LEPER_AOE_SWING_HIT, SOUND_FROM_WORLD, SNDCHAN_AUTO, 999,_,0.8,pitch);	
	float vAngles[3];
	float vOrigin[3];
	
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	float vecSwingForward[3];
	float vecSwingEnd[3];
	GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);
	vecSwingEnd[0] = vOrigin[0] + vecSwingForward[0] * LEPER_MAXRANGE_VIEW_EFFECT * 0.25;
	vecSwingEnd[1] = vOrigin[1] + vecSwingForward[1] * LEPER_MAXRANGE_VIEW_EFFECT * 0.25;
	vecSwingEnd[2] = vOrigin[2] + vecSwingForward[2] * LEPER_MAXRANGE_VIEW_EFFECT * 0.25;
	vecSwingEnd[2] -= 30.0;
	TE_Particle("hammer_impact_button_dust", vecSwingEnd, NULL_VECTOR, vAngles, -1, _, _, _, _, _, _, _, _, _, 0.0);

	//always from upwards somewhere.
	vAngles[0] = GetRandomFloat(-10.0 , -5.0);
	switch(GetRandomInt(0,1))
	{
		case 0:
		{
			vAngles[1] += GetRandomFloat(80.0 , 90.0);
		}
		case 1:
		{
			vAngles[1] -= GetRandomFloat(80.0 , 90.0);
		}
	}

	float LeperViewAnglesMins[3];
	float LeperViewAnglesMaxs[3];
	LeperViewAnglesMins = view_as<float>({-LEPER_BOUNDS_VIEW_EFFECT, -LEPER_BOUNDS_VIEW_EFFECT, -LEPER_BOUNDS_VIEW_EFFECT});
	LeperViewAnglesMaxs = view_as<float>({LEPER_BOUNDS_VIEW_EFFECT, LEPER_BOUNDS_VIEW_EFFECT, LEPER_BOUNDS_VIEW_EFFECT});

	GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);

	vecSwingEnd[0] = vOrigin[0] + vecSwingForward[0] * LEPER_MAXRANGE_VIEW_EFFECT;
	vecSwingEnd[1] = vOrigin[1] + vecSwingForward[1] * LEPER_MAXRANGE_VIEW_EFFECT;
	vecSwingEnd[2] = vOrigin[2] + vecSwingForward[2] * LEPER_MAXRANGE_VIEW_EFFECT;
	Handle trace = TR_TraceHullFilterEx( vOrigin, vecSwingEnd, LeperViewAnglesMins, LeperViewAnglesMaxs, ( MASK_SOLID ), TraceRayHitWorldOnly, client );
	if ( TR_GetFraction(trace) < 1.0)
	{
		//we hit nothing something, uh oh!
		TR_GetEndPosition(vecSwingEnd, trace);
	}
	GetClientEyeAngles(client, vAngles);
	vAngles[0] = 0.0;
	GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);

	delete trace;

	float vecSwingEndMiddle[3];
	vecSwingEndMiddle[0] = vOrigin[0] + vecSwingForward[0] * LEPER_MAXRANGE_VIEW_EFFECT;
	vecSwingEndMiddle[1] = vOrigin[1] + vecSwingForward[1] * LEPER_MAXRANGE_VIEW_EFFECT;
	vecSwingEndMiddle[2] = vOrigin[2] + vecSwingForward[2] * LEPER_MAXRANGE_VIEW_EFFECT;
	trace = TR_TraceHullFilterEx( vOrigin, vecSwingEndMiddle, LeperViewAnglesMins, LeperViewAnglesMaxs, ( MASK_SOLID ), TraceRayHitWorldOnly, client );
	if ( TR_GetFraction(trace) < 1.0)
	{
		//we hit nothing something, uh oh!
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
	
	int spawn_index = NPC_CreateByName("npc_allied_leper_visualiser", client, vabsOrigin, vabsAngles, GetTeam(client));
	if(spawn_index > 0)
	{
		i_AttacksTillReload[spawn_index] = 0;
		ModelToDelete = spawn_index;
	}
	GetClientEyeAngles(client, vabsAngles);
	int PreviousProjectile;
	static float AngEffect[3];
	AngEffect = vabsAngles;

	int MaxRepeats = 4;
	AngEffect[1] -= 90.0;
	for(int repeat; repeat <= MaxRepeats; repeat ++)
	{
		int projectile = Wand_Projectile_Spawn(client, 500.0, 99999.9, 0.0, -1, 0, "", AngEffect);
		DataPack pack2 = new DataPack();
		int laser = projectile;
		if(IsValidEntity(PreviousProjectile))
		{
			laser = ConnectWithBeam(projectile, PreviousProjectile, 255, 255, 255, 10.0, 10.0, 1.0);
		}
		SetEntityMoveType(projectile, MOVETYPE_NOCLIP);
		PreviousProjectile = projectile;
		pack2.WriteCell(EntIndexToEntRef(projectile));
		pack2.WriteCell(EntIndexToEntRef(laser));
		RequestFrames(Mylnar_DeleteLaserAndParticle, 18, pack2);
		AngEffect[1] += (180.0 / float(MaxRepeats));
	}
	return viewcontrol;
}



int SetCameraEffectLeperSolemny(int client, int &ModelToDelete)
{
	int pitch = GetRandomInt(95,100);
	for(int clientloop=1; clientloop<=MaxClients; clientloop++)
	{
		if(clientloop != client && !b_IsPlayerABot[clientloop] && IsClientInGame(clientloop))
		{
			EmitSoundToClient(clientloop, LEPER_SOLEMNY, client, SNDCHAN_AUTO, 90,_,0.8,pitch);	
		}
	}
	ClientCommand(client,"playgamesound misc/halloween/spell_overheal.wav");
//	EmitSoundToClient(client, LEPER_AOE_SWING_HIT, SOUND_FROM_WORLD, SNDCHAN_AUTO, 999,_,0.8,pitch);	
	float vAngles[3];
	float vOrigin[3];
	
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	float vecSwingForward[3];
	float vecSwingEnd[3];

	//always from upwards somewhere.
	vAngles[0] = GetRandomFloat(-10.0 , -5.0);

	float LeperViewAnglesMins[3];
	float LeperViewAnglesMaxs[3];
	LeperViewAnglesMins = view_as<float>({-LEPER_BOUNDS_VIEW_EFFECT, -LEPER_BOUNDS_VIEW_EFFECT, -LEPER_BOUNDS_VIEW_EFFECT});
	LeperViewAnglesMaxs = view_as<float>({LEPER_BOUNDS_VIEW_EFFECT, LEPER_BOUNDS_VIEW_EFFECT, LEPER_BOUNDS_VIEW_EFFECT});

	GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);

	vecSwingEnd[0] = vOrigin[0] + vecSwingForward[0] * LEPER_MAXRANGE_VIEW_EFFECT * 0.5;
	vecSwingEnd[1] = vOrigin[1] + vecSwingForward[1] * LEPER_MAXRANGE_VIEW_EFFECT * 0.5;
	vecSwingEnd[2] = vOrigin[2] + vecSwingForward[2] * LEPER_MAXRANGE_VIEW_EFFECT * 0.5;
	Handle trace = TR_TraceHullFilterEx( vOrigin, vecSwingEnd, LeperViewAnglesMins, LeperViewAnglesMaxs, ( MASK_SOLID ), TraceRayHitWorldOnly, client );
	if ( TR_GetFraction(trace) < 1.0)
	{
		//we hit nothing something, uh oh!
		TR_GetEndPosition(vecSwingEnd, trace);
	}
	delete trace;

	int viewcontrol = CreateEntityByName("prop_dynamic");
	if (IsValidEntity(viewcontrol))
	{
		float vAngleCamera[3];
		GetVectorAnglesTwoPoints(vecSwingEnd, vOrigin, vAngleCamera);
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
	int spawn_index = NPC_CreateByName("npc_allied_leper_visualiser", client, vabsOrigin, vabsAngles, GetTeam(client));
	if(spawn_index > 0)
	{
		i_AttacksTillReload[spawn_index] = 1;
		ModelToDelete = spawn_index;
	}

	return viewcontrol;
}





public void Enable_Leper(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (Timer_Leper_Management[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_LEPER_MELEE || i_CustomWeaponEquipLogic[weapon] == WEAPON_LEPER_MELEE_PAP) //2
		{
			//Is the weapon it again?
			//Yes?
			delete Timer_Leper_Management[client];
			Timer_Leper_Management[client] = null;
			DataPack pack;
			Timer_Leper_Management[client] = CreateDataTimer(0.1, Timer_Management_Leper, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_LEPER_MELEE || i_CustomWeaponEquipLogic[weapon] == WEAPON_LEPER_MELEE_PAP) //
	{
		DataPack pack;
		Timer_Leper_Management[client] = CreateDataTimer(0.1, Timer_Management_Leper, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}


public Action Timer_Management_Leper(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Timer_Leper_Management[client] = null;
		return Plugin_Stop;
	}	
	Leper_Hud_Logic(client, weapon, false);
		
	return Plugin_Continue;
}


public void Leper_Hud_Logic(int client, int weapon, bool ignoreCD)
{
	//Do your code here :)
	if(Leper_HudDelay[client] > GetGameTime() && !ignoreCD)
		return;

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding != weapon) //Only show if the weapon is actually in your hand right now.
	{
		if(Leper_SolemnyChargeCD[client] < GetGameTime())
		{
			if(!Waves_InSetup())
			{
				Leper_SolemnyCharge[client] --;
				if(Leper_SolemnyCharge[client] <= 0)
					Leper_SolemnyCharge[client] = 0;
			}

			Leper_SolemnyChargeCD[client] = GetGameTime() + 3.5;
		}
		Leper_HudDelay[client] = GetGameTime() + 0.5;

		return;
	}

	char LeperHud[256];
	switch(LeperSwingType[client])
	{
		case LEPER_NORMAL_SWING:
		{
			Format(LeperHud, sizeof(LeperHud), "Hew Inactive [R]\n");
		}
		case LEPER_AOE_HEW:
		{
			Format(LeperHud, sizeof(LeperHud), "Hew ACTIVE [R]\n");
		}
	}
	if(Leper_SolemnyCharge[client] >= MaxCurrentHitsNeededSolemnity(client))
	{
		if(Leper_SolemnyUses[client] >= LEPER_SOLEMNY_MAX)
		{
			Format(LeperHud, sizeof(LeperHud), "%sSolemnity OVER [M2] %i", LeperHud,Leper_SolemnyUses[client]);
		}
		else
		{
			Format(LeperHud, sizeof(LeperHud), "%sSolemnity [M2] %i", LeperHud,LEPER_SOLEMNY_MAX - Leper_SolemnyUses[client]);
		}
	}
	else
	{
		if(Leper_SolemnyUses[client] >= LEPER_SOLEMNY_MAX)
		{
			Format(LeperHud, sizeof(LeperHud), "%sSolemnity OVER (%i/%i)", LeperHud,Leper_SolemnyCharge[client], MaxCurrentHitsNeededSolemnity(client));	
		}
		else
		{
			Format(LeperHud, sizeof(LeperHud), "%sSolemnity (%i/%i)", LeperHud,Leper_SolemnyCharge[client], MaxCurrentHitsNeededSolemnity(client));	
		}
	}

	PrintHintText(client,"%s",LeperHud);
	StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
	Leper_HudDelay[client] = GetGameTime() + 0.5;
}
public float WeaponLeper_OnTakeDamagePlayer(int victim, float &damage, int attacker, int weapon, float damagePosition[3])
{
	if (Leper_InAnimation[victim] > GetGameTime())
	{
		return damage * 0.75; //half damage during animations.
	}
	return damage; //half damage during animations.
}
public float WeaponLeper_OnTakeDamagePlayer_Hud(int victim)
{
	if (Leper_InAnimation[victim] > GetGameTime())
	{
		return 0.75; //half damage during animations.
	}
	return 1.0; //half damage during animations.
}

void WeaponLeper_OnTakeDamage(int attacker, float &damage, int weapon, int zr_damage_custom)
{
	if(zr_damage_custom & ZR_DAMAGE_REFLECT_LOGIC)
		return;

	switch(LeperSwingType[attacker])
	{
		case LEPER_AOE_HEW:
			damage *= 1.25;
	}

	Leper_SolemnyCharge[attacker]++;
	if(Leper_SolemnyCharge[attacker] > MaxCurrentHitsNeededSolemnity(attacker))
		Leper_SolemnyCharge[attacker] = MaxCurrentHitsNeededSolemnity(attacker);

	Leper_Hud_Logic(attacker, weapon, true);
}

void LeperResetUses()
{

	Zero(Leper_SolemnyUses);
}
