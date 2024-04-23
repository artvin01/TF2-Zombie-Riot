static Handle Timer_Expidonsan_Transform[MAXPLAYERS+1] = {null, ...};
static int i_TransformInitLevel[MAXPLAYERS+1];
static int iref_Halo[MAXPLAYERS+1][2];

void Transform_Iberian_MapStart()
{
	PrecacheSound("player/taunt_yeti_appear_snow.wav");
	PrecacheSound("replay/enterperformancemode.wav");
}

public void Iberian_Activation_Enable_form_1(int client)
{
	Iberian_Activation_Enable_Global(client, 1);
}

public void Iberian_Activation_Enable_form_2(int client)
{
	Iberian_Activation_Enable_Global(client, 2);
}

public void Iberian_Activation_Enable_Global(int client, int level)
{
	switch(level)
	{
		case 1:
		{
			EmitSoundToAll("player/taunt_yeti_appear_snow.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
		}
		case 2:
		{
			EmitSoundToAll("replay/enterperformancemode.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
		}
	}
	delete Timer_Expidonsan_Transform[client];
	DataPack pack;
	Timer_Expidonsan_Transform[client] = CreateDataTimer(0.5, TimerIberian_Transform, pack, TIMER_REPEAT);
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
			int particle_halo = ParticleEffectAt(flPos, "unusual_sixthsense_teamcolor_blue", 0.0);
			iref_Halo[client][0] = EntIndexToEntRef(particle_halo);
			AddEntityToThirdPersonTransitMode(client, particle_halo);
			SetParent(viewmodelModel, particle_halo, "head", {0.0,0.0,-5.0});
		}
		if(level == 2)
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
			flPos[2] += 70.0;
			int particler = ParticleEffectAt(flPos, "scout_dodge_blue", 0.0);
			SetParent(client, particler);
			iref_Halo[client][1] = EntIndexToEntRef(particler);
			AddEntityToThirdPersonTransitMode(client, particler);
		}
	}
}


public Action TimerIberian_Transform(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(!IsValidClient(client) || !IsClientInGame(client) || i_TransformationLevel[client] != i_TransformInitLevel[client])
	{
		//To remove the particle without it lasting, unparent, then teleport off the map.
		if(IsValidEntity(iref_Halo[client][0]))
		{
			CreateTimer(0.1, Timer_RemoveEntityParticle, iref_Halo[client][0], TIMER_FLAG_NO_MAPCHANGE);
			iref_Halo[client][0] = -1;
		}
		if(IsValidEntity(iref_Halo[client][1]))
		{
			CreateTimer(0.1, Timer_RemoveEntityParticle, iref_Halo[client][1], TIMER_FLAG_NO_MAPCHANGE);
			iref_Halo[client][1] = -1;
		}

		i_TransformInitLevel[client] = -1;
		Timer_Expidonsan_Transform[client] = null;
		return Plugin_Stop;
	}	
	return Plugin_Continue;
}


