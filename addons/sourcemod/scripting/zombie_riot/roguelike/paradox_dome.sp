#pragma semicolon 1
#pragma newdecls required

// https://github.com/redsunservers/VSH-Rewrite/blob/master/addons/sourcemod/scripting/vsh/dome.sp

#define DOME_PROP_RADIUS 10000.0

#define DOME_FADE_START_MULTIPLIER 0.7
#define DOME_FADE_ALPHA_MAX 64

#define DOME_START_SOUND	"mvm/mvm_warning.wav"
#define DOME_NEARBY_SOUND	"ui/medic_alert.wav"
#define DOME_PERPARE_DURATION 4.5

#define DOME_RADIUS	3000.0

static int g_iDomeEntRef = -1;
static float g_flDomeStart = 0.0;
static float g_flDomeRadius = 0.0;
static float g_flDomePreviousGameTime = 0.0;
static float g_vecDomeCP[3];
static float g_flDomePlayerTime[MAXTF2PLAYERS] ={0.0, ...};
static bool g_bDomePlayerOutside[MAXTF2PLAYERS] = {false, ...};
static Handle g_hDomeTimerBleed = null;

void Rogue_Dome_Mapstart()
{
	PrecacheModel("models/kirillian/brsphere_huge.mdl");
}

void Rogue_Dome_WaveStart(const float pos[3])
{
	Rogue_Dome_WaveEnd();
	
	g_vecDomeCP = pos;
	
	//Create dome prop
	int iDome = CreateEntityByName("prop_dynamic");
	if (iDome == -1)
		return;
	
	g_flDomeRadius = 3000.0;
	
	DispatchKeyValueVector(iDome, "origin", g_vecDomeCP);						//Set origin to CP
	DispatchKeyValue(iDome, "model", "models/kirillian/brsphere_huge.mdl");	//Set model
	DispatchKeyValue(iDome, "disableshadows", "1");							//Disable shadow
	SetEntPropFloat(iDome, Prop_Send, "m_flModelScale", SquareRoot(g_flDomeRadius / DOME_PROP_RADIUS));	//Calculate model scale
	
	DispatchSpawn(iDome);
	
	SetEntityRenderMode(iDome, RENDER_TRANSCOLOR);
	SetEntityRenderColor(iDome, 255, 255, 255, 255);
	b_IsEntityAlwaysTranmitted[iDome] = true;
	Hook_DHook_UpdateTransmitState(iDome);
	
	g_flDomeStart = GetGameTime();
	g_flDomePreviousGameTime = g_flDomeStart;
	
	g_iDomeEntRef = EntIndexToEntRef(iDome);
	g_hDomeTimerBleed = CreateTimer(0.5, Dome_TimerBleed, _, TIMER_REPEAT);

	RequestFrame(Dome_Frame_Shrink);
}

void Rogue_Dome_WaveEnd()
{
	int iDome = EntRefToEntIndex(g_iDomeEntRef);
	if(IsValidEntity(g_iDomeEntRef))
	{
		if(iDome>MaxClients)
			RemoveEntity(iDome);
	}

	Zero(g_flDomePlayerTime);
	Zero(g_bDomePlayerOutside);
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
			float flDistanceMultiplier = Dome_GetDistance(iClient) / (g_flDomeRadius * g_flDomeRadius);
			
			if (flDistanceMultiplier > 1.0)
			{
				//Client is outside of dome, state that player is outside of dome
				g_bDomePlayerOutside[iClient] = true;
				
				//Add time on how long player have been outside of dome
				g_flDomePlayerTime[iClient] += GetGameTime() - g_flDomePreviousGameTime;
				
				//give bleed if havent been given one
				if (!TF2_IsPlayerInCondition(iClient, TFCond_Bleeding))
					TF2_MakeBleed(iClient, iClient, 9999.0);	//Does no damage, ty sourcemod
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
				
				UTIL_ScreenFade(iClient, 2000, 0, 0x0001, 255, 255, 255, RoundToNearest(flAlpha));
			}
		}
	}

	g_flDomePreviousGameTime = GetGameTime();

	RequestFrame(Dome_Frame_Shrink);
}

static Action Dome_TimerBleed(Handle hTimer)
{
	if (g_hDomeTimerBleed != hTimer)
		return Plugin_Stop;

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
				
				if (flDamage < 65.0)
					flDamage = 65.0;
				
				//Deal damage
				float health = float(GetClientHealth(iClient));
				if(health < flDamage)
				{
					SDKHooks_TakeDamage(iClient, 0, 0, flDamage, DMG_DROWN|DMG_PREVENT_PHYSICS_FORCE);
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
		GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", vecPos);
	
	else return -1.0;
	
	return GetVectorDistance(vecPos, g_vecDomeCP, true);
}
