

float Leper_InAnimation[MAXPLAYERS+1];
#define spirite "spirites/zerogxplode.spr"

#define EarthStyleShockwaveRange 250.0
void GroundSlam_Map_Precache()
{
	Zero(Leper_InAnimation);
}

public float AbilityGroundSlam(int client, int index, char name[48])
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
	if (TF2_GetClassnameSlot(classname) != TFWeaponSlot_Melee || i_IsWandWeapon[weapon])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Melee Weapon.");
		return 0.0;
	}

	if(Stats_Intelligence(client) < 750)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "You do not have enough Intelligence [25]");
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
	RPGCore_StaminaReduction(weapon, client, StatsForCalcMultiAdd);
	StatsForCalcMultiAdd = Stats_Strength(client);

	float damageDelt = RPGStats_FlatDamageSetStats(client, 0, StatsForCalcMultiAdd);

	damageDelt *= 2.2;

	Ability_OnAbility_Ground_Pound(client, 1, weapon, damageDelt);
	return (GetGameTime() + 15.0);
}

public void Ability_OnAbility_Ground_Pound(int client, int level, int weapon, float damage)
{	
	
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);

	if(!IsValidEntity(viewmodelModel))
		return;
		
	f_OriginalDamage[client] = damage;
	client_slammed_how_many_times[client] = 0;
	client_slammed_how_many_times_limit[client] = (level * 2);
	static float anglesB[3];
	GetClientEyeAngles(client, anglesB);
	static float velocity[3];
	GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velocity);
	velocity[0] *= 1.5;
	velocity[1] *= 1.5;
	velocity[2] = fmax(velocity[2], 600.0);
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);		
		
	float flPos[3]; // original
	float flAng[3]; // original
		
	float flPos_l[3]; // original
	float flAng_l[3]; // original
	GetAttachment(viewmodelModel, "foot_L", flPos, flAng);
			

	i_weaponused[client] = EntIndexToEntRef(weapon);
	particle[client] = ParticleEffectAt(flPos, "raygun_projectile_red_crit", 15.0);
			
	SetParent(viewmodelModel, particle[client], "foot_L");
	
	particle[client] = EntIndexToEntRef(particle[client]);

	GetAttachment(viewmodelModel, "foot_R", flPos_l, flAng_l);
			
	particle_1[client] = ParticleEffectAt(flPos_l, "raygun_projectile_red_crit", 15.0);
			
	SetParent(viewmodelModel, particle_1[client], "foot_R");

	particle_1[client] = EntIndexToEntRef(particle_1[client]);

	Duration_Pound[client] = GetGameTime() + 0.35;
	Is_Duration_Pound[client] = GetGameTime() + 5.0;
		
	SDKHook(client, SDKHook_PreThink, contact_ground_shockwave);

	for(int entity=1; entity<MAXENTITIES; entity++)
	{
		b_GroundPoundHit[client][entity] = false;
	}
	
	EmitSoundToAll("weapons/physcannon/energy_sing_flyby2.wav", client, SNDCHAN_STATIC, 80, _, 0.9);
	f_ImmuneToFalldamage[client] = GetGameTime() + 0.5;
}

public Action contact_ground_shockwave(int client)
{
	Is_Duration_Pound[client] = GetGameTime() + 1.0;
	f_ImmuneToFalldamage[client] = GetGameTime() + 0.5;
	if (Duration_Pound[client] < GetGameTime())
	{
		SetEntityGravity(client, 10.0);
	}
	else
	{
		SetEntityGravity(client, 1.0);
	}
	int flags = GetEntityFlags(client);
	
	if (Duration_Pound[client] < GetGameTime() && ((flags & FL_ONGROUND)==1 || (flags & (FL_SWIM|FL_INWATER))))
	{
		Is_Duration_Pound[client] = 0.0;

		SetEntityGravity(client, 1.0);
		if(IsValidEntity(EntRefToEntIndex(particle[client])))
			RemoveEntity(EntRefToEntIndex(particle[client]));
			
		if(IsValidEntity(EntRefToEntIndex(particle_1[client])))
			RemoveEntity(EntRefToEntIndex(particle_1[client]));

		float vecUp[3];
		
		GetVectors(client, client_slammed_forward[client], client_slammed_right[client], vecUp);
		
		GetAbsOrigin(client, client_slammed_pos[client]);
		client_slammed_pos[client][2] += 5.0;
		
		float vecSwingEnd[3];
		vecSwingEnd[0] = client_slammed_pos[client][0] + client_slammed_forward[client][0] * (90 * client_slammed_how_many_times[client]);
		vecSwingEnd[1] = client_slammed_pos[client][1] + client_slammed_forward[client][1] * (90 * client_slammed_how_many_times[client]);
		vecSwingEnd[2] = client_slammed_pos[client][2] + client_slammed_forward[client][2] * 100;
		
		DataPack pack = new DataPack();
		pack.WriteFloat(vecSwingEnd[0]);
		pack.WriteFloat(vecSwingEnd[1]);
		pack.WriteFloat(vecSwingEnd[2]);
		pack.WriteCell(1);
		RequestFrame(MakeExplosionFrameLater, pack);
		int weapon = EntRefToEntIndex(i_weaponused[client]);
		if(IsValidEntity(weapon))
		{
			i_ExplosiveProjectileHexArray[weapon] = EP_DEALS_CLUB_DAMAGE;
			Explode_Logic_Custom(f_OriginalDamage[client], client, client, weapon, vecSwingEnd,_,_,_,false,_,_,_,_,GroundPoundMeleeHitOnce);
	
		}
		EmitSoundToAll("ambient/atmosphere/terrain_rumble1.wav", client, SNDCHAN_STATIC, 80, _, 0.9);
		CreateEarthquake(vecSwingEnd, 0.5, 350.0, 16.0, 255.0);

		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", vecUp);
		CreateTimer(0.15, shockwave_explosions, client, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		SDKUnhook(client, SDKHook_PreThink, contact_ground_shockwave);
	}
	return Plugin_Continue;
}

float GroundPoundMeleeHitOnce(int entity, int victim, float damage, int weapon)
{
	if(b_GroundPoundHit[entity][victim])
	{
		damage *= -1.0;
		return damage;
	}
	b_GroundPoundHit[entity][victim] = true;
	return damage;
}

public Action shockwave_explosions(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		client_slammed_how_many_times[client] += 1;
		
		float vecSwingEnd[3];
		vecSwingEnd[0] = client_slammed_pos[client][0] + client_slammed_forward[client][0] * (90 * client_slammed_how_many_times[client]);
		vecSwingEnd[1] = client_slammed_pos[client][1] + client_slammed_forward[client][1] * (90 * client_slammed_how_many_times[client]);
		vecSwingEnd[2] = client_slammed_pos[client][2] + client_slammed_forward[client][2] * 100;
		
		DataPack pack = new DataPack();
		pack.WriteFloat(vecSwingEnd[0]);
		pack.WriteFloat(vecSwingEnd[1]);
		pack.WriteFloat(vecSwingEnd[2]);
		pack.WriteCell(1);
		RequestFrame(MakeExplosionFrameLater, pack);

		int weapon = EntRefToEntIndex(i_weaponused[client]);
		if(IsValidEntity(weapon))
		{
			i_ExplosiveProjectileHexArray[weapon] = EP_DEALS_CLUB_DAMAGE;
			Explode_Logic_Custom(f_OriginalDamage[client], client, client, weapon, vecSwingEnd,_,_,_,false,_,_,_,_,GroundPoundMeleeHitOnce);
		}

		if(client_slammed_how_many_times[client] > client_slammed_how_many_times_limit[client])
		{
			return Plugin_Stop;
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}


void PlayerAnimationSettingFreeze(int client, bool Freeze)
{
	int ModelToDelete = 0;
	int CameraDelete = SetCameraEffectLeperHew(client, ModelToDelete);
	DataPack pack;
	Leper_InAnimation[client] = GetGameTime() + 0.8;
	CreateDataTimer(0.8, PlayerAnimationSettingFreezePost, pack, TIMER_FLAG_NO_MAPCHANGE);
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
	int clientindex = pack.ReadCell();
	int client = GetClientOfUserId(pack.ReadCell());
	int camreadelete = EntRefToEntIndex(pack.ReadCell());
	int DeleteKillEntity = EntRefToEntIndex(pack.ReadCell());
	LeperSwingEffect[clientindex] = false;

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
	SetEntityMoveType(client, MOVETYPE_WALK);
	if (thirdperson[client])
	{
		SetVariantInt(1);
		AcceptEntityInput(client, "SetForcedTauntCam");
	}
	return Plugin_Stop;
}


#define LEPER_BOUNDS_VIEW_EFFECT 25.0
#define LEPER_MAXRANGE_VIEW_EFFECT 125.0

int SetCameraEffectAndModel(int client, int &ModelToDelete, int Type)
{
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
//	EmitSoundToClient(client, LEPER_AOE_SWING_HIT, SOUND_FROM_WORLD, SNDCHAN_AUTO, 999,_,0.8,pitch);	
	float vAngles[3];
	float vOrigin[3];
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);

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
	
	int spawn_index = NPC_CreateByName("npc_player_animator", client, vabsOrigin, vabsAngles, GetTeam(client), IntToString(Type));
	if(spawn_index > 0)
	{
		ModelToDelete = spawn_index;
	}
	return viewcontrol;
}
