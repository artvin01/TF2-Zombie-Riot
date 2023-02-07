Handle h_TimerOceanSongManagement[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
int i_Particle_1[MAXPLAYERS+1];
int i_Particle_2[MAXPLAYERS+1];
int i_Particle_3[MAXPLAYERS+1];
int i_Particle_4[MAXPLAYERS+1];
int i_Laser_1[MAXPLAYERS+1];

#define LASERBEAM "sprites/laserbeam.vmt"

//code that starts up a repeat timer upon weapon equip
public void Enable_OceanSong(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(i_CustomWeaponEquipLogic[weapon] == 11) //11 is for this weapon
	{
		SetEntPropFloat(weapon, Prop_Send, "m_flModelScale", 0.001);
	}

	if (h_TimerOceanSongManagement[client] != INVALID_HANDLE)
	{

		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == 11) //11 is for this weapon
		{
			ApplyExtraOceanEffects(client);
			//Is the weapon it again?
			//Yes?
			KillTimer(h_TimerOceanSongManagement[client]);
			h_TimerOceanSongManagement[client] = INVALID_HANDLE;
			DataPack pack;
			h_TimerOceanSongManagement[client] = CreateDataTimer(0.1, Timer_Management_OceanSong, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == 11) //11 is for this weapon
	{
		ApplyExtraOceanEffects(client);
		DataPack pack;
		h_TimerOceanSongManagement[client] = CreateDataTimer(0.1, Timer_Management_OceanSong, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

#define OCEAN_SING_OFFSET_UP 100.0
#define OCEAN_SING_OFFSET_DOWN 25.0

void ApplyExtraOceanEffects(int client, bool remove = false)
{
	bool do_new = true;
	static float flPos[3];
	static float flAng[3];
	int OldParticle1 = EntRefToEntIndex(i_Particle_1[client]);
	int OldParticle2 = EntRefToEntIndex(i_Particle_2[client]);
	int OldParticle3 = EntRefToEntIndex(i_Particle_3[client]);
	int OldParticle4 = EntRefToEntIndex(i_Particle_4[client]);
	int OldLaser1 = EntRefToEntIndex(i_Laser_1[client]);
	if(IsValidEntity(OldParticle1))
	{
		do_new = false;
	}
	if(IsValidEntity(OldParticle2))
	{
		do_new = false;
	}
	if(IsValidEntity(OldParticle3))
	{
		do_new = false;
	}
	if(IsValidEntity(OldParticle4))
	{
		do_new = false;
	}
	if(IsValidEntity(OldLaser1))
	{
		do_new = false;
	}
	if(remove)
	{
		if(IsValidEntity(OldParticle1))
		{
			RemoveEntity(OldParticle1);
		}
		if(IsValidEntity(OldParticle2))
		{
			RemoveEntity(OldParticle2);
		}
		if(IsValidEntity(OldParticle3))
		{
			RemoveEntity(OldParticle3);
		}
		if(IsValidEntity(OldParticle4))
		{
			RemoveEntity(OldParticle4);
		}
		if(IsValidEntity(OldLaser1))
		{
			RemoveEntity(OldLaser1);
		}
		return;
	}		
	if(do_new)
	{
		if(IsValidEntity(OldParticle1))
		{
			RemoveEntity(OldParticle1);
		}
		if(IsValidEntity(OldParticle2))
		{
			RemoveEntity(OldParticle2);
		}
		if(IsValidEntity(OldParticle3))
		{
			RemoveEntity(OldParticle3);
		}
		if(IsValidEntity(OldParticle4))
		{
			RemoveEntity(OldParticle4);
		}
		if(IsValidEntity(OldLaser1))
		{
			RemoveEntity(OldLaser1);
		}
	}
	else
	{
		return;
	}
	GetBoneAnglesAndPos(client, "effect_hand_r", flPos, flAng);
	flAng[0] += 80.0;

	float vecSwingForward[3];
			
	GetAngleVectors(flAng, vecSwingForward, NULL_VECTOR, NULL_VECTOR);

	float vecSwingEnd[3];
	vecSwingEnd[0] = flPos[0] + (vecSwingForward[0] * OCEAN_SING_OFFSET_DOWN);
	vecSwingEnd[1] = flPos[1] + (vecSwingForward[1] * OCEAN_SING_OFFSET_DOWN);
	vecSwingEnd[2] = flPos[2] + (vecSwingForward[2] * OCEAN_SING_OFFSET_DOWN);

	
	int particle = ParticleEffectAtOcean(vecSwingEnd, "player_drips_blue", 0.0 , _, false);


	SetParent(client, particle, "effect_hand_r", _, true);
	i_Particle_1[client] = EntIndexToEntRef(particle);


	//Setup first invis particle here.
	
	GetBoneAnglesAndPos(client, "effect_hand_r", flPos, flAng);
	flAng[0] += 70.0;

	GetAngleVectors(flAng, vecSwingForward, NULL_VECTOR, NULL_VECTOR);

	vecSwingEnd[0] = flPos[0] + (vecSwingForward[0] * OCEAN_SING_OFFSET_UP);
	vecSwingEnd[1] = flPos[1] + (vecSwingForward[1] * OCEAN_SING_OFFSET_UP);
	vecSwingEnd[2] = flPos[2] + (vecSwingForward[2] * OCEAN_SING_OFFSET_UP);

	int particle2 = ParticleEffectAtOcean(vecSwingEnd, "medicgun_beam_blue", 0.0 , particle, false);
	SetParent(client, particle2, "effect_hand_r", _, true);

	char szCtrlParti[128];
	Format(szCtrlParti, sizeof(szCtrlParti), "tf2ctrlpart%i", EntIndexToEntRef(particle2));
	DispatchKeyValue(particle2, "targetname", szCtrlParti);

	DispatchKeyValue(particle2, "cpoint1", szCtrlParti);
	ActivateEntity(particle2);
	ActivateEntity(particle);
	AcceptEntityInput(particle2, "start");
	AcceptEntityInput(particle, "start");
//	AttachParticleOceanCustom(particle,"medicgun_beam_blue",particle2, client); 

	i_Particle_2[client] = EntIndexToEntRef(particle2);


	i_Laser_1[client] = EntIndexToEntRef(ConnectWithBeamClient(particle, particle2, 65, 65, 200, 4.0, 2.0, 1.0, LASERBEAM));
}
//main code responsible for checking if the player is alive etc. and actualy giving the buffs
public Action Timer_Management_OceanSong(Handle timer, DataPack pack)
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
					ApplyExtraOceanEffects(client, false);
					float BannerPos[3];
					GetClientAbsOrigin(client, BannerPos);
					for(int ally=1; ally<=MaxClients; ally++)
					{
						if(IsClientInGame(ally) && IsPlayerAlive(ally))
						{
							float targPos[3];
							GetClientAbsOrigin(ally, targPos);
							if (GetVectorDistance(BannerPos, targPos, true) <= 160000.0) // 650.0
							{
								TF2_AddCondition(ally, TFCond_RuneRegen, 0.5, client); //So if they go out of range, they'll keep it abit
								i_ExtraPlayerPoints[client] += 1;
							}
						}
					}
				}
				else
				{
					ApplyExtraOceanEffects(client, true);
				}
			}
			else
			{
				ApplyExtraOceanEffects(client, true);
			}
		}
		else
		{
			ApplyExtraOceanEffects(client, true);
			Kill_Timer_Management_OceanSong(client);
		}
	}
	else
	{
		ApplyExtraOceanEffects(client, true);
		Kill_Timer_Management_OceanSong(client);
	}
		
	return Plugin_Continue;
}

public void Kill_Timer_Management_OceanSong(int client)
{
	if (h_TimerOceanSongManagement[client] != INVALID_HANDLE)
	{
		ApplyExtraOceanEffects(client, true);
		KillTimer(h_TimerOceanSongManagement[client]);
		h_TimerOceanSongManagement[client] = INVALID_HANDLE;
	}
}

stock int ParticleEffectAtOcean(float position[3], const char[] effectName, float duration = 0.1, int attach = 0, bool start = true)
{
	int particle = CreateEntityByName("info_particle_system");
	if (particle != -1)
	{
		TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(particle, "targetname", "rpg_fortress");
		DispatchKeyValue(particle, "effect_name", effectName);
		DispatchSpawn(particle);

		if(start)
		{
			ActivateEntity(particle);
			AcceptEntityInput(particle, "start");
		}
		SetEdictFlags(particle, (GetEdictFlags(particle) & ~FL_EDICT_ALWAYS));	
		if (duration > 0.0)
			CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
	}
	return particle;
}

void AttachParticleOceanCustom(int ent, char[] particleType,int controlpoint, int client)
{
	int particle  = CreateEntityByName("info_particle_system");
	int particle2 = CreateEntityByName("info_particle_system");
	if (IsValidEdict(particle))
	{ 
		char tName[128];
		Format(tName, sizeof(tName), "target%i", ent);
		DispatchKeyValue(ent, "targetname", tName);
		
		char cpName[128];
		Format(cpName, sizeof(cpName), "target%i", controlpoint);
		DispatchKeyValue(controlpoint, "targetname", cpName);
		
		//--------------------------------------
		char cp2Name[128];
		Format(cp2Name, sizeof(cp2Name), "tf2particle%i", controlpoint);
		
		DispatchKeyValue(particle2, "targetname", cp2Name);
		DispatchKeyValue(particle2, "parentname", cpName);
		
		float VecOrigin[3];
		GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", VecOrigin);
		TeleportEntity(particle2, VecOrigin, NULL_VECTOR, NULL_VECTOR);

		
		SetVariantString(cpName);
		AcceptEntityInput(particle2, "SetParent");
		
	//	SetVariantString("");
	//	AcceptEntityInput(particle2, "SetParentAttachment");
		//-----------------------------------------------
		
		
		DispatchKeyValue(particle, "targetname", "tf2particle");
		DispatchKeyValue(particle, "parentname", tName);
		DispatchKeyValue(particle, "effect_name", particleType);
		DispatchKeyValue(particle, "cpoint1", cp2Name);
		
		DispatchSpawn(particle);

		GetEntPropVector(controlpoint, Prop_Data, "m_vecAbsOrigin", VecOrigin);
		TeleportEntity(particle, VecOrigin, NULL_VECTOR, NULL_VECTOR);

		SetVariantString(tName);
		AcceptEntityInput(particle, "SetParent");
		
	//	SetVariantString("");
	//	AcceptEntityInput(particle, "SetParentAttachment");
		
		//The particle is finally ready
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
	}
	i_Particle_3[client] = EntIndexToEntRef(particle);
	i_Particle_4[client] = EntIndexToEntRef(particle2);
} 