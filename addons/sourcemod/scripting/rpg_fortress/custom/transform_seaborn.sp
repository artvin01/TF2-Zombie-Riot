static int ParticleRef[MAXTF2PLAYERS] = {-1, ...};
static float CreepPos[MAXTF2PLAYERS][3];
static float CreepSize[MAXTF2PLAYERS];
static Handle CreepTimer;
static int Sprite;

void Transform_Seaborn_MapStart()
{
	PrecacheSound("player/souls_receive2.wav");
	PrecacheSound("player/souls_receive3.wav");
	PrecacheSound("misc/halloween/spell_spawn_boss.wav");
	PrecacheSound("misc/halloween/spell_spawn_boss_disappear.wav");
	PrecacheSound("ambient/halloween/male_scream_13.wav");
	PrecacheSound("ambient/halloween/male_scream_17.wav");

	Sprite = PrecacheModel("materials/sprites/laserbeam.vmt");

	Zero(CreepSize);
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

	CreepSize[client] = 0.0;
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
	
	GetClientAbsOrigin(client, CreepPos[client]);
	CreepPos[client][2] += 1.0;

	int entity = ParticleEffectAt(CreepPos[client], "utaunt_fish_parent", -1.0);
	if(entity > MaxClients)
	{
		SetParent(client, entity);
		ParticleRef[client] = EntIndexToEntRef(entity);
	}

	float maxMastery;
	float mastery = Stats_GetCurrentFormMastery(client, maxMastery);

	if(maxMastery)
		CreepSize[client] = 200.0 + (mastery * 600.0 / maxMastery);

	if(!CreepTimer)
		CreepTimer = CreateTimer(0.5, Timer_CreepThink, _, TIMER_REPEAT);
}

static Action Timer_CreepThink(Handle timer)
{
	bool found;

	for(int client = 1; client <= MaxClients; client++)
	{
		if(CreepSize[client])
		{
			if(IsClientInGame(client) && IsPlayerAlive(client))
			{
				found = true;

				if(CreepSize[client] < 800.0)
					CreepSize[client] += 5.0;

				int targets;
				static int target[12];
				static float pos[3];
				float size = CreepSize[client] * CreepSize[client];

				for(int ally = 1; ally <= MaxClients; ally++)
				{
					if(ally != client)
					{
						if(!IsClientInGame(ally) || (RaceIndex[client] != RaceIndex[ally] && IsPlayerAlive(ally)))
							continue;
					}
					
					if(targets < sizeof(target))
						target[targets++] = ally;

					if(!IsPlayerAlive(ally))
						continue;

					GetEntPropVector(ally, Prop_Send, "m_vecOrigin", pos);
					if(GetVectorDistance(pos, CreepPos[client], true) < size)
						TF2_AddCondition(ally, TFCond_SpeedBuffAlly, 0.55, client);
				}

				TE_SetupBeamRingPoint(CreepPos[client], CreepSize[client] * 1.99, CreepSize[client] * 2.0, Sprite, Sprite, 0, 1, 0.5, 12.0, 0.1, {55, 55, 255, 255}, 1, 0);
				TE_Send(target, targets);

				continue;
			}

			CreepSize[client] = 0.0;
		}
	}

	if(found)
		return Plugin_Continue;
	
	CreepTimer = null;
	return Plugin_Stop;
}

public void Seaborn_Activation_Disable_form_3(int client)
{
	CleanEffects(client);

	EmitSoundToAll("ambient/halloween/male_scream_17.wav", client, SNDCHAN_AUTO, 80);
}
