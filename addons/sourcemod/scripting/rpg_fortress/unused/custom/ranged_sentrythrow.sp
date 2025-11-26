#define MORTAR_SHOT	"weapons/mortar/mortar_fire1.wav"
#define MORTAR_BOOM	"beams/beamstart5.wav"
#define MORTAR_SHOT_INCOMMING	"weapons/mortar/mortar_shell_incomming1.wav"

static int HasSentry[MAXPLAYERS];
static float SentryDamage[MAXPLAYERS];
static int DrainRate[MAXPLAYERS];

float SentryDamageRpg(int client)
{
	return SentryDamage[client];
}

int RpgHasSentry(int client)
{
	if(client <= MaxClients)
	{
		return HasSentry[client];
	}
	else
	{
		return false;
	}
}

void SentryThrow_MapStart()
{
	PrecacheSound(MORTAR_SHOT);
	PrecacheSound(MORTAR_BOOM); 
	PrecacheSound(MORTAR_SHOT_INCOMMING); 
	PrecacheSound("weapons/drg_wrench_teleport.wav");
}

public float AbilitySentryThrow(int client, int index, char name[48])
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(IsValidEntity(weapon))
		{
			static char classname[36];
			GetEntityClassname(weapon, classname, sizeof(classname));
			if (TF2_GetClassnameSlot(classname, weapon) != TFWeaponSlot_Melee && !i_IsWandWeapon[weapon] && !i_IsWrench[weapon])
			{
				if(Stats_Dexterity(client) >= 25)
				{
					if(!IsValidEntity(HasSentry[client]))
					{
						Ability_SentryThrow(client, 1, weapon);
						return (GetGameTime() + 40.0);
					}
					else
					{
						ClientCommand(client, "playgamesound items/medshotno1.wav");
						ShowGameText(client,"leaderboard_streak", 0, "Your sentry is already deployed.");
						return 0.0;
					}
				}
				else
				{
					ClientCommand(client, "playgamesound items/medshotno1.wav");
					ShowGameText(client,"leaderboard_streak", 0, "You do not have enough Dexterity [25]");
					return 0.0;
				}
			}
			else
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Ranged Weapon.");
				return 0.0;
			}
		}

	//	if(kv.GetNum("consume", 1))

	}
	return 0.0;
}

public void Ability_SentryThrow(int client, int level, int weapon)
{
	float damage = Config_GetDPSOfEntity(weapon);
	
	SentryDamage[client] = (damage * 0.3);
	
	DrainRate[client] = 10 - level*2;
	float pos[3];
	float ang[3];
	float vel[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
	GetClientEyeAngles(client, ang);
	pos[2] += 63;
	int team = GetClientTeam(client);

	vel[0] = Cosine(DegToRad(ang[0]))*Cosine(DegToRad(ang[1]))*1000.0;
	vel[1] = Cosine(DegToRad(ang[0]))*Sine(DegToRad(ang[1]))*1000.0;
	vel[2] = Sine(DegToRad(ang[0]))*-1000.0;

	int entity = CreateEntityByName("tf_projectile_pipe_remote");
	if(IsValidEntity(entity))
	{
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(entity, Prop_Send, "m_iTeamNum", team);
		SetEntProp(entity, Prop_Send, "m_bCritical", false);
		SetEntProp(entity, Prop_Send, "m_iType", 1);
	//	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 1.5);
	//	SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", weapon);
	//	SetEntPropEnt(entity, Prop_Send, "m_hLauncher", weapon);
		SetEntPropVector(entity, Prop_Data, "m_vInitialVelocity", vel);

		TeleportEntity(entity, pos, ang, NULL_VECTOR);
		DispatchSpawn(entity);
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vel);

		HasSentry[client] = EntIndexToEntRef(entity);
		EmitSoundToAll("weapons/drg_wrench_teleport.wav", entity, SNDCHAN_WEAPON, 70);

		CreateTimer(0.25, _abilitysentrygrenade, client, TIMER_REPEAT);
	}

}





public Action _abilitysentrygrenade(Handle timer, int client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		int entity = EntRefToEntIndex(HasSentry[client]);
		if(entity>MaxClients && IsValidEntity(entity))
		{
			if(!GetEntProp(entity, Prop_Send, "m_bTouched"))
				return Plugin_Continue;

			static float pos[3], ang[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
			GetClientEyeAngles(client, ang);
			ang[0] = 0.0;
			ang[2] = 0.0;

			RemoveEntity(entity);
			entity = CreateEntityByName("obj_sentrygun");
			if(IsValidEntity(entity))
			{
				DispatchSpawn(entity);

				SetEntProp(entity, Prop_Send, "m_iObjectType", view_as<int>(TFObject_Sentry));
				SetEntProp(entity, Prop_Send, "m_iState", 1);

				SetEntProp(entity, Prop_Send, "m_iTeamNum", GetClientTeam(client));
				SetEntProp(entity, Prop_Send, "m_nSkin", 2);
				SetEntProp(entity, Prop_Send, "m_iUpgradeLevel", 1);
				SetEntProp(entity, Prop_Send, "m_bMiniBuilding", true);

				SetEntPropEnt(entity, Prop_Send, "m_hBuilder", client);
				SetEntProp(entity, Prop_Send, "m_bMiniBuilding", 1);

				SetEntPropFloat(entity, Prop_Send, "m_flPercentageConstructed", 1.0);
				SetEntProp(entity, Prop_Send, "m_bPlayerControlled", false);
				SetEntProp(entity, Prop_Send, "m_bHasSapper", false);
				SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.60);

				TeleportEntity(entity, pos, ang, NULL_VECTOR);

				SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 90001);
				SetEntProp(entity, Prop_Send, "m_iAmmoShells", 75);
				SetEntProp(entity, Prop_Send, "m_iAmmoRockets", 20);
				
				PrecacheModel("models/buildables/sentry1.mdl");
				SetEntityModel(entity, "models/buildables/sentry1.mdl");
				
				int health_building = 50 + (SDKCall_GetMaxHealth(client) / 4);
				
				SetVariantInt(health_building);
				AcceptEntityInput(entity, "SetHealth");

				HasSentry[client] = EntIndexToEntRef(entity);
				CreateTimer(1.0, _abilitysentrydegen, client, TIMER_REPEAT);
				return Plugin_Stop;
			}
		}
	}
	else
	{
		int entity = EntRefToEntIndex(HasSentry[client]);
		if(entity>MaxClients && IsValidEntity(entity))
		{
			RemoveEntity(entity);
		}
			
	}

	HasSentry[client] = 0;
	return Plugin_Stop;
}

public Action _abilitysentrydegen(Handle timer, int client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		int entity = EntRefToEntIndex(HasSentry[client]);
		if(entity>MaxClients && IsValidEntity(entity))
		{
			int ammo = GetEntProp(entity, Prop_Send, "m_iAmmoShells")-DrainRate[client];
			if(ammo > 0)
			{
				SetEntProp(entity, Prop_Send, "m_iAmmoShells", ammo);
				return Plugin_Continue;
			}

			SetVariantInt(99999);
			AcceptEntityInput(entity, "RemoveHealth");
		}
	}
	else
	{
		int entity = EntRefToEntIndex(HasSentry[client]);
		if(entity>MaxClients && IsValidEntity(entity))
		{
			RemoveEntity(entity);
		}
			
	}

	HasSentry[client] = 0;
	return Plugin_Stop;
}