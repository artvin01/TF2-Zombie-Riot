static int ParticleRef[MAXTF2PLAYERS] = {-1, ...};

void Transform_Seaborn_MapStart()
{
	PrecacheSound("player/souls_receive2.wav");
	PrecacheSound("player/souls_receive3.wav");
	PrecacheSound("ambient/levels/labs/electric_explosion4.wav");
	PrecacheSound("weapons/sentry_explode.wav");
}

static void CleanEffects(int client)
{
	if(ParticleRef[client] != -1)
	{
		int entity = EntRefToEntIndex(ParticleRef[client]);
		if(entity != -1)
		{
			AcceptEntityInput(entity, "ClearParent");
			TeleportEntity(entity, {16000.0,16000.0,16000.0});
			CreateTimer(0.1, Timer_RemoveEntity, ParticleRef[client], TIMER_FLAG_NO_MAPCHANGE);
		}
		
		ParticleRef[client] = -1;
	}
}

public void Seaborn_Activation_Enable_form_1(int client)
{
	CleanEffects(client);

	EmitSoundToAll("player/souls_receive3.wav", client, SNDCHAN_AUTO, 80);
}

public void Seaborn_Activation_Disable_form_1(int client)
{
	CleanEffects(client);

	EmitSoundToAll("player/souls_receive2.wav", client, SNDCHAN_AUTO, 80);
}

public void Seaborn_Activation_Enable_form_2(int client)
{
	Seaborn_Activation_Enable_Global(client, 2);
}

public void Seaborn_Activation_Enable_form_3(int client)
{
	Seaborn_Activation_Enable_Global(client, 3);
}

public void Seaborn_Activation_Enable_Global(int client, int level)
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
		case 3:
		{
			EmitSoundToAll("weapons/sentry_explode.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
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
	if(IsValidEntity(iref_Halo[client][2]))
	{
		CreateTimer(0.1, Timer_RemoveEntityParticle, iref_Halo[client][2], TIMER_FLAG_NO_MAPCHANGE);
	}

	float flPos[3];
	float flAng[3];
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(IsValidEntity(viewmodelModel))
	{
		if(level == 1 || level == 2 || level == 3)
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
		if(level == 2 || level == 3)
		{

			GetAttachment(viewmodelModel, "head", flPos, flAng);
			int particle_halo = ParticleEffectAt(flPos, "unusual_sparkletree_gold_starglow", 0.0);
			iref_Halo[client][2] = EntIndexToEntRef(particle_halo);
			AddEntityToThirdPersonTransitMode(client, particle_halo);
			SetParent(viewmodelModel, particle_halo, "head", {0.0,0.0,-3.0});
		}
		if(level == 3)
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
			int particler = ParticleEffectAt(flPos, "utaunt_arcane_yellow_sparkle", 0.0);
			SetParent(client, particler);
			iref_Halo[client][1] = EntIndexToEntRef(particler);
			AddEntityToThirdPersonTransitMode(client, particler);
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
		if(IsValidEntity(iref_Halo[client][2]))
		{
			AcceptEntityInput(iref_Halo[client][2], "ClearParent");
			TeleportEntity(iref_Halo[client][2], {16000.0,16000.0,16000.0});
			CreateTimer(0.1, Timer_RemoveEntity, iref_Halo[client][2], TIMER_FLAG_NO_MAPCHANGE);
			iref_Halo[client][2] = -1;
		}

		i_TransformInitLevel[client] = -1;
		Timer_Expidonsan_Transform[client] = null;
		return Plugin_Stop;
	}	
	return Plugin_Continue;
}