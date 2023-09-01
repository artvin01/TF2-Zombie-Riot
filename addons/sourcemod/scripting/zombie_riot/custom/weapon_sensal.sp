static Handle h_TimerSensalWeaponManagement[MAXPLAYERS+1] = {INVALID_HANDLE, ...};

#define MAX_SENSAL_ENERGY_EFFECTS 10

int i_SensalEnergyEffect[MAXENTITIES][MAX_SENSAL_ENERGY_EFFECTS];

void SensalWeaponRemoveEffects(int iNpc)
{
	for(int loop = 0; loop<MAX_SENSAL_ENERGY_EFFECTS; loop++)
	{
		int entity = EntRefToEntIndex(i_SensalEnergyEffect[iNpc][loop]);
		if(IsValidEntity(entity))
		{
			RemoveEntity(entity);
		}
		i_SensalEnergyEffect[iNpc][loop] = INVALID_ENT_REFERENCE;
	}
}

bool SensalWeaponCheckEffects_IfNotAvaiable(int iNpc)
{
	for(int loop = 0; loop<MAX_SENSAL_ENERGY_EFFECTS; loop++)
	{
		int entity = EntRefToEntIndex(i_SensalEnergyEffect[iNpc][loop]);
		if(!IsValidEntity(entity))
		{
			return true;
		}
	}
	return false;
}


#define SensalWeapon_SOUND "ambient_mp3/lair/cap_1_tone_metal_movement2.mp3"
#define SensalWeapon_SOUND_MELEE "ambient/water/water_splash1.wav"
//code that starts up a repeat timer upon weapon equip
public void Enable_SensalWeapon(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerSensalWeaponManagement[client] != INVALID_HANDLE)
	{

		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SENSAL_SCYTHE)
		{
			ApplyExtraSensalWeaponEffects(client);
			//Is the weapon it again?
			//Yes?
			KillTimer(h_TimerSensalWeaponManagement[client]);
			h_TimerSensalWeaponManagement[client] = INVALID_HANDLE;
			DataPack pack;
			h_TimerSensalWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_SensalWeapon, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SENSAL_SCYTHE)
	{
		ApplyExtraSensalWeaponEffects(client);
		DataPack pack;
		h_TimerSensalWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_SensalWeapon, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

void ResetMapStartSensalWeapon()
{
	for( int client = 1; client <= MaxClients; client++ ) 
	{
		ApplyExtraSensalWeaponEffects(client, true);
	}
	PrecacheSound(SensalWeapon_SOUND);
	PrecacheSound(SensalWeapon_SOUND_MELEE);
}

void ApplyExtraSensalWeaponEffects(int client, bool remove = false)
{
	if(remove)
	{
		SensalWeaponRemoveEffects(client);
		return;
	}
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);

	if(!IsValidEntity(viewmodelModel))
	{
		SensalWeaponRemoveEffects(client);
		return;
	}

	if(SensalWeaponCheckEffects_IfNotAvaiable(client))
	{
		SensalWeaponRemoveEffects(client);
		SensalWeaponEffects(client, viewmodelModel, 0, "effect_hand_r");
	}
}
//main code responsible for checking if the player is alive etc. and actualy giving the buffs
public Action Timer_Management_SensalWeapon(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if (IsClientInGame(client))
	{
		if (IsPlayerAlive(client))
		{
			if(IsValidEntity(weapon))
			{
				int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
				{
					ApplyExtraSensalWeaponEffects(client, false);
					
				}
				else
				{
					ApplyExtraSensalWeaponEffects(client, true);
				}
			}
			else
			{
				ApplyExtraSensalWeaponEffects(client, true);
				Kill_Timer_Management_SensalWeapon(client);
			}
		}
		else
		{
			ApplyExtraSensalWeaponEffects(client, true);
			Kill_Timer_Management_SensalWeapon(client);
		}
	}
	else
	{
		ApplyExtraSensalWeaponEffects(client, true);
		Kill_Timer_Management_SensalWeapon(client);
	}
		
	return Plugin_Continue;
}

public void Kill_Timer_Management_SensalWeapon(int client)
{
	if (h_TimerSensalWeaponManagement[client] != INVALID_HANDLE)
	{
		ApplyExtraSensalWeaponEffects(client, true);
		KillTimer(h_TimerSensalWeaponManagement[client]);
		h_TimerSensalWeaponManagement[client] = INVALID_HANDLE;
	}
}

void SensalWeaponEffects(int client, int Wearable, int colour = 0, char[] attachment = "effect_hand_r")
{
	int red = 35;
	int green = 35;
	int blue = 255;
	if(colour == 1)
	{
		red = 255;
		green = 35;
		blue = 35;
	}
	float flPos[3];
	float flAng[3];
	if(attachment[0])
	{
		GetAttachment(Wearable, "effect_hand_r", flPos, flAng);
	}
	else
	{
		
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
	}
	int particle_1 = ParticleEffectAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	int particle_2;
	int particle_3;
	int particle_4;
	int particle_5;
	if(attachment[0])
	{
		
		particle_2 = ParticleEffectAt({0.0,0.0,19.5}, "", 0.0); //First offset we go by
		particle_3 = ParticleEffectAt({0.0,0.0,-65.0}, "", 0.0); //First offset we go by
		particle_4 = ParticleEffectAt({0.0,22.75,-65.0}, "", 0.0); //First offset we go by
		particle_5 = ParticleEffectAt({0.0,45.5,-55.25}, "", 0.0); //First offset we go by

	}
	else
	{
		particle_2 = ParticleEffectAt({0.0,16.0,0.0}, "", 0.0); //First offset we go by
		particle_3 = ParticleEffectAt({0.0,-26.0,0.0}, "", 0.0); //First offset we go by
		particle_4 = ParticleEffectAt({7.8,-26.0,0.0}, "", 0.0); //First offset we go by
		particle_5 = ParticleEffectAt({22.75,-19.5,0.0}, "", 0.0); //First offset we go by
	}
	int particle_6;

	if(attachment[0])
	{
		particle_6 = ParticleEffectAt({0.0,65.0,-45.5}, "", 0.0); //First offset we go by
	}
	else
	{
		particle_6 = ParticleEffectAt({32.5,-16.5,0.0}, "", 0.0); //First offset we go by
	}

	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_1, particle_3, "",_, true);
	SetParent(particle_1, particle_4, "",_, true);
	SetParent(particle_1, particle_5, "",_, true);
	SetParent(particle_1, particle_6, "",_, true);

	Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
	SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(Wearable, particle_1, attachment,_);


	int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, 4.0, 4.0, 1.0, LASERBEAM);
	int Laser_2 = ConnectWithBeamClient(particle_3, particle_4, red, green, blue, 4.0, 4.0, 1.0, LASERBEAM);
	int Laser_3 = ConnectWithBeamClient(particle_4, particle_5, red, green, blue, 4.0, 3.0, 1.0, LASERBEAM);
	int Laser_4 = ConnectWithBeamClient(particle_5, particle_6, red, green, blue, 3.0, 2.0, 1.0, LASERBEAM);
	

	i_SensalEnergyEffect[client][0] = EntIndexToEntRef(particle_1);
	i_SensalEnergyEffect[client][1] = EntIndexToEntRef(particle_2);
	i_SensalEnergyEffect[client][2] = EntIndexToEntRef(particle_3);
	i_SensalEnergyEffect[client][3] = EntIndexToEntRef(particle_4);
	i_SensalEnergyEffect[client][4] = EntIndexToEntRef(particle_5);
	i_SensalEnergyEffect[client][5] = EntIndexToEntRef(particle_6);
	i_SensalEnergyEffect[client][6] = EntIndexToEntRef(Laser_1);
	i_SensalEnergyEffect[client][7] = EntIndexToEntRef(Laser_2);
	i_SensalEnergyEffect[client][8] = EntIndexToEntRef(Laser_3);
	i_SensalEnergyEffect[client][9] = EntIndexToEntRef(Laser_4);
}