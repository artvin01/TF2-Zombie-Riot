static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};
static int Attack3AbilitySlotArray[MAXPLAYERS+1]={0, ...};
static float f_HealDelay[MAXENTITIES];
static float f_Duration[MAXENTITIES];
static int g_ProjectileModel;
static int g_ProjectileModelArmor;
static int g_BeamIndex_heal = -1;

//#define ARROW_TRAIL_GRENADE "effects/arrowtrail_blu.vmt"

//int trail = Trail_Attach(entity, ARROW_TRAIL_GRENADE, 255, 0.3, 3.0, 3.0, 5);


#define SOUND_HEAL_BEAM			"items/medshot4.wav"
#define SOUND_ARMOR_BEAM			"physics/metal/metal_box_strain1.wav"

#define SOUND_DASH			"npc/roller/mine/rmine_explode_shock1.wav"

public void M3_Abilities_Precache()
{
//	PrecacheModel(ARROW_TRAIL_GRENADE);
//	PrecacheDecal(ARROW_TRAIL_GRENADE, true);
	static char model[PLATFORM_MAX_PATH];
	model = "models/healthvial.mdl";
	g_ProjectileModel = PrecacheModel(model);
	model = "models/Items/battery.mdl";
	g_ProjectileModelArmor = PrecacheModel(model);
	g_BeamIndex_heal = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	PrecacheSound(SOUND_HEAL_BEAM);
	PrecacheSound(SOUND_ARMOR_BEAM);
	PrecacheSound(SOUND_DASH);
	
}
public void M3_ClearAll()
{
	Zero(ability_cooldown);
	Zero(Attack3AbilitySlotArray);
	Zero(f_HealDelay);
	Zero(f_Duration);
}

public void M3_Abilities(int client)
{
	switch(Attack3AbilitySlotArray[client])
	{
		case 1:
		{
			PlaceableTempomaryHealingGrenade(client);
		}
		case 2:
		{
			WeakDash(client);
		}
		case 3:
		{
			PlaceableTempomaryArmorGrenade(client);
		}
	}
}
public void WeakDash(int client)
{
	if (ability_cooldown[client] < GetGameTime())
	{
		ability_cooldown[client] = GetGameTime() + 120.0;
		
		EmitSoundToAll(SOUND_DASH, client, _, 70, _, 1.0);
		
		static float EntLoc[3];
		
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", EntLoc);
		
		SpawnSmallExplosion(EntLoc);
		
		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		float knockback = 750.0;
		
		ScaleVector(velocity, knockback);
		if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			velocity[2] = fmax(velocity[2], 300.0);
		else
			velocity[2] += 150.0; // a little boost to alleviate arcing issues
		
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);	
	}
	else
	{
		float Ability_CD = ability_cooldown[client] - GetGameTime();
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}


public void PlaceableTempomaryArmorGrenade(int client)
{
	if (ability_cooldown[client] < GetGameTime())
	{
		ability_cooldown[client] = GetGameTime() + 100.0;
		
		int entity = CreateEntityByName("tf_projectile_pipe");
		if(IsValidEntity(entity))
		{
			static float pos[3], ang[3], vel_2[3];
			GetClientEyeAngles(client, ang);
			GetClientEyePosition(client, pos);	
		
			ang[0] -= 8.0;
			
			float speed = 1500.0;
			
			vel_2[0] = Cosine(DegToRad(ang[0]))*Cosine(DegToRad(ang[1]))*speed;
			vel_2[1] = Cosine(DegToRad(ang[0]))*Sine(DegToRad(ang[1]))*speed;
			vel_2[2] = Sine(DegToRad(ang[0]))*speed;
			vel_2[2] *= -1;
			
			int team = GetClientTeam(client);
				
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
			SetEntProp(entity, Prop_Send, "m_iTeamNum", team, 1);
			SetEntProp(entity, Prop_Send, "m_nSkin", (team-2));
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
			SetEntPropEnt(entity, Prop_Send, "m_hThrower", client);
			SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", 0);
			for(int i; i<4; i++)
			{
				SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModel, _, i);
			}
			
			SetVariantInt(team);
			AcceptEntityInput(entity, "TeamNum", -1, -1, 0);
			SetVariantInt(team);
			AcceptEntityInput(entity, "SetTeam", -1, -1, 0); 
			
			SetEntPropEnt(entity, Prop_Send, "m_hLauncher", 0);
			DispatchSpawn(entity);
			TeleportEntity(entity, pos, ang, vel_2);
			
			IsCustomTfGrenadeProjectile(entity, 9999999.0);
			CClotBody npc = view_as<CClotBody>(entity);
			npc.m_bThisEntityIgnored = true;
			
			f_HealDelay[entity] = GetGameTime() + 1.0;
			f_Duration[entity] = GetGameTime() + 10.0;
			
			SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
			 
			DataPack pack;
			CreateDataTimer(0.1, Timer_Detect_Player_Near_Armor_Grenade, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack.WriteCell(EntIndexToEntRef(entity));
	//		pack.WriteCell(Healing_Amount);	
			pack.WriteCell(GetClientUserId(client));
		}
	}
	else
	{
		float Ability_CD = ability_cooldown[client] - GetGameTime();
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}


public Action Timer_Detect_Player_Near_Armor_Grenade(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
//	float Healing_Amount = pack.ReadCell();
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(IsValidClient(client))
		{
			float powerup_pos[3];
			float client_pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
			if(f_HealDelay[entity] < GetGameTime())
			{
				f_HealDelay[entity] = GetGameTime() + 1.0;
				int color[4];
				
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
		
				TE_SetupBeamRingPoint(powerup_pos, 10.0, 500.0, g_BeamIndex_heal, -1, 0, 5, 0.5, 5.0, 1.0, color, 0, 0);
	   			TE_SendToAll();
	   			for (int target = 1; target <= MaxClients; target++)
				{
					if (IsValidClient(target) && IsPlayerAlive(target) && GetClientTeam(target) == view_as<int>(TFTeam_Red) && TeutonType[target] == 0)
					{
						GetClientAbsOrigin(target, client_pos);
						if (GetVectorDistance(powerup_pos, client_pos, true) <= 90000)
						{
							EmitSoundToClient(target, SOUND_ARMOR_BEAM, target, _, 90, _, 1.0);
							EmitSoundToClient(target, SOUND_ARMOR_BEAM, target, _, 90, _, 1.0);
							EmitSoundToClient(target, SOUND_ARMOR_BEAM, target, _, 90, _, 1.0);
							int Armor_Max = 300;
							int Extra = 0;
						
							Extra = Armor_Level[client];
								
							Armor_Max = MaxArmorCalculation(Extra, client, 1.0);
								
							
								
							if(Armor_Charge[client] < Armor_Max)
							{
								if(Extra == 50)
									Armor_Charge[client] += 75 / 5;
									
								else if(Extra == 100)
									Armor_Charge[client] += 100 / 5;
									
								else if(Extra == 150)
									Armor_Charge[client] += 200 / 5;
									
								else if(Extra == 200)
									Armor_Charge[client] += 350 / 5;
									
								else
									Armor_Charge[client] += 25 / 5;
											
								if(Armor_Charge[client] >= Armor_Max)
								{
									Armor_Charge[client] = Armor_Max;
								}
							}
						}
					}
				}
   			}
   			if(f_Duration[entity] < GetGameTime())
   			{
   				RemoveEntity(entity);
   				return Plugin_Stop;	
   			}
   			return Plugin_Continue;
		}
		else
		{
			return Plugin_Stop;	
		}
	}
	else
	{
		return Plugin_Stop;	
	}
}



public void PlaceableTempomaryHealingGrenade(int client)
{
	if (ability_cooldown[client] < GetGameTime())
	{
		ability_cooldown[client] = GetGameTime() + 140.0;
		
		int entity = CreateEntityByName("tf_projectile_pipe");
		if(IsValidEntity(entity))
		{
			static float pos[3], ang[3], vel_2[3];
			GetClientEyeAngles(client, ang);
			GetClientEyePosition(client, pos);	
		
			ang[0] -= 8.0;
			
			float speed = 1500.0;
			
			vel_2[0] = Cosine(DegToRad(ang[0]))*Cosine(DegToRad(ang[1]))*speed;
			vel_2[1] = Cosine(DegToRad(ang[0]))*Sine(DegToRad(ang[1]))*speed;
			vel_2[2] = Sine(DegToRad(ang[0]))*speed;
			vel_2[2] *= -1;
			
			int team = GetClientTeam(client);
				
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
			SetEntProp(entity, Prop_Send, "m_iTeamNum", team, 1);
			SetEntProp(entity, Prop_Send, "m_nSkin", (team-2));
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
			SetEntPropEnt(entity, Prop_Send, "m_hThrower", client);
			SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", 0);
			for(int i; i<4; i++)
			{
				SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelArmor, _, i);
			}
			
			SetVariantInt(team);
			AcceptEntityInput(entity, "TeamNum", -1, -1, 0);
			SetVariantInt(team);	
			AcceptEntityInput(entity, "SetTeam", -1, -1, 0); 
			
			SetEntPropEnt(entity, Prop_Send, "m_hLauncher", 0);
			DispatchSpawn(entity);
			TeleportEntity(entity, pos, ang, vel_2);
			
			IsCustomTfGrenadeProjectile(entity, 9999999.0);
			CClotBody npc = view_as<CClotBody>(entity);
			npc.m_bThisEntityIgnored = true;
			
			float Healing_Amount = 10.0;
			
			int weapon = GetPlayerWeaponSlot(client, 1);
			
			if(IsValidEntity(weapon))
			{
				Healing_Amount *= RoundToCeil(Attributes_FindOnWeapon(client, weapon, 8));
			}
			
			f_HealDelay[entity] = GetGameTime() + 1.0;
			f_Duration[entity] = GetGameTime() + 10.0;
			
			SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
			 
			DataPack pack;
			CreateDataTimer(0.1, Timer_Detect_Player_Near_Healing_Grenade, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack.WriteCell(EntIndexToEntRef(entity));
			pack.WriteCell(Healing_Amount);	
			pack.WriteCell(GetClientUserId(client));
		}
	}
	else
	{
		float Ability_CD = ability_cooldown[client] - GetGameTime();
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}


public Action Timer_Detect_Player_Near_Healing_Grenade(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	float Healing_Amount = pack.ReadCell();
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(IsValidClient(client))
		{
			float powerup_pos[3];
			float client_pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
			if(f_HealDelay[entity] < GetGameTime())
			{
				f_HealDelay[entity] = GetGameTime() + 1.0;
				int color[4];
				
				color[0] = 0;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
		
				TE_SetupBeamRingPoint(powerup_pos, 10.0, 500.0, g_BeamIndex_heal, -1, 0, 5, 0.5, 5.0, 1.0, color, 0, 0);
	   			TE_SendToAll();
	   			for (int target = 1; target <= MaxClients; target++)
				{
					if (IsValidClient(target) && IsPlayerAlive(target) && GetClientTeam(target) == view_as<int>(TFTeam_Red) && TeutonType[target] == 0)
					{
						GetClientAbsOrigin(target, client_pos);
						if (GetVectorDistance(powerup_pos, client_pos, true) <= 90000)
						{
							if(dieingstate[target] > 0)
							{
								StartHealingTimer(target, 0.1, 1, 1);
								EmitSoundToClient(target, SOUND_HEAL_BEAM, target, _, 90, _, 1.0);
								dieingstate[target] -= 10;
								if(dieingstate[target] < 1)
								{
									dieingstate[target] = 1;
								}
							}
							else
							{
								if(f_TimeUntillNormalHeal[target] < GetGameTime())
								{
									Healing_Amount *= 0.25;
								}
								EmitSoundToClient(target, SOUND_HEAL_BEAM, target, _, 90, _, 1.0);
								StartHealingTimer(target, 0.1, RoundToCeil(Healing_Amount * 0.1), 10);
								
								Healing_done_in_total[client] += RoundToCeil(Healing_Amount);		
							}
						}
					}
				}
   			}
   			if(f_Duration[entity] < GetGameTime())
   			{
   				RemoveEntity(entity);
   				return Plugin_Stop;	
   			}
   			return Plugin_Continue;
		}
		else
		{
			return Plugin_Stop;	
		}
	}
	else
	{
		return Plugin_Stop;	
	}
}











public void SetAbilitySlotCount(int client, int value)
{
	Attack3AbilitySlotArray[client] = value;
}

public int GetAbilitySlotCount(int client)
{
	return Attack3AbilitySlotArray[client];
}
