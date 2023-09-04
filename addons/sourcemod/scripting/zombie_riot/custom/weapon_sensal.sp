static Handle h_TimerSensalWeaponManagement[MAXPLAYERS+1] = {INVALID_HANDLE, ...};

#define MAX_SENSAL_ENERGY_EFFECTS 10
#define SENSAL_MELEE_CHARGE_ON_HIT 0.25
#define SENSAL_MELEE_CHARGE_ON_HIT_2 0.1

static int i_SensalEnergyEffect[MAXENTITIES][MAX_SENSAL_ENERGY_EFFECTS];
static float f_SensalAbilityCharge_1[MAXENTITIES];
static float f_SensalAbilityCharge_2[MAXENTITIES];
static float f_Sensalhuddelay[MAXPLAYERS+1]={0.0, ...};
static bool b_ClientPossesBattery[MAXPLAYERS+1]={false, ...};

static char g_SyctheHitSound[][] = {
	"ambient/machines/slicer1.wav",
	"ambient/machines/slicer2.wav",
	"ambient/machines/slicer3.wav",
	"ambient/machines/slicer4.wav",
};

bool IsSensalWeapon(int Index)
{
	if(Index == WEAPON_SENSAL_SCYTHE || Index == WEAPON_SENSAL_SCYTHE_PAP_1 || Index == WEAPON_SENSAL_SCYTHE_PAP_2 || Index == WEAPON_SENSAL_SCYTHE_PAP_3)
		return true;

	return false;
}
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
		if(IsSensalWeapon(i_CustomWeaponEquipLogic[weapon]))
		{
			b_ClientPossesBattery[client] = Items_HasNamedItem(client, "Expidonsan Battery Device");
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
		
	if(IsSensalWeapon(i_CustomWeaponEquipLogic[weapon]))
	{
		b_ClientPossesBattery[client] = Items_HasNamedItem(client, "Expidonsan Battery Device");
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
	for (int i = 0; i < (sizeof(g_SyctheHitSound));   i++) { PrecacheSound(g_SyctheHitSound[i]);   }
	Zero(f_Sensalhuddelay);
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
		SensalWeaponEffects(client, client, viewmodelModel, "effect_hand_r");
	}
}

public void Sensal_Ability_M2(int client, int weapon, bool crit, int slot) // the main ability used to recover the unique mana needed to for the weapon to fire projectiles
{
	if (Ability_Check_Cooldown(client, slot) < 0.0 || CvarInfiniteCash.BoolValue)
	{
		if(f_SensalAbilityCharge_1[client] >= 0.5 || CvarInfiniteCash.BoolValue)
		{
			Rogue_OnAbilityUse(weapon);
			Ability_Apply_Cooldown(client, slot, 0.5);
			SummonScytheSensalProjectile(client, weapon);
			f_SensalAbilityCharge_1[client] -= 0.5;
			if(f_SensalAbilityCharge_1[client] < 0.0)
			{
				f_SensalAbilityCharge_1[client] = 0.0;
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Sensal Scythes Not Fully Charged");	
		}
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

public void Sensal_Ability_R_Laser(int client, int weapon, bool crit, int slot) // the main ability used to recover the unique mana needed to for the weapon to fire projectiles
{
	if (Ability_Check_Cooldown(client, slot) < 0.0 || CvarInfiniteCash.BoolValue)
	{
		if(f_SensalAbilityCharge_2[client] >= 1.0 || CvarInfiniteCash.BoolValue)
		{
			Rogue_OnAbilityUse(weapon);
			Ability_Apply_Cooldown(client, slot, 1.0);
			f_SensalAbilityCharge_2[client] -= 1.0;
			if(f_SensalAbilityCharge_2[client] < 0.0)
			{
				f_SensalAbilityCharge_2[client] = 0.0;
			}
			float fAng[3];
			float flPos[3];
			GetClientEyeAngles(client, fAng);
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
			fAng[0] = 0.0;
			
			float damage = 500.0;

			damage *= Attributes_Get(weapon, 2, 1.0);
					
			b_LagCompNPC_No_Layers = true;
			StartLagCompensation_Base_Boss(client);

			Handle swingTrace;
			float vecSwingForward[3];
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9999.9, false, 45.0, true); //infinite range, and ignore walls!
						
			int foundTarget = TR_GetEntityIndex(swingTrace);	
			delete swingTrace;
			if(foundTarget <= 0)
			{
				foundTarget = -1;
			}
			FinishLagCompensation_Base_boss();

			int spawn_index = Npc_Create(WEAPON_SENSAL_AFTERIMAGE, client, flPos, fAng, GetEntProp(client, Prop_Send, "m_iTeamNum") == 2);
			if(spawn_index > 0)
			{
				//this is the damage
				i_Target[spawn_index] = foundTarget;
				fl_heal_cooldown[spawn_index] = damage;
				i_Changed_WalkCycle[spawn_index] = EntIndexToEntRef(weapon);
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Sensal Scythes Not Fully Charged");	
		}
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
					SensalTimerHudShow(client, weapon);
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

void SensalTimerHudShow(int client, int weapon)
{
	if(f_Sensalhuddelay[client] < GetGameTime())
	{
		f_Sensalhuddelay[client] = GetGameTime() + 0.5;
		switch(i_CustomWeaponEquipLogic[weapon])
		{
			case WEAPON_SENSAL_SCYTHE:
			{
				return;
			}
			case WEAPON_SENSAL_SCYTHE_PAP_1, WEAPON_SENSAL_SCYTHE_PAP_2:
			{
				char SensalHud[255];
				if(f_SensalAbilityCharge_1[client] >= (b_ClientPossesBattery[client] ? 2.0 : 1.0))
				{
					FormatEx(SensalHud, sizeof(SensalHud), "%sScythe Summoning [READY]",SensalHud);		
				}
				else
				{
					if(b_ClientPossesBattery[client])
					{
						FormatEx(SensalHud, sizeof(SensalHud), "%sScythe Summoning [%.0f％ / 200％]",SensalHud, f_SensalAbilityCharge_1[client] * 100.0);		
					}
					else
					{
						FormatEx(SensalHud, sizeof(SensalHud), "%sScythe Summoning [%.0f％ / 100％]",SensalHud, f_SensalAbilityCharge_1[client] * 100.0);	
					}
				}
				PrintHintText(client, "%s", SensalHud);
				StopSound(client, SNDCHAN_STATIC, "ui/hint.wav");
			}
			case WEAPON_SENSAL_SCYTHE_PAP_3:
			{
				char SensalHud[255];
				if(f_SensalAbilityCharge_1[client] >= (b_ClientPossesBattery[client] ? 2.0 : 1.0))
				{
					if(b_ClientPossesBattery[client])
						FormatEx(SensalHud, sizeof(SensalHud), "%sScythe Summoning [READY x2]",SensalHud);
					else		
						FormatEx(SensalHud, sizeof(SensalHud), "%sScythe Summoning [READY]",SensalHud);
				}
				else
				{
					if(b_ClientPossesBattery[client])
					{
						FormatEx(SensalHud, sizeof(SensalHud), "%sScythe Summoning [%.0f％ / 200％]",SensalHud, f_SensalAbilityCharge_1[client] * 100.0);		
					}
					else
					{
						FormatEx(SensalHud, sizeof(SensalHud), "%sScythe Summoning [%.0f％ / 100％]",SensalHud, f_SensalAbilityCharge_1[client] * 100.0);	
					}
				}

				
				if(f_SensalAbilityCharge_2[client] >= (b_ClientPossesBattery[client] ? 2.0 : 1.0))
				{
					if(b_ClientPossesBattery[client])
						FormatEx(SensalHud, sizeof(SensalHud), "%s\nLasering Afterimage [READY x2]",SensalHud);
					else		
						FormatEx(SensalHud, sizeof(SensalHud), "%s\nLasering Afterimage [READY]",SensalHud);
				}
				else
				{
					if(b_ClientPossesBattery[client])
					{
						FormatEx(SensalHud, sizeof(SensalHud), "%s\nLasering Afterimage [%.0f％ / 200％]",SensalHud, f_SensalAbilityCharge_2[client] * 100.0);		
					}
					else
					{
						FormatEx(SensalHud, sizeof(SensalHud), "%s\nLasering Afterimage [%.0f％ / 100％]",SensalHud, f_SensalAbilityCharge_2[client] * 100.0);	
					}
				}
				PrintHintText(client, "%s", SensalHud);
				StopSound(client, SNDCHAN_STATIC, "ui/hint.wav");
			}
		}
	}
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

void SensalWeaponEffects(int owner, int client, int Wearable, char[] attachment = "effect_hand_r")
{
	int red = 125;
	int green = 125;
	int blue = 255;
	bool RecolourToRed = b_ClientPossesBattery[owner];
	if(RecolourToRed)
	{
		red = 255;
		green = 125;
		blue = 125;
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


void WeaponSensal_Scythe_OnTakeDamage(int attacker, int victim,int weapon, int zr_damage_custom)
{
	if(zr_damage_custom & ZR_DAMAGE_REFLECT_LOGIC)
		return;

	f_SensalAbilityCharge_1[attacker] += SENSAL_MELEE_CHARGE_ON_HIT;
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SENSAL_SCYTHE_PAP_2)
		f_SensalAbilityCharge_1[attacker] += SENSAL_MELEE_CHARGE_ON_HIT * 0.5;

	if(b_thisNpcIsABoss[victim])
	{
		f_SensalAbilityCharge_1[attacker] += SENSAL_MELEE_CHARGE_ON_HIT * 0.25;
	}
	if(b_thisNpcIsARaid[victim])
	{
		f_SensalAbilityCharge_1[attacker] += SENSAL_MELEE_CHARGE_ON_HIT * 0.5;
	}

	if(f_SensalAbilityCharge_1[attacker] > (b_ClientPossesBattery[attacker] ? 2.0 : 1.0))
	{
		f_SensalAbilityCharge_1[attacker] = (b_ClientPossesBattery[attacker] ? 2.0 : 1.0);
	}

	f_SensalAbilityCharge_2[attacker] += SENSAL_MELEE_CHARGE_ON_HIT_2;
	if(b_thisNpcIsABoss[victim])
	{
		f_SensalAbilityCharge_2[attacker] += SENSAL_MELEE_CHARGE_ON_HIT_2 * 0.25;
	}
	if(b_thisNpcIsARaid[victim])
	{
		f_SensalAbilityCharge_2[attacker] += SENSAL_MELEE_CHARGE_ON_HIT_2 * 0.5;
	}

	if(f_SensalAbilityCharge_2[attacker] > (b_ClientPossesBattery[attacker] ? 2.0 : 1.0))
	{
		f_SensalAbilityCharge_2[attacker] = (b_ClientPossesBattery[attacker] ? 2.0 : 1.0);
	}
}

void SummonScytheSensalProjectile(int client, int weapon)
{
	float damage = 40.0;

	damage *= Attributes_Get(weapon, 2, 1.0);
		
	float speed = 500.0;

	speed *= Attributes_Get(weapon, 103, 1.0);

	speed *= Attributes_Get(weapon, 104, 1.0);

	speed *= Attributes_Get(weapon, 475, 1.0);


	float time = 3000.0/speed;
	time *= Attributes_Get(weapon, 101, 1.0);

	time *= Attributes_Get(weapon, 102, 1.0);

	float Pos_player[3];
	Pos_player = WorldSpaceCenter(client);
	
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);

	Handle swingTrace;
	float vecSwingForward[3];
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9999.9, false, 45.0, true); //infinite range, and ignore walls!
				
	int target = TR_GetEntityIndex(swingTrace);	
	delete swingTrace;
	if(target <= 0)
	{
		target = -1;
	}
	FinishLagCompensation_Base_boss();
	
	float fAng[3];
	GetClientEyeAngles(client, fAng);
	fAng[0] = 0.0;
	FakeClientCommand(client, "voicemenu 2 1"); //battle cry!
	float RingSpawnVec[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", RingSpawnVec);
	RingSpawnVec[2] += 5.0;
	int red = 125;
	int green = 125;
	int blue = 255;
	bool RecolourToRed = b_ClientPossesBattery[client];
	if(RecolourToRed)
	{
		red = 255;
		green = 125;
		blue = 125;
	}
	spawnRing_Vectors(RingSpawnVec, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", red, green, blue, 200, 1, 0.25, 6.0, 2.1, 1, 65.0 * 2.0);	
	EmitSoundToAll("weapons/mortar/mortar_explode3.wav", client, SNDCHAN_AUTO, 80, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, Pos_player);	
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SENSAL_SCYTHE_PAP_2 || i_CustomWeaponEquipLogic[weapon] == WEAPON_SENSAL_SCYTHE_PAP_3)
	{
		for(int Repeat; Repeat <= 2; Repeat++)
		{
			int projectile = Wand_Projectile_Spawn(client, speed, 0.0, damage, WEAPON_SENSAL_SCYTHE, weapon, "", fAng, _ , Pos_player);
			SensalWeaponEffects(client, projectile, projectile, "");
			CreateTimer(time, Timer_RemoveEntityWeaponSensal, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(0.0, TimerRotateMainEffect, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			
			Initiate_HomingProjectile(projectile,
			client,
				90.0,			// float lockonAngleMax,
				45.0,				//float homingaSec,
				false,				// bool LockOnlyOnce,
				false,				// bool changeAngles,
				fAng,
				target);			// float AnglesInitiate[3]);
			
			if(Repeat == 0)
			{
				fAng[1] -= 50.0;
			}
			else if(Repeat == 1)
			{
				fAng[1] += (50.0 * 2.0);
			}
			else
			{
				fAng[1] += 50.0;
			}
		}		
	}
	else
	{
		fAng[1] += 45.0;
		for(int Repeat; Repeat <= 1; Repeat++)
		{
			int projectile = Wand_Projectile_Spawn(client, speed, 0.0, damage, WEAPON_SENSAL_SCYTHE, weapon, "", fAng, _ , Pos_player);
			SensalWeaponEffects(client, projectile, projectile, "");
			CreateTimer(time, Timer_RemoveEntityWeaponSensal, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(0.0, TimerRotateMainEffect, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			
			Initiate_HomingProjectile(projectile,
			client,
				90.0,			// float lockonAngleMax,
				45.0,				//float homingaSec,
				false,				// bool LockOnlyOnce,
				false,				// bool changeAngles,
				fAng,
				target);			// float AnglesInitiate[3]);
			fAng[1] -= 90.0;
		}
	}
}


public Action Timer_RemoveEntityWeaponSensal(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity))
	{
		int Particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(Particle))
		{
			RemoveEntity(Particle);
		}
		SensalWeaponRemoveEffects(entity);
		RemoveEntity(entity);
		
	}
	return Plugin_Stop;
}

public void Weapon_Sensal_WandTouch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		angles = GetRocketAngles(entity);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		Entity_Position = WorldSpaceCenter(target);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		SensalWeaponRemoveEffects(entity);
		EmitSoundToAll(g_SyctheHitSound[GetRandomInt(0, sizeof(g_SyctheHitSound) - 1)], entity, SNDCHAN_AUTO, 80, _, 0.8);
		
		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		if(owner < 0)
			owner = 0;
			
		TE_Particle(b_ClientPossesBattery[owner] ? "spell_batball_impact_red" : "spell_batball_impact_blue", ProjectileLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);

		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_CLUB, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position,_,ZR_DAMAGE_REFLECT_LOGIC);	// 2048 is DMG_NOGIB?
		
		
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		SensalWeaponRemoveEffects(entity);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
}