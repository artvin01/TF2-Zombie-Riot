#pragma semicolon 1
#pragma newdecls required

static int i_master_target_id[MAXENTITIES];
static int i_master_id_ref[MAXENTITIES];
static int i_npc_type[MAXENTITIES];

static float fl_master_change_timer[MAXENTITIES];
static bool b_master_exists[MAXENTITIES];
static int i_master_attracts[MAXENTITIES];

static bool b_npc_low_health[MAXENTITIES];
static bool b_npc_no_retreat[MAXENTITIES];
static bool b_npc_healer[MAXENTITIES];	//warp
static float fl_npc_healing_duration[MAXENTITIES];

static bool b_npc_sniper_anchor_point[MAXENTITIES];
static float fl_npc_sniper_anchor_find_timer[MAXENTITIES];
static int i_last_sniper_anchor_id_Ref[MAXENTITIES];

static int g_rocket_particle;
//static char gGlow1;	//blue

float fl_rally_timer[MAXENTITIES];
bool b_rally_active[MAXENTITIES];

static bool b_is_battery_buffed[MAXENTITIES];
float fl_ruina_battery[MAXENTITIES];
bool b_ruina_battery_ability_active[MAXENTITIES];
float fl_ruina_battery_timer[MAXENTITIES];
float fl_ruina_battery_timeout[MAXENTITIES];

float fl_ruina_helia_healing_timer[MAXENTITIES];
static float fl_ruina_internal_healing_timer[MAXENTITIES];

#define RUINA_ANCHOR_HARD_LIMIT 10
int i_magia_anchors_active;

static float fl_mana_sickness_timeout[MAXTF2PLAYERS];

float fl_ruina_in_combat_timer[MAXENTITIES];
static float fl_ruina_internal_teleport_timer[MAXENTITIES];
static bool b_ruina_allow_teleport[MAXENTITIES];
#define RUINA_ASTRIA_TELEPORT_SOUND "misc/halloween_eyeball/book_spawn.wav"

	/// Ruina Shields ///

static float fl_ruina_shield_power[MAXENTITIES];
static float fl_ruina_shield_strength[MAXENTITIES];
static float fl_ruina_shield_timer[MAXENTITIES];
static bool b_ruina_shield_active[MAXENTITIES];
static int i_shield_effect[MAXENTITIES];
float fl_ruina_shield_break_timeout[MAXENTITIES];
static int i_shield_color[3] = {0, 0, 0};			
/*
	0, 0, 0			//mostly white, and the top	| 0 0 0
	0, 255, 0 		//Green.					| 0 1 0
	0, 255, 255		//light blue				| 0 1 1
	255, 0, 255		//deep sea blue				| 1 0 1
	0, 0, 255		//lighter deep sea blue		| 0 0 1
	255, 255, 0		//nuclear green				| 1 1 0
	255, 0, 0		//red but its faint			| 1 0 0
*/

/*
	0 0 0		//Y
	0 0 1		//Y
	0 1 0		//Y
	0 1 1		//Y
	1 0 0		//Y
	1 0 1		//Y
	1 1 0		//Y
	1 1 1
*/

//these scales on wavecount
#define RUINA_NORMAL_NPC_MAX_SHIELD	 	175.0
#define RUINA_BOSS_NPC_MAX_SHIELD 		250.0
#define RUINA_RAIDBOSS_NPC_MAX_SHIELD 	1000.0
#define RUINA_SHIELD_NPC_TIMEOUT 		15.0
#define RUINA_SHIELD_ONTAKE_SOUND 		"weapons/flame_thrower_end.wav"			//does this work???


#define RUINA_POINT_MODEL	"models/props_c17/canister01a.mdl"
#define RUINA_BACKWARDS_MOVEMENT_SPEED_PENATLY		0.75	//for npc's that walk backwards, how much slower (or faster :3) should be walk
#define RUINA_FACETOWARDS_BASE_TURNSPEED			475.0	//for npc's that constantly face towards a target, how fast can they turn

static bool b_master_is_rallying[MAXENTITIES];
static bool b_force_reasignment[MAXENTITIES];
static int i_master_priority[MAXENTITIES];			//when searching for a master, the master with highest priority will get minnion's first. eg npc with Priority 1 will have lower priority then npc with priority 2
static int i_master_max_slaves[MAXENTITIES];		//how many npc's a master can hold before they stop accepting slaves
static int i_master_current_slaves[MAXENTITIES];
static bool b_master_is_acepting[MAXENTITIES];		//if a master npc no longer wants slaves this is set to false
static float fl_ontake_sound_timer[MAXENTITIES];

#define RUINA_AI_CORE_REFRESH_MASTER_ID_TIMER 30.0	//how often do the npc's try to get a new master, ignored by master refind

#define RUINA_INTERNAL_HEALING_COOLDOWN 1.0			//This is a particle effect cooldown, to prevent too many of them appearing/blinding people.
#define RUINA_INTERNAL_TELEPORT_COOLDOWN 5.0		//to prevent master npc's from teleporting the same npc 5 times in a row... also same reason as above

#define RUINA_NPC_PITCH 115


#define RUINA_BALL_PARTICLE_BLUE "drg_manmelter_trail_blue"
#define RUINA_BALL_PARTICLE_RED "drg_manmelter_trail_red"

#define RUINA_ION_CANNON_SOUND_SPAWN "ambient/machines/thumper_startup1.wav"
#define RUINA_ION_CANNON_SOUND_TOUCHDOWN "mvm/ambient_mp3/mvm_siren.mp3"
#define RUINA_ION_CANNON_SOUND_ATTACK "ambient/machines/thumper_hit.wav"
#define RUINA_ION_CANNON_SOUND_SHUTDOWN "ambient/machines/thumper_shutdown1.wav"
#define RUINA_ION_CANNON_SOUND_PASSIVE "ambient/energy/weld1.wav"
#define RUINA_ION_CANNON_SOUND_PASSIVE_CHARGING "weapons/physcannon/physcannon_charge.wav"

#define BEAM_COMBINE_BLACK	"materials/sprites/combineball_trail_black_1.vmt"

int i_laz_entity[MAXENTITIES];
float fl_multi_attack_delay[MAXENTITIES];
float fl_ruina_throttle[MAXENTITIES];

enum
{
	RUINA_GLOBAL_NPC = 0,	//global npc's, OR non ruina npc's
	RUINA_MELEE_NPC = 1,
	RUINA_RANGED_NPC = 2
}
enum
{
	RUINA_DEFENSE_BUFF		= 1,
	RUINA_SPEED_BUFF 		= 2,
	RUINA_ATTACK_BUFF		= 3,
	RUINA_SHIELD_BUFF		= 4,
	RUINA_TELEPORT_BUFF 	= 5,
	RUINA_HEALING_BUFF 		= 6,
	RUINA_BATTERY_BUFF	 	= 7
}

static char gLaser1;
int g_Ruina_BEAM_Laser;
int g_Ruina_HALO_Laser;
int g_Ruina_BEAM_Combine_Black;
int g_Ruina_BEAM_Combine_Blue;
int g_Ruina_BEAM_lightning;

public void Ruina_Ai_Core_Mapstart()
{
	Zero(fl_master_change_timer);
	Zero(i_master_target_id);
	Zero(b_master_exists);
	Zero(i_master_id_ref);
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
	Zero(fl_ruina_shield_strength);
	Zero(b_ruina_shield_active);
	Zero(i_shield_effect);
	Zero(fl_ruina_shield_break_timeout);
	Zero(fl_ontake_sound_timer);
	
	Zero(b_npc_low_health);
	Zero(b_npc_no_retreat);
	Zero(b_npc_healer);
	Zero(fl_npc_healing_duration);
	Zero(fl_ruina_helia_healing_timer);
	Zero(fl_ruina_internal_healing_timer);

	Zero(fl_ruina_internal_teleport_timer);
	Zero(b_ruina_allow_teleport);

	Zero(b_npc_sniper_anchor_point);
	Zero(fl_npc_sniper_anchor_find_timer);
	Zero(i_last_sniper_anchor_id_Ref);
	Zero(fl_ruina_in_combat_timer);

	Zero(fl_mana_sickness_timeout);
	Zero(b_is_battery_buffed);

	Zero(i_laz_entity);

	Zero(fl_multi_attack_delay);
	Zero(fl_ruina_throttle);
	
	PrecacheSound(RUINA_ION_CANNON_SOUND_SPAWN);
	PrecacheSound(RUINA_ION_CANNON_SOUND_TOUCHDOWN);
	PrecacheSound(RUINA_ION_CANNON_SOUND_ATTACK);
	PrecacheSound(RUINA_ION_CANNON_SOUND_SHUTDOWN);
	PrecacheSound(RUINA_ION_CANNON_SOUND_PASSIVE);
	PrecacheSound(RUINA_ION_CANNON_SOUND_PASSIVE_CHARGING);
	
	PrecacheSound(RUINA_SHIELD_ONTAKE_SOUND);

	PrecacheSound(RUINA_ASTRIA_TELEPORT_SOUND);

	PrecacheModel(RUINA_POINT_MODEL);

	g_rocket_particle = PrecacheModel(PARTICLE_ROCKET_MODEL);

	i_magia_anchors_active=0;
	
	PrecacheModel(BEAM_COMBINE_BLACK, true);
	
	gLaser1 = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	//gGlow1 = PrecacheModel("sprites/redglow2.vmt", true);
	g_Ruina_BEAM_Laser = PrecacheModel("materials/sprites/laser.vmt", true);
	g_Ruina_HALO_Laser = PrecacheModel("materials/sprites/halo01.vmt", true);
	g_Ruina_BEAM_Combine_Black 	= PrecacheModel("materials/sprites/combineball_trail_black_1.vmt", true);
	g_Ruina_BEAM_Combine_Blue 	= PrecacheModel("materials/sprites/combineball_trail_blue_1.vmt", true);

	g_Ruina_BEAM_lightning= PrecacheModel("materials/sprites/lgtning.vmt", true);
}
public void Ruina_Set_Heirarchy(int client, int type)
{
	fl_ruina_shield_break_timeout[client] = 0.0;
	i_npc_type[client] = type;
	i_master_attracts[client] = type;
	b_master_exists[client] = false;
	b_npc_healer[client] = false;
	b_npc_no_retreat[client] = false;
	fl_npc_healing_duration[client] = 0.0;
	b_npc_sniper_anchor_point[client]=false;
	i_last_sniper_anchor_id_Ref[client]=-1;
	fl_ruina_in_combat_timer[client]=0.0;
	b_is_battery_buffed[client]=false;

	CClotBody npc = view_as<CClotBody>(client);
	npc.m_iTarget=-1;	//set its target as invalid on spawn
	
}
public void Ruina_Set_Battery_Buffer(int client, bool state)
{
	b_is_battery_buffed[client]=state;
}
public void Ruina_Set_Sniper_Anchor_Point(int client, bool state)
{
	b_npc_sniper_anchor_point[client]=state;
}
public void Ruina_Set_Healer(int client)
{
	b_npc_healer[client] = true;
	b_npc_sniper_anchor_point[client]=true;
}
public void Ruina_Set_No_Retreat(int client)
{
	b_npc_no_retreat[client] = true;
}
public void Ruina_Set_Master_Heirarchy(int client, int type, bool accepting, int max_slaves, int priority)
{
	b_master_exists[client] = true;
	
	b_force_reasignment[client]=false;
	
	i_master_max_slaves[client] = max_slaves;
	
	b_master_is_acepting[client] = accepting;
	
	i_master_current_slaves[client] = 0;
	
	i_master_priority[client] = priority;
	
	i_master_attracts[client] = type;

	b_ruina_allow_teleport[client]=false;
}

void Ruina_Reset_Starts_Npc(int client)
{
	f_Ruina_Speed_Buff[client] = 0.0;
	f_Ruina_Defense_Buff[client] = 0.0;
	f_Ruina_Attack_Buff[client] = 0.0;
	f_Ruina_Speed_Buff_Amt[client] = 0.0;
	f_Ruina_Defense_Buff_Amt[client] = 0.0;
	f_Ruina_Attack_Buff_Amt[client] = 0.0;
}

public void Ruina_Master_Release_Slaves(int client)
{
	i_master_current_slaves[client] = 0;	//reset
	b_force_reasignment[client]=true;
	b_master_is_acepting[client] = false;
	//CPrintToChatAll("Master Released Slaves");
}
void Ruina_Master_Accpet_Slaves(int client)
{
	i_master_current_slaves[client] = 0;	//reset
	b_force_reasignment[client]=false;
	b_master_is_acepting[client] = true;
	//CPrintToChatAll("Master Accepting Slaves");
}
public void Ruina_NPC_OnTakeDamage_Override(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	float GameTime = GetGameTime();
	Ruina_Npc_Shield_Logic(victim, damage, damageForce, GameTime);
	Ruina_OnTakeDamage_Extra_Logic(victim, GameTime, damage);
}
void Ruina_Npc_Give_Shield(int client, float strenght)
{
	float GameTime = GetGameTime();
	if(fl_ruina_shield_break_timeout[client] > GameTime)
		return;
	
	Ruina_Remove_Shield(client);

	fl_ruina_shield_break_timeout[client] = GameTime + 120.0;
	
	float Shield_Power = RUINA_NORMAL_NPC_MAX_SHIELD;
	int wave =(ZR_GetWaveCount()+1);
	if(b_thisNpcIsABoss[client])
	{
		Shield_Power = RUINA_BOSS_NPC_MAX_SHIELD;
	}
	else if(b_thisNpcIsARaid[client])
	{
		Shield_Power = RUINA_RAIDBOSS_NPC_MAX_SHIELD;
	}
	Shield_Power *= wave;
	
	fl_ruina_shield_power[client] = Shield_Power;
	fl_ruina_shield_strength[client] = strenght;
	
	Ruina_Update_Shield(client);
}

static void Ruina_Npc_Shield_Logic(int victim, float &damage, float damageForce[3], float GameTime)
{
	//does this npc have shield power?
	if(fl_ruina_shield_power[victim]>0.0)	
	{
		Ruina_Update_Shield(victim);
		
		//remove shield damage dependant on damage dealt
		fl_ruina_shield_power[victim] -= damage*(1.0-fl_ruina_shield_strength[victim]);	
		//if the shield is still intact remove all damage
		if(fl_ruina_shield_power[victim]>=0.0)		
		{
			fl_TotalArmor[victim] = fl_ruina_shield_strength[victim];
			if(fl_ontake_sound_timer[victim]<=GameTime)
			{
				fl_ontake_sound_timer[victim] = GameTime + 0.25;
				EmitSoundToAll(RUINA_SHIELD_ONTAKE_SOUND, victim, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
			}
			//damage -= damage*fl_ruina_shield_strength[victim];
			b_ruina_shield_active[victim] = true;
			//also remove kb dependant on strength
			damageForce[0] = damageForce[0]*fl_ruina_shield_strength[victim];	
			damageForce[1] = damageForce[1]*fl_ruina_shield_strength[victim];
			damageForce[2] = damageForce[2]*fl_ruina_shield_strength[victim];
			
			
		}
		else	//if not, remove shield
		{
			fl_ruina_shield_power[victim] = 0.0;
			b_ruina_shield_active[victim] = false;
			Ruina_Remove_Shield(victim);
			fl_TotalArmor[victim] = 1.0;
		}
	}
	else
	{
		fl_TotalArmor[victim] = 1.0;
		Ruina_Remove_Shield(victim);
	}
}

static void Ruina_Remove_Shield(int client)
{
	int i_shield_entity = EntRefToEntIndex(i_shield_effect[client]);
	fl_TotalArmor[client] = 1.0;
	if(IsValidEntity(i_shield_entity))
	{
		fl_ruina_shield_break_timeout[client] = GetGameTime() + RUINA_SHIELD_NPC_TIMEOUT;
		RemoveEntity(i_shield_entity);
	}
}
static void Ruina_Update_Shield(int client)
{
	float Shield_Power = RUINA_NORMAL_NPC_MAX_SHIELD;
	int wave =(ZR_GetWaveCount()+1);
	if(b_thisNpcIsABoss[client])
	{
		Shield_Power = RUINA_BOSS_NPC_MAX_SHIELD;
	}
	else if(b_thisNpcIsARaid[client])
	{
		Shield_Power = RUINA_RAIDBOSS_NPC_MAX_SHIELD;
	}
	Shield_Power *= wave;
	
	float current_shield_power = fl_ruina_shield_power[client];
	
	int i_shield_entity = EntRefToEntIndex(i_shield_effect[client]);

	int alpha = RoundToFloor(255*(current_shield_power/Shield_Power));
	if(alpha > 255)
	{
		alpha = 255;
	}
	if(IsValidEntity(i_shield_entity))
	{
		SetEntityRenderMode(i_shield_entity, RENDER_TRANSCOLOR);
		SetEntityRenderColor(i_shield_entity, i_shield_color[0], i_shield_color[1], i_shield_color[2], alpha);
		return;
	}
	else
	{
		Ruina_Give_Shield(client, alpha);
		return;
	}
}
static void Ruina_Give_Shield(int client, int alpha)	//just stole this one from artvins vaus shield...
{
	CClotBody npc = view_as<CClotBody>(client);
	int Shield = npc.EquipItem("root", "models/effects/resist_shield/resist_shield.mdl");
	if(b_IsGiant[client])
		SetVariantString("1.35");
	else
		SetVariantString("1.0");

	AcceptEntityInput(Shield, "SetModelScale");
	SetEntityRenderMode(Shield, RENDER_TRANSCOLOR);
	
	SetEntityRenderColor(Shield, i_shield_color[0], i_shield_color[1], i_shield_color[2], alpha);
	SetEntProp(Shield, Prop_Send, "m_nSkin", 1);

	i_shield_effect[client] = EntIndexToEntRef(Shield);
}

public void Ruina_NPCDeath_Override(int entity)
{
	
	b_master_exists[entity] = false;
	int Master_Id_Main = EntRefToEntIndex(i_master_id_ref[entity]);
	//check if the master is still valid, but block the master itself
	if(IsValidEntity(Master_Id_Main) && Master_Id_Main!=entity)	
	{
		//if so we remove a slave from there list
		i_master_current_slaves[Master_Id_Main]--;
		//CPrintToChatAll("I died, but master was still alive: %i, now removing one, master has %i slaves left", entity, i_master_current_slaves[Master_Id_Main]);
	}
	Ruina_Remove_Shield(entity);
}
public int Ruina_Get_Target(int iNPC, float GameTime)
{
	CClotBody npc = view_as<CClotBody>(iNPC);
	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	return npc.m_iTarget;
}
static int i_previus_priority[MAXENTITIES];
static int GetRandomMaster(int client)
{
	i_previus_priority[client] = -1;
	int valid = -1;
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndex(i_ObjectsNpcsTotal[targ]);
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && GetTeam(client) == GetTeam(baseboss_index))
		{
			if(Check_If_I_Am_The_Right_Slave(client, baseboss_index))
				valid=baseboss_index;
		}
	}
	return valid;
}
static int GetClosestHealer(int client)
{
	int valid = -1;
	float Npc_Vec[3]; GetAbsOrigin(client, Npc_Vec);
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndex(i_ObjectsNpcsTotal[targ]);
		float dist = 99999999.9;
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && b_npc_healer[baseboss_index] && GetTeam(client) == GetTeam(baseboss_index))
		{
			float target_vec[3]; GetAbsOrigin(baseboss_index, target_vec);
			float Distance=GetVectorDistance(Npc_Vec, target_vec, true);
			if(dist>Distance)
			{
				valid = baseboss_index;
			}
		}
	}
	return valid;
}
static int GetClosestAnchor(int client)
{
	int valid = -1;
	float Npc_Vec[3]; GetAbsOrigin(client, Npc_Vec);
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndex(i_ObjectsNpcsTotal[targ]);
		float dist = 99999999.9;
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && b_npc_sniper_anchor_point[baseboss_index] && GetTeam(client) == GetTeam(baseboss_index))
		{
			float target_vec[3]; GetAbsOrigin(baseboss_index, target_vec);
			float Distance=GetVectorDistance(Npc_Vec, target_vec, true);
			if(dist>Distance)
			{
				valid = baseboss_index;
			}
		}
	}
	return valid;
}
static void Ruina_OnTakeDamage_Extra_Logic(int iNPC, float GameTime, float &damage)
{
	CClotBody npc = view_as<CClotBody>(iNPC);

	float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float Max_Health = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
	float Ratio = Health / Max_Health;

	//CPrintToChatAll("Health %f", Health);
	//CPrintToChatAll("Ratio %f", Ratio);
		
	//if the npc has less then 10% hp, is not a healer, and has no retreat set, they will retreat to the closest healer
	if(Ratio<=0.10 && !b_npc_healer[npc.index] && !b_npc_no_retreat[npc.index] && !b_master_exists[npc.index])	
	{
		fl_npc_healing_duration[npc.index] = GameTime + 2.5;
		//CPrintToChatAll("Healing Duration 1 %f", fl_npc_healing_duration[npc.index]);
	}

	int wave = ZR_GetWaveCount()+1;
	//whats a "switch" statement??
	if(wave<=15)	
	{

	}
	else if(wave <=30)	
	{
		
	}
	//npc's during "stage 3" get energy from taking dmg. going into its whole "sacrifice" theme.
	else if(wave <= 45)	
	{
		//turn damage taken into energy
		Ruina_Add_Battery(npc.index, damage);	
	}
	else if(wave <=60)
	{
		
	}
	else	//freeplay
	{

	}
}

static bool Check_If_I_Am_The_Right_Slave(int client, int other_client)
{
	if(!b_master_exists[other_client])
		return false;
		
	//is the master accepting?
	if(!b_master_is_acepting[other_client])
		return false;

	//has the master maxed out npc's?
	if(i_master_max_slaves[other_client]<=i_master_current_slaves[other_client])	
		return false;
		
	//finds the one with highest priority
	if(i_previus_priority[client]<i_master_priority[other_client])	
	{
		//checks if the type is valid, if its 3 then both are attracted
		if(i_npc_type[client]==i_master_attracts[other_client] || i_master_attracts[other_client]==RUINA_GLOBAL_NPC)	
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
	- does rally work?			- 
	- does melee rally work?	- Yes!
	- does ranged rally work?	- most likely
	- does both rally work?		- most likely
	- does release work?		- yes!
	- is there any leaking of npc slave count? - works. probably? yet to see it leak so far.
	
	Phase 3:
	- Make the npc's :)
*/

public void Ruina_Ai_Override_Core(int iNPC, int &PrimaryThreatIndex, float GameTime)
{
	CClotBody npc = view_as<CClotBody>(iNPC);

	if(fl_npc_healing_duration[npc.index] > GameTime )	//heal until 50% hp
	{
		float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
		float Max_Health = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
		float Ratio = Health / Max_Health;

		//CPrintToChatAll("Health %f", Health);
		//CPrintToChatAll("Ratio %f", Ratio);
		if(Ratio<0.5 && !b_npc_healer[npc.index] && !b_npc_no_retreat[npc.index] && !b_master_exists[npc.index])
		{
			int Healer = GetClosestHealer(npc.index);
			if(IsValidEntity(Healer))	//check if its valid in the first place, if not, likey healer doesn't exist
			{
				//CPrintToChatAll("Healing Duration 2 | Valid healer | %f", fl_npc_healing_duration[npc.index]);
				float Master_Loc[3]; WorldSpaceCenter(Healer, Master_Loc);
				float Npc_Loc[3];	WorldSpaceCenter(npc.index, Npc_Loc);
					
				float dist = GetVectorDistance(Npc_Loc, Master_Loc, true);

				fl_npc_healing_duration[npc.index] = GameTime + 2.5;		
				if(dist > (100.0 * 100.0))	//go to master until we reach this distance from master
				{
					NPC_SetGoalEntity(npc.index, Healer);
					npc.StartPathing();
					npc.m_bPathing = true;
					
				}
				return;
			}
		}
	}
	/*
		Masters have valid targets automatically inputed into the core due to them having the standard targeting
		Slave npc's however don't instead on spawn the have a -1 target inputed, this is ofcourse invalid, the core compensates for that.
		Simply put slave don't have the ability to find their own nearest target UNLESS they don't have a valid master, in that case they do find it.
		(Previously slave npc's legit went through all the trouble of finding the nearest target even though it would be instantly overwritten by this core. bruh)
	*/
	if(!b_master_exists[npc.index])	//check if the npc is a master or not
	{	
		int Master_Id_Main = EntRefToEntIndex(i_master_id_ref[npc.index]);
		if(fl_master_change_timer[npc.index]<GameTime || !IsValidEntity(Master_Id_Main) || b_force_reasignment[Master_Id_Main])
		{
			if(fl_master_change_timer[npc.index]<GameTime && IsValidEntity(Master_Id_Main))	//if the time came to reassign the current amount of slaves the master had gets reduced by 1
			{
				i_master_current_slaves[Master_Id_Main]--;
				//CPrintToChatAll("Slave %i has had a timer change previus master %i now has %i slaves",npc.index, Master_Id_Main, i_master_current_slaves[Master_Id_Main]);
			}
				
			int buffer_id_of_master = GetRandomMaster(npc.index);
			if(IsValidEntity(buffer_id_of_master))
			{
				i_master_id_ref[npc.index] = EntIndexToEntRef(buffer_id_of_master);
				Master_Id_Main = buffer_id_of_master;
			}
			else
			{
				Master_Id_Main = -1;
			}
				
				
			if(IsValidEntity(Master_Id_Main))	//only add if the master id is valid
			{
				i_master_current_slaves[Master_Id_Main]++;
				fl_master_change_timer[npc.index] = GameTime + RUINA_AI_CORE_REFRESH_MASTER_ID_TIMER;
			}
			else
			{
				fl_master_change_timer[npc.index] = GameTime + 2.0;
			}
				
			//if(IsValidEntity(Master_Id_Main))				
			//	CPrintToChatAll("Master %i has gained a slave. current count %i",Master_Id_Main, i_master_current_slaves[Master_Id_Main]);
				
			
				
		}
		bool b_return = false;
		if(IsValidEntity(Master_Id_Main))	//get master's target
		{
			CClotBody npc2 = view_as<CClotBody>(Master_Id_Main);
			PrimaryThreatIndex = npc2.m_iTarget;

			if(!IsValidEnemy(npc.index, PrimaryThreatIndex))	//almost final check to see if its valid, if its not, find the nearest one. there is a chance that the refind timer is still active, in this case the return logic handles it.
			{
				PrimaryThreatIndex = Ruina_Get_Target(npc.index, GameTime);
				//CPrintToChatAll("backup target used by npc %i, target is %N", npc.index, PrimaryThreatIndex);
				b_return = true;
			}
		}
		else	//if we don't have a master, use normal npc targeting logic
		{
			PrimaryThreatIndex = Ruina_Get_Target(npc.index, GameTime);
			//CPrintToChatAll("backup target used by npc %i, target is %N", npc.index, PrimaryThreatIndex);
			b_return = true;
		}
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		if(b_return)	//basic movement logic for when a npc no longer possese a master.
		{
			if(IsValidEnemy(npc.index, PrimaryThreatIndex))	//the almost final check, if it fails it forces a refind.
			{
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
									
					float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex, _,_,vPredictedPos);
							
					NPC_SetGoalVector(npc.index, vPredictedPos);
				}
				else 
				{
					NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
				}
				npc.StartPathing();
				npc.m_bPathing = true;

				Ruina_Special_Logic(npc.index, PrimaryThreatIndex);
			}
			else
			{
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_iTarget = GetClosestTarget(npc.index);
			}
			return;
		}
		else
		{
			float Master_Loc[3]; WorldSpaceCenter(Master_Id_Main, Master_Loc);
			float Npc_Loc[3];	WorldSpaceCenter(npc.index, Npc_Loc);
			switch(i_npc_type[npc.index])
			{
				case RUINA_MELEE_NPC:	//melee, buisness as usual, just the target is the same as the masters
				{
					if(b_master_is_rallying[Master_Id_Main])	//is master rallying targets to be near it?
					{
							
						float dist = GetVectorDistance(Npc_Loc, Master_Loc, true);
			
						if(dist > (150.0 * 150.0))	//go to master until we reach this distance from master
						{
							NPC_SetGoalEntity(npc.index, Master_Id_Main);
							npc.StartPathing();
							npc.m_bPathing = true;

							Ruina_Special_Logic(npc.index, Master_Id_Main);
								
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
										
									float vPredictedPos[3];  PredictSubjectPosition(npc, PrimaryThreatIndex, _,_,vPredictedPos);
										
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
								
							float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex, _,_,vPredictedPos);
							
							NPC_SetGoalVector(npc.index, vPredictedPos);
						}
						else 
						{
							NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
						}

						Ruina_Special_Logic(npc.index, PrimaryThreatIndex);

						npc.StartPathing();
					}	
					return;
				}
				case RUINA_RANGED_NPC:	//ranged, target is the same, npc moves towards the master npc
				{
						
					float dist = GetVectorDistance(Npc_Loc, Master_Loc, true);
						
					if(dist > (100.0 * 100.0))
					{
						NPC_SetGoalEntity(npc.index, Master_Id_Main);
						npc.StartPathing();
						npc.m_bPathing = true;

						Ruina_Special_Logic(npc.index, Master_Id_Main);
						
					}
					else
					{
						NPC_StopPathing(npc.index);
						npc.m_bPathing = false;
					}	
				}
				//for the double type just gonna use melee npc logic
				case RUINA_GLOBAL_NPC:	
				{
					if(flDistanceToTarget < npc.GetLeadRadius()) 
					{
									
						float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex, _,_, vPredictedPos);
									
						NPC_SetGoalVector(npc.index, vPredictedPos);
					}
					else 
					{
						NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
					}
					npc.StartPathing();

					Ruina_Special_Logic(npc.index, PrimaryThreatIndex);
								
					return;
				}
			}
		}
	}
	else	//if its a master buisness as usual
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex, _,_,vPredictedPos);

			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
		}
		Ruina_Special_Logic(npc.index, PrimaryThreatIndex);
		npc.StartPathing();
						
		return;
	}
}
public void Ruina_Basic_Npc_Logic(int iNPC, int PrimaryThreatIndex, float GameTime)	//this is here if I ever want to make "basic" npc's do anything special
{
	CClotBody npc = view_as<CClotBody>(iNPC);

	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
				
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(flDistanceToTarget < npc.GetLeadRadius()) 
	{
		float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex, _,_,vPredictedPos);
		
		NPC_SetGoalVector(npc.index, vPredictedPos);
	}
	else 
	{
		NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
	}
	npc.StartPathing();
}
public void Ruina_Independant_Long_Range_Npc_Logic(int iNPC, int PrimaryThreatIndex, float GameTime, int &Anchor_Id)
{
	CClotBody npc = view_as<CClotBody>(iNPC);

	
	Anchor_Id = EntRefToEntIndex(i_last_sniper_anchor_id_Ref[npc.index]);

	if(fl_npc_sniper_anchor_find_timer[npc.index] < GameTime)
	{
		fl_npc_sniper_anchor_find_timer[npc.index] = GameTime + 5.0;

		Anchor_Id = GetClosestAnchor(npc.index);

		if(IsValidEntity(Anchor_Id))
		{
			i_last_sniper_anchor_id_Ref[npc.index]= EntIndexToEntRef(Anchor_Id);
		}
	}
	if(IsValidEntity(Anchor_Id))
	{
		float Master_Loc[3]; WorldSpaceCenter(Anchor_Id, Master_Loc);
		float Npc_Loc[3];	WorldSpaceCenter(npc.index, Npc_Loc);
						
		float dist = GetVectorDistance(Npc_Loc, Master_Loc, true);
						
		if(dist > (225.0 * 225.0))
		{
			NPC_SetGoalEntity(npc.index, Anchor_Id);
			npc.StartPathing();
			npc.m_bPathing = true;

			Ruina_Special_Logic(npc.index, Anchor_Id);
					
		}
		else
		{
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
		}	
	}
	else
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_,vPredictedPos);
			
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
		}
		npc.StartPathing();
	}
}
int i_ruina_Projectile_Particle[MAXENTITIES];
float fl_ruina_Projectile_dmg[MAXENTITIES];
float fl_ruina_Projectile_radius[MAXENTITIES];
float fl_ruina_Projectile_bonus_dmg[MAXENTITIES];
Function Func_Ruina_Proj_Touch[MAXENTITIES];

/*
	Ruina_Projectiles ICBM;

					ICBM.iNPC = npc.index;
					ICBM.Start_Loc = flPos;
					float Ang[3];
					MakeVectorFromPoints(flPos, target_vec, Ang);
					GetVectorAngles(Ang, Ang);
					ICBM.color = {255,255,255,255};
					ICBM.Angles = Ang;
					ICBM.speed = 1000.0;
					ICBM.radius = 250.0;
					ICBM.damage = 500.0;
					ICBM.bonus_dmg = 2.5;
					ICBM.Time = 10.0;
					ICBM.visible = false;
					ICBM.Launch_ICBM(Func_On_Projectile_Boom);

	static void Func_On_Projectile_Boom(int projectile, float damage, float radius, float Loc[3])
{
	CPrintToChatAll("Kaboom!");
}
*/
enum struct Ruina_Projectiles
{
	int iNPC;				//index of the one spawning this.
	float Start_Loc[3];		//
	float Angles[3];		//
	int color[4];			//affects the colour of the model
	float speed;			//
	float radius;			//
	float damage;			//self explanitory
	float bonus_dmg;		//what dmg to deal if it hits an enemy thats meant to take bonus dmg
	float Time;				//how long it exists before being deleted
	bool visible;			//Make model invis?

	int Projectile_Index;

	int Launch_Projectile(Function Custom_Projectile_Touch = INVALID_FUNCTION)
	{	
		float Velocity[3];

		this.Velocity(Velocity);

		int entity = CreateEntityByName("zr_projectile_base");
		if(IsValidEntity(entity))
		{
			this.Projectile_Index = entity;
			SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", Velocity);

			fl_ruina_Projectile_dmg[entity] = this.damage;
			fl_ruina_Projectile_radius[entity] = this.radius;
			fl_ruina_Projectile_bonus_dmg[entity] = this.bonus_dmg;
			Func_Ruina_Proj_Touch[entity] = Custom_Projectile_Touch;
			
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.iNPC);
			SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
			SetTeam(entity, GetTeam(this.iNPC));
			
			TeleportEntity(entity, this.Start_Loc, this.Angles, NULL_VECTOR, true);
			DispatchSpawn(entity);

			if(!this.visible)
			{
				for(int i; i<4; i++) //This will make it so it doesnt override its collision box.
				{
					SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_rocket_particle, _, i);
				}
				SetEntityModel(entity, PARTICLE_ROCKET_MODEL);
		
				//Make it entirely invis. Shouldnt even render these 8 polygons.
				SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") &~ EF_NODRAW);

				SetEntityRenderMode(entity, RENDER_TRANSCOLOR); //Make it entirely invis.
				SetEntityRenderColor(entity, 255, 255, 255, 0);
			}

			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, Velocity, true);
			SetEntityCollisionGroup(entity, 24); //our savior
			Set_Projectile_Collision(entity); //If red, set to 27
			
			g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Ruina_RocketExplodePre);
		//	SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
			SDKHook(entity, SDKHook_StartTouch, Ruina_Projectile_Touch);

			

			if(this.Time>0.0)
			{
				CreateTimer(this.Time, Remove_Projectile_Timer, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
			}
			return entity;
		}
		return -1;
	}
	int Apply_Particle(char[] Particle_Path)
	{
		int particle = ParticleEffectAt(this.Start_Loc, Particle_Path, 0.0); //Inf duartion

		if(!IsValidEntity(particle))
			return -1;

		i_ruina_Projectile_Particle[this.Projectile_Index]= EntIndexToEntRef(particle);
		TeleportEntity(particle, NULL_VECTOR, this.Angles, NULL_VECTOR);
		SetParent(this.Projectile_Index, particle);	
		SetEntityRenderMode(this.Projectile_Index, RENDER_TRANSCOLOR); //Make it entirely invis.
		SetEntityRenderColor(this.Projectile_Index, 255, 255, 255, 0);

		return particle;
	}
	float Size;
	int Apply_Model(char[] Model_Path)
	{
		int ModelApply = ApplyCustomModelToWandProjectile(this.Projectile_Index, Model_Path, this.Size, "icbm_idle");

		if(!IsValidEntity(ModelApply))
			return -1;

		if(this.color[0])
		{
			SetEntityRenderColor(ModelApply, this.color[0], this.color[1], this.color[2], this.color[3]);
		}
		else
		{
			SetEntityRenderColor(ModelApply, 255, 255, 255, 1);
		}
		
		return ModelApply;
	}
	void Velocity(float Vel[3])
	{
		Vel[0] = Cosine(DegToRad(this.Angles[0]))*Cosine(DegToRad(this.Angles[1]))*this.speed;
		Vel[1] = Cosine(DegToRad(this.Angles[0]))*Sine(DegToRad(this.Angles[1]))*this.speed;
		Vel[2] = Sine(DegToRad(this.Angles[0]))*-this.speed;
	}
}
void Ruina_Projectile_Touch(int entity, int target)
{
	Function func = Func_Ruina_Proj_Touch[entity];

	if(func==INVALID_FUNCTION)
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(!IsValidEntity(owner))
		{
			owner = 0;
		}
			
		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);

		Explode_Logic_Custom(fl_ruina_Projectile_dmg[entity] , owner , owner , -1 , ProjectileLoc , fl_ruina_Projectile_radius[entity] , _ , _ , true, _,_, fl_ruina_Projectile_bonus_dmg[entity]);

		Ruina_Remove_Projectile(entity);
	}
	else
	{
		if(func)
		{	
			Call_StartFunction(null, func);
			Call_PushCell(entity);
			Call_PushCell(target);
			Call_Finish();
		}
	}
	
}
static Action Remove_Projectile_Timer(Handle Timer, int Ref)
{
	int ICBM = EntRefToEntIndex(Ref);

	if(IsValidEntity(ICBM))
	{
		Ruina_Remove_Projectile(ICBM);
	}

	return Plugin_Stop;
}
void Ruina_Remove_Projectile(int entity)
{
	int particle = EntRefToEntIndex(i_ruina_Projectile_Particle[entity]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
	}
	RemoveEntity(entity);
}
public MRESReturn Ruina_RocketExplodePre(int entity)
{
	return MRES_Supercede;	//Don't even think about it mate
}
enum struct Ruina_Self_Defense
{
	int iNPC;
	int target;
	float fl_distance_to_target;
	float range;
	float damage;
	float bonus_dmg;
	char attack_anim[255];
	float swing_speed;
	float swing_delay;
	float turn_speed;
	float gameTime;
	int status;

	void Swing_Melee(Function OnAttack = INVALID_FUNCTION)
	{
		CClotBody npc = view_as<CClotBody>(this.iNPC);

		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < this.gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				Handle swingTrace;
				float target_vec[3]; WorldSpaceCenter(this.target, target_vec);
				npc.FaceTowards(target_vec, this.turn_speed);
				if(npc.DoSwingTrace(swingTrace, this.target)) 
				{				
					int new_target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(IsValidEnemy(npc.index, new_target))
					{
						if(!ShouldNpcDealBonusDamage(new_target))
						{
							SDKHooks_TakeDamage(new_target, npc.index, npc.index, this.damage, DMG_CLUB, -1, _, vecHit);
						}
						else
							SDKHooks_TakeDamage(new_target, npc.index, npc.index, this.bonus_dmg, DMG_CLUB, -1, _, vecHit);

						this.status=2;

						if(OnAttack && OnAttack!=INVALID_FUNCTION)
						{
							Call_StartFunction(null, OnAttack);
							Call_PushCell(npc.index);
							Call_PushCell(new_target);
							Call_Finish();
						}
					} 
					else
					{
						this.status=3;
					}
				}
				delete swingTrace;
			}
		}

		if(this.gameTime > npc.m_flNextMeleeAttack)
		{
			if(this.fl_distance_to_target < this.range)
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, this.target);
						
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					this.status=1;
					if(this.attack_anim[0])
						npc.AddGesture(this.attack_anim);

					fl_ruina_in_combat_timer[npc.index]=this.gameTime+5.0;
							
					npc.m_flAttackHappens = this.gameTime + this.swing_delay;
					npc.m_flNextMeleeAttack = this.gameTime + this.swing_speed;
				}
			}
		}
	}
}

static float fl_mana_sickness_multi[MAXENTITIES];
static int i_mana_sickness_flat[MAXENTITIES];
static bool b_override_Sickness[MAXENTITIES];
void Ruina_AOE_Add_Mana_Sickness(float Loc[3], int iNPC, float range, float Multi, int flat_amt=0, bool override = false)
{
	fl_mana_sickness_multi[iNPC] = Multi;
	i_mana_sickness_flat[iNPC] = flat_amt;
	b_override_Sickness[iNPC] = override;
	Explode_Logic_Custom(0.0, iNPC, iNPC, -1, Loc, range, _, _, true, 99, false, _, Ruina_Apply_Mana_Debuff);
}
void Ruina_Apply_Mana_Debuff(int entity, int victim, float damage, int weapon)
{
	if(!IsValidClient(victim))
		return;

	if(GetTeam(victim) != TFTeam_Red)
		return;

	float GameTime = GetGameTime();

	bool override = b_override_Sickness[entity];
	
	if(fl_mana_sickness_timeout[victim] > GameTime && !override)
		return;
		
	float Multi = fl_mana_sickness_multi[entity];
	int flat_amt = i_mana_sickness_flat[entity];
	float OverMana_Ratio = Current_Mana[victim]/max_mana[victim];

	b_override_Sickness[entity] = false;

	Current_Mana[victim] += RoundToCeil(max_mana[victim]*Multi+flat_amt);

	if(OverMana_Ratio>2.0)
	{
		Apply_Sickness(entity, victim);
	}
}
stock void Ruina_Add_Mana_Sickness(int iNPC, int Target, float Multi, int flat_amt=0, bool override = false)
{
	if(IsValidClient(Target))
	{
		float GameTime = GetGameTime();

		if(fl_mana_sickness_timeout[Target] > GameTime && !override)
			return;

		float OverMana_Ratio = Current_Mana[Target]/max_mana[Target];

		Current_Mana[Target] += RoundToCeil(max_mana[Target]*Multi+flat_amt);

		if(OverMana_Ratio>2.0)
		{
			Apply_Sickness(iNPC, Target);
		}
	}
}
//Once target has too much mana, aka 2x their max, an ION cannon that does true damage that scales on how much max mana they have is fired
static void Apply_Sickness(int iNPC, int Target)
{
	//Override means that it WILL IGNORE the grace timeout period.
	Current_Mana[Target] = 0;
	float GameTime = GetGameTime();

	int wave = ZR_GetWaveCount()+1;

	float 	dmg 		= 250.0,
			time 		= 2.5,		//how long until it goes boom
			Timeout	 	= 5.0,		//how long is the grace period for the mana sickness
			Slow_Time	= 2.0,		//how long the slowdown lasts
			Radius		= 100.0;	//self explanitory

	float mana = max_mana[Target];

	int color[4];

	if(mana <=400.0)	//a base mana asumption
		mana=400.0;

	if(wave<=15)
	{
		Radius		= 100.0;
		dmg 		= mana;	//evil.
		time 		= 5.0;
		Timeout 	= 6.0;
		Slow_Time 	= 5.0;
	}
	else if(wave<=30)
	{
		Radius		= 125.0;
		dmg 		= mana*1.25;
		time 		= 4.5;
		Timeout 	= 5.5;
		Slow_Time 	= 5.0;
	}
	else if(wave<=45)
	{
		Radius		= 175.0;
		dmg 		= mana*1.5;
		time 		= 4.0;
		Timeout 	= 5.0;
		Slow_Time 	= 5.5;
	}
	else
	{
		Radius		= 200.0;
		dmg 		= mana*2.0;
		time 		= 3.0;
		Timeout 	= 4.5;
		Slow_Time 	= 6.0;
	}

	Ruina_Color(color);

	fl_mana_sickness_timeout[Target] = GameTime + Timeout;

	Mana_Regen_Delay[Target] = GameTime + Timeout;
	Mana_Regen_Block_Timer[Target] = GameTime + Timeout;

	TF2_StunPlayer(Target, Slow_Time, 0.75, TF_STUNFLAG_SLOWDOWN);

	float end_point[3];
	GetClientAbsOrigin(Target, end_point);
	end_point[2]+=5.0;

	Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, end_point);

	float Thickness = 6.0;
	TE_SetupBeamRingPoint(end_point, Radius*2.0, 0.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, time, Thickness, 0.75, color, 1, 0);
	TE_SendToAll();
	TE_SetupBeamRingPoint(end_point, Radius*2.0, Radius*2.0+0.5, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, time, Thickness, 0.1, color, 1, 0);
	TE_SendToAll();

	DataPack pack;
	CreateDataTimer(time, Ruina_Mana_Sickness_Ion, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(GetTeam(iNPC));
	pack.WriteFloatArray(end_point, sizeof(end_point));
	pack.WriteCellArray(color, sizeof(color));
	pack.WriteFloat(Radius);
	pack.WriteFloat(dmg);

	float Sky_Loc[3]; Sky_Loc = end_point; Sky_Loc[2]+=500.0; end_point[2]-=100.0;

	int laser;
	laser = ConnectWithBeam(-1, -1, color[0], color[1], color[2], 4.0, 4.0, 5.0, BEAM_COMBINE_BLACK, end_point, Sky_Loc);

	CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
}
void Ruina_Color(int color[4])
{
	int wave = ZR_GetWaveCount()+1;
	if(wave<=15)
	{
		color 	= {255, 0, 0, 255};
	}
	else if(wave<=30)
	{
		color 	= {255, 150, 150, 255};
	}
	else if(wave<=45)
	{	
		color 	= {255, 200, 200, 255};
	}
	else
	{
		color 	= {255, 255, 255, 255};
	}
}
Action Ruina_Mana_Sickness_Ion(Handle Timer, DataPack data)
{
	data.Reset();
	int Team = data.ReadCell();
	float end_point[3];
	int color[4];
	data.ReadFloatArray(end_point, sizeof(end_point));
	data.ReadCellArray(color, sizeof(color));
	float Radius	= data.ReadFloat();
	float dmg 		= data.ReadFloat();

	//DMG_SLASH is true dmg?

	float Thickness = 6.0;
	TE_SetupBeamRingPoint(end_point, 0.0, Radius*2.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, 0.75, Thickness, 0.75, color, 1, 0);
	TE_SendToAll();

	Radius = Radius*Radius;

	for(int client = 1; client <= MaxClients; client++)
	{
		if(view_as<CClotBody>(client).m_bThisEntityIgnored)
			continue;
		
		if(!IsClientInGame(client))
		 	continue;	

		if(!IsEntityAlive(client))
			continue;
		
		if(GetTeam(client) == Team)
			continue;
		
		float Vic_Pos[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", Vic_Pos);

		if(GetVectorDistance(Vic_Pos, end_point, true) > Radius)
			continue;

		SDKHooks_TakeDamage(client, 0, 0, dmg, DMG_SLASH|DMG_PREVENT_PHYSICS_FORCE);

		int laser;
		laser = ConnectWithBeam(-1, client, color[0], color[1], color[2], 2.5, 2.5, 0.25, BEAM_COMBINE_BLACK, end_point);
		CreateTimer(0.1, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
	}
	for(int a; a < i_MaxcountNpcTotal; a++)
	{
		int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[a]);
		if(entity != INVALID_ENT_REFERENCE && !view_as<CClotBody>(entity).m_bThisEntityIgnored && !b_NpcIsInvulnerable[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity] && IsEntityAlive(entity))
		{
			if(GetTeam(entity) == Team)
				continue;

			float Vic_Pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", Vic_Pos);

			if(GetVectorDistance(Vic_Pos, end_point, true) > Radius)
				continue;

			SDKHooks_TakeDamage(entity, 0, 0, dmg*2.0, DMG_SLASH|DMG_PREVENT_PHYSICS_FORCE);

			int laser;
			laser = ConnectWithBeam(-1, entity, color[0], color[1], color[2], 2.5, 2.5, 0.25, BEAM_COMBINE_BLACK, end_point);
			CreateTimer(0.1, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	for(int a; a < i_MaxcountBuilding; a++)
	{
		int entity = EntRefToEntIndex(i_ObjectsBuilding[a]);
		if(entity != INVALID_ENT_REFERENCE)
		{
			if(!b_ThisEntityIgnored[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity])
			{
				float Vic_Pos[3];
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", Vic_Pos);

				if(GetVectorDistance(Vic_Pos, end_point, true) > Radius)
					continue;

				SDKHooks_TakeDamage(entity, 0, 0, dmg*2.0, DMG_SLASH|DMG_PREVENT_PHYSICS_FORCE);
				int laser;
				laser = ConnectWithBeam(-1, entity, color[0], color[1], color[2], 2.5, 2.5, 0.25, BEAM_COMBINE_BLACK, end_point);
				CreateTimer(0.1, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}

	float Sky_Loc[3]; Sky_Loc = end_point; Sky_Loc[2]+=1000.0; end_point[2]-=100.0;

	int laser;
	laser = ConnectWithBeam(-1, -1, color[0], color[1], color[2], 7.0, 7.0, 1.0, BEAM_COMBINE_BLACK, end_point, Sky_Loc);
	CreateTimer(1.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
	laser = ConnectWithBeam(-1, -1, color[0], color[1], color[2], 5.0, 5.0, 0.1, LASERBEAM, end_point, Sky_Loc);
	CreateTimer(1.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Stop;
}
Action Ruina_Generic_Ion(Handle Timer, DataPack data)
{
	data.Reset();
	int iNPC =EntRefToEntIndex(data.ReadCell());
	float end_point[3];
	int color[4];
	data.ReadFloatArray(end_point, sizeof(end_point));
	data.ReadCellArray(color, sizeof(color));
	float Radius	= data.ReadFloat();
	float dmg 		= data.ReadFloat();
	float Sickness_Multi = data.ReadFloat();
	int Sickness_flat 	= data.ReadCell();
	bool Override = data.ReadCell();

	if(!IsValidEntity(iNPC))
		return Plugin_Stop;
	/*
	stock void Explode_Logic_Custom(float damage,
int client,
int entity,
int weapon,
float spawnLoc[3] = {0.0,0.0,0.0},
float explosionRadius = EXPLOSION_RADIUS,
float ExplosionDmgMultihitFalloff = EXPLOSION_AOE_DAMAGE_FALLOFF,
float explosion_range_dmg_falloff = EXPLOSION_RANGE_FALLOFF,
bool FromBlueNpc = false,
int maxtargetshit = 10,
bool ignite = false,
float dmg_against_entity_multiplier = 3.0,
Function FunctionToCallOnHit = INVALID_FUNCTION,
Function FunctionToCallBeforeHit = INVALID_FUNCTION,
int inflictor = 0)
	*/

	Explode_Logic_Custom(dmg, iNPC, iNPC, -1, _, Radius, _, _, true, _, _, 2.0);

	if(Sickness_flat || Sickness_Multi)
		Ruina_AOE_Add_Mana_Sickness(end_point, iNPC, Radius, Sickness_Multi, Sickness_flat,Override);

	float Thickness = 6.0;
	TE_SetupBeamRingPoint(end_point, 0.0, Radius*2.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, 0.75, Thickness, 0.75, color, 1, 0);
	TE_SendToAll();



	float Sky_Loc[3]; Sky_Loc = end_point; Sky_Loc[2]+=1000.0; end_point[2]-=100.0;

	int laser;
	laser = ConnectWithBeam(-1, -1, color[0], color[1], color[2], 7.0, 7.0, 1.0, BEAM_COMBINE_BLACK, end_point, Sky_Loc);
	CreateTimer(1.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
	laser = ConnectWithBeam(-1, -1, color[0], color[1], color[2], 5.0, 5.0, 0.1, LASERBEAM, end_point, Sky_Loc);
	CreateTimer(1.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Stop;
}
public void Ruina_Add_Battery(int iNPC, float Amt)
{
	CClotBody npc = view_as<CClotBody>(iNPC);

	if(NpcStats_IsEnemySilenced(npc.index))
		Amt*=0.75;

	fl_ruina_battery[npc.index] += Amt;
}
public void Ruina_Runaway_Logic(int iNPC, int PrimaryThreatIndex)
{
	CClotBody npc = view_as<CClotBody>(iNPC);
	if(fl_npc_healing_duration[npc.index] > GetGameTime(npc.index))
		return;

	int Master_Id_Main = EntRefToEntIndex(i_master_id_ref[npc.index]);
	if(IsValidEntity(Master_Id_Main))//do we have a master?
	{
		if(!b_master_is_rallying[Master_Id_Main])	//is master rallying targets to be near it?
		{
			npc.StartPathing();
			float vBackoffPos[3];
			BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex,_,vBackoffPos);
			NPC_SetGoalVector(npc.index, vBackoffPos, true);
			
		}
		else
		{
			npc.m_bAllowBackWalking=false;
		}
	}
	else	//no?
	{
		npc.StartPathing();
		float vBackoffPos[3];
		BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex,_,vBackoffPos);
		NPC_SetGoalVector(npc.index, vBackoffPos, true);
	}
}
#define RUINA_BUFF_AMTS 5
public void Helia_Healing_Logic(int iNPC, int Healing, float Range, float GameTime, float cylce_speed, int color[4])
{
	CClotBody npc = view_as<CClotBody>(iNPC);

	if(fl_ruina_helia_healing_timer[npc.index]<=GameTime)
	{
		float npc_Loc[3]; GetAbsOrigin(npc.index, npc_Loc); npc_Loc[2]+=10.0;
		float Thickness = 6.0;
		TE_SetupBeamRingPoint(npc_Loc, Range*2.0, 0.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, cylce_speed, Thickness, 0.5, color, 1, 0);
		TE_SendToAll();
		
		fl_ruina_helia_healing_timer[npc.index]=cylce_speed+GameTime;
		Apply_Master_Buff(npc.index, RUINA_HEALING_BUFF, Range, 0.0, float(Healing), true);
	}
}
static void Helia_Healing_Buff(int baseboss_index, float Power)
{
	int Healing = RoundToFloor(Power);

	CClotBody npc = view_as<CClotBody>(baseboss_index);

	

	int Current_Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	int Max_Health = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");

	//if we have overheal, don't bother
	if(Current_Health > Max_Health)
		return;

	int Healed_Health = Current_Health + Healing;

	if(Healed_Health >= Max_Health)
	{
		Healed_Health = Max_Health;
	}

	SetEntProp(npc.index, Prop_Data, "m_iHealth", Healed_Health);

	//Todo: Test if this works properly!

	float GameTime = GetGameTime(npc.index);

	if(fl_ruina_internal_healing_timer[npc.index]>GameTime)
		return;

	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	WorldSpaceVec[2]-=25.0;

	fl_ruina_internal_healing_timer[npc.index]=GameTime+RUINA_INTERNAL_HEALING_COOLDOWN;

	char Particle[30];
	
	switch(GetRandomInt(0,2))
	{
		case 0:
			Particle = "spell_cast_wheel_red";
		case 1:
			Particle = "spell_cast_wheel_blue";
	}
	int Healing_Effect = ParticleEffectAt_Parent(WorldSpaceVec, Particle, npc.index, "", {0.0,0.0,0.0});

	CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(Healing_Effect), TIMER_FLAG_NO_MAPCHANGE);
}
public void Astria_Teleport_Allies(int iNPC, float Range, int colour[4])
{
	CClotBody npc = view_as<CClotBody>(iNPC);

	float npc_Loc[3]; GetAbsOrigin(npc.index, npc_Loc); npc_Loc[2]+=2.5;	
	float Thickness = 6.0;
	TE_SetupBeamRingPoint(npc_Loc, Range*2.0, 0.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, 0.5, Thickness, 0.5, colour, 1, 0);
	TE_SendToAll();
	Apply_Master_Buff(npc.index, RUINA_TELEPORT_BUFF, Range, 0.0, 0.0);
}
static void Astria_Teleportation(int iNPC, int PrimaryThreatIndex)
{
	CClotBody npc = view_as<CClotBody>(iNPC);

	float GameTime = GetGameTime(npc.index);

	if(fl_ruina_internal_teleport_timer[npc.index]>GameTime || NpcStats_IsEnemySilenced(npc.index))
	{
		return;
	}

	fl_ruina_internal_teleport_timer[npc.index]=GameTime + RUINA_INTERNAL_TELEPORT_COOLDOWN;

	float vPredictedPos[3]; 

	if(IsValidAlly(npc.index, PrimaryThreatIndex))
	{
		WorldSpaceCenter(PrimaryThreatIndex, vPredictedPos);	//teleport ontop of their heads :trolley:
		vPredictedPos[2]+=100.0;
	}
	else
	{
		PredictSubjectPosition(npc, PrimaryThreatIndex,_,_,vPredictedPos);	//otherwise just normal buisness xd
	}
	

	float Loc[3];
	GetAbsOrigin(npc.index, Loc);
	Loc[2]+=75.0;

	float start_offset[3], end_offset[3];
	WorldSpaceCenter(npc.index, start_offset);

	bool Succeed = NPC_Teleport(npc.index, vPredictedPos);
	if(Succeed)
	{	
		EmitSoundToAll(RUINA_ASTRIA_TELEPORT_SOUND, npc.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

		b_ruina_allow_teleport[npc.index]=false;
		float npc_Loc[3]; GetAbsOrigin(npc.index, npc_Loc); npc_Loc[2]+=10.0;
		float Range = 250.0;
		float Thickness = 6.0;
		TE_SetupBeamRingPoint(npc_Loc, Range*2.0, 0.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, 0.5, Thickness, 0.5, {30, 230, 226, 200}, 1, 0);
		TE_SendToAll();
		int entity = Ruina_Create_Entity_Specific(Loc, _ , 2.45);
		if(IsValidEntity(entity))
		{
			Ruina_AttachParticle(entity, "spell_cast_wheel_blue", 2.4, "nozzle");
			//Ruina_Move_Entity(entity, Loc, 5.0);
		}
		float effect_duration = 0.25;
	
		end_offset = vPredictedPos;
							
		start_offset[2]-= 25.0;
		end_offset[2] -= 25.0;
							
		for(int help=1 ; help<=8 ; help++)
		{	
			Astria_Teleport_Effect(RUINA_BALL_PARTICLE_RED, effect_duration, start_offset, end_offset);
							
			start_offset[2] += 12.5;
			end_offset[2] += 12.5;
		}
	}
}
static void Astria_Teleport_Effect(char type[255], float duration = 0.0, float start_point[3], float end_point[3])
{
	int part1 = CreateEntityByName("info_particle_system");
	if(IsValidEdict(part1))
	{
		TeleportEntity(part1, start_point, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(part1, "effect_name", type);
		SetVariantString("!activator");
		DispatchSpawn(part1);
		ActivateEntity(part1);
		AcceptEntityInput(part1, "Start");
		
		DataPack pack;
		CreateDataTimer(0.1, Timer_Move_Particle, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(part1));
		pack.WriteCell(end_point[0]);
		pack.WriteCell(end_point[1]);
		pack.WriteCell(end_point[2]);
		pack.WriteCell(duration);
	}
}
public void Master_Apply_Defense_Buff(int client, float range, float time, float power)
{
	Apply_Master_Buff(client, RUINA_DEFENSE_BUFF, range, time, power);
}

public void Master_Apply_Speed_Buff(int client, float range, float time, float power)
{
	Apply_Master_Buff(client, RUINA_SPEED_BUFF, range, time, power);
}

public void Master_Apply_Attack_Buff(int client, float range, float time, float power)
{
	Apply_Master_Buff(client, RUINA_ATTACK_BUFF, range, time, power);
}

public void Master_Apply_Shield_Buff(int client, float range, float power)
{
	Apply_Master_Buff(client, RUINA_SHIELD_BUFF, range, 0.0, power);
}
public void Master_Apply_Battery_Buff(int client, float range, float power)
{
	Apply_Master_Buff(client, RUINA_BATTERY_BUFF, range, 0.0, power);
}
void Ruina_Special_Logic(int iNPC, int Target)
{
	if(b_ruina_allow_teleport[iNPC])
	{
		Astria_Teleportation(iNPC, Target);
		return;
	}
}

static float fl_buff_amt[MAXENTITIES];
static float fl_buff_time[MAXENTITIES];
static bool b_buff_override[MAXENTITIES];

/*
	Should work with non ruina npc's - NOT TESTED YET!
*/
static void Apply_Master_Buff(int iNPC, int buff_type, float range, float time, float amt, bool Override=false)
{
	CClotBody npc = view_as<CClotBody>(iNPC);
	
	if(NpcStats_IsEnemySilenced(npc.index))
		return;
	
	b_buff_override[npc.index] = Override;

	switch(buff_type)
	{
		case RUINA_DEFENSE_BUFF:
		{
			b_NpcIsTeamkiller[npc.index] = true;
			fl_buff_amt[npc.index] = amt;
			fl_buff_time[npc.index] = time;
			Explode_Logic_Custom(0.0, npc.index, npc.index, -1, _, range, _, _, true, 99, false, _, Ruina_Apply_Defense_buff);
			b_NpcIsTeamkiller[npc.index] = false;
		}
		case RUINA_SPEED_BUFF:
		{
			b_NpcIsTeamkiller[npc.index] = true;
			fl_buff_amt[npc.index] = amt;
			fl_buff_time[npc.index] = time;
			Explode_Logic_Custom(0.0, npc.index, npc.index, -1, _, range, _, _, true, 99, false, _, Ruina_Apply_Speed_buff);
			b_NpcIsTeamkiller[npc.index] = false;
		}
		case RUINA_ATTACK_BUFF:
		{
			b_NpcIsTeamkiller[npc.index] = true;
			fl_buff_amt[npc.index] = amt;
			fl_buff_time[npc.index] = time;
			Explode_Logic_Custom(0.0, npc.index, npc.index, -1, _, range, _, _, true, 99, false, _, Ruina_Apply_Attack_buff);
			b_NpcIsTeamkiller[npc.index] = false;
		}
		case RUINA_SHIELD_BUFF:
		{
			b_NpcIsTeamkiller[npc.index] = true;
			fl_buff_amt[npc.index] = amt;
			Explode_Logic_Custom(0.0, npc.index, npc.index, -1, _, range, _, _, true, 99, false, _, Ruina_Shield_Buff);
			b_NpcIsTeamkiller[npc.index] = false;
		}
		case RUINA_HEALING_BUFF:
		{
			b_NpcIsTeamkiller[npc.index] = true;
			fl_buff_amt[npc.index] = amt;
			Explode_Logic_Custom(0.0, npc.index, npc.index, -1, _, range, _, _, true, 99, false, _, Ruina_Healing_Buff);
			b_NpcIsTeamkiller[npc.index] = false;
		}
		case RUINA_TELEPORT_BUFF:
		{
			b_NpcIsTeamkiller[npc.index] = true;
			Explode_Logic_Custom(0.0, npc.index, npc.index, -1, _, range, _, _, true, 99, false, _, Ruina_Teleport_Buff);
			b_NpcIsTeamkiller[npc.index] = false;
		}
		case RUINA_BATTERY_BUFF:
		{
			fl_buff_amt[npc.index] = amt;
			b_NpcIsTeamkiller[npc.index] = true;
			Explode_Logic_Custom(0.0, npc.index, npc.index, -1, _, range, _, _, true, 99, false, _, Ruina_Battery_Buff);
			b_NpcIsTeamkiller[npc.index] = false;
		}
	}
}
public void Ruina_Battery_Buff(int entity, int victim, float damage, int weapon)
{
	if(entity==victim)
		return;	//don't buff itself!

	if(GetTeam(entity) != GetTeam(victim))
		return;
	
	//don't buff the batteries of other battery buffers otherwise a snowball effect might ocur
	if(b_is_battery_buffed[victim])	
		return;
	
	Ruina_Add_Battery(victim, fl_buff_amt[entity]);
}
public void Ruina_Shield_Buff(int entity, int victim, float damage, int weapon)
{
	if(entity==victim)
		return;	//don't buff itself!

	if(GetTeam(entity) != GetTeam(victim))
		return;

	//same type of npc, or a global type
	if(i_npc_type[victim]==i_master_attracts[entity] || (i_master_attracts[entity]==RUINA_GLOBAL_NPC || b_buff_override[entity]))	
	{
		float amt = fl_buff_amt[entity];
		Ruina_Npc_Give_Shield(victim, amt);
	}
}
public void Ruina_Teleport_Buff(int entity, int victim, float damage, int weapon)
{
	if(entity==victim)
		return;	//don't buff itself!

	if(GetTeam(entity) != GetTeam(victim))
		return;

	//same type of npc, or a global type
	if(i_npc_type[victim]==i_master_attracts[entity] || (i_master_attracts[entity]==RUINA_GLOBAL_NPC || b_buff_override[entity]))	
	{
		b_ruina_allow_teleport[victim]=true;
	}
}
public void Ruina_Healing_Buff(int entity, int victim, float damage, int weapon)
{
	if(entity==victim)
		return;	//don't buff itself!

	if(GetTeam(entity) != GetTeam(victim))
		return;

	//same type of npc, or a global type
	if(i_npc_type[victim]==i_master_attracts[entity] || (i_master_attracts[entity]==RUINA_GLOBAL_NPC || b_buff_override[entity]))	
	{
		float amt = fl_buff_amt[entity];
		Helia_Healing_Buff(victim, amt);
	}
}
/*
	f_Ruina_Speed_Buff[entity] = 0.0;
	f_Ruina_Defense_Buff[entity] = 0.0;
	f_Ruina_Attack_Buff[entity] = 0.0;
*/
public void Ruina_Apply_Defense_buff(int entity, int victim, float damage, int weapon)
{
	if(entity==victim)
		return;	//don't buff itself!

	if(GetTeam(entity) != GetTeam(victim))
		return;

	//same type of npc, or a global type
	if(i_npc_type[victim]==i_master_attracts[entity] || (i_master_attracts[entity]==RUINA_GLOBAL_NPC || b_buff_override[entity]))	
	{
		float time = fl_buff_time[entity];
		float amt = fl_buff_amt[entity];
		float GameTime = GetGameTime();
		if(f_Ruina_Defense_Buff[victim]>GameTime)
		{
			if(amt>f_Ruina_Defense_Buff_Amt[victim])	//higher is better
			{
				f_Ruina_Defense_Buff_Amt[victim] = amt;
			}
		}
		else
		{
			f_Ruina_Defense_Buff_Amt[victim] = amt;
		}
		f_Ruina_Defense_Buff[victim] = GameTime + time;

	}
	
}
public void Ruina_Apply_Speed_buff(int entity, int victim, float damage, int weapon)
{
	if(entity==victim)
		return;	//don't buff itself!
	
	if(GetTeam(entity) != GetTeam(victim))
		return;
	

	//same type of npc, or a global type
	if(i_npc_type[victim]==i_master_attracts[entity] || (i_master_attracts[entity]==RUINA_GLOBAL_NPC || b_buff_override[entity]))	
	{
		float time = fl_buff_time[entity];
		float amt = fl_buff_amt[entity];

		float GameTime = GetGameTime();
		if(f_Ruina_Speed_Buff[victim]>GameTime)
		{
			if(amt>f_Ruina_Speed_Buff_Amt[victim])	//higher is better
			{
				f_Ruina_Speed_Buff_Amt[victim] = amt;
			}
		}
		else
		{
			f_Ruina_Speed_Buff_Amt[victim] = amt;
		}
		f_Ruina_Speed_Buff[victim] = GameTime + time;
	}
}
public void Ruina_Apply_Attack_buff(int entity, int victim, float damage, int weapon)
{
	if(entity==victim)
		return;	//don't buff itself!

	if(GetTeam(entity) != GetTeam(victim))
		return;

	//same type of npc, or a global type
	if(i_npc_type[victim]==i_master_attracts[entity] || (i_master_attracts[entity]==RUINA_GLOBAL_NPC || b_buff_override[entity]))	
	{
		float time = fl_buff_time[entity];
		float amt = fl_buff_amt[entity];

		float GameTime = GetGameTime();
		if(f_Ruina_Attack_Buff[victim]>GameTime)
		{
			if(amt>f_Ruina_Attack_Buff_Amt[victim])	//higher is better
			{
				f_Ruina_Attack_Buff_Amt[victim] = amt;
			}
		}
		else
		{
			
			f_Ruina_Attack_Buff_Amt[victim] = amt;
		}
		f_Ruina_Attack_Buff[victim] = GameTime + time;
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

//todo: DOESNT HAVE A PLUGIN_STOP;
//note: just redo this entire thing, ive gone past the need for TE's to make ions. plus this thing sucks
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
				
				int color[4];
				color[0] = r;
				color[1] = g;
				color[2] = b;
				color[3] = a;
				float Thickness = 8.0;
				TE_SetupBeamRingPoint(cur_vec, range*2.0, range*2.0+1.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, 0.1, Thickness, 0.1, color, 1, 0);
				TE_SendToAll();
				
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
							float Dmg = damage;

							float falloffmax = 0.80;	//it will deal only 20% of the original dmg at max range!
							float falloffstart = range*0.5;
							if (dist > falloffstart)		//reduce damage if the target just grazed it.
							{
								float diff = dist - falloffstart;
								float rad = range - falloffstart;
								
								Dmg *= 1.0 - ((diff/rad) * falloffmax);
							}

							fl_ion_attack_sound_delay[ion]++;
							if(fl_ion_attack_sound_delay[ion]>1.0)
							{
								fl_ion_attack_sound_delay[ion] = 0.0;
								EmitSoundToAll(RUINA_ION_CANNON_SOUND_ATTACK, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, cur_vec);
							}

							SDKHooks_TakeDamage(client, 0, 0, Dmg, DMG_CLUB, _, _, cur_vec);
						}
					}
				}
				cur_vec[2] -= 50.0;
				TE_SetupBeamPoints(cur_vec, skyloc, g_Ruina_BEAM_Laser, 0, 0, 0, 0.1, start_size, end_size, 0, 0.25, colour, 0);
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
				
				float Thickness = 8.0;
				TE_SetupBeamRingPoint(cur_vec, range/2.5, range/2.5+1.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, 0.1, Thickness, 0.1, colour, 1, 0);
				TE_SendToAll();
				
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
					TE_SetupBeamPoints(EndLoc, skyloc, g_Ruina_BEAM_Laser, 0, 0, 0, 0.1, start_size, end_size, 0, 0.25, colour, 0);
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
static int Ruina_AttachParticle(int entity, char type[255], float duration = 0.0, char point[255], float zTrans = 0.0)
{
	if (IsValidEntity(entity))
	{
		int part1 = CreateEntityByName("info_particle_system");
		if (IsValidEdict(part1))
		{
			float pos[3];
			if (HasEntProp(entity, Prop_Data, "m_vecAbsOrigin"))
			{
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
			}
			else if (HasEntProp(entity, Prop_Send, "m_vecOrigin"))
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
			}
			
			if (zTrans != 0.0)
			{
				pos[2] += zTrans;
			}
			
			TeleportEntity(part1, pos, NULL_VECTOR, NULL_VECTOR);
			DispatchKeyValue(part1, "effect_name", type);
			SetVariantString("!activator");
			AcceptEntityInput(part1, "SetParent", entity, part1);
			SetVariantString(point);
			AcceptEntityInput(part1, "SetParentAttachmentMaintainOffset", part1, part1);
			DispatchKeyValue(part1, "targetname", "present");
			DispatchSpawn(part1);
			ActivateEntity(part1);
			AcceptEntityInput(part1, "Start");
			
			if (duration > 0.0)
			{
				CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(part1), TIMER_FLAG_NO_MAPCHANGE);
			}
			return part1;
		}
		else
		{
			return -1;
		}
	}
	return -1;
}

static int Ruina_Create_Entity_Specific(float Loc[3], int old_particle=-1, float time=0.0)
{
	if(!IsValidEntity(old_particle))
	{
		//i_laser_particle_index[client][cycle]= EntIndexToEntRef(ParticleEffectAt({0.0,0.0,0.0}, "", 0.0));
		int particle_new = Ruina_Create_Entity(Loc, time);
		return particle_new;
	}
	else
	{
		return old_particle;
	}
}
int Ruina_Create_Entity(float Loc[3], float duration, int noclip = false)
{
	int prop = CreateEntityByName("prop_physics_override");
	
	if (IsValidEntity(prop))
	{
	
		DispatchKeyValue(prop, "model", RUINA_POINT_MODEL);
		
		DispatchKeyValue(prop, "modelscale", "0.001");
		
		DispatchKeyValue(prop, "solid", "0"); 
		
		DispatchSpawn(prop);
		
		ActivateEntity(prop);
		
		SetEntProp(prop, Prop_Send, "m_fEffects", 32); //EF_NODRAW
		
		MakeObjectIntangeable(prop);
		
		if(noclip)
		{
			SetEntityMoveType(prop, MOVETYPE_NOCLIP);
		}

		if(duration > 0.0)
		{
			CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
		}

		TeleportEntity(prop, Loc, NULL_VECTOR, NULL_VECTOR);
		
		return prop;
	}
	else
	{
		return -1;
	}
}

static int Ruina_Laser_BEAM_HitDetected[MAXENTITIES];
static int i_targets_hit;
enum struct Ruina_Laser_Logic
{
	int client;
	float Start_Point[3];
	float End_Point[3];
	float Radius;
	float Damage;
	float Bonus_Damage;
	int damagetype;

	bool trace_hit;
	bool trace_hit_enemy;

	/*
		Todo: 
			If needed, add a trace version that only triggers a void instead of also dealing damage.
			Test it fully, should work, but just incase, need to try and break it.
	*/

	void DoForwardTrace_Basic(float Dist=-1.0)
	{
		float Angles[3], startPoint[3], Loc[3];
		WorldSpaceCenter(this.client, startPoint);
		GetEntPropVector(this.client, Prop_Data, "m_angRotation", Angles);
		CClotBody npc = view_as<CClotBody>(this.client);
		int iPitch = npc.LookupPoseParameter("body_pitch");
				
		float flPitch = npc.GetPoseParameter(iPitch);
		flPitch *= -1.0;
		Angles[0] = flPitch;

		Handle trace = TR_TraceRayFilterEx(startPoint, Angles, 11, RayType_Infinite, Ruina_Laser_BEAM_TraceWallsOnly);

		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(Loc, trace);
			delete trace;


			if(Dist !=-1.0)
			{
				ConformLineDistance(Loc, startPoint, Loc, Dist);
			}
			this.Start_Point = startPoint;
			this.End_Point = Loc;
			this.trace_hit=true;
		}
		else
		{
			delete trace;
		}
	}
	void DoForwardTrace_Custom(float Angles[3], float startPoint[3], float Dist=-1.0)
	{
		float Loc[3];
		Handle trace = TR_TraceRayFilterEx(startPoint, Angles, 11, RayType_Infinite, Ruina_Laser_BEAM_TraceWallsOnly);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(Loc, trace);
			delete trace;


			if(Dist !=-1.0)
			{
				ConformLineDistance(Loc, startPoint, Loc, Dist);
			}
			this.Start_Point = startPoint;
			this.End_Point = Loc;
			this.trace_hit=true;
		}
		else
		{
			delete trace;
		}
	}

	void Deal_Damage(Function Attack_Function = INVALID_FUNCTION)
	{

		Zero(Ruina_Laser_BEAM_HitDetected);

		i_targets_hit = 0;	//todo: test this! | so far works!

		float hullMin[3], hullMax[3];
		hullMin[0] = -this.Radius;
		hullMin[1] = hullMin[0];
		hullMin[2] = hullMin[0];
		hullMax[0] = -hullMin[0];
		hullMax[1] = -hullMin[1];
		hullMax[2] = -hullMin[2];

		Handle trace = TR_TraceHullFilterEx(this.Start_Point, this.End_Point, hullMin, hullMax, 1073741824, Ruina_Laser_BEAM_TraceUsers);	// 1073741824 is CONTENTS_LADDER?
		delete trace;

				
		for (int loop = 0; loop < i_targets_hit; loop++)
		{
			int victim = Ruina_Laser_BEAM_HitDetected[loop];
			if (victim && IsValidEnemy(this.client, victim))
			{
				this.trace_hit_enemy=true;

				float playerPos[3];
				WorldSpaceCenter(victim, playerPos);

				float Dmg = this.Damage;

				if(ShouldNpcDealBonusDamage(victim))
					Dmg = this.Bonus_Damage;
				
				SDKHooks_TakeDamage(victim, this.client, this.client, Dmg, this.damagetype, -1, _, playerPos);

				if(Attack_Function && Attack_Function != INVALID_FUNCTION)
				{	
					Call_StartFunction(null, Attack_Function);
					Call_PushCell(this.client);
					Call_PushCell(victim);
					Call_PushCell(this.damagetype);
					Call_PushFloat(this.Damage);
					Call_Finish();

					//static void On_LaserHit(int client, int target, int damagetype, float damage)
				}
			}
		}
	}
}

static bool Ruina_Laser_BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}
static bool Ruina_Laser_BEAM_TraceUsers(int entity, int contentsMask)
{
	if (IsEntityAlive(entity))
	{
		for(int i=0 ; i < MAXENTITIES ; i++)
		{
			if(!Ruina_Laser_BEAM_HitDetected[i])
			{
				i_targets_hit++;
				Ruina_Laser_BEAM_HitDetected[i] = entity;
				break;
			}
		}
	}
	return false;
}
/*
static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}
*/
	/// Custom Hand Particles or body or wings or halo or whatnot ///

#define RUINA_MAX_PARTICLE_ENTS 15

//Current highest particle amt: 15.

int i_particle_ref_id[MAXENTITIES][RUINA_MAX_PARTICLE_ENTS];
int i_laser_ref_id[MAXENTITIES][RUINA_MAX_PARTICLE_ENTS];

void Ruina_Clean_Particles(int client)
{
	for(int i=0 ; i < RUINA_MAX_PARTICLE_ENTS; i++)
	{
		int laser = EntRefToEntIndex(i_laser_ref_id[client][i]);
		int particle = EntRefToEntIndex(i_particle_ref_id[client][i]);

		if(IsValidEntity(laser))
			RemoveEntity(laser);
		if(IsValidEntity(particle))
			RemoveEntity(particle);

		i_particle_ref_id[client][i] = INVALID_ENT_REFERENCE;
		i_laser_ref_id[client][i] = INVALID_ENT_REFERENCE;
	}
}
/*
void Ruina_Move_Entity(int entity, float loc[3], float Ang[3], bool old=false)
{
	if(IsValidEntity(entity))	
	{
		if(old)
		{
			//the version bellow creates some "funny" movements/interactions..
			float vecView[3], vecFwd[3], Entity_Loc[3], vecVel[3];
					
			MakeVectorFromPoints(Entity_Loc, loc, vecView);
			GetVectorAngles(vecView, vecView);
			
			float dist = GetVectorDistance(Entity_Loc, loc);

			GetAngleVectors(vecView, vecFwd, NULL_VECTOR, NULL_VECTOR);
		
			Entity_Loc[0]+=vecFwd[0] * dist;
			Entity_Loc[1]+=vecFwd[1] * dist;
			Entity_Loc[2]+=vecFwd[2] * dist;
			
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vecFwd);
			
			SubtractVectors(Entity_Loc, vecFwd, vecVel);
			ScaleVector(vecVel, 10.0);

			TeleportEntity(entity, NULL_VECTOR, Ang, vecVel);
		}
		else
		{
			float flNewVec[3], flRocketPos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flRocketPos);
			float Ratio = (GetVectorDistance(loc, flRocketPos))/250.0;

			if(Ratio<0.075)
				Ratio=0.075;

			float flSpeedInit = 1250.0*Ratio;
		
			SubtractVectors(loc, flRocketPos, flNewVec);
			NormalizeVector(flNewVec, flNewVec);
			
			float flAng[3];
			GetVectorAngles(flNewVec, flAng);
			
			ScaleVector(flNewVec, flSpeedInit);
			TeleportEntity(entity, NULL_VECTOR, Ang, flNewVec);
		}
	}
}*/
/*
static void Ruina_Teleport_Entity(int entity, float loc[3])
{
	if(IsValidEntity(entity))	
		TeleportEntity(entity, loc, NULL_VECTOR, NULL_VECTOR);
}*/

/*

Add sound effects to mana sickness ION's

Mana Sickness:
Its a special effect for ruina.
If a player gets more then 2x thier max mana, an ION cannon is fired onto their location, the stats scale on the current "stage"
Additionally, they get slowed a bit, and lose all their mana alongside their mana regen being blocked.

Names per stage:
	Stage 1 -> Stage 2 -> Stage 3 -> Starge 4.

	Each subsequent stage the npc gains a new ability, most of the time it will be an expanded version of what they have, or something new. alongside just higher base stats.

	//created
	1: Magia -> Magnium -> Magianas -> Magianius
	{
		State: Slave AI
		Class: Medic.
		Ranged.
		Retreats from enemies.
		Battery: Buff's nearby Ranged npc's speed

		Stage 1: Done.
		Stage 2: Done
		Stage 3: Null
		Stage 4: Null

		Magnia:
		{
			Fire 2 projectils in a row, with a reload between them
			ICBM: Gains the ability to launch a "homing" projectile rocket.
			Additionally: while the battery boost is active fired projectiles have homing
		}
	}
	//created
	2: Lanius -> Laniun -> Loonaris -> Loonarionus
	{

		State: Slave AI
		Class: Scout.
		Melee.
		Teleporting.
		Battery: Buff's nearby Melee npc's speed

		Stage 1: Done.
		Stage 2: Done.
		Stage 3: Null
		Stage 4: Null

		Laniun:
		{
			Is just stronger variant + Teleport deals damage to targets hit
		}


	}
	//created
	3: Helia -> Heliara -> Heliaris -> Heliarionus
	{
		state: Independant AI.
		Class: Medic
		Support: Healer
		Heals nearby npc's within range in a AOE.
		Battery: Massive AOE healing for 2.5 seconds

		Stage 1: Done.
		Stage 2: Done.
		Stage 3: Null
		Stage 4: Null

		Stellaria
		{
			is just stronger variant
		}
	}
	//created
	4: Astria -> Astriana -> Astrianis -> Astrianious
	{
		state: Master AI.
		Class: Engie
		Slow itself, boots nearby npc speed passively.
		Battery: Nearby npc's gain the ability to teleport once. cannot have multiple "charges" (since its a bool)

		Stage 1: Done.
		Stage 2: Done.
		Stage 3: Null
		Stage 4: Null

		Astriana
		{
			is simply stronger.
		}
	}

	//created
	5: Europa -> Europis -> Eurainis -> Euranionis
	{
		State: Master AI.
		Class: Pyro.
		Summons "brainless" npc's
		Battery: Summons itself.

		Stage 1: Done.
		Stage 2: Done.
		Stage 3: Null	
		Stage 4: Null

		Europis
		{
			Battery: Alongside summoning itself, it boosts the speed of ruina npc's in a small radius. this is heavy boost, lasts for a while	
			Also the summon now includes Magia and Lanius from the previous stage.
		}
	}
	//created
	6: Daedalus -> Draedon -> Draeonis -> Draconia
	{
		State: Slave.
		Class: Scout
		Support: Shield.
		Battery: Provides shield to npc's within range.

		Stage 1: Done.
		Stage 2: Done. 
		Stage 3: Null
		Stage 4: Null

		Draedon
		{
			Its just a buffed version.
		}
	}
	//created
	7: Aether -> Aetheria -> Aetherium -> Aetherianus
	{
		State: Slave - Indepentant Long range.
		Class: Sniper
		Ranged:

		Attacks from a far with artilery spells. basically the railgunners of this wave.

		Stage 1: Done.
		Stage 2: Done.
		Stage 3: Null
		Stage 4: Null

		Aetheria
		{
			battery: gains the ability to shoot a laser projectile of D00M
		}
	}
	//created
	8: Malius -> Maliana -> Malianium -> Malianius.
	{
		State: Master AI.
		Class: Engie
		Support: Battery
		Battery: Gives a set amt of battery to nearby npc's

		Stage 1: Done.
		Stage 2: Done.	
		Stage 3: Null
		Stage 4: Null

		Maliana
		{
			Is a stronger variant, does an animation and stands still while casting the battery buff.
		}

		Maliana:

		Npc's within range have their passive battery gain boosted
	}
	//created
	9: Ruriana -> Ruianus -> Ruliana -> Ruina
	{
		State: Master AI.
		Class: Medic.
		Ranged, Melee.
		Passive: damage taken is healed to allies around.

		Stage 1: Done.
		Stage 2: Done.
		Stage 3: Null
		Stage 4: Null

		Ruianus
		{
			Every 20 seconds fire a fantasmal wave.
			This fantasmal wave can be dodged by simply jumping over it.
			Additionally, a portion of the damage dealt by this wave is transfered over to the healing amount.
		}
	}
	10: Laz -> Lazius -> Lazines -> Lazurus
	{
		State: Master AI.
		Class: Demo.
		Ranged: Laser.

		Stage 1: Done.	Laz
		Stage 2: Done.	Lazius
		Stage 3: Null	Lazines
		Stage 4: Null	Lazurus

		Lazius
		{
			battery: shoot a stronger variant of the laser, has better homing too
		}
	}
	//created
	11: Drone -> Dronian -> Dronis -> Dronianis
	{
		State: Melee AI.
		Class: Spy
		Melee.
		it only exists as a minnion to be spammed. it has nothing special for now

		Stage 1: Done.
		Stage 2: Done.
		Stage 3: Null
		Stage 4: Null

		Dronian
		{
			is just a stronger variant
		}
	}

	Todo: Rewrite these. mostly the anchor and Valiant. as for the weaver, mostly how it attacks.
	Valiant	//Gonna be set into special, like expi spies.
	{
		State: Independant
		Class: Engie
		Has the ability to build a special building that once built spawns drones and maintains an ION
	}
	Building: "Magia Anchor"
	{
		spawns drones respective to the stage.
		controls a special ION, 1 ion per stage.
		A maximum of 4 of them can exist at a time.
		once 4 exist, they have the abiltiy to summon a "Storm Weaver"
	}
	Special: "Storm Weaver":
	{
		A worm boss, it itself doesn't have a hitbox.
	}


	Stage 1 specials:

	Adiantum - Boss. W14, W15.

	Theocracy - Boss. W15

	Stage 2 specials:

	Stage 3 specials:

	Stage 4 specials:


*/

stock void Lanius_Teleport_Effect(char[] type, float duration = 0.0, float start_point[3], float end_point[3])
{
	int part1 = CreateEntityByName("info_particle_system");
	if(IsValidEdict(part1))
	{
		TeleportEntity(part1, start_point, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(part1, "effect_name", type);
		SetVariantString("!activator");
		DispatchSpawn(part1);
		ActivateEntity(part1);
		AcceptEntityInput(part1, "Start");
		
		DataPack pack;
		CreateDataTimer(0.1, Timer_Move_Particle, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(part1));
		pack.WriteCell(end_point[0]);
		pack.WriteCell(end_point[1]);
		pack.WriteCell(end_point[2]);
		pack.WriteCell(duration);
	}
}