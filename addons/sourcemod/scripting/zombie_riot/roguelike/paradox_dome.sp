#pragma semicolon 1
#pragma newdecls required

// https://github.com/redsunservers/VSH-Rewrite/blob/master/addons/sourcemod/scripting/vsh/dome.sp

#define DOME_PROP_RADIUS 10000.0 // Don't change

#define DOME_FADE_START_MULTIPLIER 0.9
#define DOME_FADE_ALPHA_MAX 64

#define DOME_NEARBY_SOUND	"ui/medic_alert.wav"

#define DOME_RADIUS	3000.0
#define DOME_RADIUS_ROGUE3	2700.0
#define DOME_RED 255
#define DOME_GREEN 125
#define DOME_BLUE 125

float DomeRadiusGlobal()
{
	switch(Rogue_Theme())
	{
		case BlueParadox:
		{
			return DOME_RADIUS;
		}
		case ReilaRift:
		{
			return (DOME_RADIUS_ROGUE3);
		}
	}
	return DOME_RADIUS;
}
static int g_iDomeEntRef = -1;
static float g_flDomeStart = 0.0;
static float g_flDomePreviousGameTime = 0.0;
static float g_vecDomeCP[3];
static float g_flDomePlayerTime[MAXPLAYERS] ={0.0, ...};
static bool g_bDomePlayerOutside[MAXENTITIES] = {false, ...};
static Handle g_hDomeTimerBleed = null;

void Rogue_Dome_Mapstart()
{
	PrecacheModel("models/kirillian/zr_rogue_dome_2.mdl");
	PrecacheSound(DOME_NEARBY_SOUND);
	if(g_hDomeTimerBleed != null)
		delete g_hDomeTimerBleed;
}

void Rogue_Dome_WaveStart(const float pos[3])
{
	Rogue_Dome_WaveEnd();

	g_vecDomeCP = pos;
	
	//Create dome prop
	int iDome = CreateEntityByName("prop_dynamic");
	if (iDome == -1)
		return;
	
	DispatchKeyValueVector(iDome, "origin", g_vecDomeCP);						//Set origin to CP
	DispatchKeyValue(iDome, "model", "models/kirillian/zr_rogue_dome_2.mdl");	//Set model
	DispatchKeyValue(iDome, "disableshadows", "1");							//Disable shadow
	SetEntPropFloat(iDome, Prop_Send, "m_flModelScale", SquareRoot(DomeRadiusGlobal() / DOME_PROP_RADIUS));	//Calculate model scale
	
	DispatchSpawn(iDome);
	float AlphaForwardData;
	AlphaForwardData = SquareRoot(DomeRadiusGlobal() / DOME_PROP_RADIUS);

	//NEVER CHANGE THIS
	AlphaForwardData *= 200.0;


	if(AlphaForwardData >= 254.0)
		AlphaForwardData = 254.0;

	SetEntityRenderMode(iDome, RENDER_TRANSCOLOR);
	SetEntityRenderColor(iDome, DOME_RED, DOME_GREEN, DOME_BLUE, RoundToNearest(AlphaForwardData));
	SetEntityTransmitState(iDome, FL_EDICT_ALWAYS);
	CBaseEntity(iDome).AddEFlags(EFL_IN_SKYBOX);
	SDKHook(iDome, SDKHook_SetTransmit, Dome_Transmit);
//	b_IsEntityAlwaysTranmitted[iDome] = true;
//	Hook_DHook_UpdateTransmitState(iDome);
	
	g_flDomeStart = GetGameTime();
	g_flDomePreviousGameTime = g_flDomeStart;
	
	g_iDomeEntRef = EntIndexToEntRef(iDome);

	if(g_hDomeTimerBleed != null)
		delete g_hDomeTimerBleed;
		
	g_hDomeTimerBleed = CreateTimer(0.5, Dome_TimerBleed, _, TIMER_REPEAT);

	RequestFrame(Dome_Frame_Shrink);
}
public Action Dome_Transmit(int entity, int client)
{
	return Plugin_Handled;
}


void Rogue_Dome_WaveEnd()
{
	int iDome = EntRefToEntIndex(g_iDomeEntRef);
	if(IsValidEntity(g_iDomeEntRef))
	{
		if(iDome>MaxClients)
			RemoveEntity(iDome);
	}

	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient))
		{
			if (g_bDomePlayerOutside[iClient])
			{
				//Client is not outside of dome, remove bleed
				TF2_RemoveCondition(iClient, TFCond_Bleeding);
				g_bDomePlayerOutside[iClient] = false;
			}
		}
	}

	g_flDomeStart = 0.0;
	Zero(g_flDomePlayerTime);
}

static void Dome_Frame_Shrink()
{
	if (g_flDomeStart == 0.0)
		return;

	int iDome = EntRefToEntIndex(g_iDomeEntRef);
	if (!IsValidEntity(iDome))
		return;
	
	//Give client bleed if outside of dome
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient))
		{
			// 0.0 = centre of CP
			//<1.0 = inside dome
			// 1.0 = at border of dome
			//>1.0 = outside of dome
			float flDistanceMultiplier = Dome_GetDistance(iClient) / (DomeRadiusGlobal() * DomeRadiusGlobal());
			
			if (flDistanceMultiplier > 1.0)
			{
				//Client is outside of dome, state that player is outside of dome
				g_bDomePlayerOutside[iClient] = true;
				
				//Add time on how long player have been outside of dome
				g_flDomePlayerTime[iClient] += GetGameTime() - g_flDomePreviousGameTime;
				
				//give bleed if havent been given one
				if (!TF2_IsPlayerInCondition(iClient, TFCond_Bleeding))
					TF2_MakeBleed(iClient, iClient, 99.0);	//Does no damage, ty sourcemod
			}
			else if (g_bDomePlayerOutside[iClient])
			{
				//Client is not outside of dome, remove bleed
				TF2_RemoveCondition(iClient, TFCond_Bleeding);
				g_bDomePlayerOutside[iClient] = false;
			}
			
			//Create fade
			if (flDistanceMultiplier > DOME_FADE_START_MULTIPLIER)
			{
				float flAlpha;
				if (flDistanceMultiplier > 1.0)
					flAlpha = float(DOME_FADE_ALPHA_MAX);
				else
					flAlpha = (flDistanceMultiplier - DOME_FADE_START_MULTIPLIER) * (1.0/(1.0-DOME_FADE_START_MULTIPLIER)) * DOME_FADE_ALPHA_MAX;
				
				UTIL_ScreenFade(iClient, 600, 0, 0x0001, DOME_RED, DOME_GREEN, DOME_BLUE, RoundToNearest(flAlpha));
			}
		}
	}
	for (int entityrand = 1; entityrand < MAXENTITIES; entityrand++)
	{
		if(b_ThisWasAnNpc[entityrand] && !b_NpcHasDied[entityrand] && !b_StaticNPC[entityrand])
		{
			float flDistanceMultiplier = Dome_GetDistance(entityrand) / (DomeRadiusGlobal() * DomeRadiusGlobal());
			
			if (flDistanceMultiplier > 1.0)
			{
				f_DomeInsideTest[entityrand] = GetGameTime() + 0.1;
				g_bDomePlayerOutside[entityrand] = true;
			}
			else
			{
				g_bDomePlayerOutside[entityrand] = false;
			}
		}
	}

	g_flDomePreviousGameTime = GetGameTime();

	RequestFrame(Dome_Frame_Shrink);
}

static Action Dome_TimerBleed(Handle hTimer)
{
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient))
		{
			StopSound(iClient, SNDCHAN_AUTO, DOME_NEARBY_SOUND);
			
			//Check if player is outside of dome
			if (g_bDomePlayerOutside[iClient])
			{
				//Calculate damage, the longer the player is outside of the dome, the more damage it deals
				float flDamage = Pow(2.0, g_flDomePlayerTime[iClient]);
				
				//Deal damage
				float health = float(GetClientHealth(iClient));
				if(health < flDamage)
				{
					SDKHooks_TakeDamage(iClient, 0, 0, flDamage, DMG_OUTOFBOUNDS|DMG_PREVENT_PHYSICS_FORCE);
				}
				else
				{
					SetEntityHealth(iClient, RoundToCeil(health-flDamage));
				}
				EmitSoundToClient(iClient, DOME_NEARBY_SOUND);
			}
		}
	}
	
	return Plugin_Continue;
}

static float Dome_GetDistance(int iEntity)
{
	float vecPos[3];
	
	//Client
	if (0 < iEntity <= MaxClients && IsClientInGame(iEntity) && IsPlayerAlive(iEntity))
		GetClientEyePosition(iEntity, vecPos);
	
	//Buildings
	else if (IsValidEntity(iEntity))
		GetEntPropVector(iEntity, Prop_Data, "m_vecAbsOrigin", vecPos);
	
	else return -1.0;
	
	return GetVectorDistance(vecPos, g_vecDomeCP, true);
}

stock bool Dome_PointOutside(float pos[3])
{
	if(!IsValidEntity(g_iDomeEntRef))
		return false;
	
	return GetVectorDistance(pos, g_vecDomeCP, true) > (DomeRadiusGlobal() * DomeRadiusGlobal());
}