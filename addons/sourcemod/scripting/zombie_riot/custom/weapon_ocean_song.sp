static Handle h_TimerOceanSongManagement[MAXPLAYERS+1] = {null, ...};
static int i_Particle_1[MAXPLAYERS+1];
static int i_Particle_2[MAXPLAYERS+1];
static int i_Particle_3[MAXPLAYERS+1];
static int i_Particle_4[MAXPLAYERS+1];
static int i_Laser_1[MAXPLAYERS+1];
static float f_OceanBuffAbility[MAXPLAYERS+1];
static float f_OceanIndicator[MAXPLAYERS+1];
static float f_OceanIndicatorHud[MAXPLAYERS+1];

static int ColourOcean[MAXPLAYERS+1][4];

#define OCEAN_HEAL_BASE 0.15
#define OCEAN_SOUND "ambient_mp3/lair/cap_1_tone_metal_movement2.mp3"
#define OCEAN_SOUND_MELEE "ambient/water/water_splash1.wav"
//code that starts up a repeat timer upon weapon equip
public void Enable_OceanSong(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{

	if (h_TimerOceanSongManagement[client] != null)
	{

		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_OCEAN || i_CustomWeaponEquipLogic[weapon] == WEAPON_OCEAN_PAP) //11 is for this weapon
		{
			if(i_CustomWeaponEquipLogic[weapon] == WEAPON_OCEAN)
			{
				ColourOcean[client][0] = 255;
				ColourOcean[client][1] = 125;
				ColourOcean[client][2] = 125;
				ColourOcean[client][3] = 200;
			}
			else
			{
				ColourOcean[client][0] = 25;
				ColourOcean[client][1] = 25;
				ColourOcean[client][2] = 240;
				ColourOcean[client][3] = 200;
			}
			ApplyExtraOceanEffects(client, true);
			ApplyExtraOceanEffects(client);
			//Is the weapon it again?
			//Yes?
			delete h_TimerOceanSongManagement[client];
			h_TimerOceanSongManagement[client] = null;
			DataPack pack;
			h_TimerOceanSongManagement[client] = CreateDataTimer(0.1, Timer_Management_OceanSong, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_OCEAN || i_CustomWeaponEquipLogic[weapon] == WEAPON_OCEAN_PAP) //11 is for this weapon
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_OCEAN)
		{
			ColourOcean[client][0] = 255;
			ColourOcean[client][1] = 125;
			ColourOcean[client][2] = 125;
			ColourOcean[client][3] = 200;
		}
		else
		{
			ColourOcean[client][0] = 25;
			ColourOcean[client][1] = 25;
			ColourOcean[client][2] = 240;
			ColourOcean[client][3] = 200;
		}
		ApplyExtraOceanEffects(client, true);
		ApplyExtraOceanEffects(client);
		DataPack pack;
		h_TimerOceanSongManagement[client] = CreateDataTimer(0.1, Timer_Management_OceanSong, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

#define OCEAN_SING_OFFSET_UP 100.0
#define OCEAN_SING_OFFSET_DOWN 25.0

void ResetMapStartOcean()
{
	for( int client = 1; client <= MaxClients; client++ ) 
	{
		ApplyExtraOceanEffects(client, true);
	}
	PrecacheSound(OCEAN_SOUND);
	PrecacheSound(OCEAN_SOUND_MELEE);
	Zero(f_OceanBuffAbility);
	Zero(f_OceanIndicator);
	Zero(f_OceanIndicatorHud);
}

void ConnectTwoEntitiesWithMedibeam(int owner, int target)
{
	int OldParticle = EntRefToEntIndex(i_Particle_1[owner]);
	int OldParticle2 = EntRefToEntIndex(i_Particle_2[owner]);
	if(!IsValidEntity(OldParticle) || !IsValidEntity(OldParticle2))
	{
		return;
	}
	float vecTarget[3];
	
	WorldSpaceCenter(target, vecTarget);
	int particle;
	if(ColourOcean[owner][0] != 25)
	{
		particle = ParticleEffectAtOcean(vecTarget, "medicgun_beam_red", 0.0 , false);
	}
	else
	{
		particle = ParticleEffectAtOcean(vecTarget, "medicgun_beam_blue", 0.0, false);
	}
	
	SetParent(target, particle, "", _, true);

	i_Particle_3[owner] = EntIndexToEntRef(particle);

	CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
	
	WorldSpaceCenter(OldParticle2, vecTarget);

	int particle2;
	if(ColourOcean[owner][0] != 25)
	{
		particle2 = ParticleEffectAtOcean(vecTarget, "medicgun_beam_red", 0.0, false);
	}
	else
	{
		particle2 = ParticleEffectAtOcean(vecTarget, "medicgun_beam_blue", 0.0, false);
	}
	SetParent(OldParticle2, particle2, "", _, true);

	i_Particle_4[owner] = EntIndexToEntRef(particle2);
	CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(particle2), TIMER_FLAG_NO_MAPCHANGE);

	char szCtrlParti[128];
	Format(szCtrlParti, sizeof(szCtrlParti), "tf2ctrlpart%i", EntIndexToEntRef(particle2));
	DispatchKeyValue(particle, "targetname", szCtrlParti);

	DispatchKeyValue(particle2, "cpoint1", szCtrlParti);
	ActivateEntity(particle2);
//	ActivateEntity(particle);
	AcceptEntityInput(particle2, "start");
//	AcceptEntityInput(particle, "start");	


}

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
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);

	if(!IsValidEntity(viewmodelModel))
		return;

	GetAttachment(viewmodelModel, "effect_hand_r", flPos, flAng);

	int particle_1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically

	int particle;
	int particle2;
	if(ColourOcean[client][0] != 25)
	{
		particle = ParticleEffectAtOcean({0.0,0.0,20.0}, "player_dripsred", 0.0 , false);
		particle2 = ParticleEffectAtOcean({0.0,0.0,-40.0}, "medicgun_beam_red", 0.0 , false);

	}
	else
	{
		particle = ParticleEffectAtOcean({0.0,0.0,20.0}, "player_drips_blue", 0.0 , false);
		particle2 = ParticleEffectAtOcean({0.0,0.0,-40.0}, "medicgun_beam_blue", 0.0 , false);
	}
	SetParent(particle_1, particle, "",_, true);
	SetParent(particle_1, particle2, "",_, true);
	Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
	SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(viewmodelModel, particle_1, "effect_hand_r",_);



	char szCtrlParti[128];
	Format(szCtrlParti, sizeof(szCtrlParti), "tf2ctrlpart%i", EntIndexToEntRef(particle2));
	DispatchKeyValue(particle2, "targetname", szCtrlParti);

	DispatchKeyValue(particle2, "cpoint1", szCtrlParti);
	ActivateEntity(particle2);
	ActivateEntity(particle);
	AcceptEntityInput(particle2, "start");
	AcceptEntityInput(particle, "start");

	i_Particle_1[client] = EntIndexToEntRef(particle);
	i_Particle_3[client] = EntIndexToEntRef(particle_1);
	i_Particle_2[client] = EntIndexToEntRef(particle2);


	i_Laser_1[client] = EntIndexToEntRef(ConnectWithBeamClient(particle, particle2, ColourOcean[client][0], ColourOcean[client][01], ColourOcean[client][2], 4.0, 2.0, 1.0, LASERBEAM, client));
}
//main code responsible for checking if the player is alive etc. and actualy giving the buffs
public Action Timer_Management_OceanSong(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		ApplyExtraOceanEffects(client, true);
		h_TimerOceanSongManagement[client] = null;
		return Plugin_Stop;
	}	
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_OCEAN)
		{
			ColourOcean[client][0] = 255;
			ColourOcean[client][1] = 125;
			ColourOcean[client][2] = 125;
			ColourOcean[client][3] = 200;
		}
		else
		{
			ColourOcean[client][0] = 25;
			ColourOcean[client][1] = 25;
			ColourOcean[client][2] = 240;
			ColourOcean[client][3] = 200;
		}
		
		ApplyExtraOceanEffects(client, false);
		DoHealingOcean(client, client,_,_,_, weapon);
		if(f_OceanIndicator[client] < GetGameTime())
		{
			
			f_OceanIndicator[client] = GetGameTime() + 0.25;
			float UserLoc[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", UserLoc);
			spawnRing_Vectors(UserLoc, 400 * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", ColourOcean[client][0], ColourOcean[client][1], ColourOcean[client][2], ColourOcean[client][3], 1, 0.29, 5.0, 1.1, 5, 399.9 * 2.0, client);	
		
			if(f_OceanIndicatorHud[client] < GetGameTime())
			{
				f_OceanIndicatorHud[client] = GetGameTime() + 0.75;
			}
		}
	}
	else
	{
		ApplyExtraOceanEffects(client, true);
	}
		
	return Plugin_Continue;
}

void DoHealingOcean(int client, int target, float range = 160000.0, float extra_heal = 1.0, bool HordingsBuff = false, int weapon = 0)
{
	float BannerPos[3];
	GetEntPropVector(target, Prop_Data, "m_vecOrigin", BannerPos);
	float flHealMulti = 1.0;
	float flHealMutli_Calc;
	if(!HordingsBuff)
	{
		flHealMulti = Attributes_GetOnPlayer(client, 8, true, true);
		if(weapon > 0)
			flHealMulti *= Attributes_Get(weapon, 8, 1.0);
	}
	else
	{
		flHealMulti = 1.0;
	}
	
	float targPos[3];
	for(int ally=1; ally<=MaxClients; ally++)
	{
		if(IsClientInGame(ally) && IsPlayerAlive(ally) && dieingstate[ally] == 0 && TeutonType[ally] == TEUTON_NONE)
		{
			GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
			if (GetVectorDistance(BannerPos, targPos, true) <= range) // 650.0
			{
				float healingMulti = 1.0;

				int weapon2 = GetEntPropEnt(ally, Prop_Send, "m_hActiveWeapon");
				if(IsValidEntity(weapon2))
				{
					if(i_WeaponArchetype[weapon2] == 22)	// Abyssal Hunter
					{
						healingMulti = 1.0825;
					}
				}

				if(healingMulti > 0.0)
				{	
					if(!HordingsBuff && f_TimeUntillNormalHeal[ally] > GetGameTime())
					{
						flHealMutli_Calc = flHealMulti * 0.5;
					}
					else 
					{
						flHealMutli_Calc = flHealMulti;
					} 
					flHealMutli_Calc *= extra_heal * healingMulti;
					HealEntityGlobal(client, ally, OCEAN_HEAL_BASE * flHealMutli_Calc, 1.0);
				}
				if(!HordingsBuff)
				{
					if(f_OceanBuffAbility[client] > GetGameTime())
					{
						ApplyStatusEffect(client, ally, "Oceanic Scream", 0.21);
					}
					else 
					{
						if(!HasSpecificBuff(ally, "Oceanic Scream")) // dont extend
							ApplyStatusEffect(client, ally, "Oceanic Singing", 0.21);
					}
				}
			}
		}
	}
	for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
	{
		int ally = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again]);
		if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == TFTeam_Red)
		{
			GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
			if (GetVectorDistance(BannerPos, targPos, true) <= range)
			{
				if(!HordingsBuff && f_TimeUntillNormalHeal[ally] > GetGameTime())
				{
					flHealMutli_Calc = flHealMulti * 0.5;
				}
				else 
				{
					flHealMutli_Calc = flHealMulti;
				} 
				flHealMutli_Calc *= extra_heal;
				HealEntityGlobal(client, ally, OCEAN_HEAL_BASE * flHealMutli_Calc, 1.0);
				if(!HordingsBuff)
				{
					if(f_OceanBuffAbility[client] > GetGameTime())
					{
						ApplyStatusEffect(client, ally, "Oceanic Scream", 0.21);
					}
					else 
					{
						ApplyStatusEffect(client, ally, "Oceanic Singing", 0.21);
					}
				}
			}
		}
	}
}


stock int ParticleEffectAtOcean(float position[3], const char[] effectName, float duration = 0.1, bool start = true)
{
	int particle = CreateEntityByName("info_particle_system");
	if (particle != -1)
	{
	//	float angle[3];
	//	angle[0] = 90.0;
	//	angle[1] = 90.0;
	//	angle[2] = 90.0;
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
public void Ocean_song_ability(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, 75.0);
		f_OceanBuffAbility[client] = GetGameTime() + 15.0;
		float UserLoc[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", UserLoc);
		spawnRing_Vectors(UserLoc, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt",  ColourOcean[client][0], ColourOcean[client][1], ColourOcean[client][2], ColourOcean[client][3], 1, 2.5, 12.0, 2.1, 5, 650 * 2.0);	
		spawnRing_Vectors(UserLoc, 0.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", ColourOcean[client][0], ColourOcean[client][1], ColourOcean[client][2], ColourOcean[client][3], 1, 2.0, 12.0, 2.1, 5, 650 * 2.0);	
		spawnRing_Vectors(UserLoc, 0.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", ColourOcean[client][0], ColourOcean[client][1], ColourOcean[client][2], ColourOcean[client][3], 1, 1.5, 12.0, 2.1, 5, 650 * 2.0);	
		spawnRing_Vectors(UserLoc, 0.0, 0.0, 0.0, 20.0, "materials/sprites/laserbeam.vmt", ColourOcean[client][0], ColourOcean[client][1], ColourOcean[client][2], ColourOcean[client][3], 1, 1.0, 12.0, 2.1, 5, 650 * 2.0);	
		spawnRing_Vectors(UserLoc, 0.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", ColourOcean[client][0], ColourOcean[client][1], ColourOcean[client][2], ColourOcean[client][3], 1, 0.5, 12.0, 2.1, 5, 650 * 2.0);	
		EmitSoundToAll(OCEAN_SOUND, client, _, 75, _, 1.0);
		EmitSoundToAll(OCEAN_SOUND, client, _, 75, _, 1.0);
		EmitSoundToAll(OCEAN_SOUND, client, _, 75, _, 1.0);
		EmitSoundToAll(OCEAN_SOUND, client, _, 75, _, 1.0);
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
	}

}

#define OCEAN_MELEE_RANGE_DETECTION 300.0

public void Weapon_Ocean_Attack(int client, int weapon, bool crit, int slot)
{		
	float vecSwingForward[3];
	StartPlayerOnlyLagComp(client, true);
	Handle swingTrace;
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, OCEAN_MELEE_RANGE_DETECTION, true); //want to hit only allies!
				
	int target = TR_GetEntityIndex(swingTrace);
	float vecHit[3];
	TR_GetEndPosition(vecHit, swingTrace);	

	delete swingTrace;


	if(IsValidAlly(client, target))
	{
		int pitch = GetRandomInt(90,110);
		EmitSoundToAll(OCEAN_SOUND_MELEE, client, _, 75, _, 1.0, pitch);
		EmitSoundToAll(OCEAN_SOUND_MELEE, target, _, 75, _, 1.0, pitch);
		float UserLoc[3];
		GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", UserLoc);
		spawnRing_Vectors(UserLoc, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", ColourOcean[client][0], ColourOcean[client][1], ColourOcean[client][2], ColourOcean[client][3], 1, 0.5, 6.0, 2.1, 5, 150 * 2.0);	
		DoHealingOcean(client, target, 22500.0, 16.0,_, weapon);
		ConnectTwoEntitiesWithMedibeam(client, target);
	}
	EndPlayerOnlyLagComp(client);
}