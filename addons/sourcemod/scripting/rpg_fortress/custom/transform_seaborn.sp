static int ParticleRef[MAXTF2PLAYERS] = {-1, ...};

void Transform_Seaborn_MapStart()
{
	PrecacheSound("player/souls_receive2.wav");
	PrecacheSound("player/souls_receive3.wav");
	PrecacheSound("misc/halloween/spell_spawn_boss.wav");
	PrecacheSound("misc/halloween/spell_spawn_boss_disappear.wav");
	PrecacheSound("ambient/halloween/male_scream_13.wav");
	PrecacheSound("ambient/halloween/male_scream_17.wav");
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
	
	float pos[3]; GetClientAbsOrigin(client, pos);
	pos[2] += 1.0;

	int entity = ParticleEffectAt(pos, "utaunt_hands_floor2_blue", -1.0);
	if(entity > MaxClients)
	{
		SetParent(client, entity);
		ParticleRef[client] = EntIndexToEntRef(entity);
	}
}

public void Seaborn_Activation_Disable_form_1(int client)
{
	CleanEffects(client);

	EmitSoundToAll("player/souls_receive2.wav", client, SNDCHAN_AUTO, 80);
}

public void Seaborn_Activation_Enable_form_2(int client)
{
	CleanEffects(client);

	EmitSoundToAll("misc/halloween/spell_spawn_boss.wav", client, SNDCHAN_AUTO, 80);

	float pos[3]; GetClientAbsOrigin(client, pos);
	pos[2] += 1.0;

	ParticleEffectAt(pos, "halloween_boss_summon", 8.0);
	
	TF2_AddCondition(client, TFCond_HalloweenGiant);
}

public void Seaborn_Activation_Disable_form_2(int client)
{
	CleanEffects(client);

	EmitSoundToAll("misc/halloween/spell_spawn_boss_disappear.wav", client, SNDCHAN_AUTO, 80);

	float pos[3]; GetClientAbsOrigin(client, pos);
	pos[2] += 1.0;
	
	int entity = ParticleEffectAt(pos, "halloween_boss_death", 1.0);
	if(entity > MaxClients)
	{
		SetParent(client, entity);
	}

	TF2_RemoveCondition(client, TFCond_HalloweenGiant);
}

public void Seaborn_Activation_Enable_form_3(int client)
{
	CleanEffects(client);

	EmitSoundToAll("ambient/halloween/male_scream_13.wav", client, SNDCHAN_AUTO, 80);
	
	float pos[3]; GetClientAbsOrigin(client, pos);
	pos[2] += 1.0;

	int entity = ParticleEffectAt(pos, "utaunt_fish_parent", -1.0);
	if(entity > MaxClients)
	{
		SetParent(client, entity);
		ParticleRef[client] = EntIndexToEntRef(entity);
	}
}

public void Seaborn_Activation_Disable_form_3(int client)
{
	CleanEffects(client);

	EmitSoundToAll("ambient/halloween/male_scream_17.wav", client, SNDCHAN_AUTO, 80);
}
