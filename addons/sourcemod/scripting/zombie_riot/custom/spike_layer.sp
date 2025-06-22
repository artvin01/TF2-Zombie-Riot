#pragma semicolon 1
#pragma newdecls required

/*
public Action Do_Spike_Stuff(Handle dashHud, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		int owner_failsafe = GetEntPropEnt(entity, Prop_Send, "m_hLauncher");
		if(IsValidEntity(owner))
		{
			int weapon = GetPlayerWeaponSlot(owner, TFWeaponSlot_Primary);
			int index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		//	PrintToChatAll("test");
			if(index == 997) //Hardcode to this.
			{
				PrintToChatAll("test");
				Do_Spike_Change(entity, weapon, owner);
			}
		}
		else if(IsValidEntity(owner_failsafe))
		{
			int weapon = GetPlayerWeaponSlot(owner, TFWeaponSlot_Primary);
			int index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		//	PrintToChatAll("test");
			if(index == 997) //Hardcode to this.
			{
				PrintToChatAll("test");
				Do_Spike_Change(entity, weapon, owner);
			}
		}
	}
}


public void Do_Spike_Change(int projectile, int weapon, int client)
{
	SetEntityCollisionGroup(projectile, ); 									//Make sure it doesnt collide with anything except the world.
	SDKHook(projectile, SDKHook_ShouldCollide, Spike_ShouldCollide);
}


public bool Spike_ShouldCollide(int client, int collisiongroup, int contentsmask, bool originalResult)
{
	return false;
} 
*/ 
//Doesnt work, arrows ignore this.
//Do usual method!
//Make bullets 0 and add 280 ; 1 so it shoots litterally nothing!

//static int Spike_Owner[MAXENTITIES]={0, ...};


#define MAXSPIKESALLOWED 60

static int Spike_Health[MAXENTITIES]={0, ...};
static int Spikes_Alive[MAXPLAYERS+1]={0, ...};
static int Spikes_AliveCap[MAXPLAYERS+1]={30, ...};
static int Spike_MaxHealth[MAXENTITIES]={0, ...};
static int Is_Spike[MAXENTITIES]={false, ...};
static int Spikes_AliveGlobal;
Handle h_TimerSpikeLayerManagement[MAXPLAYERS+1] = {null, ...};
static float f_SpikeLayerHudDelay[MAXPLAYERS];
static float f_DeleteAllSpikesDelay[MAXPLAYERS];


bool IsEntitySpike(int entity)
{
	if(Is_Spike[entity] > 0)
		return true;
	
	return false;
}
int IsEntitySpikeValue(int entity)
{
	return Is_Spike[entity];
}

void SetEntitySpike(int entity, int set)
{
	Is_Spike[entity] = set;
}

void Reset_stats_SpikeLayer_Singular(int client) //This is on disconnect/connect
{
	if (h_TimerSpikeLayerManagement[client] != null)
	{
		delete h_TimerSpikeLayerManagement[client];
	}	
	h_TimerSpikeLayerManagement[client] = null;
	f_SpikeLayerHudDelay[client] = 0.0;
	f_DeleteAllSpikesDelay[client] = 0.0;
}

public void Weapon_Spike_Layer(int client, int weapon, const char[] classname, bool &result)
{
	Spikes_AliveCap[client] = 15;
	if(Spikes_AliveGlobal >= MAXSPIKESALLOWED)
	{
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Spike Limit Reached");
		return;
	}
	if(weapon >= MaxClients)
	{
		if(15 <= Spikes_Alive[client])
		{
			//ONLY give back ammo IF the Spike has full health.
			int Ammo_type = GetAmmoType_WeaponPrimary(weapon);
			//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
			//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
			SetAmmo(client, Ammo_type, GetAmmo(client, Ammo_type)+1); //Give ammo back that they just spend like an idiot
			for(int i; i<Ammo_MAX; i++)
			{
				CurrentAmmo[client][i] = GetAmmo(client, i);
			}	
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Spike Limit Reached");
			return;
		}
		
		float Calculate_HP_Spikes = 45.0; 
		Calculate_HP_Spikes *= 2.0;
		Calculate_HP_Spikes *= 0.7;
		
		float Bonus_damage;
			
		float attack_speed;
		
		attack_speed = 1.0 / Attributes_GetOnPlayer(client, 343, true, true); //Sentry attack speed bonus
				
		Bonus_damage = attack_speed * Attributes_GetOnPlayer(client, 287, true, !Merchant_IsAMerchant(client));			//Sentry damage bonus

		Bonus_damage *= BuildingWeaponDamageModif(1);
		
		if (Bonus_damage <= 1.0)
			Bonus_damage = 1.0;
			
		Calculate_HP_Spikes *= Bonus_damage;
		
		static float ang[3], pos[3], vel[3];
		int team = GetClientTeam(client);

		GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
		GetClientEyeAngles(client, ang);
		pos[2] += 63;

		vel[0] = Cosine(DegToRad(ang[0]))*Cosine(DegToRad(ang[1]))*1500.0;
		vel[1] = Cosine(DegToRad(ang[0]))*Sine(DegToRad(ang[1]))*1500.0;
		vel[2] = Sine(DegToRad(ang[0]))*-1500.0;

		int entity = CreateEntityByName("tf_projectile_pipe_remote");
		if(IsValidEntity(entity))
		{
			b_ExpertTrapper[entity] = b_ExpertTrapper[client];
			b_StickyIsSticking[entity] = true; //Make them not stick to npcs.
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
			SetTeam(entity, team);
			SetEntProp(entity, Prop_Send, "m_bCritical", false); 	//No crits, causes particles which cause FPS DEATH!! Crits in tf2 cause immensive lag from what i know from ff2.
																	//Might also just be cosmetics, eitherways, dont use this, litterally no reason to!
			SetEntProp(entity, Prop_Send, "m_iType", 1);
			SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.75);
			Spike_Health[entity] = RoundToCeil(Calculate_HP_Spikes);
			Spike_MaxHealth[entity] = RoundToCeil(Calculate_HP_Spikes);
		//	SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", weapon);
		//	SetEntPropEnt(entity, Prop_Send, "m_hLauncher", weapon);
		/*
			DONT DO THIS!!
			Entity 69 (class 'tf_projectile_pipe_remote') reported ENTITY_CHANGE_NONE but 'm_hOriginalLauncher' changed.
			Entity 69 (class 'tf_projectile_pipe_remote') reported ENTITY_CHANGE_NONE but 'm_hLauncher' changed.
		
		*/
			SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vel);

			TeleportEntity(entity, pos, ang, NULL_VECTOR);
			DispatchSpawn(entity);
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vel);
			SetEntitySpike(entity, 1);
		//	Spike_Owner[entity] = client;

		//	HasSentry[client] = EntIndexToEntRef(entity);
		//	EmitSoundToAll("weapons/drg_wrench_teleport.wav", entity, SNDCHAN_WEAPON, 70);
			Spikes_Alive[client] += 1;
			Spikes_AliveGlobal += 1;
			CreateTimer(0.25, Detect_Spike_Still, EntIndexToEntRef(entity), TIMER_REPEAT);
		}
		//Borowed from RPG fortress!
	}
}


public void Weapon_Spike_Layer_PAP(int client, int weapon, const char[] classname, bool &result)
{
	Spikes_AliveCap[client] = 20;
	if(Spikes_AliveGlobal >= MAXSPIKESALLOWED)
	{
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Spike Limit Reached");
		return;
	}
	if(weapon >= MaxClients)
	{
		if(20 <= Spikes_Alive[client])
		{
			//ONLY give back ammo IF the Spike has full health.
			int Ammo_type = GetAmmoType_WeaponPrimary(weapon);
			//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
			//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
			SetAmmo(client, Ammo_type, GetAmmo(client, Ammo_type)+1); //Give ammo back that they just spend like an idiot
			for(int i; i<Ammo_MAX; i++)
			{
				CurrentAmmo[client][i] = GetAmmo(client, i);
			}	
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Spike Limit Reached");
			return;
		}
		
		float Calculate_HP_Spikes = 55.0; 
		Calculate_HP_Spikes *= 2.0;
		Calculate_HP_Spikes *= 0.7;
		
		float Bonus_damage;
			
		float attack_speed;
		
		attack_speed = 1.0 / Attributes_GetOnPlayer(client, 343, true, true); //Sentry attack speed bonus
				
		Bonus_damage = attack_speed * Attributes_GetOnPlayer(client, 287, true, !Merchant_IsAMerchant(client));			//Sentry damage bonus

		Bonus_damage *= BuildingWeaponDamageModif(1);
		
		if (Bonus_damage <= 1.0)
			Bonus_damage = 1.0;
			
		Calculate_HP_Spikes *= Bonus_damage;

		
		static float ang[3], pos[3], vel[3];
		int team = GetClientTeam(client);

		GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
		GetClientEyeAngles(client, ang);
		pos[2] += 63;

		vel[0] = Cosine(DegToRad(ang[0]))*Cosine(DegToRad(ang[1]))*1500.0;
		vel[1] = Cosine(DegToRad(ang[0]))*Sine(DegToRad(ang[1]))*1500.0;
		vel[2] = Sine(DegToRad(ang[0]))*-1500.0;

		int entity = CreateEntityByName("tf_projectile_pipe_remote");
		if(IsValidEntity(entity))
		{
			b_ExpertTrapper[entity] = b_ExpertTrapper[client];
			b_StickyIsSticking[entity] = true; //Make them not stick to npcs.
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
			SetTeam(entity, team);
			SetEntProp(entity, Prop_Send, "m_bCritical", false); 	//No crits, causes particles which cause FPS DEATH!! Crits in tf2 cause immensive lag from what i know from ff2.
																	//Might also just be cosmetics, eitherways, dont use this, litterally no reason to!
			SetEntProp(entity, Prop_Send, "m_iType", 1);
			SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.75);
			Spike_Health[entity] = RoundToCeil(Calculate_HP_Spikes);
			Spike_MaxHealth[entity] = RoundToCeil(Calculate_HP_Spikes);
			SetEntitySpike(entity, 1);
		//	SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", weapon);
		//	SetEntPropEnt(entity, Prop_Send, "m_hLauncher", weapon);
		/*
			DONT DO THIS!!
			Entity 69 (class 'tf_projectile_pipe_remote') reported ENTITY_CHANGE_NONE but 'm_hOriginalLauncher' changed.
			Entity 69 (class 'tf_projectile_pipe_remote') reported ENTITY_CHANGE_NONE but 'm_hLauncher' changed.
		
		*/
			SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vel);

			TeleportEntity(entity, pos, ang, NULL_VECTOR);
			DispatchSpawn(entity);
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vel);
		//	Spike_Owner[entity] = client;

		//	HasSentry[client] = EntIndexToEntRef(entity);
		//	EmitSoundToAll("weapons/drg_wrench_teleport.wav", entity, SNDCHAN_WEAPON, 70);
			Spikes_Alive[client] += 1;
			Spikes_AliveGlobal += 1;
			CreateTimer(0.25, Detect_Spike_Still, EntIndexToEntRef(entity), TIMER_REPEAT);
		}
		//Borowed from RPG fortress!
	}
}

public Action Detect_Spike_Still(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
	//	int client = GetEntPropEnt(entity, Prop_Send, "m_hLauncher"); //Doesnt save this shit for some reason. use array as usual!
	//	int client = Spike_Owner[entity];
		int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(IsValidClient(client))
		{
			if(entity>MaxClients && IsValidEntity(entity))
			{
				if(!GetEntProp(entity, Prop_Send, "m_bTouched"))
					return Plugin_Continue;
	
				static float pos[3];
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
				
			//	RemoveEntity(entity);
				
				if(IsValidEntity(entity))
				{
					DataPack pack;
					CreateDataTimer(0.25, Did_Enemy_Step_On_Spike, pack, TIMER_REPEAT);
					pack.WriteCell(EntIndexToEntRef(entity));
					pack.WriteCell(entity);
					pack.WriteCell(client);
				//	SDKHook(entity, SDKHook_ShouldCollide, Spike_ShouldCollide); //So zombies cant use these as stairs lol
					return Plugin_Stop;
				}
			}
		}
		else
		{
			if(entity>MaxClients && IsValidEntity(entity))
			{
			//	Spikes_Alive[client] -= 1;
				SetEntitySpike(entity, 0);
				RemoveEntity(entity);
			}
				
		}
	}
	return Plugin_Stop;
}
public Action Did_Enemy_Step_On_Spike(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int original_entity = pack.ReadCell();
	int original_client = pack.ReadCell();
	if(IsValidEntity(entity))
	{
	//	int client = GetEntPropEnt(entity, Prop_Send, "m_hLauncher");
	//	int client = Spike_Owner[entity];
		int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(client > 0 && IsClientInGame(client))
		{
			if(entity>MaxClients && IsValidEntity(entity))
			{
	//			PrintToChatAll("check for enemies");
				// dont do GetClosestTarget_BaseBoss, cus it would only hurt one at a time, that would suck ass, cant use ontouch, kills server more
				// then a simple distance check and i cant even use it either.
				// cant use Spike_ShouldCollide as it doesnt give on what it collided with. Maybe. Eitherways those ways are very not good or rape server
				// Just do this:
				float targPos[3];
				float Spikepos[3];
				
				for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
				{
					int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
					if (IsValidEntity(baseboss_index) && GetTeam(baseboss_index) != TFTeam_Red)
					{
						if(!b_NpcHasDied[baseboss_index])
						{
							GetEntPropVector(baseboss_index, Prop_Data, "m_vecAbsOrigin", targPos);
							GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", Spikepos);
							if (GetVectorDistance(Spikepos, targPos, true) <= 2500) //Use squaring cus optimisation is for cool kids. 50*50
							{
								int Health = GetEntProp(baseboss_index, Prop_Data, "m_iHealth");
								//This is needed as we delay deaths in riot due to other factors that arent possible to fix, i think.
								
								if(Health <= 0)
									continue;
								
								//Just do full damage.
								float DamageTrap = float(Spike_Health[entity]);
								if(b_ExpertTrapper[client] && b_ExpertTrapper[entity])
									DamageTrap *= 4.5;

								SDKHooks_TakeDamage(baseboss_index, client, client, DamageTrap, DMG_BULLET, -1, NULL_VECTOR, Spikepos);

								RemoveEntity(entity);
								SetEntitySpike(entity, 0);
								Spikes_Alive[client] -= 1;
								Spikes_AliveGlobal -= 1;

								return Plugin_Stop;
							}
						}
					}
				}
				return Plugin_Continue;
			}
		}
		else
		{
			if(entity>MaxClients && IsValidEntity(entity))
			{
				Spikes_AliveGlobal -= 1;
				Spikes_Alive[original_client] -= 1; // I dont knowhow this happend or how to delete you off it, im sorry. Youre lost. Edit: Actually, this is fine to do! Arrays dont care if its a valid entity or not, luckly.
				SetEntitySpike(entity, 0);
				RemoveEntity(entity);
				return Plugin_Stop;
			}
				
		}
	}
	else
	{
		Spikes_AliveGlobal -= 1;
		Spikes_Alive[original_client] -= 1; // I dont knowhow this happend or how to delete you off it, im sorry. Youre lost. Edit: Actually, this is fine to do! Arrays dont care if its a valid entity or not, luckly.
		SetEntitySpike(original_entity, 0);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public void Spike_Pick_Back_up(int client, int weapon, const char[] classname, bool &result)
{
	static float angles[3];
	GetClientEyeAngles(client, angles);
	if(angles[0] < -85.0)
	{
		if(f_DeleteAllSpikesDelay[client] > GetGameTime())
		{
			bool PlaySound = false;
			for( int entity = 1; entity <= MAXENTITIES; entity++ ) 
			{
				if (IsValidEntity(entity))
				{
					static char buffer[64];
					GetEntityClassname(entity, buffer, sizeof(buffer));
					if(Is_Spike[entity] == 1 && !StrContains(buffer, "tf_projectile_pipe_remote"))
					{
						int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
						if(owner == client) //Hardcode to this index.
						{
							Is_Spike[entity] = 0;
							if(Spike_Health[entity] == Spike_MaxHealth[entity])
							{
								//ONLY give back ammo IF the Spike has full health.
								int Ammo_type = GetAmmoType_WeaponPrimary(weapon);
								PlaySound = true;
								SetAmmo(client, Ammo_type, GetAmmo(client, Ammo_type)+1);
								for(int i; i<Ammo_MAX; i++)
								{
									CurrentAmmo[client][i] = GetAmmo(client, i);
								}	
							}
							RemoveEntity(entity);
						}
					}
				}
			}
			if(PlaySound)
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Spike Masspickup Done");
				ClientCommand(client, "playgamesound items/ammo_pickup.wav");
				ClientCommand(client, "playgamesound items/ammo_pickup.wav");
			}
			else
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Spike Masspickup None");
			}
			return;
		}
		f_DeleteAllSpikesDelay[client] = GetGameTime() + 0.2;
		
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Spike Masspickup Confirm");
		return;
	}
	int entity = GetClientPointVisible(client);
	if(entity > 0)
	{
		static char buffer[64];
		if(GetEntityClassname(entity, buffer, sizeof(buffer)))
		{
			if(Is_Spike[entity] == 1 && !StrContains(buffer, "tf_projectile_pipe_remote"))
			{
				if(IsValidEntity(weapon))
				{
					int index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
					int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					if(index == 997 && owner == client) //Hardcode to this index.
					{
						Is_Spike[entity] = false;
					//	Spikes_Alive[client] -= 1;
						if(Spike_Health[entity] == Spike_MaxHealth[entity])
						{
							//ONLY give back ammo IF the Spike has full health.
							int Ammo_type = GetAmmoType_WeaponPrimary(weapon);
							ClientCommand(client, "playgamesound items/ammo_pickup.wav");
							ClientCommand(client, "playgamesound items/ammo_pickup.wav");
							SetAmmo(client, Ammo_type, GetAmmo(client, Ammo_type)+1);
							for(int i; i<Ammo_MAX; i++)
							{
								CurrentAmmo[client][i] = GetAmmo(client, i);
							}	
						}
						RemoveEntity(entity);
					}
				}
			}
		}
	}
}


public void Enable_SpikeLayer(int client, int weapon) 
{
	if (h_TimerSpikeLayerManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SPIKELAYER) 
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerSpikeLayerManagement[client];
			h_TimerSpikeLayerManagement[client] = null;
			DataPack pack;
			h_TimerSpikeLayerManagement[client] = CreateDataTimer(0.1, Timer_Management_SpikeLayer, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SPIKELAYER)
	{
		DataPack pack;
		h_TimerSpikeLayerManagement[client] = CreateDataTimer(0.1, Timer_Management_SpikeLayer, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}
public Action Timer_Management_SpikeLayer(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerSpikeLayerManagement[client] = null;
		return Plugin_Stop;
	}	
	SpikeLayer_Cooldown_Logic(client, weapon);

	return Plugin_Continue;
}



public void SpikeLayer_Cooldown_Logic(int client, int weapon)
{
	if(IsValidEntity(weapon))
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SPIKELAYER)
		{
			int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
			{
				if(f_SpikeLayerHudDelay[client] < GetGameTime())
				{
					PrintHintText(client,"Spikes Layed [%i/%i]\nSpike Global Limit[%i/%i]",Spikes_Alive[client],Spikes_AliveCap[client],Spikes_AliveGlobal,MAXSPIKESALLOWED);	
					
					f_SpikeLayerHudDelay[client] = GetGameTime() + 0.5;
				}
			}
		}
	}
}