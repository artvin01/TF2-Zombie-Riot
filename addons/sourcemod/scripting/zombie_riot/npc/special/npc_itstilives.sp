#pragma semicolon 1
#pragma newdecls required

static int GlobalHealth;
static int LeadStealer;
static ArrayList CollectedBodies;
static ArrayStack CollectedSounds[MAXENTITIES];

static char[] GetItstilivesHealth()
{
	GlobalHealth = 90;
	
	GlobalHealth *= CountPlayersOnRed(); //yep its high! will need tos cale with waves expoentially.
	
	float temp_float_hp = float(GlobalHealth);
	
	if(CurrentRound+1 < 30)
	{
		GlobalHealth = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.20));
	}
	else if(CurrentRound+1 < 45)
	{
		GlobalHealth = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.25));
	}
	else
	{
		GlobalHealth = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.35)); //Yes its way higher but i reduced overall hp of him
	}
	
	GlobalHealth = GlobalHealth * 9 / 16;
	
	char buffer[16];
	IntToString(GlobalHealth, buffer, sizeof(buffer));
	return buffer;
}

void Itstilives_MapStart()
{
	delete CollectedBodies;
	CollectedBodies = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	
	CollectedBodies.PushString("models/error.mdl");
	CollectedBodies.PushString("models/player/scout.mdl");
	CollectedBodies.PushString("models/player/soldier.mdl");
	CollectedBodies.PushString("models/player/pyro.mdl");
	CollectedBodies.PushString("models/player/demo.mdl");
	CollectedBodies.PushString("models/player/heavy.mdl");
	CollectedBodies.PushString("models/player/engineer.mdl");
	CollectedBodies.PushString("models/player/medic.mdl");
	CollectedBodies.PushString("models/player/sniper.mdl");
	CollectedBodies.PushString("models/player/spy.mdl");
}

methodmap Itstilives < CClotBody
{
	property bool m_bTargetBlue
	{
		public get()
		{
			return this.GetTeam() != 3;
		}
		public set(bool value)
		{
			if(value)
			{
				Change_Npc_Collision(this.index, 4);
				SetEntProp(this.index, Prop_Send, "m_iTeamNum", TFTeam_Red);
				b_Is_Blue_Npc[this.index] = false;
				b_IsAlliedNpc[this.index] = true;
			}
			else
			{
				Change_Npc_Collision(this.index, 2);
				SetEntProp(this.index, Prop_Send, "m_iTeamNum", TFTeam_Blue);
				b_Is_Blue_Npc[this.index] = true;
				b_IsAlliedNpc[this.index] = false;
			}
		}
	}
	
	public Itstilives(int client, float vecPos[3], float vecAng[3])
	{
		GetItstilivesHealth();
		
		static int MiniBosses[] = { NAZI_PANZER, SAWRUNNER, L4D2_TANK };
		Itstilives npc = view_as<Itstilives>(Npc_Create(MiniBosses[GetURandomInt() % sizeof(MiniBosses)], client, vecPos, vecAng, false));
		
		if(npc != view_as<Itstilives>(INVALID_ENT_REFERENCE))
			CollectNPC(npc.index, true);
		
		return npc;
	}
}

public Action Itstilives_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(damage > 99999.9)
		return Plugin_Continue;
	
	Itstilives npc = view_as<Itstilives>(victim);
	
	if(attacker > MaxClients)
	{
		if(CollectedSounds[attacker])
		{
			if(npc.m_bTargetBlue)
			{
				GlobalHealth += RoundToCeil(damage);
				npc.m_bTargetBlue = false;
			}
		}
		else if(GetEntProp(attacker, Prop_Send, "m_iTeamNum") == 2)
		{
			SetEntityRenderMode(attacker, RENDER_NONE);
		}
		else
		{
			CollectNPC(attacker, false);
			if(npc.m_bTargetBlue)
				npc.m_bTargetBlue = false;
		}
	}
	else if(attacker > 0)
	{
		GlobalHealth -= RoundToFloor(damage);
		
		if(GlobalHealth < 1)
		{
			CleanNPCs();
			damage = 0.0;
			return Plugin_Handled;
		}
		
		if(!npc.m_bTargetBlue && !(GetURandomInt() % (LeadStealer ? 49 : 139)))
		{
			int i = MaxClients + 1;
			while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
			{
				if(!CollectedSounds[i] && GetEntProp(i, Prop_Send, "m_iTeamNum") == 3)
				{
					npc.m_bTargetBlue = true;
					break;
				}
			}
		}
		
		SetEntProp(victim, Prop_Data, "m_iHealth", GlobalHealth);
	}
	
	damage = 0.0;
	return Plugin_Changed;
}

public Action Itstilives_RandomSoundBoss(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity != INVALID_ENT_REFERENCE)
	{
		char buffer[PLATFORM_MAX_PATH];
		GetRandomSound(buffer, sizeof(buffer));
		CollectedSounds[entity].PushString(buffer);
		EmitRandomSound(entity, buffer);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

static void CollectNPC(int entity, bool lead)
{
	Itstilives npc = view_as<Itstilives>(entity);
	
	SetEntProp(npc.index, Prop_Data, "m_iHealth", GlobalHealth);
	SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", GlobalHealth);
	
	float position[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
	
	char filepath[PLATFORM_MAX_PATH];
	for(int i = lead ? 0 : 3; i < 5; i++)
	{
		GetRandomModel(filepath, sizeof(filepath));
		if(filepath[0])
		{
			int prop = CreateEntityByName("prop_dynamic_override");
			if(prop != -1)
			{
				TeleportEntity(prop, position, NULL_VECTOR, NULL_VECTOR);
				
				DispatchKeyValue(prop, "model", filepath);
				DispatchKeyValue(prop, "solid", "0");
				DispatchKeyValue(prop, "RandomAnimation", "1");
				DispatchKeyValue(prop, "MinAnimTime", "1");
				DispatchKeyValue(prop, "MaxAnimTime", "4");
				DispatchSpawn(prop);
				
				SetVariantString("!activator");
				AcceptEntityInput(prop, "SetParent", entity, prop);
				SetEntPropEnt(prop, Prop_Send, "m_hOwnerEntity", entity);
				SetEntProp(prop, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_BONEMERGE_FASTCULL);
				
				CreateTimer(0.1, Timer_RandomModelEffectCrazed, EntIndexToEntRef(prop), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	
	GetEntPropString(entity, Prop_Data, "m_modelString", filepath, sizeof(filepath));
	CollectedBodies.PushString(filepath);
	
	CreateTimer(0.11, Timer_RandomModelEffect, EntIndexToEntRef(entity), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(lead ? 0.15 : 0.45, Timer_RandomSoundBoss, EntIndexToEntRef(entity), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
	if(!CollectedSounds[entity])
		CollectedSounds[entity] = new ArrayStack(ByteCountToCells(PLATFORM_MAX_PATH));
	
	
	npc.m_bDissapearOnDeath = true;
	npc.m_bStaticNPC = true;
	
	if(lead)
	{
		LeadStealer = entity;
	}
	else
	{
		Event event = CreateEvent("localplayer_pickup_weapon", true);
		
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				ClientCommand(client, "dsp_player %d", GetURandomInt() % 60);
				SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | (1 << 7));
				
				event.FireToClient(client);
				
				if(LastMann && TeutonType[client] == TEUTON_NONE)
				{
					GlobalHealth += 100000;
					SDKHook(client, SDKHook_PreThink, ItWon);
				}
			}
		}
		
		event.Cancel();
	}
}

public void ItWon(int client)
{
	if(!LastMann || TeutonType[client] != TEUTON_NONE || !IsPlayerAlive(client))
		SDKUnhook(client, SDKHook_PreThink, ItWon);
	
	Event event = CreateEvent("localplayer_pickup_weapon", true);
	event.FireToClient(client);
	event.Cancel();
}

static void CleanNPCs()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			ClientCommand(client, "dsp_player 0");
			SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") & ~(1 << 7));
		}
	}
	
	GlobalHealth = 0;
	
	int entity = MaxClients + 1;
	while((entity = FindEntityByClassname(entity, "zr_base_npc")) != -1)
	{
		SetEntityRenderMode(entity, RENDER_NORMAL);
		
		if(CollectedSounds[entity])
		{
			char buffer[PLATFORM_MAX_PATH];
			while(!CollectedSounds[entity].Empty)
			{
				CollectedSounds[entity].PopString(buffer, sizeof(buffer));
				StopSound(entity, SNDCHAN_AUTO, buffer);
				StopSound(entity, SNDCHAN_STATIC, buffer);
			}
			
			delete CollectedSounds[entity];
			SDKHooks_TakeDamage(entity, entity, entity, 99999999.9);
		}
	}
}

public Action Timer_RandomSoundBoss(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity != INVALID_ENT_REFERENCE)
	{
		char buffer[PLATFORM_MAX_PATH];
		GetRandomSound(buffer, sizeof(buffer));
		CollectedSounds[entity].PushString(buffer);
		EmitRandomSound(entity, buffer);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

public Action Timer_RandomModelEffect(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity != INVALID_ENT_REFERENCE)
	{
		SetRandomEffects(entity, false);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

public Action Timer_RandomModelEffectCrazed(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity != INVALID_ENT_REFERENCE)
	{
		SetRandomEffects(entity, true);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

static void GetRandomModel(char[] buffer, int length)
{
	if(CollectedBodies)
		CollectedBodies.GetString(GetURandomInt() % CollectedBodies.Length, buffer, length);
}

static void GetRandomSound(char[] buffer, int length)
{
	static int TableSound = INVALID_STRING_TABLE;
	if(TableSound == INVALID_STRING_TABLE)
		TableSound = FindStringTable("soundprecache");
	
	int strings = GetStringTableNumStrings(TableSound);
	int start = GetURandomInt() % strings;
	for(int i = start + 1; i != start; i++)
	{
		if(i >= strings)
		{
			i = -1;
			continue;
		}
		
		ReadStringTable(TableSound, i, buffer, length);
		
		if(buffer[0])
			break;
	}
}

static void EmitRandomSound(int entity, const char[] buffer)
{
	EmitSoundToAll(buffer, entity, _, GetURandomInt() % 76 + 50, _, GetURandomFloat() / 2.0 + 0.5, (GetURandomInt() % 4) ? (GetURandomInt() % 71 + 25) : (GetURandomInt() % 101 + 120));
}

static void SetRandomEffects(int entity, bool rotation)
{
	if(!(GetURandomInt() % 4))
	{
		SetEntityRenderMode(entity, view_as<RenderMode>(GetURandomInt() % view_as<int>(RENDER_ENVIRONMENTAL)));
		SetEntityRenderColor(entity, GetURandomInt() % 256, GetURandomInt() % 256, GetURandomInt() % 256, (GetURandomInt() % 2) ? 255 : GetURandomInt() % 129 + 128);
	}
	else if(GetURandomInt() % 2)
	{
		SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
		SetEntityRenderColor(entity, 0, 0, 0);
	}
	
	if(!(GetURandomInt() % 6))
	{
		SetEntityRenderFx(entity, view_as<RenderFx>(GetURandomInt() % view_as<int>(RENDERFX_GLOWSHELL)));
	}
	else if(GetURandomInt() % 2)
	{
		SetEntityRenderFx(entity, RENDERFX_NONE);
	}
	
	if(rotation)
	{
		if(!(GetURandomInt() % 5))
		{
			float ang[3];
			GetEntPropVector(entity, Prop_Data, "m_angAbsRotation", ang);
			
			if(GetURandomInt() % 3)
				ang[0] = GetURandomFloat() * 360.0 - 180.0;
			
			if(GetURandomInt() % 3)
				ang[1] = GetURandomFloat() * 360.0 - 180.0;
			
			if(GetURandomInt() % 3)
				ang[2] = GetURandomFloat() * 360.0 - 180.0;
			
			TeleportEntity(entity, NULL_VECTOR, ang, NULL_VECTOR);
			SetEntProp(entity, Prop_Send, "m_fEffects", 0);
		}
		else if(GetURandomInt() % 2)
		{
			SetEntProp(entity, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_BONEMERGE_FASTCULL);
		}
	}
}