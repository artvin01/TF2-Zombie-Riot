bool b_IsSkyboxProp[2049] = { false, ... };
bool b_SkyboxChanged = false;
char s_OriginalSkybox[255] = "sky_tf2_04";

ConVar SkyName;

public void SkyboxProps_OnPluginStart()
{
	RegAdminCmd("spawnskyboxprop", SpawnProp, ADMFLAG_GENERIC, "Spawn a prop in the 3D skybox.");
	RegAdminCmd("spawnskyboxparticle", SpawnAParticle, ADMFLAG_GENERIC, "Spawn a particle in the 3D skybox.");
	RegAdminCmd("changeskybox", ChangeSkybox, ADMFLAG_GENERIC, "Change the current skybox texture.");
	RegAdminCmd("resetskybox", ResetSkybox, ADMFLAG_GENERIC, "Reset the skybox texture to its default.");
	RegAdminCmd("clearskybox", ClearSkybox, ADMFLAG_GENERIC, "Removes all props from the 3D skybox, which were spawned by this plugin.");
	
	SkyName = FindConVar("sv_skyname");
}

#define SND_SPAWNED		"misc/rd_points_return01.wav"
#define SND_CLEARED		"misc/rd_finale_beep01.wav"

public SkyboxProps_OnMapStart()
{
	PrecacheSound(SND_SPAWNED, true);
	PrecacheSound(SND_CLEARED, true);
}

public Action SpawnProp(int client, int args)
{
	if (args < 1 || args > 12)
	{
		PrintMessageToClient(client, "{green}[Skybox Props] {default}Usage: sm_spawnskyboxprop <prop's model name> OPTIONAL: <scale> <X, Y, Z offsets (spaced)> <X, Y, Z rotations (spaced)> <animation> <playback rate> <lifespan> <skin>");
		return Plugin_Continue;
	}
		
	char prop[255];
	GetCmdArg(1, prop, sizeof(prop));
		
	if (!FileExists(prop) && !FileExists(prop, true))
	{
		char msg[255];
		Format(msg, sizeof(msg), "{green}[Skybox Props] {default}Failed to spawn prop: unable to find model {red}''%s''{default}.", prop);
		PrintMessageToClient(client, msg);
		
		return Plugin_Continue;
	}
	else
	{
		int cam = FindEntityByClassname(-1, "sky_camera");
			
		if (cam == -1)
		{
			PrintMessageToClient(client, "{green}[Skybox Props] {default}Failed to spawn prop: this map does not use a 3D skybox.");
			return Plugin_Continue;
		}
			
		PrecacheModel(prop);
			
		float CamLoc[3], values[7], offset[3], ang[3];
		GetEntPropVector(cam, Prop_Send, "m_vecOrigin", CamLoc);
			
		for (int i = 2; i <= 8; i++)
		{
			if (i > args)
			{
				if (i == 2)
				{
					values[i - 2] = 1.0;
				}
				else
				{
					values[i - 2] = 0.0;
				}
			}
			else
			{
				char arg[32];
				GetCmdArg(i, arg, sizeof(arg));
				values[i - 2] = StringToFloat(arg);
			}
		}
			
		for (int vec = 1; vec < 7; vec++)
		{
			if (vec < 4)
			{
				offset[vec - 1] = CamLoc[vec - 1] + values[vec];
			}
			else
			{
				ang[vec - 4] = values[vec];
			}
		}
			
		char sequence[255] = "ref";
		char skin[255] = "0";
		char otherString[255];
			
		if (args >= 9)
		{
			GetCmdArg(9, sequence, sizeof(sequence));
		}
			
		float rate = 1.0;
		float life = 0.0;
		if (args >= 10)
		{
			GetCmdArg(10, otherString, sizeof(otherString));
			rate = StringToFloat(otherString);
		}
			
		if (args >= 11)
		{
			GetCmdArg(11, otherString, sizeof(otherString));
			life = StringToFloat(otherString);
		}
			
		if (args >= 12)
		{
			GetCmdArg(12, skin, sizeof(skin));
		}
			
		int spawned = Animator_SpawnDummy(prop, sequence, offset, ang, skin, rate, life);
			
		if (IsValidEdict(spawned))
		{
			PlaySoundToClient(client, SND_SPAWNED);
			
			char msg[255];
			Format(msg, sizeof(msg), "{green}[Skybox Props] {default}Successfully spawned skybox prop: {green}''%s''{default}.", prop);
			PrintMessageToClient(client, msg);
			
			SetEntPropFloat(spawned, Prop_Send, "m_flModelScale", values[0]); 
			b_IsSkyboxProp[spawned] = true;
		}
		else
		{
			PrintMessageToClient(client, "{green}[Skybox Props] {default}Failed to spawn prop: invalid prop entity spawned, please try again.");
		}
	}
		
	return Plugin_Continue;
}

public Action SpawnAParticle(int client, int args)
{
	if (args < 1 || args > 5)
	{
		PrintMessageToClient(client, "{green}[Skybox Props] {default}Usage: sm_spawnskyboxparticle <particle name> <OPTIONAL: X offset> <OPTIONAL: Y offset> <OPTIONAL: Z offset> <OPTIONAL: lifespan>");
		return Plugin_Continue;
	}
		
	char particle[255];
	GetCmdArg(1, particle, sizeof(particle));
		
	int cam = FindEntityByClassname(-1, "sky_camera");
			
	if (cam == -1)
	{
		PrintMessageToClient(client, "{green}[Skybox Props] {default}Failed to spawn particle: this map does not use a 3D skybox.");
		return Plugin_Continue;
	}
			
	float CamLoc[3], offset[3], lifespan;
	GetEntPropVector(cam, Prop_Send, "m_vecOrigin", CamLoc);
		
	for (int i = 2; i <= 5; i++)
	{
		if (i > args)
		{
			if (i == 5)
			{
				lifespan = 0.0;
			}
			else
			{
				offset[i - 2] = CamLoc[i - 2];
			}
		}
		else
		{
			char arg[255];
			GetCmdArg(i, arg, sizeof(arg));
	
			float value = StringToFloat(arg);
				
			if (i == 5)
			{
				lifespan = value;
			}
			else
			{
				offset[i - 2] = CamLoc[i - 2] + value;
			}
		}
	}
		
	int spawned = SpawnParticle_R(offset, particle, lifespan);
		
	if (IsValidEdict(spawned))
	{
		PlaySoundToClient(client, SND_SPAWNED);
		
		char msg[255];
		Format(msg, sizeof(msg), "{green}[Skybox Props] {default}Successfully spawned skybox particle: {green}''%s''{default}.", particle);
		PrintMessageToClient(client, msg);
		
		b_IsSkyboxProp[spawned] = true;
	}
	else
	{
		PrintMessageToClient(client, "{green}[Skybox Props] {default}Failed to spawn particle: invalid particle entity spawned, please try again.");
	}
	
	return Plugin_Continue;
}

public Action ClearSkybox(int client, int args)
{
	int numRemoved = 0;
		
	for (int i = MaxClients + 1; i <= 2048; i++)
	{
		if (IsValidEdict(i))
		{
			if (b_IsSkyboxProp[i])
			{
				RemoveEntity(i);
				numRemoved++;
			}
		}
	}
		
	PlaySoundToClient(client, SND_CLEARED);
	
	char msg[255];
	Format(msg, sizeof(msg), "{green}[Skybox Props] {default}Successfully despawned {olive}%i{default} skybox prop(s).", numRemoved);
	PrintMessageToClient(client, msg);
	
	return Plugin_Continue;
}

public Action ChangeSkybox(int client, int args)
{
	if (args > 1)
	{
		PrintMessageToClient(client, "{green}[Skybox Props] {default}Usage: sm_changeskybox <skybox texture>");
		return Plugin_Continue;
	}
		
	char texture[255];
	GetCmdArg(1, texture, sizeof(texture));
		
	if (!b_SkyboxChanged)
	{
		SkyName.GetString(s_OriginalSkybox, sizeof(s_OriginalSkybox));
	}
		
	SkyName.SetString(texture, true);
	b_SkyboxChanged = true;
		
	PlaySoundToClient(client, SND_SPAWNED);
	
	char msg[255];
	Format(msg, sizeof(msg), "{green}[Skybox Props] {default}Successfully changed the skybox texture to {green}''%s''{default}.", texture);
	PrintMessageToClient(client, msg);
	
	return Plugin_Continue;
}

public Action ResetSkybox(int client, int args)
{
	if (!b_SkyboxChanged)
	{
		PrintMessageToClient(client, "{green}[Skybox Props] {default}The skybox has not yet been changed.");
		return Plugin_Continue;
	}
		
	SkyName.SetString(s_OriginalSkybox, true);
	b_SkyboxChanged = false;
		
	PlaySoundToClient(client, SND_CLEARED);
	PrintMessageToClient(client, "{green}[Skybox Props] {default}Successfully reset the skybox texture.");
		
	return Plugin_Continue;
}

public void SkyboxProps_OnEntityDestroyed(int entity)
{
	b_IsSkyboxProp[entity] = false;
}

void PrintMessageToClient(int client, char message[255])
{
	if (IsValidClient(client))
	{
		CPrintToChat(client, message);
	}
}

void PlaySoundToClient(int client, char sound[255])
{
	if (IsValidClient(client))
	{
		EmitSoundToClient(client, sound, _, _, 120);
	}
}

public int Animator_SpawnDummy(char model[255], char animation[255], float spawnLoc[3], float spawnAng[3], char skin[255], float rate, float life)
{
	int ReturnValue = -1;
	
	ReturnValue = CreateEntityByName("prop_dynamic_override");
	
	if(IsValidEntity(ReturnValue))
	{
		TeleportEntity(ReturnValue, spawnLoc, NULL_VECTOR, NULL_VECTOR);
	
		DispatchKeyValue(ReturnValue, "skin", skin);
		DispatchKeyValue(ReturnValue, "model", model);	
		
		DispatchKeyValueVector(ReturnValue, "angles", spawnAng);
		
		DispatchSpawn(ReturnValue);
		ActivateEntity(ReturnValue);
		
		SetVariantString(animation);
		AcceptEntityInput(ReturnValue, "SetAnimation");
		DispatchKeyValueFloat(ReturnValue, "playbackrate", rate);
		
		if (life > 0.0)
		{
			CreateTimer(life, Timer_RemoveEntity, EntIndexToEntRef(ReturnValue), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else
	{
		ReturnValue = -1;
	}
	
	return ReturnValue;
}

stock int SpawnParticle_R(float origin[3], char particle[255], float duration = 0.0)
{
	int Effect = CreateEntityByName("info_particle_system");
	if (IsValidEdict(Effect))
	{
		TeleportEntity(Effect, origin, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(Effect, "effect_name", particle);
		SetVariantString("!activator");
		DispatchKeyValue(Effect, "targetname", "present");
		DispatchSpawn(Effect);
		ActivateEntity(Effect);
		AcceptEntityInput(Effect, "Start");
		
		if (duration > 0.0)
		{
			CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(Effect), TIMER_FLAG_NO_MAPCHANGE);
		}
		
		return Effect;
	}
	
	return -1;
}