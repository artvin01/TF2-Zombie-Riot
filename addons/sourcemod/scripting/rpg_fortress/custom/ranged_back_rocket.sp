
bool BackRocket_StopHovering[MAXENTITIES];

void BackRockets_MapStart()
{

	PrecacheSound("weapons/drg_wrench_teleport.wav");
}

public float AbilityBackRockets(int client, int index, char name[48])
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
	if (TF2_GetClassnameSlot(classname) == TFWeaponSlot_Melee || i_IsWandWeapon[weapon])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Ranged Weapon.");
		return 0.0;
	}
	if(Stats_Intelligence(client) < 25)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "You do not have enough Intelligence [25]");
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
	RPGCore_StaminaReduction(weapon, client, StatsForCalcMultiAdd / 2);
	RPGCore_ResourceReduction(client, StatsForCalcMultiAdd_Capacity);

	StatsForCalcMultiAdd = Stats_Precision(client);

	float damageDelt = RPGStats_FlatDamageSetStats(client, 0, StatsForCalcMultiAdd);

	damageDelt *= 1.8;

	Ability_BackRocket(client, 1, weapon, damageDelt);
	return (GetGameTime() + 15.0);
}



public void Ability_BackRocket(int client, int level, int weapon, float damage)
{
	CClotBody npc = view_as<CClotBody>(client);
	//Spawns 3 rockets with set damage
//	npc.PlayRocketSound();
	EmitSoundToAll("weapons/rpg/rocketfire1.wav", client, SNDCHAN_AUTO, 80, _, 1.0,_);	
	int RocketIndex = 0;
	for(float loopDo = 0.5; loopDo <= 1.2; loopDo += 0.3)
	{
		//shoot upwards.
		float vecSelf2[3];
		WorldSpaceCenter(npc.index, vecSelf2);
		vecSelf2[2] += 50.0;
		vecSelf2[0] += GetRandomFloat(-10.0, 10.0);
		vecSelf2[1] += GetRandomFloat(-10.0, 10.0);
		float RocketDamage = damage;
		int RocketGet = npc.FireRocket(vecSelf2, RocketDamage, 150.0);
		SetEntPropFloat(RocketGet, Prop_Send, "m_flModelScale", 0.85);
		DataPack pack;
		CreateDataTimer(loopDo, PlayerWF_Rocket_Stand, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(RocketGet));
		pack.WriteCell(EntIndexToEntRef(client));
		BackRocket_StopHovering[RocketGet] = false;
		
		RocketIndex++;
		DataPack pack2 = new DataPack();
		pack2.WriteCell(EntIndexToEntRef(client));
		pack2.WriteCell(EntIndexToEntRef(RocketGet));
		pack2.WriteCell(RocketIndex);
		RequestFrame(BackRocket_HoverBehindPlayer, pack2);
	}
}

void BackRocket_HoverBehindPlayer(DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client))
	{
		delete pack;
		return;
	}
	int RocketGet = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(RocketGet))
	{
		delete pack;
		return;
	}
	int RocketIndex = pack.ReadCell();
	if(BackRocket_StopHovering[RocketGet])
	{
		//stop moving the rocket.
		delete pack;
		return;
	}
	//RocketIndex is used for what offset the rocket should be at!
	float EyesBelowClient[3];
	float OffsetOfRocket[3];
	switch(RocketIndex)
	{
		case 1:
		{
			OffsetOfRocket = {0.0, -40.0, 30.0};
		}
		case 2:
		{
			OffsetOfRocket = {0.0, 0.0, 50.0};
		}
		case 3:
		{
			OffsetOfRocket = {0.0, 40.0, 30.0};
		}
	}

	float DummyAngles[3];
	float fFinalPos[3];
	float Velocity[3];
	float Angles[3];
	GetClientEyeAngles(client, DummyAngles);
	GetBeamDrawStartPoint_Stock(client, EyesBelowClient, OffsetOfRocket);
	float CurrentRocketPos[3]; 
	WorldSpaceCenter(RocketGet, CurrentRocketPos);

	MakeVectorFromPoints(CurrentRocketPos, EyesBelowClient, fFinalPos);

	float flDistanceToTarget = GetVectorDistance(CurrentRocketPos, EyesBelowClient);
	if(flDistanceToTarget >= 5.0)
	{
			
		GetVectorAngles(fFinalPos, Angles);
		GetAngleVectors(Angles, Velocity, NULL_VECTOR, NULL_VECTOR);
			
		float mult = (flDistanceToTarget / 80.0);
		float CurrentVelocity = 500.0;
		mult *= 2.0;
		/*
		float SubjectAbsVelocity[3];
		GetEntPropVector(RocketGet, Prop_Data, "m_vecAbsVelocity", SubjectAbsVelocity);
		CurrentVelocity = SquareRoot(Pow(SubjectAbsVelocity[0], 2.0)+Pow(SubjectAbsVelocity[1], 2.0));
		PrintToChatAll("Velocity %1.f",CurrentVelocity);
		*/
		float FinalVelScale = CurrentVelocity * mult;
		ScaleVector(Velocity, FinalVelScale);
		//out endgoal is now EyesBelowClient
		//we now try to move the rocket to this location via speed.
		float eyeAng[3];
		GetClientEyeAngles(client, eyeAng);
		TeleportEntity(RocketGet, NULL_VECTOR, eyeAng, Velocity);
	}
		
	
	//repeat next frame.
	RequestFrame(BackRocket_HoverBehindPlayer, pack);
}

//from wand of skulls
stock void AddInFrontOf(float fVecOrigin[3], float fVecAngle[3], float fUnits, float fOutPut[3])
{
	float fVecView[3]; GetViewVector(fVecAngle, fVecView);
	
	fOutPut[0] = fVecView[0] * fUnits + fVecOrigin[0];
	fOutPut[1] = fVecView[1] * fUnits + fVecOrigin[1];
	fOutPut[2] = fVecView[2] * fUnits + fVecOrigin[2];
}
stock void GetViewVector(float fVecAngle[3], float fOutPut[3])
{
	fOutPut[0] = Cosine(fVecAngle[1] / (180 / FLOAT_PI));
	fOutPut[1] = Sine(fVecAngle[1] / (180 / FLOAT_PI));
	fOutPut[2] = -Sine(fVecAngle[0] / (180 / FLOAT_PI));
}

public Action PlayerWF_Rocket_Stand(Handle timer, DataPack pack)
{
	pack.Reset();
	int RocketEnt = EntRefToEntIndex(pack.ReadCell());
	int RocketOwner = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(RocketEnt))
		return Plugin_Stop;
		
	if(!IsValidEntity(RocketOwner))
	{
		RemoveEntity(RocketEnt);
		return Plugin_Stop;
	}
	EmitSoundToAll("weapons/sentry_spot_client.wav", RocketEnt, SNDCHAN_AUTO, 80, _, 1.0,_);	

	float vecSelf[3];
	WorldSpaceCenter(RocketEnt, vecSelf);
	float vecEndGoal[3];
	float eyePos[3];
	float eyeAng[3];
			   
	GetClientEyePosition(RocketOwner, eyePos);
	GetClientEyeAngles(RocketOwner, eyeAng);
	Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, RocketOwner);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(vecEndGoal, trace);
	} 			
	delete trace;
	
	TE_SetupBeamPoints(vecSelf, vecEndGoal, Shared_BEAM_Laser, 0, 0, 0, 0.11, 3.0, 3.0, 0, 0.0, {0,0,255,255}, 3);
	TE_SendToAll(0.0);
	float vecAngles[3];
	MakeVectorFromPoints(vecSelf, vecEndGoal, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);
	TeleportEntity(RocketEnt, NULL_VECTOR, vecAngles, {0.0,0.0,0.0});
	DataPack pack2;
	CreateDataTimer(0.1, PlayerWF_Rocket_Stand_Fire, pack2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	pack2.WriteCell(EntIndexToEntRef(RocketEnt));
	pack2.WriteCell(EntIndexToEntRef(RocketOwner));
	pack2.WriteFloat(GetGameTime() + 1.0); //time till rocketing to Target
	return Plugin_Stop;
}


public Action PlayerWF_Rocket_Stand_Fire(Handle timer, DataPack pack)
{
	pack.Reset();
	int RocketEnt = EntRefToEntIndex(pack.ReadCell());
	int RocketOwner = EntRefToEntIndex(pack.ReadCell());
	float TimeTillRocketing = pack.ReadFloat();
	if(!IsValidEntity(RocketEnt))
		return Plugin_Stop;
		
	if(!IsValidEntity(RocketOwner))
	{
		RemoveEntity(RocketEnt);
		return Plugin_Stop;
	}

	//keep looking at them
	float vecSelf[3];
	WorldSpaceCenter(RocketEnt, vecSelf);
	float vecEndGoal[3];
	float eyePos[3];
	float eyeAng[3];
			   
	GetClientEyePosition(RocketOwner, eyePos);
	GetClientEyeAngles(RocketOwner, eyeAng);
	Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, RocketOwner);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(vecEndGoal, trace);
	} 			
	delete trace;
	
	
	float VecSpeedToDo[3];
	float vecAngles[3];
	MakeVectorFromPoints(vecSelf, vecEndGoal, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);
	if(TimeTillRocketing < GetGameTime())
	{
		float SpeedApply = 1000.0;
		VecSpeedToDo[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*SpeedApply;
		VecSpeedToDo[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*SpeedApply;
		VecSpeedToDo[2] = Sine(DegToRad(vecAngles[0]))*-SpeedApply;
		TE_SetupBeamPoints(vecSelf, vecEndGoal, Shared_BEAM_Laser, 0, 0, 0, 0.11, 3.0, 3.0, 0, 0.0, {255,0,0,255}, 3);
		TE_SendToAll(0.0);
		EmitSoundToAll("weapons/sentry_rocket.wav", RocketEnt, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);	
		BackRocket_StopHovering[RocketEnt] = true;
	}
	else
	{
		
		TE_SetupBeamPoints(vecSelf, vecEndGoal, Shared_BEAM_Laser, 0, 0, 0, 0.11, 3.0, 3.0, 0, 0.0, {0,0,255,255}, 3);
		TE_SendToAll(0.0);
	}
	TeleportEntity(RocketEnt, NULL_VECTOR, vecAngles, VecSpeedToDo);
	if(TimeTillRocketing < GetGameTime())
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}