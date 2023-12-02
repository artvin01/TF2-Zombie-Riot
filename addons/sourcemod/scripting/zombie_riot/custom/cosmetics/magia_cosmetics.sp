
#define MAX_MAGIA_COSMETIC_ENERGY_EFFECTS 22
static int i_MagiaCosmeticEffect[MAXENTITIES][MAX_MAGIA_COSMETIC_ENERGY_EFFECTS];
static Handle h_MagiaCosmeticEffectManagement[MAXPLAYERS+1] = {null, ...};

void MagiaCosmeticRemoveEffects(int iNpc)
{
	for(int loop = 0; loop<MAX_MAGIA_COSMETIC_ENERGY_EFFECTS; loop++)
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
	for(int loop = 0; loop<MAX_MAGIA_COSMETIC_ENERGY_EFFECTS; loop++)
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
public void EnableMagiaCosmetic(int client) 
{
	if(TeutonType[client] != TEUTON_NONE)
		return;
		
	bool HasWings = view_as<bool>(Store_HasNamedItem(client, "Magia Cosmetic Wings [???]"));
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
	if(TeutonType[client] != TEUTON_NONE)
	{
		ApplyExtraMagiaCosmeticEffects(client,true);
		h_MagiaCosmeticEffectManagement[client] = null;
		return Plugin_Stop;
	}
	bool HasWings = view_as<bool>(Store_HasNamedItem(client, "Magia Cosmetic Wings [???]"));
	if(!HasWings)
	{
		ApplyExtraMagiaCosmeticEffects(client,true);
		h_MagiaCosmeticEffectManagement[client] = null;
		return Plugin_Stop;
	}
	ApplyExtraMagiaCosmeticEffects(client);
		
	return Plugin_Continue;
}
void MagiaCosmeticEffects(int entity, int wearable)	//Magia Cosmetic Wings [???]
{
	int red = 185;
	int green = 205;
	int blue = 237;
	float flPos[3];
	float flAng[3];
	
	//possible loop function?
	/*
		1st: left and right, negative is right, positive is left 
		2nd: Up and down, negative up, positive down.
		3rd: front and back, negative goes back.
	*/

	int ParticleOffsetMain = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	GetAttachment(wearable, "flag", flPos, flAng);
	Custom_SDKCall_SetLocalOrigin(ParticleOffsetMain, flPos);
	SetEntPropVector(ParticleOffsetMain, Prop_Data, "m_angRotation", flAng); 
	SetParent(wearable, ParticleOffsetMain, "flag",_);


	/*
		1st: left and right, negative is right, positive is left 
		2nd: Up and down, negative up, positive down.
		3rd: front and back, negative goes back.
	*/


	//Left

	int particle_left_core = InfoTargetParentAt({0.0, 6.5, -7.5}, "", 0.0);


	/*
		X = +Left, -Right
		Y = -Up, +Down
		Z = +Backwards, -Forward
	*/

	int particle_left_wing_1 = InfoTargetParentAt({7.5, -7.5, -2.5}, "", 0.0);		//head
	int particle_left_wing_2 = InfoTargetParentAt({25.0, 40.0, 20.0}, "", 0.0);		//bottom
	int particle_left_wing_3 = InfoTargetParentAt({19.5, -15.5, 15.0}, "", 0.0);		//top
	int particle_left_wing_4 = InfoTargetParentAt({45.0, 0.0, 10.0}, "", 0.0);		//side

	SetParent(particle_left_core, particle_left_wing_1, "",_, true);
	SetParent(particle_left_core, particle_left_wing_2, "",_, true);
	SetParent(particle_left_core, particle_left_wing_3, "",_, true);
	SetParent(particle_left_core, particle_left_wing_4, "",_, true);
	//SetParent(particle_left_core, particle_2_Wingset_1, "",_, true);



	Custom_SDKCall_SetLocalOrigin(particle_left_core, flPos);
	SetEntPropVector(particle_left_core, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_left_core, "",_);

	float start_1 = 2.0;
	float end_1 = 0.5;
	float amp =0.1;

	int laser_left_wing_1 = ConnectWithBeamClient(particle_left_wing_1, particle_left_wing_2, red, green, blue, start_1, end_1, amp, LASERBEAM, entity);
	int laser_left_wing_2 = ConnectWithBeamClient(particle_left_wing_1, particle_left_wing_3, red, green, blue, start_1, end_1, amp, LASERBEAM, entity);
	int laser_left_wing_3 = ConnectWithBeamClient(particle_left_wing_1, particle_left_wing_4, red, green, blue, start_1, end_1, amp, LASERBEAM, entity);
	int laser_left_wing_4 = ConnectWithBeamClient(particle_left_wing_2, particle_left_wing_4, red, green, blue, end_1, end_1, amp, LASERBEAM, entity);
	int laser_left_wing_5 = ConnectWithBeamClient(particle_left_wing_3, particle_left_wing_4, red, green, blue, end_1, end_1, amp, LASERBEAM, entity);

	i_MagiaCosmeticEffect[entity][1] = EntIndexToEntRef(particle_left_core);
	i_MagiaCosmeticEffect[entity][2] = EntIndexToEntRef(particle_left_wing_1);
	i_MagiaCosmeticEffect[entity][3] = EntIndexToEntRef(particle_left_wing_3);
	i_MagiaCosmeticEffect[entity][4] = EntIndexToEntRef(particle_left_wing_4);

	i_MagiaCosmeticEffect[entity][5] = EntIndexToEntRef(laser_left_wing_1);
	i_MagiaCosmeticEffect[entity][6] = EntIndexToEntRef(laser_left_wing_2);
	i_MagiaCosmeticEffect[entity][7] = EntIndexToEntRef(laser_left_wing_2);
	i_MagiaCosmeticEffect[entity][8] = EntIndexToEntRef(laser_left_wing_3);
	i_MagiaCosmeticEffect[entity][9] = EntIndexToEntRef(laser_left_wing_4);
	i_MagiaCosmeticEffect[entity][10] = EntIndexToEntRef(laser_left_wing_5);

	//right

	int particle_right_core = InfoTargetParentAt({0.0, 6.5, -7.5}, "", 0.0);


	/*
		X = +Left, -Right
		Y = -Up, +Down
		Z = +Backwards, -Forward
	*/

	int particle_right_wing_1 = InfoTargetParentAt({-7.5, -7.5, -2.5}, "", 0.0);		//head
	int particle_right_wing_2 = InfoTargetParentAt({-25.0, 40.0, 20.0}, "", 0.0);		//bottom
	int particle_right_wing_3 = InfoTargetParentAt({-19.5, -15.5, 15.0}, "", 0.0);		//top
	int particle_right_wing_4 = InfoTargetParentAt({-45.0, 0.0, 10.0}, "", 0.0);		//side

	SetParent(particle_right_core, particle_right_wing_1, "",_, true);
	SetParent(particle_right_core, particle_right_wing_2, "",_, true);
	SetParent(particle_right_core, particle_right_wing_3, "",_, true);
	SetParent(particle_right_core, particle_right_wing_4, "",_, true);
	//SetParent(particle_left_core, particle_2_Wingset_1, "",_, true);



	Custom_SDKCall_SetLocalOrigin(particle_right_core, flPos);
	SetEntPropVector(particle_right_core, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_right_core, "",_);

	//float start_1 = 2.0;
	//float end_1 = 0.5;
	//float amp =0.1;

	int laser_right_wing_1 = ConnectWithBeamClient(particle_right_wing_1, particle_right_wing_2, red, green, blue, start_1, end_1, amp, LASERBEAM, entity);
	int laser_right_wing_2 = ConnectWithBeamClient(particle_right_wing_1, particle_right_wing_3, red, green, blue, start_1, end_1, amp, LASERBEAM, entity);
	int laser_right_wing_3 = ConnectWithBeamClient(particle_right_wing_1, particle_right_wing_4, red, green, blue, start_1, end_1, amp, LASERBEAM, entity);
	int laser_right_wing_4 = ConnectWithBeamClient(particle_right_wing_2, particle_right_wing_4, red, green, blue, end_1, end_1, amp, LASERBEAM, entity);
	int laser_right_wing_5 = ConnectWithBeamClient(particle_right_wing_3, particle_right_wing_4, red, green, blue, end_1, end_1, amp, LASERBEAM, entity);

	i_MagiaCosmeticEffect[entity][11] = EntIndexToEntRef(particle_right_core);
	i_MagiaCosmeticEffect[entity][12] = EntIndexToEntRef(particle_right_wing_1);
	i_MagiaCosmeticEffect[entity][13] = EntIndexToEntRef(particle_right_wing_2);
	i_MagiaCosmeticEffect[entity][14] = EntIndexToEntRef(particle_right_wing_3);
	i_MagiaCosmeticEffect[entity][15] = EntIndexToEntRef(particle_right_wing_4);

	i_MagiaCosmeticEffect[entity][16] = EntIndexToEntRef(laser_right_wing_1);
	i_MagiaCosmeticEffect[entity][17] = EntIndexToEntRef(laser_right_wing_2);
	i_MagiaCosmeticEffect[entity][19] = EntIndexToEntRef(laser_right_wing_3);
	i_MagiaCosmeticEffect[entity][20] = EntIndexToEntRef(laser_right_wing_4);
	i_MagiaCosmeticEffect[entity][21] = EntIndexToEntRef(laser_right_wing_5);

	i_MagiaCosmeticEffect[entity][0] = EntIndexToEntRef(ParticleOffsetMain);



}
