#define MAX_MAGIA_COSMETIC_EFFECTS 55
static int i_MagiaCosmeticEffect[MAXENTITIES][MAX_MAGIA_COSMETIC_EFFECTS];

static Handle h_MagiaCosmeticEffectManagement[MAXPLAYERS+1] = {null, ...};

void MagiaCosmeticRemoveEffects(int iNpc)
{
	for(int loop = 0; loop<MAX_MAGIA_COSMETIC_EFFECTS; loop++)
	{
		int entity = EntRefToEntIndex(i_MagiaCosmeticEffect[iNpc][loop]);
		if(IsValidEntity(entity))
		{
			RemoveEntity(entity);
		}
		i_MagiaCosmeticEffect[iNpc][loop] = INVALID_ENT_REFERENCE;
	}
}


bool MagiaCosmeticEffects_IfNotAvaiable(int iNpc)
{
	for(int loop = 0; loop<MAX_MAGIA_COSMETIC_EFFECTS; loop++)
	{
		int entity = EntRefToEntIndex(i_MagiaCosmeticEffect[iNpc][loop]);
		if(!IsValidEntity(entity))
		{
			return true;
		}
	}
	return false;
}

void ApplyExtraMagiaCosmeticEffects(int client, bool remove = false)
{
	if(remove)
	{
		MagiaCosmeticRemoveEffects(client);
		return;
	}
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);

	if(!IsValidEntity(viewmodelModel))
	{
		MagiaCosmeticRemoveEffects(client);
		return;
	}

	if(MagiaCosmeticEffects_IfNotAvaiable(client))
	{
		MagiaCosmeticRemoveEffects(client);
		MagiaCosmeticEffects(client,viewmodelModel);
	}
}


public void Enable_Magia_Wings(int client) 
{
	bool HasWings = Items_HasNamedItem(client, "Magia Cosmetic Wings [???]");
	if (h_MagiaCosmeticEffectManagement[client] != null)
	{
		//This timer already exists.
		if(HasWings)
		{
			MagiaCosmeticRemoveEffects(client);
			ApplyExtraMagiaCosmeticEffects(client,_);
			//Is the weapon it again?
			//Yes?
			delete h_MagiaCosmeticEffectManagement[client];
			h_MagiaCosmeticEffectManagement[client] = null;
			DataPack pack;
			h_MagiaCosmeticEffectManagement[client] = CreateDataTimer(0.1, TimerMagiaCosmetic, pack, TIMER_REPEAT);
			pack.WriteCell(client);
		}
		return;
	}
	
	if(HasWings)
	{
		MagiaCosmeticRemoveEffects(client);
		ApplyExtraMagiaCosmeticEffects(client,_);
		DataPack pack;
		h_MagiaCosmeticEffectManagement[client] = CreateDataTimer(0.1, TimerMagiaCosmetic, pack, TIMER_REPEAT);
		pack.WriteCell(client);
	}
}


public Action TimerMagiaCosmetic(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		ApplyExtraMagiaCosmeticEffects(client,true);
		h_MagiaCosmeticEffectManagement[client] = null;
		return Plugin_Stop;
	}	

	ApplyExtraMagiaCosmeticEffects(client);
		
	return Plugin_Continue;
}

void MagiaCosmeticEffects(int entity, int wearable)
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
	
	int Laser_1_Wingset_1 = ConnectWithBeamClient(particle_2_Wingset_1, particle_5_Wingset_1, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_2_Wingset_1 = ConnectWithBeamClient(particle_2_Wingset_1, particle_4_Wingset_1, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_3_Wingset_1 = ConnectWithBeamClient(particle_4_Wingset_1, particle_3_Wingset_1, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_4_Wingset_1 = ConnectWithBeamClient(particle_5_Wingset_1, particle_3_Wingset_1, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);

	
	i_MagiaCosmeticEffect[entity][0] = EntIndexToEntRef(particle_1_Wingset_1);
	i_MagiaCosmeticEffect[entity][1] = EntIndexToEntRef(particle_2_Wingset_1);
	i_MagiaCosmeticEffect[entity][2] = EntIndexToEntRef(particle_3_Wingset_1);
	i_MagiaCosmeticEffect[entity][3] = EntIndexToEntRef(particle_4_Wingset_1);
	i_MagiaCosmeticEffect[entity][4] = EntIndexToEntRef(particle_5_Wingset_1);
	i_MagiaCosmeticEffect[entity][5] = EntIndexToEntRef(Laser_1_Wingset_1);
	i_MagiaCosmeticEffect[entity][6] = EntIndexToEntRef(Laser_2_Wingset_1);
	i_MagiaCosmeticEffect[entity][7] = EntIndexToEntRef(Laser_3_Wingset_1);
	i_MagiaCosmeticEffect[entity][8] = EntIndexToEntRef(Laser_4_Wingset_1);
												
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
	
	int Laser_1_Wingset_2 = ConnectWithBeamClient(particle_2_Wingset_2, particle_5_Wingset_2, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_2_Wingset_2 = ConnectWithBeamClient(particle_2_Wingset_2, particle_4_Wingset_2, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_3_Wingset_2 = ConnectWithBeamClient(particle_4_Wingset_2, particle_3_Wingset_2, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_4_Wingset_2 = ConnectWithBeamClient(particle_5_Wingset_2, particle_3_Wingset_2, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);

	
	i_MagiaCosmeticEffect[entity][9] = EntIndexToEntRef(particle_1_Wingset_2);
	i_MagiaCosmeticEffect[entity][10] = EntIndexToEntRef(particle_2_Wingset_2);
	i_MagiaCosmeticEffect[entity][11] = EntIndexToEntRef(particle_3_Wingset_2);
	i_MagiaCosmeticEffect[entity][12] = EntIndexToEntRef(particle_4_Wingset_2);
	i_MagiaCosmeticEffect[entity][13] = EntIndexToEntRef(particle_5_Wingset_2);
	i_MagiaCosmeticEffect[entity][14] = EntIndexToEntRef(Laser_1_Wingset_2);
	i_MagiaCosmeticEffect[entity][15] = EntIndexToEntRef(Laser_2_Wingset_2);
	i_MagiaCosmeticEffect[entity][16] = EntIndexToEntRef(Laser_3_Wingset_2);
	i_MagiaCosmeticEffect[entity][17] = EntIndexToEntRef(Laser_4_Wingset_2);



	
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
	
	int Laser_1_Wingset_3 = ConnectWithBeamClient(particle_2_Wingset_3, particle_5_Wingset_3, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_2_Wingset_3 = ConnectWithBeamClient(particle_2_Wingset_3, particle_4_Wingset_3, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_3_Wingset_3 = ConnectWithBeamClient(particle_4_Wingset_3, particle_3_Wingset_3, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_4_Wingset_3 = ConnectWithBeamClient(particle_5_Wingset_3, particle_3_Wingset_3, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);

	
	i_MagiaCosmeticEffect[entity][18] = EntIndexToEntRef(particle_1_Wingset_3);
	i_MagiaCosmeticEffect[entity][19] = EntIndexToEntRef(particle_2_Wingset_3);
	i_MagiaCosmeticEffect[entity][20] = EntIndexToEntRef(particle_3_Wingset_3);
	i_MagiaCosmeticEffect[entity][21] = EntIndexToEntRef(particle_4_Wingset_3);
	i_MagiaCosmeticEffect[entity][22] = EntIndexToEntRef(particle_5_Wingset_3);
	i_MagiaCosmeticEffect[entity][23] = EntIndexToEntRef(Laser_1_Wingset_3);
	i_MagiaCosmeticEffect[entity][24] = EntIndexToEntRef(Laser_2_Wingset_3);
	i_MagiaCosmeticEffect[entity][25] = EntIndexToEntRef(Laser_3_Wingset_3);
	i_MagiaCosmeticEffect[entity][26] = EntIndexToEntRef(Laser_4_Wingset_3);

	
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
	
	int Laser_1_Wingset_4 = ConnectWithBeamClient(particle_2_Wingset_4, particle_5_Wingset_4, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_2_Wingset_4 = ConnectWithBeamClient(particle_2_Wingset_4, particle_4_Wingset_4, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_3_Wingset_4 = ConnectWithBeamClient(particle_4_Wingset_4, particle_3_Wingset_4, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_4_Wingset_4 = ConnectWithBeamClient(particle_5_Wingset_4, particle_3_Wingset_4, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);

	
	i_MagiaCosmeticEffect[entity][27] = EntIndexToEntRef(particle_1_Wingset_4);
	i_MagiaCosmeticEffect[entity][28] = EntIndexToEntRef(particle_2_Wingset_4);
	i_MagiaCosmeticEffect[entity][29] = EntIndexToEntRef(particle_3_Wingset_4);
	i_MagiaCosmeticEffect[entity][30] = EntIndexToEntRef(particle_4_Wingset_4);
	i_MagiaCosmeticEffect[entity][31] = EntIndexToEntRef(particle_5_Wingset_4);
	i_MagiaCosmeticEffect[entity][32] = EntIndexToEntRef(Laser_1_Wingset_4);
	i_MagiaCosmeticEffect[entity][33] = EntIndexToEntRef(Laser_2_Wingset_4);
	i_MagiaCosmeticEffect[entity][34] = EntIndexToEntRef(Laser_3_Wingset_4);
	i_MagiaCosmeticEffect[entity][35] = EntIndexToEntRef(Laser_4_Wingset_4);


	
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
	
	int Laser_1_Wingset_5 = ConnectWithBeamClient(particle_2_Wingset_5, particle_5_Wingset_5, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_2_Wingset_5 = ConnectWithBeamClient(particle_2_Wingset_5, particle_4_Wingset_5, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_3_Wingset_5 = ConnectWithBeamClient(particle_4_Wingset_5, particle_3_Wingset_5, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_4_Wingset_5 = ConnectWithBeamClient(particle_5_Wingset_5, particle_3_Wingset_5, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);

	
	i_MagiaCosmeticEffect[entity][36] = EntIndexToEntRef(particle_1_Wingset_5);
	i_MagiaCosmeticEffect[entity][37] = EntIndexToEntRef(particle_2_Wingset_5);
	i_MagiaCosmeticEffect[entity][38] = EntIndexToEntRef(particle_3_Wingset_5);
	i_MagiaCosmeticEffect[entity][39] = EntIndexToEntRef(particle_4_Wingset_5);
	i_MagiaCosmeticEffect[entity][40] = EntIndexToEntRef(particle_5_Wingset_5);
	i_MagiaCosmeticEffect[entity][41] = EntIndexToEntRef(Laser_1_Wingset_5);
	i_MagiaCosmeticEffect[entity][42] = EntIndexToEntRef(Laser_2_Wingset_5);
	i_MagiaCosmeticEffect[entity][43] = EntIndexToEntRef(Laser_3_Wingset_5);
	i_MagiaCosmeticEffect[entity][44] = EntIndexToEntRef(Laser_4_Wingset_5);

	
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
	
	int Laser_1_Wingset_6 = ConnectWithBeamClient(particle_2_Wingset_6, particle_5_Wingset_6, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_2_Wingset_6 = ConnectWithBeamClient(particle_2_Wingset_6, particle_4_Wingset_6, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_3_Wingset_6 = ConnectWithBeamClient(particle_4_Wingset_6, particle_3_Wingset_6, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_4_Wingset_6 = ConnectWithBeamClient(particle_5_Wingset_6, particle_3_Wingset_6, red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);

	
	i_MagiaCosmeticEffect[entity][45] = EntIndexToEntRef(particle_1_Wingset_6);
	i_MagiaCosmeticEffect[entity][46] = EntIndexToEntRef(particle_2_Wingset_6);
	i_MagiaCosmeticEffect[entity][47] = EntIndexToEntRef(particle_3_Wingset_6);
	i_MagiaCosmeticEffect[entity][48] = EntIndexToEntRef(particle_4_Wingset_6);
	i_MagiaCosmeticEffect[entity][49] = EntIndexToEntRef(particle_5_Wingset_6);
	i_MagiaCosmeticEffect[entity][50] = EntIndexToEntRef(Laser_1_Wingset_6);
	i_MagiaCosmeticEffect[entity][51] = EntIndexToEntRef(Laser_2_Wingset_6);
	i_MagiaCosmeticEffect[entity][52] = EntIndexToEntRef(Laser_3_Wingset_6);
	i_MagiaCosmeticEffect[entity][53] = EntIndexToEntRef(Laser_4_Wingset_6);
	i_MagiaCosmeticEffect[entity][54] = EntIndexToEntRef(ParticleOffsetMain);

}
