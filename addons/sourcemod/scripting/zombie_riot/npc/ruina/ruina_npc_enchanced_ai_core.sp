#pragma semicolon 1
#pragma newdecls required

static int i_master_target_id[MAXENTITIES];
static int i_master_id[MAXENTITIES];
static int i_npc_type[MAXENTITIES];

static float fl_master_change_timer[MAXENTITIES];
static bool b_master_exists[MAXENTITIES];
static int i_master_attracts[MAXENTITIES];

static char gLaser1;
static int BeamWand_Laser;
//static char gGlow1;	//blue

float fl_rally_timer[MAXENTITIES];
bool b_rally_active[MAXENTITIES];

float fl_ruina_battery[MAXENTITIES];
bool b_ruina_battery_ability_active[MAXENTITIES];
float fl_ruina_battery_timer[MAXENTITIES];

float fl_ruina_shield_power[MAXENTITIES];
float fl_ruina_shield_strenght[MAXENTITIES];
float fl_ruina_shield_timer[MAXENTITIES];
bool b_ruina_shield_active[MAXENTITIES];

static bool b_master_is_rallying[MAXENTITIES];
static bool b_force_reasignment[MAXENTITIES];
static int i_master_priority[MAXENTITIES];		//when searching for a master, the master with highest priority will get minnion's first. eg npc with Priority 1 will have lower priority then npc with priority 2
static int i_master_max_slaves[MAXENTITIES];	//how many npc's a master can hold before they stop accepting slaves
static int i_master_current_slaves[MAXENTITIES];
static bool b_master_is_acepting[MAXENTITIES];	//if a master npc no longer wants slaves this is set to false

#define RUINA_AI_CORE_REFRESH_MASTER_ID_TIMER 30.0	//how often do the npc's try to get a new master, ignored by master refind

#define RUINA_NPC_PITCH 115


#define RUINA_BALL_PARTICLE_BLUE "drg_manmelter_trail_blue"

#define RUINA_ION_CANNON_SOUND_SPAWN "ambient/machines/thumper_startup1.wav"
#define RUINA_ION_CANNON_SOUND_TOUCHDOWN "mvm/ambient_mp3/mvm_siren.mp3"
#define RUINA_ION_CANNON_SOUND_ATTACK "ambient/machines/thumper_hit.wav"
#define RUINA_ION_CANNON_SOUND_SHUTDOWN "ambient/machines/thumper_shutdown1.wav"
#define RUINA_ION_CANNON_SOUND_PASSIVE "ambient/energy/weld1.wav"
#define RUINA_ION_CANNON_SOUND_PASSIVE_CHARGING "weapons/physcannon/physcannon_charge.wav"

public void Ruina_Ai_Core_Mapstart()
{
	Zero(fl_master_change_timer);
	Zero(i_master_target_id);
	Zero(b_master_exists);
	Zero(i_master_id);
	Zero(i_npc_type);
	
	Zero(b_master_is_rallying);
	Zero(b_force_reasignment);
	Zero(i_master_priority);
	Zero(i_master_max_slaves);
	Zero(b_master_is_acepting);
	
	Zero(fl_rally_timer);
	Zero(b_rally_active);
	Zero(fl_ruina_battery);
	Zero(b_ruina_battery_ability_active);
	Zero(fl_ruina_battery_timer);
	Zero(fl_ruina_shield_power);
	Zero(fl_ruina_shield_timer);
	Zero(fl_ruina_shield_strenght);
	Zero(b_ruina_shield_active);
	
	PrecacheSound(RUINA_ION_CANNON_SOUND_SPAWN);
	PrecacheSound(RUINA_ION_CANNON_SOUND_TOUCHDOWN);
	PrecacheSound(RUINA_ION_CANNON_SOUND_ATTACK);
	PrecacheSound(RUINA_ION_CANNON_SOUND_SHUTDOWN);
	PrecacheSound(RUINA_ION_CANNON_SOUND_PASSIVE);
	PrecacheSound(RUINA_ION_CANNON_SOUND_PASSIVE_CHARGING);
	
	
	
	gLaser1 = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	//gGlow1 = PrecacheModel("sprites/redglow2.vmt", true);
	BeamWand_Laser = PrecacheModel("materials/sprites/laser.vmt", true);
}
public void Ruina_Set_Heirarchy(int client, int type)
{
	i_npc_type[client] = type;
	b_master_exists[client] = false;
}
public void Ruina_Set_Master_Heirarchy(int client, bool melee, bool ranged, bool accepting, int max_slaves, int priority)
{
	b_master_exists[client] = true;
	
	b_force_reasignment[client]=false;
	
	i_master_max_slaves[client] = max_slaves;
	
	b_master_is_acepting[client] = accepting;
	
	i_master_current_slaves[client] = 0;
	
	i_master_priority[client] = priority;
	
	if(melee)
		i_master_attracts[client] = 1;
	if(ranged)
		i_master_attracts[client] = 2;
	if(ranged && melee)
		i_master_attracts[client] = 3;
}

public void Ruina_Master_Release_Slaves(int client)
{
	i_master_current_slaves[client] = 0;	//reset
	b_force_reasignment[client]=true;
	b_master_is_acepting[client] = false;
	CPrintToChatAll("Master Released Slaves");
}
public void Ruina_Master_Accpet_Slaves(int client)
{
	i_master_current_slaves[client] = 0;	//reset
	b_force_reasignment[client]=false;
	b_master_is_acepting[client] = true;
	CPrintToChatAll("Master Accepting Slaves");
}
public void Ruina_NPC_OnTakeDamage_Override(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	
	if(fl_ruina_shield_power[victim]>0.0)	//does this npc have shield power?
	{
		fl_ruina_shield_power[victim] -= damage*fl_ruina_shield_strenght[victim];	//remove shield damage dependant on damage dealt
		if(fl_ruina_shield_power[victim]>=0.0)		//if the shield is still intact remove all damage
		{
			damage -= damage*fl_ruina_shield_strenght[victim];
			b_ruina_shield_active[victim] = true;
			damageForce[0] -= damageForce[0]*fl_ruina_shield_strenght[victim];	//also remove kb dependant on strenght
			damageForce[1] -= damageForce[1]*fl_ruina_shield_strenght[victim];
			damageForce[2] -= damageForce[2]*fl_ruina_shield_strenght[victim];
		}
		else	//if not, remove shield, deal the remaining damage 
		{
			damage = fl_ruina_shield_power[victim] * -1.0;
			fl_ruina_shield_power[victim] = 0.0;
			b_ruina_shield_active[victim] = false;
		}
	}
	switch(i_NpcInternalId[victim])
	{
		case RUINA_THEOCRACY:
			Theocracy_ClotDamaged(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case RUINA_ADIANTUM:
			Adiantum_ClotDamaged(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case RUINA_LANIUS:
			Lanius_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
			
		case RUINA_MAGIA:
			Magia_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	}
		
}

public void Ruina_NPCDeath_Override(int entity)
{
	
	b_master_exists[entity] = false;
	if(IsValidEntity(i_master_id[entity]) && i_master_id[entity]!=entity)	//check if the master is still valid, but block the master itself
	{
		//if so we remove a slave from there list
		i_master_current_slaves[i_master_id[entity]]--;
		//CPrintToChatAll("I died, but master was still alive: %i, now removing one, master has %i slaves left", entity, i_master_current_slaves[i_master_id[entity]]);
	}
	
	
	
	switch(i_NpcInternalId[entity])
	{
		case RUINA_THEOCRACY:
			Theocracy_NPCDeath(entity);
			
		case RUINA_ADIANTUM:
			Adiantum_NPCDeath(entity);
			
		case RUINA_LANIUS:
			Lanius_NPCDeath(entity);
			
		case RUINA_MAGIA:
			Magia_NPCDeath(entity);
			
		default:
			PrintToChatAll("This RUINA Npc Did NOT Get a Valid Internal ID! ID that was given but was invalid:[%i]", i_NpcInternalId[entity]);
	}
		
		
}
static int i_previus_priority[MAXENTITIES];
static int GetRandomMaster(int client)
{
	i_previus_priority[client] = -1;
	int valid = -1;
	for(int targ; targ<i_MaxcountNpc; targ++)
	{
		int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs[targ]);
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index])
		{
			if(Check_If_I_Am_The_Right_Slave(client, baseboss_index))
				valid=baseboss_index;
		}
	}
	return valid;
}

static bool Check_If_I_Am_The_Right_Slave(int client, int other_client)
{
	if(!b_master_exists[other_client])
		return false;
		
	if(!b_master_is_acepting[other_client])	//is the master accepting?
		return false;

	if(i_master_max_slaves[other_client]<=i_master_current_slaves[other_client])	//has the master maxed out npc's?
		return false;
		
	if(i_previus_priority[client]<i_master_priority[other_client])	//finds the one with highest priority
	{
		if(i_npc_type[client]==i_master_attracts[other_client] || i_master_attracts[other_client]==3)	//checks if the type is valid, if its 3 then both are attracted
		{
			i_previus_priority[client] = i_master_priority[other_client];
			return true;	//ayo we found a new home
		}
		else
			return false;
	}
	else
		return false;
}

public void Ruina_Master_Rally(int client, bool rally)
{
	b_master_is_rallying[client] = rally;
	/*if(rally)
		CPrintToChatAll("Master %i has initiated rally", client);
	else
		CPrintToChatAll("Master %i has stoped the rally", client);*/
}

/*
	TODO: 
	phase 1: Done
	Add a priority system, to prevent say bosses from losing guards. - Done!
	allow an ability to "release" slave npc's, eg: master calls in a group and then warps them into an enemy base - Done!
	add a "rally" ability	- Done!
	
	Phase 2: Stable enough to begin making npc's.
	Test it thoroughly, 
	- does proper asignment work? (Check_If_I_Am_The_Right_Slave)	- yes!
	- does rally work?		
	- does melee rally work?	- Yes!
	- does ranged rally work?	- most likely
	- does both rally work?		- most likely
	- does release work?	
	- is there any leaking of npc slave count? - works.
	
	Phase 3:
	- Make the npc's :)
*/

public void Ruina_Ai_Override_Core(int iNPC, int &PrimaryThreatIndex)
{
		CClotBody npc = view_as<CClotBody>(iNPC);
		
		float GameTime = GetGameTime(npc.index);
		
		int Backup_Target = PrimaryThreatIndex;
		
		if(!b_master_exists[npc.index])	//check if the npc is a master or not
		{	
			
			if(fl_master_change_timer[npc.index]<GameTime || !IsValidEntity(i_master_id[npc.index]) || b_force_reasignment[i_master_id[npc.index]])
			{
				if(fl_master_change_timer[npc.index]<GameTime && IsValidEntity(i_master_id[npc.index]))	//if the time came to reassign the current amount of slaves the master had gets reduced by 1
				{
					i_master_current_slaves[i_master_id[npc.index]]--;
					//CPrintToChatAll("Slave %i has had a timer change previus master %i now has %i slaves",npc.index, i_master_id[npc.index], i_master_current_slaves[i_master_id[npc.index]]);
				}
				
				i_master_id[npc.index] = GetRandomMaster(npc.index);
				
				if(IsValidEntity(i_master_id[npc.index]))	//only add if the master id is valid
					i_master_current_slaves[i_master_id[npc.index]]++;
				
				//if(IsValidEntity(i_master_id[npc.index]))				
				//	CPrintToChatAll("Master %i has gained a slave. current count %i",i_master_id[npc.index], i_master_current_slaves[i_master_id[npc.index]]);
				
				fl_master_change_timer[npc.index] = GameTime + RUINA_AI_CORE_REFRESH_MASTER_ID_TIMER;
				
			}
			bool b_return = false;
			if(IsValidEntity(i_master_id[npc.index]))	//get master's target
			{
				CClotBody npc2 = view_as<CClotBody>(i_master_id[npc.index]);
				PrimaryThreatIndex = npc2.m_iTarget;
			}
			else
			{
				PrimaryThreatIndex = Backup_Target;
				//CPrintToChatAll("backup target used by npc %i, target is %N", npc.index, PrimaryThreatIndex);
				b_return = true;
			}
			
			
			if(!IsValidEnemy(npc.index, PrimaryThreatIndex))	//check if its valid
			{
				PrimaryThreatIndex = Backup_Target;
				//CPrintToChatAll("backup target used by npc %i, target is %N", npc.index, PrimaryThreatIndex);
				b_return = true;
			}
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
					
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			if(b_return)	//basic movement logic for when a npc no longer possese a master
			{
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
									
					float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
						
					NPC_SetGoalVector(npc.index, vPredictedPos);
				}
				else 
				{
					NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
				}
				npc.StartPathing();
				return;
			}
			if(IsValidEntity(i_master_id[npc.index]))
			{
				switch(i_npc_type[npc.index])
				{
					case 1:	//melee, buisness as usual, just the target is the same as the masters
					{
						if(b_master_is_rallying[i_master_id[npc.index]])	//is master rallying targets to be near it?
						{
							float Master_Loc[3]; Master_Loc = WorldSpaceCenter(i_master_id[npc.index]);
							float Npc_Loc[3];	Npc_Loc = WorldSpaceCenter(npc.index);
							
							float dist = GetVectorDistance(Npc_Loc, Master_Loc, true);
							
							if(dist > (150.0 * 150.0))	//go to master until we reach this distance from master
							{
								NPC_SetGoalEntity(npc.index, i_master_id[npc.index]);
								npc.StartPathing();
								npc.m_bPathing = true;
								
							}
							else
							{
								if(flDistanceToTarget>(300.0 * 300.0))	//if master is within range we stop moving and stand still
								{
									NPC_StopPathing(npc.index);
									npc.m_bPathing = false;
								}
								else	//but if master's target is too close we attack them
								{
									//Predict their pos.
									if(flDistanceToTarget < npc.GetLeadRadius()) 
									{
										
										float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
										
										NPC_SetGoalVector(npc.index, vPredictedPos);
									}
									else 
									{
										NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
									}
									npc.StartPathing();
								}
							}
						}
						else	//no? buisness as usual
						{
							//Predict their pos.
							if(flDistanceToTarget < npc.GetLeadRadius()) 
							{
								
								float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
								
								NPC_SetGoalVector(npc.index, vPredictedPos);
							}
							else 
							{
								NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
							}
							npc.StartPathing();
						}
						
						
						
						
						return;
					}
					case 2:	//ranged, target is the same, npc moves towards the master npc
					{
						float Master_Loc[3]; Master_Loc = WorldSpaceCenter(i_master_id[npc.index]);
						float Npc_Loc[3];	Npc_Loc = WorldSpaceCenter(npc.index);
						
						float dist = GetVectorDistance(Npc_Loc, Master_Loc, true);
						
						if(dist > (100.0 * 100.0))
						{
							NPC_SetGoalEntity(npc.index, i_master_id[npc.index]);
							npc.StartPathing();
							npc.m_bPathing = true;
							
						}
						else
						{
							NPC_StopPathing(npc.index);
							npc.m_bPathing = false;
						}
							
	
						
					}
					case 3:	//for the double type just gonna use melee npc logic
					{
						if(flDistanceToTarget < npc.GetLeadRadius()) 
						{
									
							float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
									
							NPC_SetGoalVector(npc.index, vPredictedPos);
						}
						else 
						{
							NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
						}
						npc.StartPathing();
								
						return;
					}
				}
			}
			else
			{
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
							
					float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
							
					NPC_SetGoalVector(npc.index, vPredictedPos);
				}
				else 
				{
					NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
				}
				npc.StartPathing();
						
				return;
			}
		}
		else	//if its a master buisness as usual
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
				
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			if(flDistanceToTarget < npc.GetLeadRadius()) 
			{
						
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
						
				NPC_SetGoalVector(npc.index, vPredictedPos);
			}
			else 
			{
				NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
			}
			npc.StartPathing();
						
			return;
		}
}

public void Ruina_Runaway_Logic(int iNPC, int PrimaryThreatIndex)
{
	CClotBody npc = view_as<CClotBody>(iNPC);
	
	if(IsValidEntity(i_master_id[npc.index]))//do we have a master?
	{
		if(!b_master_is_rallying[i_master_id[npc.index]])	//is master rallying targets to be near it?
		{
			npc.StartPathing();
			float vBackoffPos[3];
			vBackoffPos = BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex);
			NPC_SetGoalVector(npc.index, vBackoffPos, true);
		}
	}
	else	//no?
	{
		npc.StartPathing();
		float vBackoffPos[3];
		vBackoffPos = BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex);
		NPC_SetGoalVector(npc.index, vBackoffPos, true);
	}
}

public void Apply_Master_Buff(int iNPC, bool buff_type[3], float range, float time, float amt[3])	//only works with npc's
{
	CClotBody npc = view_as<CClotBody>(iNPC);
	float pos1[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
	for(int targ; targ<i_MaxcountNpc; targ++)
	{
		int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs[targ]);
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index])
		{
			if(baseboss_index!=npc.index)
			{
				if(i_npc_type[baseboss_index]==i_master_attracts[npc.index] || i_master_attracts[npc.index]==3)	//same type of npc, or a global type
				{
					if(GetEntProp(baseboss_index, Prop_Data, "m_iTeamNum") == GetEntProp(npc.index, Prop_Data, "m_iTeamNum") && IsEntityAlive(baseboss_index))
					{
						static float pos2[3];
						GetEntPropVector(baseboss_index, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (range * range))
						{
							if(i_NpcInternalId[baseboss_index] != i_NpcInternalId[npc.index]) //cannot buff itself
							{
								if(buff_type[0])
									Apply_Defense_buff(time, baseboss_index, amt[0]);
								if(buff_type[1])
									Apply_Speed_buff(time, baseboss_index, amt[1]);
								if(buff_type[2])
									Apply_Attack_buff(time, baseboss_index, amt[2]);
							}		
						}
					}
				}
			}
		}
	}
}
/*
	f_Ruina_Speed_Buff[entity] = 0.0;
	f_Ruina_Defense_Buff[entity] = 0.0;
	f_Ruina_Attack_Buff[entity] = 0.0;
*/
static void Apply_Defense_buff(float time, int Other_Npc, float amt)
{
	float GameTime = GetGameTime();
	if(f_Ruina_Defense_Buff[Other_Npc]>GameTime)
	{
		if(amt>f_Ruina_Defense_Buff_Amt[Other_Npc])	//higher is better
		{
			f_Ruina_Defense_Buff_Amt[Other_Npc] = amt;
		}
	}
	else
	{
		f_Ruina_Defense_Buff[Other_Npc] = GameTime + time;
		f_Ruina_Defense_Buff_Amt[Other_Npc] = amt;
	}
	
}
static void Apply_Speed_buff(float time, int Other_Npc, float amt)
{
	float GameTime = GetGameTime();
	if(f_Ruina_Speed_Buff[Other_Npc]>GameTime)
	{
		if(amt>f_Ruina_Speed_Buff_Amt[Other_Npc])	//higher is better
		{
			f_Ruina_Speed_Buff_Amt[Other_Npc] = amt;
		}
	}
	else
	{
		f_Ruina_Speed_Buff[Other_Npc] = GameTime + time;
		f_Ruina_Speed_Buff_Amt[Other_Npc] = amt;
	}
}
static void Apply_Attack_buff(float time, int Other_Npc, float amt)
{
	float GameTime = GetGameTime();
	if(f_Ruina_Attack_Buff[Other_Npc]>GameTime)
	{
		if(amt>f_Ruina_Attack_Buff_Amt[Other_Npc])	//higher is better
		{
			f_Ruina_Attack_Buff_Amt[Other_Npc] = amt;
		}
	}
	else
	{
		f_Ruina_Attack_Buff[Other_Npc] = GameTime + time;
		f_Ruina_Attack_Buff_Amt[Other_Npc] = amt;
	}
}

public Action Timer_Move_Particle(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	float end_point[3];
	end_point[0] = pack.ReadCell();
	end_point[1] = pack.ReadCell();
	end_point[2] = pack.ReadCell();
	float duration = pack.ReadCell();
	
	if(IsValidEntity(entity) && entity > MaxClients)
	{
		TeleportEntity(entity, end_point, NULL_VECTOR, NULL_VECTOR);
		if (duration > 0.0)
		{
			CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Continue;
}

				 ///////////////////
				/// Wave Events ///
			   ///////////////////
/*
float speed = kv.GetFloat("ruina_ion_cannon_speed", 9.0);
float damage = kv.GetFloat("ruina_ion_cannon_damage", 1000.0);
float range = kv.GetFloat("ruina_ion_cannon_range", 250.0);
float charge_time = kv.GetFloat("ruina_ion_cannon_charge_time", 5.0);
int red = kv.GetNum("ruina_ion_cannon_red", 255);
int green = kv.GetNum("ruina_ion_cannon_green", 255);
int blue = kv.GetNum("ruina_ion_cannon_blue", 255);
int ion_amt = kv.GetNum("ruina_ion_cannon_spawn_amt", 1);	//if set to -1 it will spawn as many ions as there are players on red	
*/

static float fl_ion_current_location[MAXTF2PLAYERS+1][3];
static float fl_angle[MAXTF2PLAYERS + 1];
static float fl_ion_sound_delay[MAXTF2PLAYERS + 1];
static float fl_ion_attack_sound_delay[MAXTF2PLAYERS + 1];
static bool b_touchdown;
static bool b_kill;
static bool b_ion_active;

public Action Command_Spawn_Ruina_Cannon(int client, int args)
{
	if(b_ion_active)
	{
		CPrintToChat(client,"Ruina Ion cannon's area already active!");
	}
	else
	{
		CPrintToChat(client, "Ruina Ion Cannon's Summoned");
		Ruina_Create_Ion_Cannon(-1, 100.0, 7.5, 100.0, 255, 255, 255, 5.0);
	}
	
	
	return Plugin_Handled;
}
public Action Command_Kill_Ruina_Cannon(int client, int args)
{
	
	CPrintToChat(client, "Killed Ruina Ion Cannon's");
	b_kill = true;
	
	return Plugin_Handled;
}

public void Ruina_Create_Ion_Cannon(int amt, float damage, float speed, float range, int r, int g, int b, float charge_time)
{
	
		b_ion_active = true;
		b_kill = false;
		for(int ion=0 ; ion< MAXTF2PLAYERS ; ion++)
		{
			if(IsValidClient(ion))
			{
				fl_ion_sound_delay[ion] = 0.0;
				fl_ion_attack_sound_delay[ion] = 0.0;
				float loc[3]; GetEntPropVector(ion, Prop_Data, "m_vecAbsOrigin", loc);
				loc[0] += GetRandomFloat(350.0, -350.0);
				loc[1] += GetRandomFloat(350.0, -350.0);
				fl_ion_current_location[ion] = loc;
			}
		}
		b_touchdown = false;
		EmitSoundToAll(RUINA_ION_CANNON_SOUND_SPAWN);
		DataPack pack;
		CreateDataTimer(0.1, Ruina_Ion_Timer, pack, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
		pack.WriteCell(amt);
		pack.WriteCell(damage);
		pack.WriteCell(speed);
		pack.WriteCell(range);
		pack.WriteCell(r);
		pack.WriteCell(g);
		pack.WriteCell(b);
		pack.WriteCell(ZR_GetWaveCount()+1);
		pack.WriteCell(charge_time+GetGameTime());
		pack.WriteCell(charge_time);
		
		
}

static Action Ruina_Ion_Timer(Handle time, DataPack pack)
{
	int true_current_round = ZR_GetWaveCount() + 1;
	
	
	pack.Reset();
	int amt = pack.ReadCell();
	float damage =pack.ReadCell();
	float speed =pack.ReadCell();
	float range =pack.ReadCell();
	int r =pack.ReadCell();
	int g =pack.ReadCell();
	int b =pack.ReadCell();
	int current_round = pack.ReadCell();
	int a = 155;
	float charge_time = pack.ReadCell();
	float base_charge_time= pack.ReadCell();
	
	//int loop_for=amt;
	if(amt==-1)
	{
		amt = CountPlayersOnRed();
		//loop_for = MAXTF2PLAYERS;
	}
		
		
	if(charge_time>GetGameTime())
	{
		Ruina_Ion_Cannon_Charging(charge_time, range, r, g, b, a, base_charge_time, amt);
		return Plugin_Continue;
	}
	else
	{
		if(!b_touchdown)
		{
			b_touchdown = true;
			EmitSoundToAll(RUINA_ION_CANNON_SOUND_TOUCHDOWN);
		}
	}
	if(true_current_round!=current_round || b_kill)
	{
		b_ion_active = false;
		EmitSoundToAll(RUINA_ION_CANNON_SOUND_SHUTDOWN);
		return Plugin_Stop;	//kill ion if its not the same round anymore 
	}
	
	
	
	float start_size = 15.0;
	float end_size = 30.0;
	int colour[4];
	colour[0] = r;
	colour[1] = g;
	colour[2] = b;
	colour[3] = a;
	
	
	int ions_active = 0;
	for(int ion=1 ; ion<= MAXTF2PLAYERS ; ion++)
	{
		if(IsValidClient(ion) && IsClientInGame(ion) && GetClientTeam(ion) != 3 && IsEntityAlive(ion) && TeutonType[ion] == TEUTON_NONE && dieingstate[ion] == 0)
		{
			if(ions_active<amt)
			{
				float cur_vec[3]; cur_vec = fl_ion_current_location[ion];
				float loc[3]; GetEntPropVector(ion, Prop_Data, "m_vecAbsOrigin", loc);
				ions_active++;
				float vecAngles[3], Direction[3];
				
				
				MakeVectorFromPoints(cur_vec, loc, vecAngles);
				GetVectorAngles(vecAngles, vecAngles);
					
				GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
				ScaleVector(Direction, speed);
				AddVectors(cur_vec, Direction, cur_vec);
				
				fl_ion_current_location[ion] = cur_vec;
				
				
				
				Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, cur_vec);
				float skyloc[3]; skyloc = cur_vec; skyloc[2] += 3000.0;
				Ruina_spawnRing_Vector(cur_vec, 2.0*range, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.1, 8.0, 0.1, 1);
				
				fl_ion_sound_delay[ion]++;
				if(fl_ion_sound_delay[ion]>1.0)
				{
					fl_ion_sound_delay[ion] = 0.0;
					EmitSoundToAll(RUINA_ION_CANNON_SOUND_PASSIVE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.25, SNDPITCH_NORMAL, -1, cur_vec);
				}
					
				for(int client=1 ; client<= MAXTF2PLAYERS ; client++)
				{
					if(IsValidClient(client) && IsClientInGame(client) && GetClientTeam(client) != 3 && IsEntityAlive(client) && TeutonType[client] == TEUTON_NONE && dieingstate[client] == 0)
					{
						float loc2[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", loc2);
						float dist = GetVectorDistance(loc2, cur_vec, true);
						
						if(dist < (range * range))
						{
							float fake_damage = damage*(1.01 - (dist / (range * range)));	//reduce damage if the target just grazed it.
							
							fl_ion_attack_sound_delay[ion]++;
							if(fl_ion_attack_sound_delay[ion]>1.0)
							{
								fl_ion_attack_sound_delay[ion] = 0.0;
								EmitSoundToAll(RUINA_ION_CANNON_SOUND_ATTACK, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, cur_vec);
							}
							/*int health = GetClientHealth(client);
							health -= RoundToFloor(fake_damage);	//FUCKING TAKE DAMAGE GOD DAMMIT
							if((health) < 1)
							{
								health = 1;
							}
					
							SetEntityHealth(client, health); // Self dmg
							
							CPrintToChatAll("hit %N with %f dmg", client, fake_damage);*/
							SDKHooks_TakeDamage(client, 0, 0, fake_damage, DMG_CLUB, _, _, cur_vec);
						}
					}
				}
				cur_vec[2] -= 50.0;
				TE_SetupBeamPoints(cur_vec, skyloc, BeamWand_Laser, 0, 0, 0, 0.1, start_size, end_size, 0, 0.25, colour, 0);
				TE_SendToAll();
				TE_SetupBeamPoints(cur_vec, skyloc, BeamWand_Laser, 0, 0, 0, 0.1, start_size, end_size, 0, 0.25, colour, 0);
				TE_SendToAll();
			}
		}
	}
	
	
	return Plugin_Continue;
}
static void Ruina_Ion_Cannon_Charging(float charge_time, float range, int r, int g, int b, int a, float base_charge_time, int amt)
{
	range *= 5.0;
	int colour[4];
	colour[0] = r;
	colour[1] = g;
	colour[2] = b;
	colour[3] = a;
	int ions_active = 0;
	float GameTime = GetGameTime();
	float duration = charge_time - GameTime;
	
	range *= duration / base_charge_time;
	
	float start_size = 15.0;
	float end_size = 30.0;
	
	for(int ion=1 ; ion<= MAXTF2PLAYERS ; ion++)
	{
		if(IsValidClient(ion) && IsClientInGame(ion) && GetClientTeam(ion) != 3 && IsEntityAlive(ion) && TeutonType[ion] == TEUTON_NONE && dieingstate[ion] == 0)
		{
			if(ions_active<amt)
			{
				ions_active++;
				
				float cur_vec[3]; cur_vec = fl_ion_current_location[ion];
				Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, cur_vec);
				Ruina_spawnRing_Vector(cur_vec, range/2.5, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt" , colour[0], colour[1], colour[2], colour[3], 1, 0.1, 2.0, 1.25, 1);
				
				
				fl_ion_sound_delay[ion]++;
				if(fl_ion_sound_delay[ion]>2.0)
				{
					fl_ion_sound_delay[ion] = 0.0;
					EmitSoundToAll(RUINA_ION_CANNON_SOUND_PASSIVE_CHARGING, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.25, SNDPITCH_NORMAL, -1, cur_vec);
				}
				
				if(fl_angle[ion]>=360.0)
				{
					fl_angle[ion] = 0.0;
				}
				fl_angle[ion] += 2.5;
				float EndLoc[3];
				int amt2 = 5;
				for (int j = 0; j < amt2; j++)
				{
					float tempAngles[3], Direction[3];
					tempAngles[0] = 0.0;
					tempAngles[1] = fl_angle[ion] + (float(j) * 360.0/amt2);
					tempAngles[2] = 0.0;
						
					GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
					ScaleVector(Direction, range);
					AddVectors(cur_vec, Direction, EndLoc);
					
					Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, EndLoc);
					
					float skyloc[3]; skyloc = EndLoc; skyloc[2] += 3000.0; EndLoc[2] -= 50.0;
					TE_SetupBeamPoints(EndLoc, skyloc, BeamWand_Laser, 0, 0, 0, 0.1, start_size, end_size, 0, 0.25, colour, 0);
					TE_SendToAll();
					
					EndLoc[2] += 50.0;
					
					cur_vec[2] = EndLoc[2];
					TE_SetupBeamPoints(EndLoc, cur_vec, gLaser1, 0, 0, 0, 0.1, 5.0, 2.0, 0, 0.1, colour, 0);
					TE_SendToAll();
				}
			}
		}
	}
}
public void Ruina_Proper_To_Groud_Clip(float vecHull[3], float StepHeight, float vecorigin[3])
{
	float originalPostionTrace[3];
	float startPostionTrace[3];
	float endPostionTrace[3];
	endPostionTrace = vecorigin;
	startPostionTrace = vecorigin;
	originalPostionTrace = vecorigin;
	startPostionTrace[2] += StepHeight;
	endPostionTrace[2] -= 5000.0;

	float vecHullMins[3];
	vecHullMins = vecHull;

	vecHullMins[0] *= -1.0;
	vecHullMins[1] *= -1.0;
	vecHullMins[2] *= -1.0;

	Handle trace;
	trace = TR_TraceHullFilterEx( startPostionTrace, endPostionTrace, vecHullMins, vecHull, MASK_NPCSOLID,HitOnlyWorld, 0);
	if ( TR_GetFraction(trace) < 1.0)
	{
		// This is the point on the actual surface (the hull could have hit space)
		TR_GetEndPosition(vecorigin, trace);	
	}
	vecorigin[0] = originalPostionTrace[0];
	vecorigin[1] = originalPostionTrace[1];

	float VecCalc = (vecorigin[2] - startPostionTrace[2]);
	if(VecCalc > (StepHeight - (vecHull[2] + 2.0)) || VecCalc > (StepHeight - (vecHull[2] + 2.0)) ) //This means it was inside something, in this case, we take the normal non traced position.
	{
		vecorigin[2] = originalPostionTrace[2];
	}

	delete trace;
	//if it doesnt hit anything, then it just does buisness as usual
}
static void Ruina_spawnRing_Vector(float center[3], float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0) //Spawns a TE beam ring at a client's/entity's location
{
	center[0] += modif_X;
	center[1] += modif_Y;
	center[2] += modif_Z;
	
	int ICE_INT = PrecacheModel(sprite);
	
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = alpha;
	
	if (endRange == -69.0)
	{
		endRange = range + 0.5;
	}
	
	TE_SetupBeamRingPoint(center, range, endRange, ICE_INT, ICE_INT, 0, fps, life, width, amp, color, speed, 0);
	TE_SendToAll();
}