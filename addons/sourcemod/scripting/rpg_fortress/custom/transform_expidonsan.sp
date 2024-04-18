Handle Timer_Expidonsan_Transform[MAXPLAYERS+1] = {null, ...};
int i_TransformInitLevel[MAXPLAYERS+1];
int iref_Halo[MAXPLAYERS+1];

void Transform_Expidonsa_MapStart()
{
	PrecacheSound("player/taunt_wormshhg.wav");
}

public void Halo_Activation_Enable_form_1(int client)
{
	Halo_Activation_Enable_Global(client, 1);

}

public void Halo_Activation_Enable_Global(int client, int level)
{
	EmitSoundToAll("player/taunt_wormshhg.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
	delete Timer_Expidonsan_Transform[client];
	DataPack pack;
	Timer_Expidonsan_Transform[client] = CreateDataTimer(0.5, TimerExpidonsan_Transform, pack, TIMER_REPEAT);
	pack.WriteCell(client);
	i_TransformInitLevel[client] = i_TransformationLevel[client];
	
	if(IsValidEntity(iref_Halo[client]))
		RemoveEntity(iref_Halo[client]);

	float flPos[3];
	float flAng[3];
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(IsValidEntity(viewmodelModel))
	{
		GetAttachment(viewmodelModel, "head", flPos, flAng);
		flPos[2] += 10.0;
		int particle_halo = ParticleEffectAt(flPos, "unusual_symbols_parent_lightning", 0.0);
		iref_Halo[client] = EntIndexToEntRef(particle_halo);
		AddEntityToThirdPersonTransitMode(client, particle_halo);
		SetParent(viewmodelModel, particle_halo, "head");
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
		flPos[2] += 20.0;
		ParticleEffectAt(flPos, "bombinomicon_flash", 1.0);
	}
}


public Action TimerExpidonsan_Transform(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(!IsValidClient(client) || !IsClientInGame(client) || i_TransformationLevel[client] != i_TransformInitLevel[client])
	{
		if(IsValidEntity(iref_Halo[client]))
			RemoveEntity(iref_Halo[client]);

		i_TransformInitLevel[client] = -1;
		Timer_Expidonsan_Transform[client] = null;
		return Plugin_Stop;
	}	
	return Plugin_Continue;
}