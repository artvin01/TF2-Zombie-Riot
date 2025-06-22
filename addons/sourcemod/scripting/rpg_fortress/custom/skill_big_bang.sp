

#define spirite "spirites/zerogxplode.spr"

#define EarthStyleShockwaveRange 250.0

void BigBang_Map_Precache()
{
	PrecacheSound(BING_BANG_SOUND);
	PrecacheSound(BING_BANG_BOOM_SOUND);
}

public float AbilityBingBang(int client, int index, char name[48])
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
	if (TF2_GetClassnameSlot(classname, weapon) != TFWeaponSlot_Melee || i_IsWandWeapon[weapon])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Melee Weapon.");
		return 0.0;
	}

	if(Stats_Intelligence(client) < 750)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "You do not have enough Intelligence [750]");
		return 0.0;
	}
	
	
	int StatsForCalcMultiAdd;
	Stats_Strength(client, StatsForCalcMultiAdd);
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
	int Type = 1;
	if(Stats_Intelligence(client) >= 2000)
	{
		Type = 2;
	}
	RPGCore_CancelMovementAbilities(client);
	RPGCore_StaminaReduction(weapon, client, StatsForCalcMultiAdd);
	StatsForCalcMultiAdd = Stats_Strength(client);

	float damageDelt = RPGStats_FlatDamageSetStats(client, 0, StatsForCalcMultiAdd);

	damageDelt *= 4.2;
	PlayerAnimationSettingFreeze(client, Type, damageDelt);
	EmitSoundToAll(BING_BANG_SOUND, client, SNDCHAN_AUTO, 80, _, 1.0, 100);
	EmitSoundToAll(BING_BANG_SOUND, client, SNDCHAN_AUTO, 80, _, 1.0, 100);
	return (GetGameTime() + 15.0);
}

void PlayerAnimationSettingFreeze(int client, int type, float damage)
{
	float TimeUntillUnfreeze;
	switch(type)
	{
		case 1:
		{
			TimeUntillUnfreeze = 2.0;
		}
		case 2:
		{
			TimeUntillUnfreeze = 1.0;
		}
	}
	IncreaseEntityDamageTakenBy(client, 0.5, TimeUntillUnfreeze);
	int ModelToDelete = 0;
	int CameraDelete = SetCameraEffectAndModel(client, ModelToDelete, type, damage);
	DataPack pack;
	CreateDataTimer(TimeUntillUnfreeze, PlayerAnimationSettingFreezePost, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(client);
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(EntIndexToEntRef(CameraDelete));
	pack.WriteCell(EntIndexToEntRef(ModelToDelete));

	TF2_AddCondition(client, TFCond_FreezeInput, -1.0);

	SetEntityMoveType(client, MOVETYPE_NONE);
	SetEntProp(client, Prop_Send, "m_bIsPlayerSimulated", 0);
	SetEntProp(client, Prop_Send, "m_bSimulatedEveryTick", 0);
	SetEntProp(client, Prop_Send, "m_bClientSideAnimation", 0);
	SetEntProp(client, Prop_Send, "m_bClientSideFrameReset", 1);
	SetEntProp(client, Prop_Send, "m_bForceLocalPlayerDraw", 1);
	int entity, i;
	while(TF2U_GetWearable(client, entity, i))
	{
		SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") | EF_NODRAW);
	}
}


public Action PlayerAnimationSettingFreezePost(Handle timer, DataPack pack)
{
	pack.Reset();
	pack.ReadCell();
	int client = GetClientOfUserId(pack.ReadCell());
	int camreadelete = EntRefToEntIndex(pack.ReadCell());
	int DeleteKillEntity = EntRefToEntIndex(pack.ReadCell());

	if(camreadelete != -1)
		RemoveEntity(camreadelete);

	if(DeleteKillEntity != -1)
	{
		SmiteNpcToDeath(DeleteKillEntity);
	}

	if(!client)
		return Plugin_Stop;

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
	return Plugin_Stop;
}


#define LEPER_BOUNDS_VIEW_EFFECT 25.0
#define LEPER_MAXRANGE_VIEW_EFFECT 175.0

int SetCameraEffectAndModel(int client, int &ModelToDelete, int Type, float damage)
{
	/*
	int pitch = GetRandomInt(95,100);	
	for(int clientloop=1; clientloop<=MaxClients; clientloop++)
	{
		if(clientloop != client && !b_IsPlayerABot[clientloop] && IsClientInGame(clientloop))
		{
			switch(Type)
			{
				case 1:
				{
					EmitSoundToClient(clientloop, LEPER_AOE_SWING_HIT, client, SNDCHAN_AUTO, 90,_,0.8,pitch);
				}
			}	
		}
	}
	switch(Type)
	{
		case 1:
		{
			ClientCommand(client,"playgamesound ambient/rottenburg/barrier_smash.wav");
		}
	}	
	*/
	float vAngles[3];
	float vOrigin[3];
	float vecSwingForward[3];
	float vecSwingEnd[3];	
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);

	//always from upwards somewhere.
	vAngles[0] = GetRandomFloat(-2.0 , -1.0);
	/*
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
*/
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
	char Buffer[32];
	IntToString(Type, Buffer, sizeof(Buffer));
	
	int spawn_index = NPC_CreateByName("npc_player_animator", client, vabsOrigin, vabsAngles, GetTeam(client), Buffer);
	if(spawn_index > 0)
	{
		CClotBody npc = view_as<CClotBody>(spawn_index);
		npc.m_flNextMeleeAttack = damage;
		i_AttacksTillReload[spawn_index] = Type;
		ModelToDelete = spawn_index;
	}
	return viewcontrol;
}
