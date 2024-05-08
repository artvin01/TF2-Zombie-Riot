static Handle Timer_Expidonsan_Transform[MAXPLAYERS+1] = {null, ...};
static int i_TransformInitLevel[MAXPLAYERS+1];
static int iref_Halo[MAXPLAYERS+1][2];

void Transform_Expidonsa_MapStart()
{
	PrecacheSound("player/taunt_wormshhg.wav");
	PrecacheSound("ambient/levels/labs/electric_explosion4.wav");
}

public void Halo_Activation_Enable_form_1(int client)
{
	Halo_Activation_Enable_Global(client, 1);
}

public void Halo_Activation_Enable_form_2(int client)
{
	Halo_Activation_Enable_Global(client, 2);
}

public void Halo_Activation_Enable_Global(int client, int level)
{
	switch(level)
	{
		case 1:
		{
			EmitSoundToAll("player/taunt_wormshhg.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
		}
		case 2:
		{
			EmitSoundToAll("ambient/levels/labs/electric_explosion4.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
		}
	}
	delete Timer_Expidonsan_Transform[client];
	DataPack pack;
	Timer_Expidonsan_Transform[client] = CreateDataTimer(0.5, TimerExpidonsan_Transform, pack, TIMER_REPEAT);
	pack.WriteCell(client);
	i_TransformInitLevel[client] = i_TransformationLevel[client];
	
	if(IsValidEntity(iref_Halo[client][0]))
	{
		CreateTimer(0.1, Timer_RemoveEntityParticle, iref_Halo[client][0], TIMER_FLAG_NO_MAPCHANGE);
	}

	if(IsValidEntity(iref_Halo[client][1]))
	{
		CreateTimer(0.1, Timer_RemoveEntityParticle, iref_Halo[client][1], TIMER_FLAG_NO_MAPCHANGE);
	}

	float flPos[3];
	float flAng[3];
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(IsValidEntity(viewmodelModel))
	{
		if(level == 1 || level == 2)
		{
			GetAttachment(viewmodelModel, "head", flPos, flAng);
			int particle_halo = ParticleEffectAt(flPos, "unusual_symbols_parent_lightning", 0.0);
			iref_Halo[client][0] = EntIndexToEntRef(particle_halo);
			AddEntityToThirdPersonTransitMode(client, particle_halo);
			SetParent(viewmodelModel, particle_halo, "head", {0.0,0.0,-3.0});
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
			flPos[2] += 20.0;
			ParticleEffectAt(flPos, "bombinomicon_flash", 1.0);
		}
		if(level == 2)
		{

			GetAttachment(viewmodelModel, "head", flPos, flAng);
			int particle_halo = ParticleEffectAt(flPos, "unusual_sparkletree_gold_starglow", 0.0);
			iref_Halo[client][1] = EntIndexToEntRef(particle_halo);
			AddEntityToThirdPersonTransitMode(client, particle_halo);
			SetParent(viewmodelModel, particle_halo, "head", {0.0,0.0,-3.0});
		}
	}
}


public Action TimerExpidonsan_Transform(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(!IsValidClient(client) || !IsClientInGame(client) || i_TransformationLevel[client] != i_TransformInitLevel[client])
	{
		//To remove the particle without it lasting, unparent, then teleport off the map.
		if(IsValidEntity(iref_Halo[client][0]))
		{
			AcceptEntityInput(iref_Halo[client][0], "ClearParent");
			TeleportEntity(iref_Halo[client][0], {16000.0,16000.0,16000.0});
			CreateTimer(0.1, Timer_RemoveEntity, iref_Halo[client][0], TIMER_FLAG_NO_MAPCHANGE);
			iref_Halo[client][0] = -1;
		}
		if(IsValidEntity(iref_Halo[client][1]))
		{
			AcceptEntityInput(iref_Halo[client][1], "ClearParent");
			TeleportEntity(iref_Halo[client][1], {16000.0,16000.0,16000.0});
			CreateTimer(0.1, Timer_RemoveEntity, iref_Halo[client][1], TIMER_FLAG_NO_MAPCHANGE);
			iref_Halo[client][1] = -1;
		}

		i_TransformInitLevel[client] = -1;
		Timer_Expidonsan_Transform[client] = null;
		return Plugin_Stop;
	}	
	return Plugin_Continue;
}