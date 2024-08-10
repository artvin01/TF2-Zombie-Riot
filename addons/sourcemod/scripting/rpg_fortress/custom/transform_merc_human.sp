static Handle Timer_Expidonsan_Transform[MAXPLAYERS+1] = {null, ...};
static int i_TransformInitLevel[MAXPLAYERS+1];
static int iref_Halo[MAXPLAYERS+1][2];

void Transform_MercHuman_MapStart()
{
	PrecacheSound("ui/rd_2base_alarm.wav");
	PrecacheSound("ui/quest_decode_halloween.wav");
	PrecacheSound("ui/halloween_boss_tagged_other_it.wav");
}

public void MercHuman_Activation_Enable_form_1(int client)
{
	//Respawn Resolve
	MercHuman_Activation_Enable_Global(client, 1);
}

public void MercHuman_Activation_Enable_form_2(int client)
{
	//Merasmus Magic!
	MercHuman_Activation_Enable_Global(client, 2);
}
public void MercHuman_Activation_Enable_form_3(int client)
{
	//Merasmus Magic!
	MercHuman_Activation_Enable_Global(client, 3);
}

public void MercHuman_Activation_Enable_Global(int client, int level)
{
	switch(level)
	{
		case 1:
		{
			EmitSoundToAll("ui/rd_2base_alarm.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
		}
		case 2:
		{
			EmitSoundToAll("ui/quest_decode_halloween.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
		}
		case 3:
		{
			EmitSoundToAll("ui/halloween_boss_tagged_other_it.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
		}
	}
	delete Timer_Expidonsan_Transform[client];
	DataPack pack;
	Timer_Expidonsan_Transform[client] = CreateDataTimer(0.5, TimerMercHuman_Transform, pack, TIMER_REPEAT);
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
			flPos[2] -= 10.0;
			int particle_halo = ParticleEffectAt(flPos, "unusual_phantomcrown_purple_parent", 0.0);
			iref_Halo[client][0] = EntIndexToEntRef(particle_halo);
			AddEntityToThirdPersonTransitMode(client, particle_halo);
			SetParent(viewmodelModel, particle_halo, "head", {0.0,0.0,-10.0});
		}
		if(level == 2)
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
			int particler = ParticleEffectAt(flPos, "utaunt_merasmus_fire_embers", 0.0);
			SetParent(client, particler);
			iref_Halo[client][1] = EntIndexToEntRef(particler);
			AddEntityToThirdPersonTransitMode(client, particler);
		}
		if(level == 3)
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
			flPos[2] += 10.0;
			int particler = ParticleEffectAt(flPos, "eyeboss_aura_grumpy", 0.0);
			SetParent(client, particler);
			iref_Halo[client][1] = EntIndexToEntRef(particler);
			AddEntityToThirdPersonTransitMode(client, particler);

			
			GetAttachment(viewmodelModel, "head", flPos, flAng);
			flPos[2] += 10.0;
			int particle_halo = ParticleEffectAt(flPos, "unusual_eyeboss_parent", 0.0);
			iref_Halo[client][0] = EntIndexToEntRef(particle_halo);
			AddEntityToThirdPersonTransitMode(client, particle_halo);
			SetParent(viewmodelModel, particle_halo, "head", {0.0,0.0,-10.0});
		}
	}
}


public Action TimerMercHuman_Transform(Handle timer, DataPack pack)
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