
#define MAX_SILVESTER_COSMETIC_ENERGY_EFFECTS 55
static int i_SilvesterCosmeticEffect[MAXENTITIES][MAX_SILVESTER_COSMETIC_ENERGY_EFFECTS];
static Handle h_SilvesterCosmeticEffectManagement[MAXPLAYERS+1] = {null, ...};

void SilvesterCosmeticRemoveEffects(int iNpc)
{
	for(int loop = 0; loop<MAX_SILVESTER_COSMETIC_ENERGY_EFFECTS; loop++)
	{
		int entity = EntRefToEntIndex(i_SilvesterCosmeticEffect[iNpc][loop]);
		if(IsValidEntity(entity))
		{
			RemoveEntity(entity);
		}
		i_SilvesterCosmeticEffect[iNpc][loop] = INVALID_ENT_REFERENCE;
	}
}


bool SilvesterCosmeticEffects_IfNotAvaiable(int iNpc)
{
	for(int loop = 0; loop<MAX_SILVESTER_COSMETIC_ENERGY_EFFECTS; loop++)
	{
		int entity = EntRefToEntIndex(i_SilvesterCosmeticEffect[iNpc][loop]);
		if(!IsValidEntity(entity))
		{
			return true;
		}
	}
	return false;
}

void ApplyExtraSilvesterCosmeticEffects(int client, bool remove = false)
{
	if(remove)
	{
		SilvesterCosmeticRemoveEffects(client);
		return;
	}
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);

	if(!IsValidEntity(viewmodelModel))
	{
		SilvesterCosmeticRemoveEffects(client);
		return;
	}

	if(SilvesterCosmeticEffects_IfNotAvaiable(client))
	{
		SilvesterCosmeticRemoveEffects(client);
		SilvesterCosmeticEffects(client,viewmodelModel);
	}
}


public void EnableSilvesterCosmetic(int client) 
{
	if(TeutonType[client] != TEUTON_NONE)
		return;
		
	bool HasWings = view_as<bool>(Store_HasNamedItem(client, "Silvester Cosmetic Wings [???]"));
	if (h_SilvesterCosmeticEffectManagement[client] != null)
	{
		//This timer already exists.
		if(HasWings)
		{
			SilvesterCosmeticRemoveEffects(client);
			ApplyExtraSilvesterCosmeticEffects(client,_);
			//Is the weapon it again?
			//Yes?
			delete h_SilvesterCosmeticEffectManagement[client];
			h_SilvesterCosmeticEffectManagement[client] = null;
			DataPack pack;
			h_SilvesterCosmeticEffectManagement[client] = CreateDataTimer(0.1, TimerSilvesterCosmetic, pack, TIMER_REPEAT);
			pack.WriteCell(client);
		}
		return;
	}
	
	if(HasWings)
	{
		SilvesterCosmeticRemoveEffects(client);
		ApplyExtraSilvesterCosmeticEffects(client,_);
		DataPack pack;
		h_SilvesterCosmeticEffectManagement[client] = CreateDataTimer(0.1, TimerSilvesterCosmetic, pack, TIMER_REPEAT);
		pack.WriteCell(client);
	}
}


public Action TimerSilvesterCosmetic(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		ApplyExtraSilvesterCosmeticEffects(client,true);
		h_SilvesterCosmeticEffectManagement[client] = null;
		return Plugin_Stop;
	}	
	if(TeutonType[client] != TEUTON_NONE)
	{
		ApplyExtraSilvesterCosmeticEffects(client,true);
		h_SilvesterCosmeticEffectManagement[client] = null;
		return Plugin_Stop;
	}
	bool HasWings = view_as<bool>(Store_HasNamedItem(client, "Silvester Cosmetic Wings [???]"));
	if(!HasWings)
	{
		ApplyExtraSilvesterCosmeticEffects(client,true);
		h_SilvesterCosmeticEffectManagement[client] = null;
		return Plugin_Stop;
	}
	ApplyExtraSilvesterCosmeticEffects(client);
		
	return Plugin_Continue;
}

void SilvesterCosmeticEffects(int entity, int wearable)
{
	int red = 190;
	int green = 190;
	int blue = 0;
	float flPos[3];
	float flAng[3];
	
	//possible loop function?
	/*
		Fist axies from the POV of the person LOOKINGF at the equipper
		flag

		1st: left and right, negative is left, positive is right 
		2nd: Up and down, negative up, positive down.
		3rd: front and back, negative goes back.
	*/

	int ParticleOffsetMain = ParticleEffectAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	GetAttachment(wearable, "flag", flPos, flAng);
	Custom_SDKCall_SetLocalOrigin(ParticleOffsetMain, flPos);
	SetEntPropVector(ParticleOffsetMain, Prop_Data, "m_angRotation", flAng); 
	SetParent(wearable, ParticleOffsetMain, "flag",_);
	
	int particle_1_Wingset_1 = ParticleEffectAt({26.0,30.0,-11.0}, "", 0.0); //This is the root bone basically

	int particle_2_Wingset_1 = ParticleEffectAt({-12.1,-12.1,-9.1}, "", 0.0); 
	int particle_3_Wingset_1 = ParticleEffectAt({12.1,12.1,-9.1}, "", 0.0); 
	int particle_4_Wingset_1 = ParticleEffectAt({-6.1,9.1,-9.1}, "", 0.0); 
	int particle_5_Wingset_1 = ParticleEffectAt({9.1,-6.1,-9.1}, "", 0.0);


	SetParent(particle_1_Wingset_1, particle_2_Wingset_1, "",_, true);
	SetParent(particle_1_Wingset_1, particle_3_Wingset_1, "",_, true);
	SetParent(particle_1_Wingset_1, particle_4_Wingset_1, "",_, true);
	SetParent(particle_1_Wingset_1, particle_5_Wingset_1, "",_, true);

	
	Custom_SDKCall_SetLocalOrigin(particle_1_Wingset_1, flPos);
	SetEntPropVector(particle_1_Wingset_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_1_Wingset_1, "",_);
	
	int Laser_1_Wingset_1 = ConnectWithBeamClient(particle_2_Wingset_1, particle_5_Wingset_1, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);
	int Laser_2_Wingset_1 = ConnectWithBeamClient(particle_2_Wingset_1, particle_4_Wingset_1, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);
	int Laser_3_Wingset_1 = ConnectWithBeamClient(particle_4_Wingset_1, particle_3_Wingset_1, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);
	int Laser_4_Wingset_1 = ConnectWithBeamClient(particle_5_Wingset_1, particle_3_Wingset_1, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);

	
	i_SilvesterCosmeticEffect[entity][0] = EntIndexToEntRef(particle_1_Wingset_1);
	i_SilvesterCosmeticEffect[entity][1] = EntIndexToEntRef(particle_2_Wingset_1);
	i_SilvesterCosmeticEffect[entity][2] = EntIndexToEntRef(particle_3_Wingset_1);
	i_SilvesterCosmeticEffect[entity][3] = EntIndexToEntRef(particle_4_Wingset_1);
	i_SilvesterCosmeticEffect[entity][4] = EntIndexToEntRef(particle_5_Wingset_1);
	i_SilvesterCosmeticEffect[entity][5] = EntIndexToEntRef(Laser_1_Wingset_1);
	i_SilvesterCosmeticEffect[entity][6] = EntIndexToEntRef(Laser_2_Wingset_1);
	i_SilvesterCosmeticEffect[entity][7] = EntIndexToEntRef(Laser_3_Wingset_1);
	i_SilvesterCosmeticEffect[entity][8] = EntIndexToEntRef(Laser_4_Wingset_1);
												
	int particle_1_Wingset_2 = ParticleEffectAt({26.0,-30.0,-11.0}, "", 0.0); //This is the root bone basically

	int particle_2_Wingset_2 = ParticleEffectAt({12.1,-12.1,-9.1}, "", 0.0); 
	int particle_3_Wingset_2 = ParticleEffectAt({-12.1,12.1,-9.1}, "", 0.0); 
	int particle_4_Wingset_2 = ParticleEffectAt({-6.1,-9.1,-9.1}, "", 0.0); 
	int particle_5_Wingset_2 = ParticleEffectAt({9.1,6.1,-9.1}, "", 0.0);

	SetParent(particle_1_Wingset_2, particle_2_Wingset_2, "",_, true);
	SetParent(particle_1_Wingset_2, particle_3_Wingset_2, "",_, true);
	SetParent(particle_1_Wingset_2, particle_4_Wingset_2, "",_, true);
	SetParent(particle_1_Wingset_2, particle_5_Wingset_2, "",_, true);

	
	Custom_SDKCall_SetLocalOrigin(particle_1_Wingset_2, flPos);
	SetEntPropVector(particle_1_Wingset_2, Prop_Data, "m_angRotation", flAng);
	SetParent(ParticleOffsetMain, particle_1_Wingset_2, "",_);
	
	int Laser_1_Wingset_2 = ConnectWithBeamClient(particle_2_Wingset_2, particle_5_Wingset_2, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);
	int Laser_2_Wingset_2 = ConnectWithBeamClient(particle_2_Wingset_2, particle_4_Wingset_2, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);
	int Laser_3_Wingset_2 = ConnectWithBeamClient(particle_4_Wingset_2, particle_3_Wingset_2, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);
	int Laser_4_Wingset_2 = ConnectWithBeamClient(particle_5_Wingset_2, particle_3_Wingset_2, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);

	
	i_SilvesterCosmeticEffect[entity][9] = EntIndexToEntRef(particle_1_Wingset_2);
	i_SilvesterCosmeticEffect[entity][10] = EntIndexToEntRef(particle_2_Wingset_2);
	i_SilvesterCosmeticEffect[entity][11] = EntIndexToEntRef(particle_3_Wingset_2);
	i_SilvesterCosmeticEffect[entity][12] = EntIndexToEntRef(particle_4_Wingset_2);
	i_SilvesterCosmeticEffect[entity][13] = EntIndexToEntRef(particle_5_Wingset_2);
	i_SilvesterCosmeticEffect[entity][14] = EntIndexToEntRef(Laser_1_Wingset_2);
	i_SilvesterCosmeticEffect[entity][15] = EntIndexToEntRef(Laser_2_Wingset_2);
	i_SilvesterCosmeticEffect[entity][16] = EntIndexToEntRef(Laser_3_Wingset_2);
	i_SilvesterCosmeticEffect[entity][17] = EntIndexToEntRef(Laser_4_Wingset_2);



	
	int particle_1_Wingset_3 = ParticleEffectAt({-26.0,-30.0,-11.0}, "", 0.0); //This is the root bone basically

	int particle_2_Wingset_3 = ParticleEffectAt({-12.1,-12.1,-9.1}, "", 0.0); 
	int particle_3_Wingset_3 = ParticleEffectAt({12.1,12.1,-9.1}, "", 0.0); 
	int particle_4_Wingset_3 = ParticleEffectAt({-9.1,6.1,-9.1}, "", 0.0); 
	int particle_5_Wingset_3 = ParticleEffectAt({6.1,-9.1,-9.1}, "", 0.0);

	SetParent(particle_1_Wingset_3, particle_2_Wingset_3, "",_, true);
	SetParent(particle_1_Wingset_3, particle_3_Wingset_3, "",_, true);
	SetParent(particle_1_Wingset_3, particle_4_Wingset_3, "",_, true);
	SetParent(particle_1_Wingset_3, particle_5_Wingset_3, "",_, true);

	
	Custom_SDKCall_SetLocalOrigin(particle_1_Wingset_3, flPos);
	SetEntPropVector(particle_1_Wingset_3, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_1_Wingset_3, "",_);
	
	int Laser_1_Wingset_3 = ConnectWithBeamClient(particle_2_Wingset_3, particle_5_Wingset_3, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);
	int Laser_2_Wingset_3 = ConnectWithBeamClient(particle_2_Wingset_3, particle_4_Wingset_3, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);
	int Laser_3_Wingset_3 = ConnectWithBeamClient(particle_4_Wingset_3, particle_3_Wingset_3, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);
	int Laser_4_Wingset_3 = ConnectWithBeamClient(particle_5_Wingset_3, particle_3_Wingset_3, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);

	
	i_SilvesterCosmeticEffect[entity][18] = EntIndexToEntRef(particle_1_Wingset_3);
	i_SilvesterCosmeticEffect[entity][19] = EntIndexToEntRef(particle_2_Wingset_3);
	i_SilvesterCosmeticEffect[entity][20] = EntIndexToEntRef(particle_3_Wingset_3);
	i_SilvesterCosmeticEffect[entity][21] = EntIndexToEntRef(particle_4_Wingset_3);
	i_SilvesterCosmeticEffect[entity][22] = EntIndexToEntRef(particle_5_Wingset_3);
	i_SilvesterCosmeticEffect[entity][23] = EntIndexToEntRef(Laser_1_Wingset_3);
	i_SilvesterCosmeticEffect[entity][24] = EntIndexToEntRef(Laser_2_Wingset_3);
	i_SilvesterCosmeticEffect[entity][25] = EntIndexToEntRef(Laser_3_Wingset_3);
	i_SilvesterCosmeticEffect[entity][26] = EntIndexToEntRef(Laser_4_Wingset_3);

	
	int particle_1_Wingset_4 = ParticleEffectAt({-26.0,30.0,-11.0}, "", 0.0); //This is the root bone basically

	int particle_2_Wingset_4 = ParticleEffectAt({-12.1,12.1,-9.1}, "", 0.0); 
	int particle_3_Wingset_4 = ParticleEffectAt({12.1,-12.1,-9.1}, "", 0.0); 
	int particle_4_Wingset_4 = ParticleEffectAt({6.1,9.1,-9.1}, "", 0.0); 
	int particle_5_Wingset_4 = ParticleEffectAt({-9.1,-6.1,-9.1}, "", 0.0);

	SetParent(particle_1_Wingset_4, particle_2_Wingset_4, "",_, true);
	SetParent(particle_1_Wingset_4, particle_3_Wingset_4, "",_, true);
	SetParent(particle_1_Wingset_4, particle_4_Wingset_4, "",_, true);
	SetParent(particle_1_Wingset_4, particle_5_Wingset_4, "",_, true);

	
	Custom_SDKCall_SetLocalOrigin(particle_1_Wingset_4, flPos);
	SetEntPropVector(particle_1_Wingset_4, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_1_Wingset_4, "",_);
	
	int Laser_1_Wingset_4 = ConnectWithBeamClient(particle_2_Wingset_4, particle_5_Wingset_4, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);
	int Laser_2_Wingset_4 = ConnectWithBeamClient(particle_2_Wingset_4, particle_4_Wingset_4, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);
	int Laser_3_Wingset_4 = ConnectWithBeamClient(particle_4_Wingset_4, particle_3_Wingset_4, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);
	int Laser_4_Wingset_4 = ConnectWithBeamClient(particle_5_Wingset_4, particle_3_Wingset_4, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);

	
	i_SilvesterCosmeticEffect[entity][27] = EntIndexToEntRef(particle_1_Wingset_4);
	i_SilvesterCosmeticEffect[entity][28] = EntIndexToEntRef(particle_2_Wingset_4);
	i_SilvesterCosmeticEffect[entity][29] = EntIndexToEntRef(particle_3_Wingset_4);
	i_SilvesterCosmeticEffect[entity][30] = EntIndexToEntRef(particle_4_Wingset_4);
	i_SilvesterCosmeticEffect[entity][31] = EntIndexToEntRef(particle_5_Wingset_4);
	i_SilvesterCosmeticEffect[entity][32] = EntIndexToEntRef(Laser_1_Wingset_4);
	i_SilvesterCosmeticEffect[entity][33] = EntIndexToEntRef(Laser_2_Wingset_4);
	i_SilvesterCosmeticEffect[entity][34] = EntIndexToEntRef(Laser_3_Wingset_4);
	i_SilvesterCosmeticEffect[entity][35] = EntIndexToEntRef(Laser_4_Wingset_4);


	
	int particle_1_Wingset_5 = ParticleEffectAt({-37.0,0.0,-11.0}, "", 0.0); //This is the root bone basically

	int particle_2_Wingset_5 = ParticleEffectAt({-15.1,0.0,-9.1}, "", 0.0); 
	int particle_3_Wingset_5 = ParticleEffectAt({15.1,0.0,-9.1}, "", 0.0); 
	int particle_4_Wingset_5 = ParticleEffectAt({-3.0,10.5,-9.1}, "", 0.0); 
	int particle_5_Wingset_5 = ParticleEffectAt({-3.0,-10.5,-9.1}, "", 0.0);

	SetParent(particle_1_Wingset_5, particle_2_Wingset_5, "",_, true);
	SetParent(particle_1_Wingset_5, particle_3_Wingset_5, "",_, true);
	SetParent(particle_1_Wingset_5, particle_4_Wingset_5, "",_, true);
	SetParent(particle_1_Wingset_5, particle_5_Wingset_5, "",_, true);

	
	Custom_SDKCall_SetLocalOrigin(particle_1_Wingset_5, flPos);
	SetEntPropVector(particle_1_Wingset_5, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_1_Wingset_5, "",_);
	
	int Laser_1_Wingset_5 = ConnectWithBeamClient(particle_2_Wingset_5, particle_5_Wingset_5, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);
	int Laser_2_Wingset_5 = ConnectWithBeamClient(particle_2_Wingset_5, particle_4_Wingset_5, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);
	int Laser_3_Wingset_5 = ConnectWithBeamClient(particle_4_Wingset_5, particle_3_Wingset_5, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);
	int Laser_4_Wingset_5 = ConnectWithBeamClient(particle_5_Wingset_5, particle_3_Wingset_5, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);

	
	i_SilvesterCosmeticEffect[entity][36] = EntIndexToEntRef(particle_1_Wingset_5);
	i_SilvesterCosmeticEffect[entity][37] = EntIndexToEntRef(particle_2_Wingset_5);
	i_SilvesterCosmeticEffect[entity][38] = EntIndexToEntRef(particle_3_Wingset_5);
	i_SilvesterCosmeticEffect[entity][39] = EntIndexToEntRef(particle_4_Wingset_5);
	i_SilvesterCosmeticEffect[entity][40] = EntIndexToEntRef(particle_5_Wingset_5);
	i_SilvesterCosmeticEffect[entity][41] = EntIndexToEntRef(Laser_1_Wingset_5);
	i_SilvesterCosmeticEffect[entity][42] = EntIndexToEntRef(Laser_2_Wingset_5);
	i_SilvesterCosmeticEffect[entity][43] = EntIndexToEntRef(Laser_3_Wingset_5);
	i_SilvesterCosmeticEffect[entity][44] = EntIndexToEntRef(Laser_4_Wingset_5);

	
	int particle_1_Wingset_6 = ParticleEffectAt({37.0,0.0,-11.0}, "", 0.0); //This is the root bone basically

	int particle_2_Wingset_6 = ParticleEffectAt({-15.1,0.0,-9.1}, "", 0.0); 
	int particle_3_Wingset_6 = ParticleEffectAt({15.1,0.0,-9.1}, "", 0.0); 
	int particle_4_Wingset_6 = ParticleEffectAt({3.0,10.5,-9.1}, "", 0.0); 
	int particle_5_Wingset_6 = ParticleEffectAt({3.0,-10.5,-9.1}, "", 0.0);

	SetParent(particle_1_Wingset_6, particle_2_Wingset_6, "",_, true);
	SetParent(particle_1_Wingset_6, particle_3_Wingset_6, "",_, true);
	SetParent(particle_1_Wingset_6, particle_4_Wingset_6, "",_, true);
	SetParent(particle_1_Wingset_6, particle_5_Wingset_6, "",_, true);

	
	Custom_SDKCall_SetLocalOrigin(particle_1_Wingset_6, flPos);
	SetEntPropVector(particle_1_Wingset_6, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_1_Wingset_6, "",_);
	
	int Laser_1_Wingset_6 = ConnectWithBeamClient(particle_2_Wingset_6, particle_5_Wingset_6, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);
	int Laser_2_Wingset_6 = ConnectWithBeamClient(particle_2_Wingset_6, particle_4_Wingset_6, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);
	int Laser_3_Wingset_6 = ConnectWithBeamClient(particle_4_Wingset_6, particle_3_Wingset_6, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);
	int Laser_4_Wingset_6 = ConnectWithBeamClient(particle_5_Wingset_6, particle_3_Wingset_6, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM, entity);

	
	i_SilvesterCosmeticEffect[entity][45] = EntIndexToEntRef(particle_1_Wingset_6);
	i_SilvesterCosmeticEffect[entity][46] = EntIndexToEntRef(particle_2_Wingset_6);
	i_SilvesterCosmeticEffect[entity][47] = EntIndexToEntRef(particle_3_Wingset_6);
	i_SilvesterCosmeticEffect[entity][48] = EntIndexToEntRef(particle_4_Wingset_6);
	i_SilvesterCosmeticEffect[entity][49] = EntIndexToEntRef(particle_5_Wingset_6);
	i_SilvesterCosmeticEffect[entity][50] = EntIndexToEntRef(Laser_1_Wingset_6);
	i_SilvesterCosmeticEffect[entity][51] = EntIndexToEntRef(Laser_2_Wingset_6);
	i_SilvesterCosmeticEffect[entity][52] = EntIndexToEntRef(Laser_3_Wingset_6);
	i_SilvesterCosmeticEffect[entity][53] = EntIndexToEntRef(Laser_4_Wingset_6);
	i_SilvesterCosmeticEffect[entity][54] = EntIndexToEntRef(ParticleOffsetMain);

}
