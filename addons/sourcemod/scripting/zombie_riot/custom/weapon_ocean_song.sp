static Handle h_TimerOceanSongManagement[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
static int i_Particle_1[MAXPLAYERS+1];
static int i_Particle_2[MAXPLAYERS+1];
static int i_Particle_3[MAXPLAYERS+1];
static int i_Particle_4[MAXPLAYERS+1];
static int i_Laser_1[MAXPLAYERS+1];
static float f_OceanBuffAbility[MAXPLAYERS+1];

#define OCEAN_HEAL_BASE 0.15
#define OCEAN_SOUND "ambient_mp3/lair/cap_1_tone_metal_movement2.mp3"
#define OCEAN_SOUND_MELEE "ambient/water/water_splash1.wav"
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
			h_TimerOceanSongManagement[client] = CreateDataTimer(0.1, Timer_Management_OceanSong, pack, TIMER_REPEAT);
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

void ResetMapStartOcean()
{
	for( int client = 1; client <= MaxClients; client++ ) 
	{
		ApplyExtraOceanEffects(client, true);
	}
	PrecacheSound(OCEAN_SOUND);
	PrecacheSound(OCEAN_SOUND_MELEE);
	Zero(f_OceanBuffAbility);
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
	
	vecTarget = WorldSpaceCenter(target);

	int particle = ParticleEffectAtOcean(vecTarget, "medicgun_beam_red", 0.0 , _, false);
	
	SetParent(target, particle, "", _, true);

	i_Particle_3[owner] = EntIndexToEntRef(particle);

	CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
	
	vecTarget = WorldSpaceCenter(OldParticle2);

	int particle2 = ParticleEffectAtOcean(vecTarget, "medicgun_beam_red", 0.0 , particle, false);
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

	GetBoneAnglesAndPos(viewmodelModel, "effect_hand_r", flPos, flAng);
	flAng[0] += 80.0;

	float vecSwingForward[3];
			
	GetAngleVectors(flAng, vecSwingForward, NULL_VECTOR, NULL_VECTOR);

	float vecSwingEnd[3];
	vecSwingEnd[0] = flPos[0] + (vecSwingForward[0] * OCEAN_SING_OFFSET_DOWN);
	vecSwingEnd[1] = flPos[1] + (vecSwingForward[1] * OCEAN_SING_OFFSET_DOWN);
	vecSwingEnd[2] = flPos[2] + (vecSwingForward[2] * OCEAN_SING_OFFSET_DOWN);

	
	int particle = ParticleEffectAtOcean(vecSwingEnd, "player_dripsred", 0.0 , _, false);


	SetParent(viewmodelModel, particle, "effect_hand_r", _, true);
	i_Particle_1[client] = EntIndexToEntRef(particle);


	//Setup first invis particle here.
	
	GetBoneAnglesAndPos(viewmodelModel, "effect_hand_r", flPos, flAng);
	flAng[0] += 70.0;

	GetAngleVectors(flAng, vecSwingForward, NULL_VECTOR, NULL_VECTOR);

	vecSwingEnd[0] = flPos[0] + (vecSwingForward[0] * OCEAN_SING_OFFSET_UP);
	vecSwingEnd[1] = flPos[1] + (vecSwingForward[1] * OCEAN_SING_OFFSET_UP);
	vecSwingEnd[2] = flPos[2] + (vecSwingForward[2] * OCEAN_SING_OFFSET_UP);

	int particle2 = ParticleEffectAtOcean(vecSwingEnd, "medicgun_beam_red", 0.0 , particle, false);
	SetParent(viewmodelModel, particle2, "effect_hand_r", _, true);

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


	i_Laser_1[client] = EntIndexToEntRef(ConnectWithBeamClient(particle, particle2, 200, 65, 65, 4.0, 2.0, 1.0, LASERBEAM));
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
					DoHealingOcean(client, client);
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
	}
	else
	{
		ApplyExtraOceanEffects(client, true);
		Kill_Timer_Management_OceanSong(client);
	}
		
	return Plugin_Continue;
}

void DoHealingOcean(int client, int target, float range = 160000.0, float extra_heal = 1.0, bool HordingsBuff = false)
{
	float BannerPos[3];
	GetEntPropVector(target, Prop_Data, "m_vecOrigin", BannerPos);
	float flHealMulti = 1.0;
	float flHealMutli_Calc;
	if(!HordingsBuff)
	{
		flHealMulti = Attributes_GetOnPlayer(client, 8, true, true);
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

				int weapon = GetEntPropEnt(ally, Prop_Send, "m_hActiveWeapon");
				if(IsValidEntity(weapon))
				{
					if(Panic_Attack[weapon])
					{
						healingMulti = 0.0;
					}
					else if(i_WeaponArchetype[weapon] == 22)	// Abyssal Hunter
					{
						healingMulti = 1.0825;
					}
				}

				if(healingMulti > 0.0)
				{	
					if(f_TimeUntillNormalHeal[ally] > GetGameTime())
					{
						flHealMutli_Calc = flHealMulti * 0.5;
					}
					else 
					{
						flHealMutli_Calc = flHealMulti;
					} 
					flHealMutli_Calc *= extra_heal * healingMulti;
					int healingdone = HealEntityViaFloat(ally, OCEAN_HEAL_BASE * flHealMutli_Calc, 1.0);
					if(healingdone > 0)
					{
						if(client < MaxClients)
						{
							Healing_done_in_total[client] += healingdone;
						}
						ApplyHealEvent(ally, healingdone);
					}
				}
				if(!HordingsBuff)
				{
					if(f_OceanBuffAbility[client] > GetGameTime())
					{
						f_Ocean_Buff_Stronk_Buff[ally] = GetGameTime() + 0.21;
					}
					else 
					{
						f_Ocean_Buff_Weak_Buff[ally] = GetGameTime() + 0.21;
					}
				}
			}
		}
	}
	for(int entitycount_again; entitycount_again<i_MaxcountNpc_Allied; entitycount_again++)
	{
		int ally = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount_again]);
		if (IsValidEntity(ally) && !b_NpcHasDied[ally])
		{
			GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
			if (GetVectorDistance(BannerPos, targPos, true) <= range)
			{
				if(f_TimeUntillNormalHeal[ally] > GetGameTime())
				{
					flHealMutli_Calc = flHealMulti * 0.5;
				}
				else 
				{
					flHealMutli_Calc = flHealMulti;
				} 
				flHealMutli_Calc *= extra_heal;
				int healingdone = HealEntityViaFloat(ally, OCEAN_HEAL_BASE * flHealMutli_Calc, 1.0);
				if(!HordingsBuff)
				{
					if(f_OceanBuffAbility[client] > GetGameTime())
					{
						f_Ocean_Buff_Stronk_Buff[ally] = GetGameTime() + 0.21;
					}
					else 
					{
						f_Ocean_Buff_Weak_Buff[ally] = GetGameTime() + 0.21;
					}
				}
				if(client < MaxClients)
				{
					Healing_done_in_total[client] += healingdone;
				}
			}
		}
	}
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
/*
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
*/
public void Ocean_song_ability(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, 75.0);
		f_OceanBuffAbility[client] = GetGameTime() + 15.0;
		float UserLoc[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", UserLoc);
		spawnRing_Vectors(UserLoc, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 125, 125, 200, 1, 2.5, 12.0, 2.1, 5, 650 * 2.0);	
		spawnRing_Vectors(UserLoc, 0.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 255, 125, 125, 200, 1, 2.0, 12.0, 2.1, 5, 650 * 2.0);	
		spawnRing_Vectors(UserLoc, 0.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 255, 125, 125, 200, 1, 1.5, 12.0, 2.1, 5, 650 * 2.0);	
		spawnRing_Vectors(UserLoc, 0.0, 0.0, 0.0, 20.0, "materials/sprites/laserbeam.vmt", 255, 125, 125, 200, 1, 1.0, 12.0, 2.1, 5, 650 * 2.0);	
		spawnRing_Vectors(UserLoc, 0.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 255, 125, 125, 200, 1, 0.5, 12.0, 2.1, 5, 650 * 2.0);	
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
		spawnRing_Vectors(UserLoc, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 125, 125, 200, 1, 0.5, 6.0, 2.1, 5, 150 * 2.0);	
		DoHealingOcean(client, target, 22500.0, 8.0);
		ConnectTwoEntitiesWithMedibeam(client, target);
	}
	EndPlayerOnlyLagComp(client);
}