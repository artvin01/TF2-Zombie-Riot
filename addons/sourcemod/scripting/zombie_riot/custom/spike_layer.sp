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



static int Spike_Health[MAXENTITIES]={0, ...};
static int Spikes_Alive[MAXPLAYERS+1]={0, ...};
static int Spike_MaxHealth[MAXENTITIES]={0, ...};
static bool Is_Spike[MAXENTITIES]={false, ...};

bool IsEntitySpike(int entity)
{
	return Is_Spike[entity];
}

public void Weapon_Spike_Layer(int client, int weapon, const char[] classname, bool &result)
{
	if(weapon >= MaxClients)
	{
		if(40 <= Spikes_Alive[client])
		{
			//ONLY give back ammo IF the Spike has full health.
			int Ammo_type = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
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
		
		float Calculate_HP_Spikes = 70.0; 
		
		float Bonus_damage;
			
		float attack_speed;
		
		attack_speed = 1.0 / Attributes_FindOnPlayer(client, 343, true, 1.0); //Sentry attack speed bonus
				
		Bonus_damage = attack_speed * Attributes_FindOnPlayer(client, 287, true, 1.0);			//Sentry damage bonus
		
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
			b_StickyIsSticking[entity] = true; //Make them not stick to npcs.
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
			SetEntProp(entity, Prop_Send, "m_iTeamNum", team);
			SetEntProp(entity, Prop_Send, "m_bCritical", false); 	//No crits, causes particles which cause FPS DEATH!! Crits in tf2 cause immensive lag from what i know from ff2.
																	//Might also just be cosmetics, eitherways, dont use this, litterally no reason to!
			SetEntProp(entity, Prop_Send, "m_iType", 1);
			SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.75);
			Spike_Health[entity] = RoundToCeil(Calculate_HP_Spikes);
			Spike_MaxHealth[entity] = RoundToCeil(Calculate_HP_Spikes);
			Is_Spike[entity] = true;
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
			CreateTimer(0.25, Detect_Spike_Still, EntIndexToEntRef(entity), TIMER_REPEAT);
		}
		//Borowed from RPG fortress!
	}
}


public void Weapon_Spike_Layer_PAP(int client, int weapon, const char[] classname, bool &result)
{
	if(weapon >= MaxClients)
	{
		if(60 <= Spikes_Alive[client])
		{
			//ONLY give back ammo IF the Spike has full health.
			int Ammo_type = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
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
		
		float Calculate_HP_Spikes = 80.0; 
		
		float Bonus_damage;
			
		float attack_speed;
		
		attack_speed = 1.0 / Attributes_FindOnPlayer(client, 343, true, 1.0); //Sentry attack speed bonus
				
		Bonus_damage = attack_speed * Attributes_FindOnPlayer(client, 287, true, 1.0);			//Sentry damage bonus
		
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
			b_StickyIsSticking[entity] = true; //Make them not stick to npcs.
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
			SetEntProp(entity, Prop_Send, "m_iTeamNum", team);
			SetEntProp(entity, Prop_Send, "m_bCritical", false); 	//No crits, causes particles which cause FPS DEATH!! Crits in tf2 cause immensive lag from what i know from ff2.
																	//Might also just be cosmetics, eitherways, dont use this, litterally no reason to!
			SetEntProp(entity, Prop_Send, "m_iType", 1);
			SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.75);
			Spike_Health[entity] = RoundToCeil(Calculate_HP_Spikes);
			Spike_MaxHealth[entity] = RoundToCeil(Calculate_HP_Spikes);
			Is_Spike[entity] = true;
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
		if(IsClientInGame(client))
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
				Is_Spike[entity] = false;
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
				
				for(int entitycount; entitycount<i_MaxcountNpc; entitycount++)
				{
					int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs[entitycount]);
					if (IsValidEntity(baseboss_index))
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
								
								//int MaxHealth = GetEntProp(baseboss_index, Prop_Data, "m_iMaxHealth");
								
								int Damage_Calc;
								
								//Damage_Calc = MaxHealth - Health; //how much dmg to kill
								
								Damage_Calc = Health;
								
							//	PrintToChatAll("%i",Damage_Calc);
								if(Damage_Calc > Spike_Health[entity])
								{
									//i was trying some really dumb math, its actually this easy...
									Damage_Calc = Spike_Health[entity];
								}
								
								float Health_Before_Hurt = float(GetEntProp(baseboss_index, Prop_Data, "m_iHealth"));
					
								//Just do full damage.
								SDKHooks_TakeDamage(baseboss_index, client, client, float(Damage_Calc), DMG_BULLET, -1, NULL_VECTOR, Spikepos);
								
								float Health_After_Hurt = float(GetEntProp(baseboss_index, Prop_Data, "m_iHealth"));
								
								Spike_Health[entity] -= RoundToCeil(Health_Before_Hurt - Health_After_Hurt);
								
								if (Spike_Health[entity] == 0)
								{
									RemoveEntity(entity);
									Is_Spike[entity] = false;
									Spikes_Alive[client] -= 1;
									return Plugin_Stop;
								}
								else if (Spike_Health[entity] < 0)
								{
									RemoveEntity(entity);
									Is_Spike[entity] = false;
									Spikes_Alive[client] -= 1;
								//	not anymore bug, enemies CAN take more damage.
								//	PrintToConsoleAll("Somehow the spike did more dmg then it has health? BUG!!!!!!!");
									return Plugin_Stop;
								}
								
								//We cant use posttake damage, any resistance will just eat spikes hard, no real way around that unless i do litteral frame checks that rape
								//Server performance in 0.0001 nano seconds
								//So we just calculate it beforehand!
								//Minicrits included?
								//any enemy with invineability like minions will sadly be ignored by this, but i guess that buffs them!
								//Or i should probably add a check for those types of enemy, or a global native or some crap, but thats too much effort
								//i will probably just do a check for if they are invinceable or not.
								//Also with this logic, NPC's should NEVER gib from this, if they do, then there is a bug!!!!!!!
								
						//		RemoveEntity(entity);
						//		return Plugin_Stop;
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
				Spikes_Alive[original_client] -= 1; // I dont knowhow this happend or how to delete you off it, im sorry. Youre lost. Edit: Actually, this is fine to do! Arrays dont care if its a valid entity or not, luckly.
				Is_Spike[entity] = false;
				RemoveEntity(entity);
				return Plugin_Stop;
			}
				
		}
	}
	else
	{
		Spikes_Alive[original_client] -= 1; // I dont knowhow this happend or how to delete you off it, im sorry. Youre lost. Edit: Actually, this is fine to do! Arrays dont care if its a valid entity or not, luckly.
		Is_Spike[original_entity] = false;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public void Spike_Pick_Back_up(int client, int weapon, const char[] classname, bool &result)
{
	int entity = GetClientPointVisible(client);
	if(entity > 0)
	{
		static char buffer[64];
		if(GetEntityClassname(entity, buffer, sizeof(buffer)))
		{
			if(Is_Spike[entity] && !StrContains(buffer, "tf_projectile_pipe_remote"))
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
							int Ammo_type = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
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