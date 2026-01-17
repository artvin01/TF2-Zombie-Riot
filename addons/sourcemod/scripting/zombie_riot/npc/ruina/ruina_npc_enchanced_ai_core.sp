#pragma semicolon 1
#pragma newdecls required

#define LASERBEAM "sprites/laserbeam.vmt"

static int i_master_target_id[MAXENTITIES];
static int i_master_id_ref[MAXENTITIES];
static int i_npc_type[MAXENTITIES];

static float fl_master_change_timer[MAXENTITIES];
static bool b_is_a_master[MAXENTITIES];
static int i_master_attracts[MAXENTITIES];

static bool b_npc_low_health[MAXENTITIES];
static bool b_npc_no_retreat[MAXENTITIES];
bool b_ruina_npc_healer[MAXENTITIES];	//warp
static float fl_npc_healing_duration[MAXENTITIES];

static bool b_npc_sniper_anchor_point[MAXENTITIES];
static float fl_npc_sniper_anchor_find_timer[MAXENTITIES];
static int i_last_sniper_anchor_id_Ref[MAXENTITIES];

static bool b_ruina_npc[MAXENTITIES];

//static char gGlow1;	//blue

float fl_rally_timer[MAXENTITIES];
bool b_rally_active[MAXENTITIES];

static bool b_is_battery_buffed[MAXENTITIES];
bool b_ruina_battery_ability_active[MAXENTITIES];
float fl_ruina_battery_timer[MAXENTITIES];
float fl_ruina_battery_timeout[MAXENTITIES];

float fl_ruina_helia_healing_timer[MAXENTITIES];



static float fl_mana_sickness_timeout[MAXPLAYERS];

float fl_ruina_in_combat_timer[MAXENTITIES];
static float fl_ruina_internal_teleport_timer[MAXENTITIES];
static bool b_ruina_allow_teleport[MAXENTITIES];
#define RUINA_ASTRIA_TELEPORT_SOUND "misc/halloween_eyeball/book_spawn.wav"

	/// Ruina Shields ///

static float fl_ruina_shield_timer[MAXENTITIES];
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

float fl_ruina_buff_amt[MAXENTITIES];
float fl_ruina_buff_time[MAXENTITIES];
bool b_ruina_buff_override[MAXENTITIES];
bool b_ruina_nerf_healing[MAXENTITIES];

#define RUINA_NORMAL_NPC_MAX_SHIELD	 	0.25
#define RUINA_BOSS_NPC_MAX_SHIELD 		0.15
#define RUINA_RAIDBOSS_NPC_MAX_SHIELD 	0.1
#define RUINA_SHIELD_NPC_TIMEOUT 		7.5
#define RUINA_SHIELD_ONTAKE_SOUND 		"weapons/flame_thrower_end.wav"			//does this work???


#define RUINA_POINT_MODEL	"models/props_c17/canister01a.mdl"
#define RUINA_BACKWARDS_MOVEMENT_SPEED_PENALTY		0.7		//for npc's that walk backwards, how much slower (or faster :3) should be walk
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

#define RUINA_ION_CANNON_SOUND_SPAWN 				"ambient/machines/thumper_startup1.wav"
#define RUINA_ION_CANNON_SOUND_TOUCHDOWN 			"ambient/machines/thumper_hit.wav"
#define RUINA_ION_CANNON_SOUND_ATTACK 				"ambient/machines/thumper_dust.wav"

#define BEAM_COMBINE_BLACK	"materials/sprites/combineball_trail_black_1.vmt"
#define BEAM_COMBINE_BLUE	"materials/sprites/combineball_trail_blue_1.vmt"
#define BEAM_DIAMOND 		"materials/sprites/physring1.vmt"

int i_Ruina_Overlord_Ref;

int i_laz_entity[MAXENTITIES];
float fl_multi_attack_delay[MAXENTITIES];
float fl_ruina_throttle[MAXENTITIES];

enum
{
	RUINA_GLOBAL_NPC = 1,
	RUINA_MELEE_NPC = 2,
	RUINA_RANGED_NPC = 3
}
enum
{
	RUINA_DEFENSE_BUFF		= 1,
	RUINA_SPEED_BUFF 		= 2,
	RUINA_ATTACK_BUFF		= 3,
	RUINA_SHIELD_BUFF		= 4,
	RUINA_TELEPORT_BUFF 	= 5,
	RUINA_BATTERY_BUFF	 	= 6
}

//static char gLaser1;
int g_Ruina_Laser_BEAM;
int g_Ruina_BEAM_Diamond;
int g_Ruina_BEAM_Laser;
int g_Ruina_BEAM_Glow;
int g_Ruina_HALO_Laser;
int g_Ruina_BEAM_Combine_Black;
int g_Ruina_BEAM_Combine_Blue;
int g_Ruina_BEAM_lightning;
char g_Ruina_Glow_Blue;	//blue
char g_Ruina_Glow_Red;	//red

static char g_EnergyChargeSounds[][] = {
	"weapons/airboat/airboat_gun_energy1.wav",
	"weapons/airboat/airboat_gun_energy2.wav",
};
char g_Ruina_MagicAttackSounds[][] = {
	"ambient/energy/zap3.wav",
	"ambient/energy/zap7.wav",
	"ambient/energy/zap8.wav",
	"ambient/energy/zap9.wav"
};

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return -1;
}

void Ruina_Ai_Core_Mapstart()
{
	NPCData data1;
	strcopy(data1.Name, sizeof(data1.Name), "Mana Overload");
	strcopy(data1.Plugin, sizeof(data1.Plugin), "npc_donoteveruse_3");
	data1.Category = Type_Ruina;
	data1.Func = ClotSummon;
	strcopy(data1.Icon, sizeof(data1.Icon), ""); 						//leaderboard_class_(insert the name)
	data1.IconCustom = false;											//download needed?
	data1.Flags = 0;													//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data1);

	NPCData data2;
	strcopy(data2.Name, sizeof(data2.Name), "Master System");
	strcopy(data2.Plugin, sizeof(data2.Plugin), "npc_donoteveruse_4");
	data2.Category = Type_Ruina;
	data2.Func = ClotSummon;
	strcopy(data2.Icon, sizeof(data2.Icon), ""); 						//leaderboard_class_(insert the name)
	data2.IconCustom = false;											//download needed?
	data2.Flags = 0;													//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data2);

	PrecacheSoundArray(g_EnergyChargeSounds);

	Zero(b_ruina_npc);

	Zero(b_ruina_nerf_healing);
	Zero(fl_master_change_timer);
	Zero(i_master_target_id);
	Zero(b_is_a_master);
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
	Zero(fl_ruina_battery_max);
	
	Zero(fl_ruina_shield_timer);
	Zero(i_shield_effect);
	Zero(fl_ruina_shield_break_timeout);
	Zero(fl_ontake_sound_timer);
	
	Zero(b_npc_low_health);
	Zero(b_npc_no_retreat);
	Zero(b_ruina_npc_healer);
	Zero(fl_npc_healing_duration);
	Zero(fl_ruina_helia_healing_timer);

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
	
	PrecacheSound(RUINA_SHIELD_ONTAKE_SOUND);

	PrecacheSound(RUINA_ASTRIA_TELEPORT_SOUND);

	PrecacheModel(RUINA_POINT_MODEL);
	
	PrecacheModel(BEAM_COMBINE_BLACK, true);

	i_Ruina_Overlord_Ref = INVALID_ENT_REFERENCE;
	
	g_Ruina_Laser_BEAM 			= PrecacheModel("materials/sprites/laserbeam.vmt", true);
	//gGlow1 = PrecacheModel("sprites/redglow2.vmt", true);
	g_Ruina_BEAM_Diamond 		= PrecacheModel(BEAM_DIAMOND, true);
	g_Ruina_BEAM_Laser 			= PrecacheModel("materials/sprites/laser.vmt", true);
	g_Ruina_HALO_Laser 			= PrecacheModel("materials/sprites/halo01.vmt", true);
	g_Ruina_BEAM_Combine_Black 	= PrecacheModel(BEAM_COMBINE_BLACK, true);
	g_Ruina_BEAM_Combine_Blue 	= PrecacheModel(BEAM_COMBINE_BLUE, true);

	g_Ruina_BEAM_Glow 			= PrecacheModel("sprites/glow02.vmt", true);

	g_Ruina_BEAM_lightning		= PrecacheModel("materials/sprites/lgtning.vmt", true);

	g_Ruina_Glow_Blue 			= PrecacheModel("sprites/blueglow2.vmt", true);
	g_Ruina_Glow_Red 			= PrecacheModel("sprites/redglow2.vmt", true);
}
static void OffsetGive_BatteryChargeStatus(int ref)
{
	int npc = EntRefToEntIndex(ref);
	if(!IsValidEntity(npc))
		return;
	
	ApplyStatusEffect(npc, npc, "Ruina Battery Charge", 9999.0);
}
void Ruina_Set_Heirarchy(int client, int type)
{
	RequestFrame(OffsetGive_BatteryChargeStatus, EntIndexToEntRef(client));

	Ruina_Remove_Shield(client);
	b_ruina_npc[client] = true;
	b_ruina_nerf_healing[client] = false;
	fl_ruina_shield_break_timeout[client] = 0.0;
	i_npc_type[client] = type;
	i_master_attracts[client] = type;
	b_is_a_master[client] = false;
	b_ruina_npc_healer[client] = false;
	b_npc_no_retreat[client] = false;
	fl_npc_healing_duration[client] = 0.0;
	b_npc_sniper_anchor_point[client]=false;
	i_last_sniper_anchor_id_Ref[client]=-1;
	fl_ruina_in_combat_timer[client]=0.0;
	b_is_battery_buffed[client]=false;
	b_ruina_allow_teleport[client] = false;

	CClotBody npc = view_as<CClotBody>(client);
	npc.m_iTarget=-1;	//set its target as invalid on spawn
	npc.m_flNextRangedAttack = GetRandomFloat(0.5, 2.5) + GetGameTime();
	npc.m_flNextMeleeAttack = GetRandomFloat(0.5, 2.5) + GetGameTime();
	
}
void Ruina_Set_Battery_Buffer(int client, bool state)
{
	b_is_battery_buffed[client]=state;
}
void Ruina_Set_Sniper_Anchor_Point(int client, bool state)
{
	b_npc_sniper_anchor_point[client]=state;
}
void Ruina_Set_Healer(int client)
{
	b_ruina_npc_healer[client] = true;
	b_npc_sniper_anchor_point[client]=true;
}
void Ruina_Set_No_Retreat(int client)
{
	b_npc_no_retreat[client] = true;
}
void Ruina_Set_Master_Heirarchy(int client, int type, bool accepting, int max_slaves, int priority)
{
	b_is_a_master[client] = true;
	
	b_force_reasignment[client]=false;
	
	i_master_max_slaves[client] = max_slaves;
	
	b_master_is_acepting[client] = accepting;
	
	i_master_current_slaves[client] = 0;
	
	i_master_priority[client] = priority;
	
	i_master_attracts[client] = type;

	b_ruina_allow_teleport[client]=false;
}
void Ruina_Set_Overlord(int client, bool state)
{
	if(state)
	{
		i_Ruina_Overlord_Ref = EntIndexToEntRef(client);
	}
	else
	{
		if(EntRefToEntIndex(i_Ruina_Overlord_Ref)==client)
		{
			i_Ruina_Overlord_Ref = INVALID_ENT_REFERENCE;
		}
	}
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
void Ruina_Npc_Give_Shield(int client, float strenght, bool ScaleWithPlayersAlive = false)
{
	float GameTime = GetGameTime();
	if(fl_ruina_shield_break_timeout[client] > GameTime && !b_ruina_buff_override[client])
		return;
	
	Ruina_Remove_Shield(client);

	fl_ruina_shield_break_timeout[client] = GameTime + 120.0;
	
	float Shield_Power = RUINA_NORMAL_NPC_MAX_SHIELD;
	if(b_thisNpcIsABoss[client])
	{
		Shield_Power = RUINA_BOSS_NPC_MAX_SHIELD;
	}
	if(b_thisNpcIsARaid[client])
	{
		Shield_Power = RUINA_RAIDBOSS_NPC_MAX_SHIELD;
		if(Waves_InFreeplay())
			Shield_Power = 0.06;
	}

	if(ScaleWithPlayersAlive)
	{
		Shield_Power *= NpcDoHealthRegenScaling(client);
	}
	GrantEntityArmor(client, false, Shield_Power, strenght, 1);
	
	Ruina_Update_Shield(client);
}

static void Ruina_Npc_Shield_Logic(int victim, float &damage, float damageForce[3], float GameTime)
{
	//does this npc have shield power?
	CClotBody npc = view_as<CClotBody>(victim);
	if(npc.m_flArmorCount>0.0)	
	{
		Ruina_Update_Shield(victim);

		if(fl_ontake_sound_timer[victim]<=GameTime)
		{
			fl_ontake_sound_timer[victim] = GameTime + 0.1;
			EmitSoundToAll(RUINA_SHIELD_ONTAKE_SOUND, victim, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		}
		//also remove kb dependant on strength
		for(int i=0 ; i < 3 ; i ++)
		{	
			damageForce[i] = damageForce[i] * npc.m_flArmorProtect;
		}
	}
	else
	{
		Ruina_Remove_Shield(victim);
	}
}

static void Ruina_Remove_Shield(int client)
{
	int i_shield_entity = EntRefToEntIndex(i_shield_effect[client]);
	if(IsValidEntity(i_shield_entity))
	{
		fl_ruina_shield_break_timeout[client] = GetGameTime() + RUINA_SHIELD_NPC_TIMEOUT;
		RemoveEntity(i_shield_entity);
	}
}
static void Ruina_Update_Shield(int client)
{
	CClotBody npc = view_as<CClotBody>(client);

	int i_shield_entity = EntRefToEntIndex(i_shield_effect[client]);

	int alpha = RoundToFloor(255*(npc.m_flArmorCount/npc.m_flArmorCountMax));
	if(alpha > 255)
	{
		alpha = 255;
	}
	if(IsValidEntity(i_shield_entity))
	{
		if(alpha != 255)
			SetEntityRenderMode(i_shield_entity, RENDER_TRANSCOLOR);
		else
			SetEntityRenderMode(i_shield_entity, RENDER_NORMAL);

		SetEntityRenderColor(i_shield_entity, i_shield_color[0], i_shield_color[1], i_shield_color[2], alpha);
	}
	else
	{
		Ruina_Give_Shield(client, alpha);
	}
	
}
static void Ruina_Give_Shield(int client, int alpha)	//just stole this one from artvins vaus shield...
{
	CClotBody npc = view_as<CClotBody>(client);
	int Shield = npc.EquipItem("", "models/effects/resist_shield/resist_shield.mdl");
	if(b_IsGiant[client])
		SetVariantString("1.35");
	else
		SetVariantString("1.0");

	AcceptEntityInput(Shield, "SetModelScale");
	if(alpha != 255)
		SetEntityRenderMode(Shield, RENDER_TRANSCOLOR);
	else
		SetEntityRenderMode(Shield, RENDER_NORMAL);
	
	SetEntityRenderColor(Shield, i_shield_color[0], i_shield_color[1], i_shield_color[2], alpha);
	SetEntProp(Shield, Prop_Send, "m_nSkin", 1);

	i_shield_effect[client] = EntIndexToEntRef(Shield);
}

void Ruina_NPCDeath_Override(int entity)
{
	fl_ruina_battery_max[entity] = 0.0;

	b_ruina_npc[entity] = false;
	b_is_a_master[entity] = false;
	int Master_Id_Main = EntRefToEntIndex(i_master_id_ref[entity]);
	//check if the master is still valid, but block the master itself
	if(IsValidEntity(Master_Id_Main) && Master_Id_Main!=entity)	
	{
		//if so we remove a slave from there list
		i_master_current_slaves[Master_Id_Main]--;
		//CPrintToChatAll("I died, but master was still alive: %i, now removing one, master has %i slaves left", entity, i_master_current_slaves[Master_Id_Main]);
	}
	Ruina_Remove_Shield(entity);
	i_npc_type[entity] = 0;
	b_ruina_nerf_healing[entity] = false;
}
int Ruina_Get_Target(int iNPC, float GameTime)
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
	if(IsValidAlly(client, EntRefToEntIndex(i_Ruina_Overlord_Ref)))
		return EntRefToEntIndex(i_Ruina_Overlord_Ref);

	i_previus_priority[client] = -1;
	int valid = -1;
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
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
		int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
		float dist = 99999999.9;
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && b_ruina_npc_healer[baseboss_index] && GetTeam(client) == GetTeam(baseboss_index))
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
	if(IsValidAlly(client, EntRefToEntIndex(i_Ruina_Overlord_Ref)))
		return EntRefToEntIndex(i_Ruina_Overlord_Ref);

	int valid = -1;
	float Npc_Vec[3]; GetAbsOrigin(client, Npc_Vec);
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
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
	float Max_Health = float(ReturnEntityMaxHealth(npc.index));
	float Ratio = Health / Max_Health;

	//CPrintToChatAll("Health %f", Health);
	//CPrintToChatAll("Ratio %f", Ratio);
		
	//if the npc has less then 10% hp, is not a healer, and has no retreat set, they will retreat to the closest healer
	if(Ratio<=0.10 && !b_ruina_npc_healer[npc.index] && !b_npc_no_retreat[npc.index])	
	{
		fl_npc_healing_duration[npc.index] = GameTime + 2.5;
		//CPrintToChatAll("Healing Duration 1 %f", fl_npc_healing_duration[npc.index]);
	}

	if(b_is_battery_buffed[npc.index] && fl_ruina_battery_timer[npc.index] > GameTime)
		return;

	int wave = iRuinaWave();
	if(wave <= 20)	
	{
		float Health_Post = (Health-damage);
		float Difference = Health_Post/Max_Health;
		float Give = 1250.0*(Ratio-Difference);
		//turn damage taken into energy
		Ruina_Add_Battery(npc.index, Give);	
		//CPrintToChatAll("Gave %f battery",Give );
	}
	else if(wave <=40)
	{
		float Health_Post = (Health-damage);
		float Difference = Health_Post/Max_Health;
		float Give = 1450.0*(Ratio-Difference);
		//turn damage taken into energy
		Ruina_Add_Battery(npc.index, Give);	
		//CPrintToChatAll("Gave %f battery",Give );
	}
	else	//freeplay
	{
		float Health_Post = (Health-damage);
		float Difference = Health_Post/Max_Health;
		float Give = 1700.0*(Ratio-Difference);
		//turn damage taken into energy
		Ruina_Add_Battery(npc.index, Give);	
		//CPrintToChatAll("Gave %f battery",Give );
	}
}

static bool Check_If_I_Am_The_Right_Slave(int client, int other_client)
{
	if(!b_is_a_master[other_client])
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

void Ruina_Ai_Override_Core(int iNPC, int &PrimaryThreatIndex, float GameTime)
{
	CClotBody npc = view_as<CClotBody>(iNPC);

	if(fl_npc_healing_duration[npc.index] > GameTime )	//heal until 50% hp
	{
		float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
		float Max_Health = float(ReturnEntityMaxHealth(npc.index));
		float Ratio = Health / Max_Health;

		//CPrintToChatAll("Health %f", Health);
		//CPrintToChatAll("Ratio %f", Ratio);
		if(Ratio<0.5 && !b_ruina_npc_healer[npc.index] && !b_npc_no_retreat[npc.index])
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
					npc.SetGoalEntity(Healer);
					npc.StartPathing();
					
					
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
	if(!b_is_a_master[npc.index])	//check if the npc is a master or not
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

			//we only change targets every so often as to make it so if a player touches the npc the npc will actually attack them and not just ignore them causing infinite body blocking.
			if(npc.m_flGetClosestTargetTime < GameTime || !IsValidEnemy(npc.index, PrimaryThreatIndex))
			{
				PrimaryThreatIndex = npc2.m_iTarget;
				npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
			}
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
							
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(PrimaryThreatIndex);
				}
				npc.StartPathing();
				

				Ruina_Special_Logic(npc.index, PrimaryThreatIndex);
			}
			else
			{
				npc.StopPathing();
				
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
							npc.SetGoalEntity(Master_Id_Main);
							npc.StartPathing();
							

							Ruina_Special_Logic(npc.index, Master_Id_Main);
								
						}
						else
						{
							if(flDistanceToTarget>(300.0 * 300.0))	//if master is within range we stop moving and stand still
							{
								npc.StopPathing();
								
							}
							else	//but if master's target is too close we attack them
							{
								//Predict their pos.
								if(flDistanceToTarget < npc.GetLeadRadius()) 
								{
										
									float vPredictedPos[3];  PredictSubjectPosition(npc, PrimaryThreatIndex, _,_,vPredictedPos);
										
									npc.SetGoalVector(vPredictedPos);
								}
								else 
								{
									npc.SetGoalEntity(PrimaryThreatIndex);
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
							
							npc.SetGoalVector(vPredictedPos);
						}
						else 
						{
							npc.SetGoalEntity(PrimaryThreatIndex);
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
						npc.SetGoalEntity(Master_Id_Main);
						npc.StartPathing();
						

						Ruina_Special_Logic(npc.index, Master_Id_Main);
						
					}
					else
					{
						npc.StopPathing();
						
					}	
				}
				//for the double type just gonna use melee npc logic
				case RUINA_GLOBAL_NPC:	
				{
					if(flDistanceToTarget < npc.GetLeadRadius()) 
					{
									
						float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex, _,_, vPredictedPos);
									
						npc.SetGoalVector(vPredictedPos);
					}
					else 
					{
						npc.SetGoalEntity(PrimaryThreatIndex);
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
		if(!IsValidEnemy(npc.index, PrimaryThreatIndex))
		{
			npc.StopPathing();
			
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
			return;
		}

		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex, _,_,vPredictedPos);

			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(PrimaryThreatIndex);
		}
		Ruina_Special_Logic(npc.index, PrimaryThreatIndex);
		npc.StartPathing();
						
		return;
	}
}
void Ruina_Basic_Npc_Logic(int iNPC, int &PrimaryThreatIndex, float GameTime)	//this is here if I ever want to make "basic" npc's do anything special
{
	if(IsValidAlly(iNPC, EntRefToEntIndex(i_Ruina_Overlord_Ref)))
	{
		Ruina_Ai_Override_Core(iNPC, PrimaryThreatIndex, GameTime);
		return;
	}
	CClotBody npc = view_as<CClotBody>(iNPC);

	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
				
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(flDistanceToTarget < npc.GetLeadRadius()) 
	{
		float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex, _,_,vPredictedPos);
		
		npc.SetGoalVector(vPredictedPos);
	}
	else 
	{
		npc.SetGoalEntity(PrimaryThreatIndex);
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
			npc.SetGoalEntity(Anchor_Id);
			npc.StartPathing();
			

			Ruina_Special_Logic(npc.index, Anchor_Id);
					
		}
		else
		{
			npc.StopPathing();
			
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
			
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(PrimaryThreatIndex);
		}
		npc.StartPathing();
	}
}
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
			SetEntPropVector(entity, Prop_Data, "m_vInitialVelocity", Velocity);

			fl_ruina_Projectile_dmg[entity] = this.damage;
			fl_ruina_Projectile_radius[entity] = this.radius;
			fl_ruina_Projectile_bonus_dmg[entity] = this.bonus_dmg;
			Func_Ruina_Proj_Touch[entity] = Custom_Projectile_Touch;
			
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.iNPC);
			SetTeam(entity, GetTeam(this.iNPC));
			DispatchKeyValue(entity, "model", ENERGY_BALL_MODEL);
			
			TeleportEntity(entity, NULL_VECTOR, this.Angles, NULL_VECTOR, true);
			int frame = GetEntProp(entity, Prop_Send, "m_ubInterpolationFrame");
			Custom_SDKCall_SetLocalOrigin(entity, this.Start_Loc);
			DispatchSpawn(entity);
			SetEntPropVector(entity, Prop_Send, "m_angRotation", this.Angles); //set it so it can be used
			SetEntPropVector(entity, Prop_Data, "m_angRotation", this.Angles); 
			if(!this.visible)
			{
				SetEntityModel(entity, ENERGY_BALL_MODEL);
			}

			Hook_DHook_UpdateTransmitState(entity);

			SetEntityMoveType(entity, MOVETYPE_FLY);
		//	RunScriptCode(entity, -1, -1, "self.SetMoveType(Constants.EMoveType.MOVETYPE_FLY, Constants.EMoveCollide.MOVECOLLIDE_FLY_CUSTOM)");	//do some weird script magic?
			Custom_SetAbsVelocity(entity, Velocity);	//set speed
			SetEntProp(entity, Prop_Send, "m_ubInterpolationFrame", frame);

			SetEntityCollisionGroup(entity, 24); //our savior
			Set_Projectile_Collision(entity); //If red, set to 27

			//so they dont get stuck on entities in the air.
			SetEntProp(entity, Prop_Send, "m_usSolidFlags", FSOLID_NOT_SOLID | FSOLID_TRIGGER); 

			//detection
			SDKHook(entity, SDKHook_Think, ProjectileBaseThink);
			SDKHook(entity, SDKHook_ThinkPost, ProjectileBaseThinkPost);
			CBaseCombatCharacter(entity).SetNextThink(GetGameTime());

			WandProjectile_ApplyFunctionToEntity(entity, Ruina_Projectile_Touch);

			SDKHook(entity, SDKHook_StartTouch, Wand_Base_StartTouch);

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

		i_WandParticle[this.Projectile_Index]= EntIndexToEntRef(particle);
		TeleportEntity(particle, NULL_VECTOR, this.Angles, NULL_VECTOR);
		SetParent(this.Projectile_Index, particle);	
		SetEntityRenderMode(this.Projectile_Index, RENDER_NONE); //Make it entirely invis.
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
		float speed = this.speed;
		Rogue_Paradox_ProjectileSpeed(this.iNPC, speed);

		Vel[0] = Cosine(DegToRad(this.Angles[0]))*Cosine(DegToRad(this.Angles[1]))*speed;
		Vel[1] = Cosine(DegToRad(this.Angles[0]))*Sine(DegToRad(this.Angles[1]))*speed;
		Vel[2] = Sine(DegToRad(this.Angles[0]))*-speed;
	}
}
void Ruina_Projectile_Touch(int entity, int target)
{
	Function func = Func_Ruina_Proj_Touch[entity];

	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))	//owner is invalid, evacuate.
	{
		Ruina_Remove_Projectile(entity);
		return;
	}
	if(!IsValidEnemy(owner, target) && target != 0)
		return;

	if(func==INVALID_FUNCTION)
	{	
		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);

		if(fl_ruina_Projectile_radius[entity]>0.0)
			Explode_Logic_Custom(fl_ruina_Projectile_dmg[entity] , owner , owner , -1 , ProjectileLoc , fl_ruina_Projectile_radius[entity] , _ , _ , true, _,_, fl_ruina_Projectile_bonus_dmg[entity]);
		else if(target != 0)
			SDKHooks_TakeDamage(target, owner, owner, fl_ruina_Projectile_dmg[entity], DMG_PLASMA, -1, _, ProjectileLoc);

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
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
	}
	RemoveEntity(entity);
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

	void Swing_Melee(Function OnAttack = INVALID_FUNCTION, Function OnSwing = INVALID_FUNCTION)
	{
		CClotBody npc = view_as<CClotBody>(this.iNPC);

		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < this.gameTime)
			{
				npc.m_flAttackHappens = 0.0;

				if(OnSwing && OnSwing!=INVALID_FUNCTION)
				{
					Call_StartFunction(null, OnSwing);
					Call_PushCell(npc.index);
					Call_Finish();
				}
				
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

static float fl_mana_sickness_multi;
static int i_mana_sickness_flat;
static bool b_override_Sickness;
void Ruina_AOE_Add_Mana_Sickness(float Loc[3], int iNPC, float range, float Multi, int flat_amt=0, bool override = false)
{
	fl_mana_sickness_multi = Multi;
	i_mana_sickness_flat= flat_amt;
	b_override_Sickness= override;
	Explode_Logic_Custom(0.0, iNPC, iNPC, -1, Loc, range, _, _, true, 99, false, _, Ruina_Apply_Mana_Debuff);
}
void Ruina_Apply_Mana_Debuff(int entity, int victim, float damage, int weapon)
{
	if(!IsValidClient(victim))
		return;

	if(GetTeam(victim) != TFTeam_Red)
		return;
	ManaCalculationsBefore(victim);
	float GameTime = GetGameTime();

	bool override = b_override_Sickness;
	
	if(fl_mana_sickness_timeout[victim] > GameTime && !override)
		return;
		
	float Multi = fl_mana_sickness_multi;
	int flat_amt = i_mana_sickness_flat;
	float OverMana_Ratio = Current_Mana[victim]/max_mana[victim];

	int wep_hold = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
	if(IsValidEntity(wep_hold))
	{
		if(!i_IsWandWeapon[wep_hold])
		{
			flat_amt = RoundToFloor(flat_amt*0.75);
		}
	}

	b_override_Sickness = false;

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

		int weapon = GetEntPropEnt(Target, Prop_Send, "m_hActiveWeapon");
		if(IsValidEntity(weapon))
		{
			if(!i_IsWandWeapon[weapon])
			{
				flat_amt = RoundToFloor(flat_amt*0.75);
			}
		}

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

	int wave = iRuinaWave();

	float 	dmg 		= 250.0,
			time 		= 2.5,		//how long until it goes boom
			Timeout	 	= 5.0,		//how long is the grace period for the mana sickness
			Slow_Time	= 2.0,		//how long the slowdown lasts
			Radius		= 100.0;	//self explanitory

	float mana = max_mana[Target];

	int color[4];

	if(mana <=400.0)	//a base mana asumption
		mana=400.0;

	if(wave<=10)
	{
		Radius		= 100.0;
		dmg 		= mana+100.0;	//evil.
		time 		= 5.0;
		Timeout 	= 6.0;
		Slow_Time 	= 5.0;
	}
	else if(wave<=20)
	{
		Radius		= 125.0;
		dmg 		= mana*1.25+200.0;
		time 		= 4.5;
		Timeout 	= 5.5;
		Slow_Time 	= 5.0;
	}
	else if(wave<=30)
	{
		Radius		= 175.0;
		dmg 		= mana*1.5+300.0;
		time 		= 4.0;
		Timeout 	= 5.0;
		Slow_Time 	= 5.5;
	}
	else
	{
		Radius		= 200.0;
		dmg 		= mana*2.0+400.0;
		time 		= 3.0;
		Timeout 	= 4.5;
		Slow_Time 	= 6.0;
	}

	Ruina_Color(color);

	fl_mana_sickness_timeout[Target] = GameTime + Timeout;

	Mana_Regen_Delay[Target] = GameTime + Timeout;
	Mana_Regen_Block_Timer[Target] = GameTime + Timeout;

	if(!HasSpecificBuff(Target, "Fluid Movement"))
		TF2_StunPlayer(Target, Slow_Time, 0.5, TF_STUNFLAG_SLOWDOWN);	//50% slower

	Force_ExplainBuffToClient(Target, "Overmana Overload");
	float end_point[3];
	GetClientAbsOrigin(Target, end_point);
	end_point[2]+=5.0;

	//Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, end_point);

	float Thickness = 6.0;
	int Tempcolor[4];
	Tempcolor = color;
	Tempcolor [3] = 80;
	TE_SetupBeamRingPoint(end_point, Radius*2.0, 0.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, time, Thickness, 0.75, Tempcolor, 1, 0);
	TE_SendToAll();
	TE_SetupBeamRingPoint(end_point, Radius*2.0, Radius*2.0+0.5, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, time, Thickness, 0.1, color, 1, 0);
	TE_SendToAll();

	//BECOME LOUDER!!!!!!1111111!!1!!!!!!!!!!!!!1!!!!
	EmitSoundToClient(Target, RUINA_ION_CANNON_SOUND_SPAWN, Target, SNDCHAN_STATIC, SNDLEVEL_NORMAL, _, 1.0);
	EmitSoundToClient(Target, RUINA_ION_CANNON_SOUND_SPAWN, Target, SNDCHAN_STATIC, SNDLEVEL_NORMAL, _, 0.7);

	Ruina_IonSoundInvoke(end_point);

	DataPack pack;
	CreateDataTimer(time, Ruina_Mana_Sickness_Ion, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(GetTeam(iNPC));
	pack.WriteFloatArray(end_point, sizeof(end_point));
	pack.WriteCellArray(color, sizeof(color));
	pack.WriteFloat(Radius);
	pack.WriteFloat(dmg);

	if(AtEdictLimit(EDICT_NPC))
		return;

	float Sky_Loc[3]; Sky_Loc = end_point; Sky_Loc[2]+=500.0; end_point[2]-=100.0;

	int laser;
	laser = ConnectWithBeam(-1, -1, color[0], color[1], color[2], 4.0, 4.0, 5.0, BEAM_COMBINE_BLACK, end_point, Sky_Loc);

	CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
}
void Ruina_Color(int color[4], int wave = -1)
{
	if(wave == -1)
		wave = iRuinaWave();
		
	if(wave<=10)
	{
		color 	= {255, 0, 0, 255};
	}
	else if(wave<=20)
	{
		color 	= {255, 150, 150, 255};
	}
	else if(wave<=30)
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

	float Thickness = 6.0;
	int Tempcolor[4];
	Tempcolor = color;
	Tempcolor [3] = 80;
	TE_SetupBeamRingPoint(end_point, 0.0, Radius*2.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, 0.25, Thickness, 0.75, Tempcolor, 1, 0);
	TE_SendToAll();

	

	Radius = Radius*Radius;

	EmitSoundToAll(RUINA_ION_CANNON_SOUND_TOUCHDOWN, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, end_point);
	EmitSoundToAll(RUINA_ION_CANNON_SOUND_TOUCHDOWN, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, end_point);

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

		EmitSoundToClient(client, RUINA_ION_CANNON_SOUND_ATTACK);
		EmitSoundToClient(client, RUINA_ION_CANNON_SOUND_ATTACK);

		SDKHooks_TakeDamage(client, 0, 0, dmg, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);

		int laser;
		laser = ConnectWithBeam(-1, client, color[0], color[1], color[2], 2.5, 2.5, 0.25, BEAM_COMBINE_BLACK, end_point);
		CreateTimer(0.1, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
	}
	for(int a; a < i_MaxcountNpcTotal; a++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[a]);
		if(entity != INVALID_ENT_REFERENCE && !view_as<CClotBody>(entity).m_bThisEntityIgnored && !b_NpcIsInvulnerable[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity] && IsEntityAlive(entity))
		{
			if(GetTeam(entity) == Team)
				continue;

			float Vic_Pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", Vic_Pos);

			if(GetVectorDistance(Vic_Pos, end_point, true) > Radius)
				continue;

			SDKHooks_TakeDamage(entity, 0, 0, dmg*2.0, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);

			int laser;
			laser = ConnectWithBeam(-1, entity, color[0], color[1], color[2], 2.5, 2.5, 0.25, BEAM_COMBINE_BLACK, end_point);
			CreateTimer(0.1, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	for(int a; a < i_MaxcountBuilding; a++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsBuilding[a]);
		if(entity != INVALID_ENT_REFERENCE)
		{
			if(!b_ThisEntityIgnored[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity])
			{
				float Vic_Pos[3];
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", Vic_Pos);

				if(GetVectorDistance(Vic_Pos, end_point, true) > Radius)
					continue;

				SDKHooks_TakeDamage(entity, 0, 0, dmg*2.0, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
				int laser;
				laser = ConnectWithBeam(-1, entity, color[0], color[1], color[2], 2.5, 2.5, 0.25, BEAM_COMBINE_BLACK, end_point);
				CreateTimer(0.1, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}

	if(AtEdictLimit(EDICT_NPC))
		return Plugin_Stop; 

	float Sky_Loc[3]; Sky_Loc = end_point; Sky_Loc[2]+=1000.0; end_point[2]-=100.0;

	int laser;
	laser = ConnectWithBeam(-1, -1, color[0], color[1], color[2], 7.0, 7.0, 1.0, BEAM_COMBINE_BLACK, end_point, Sky_Loc);
	CreateTimer(1.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
	laser = ConnectWithBeam(-1, -1, color[0], color[1], color[2], 5.0, 5.0, 0.1, LASERBEAM, end_point, Sky_Loc);
	CreateTimer(1.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);

	int particle = ParticleEffectAt(Sky_Loc, "kartimpacttrail", 1.0);
	SetEdictFlags(particle, (GetEdictFlags(particle) | FL_EDICT_ALWAYS));	
	CreateTimer(0.25, Nearl_Falling_Shot, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);

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

	Explode_Logic_Custom(dmg, iNPC, iNPC, -1, end_point, Radius, _, _, true, _ , _    , 2.0, Generic_ion_OnHit);

	EmitSoundToAll(RUINA_ION_CANNON_SOUND_TOUCHDOWN, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, end_point);
	EmitSoundToAll(RUINA_ION_CANNON_SOUND_TOUCHDOWN, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, end_point);

	if(Sickness_flat || Sickness_Multi)
		Ruina_AOE_Add_Mana_Sickness(end_point, iNPC, Radius, Sickness_Multi, Sickness_flat,Override);

	float Thickness = 6.0;
	TE_SetupBeamRingPoint(end_point, 0.0, Radius*2.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, 0.35, Thickness, 0.75, color, 1, 0);
	TE_SendToAll();

	float Sky_Loc[3]; Sky_Loc = end_point; Sky_Loc[2]+=1000.0; end_point[2]-=100.0;

	if(AtEdictLimit(EDICT_NPC))
		return Plugin_Stop;
		
	int laser;
	laser = ConnectWithBeam(-1, -1, color[0], color[1], color[2], 7.0, 7.0, 1.0, BEAM_COMBINE_BLACK, end_point, Sky_Loc);
	CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
	laser = ConnectWithBeam(-1, -1, color[0], color[1], color[2], 5.0, 5.0, 0.1, LASERBEAM, end_point, Sky_Loc);
	CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);

	int particle = ParticleEffectAt(Sky_Loc, "kartimpacttrail", 1.0);
	SetEdictFlags(particle, (GetEdictFlags(particle) | FL_EDICT_ALWAYS));	
	CreateTimer(0.25, Nearl_Falling_Shot, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Stop;
}
void Ruina_IonSoundInvoke(float Loc[3])
{
	EmitSoundToAll(RUINA_ION_CANNON_SOUND_SPAWN, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, Loc);
	EmitSoundToAll(RUINA_ION_CANNON_SOUND_SPAWN, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, Loc);
}
static void Generic_ion_OnHit(int entity, int victim, float damage, int weapon)
{
	if(IsValidClient(victim))
	{
		EmitSoundToClient(victim, RUINA_ION_CANNON_SOUND_ATTACK);
		EmitSoundToClient(victim, RUINA_ION_CANNON_SOUND_ATTACK);
	}
}
public void Ruina_Add_Battery(int iNPC, float Amt)
{
	CClotBody npc = view_as<CClotBody>(iNPC);

	if(NpcStats_IsEnemySilenced(npc.index))
		Amt*=0.9;

	fl_ruina_battery[npc.index] += Amt;
}
void Ruina_Runaway_Logic(int iNPC, int PrimaryThreatIndex)
{
	CClotBody npc = view_as<CClotBody>(iNPC);
	if(fl_npc_healing_duration[npc.index] > GetGameTime(npc.index))
		return;

	if(b_is_a_master[npc.index] || b_thisNpcIsABoss[npc.index] || b_thisNpcIsARaid[npc.index] || b_ruina_npc_healer[npc.index])	//if its a master type or a raid/boss or a healer npc allow it to also walk backwards.
	{
		int Master_Id_Main = EntRefToEntIndex(i_master_id_ref[npc.index]);
		if(IsValidEntity(Master_Id_Main))//do we have a master?
		{
			if(!b_master_is_rallying[Master_Id_Main])	//is master rallying targets to be near it?
			{
				npc.StartPathing();
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true);
			}
			else
			{
				npc.m_bAllowBackWalking=false;
			}
		}
		else
		{
			npc.StartPathing();
			float vBackoffPos[3];
			BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex,_,vBackoffPos);
			npc.SetGoalVector(vBackoffPos, true);
		}
		
		return;
	}
	//if it isn't then simply make it stop walking.
	int Master_Id_Main = EntRefToEntIndex(i_master_id_ref[npc.index]);
	if(IsValidEntity(Master_Id_Main))//do we have a master?
	{
		if(!b_master_is_rallying[Master_Id_Main])	//is master rallying targets to be near it?
		{
			npc.StopPathing();
			
			npc.m_bAllowBackWalking=false;
		}
		else
		{
			npc.m_bAllowBackWalking=false;
		}
	}
	else	//no?
	{
		npc.StopPathing();
		
		npc.m_bAllowBackWalking=false;
	}
}
void Helia_Healing_Logic(int iNPC, int Healing, float Range, float GameTime, float cylce_speed)
{
	CClotBody npc = view_as<CClotBody>(iNPC);

	if(fl_ruina_helia_healing_timer[npc.index]<=GameTime)
	{	
		ExpidonsaGroupHeal(npc.index, Range, 15, float(Healing), 1.3, false, Ruina_NerfHealingOnBossesOrHealers);
		DesertYadeamDoHealEffect(npc.index, Range);

		//int color[4]; Ruina_Color(color);
		//float Npc_Vec[3];
		//GetAbsOrigin(npc.index, Npc_Vec); Npc_Vec[2]+=2.5;
		//TE_SetupBeamRingPoint(Npc_Vec, 0.0, Range*2.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, 0.5, 10.0, 1.0, color, 1, 0);
		//TE_SendToAll();

		fl_ruina_helia_healing_timer[npc.index]=cylce_speed+GameTime;
	}
}
bool Ruina_NerfHealingOnBossesOrHealers(int healer, int healed_target, float &healingammount)
{
	CClotBody npc = view_as<CClotBody>(healed_target);

	float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float Max_Health = float(ReturnEntityMaxHealth(npc.index));
	float Ratio = Health / Max_Health;

	if(Ratio > 1.0)
	{//the target npc has overheal, nerf the healing ratio
		healingammount*=0.9;
	}
	
	if(fl_npc_healing_duration[npc.index] < GetGameTime(npc.index))
	{//the npc is not retreating to a healer npc. simply put, if the npc is running towards a healer npc, they won't get their healing nerfed from this specific value.
		
		if(b_ruina_nerf_healing[healed_target])
		{//the npc is a special case that needs to get less healing otherwise unfun balance happens
			healingammount *=0.8;
		}
		else if(b_thisNpcIsABoss[healed_target] || b_thisNpcIsARaid[healed_target])
		{//this npc is a raid/boss healing target
			healingammount *=0.9;
		}
	}
	if(b_ruina_npc_healer[healed_target])
	{//this npc MUST have less healing.
		healingammount *=0.8;
	}

	if(!b_ruina_npc[healed_target])
	{//ruina is now xenophobic of other races. and people. mostly to nerf minibosses from being healed
		healingammount *=0.5;
	}
	

	return false;
}
bool Lanius_Teleport_Logic(int iNPC, int PrimaryThreatIndex, float Dist_Min, float Dist_Max, float recharge, float dmg = 0.0, float radius = 0.0, Function OnTeleportLaseHit = INVALID_FUNCTION)
{
	CClotBody npc = view_as<CClotBody>(iNPC);

	float flVel[3];
	GetEntPropVector(PrimaryThreatIndex, Prop_Data, "m_vecAbsVelocity", flVel);
	float abs_vel = fabs(flVel[0]) + fabs(flVel[1]) + fabs(flVel[2]);

	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
	float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
	float flDistanceToTarget = GetVectorDistance(vecTarget, Npc_Vec, true);

	float GameTime = GetGameTime(npc.index);

	bool block = false;

	if(npc.m_flDoingAnimation < GameTime && !npc.m_bisWalking)
	{
		npc.StartPathing();
		block = true;
		npc.m_iChanged_WalkCycle = -1;
		npc.m_bisWalking = true;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		npc.m_flRangedArmor = 1.0;
		npc.m_flMeleeArmor = 1.0;
	}

	if (abs_vel >= 190.0)
	{
		if(flDistanceToTarget > Dist_Min && flDistanceToTarget < Dist_Max)
		{
			//CPrintToChatAll("Inrange");
			if(npc.m_flNextTeleport > GameTime)
				return false;

			if(npc.m_flDoingAnimation < GameTime && npc.m_bisWalking && !block)
			{
				npc.m_flRangedArmor = 0.75;
				npc.m_flMeleeArmor = 0.75;
				npc.m_flDoingAnimation = GameTime + 1.0;
				npc.SetPlaybackRate(1.0);	
				npc.SetCycle(0.1);
				npc.StopPathing();
				
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("taunt_the_trackmans_touchdown");
				return false;
			}	

			if(npc.m_flDoingAnimation > GameTime)
				return false;

			npc.m_bisWalking = true;
			npc.StartPathing();
			npc.m_iChanged_WalkCycle = -1;

			
			float vPredictedPos[3],
			SubjectAbsVelocity[3];
			GetEntPropVector(PrimaryThreatIndex, Prop_Data, "m_vecAbsVelocity", SubjectAbsVelocity);
			SubjectAbsVelocity[2] = 0.0;
			for(int i=0 ; i < 2 ; i++)	{SubjectAbsVelocity[i]*=-0.5;}
			AddVectors(vecTarget, SubjectAbsVelocity, vPredictedPos);
			float npc_Loc[3]; GetAbsOrigin(npc.index, npc_Loc); npc_Loc[2]+=2.5;	

			/*float Thickness = 6.0;
			float Range = 50.0;
			int colour[4];
			Ruina_Color(colour);
			vPredictedPos[2]+=10.0;
			TE_SetupBeamRingPoint(vPredictedPos, Range*2.0, Range*2.0 + 1.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, 0.1, Thickness, 0.5, colour, 1, 0);
			TE_SendToAll();
			*/
			vPredictedPos[2]+=45.0;

			npc.FaceTowards(vPredictedPos);
			npc.FaceTowards(vPredictedPos);
				
			float start_offset[3], end_offset[3];
			start_offset = Npc_Vec;

			if(NPC_Teleport(npc.index, vPredictedPos))
			{				
				float effect_duration = 0.25;

				end_offset = vPredictedPos;

				if(dmg!=0.0)
				{
					Ruina_Laser_Logic Laser;
					Laser.client = npc.index;
					Laser.Start_Point = Npc_Vec;
					Laser.End_Point = vPredictedPos;
					Laser.Radius = radius;
					Laser.Damage = dmg;
					Laser.Bonus_Damage = dmg*1.5;
					Laser.damagetype = DMG_PLASMA;
					Laser.Deal_Damage(OnTeleportLaseHit);
				}

				npc.m_flNextTeleport = GameTime + recharge;

				end_offset[2] -=45.0;
								
				for(int help=1 ; help<=8 ; help++)
				{	
					Lanius_Teleport_Effect(RUINA_BALL_PARTICLE_BLUE, effect_duration, start_offset, end_offset);
									
					start_offset[2] += 12.5;
					end_offset[2] += 12.5;
				}
				return true;
			}
			else
			{
				npc.m_flNextTeleport = GameTime + 3.0;
				return false;
			}
		}
	}

	return false;
}
void Astria_Teleport_Allies(int iNPC, float Range, int colour[4])
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
		float SubjectAbsVelocity[3];
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		GetEntPropVector(PrimaryThreatIndex, Prop_Data, "m_vecAbsVelocity", SubjectAbsVelocity);
		for(int i=0 ; i < 2 ; i++)	{SubjectAbsVelocity[i]*=-0.5;}
		AddVectors(vecTarget, SubjectAbsVelocity, vPredictedPos);
		float flVel[3];
		GetEntPropVector(PrimaryThreatIndex, Prop_Data, "m_vecAbsVelocity", flVel);
		float abs_vel = fabs(flVel[0]) + fabs(flVel[1]) + fabs(flVel[2]);
	
		if (abs_vel < 190.0)//don't teleport ontop of enemy gamers
			return;
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
		int colour[4];
		Ruina_Color(colour);
		TE_SetupBeamRingPoint(npc_Loc, Range*2.0, 0.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, 0.5, Thickness, 0.5, colour, 1, 0);
		TE_SendToAll();
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
void Master_Apply_Defense_Buff(int client, float range, float time, float power)
{
	Apply_Master_Buff(client, RUINA_DEFENSE_BUFF, range, time, power);
}
void Master_Apply_Speed_Buff(int client, float range, float time, float power)
{
	Apply_Master_Buff(client, RUINA_SPEED_BUFF, range, time, power);
}
void Master_Apply_Attack_Buff(int client, float range, float time, float power)
{
	Apply_Master_Buff(client, RUINA_ATTACK_BUFF, range, time, power);
}
void Master_Apply_Shield_Buff(int client, float range, float power, bool override = false)
{
	Apply_Master_Buff(client, RUINA_SHIELD_BUFF, range, 0.0, power, override);
}
void Master_Apply_Battery_Buff(int client, float range, float power)
{
	EmitSoundToAll(g_EnergyChargeSounds[GetRandomInt(0, sizeof(g_EnergyChargeSounds) - 1)], client, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.25, GetRandomInt(RUINA_NPC_PITCH-25, RUINA_NPC_PITCH+25));
	
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
static void Apply_Master_Buff(int iNPC, int buff_type, float range, float time, float amt, bool Override=false)
{
	CClotBody npc = view_as<CClotBody>(iNPC);
	
	if(NpcStats_IsEnemySilenced(npc.index))
		time*0.75;
	
	b_ruina_buff_override[npc.index] = Override;

	switch(buff_type)
	{
		case RUINA_DEFENSE_BUFF:
		{
			b_NpcIsTeamkiller[npc.index] = true;
			fl_ruina_buff_amt[npc.index] = amt;
			fl_ruina_buff_time[npc.index] = time;
			Explode_Logic_Custom(0.0, npc.index, npc.index, -1, _, range, _, _, true, 99, false, _, Ruina_Apply_Defense_buff);
			b_NpcIsTeamkiller[npc.index] = false;
		}
		case RUINA_SPEED_BUFF:
		{
			b_NpcIsTeamkiller[npc.index] = true;
			fl_ruina_buff_amt[npc.index] = amt;
			fl_ruina_buff_time[npc.index] = time;
			Explode_Logic_Custom(0.0, npc.index, npc.index, -1, _, range, _, _, true, 99, false, _, Ruina_Apply_Speed_buff);
			b_NpcIsTeamkiller[npc.index] = false;
		}
		case RUINA_ATTACK_BUFF:
		{
			b_NpcIsTeamkiller[npc.index] = true;
			fl_ruina_buff_amt[npc.index] = amt;
			fl_ruina_buff_time[npc.index] = time;
			Explode_Logic_Custom(0.0, npc.index, npc.index, -1, _, range, _, _, true, 99, false, _, Ruina_Apply_Attack_buff);
			b_NpcIsTeamkiller[npc.index] = false;
		}
		case RUINA_SHIELD_BUFF:
		{
			b_NpcIsTeamkiller[npc.index] = true;
			fl_ruina_buff_amt[npc.index] = amt;
			Explode_Logic_Custom(0.0, npc.index, npc.index, -1, _, range, _, _, true, 99, false, _, Ruina_Shield_Buff);
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
			fl_ruina_buff_amt[npc.index] = amt;
			b_NpcIsTeamkiller[npc.index] = true;
			Explode_Logic_Custom(0.0, npc.index, npc.index, -1, _, range, _, _, true, 99, false, _, Ruina_Battery_Buff);
			b_NpcIsTeamkiller[npc.index] = false;
		}
	}
}
void Ruina_Battery_Buff(int entity, int victim, float damage, int weapon)
{
	if(entity==victim)
		return;	//don't buff itself!

	if(GetTeam(entity) != GetTeam(victim))
		return;

	if(Block_Buffs(victim))
		return;
	
	//don't buff the batteries of other battery buffers otherwise a snowball effect might ocur
	if(b_is_battery_buffed[victim])	
		return;
	
	Ruina_Add_Battery(victim, fl_ruina_buff_amt[entity]);
}
void Ruina_Shield_Buff(int entity, int victim, float damage, int weapon)
{
	if(entity==victim)
		return;	//don't buff itself!

	if(GetTeam(entity) != GetTeam(victim))
		return;

	if(Block_Buffs(victim))
		return;

	//same type of npc, or a global type
	if(i_npc_type[victim])//if(i_npc_type[victim]==i_master_attracts[entity] || (i_master_attracts[entity]==RUINA_GLOBAL_NPC || b_ruina_buff_override[entity]))	
	{
		float amt = fl_ruina_buff_amt[entity];
		Ruina_Npc_Give_Shield(victim, amt);
	}
}
void Ruina_Teleport_Buff(int entity, int victim, float damage, int weapon)
{
	if(entity==victim)
		return;	//don't buff itself!

	if(GetTeam(entity) != GetTeam(victim))
		return;

	if(Block_Buffs(victim))
		return;

	//same type of npc, or a global type
	//if(i_npc_type[victim]==i_master_attracts[entity] || (i_master_attracts[entity]==RUINA_GLOBAL_NPC || b_ruina_buff_override[entity]))	
	{
		b_ruina_allow_teleport[victim]=true;
	}
}
static bool Block_Buffs(int entity)
{
	if(!b_ruina_npc[entity])
		return true;

	return false;
}

void Ruina_Apply_Defense_buff(int entity, int victim, float damage, int weapon)
{
	if(entity==victim)
		return;	//don't buff itself!

	if(GetTeam(entity) != GetTeam(victim))
		return;

	//same type of npc, or a global type
	//if(i_npc_type[victim]==i_master_attracts[entity] || (i_master_attracts[entity]==RUINA_GLOBAL_NPC || b_ruina_buff_override[entity]))	
	{
		float time = fl_ruina_buff_time[entity];
		float amt = fl_ruina_buff_amt[entity];
		ApplyStatusEffect(entity, victim, "Ruina's Defense", time);
		NpcStats_RuinaDefenseStengthen(victim, amt);
	}
	
}
void Ruina_Apply_Speed_buff(int entity, int victim, float damage, int weapon)
{
	if(entity==victim)
		return;	//don't buff itself!
	
	if(GetTeam(entity) != GetTeam(victim))
		return;
	

	//same type of npc, or a global type
	//if(i_npc_type[victim]==i_master_attracts[entity] || (i_master_attracts[entity]==RUINA_GLOBAL_NPC || b_ruina_buff_override[entity]))	
	{
		float time = fl_ruina_buff_time[entity];
		float amt = fl_ruina_buff_amt[entity];

		ApplyStatusEffect(entity, victim, "Ruina's Agility", time);
		NpcStats_RuinaAgilityStengthen(victim, amt);
	}
}
void Ruina_Apply_Attack_buff(int entity, int victim, float damage, int weapon)
{
	if(entity==victim)
		return;	//don't buff itself!

	if(GetTeam(entity) != GetTeam(victim))
		return;

	//same type of npc, or a global type
	//if(i_npc_type[victim]==i_master_attracts[entity] || (i_master_attracts[entity]==RUINA_GLOBAL_NPC || b_ruina_buff_override[entity]))	
	{
		float time = fl_ruina_buff_time[entity];
		float amt = fl_ruina_buff_amt[entity];
		ApplyStatusEffect(entity, victim, "Ruina's Damage", time);
		NpcStats_RuinaDamageStengthen(victim, amt);
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

void Ruina_Proper_To_Groud_Clip(float vecHull[3], float StepHeight, float vecorigin[3])
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
stock void Offset_Vector(float BEAM_BeamOffset[3], float Angles[3], float Result_Vec[3])
{
	float tmp[3];
	float actualBeamOffset[3];

	tmp[0] = BEAM_BeamOffset[0];
	tmp[1] = BEAM_BeamOffset[1];
	tmp[2] = 0.0;
	VectorRotate(BEAM_BeamOffset, Angles, actualBeamOffset);
	actualBeamOffset[2] = BEAM_BeamOffset[2];
	Result_Vec[0] += actualBeamOffset[0];
	Result_Vec[1] += actualBeamOffset[1];
	Result_Vec[2] += actualBeamOffset[2];
}
int iRuinaWave()
{
	int wave = Waves_GetRoundScale()+1;
	wave = RoundToCeil(wave * MinibossScalingReturn());
	return wave;
}
enum struct Ruina_Laser_Logic
{
	int client;
	float Start_Point[3];
	float End_Point[3];
	float Angles[3];
	float Radius;
	float Damage;
	float Bonus_Damage;
	int damagetype;

	bool trace_hit;
	bool trace_hit_enemy;

	float Custom_Hull[3];

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


			if(Dist !=-1.0)
			{
				ConformLineDistance(Loc, startPoint, Loc, Dist);
			}
			this.Start_Point = startPoint;
			this.End_Point = Loc;
			this.trace_hit=true;
			this.Angles = Angles;
		}
		delete trace;
	}
	void DoForwardTrace_Custom(float Angles[3], float startPoint[3], float Dist=-1.0)
	{
		float Loc[3];
		Handle trace = TR_TraceRayFilterEx(startPoint, Angles, 11, RayType_Infinite, Ruina_Laser_BEAM_TraceWallsOnly);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(Loc, trace);
			


			if(Dist !=-1.0)
			{
				ConformLineDistance(Loc, startPoint, Loc, Dist);
			}
			this.Start_Point = startPoint;
			this.End_Point = Loc;
			this.Angles = Angles;
			this.trace_hit=true;
		}
		delete trace;
	}
	void Enumerate_Simple()
	{
		Zero(i_Ruina_Laser_BEAM_HitDetected);

		float hullMin[3], hullMax[3];
		this.SetHull(hullMin, hullMax);

		Handle trace = TR_TraceHullFilterEx(this.Start_Point, this.End_Point, hullMin, hullMax, 1073741824, Ruina_Laser_BEAM_TraceUsers);	// 1073741824 is CONTENTS_LADDER?
		delete trace;

		//the idea for this one is to then use
		//for (int loop = 0; loop < sizeof(i_Ruina_Laser_BEAM_HitDetected); loop++)
		//to loop throught the stuff. inside the specific npc that needs to use this
	}
	bool Any_entities;
	//in this case, no default func since this things entire point is to find entities
	void Detect_Entities(Function Attack_Function)
	{
		Zero(i_Ruina_Laser_BEAM_HitDetected);

		float hullMin[3], hullMax[3];
		this.SetHull(hullMin, hullMax);

		Handle trace = TR_TraceHullFilterEx(this.Start_Point, this.End_Point, hullMin, hullMax, 1073741824, Ruina_Laser_BEAM_TraceUsers);	// 1073741824 is CONTENTS_LADDER?
		delete trace;

		for (int loop = 0; loop < sizeof(i_Ruina_Laser_BEAM_HitDetected); loop++)
		{
			int victim = i_Ruina_Laser_BEAM_HitDetected[loop];
			if (victim && (this.Any_entities || IsValidEnemy(this.client, victim)))
			{
				this.trace_hit_enemy=true;

				float playerPos[3];
				WorldSpaceCenter(victim, playerPos);

				//still send the dmg over.
				float Dmg = this.Damage;

				if(ShouldNpcDealBonusDamage(victim))
					Dmg = this.Bonus_Damage;

				Call_StartFunction(null, Attack_Function);
				Call_PushCell(this.client);
				Call_PushCell(victim);
				Call_PushCell(this.damagetype);
				Call_PushFloat(Dmg);
				Call_Finish();

				//static void On_LaserHit(int client, int target, int damagetype, float damage)
			}
		}
	}

	void Deal_Damage(Function Attack_Function = INVALID_FUNCTION)
	{
		Zero(i_Ruina_Laser_BEAM_HitDetected);

		float hullMin[3], hullMax[3];
		this.SetHull(hullMin, hullMax);

		Handle trace = TR_TraceHullFilterEx(this.Start_Point, this.End_Point, hullMin, hullMax, 1073741824, Ruina_Laser_BEAM_TraceUsers);	// 1073741824 is CONTENTS_LADDER?
		delete trace;
		
		for (int loop = 0; loop < sizeof(i_Ruina_Laser_BEAM_HitDetected); loop++)
		{
			int victim = i_Ruina_Laser_BEAM_HitDetected[loop];
			if (victim && IsValidEnemy(this.client, victim))
			{
				this.trace_hit_enemy=true;

				float playerPos[3];
				WorldSpaceCenter(victim, playerPos);

				float Dmg = this.Damage;

				if(ShouldNpcDealBonusDamage(victim))
					Dmg = this.Bonus_Damage;
				
				if(Dmg!=0.0)
					SDKHooks_TakeDamage(victim, this.client, this.client, Dmg, this.damagetype, -1, _, playerPos);

				if(Attack_Function && Attack_Function != INVALID_FUNCTION)
				{	
					Call_StartFunction(null, Attack_Function);
					Call_PushCell(this.client);
					Call_PushCell(victim);
					Call_PushCell(this.damagetype);
					Call_PushFloat(Dmg);
					Call_Finish();

					//static void On_LaserHit(int client, int target, int damagetype, float damage)
				}
			}
		}
	}
	void SetHull(float hullMin[3], float hullMax[3])
	{
		if(this.Custom_Hull[0] != 0.0 || this.Custom_Hull[1] != 0.0 || this.Custom_Hull[2] != 0.0)
		{
			hullMin[0] = -this.Custom_Hull[0];
			hullMin[1] = -this.Custom_Hull[1];
			hullMin[2] = -this.Custom_Hull[2];
		}
		else
		{
			hullMin[0] = -this.Radius;
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
		}
		hullMax[0] = -hullMin[0];
		hullMax[1] = -hullMin[1];
		hullMax[2] = -hullMin[2];
	}
}

bool Ruina_Laser_BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}
static bool Ruina_Laser_BEAM_TraceUsers(int entity, int contentsMask)
{
	if (IsEntityAlive(entity))
	{
		for(int i=0 ; i < sizeof(i_Ruina_Laser_BEAM_HitDetected) ; i++)
		{
			if(!i_Ruina_Laser_BEAM_HitDetected[i])
			{
				i_Ruina_Laser_BEAM_HitDetected[i] = entity;
				break;
			}
		}
	}
	return false;
}
//A far more "simplified" version of the ruina laser that comes pre packaged with laser effects, falloff, and the like.
enum struct Basic_NPC_Laser
{
	CClotBody npc;
	float Radius;
	float Range;
	float Close_Dps;
	float Long_Dps;
	int Color[4];

	float EffectsStartLoc[3];
	bool DoEffects;
	bool RelativeOffset;
}
void Basic_NPC_Laser_Logic(Basic_NPC_Laser Data)
{
	CClotBody npc = Data.npc;
	float Radius = Data.Radius;
	float diameter = Radius*2.0;
	float Range = Data.Range;
	float Close_Dps =  Data.Close_Dps;
	float Long_Dps =  Data.Long_Dps;
	float Max_Dist = Range*Range;
	
	Ruina_Laser_Logic Laser;
	Laser.client = npc.index;
	
	GetOffsetLaserStartLoc(Data, Laser);

	if(Data.DoEffects)
		BeamEffects(Laser.Start_Point, Laser.End_Point, Data.Color, diameter);
	
	Laser.Radius = Radius;
	Laser.Enumerate_Simple();
	for (int loop = 0; loop < sizeof(i_Ruina_Laser_BEAM_HitDetected); loop++)
	{
		//get victims from the "Enumerate_Simple"
		int victim = i_Ruina_Laser_BEAM_HitDetected[loop];
		if(!victim)
			break;	//no more targets are left, break the loop!

		float playerPos[3];
		GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
		float Dist = GetVectorDistance(Laser.Start_Point, playerPos, true);	//make is squared for optimisation sake

		float Ratio = Dist / Max_Dist;
		float damage = Close_Dps + (Long_Dps-Close_Dps) * Ratio;

		//somehow negative damage. invert.
		if (damage < 0)
			damage *= -1.0;
		
		SDKHooks_TakeDamage(victim, npc.index, npc.index, damage, DMG_PLASMA);	// 2048 is DMG_NOGIB?
	}
}
//this basically makes the offset actually affect the traces's start pos. annoying, but its needed.
static void GetOffsetLaserStartLoc(Basic_NPC_Laser Data, Ruina_Laser_Logic Laser)	//:(
{
	CClotBody npc = Data.npc;
	float Angles[3], startPoint[3];
	WorldSpaceCenter(npc.index, startPoint);
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);
	
	int iPitch = npc.LookupPoseParameter("body_pitch");
			
	float flPitch = npc.GetPoseParameter(iPitch);
	flPitch *= -1.0;
	Angles[0] = flPitch;

	if(Data.RelativeOffset)
		Offset_Vector(Data.EffectsStartLoc, Angles, startPoint);
	else if(Data.EffectsStartLoc[0] != 0.0 || Data.EffectsStartLoc[1] != 0.0 || Data.EffectsStartLoc[2] != 0.0)
		startPoint = Data.EffectsStartLoc;

	Laser.DoForwardTrace_Custom(Angles, startPoint, Data.Range);
}

static void BeamEffects(float startPoint[3], float endPoint[3], int color[4], float diameter)
{
	int colorLayer4[4];
	SetColorRGBA(colorLayer4, color[0], color[1], color[2], color[3]);
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, color[3]);
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, color[3]);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, color[3]);
	TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
	TE_SendToAll(0.0);
//	TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
//	TE_SendToAll(0.0);
// I have removed one TE as its way too many te's at once.
	TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
	TE_SendToAll(0.0);
	int glowColor[4];
	SetColorRGBA(glowColor, color[0], color[1], color[2], color[3]);
	TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Glow, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
	TE_SendToAll(0.0);
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
stock bool IsVecEmpty(float vec[3])
{	
	for(int i=0 ; i < 3 ; i++) {if(vec[i]) return false;}
	return true;
}

enum struct VectorTurnData {
	float Origin[3];
	float TargetVec[3];
	float CurrentAngles[3];

	float PitchSpeed;
	float YawSpeed;

	float YawRotateLeft;
	float PitchRotateLeft;

}

stock float[] TurnVectorTowardsGoal(VectorTurnData Data)
{
	CClotBody Nada = view_as<CClotBody>(0);	//the util stuff is defined inside a methodmap. thing is, they don't use any npc specific data from the methodmap. so uh. yeah
	float desiredPitch;
	float desiredYaw;
	if(!IsVecEmpty(Data.Origin)) {
		//we have a valid origin, therefor assume its a turn from one location vector to another location vector.
		float SubractedVec[3];
		Data.Origin[2] += 1.0;
		for(int i=0 ; i < 3 ; i++) {SubractedVec[i] = Data.TargetVec[i] - Data.Origin[i];}
		
		desiredPitch = Nada.UTIL_VecToPitch( SubractedVec );
		desiredYaw = Nada.UTIL_VecToYaw( SubractedVec );
	}
	else {
		//otherwise the "TargetVec" is angle values.
		desiredYaw   = Data.TargetVec[1];
		desiredPitch = Data.TargetVec[0];	
	}

	float angles[3];
	angles = Data.CurrentAngles;

	float angleDiff_Yaw = Nada.UTIL_AngleDiff( desiredYaw, angles[1] );		//now get the difference between what we want and what we have as our angles
	float deltaYaw = Data.YawSpeed;										//set turn speed
	angleDiff_Yaw = fixAngle(angleDiff_Yaw);
	Data.YawRotateLeft = angleDiff_Yaw;
	if ( angleDiff_Yaw < -deltaYaw )	
	{
		angles[1] -= deltaYaw;
	}
	else if ( angleDiff_Yaw > deltaYaw )
	{
		angles[1] += deltaYaw;
	}
	else
	{
		//if the turn speed is higher then the amount needed to turn, just set the turn as the same as the difference
		angles[1] += angleDiff_Yaw;
	}
	Data.YawSpeed = fabs(angleDiff_Yaw) > Data.YawSpeed ? (angleDiff_Yaw  > 0 ? Data.YawSpeed*-1.0 : Data.YawSpeed): angleDiff_Yaw;	//now set the turn rates as a return value.
	//usefull if you wanna say make an object's "spin" dependant on how fast its turning
	//Pitch
	float angleDiff_Pitch = Nada.UTIL_AngleDiff( desiredPitch, angles[0] );	//now get the difference between what we want and what we have as our angles
	float deltaPitch = Data.PitchSpeed;									//set turn speed
	angleDiff_Pitch = fixAngle(angleDiff_Pitch);
	Data.PitchRotateLeft = angleDiff_Pitch;
	if ( angleDiff_Pitch < -deltaYaw )
	{
		angles[0] -= deltaPitch;
	}
	else if ( angleDiff_Pitch > deltaYaw )
	{
		angles[0] += deltaPitch;
	}
	else
	{
		angles[0] += angleDiff_Pitch;
	}
	Data.PitchSpeed = fabs(angleDiff_Pitch) > Data.PitchSpeed ? (angleDiff_Pitch  > 0 ? Data.PitchSpeed*-1.0 : Data.PitchSpeed): angleDiff_Pitch;	//now set the turn rates as a return value.
	//usefull if you wanna say make an object's "spin" dependant on how fast its turning


	return angles;
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

Mana Sickness:
Its a special effect for ruina.
If a player gets more then 2x thier max mana, an ION cannon is fired onto their location, the stats scale on the current "stage"
Additionally, they get slowed a bit, and lose all their mana alongside their mana regen being blocked.

Names per stage:
	Stage 1 -> Stage 2 -> Stage 3 -> Starge 4.

	Each subsequent stage the npc gains a new ability, most of the time it will be an expanded version of what they have, or something new. alongside just higher base stats.

	Stage 1: Introduction.
	Stage 2: ?
	Stage 3: Battery gain via takedamage.								- make the battery ongain a % of health lost cause otherwise converting damage taken into battery would be op.
	Stage 4: Use particle effects as cosmetic things, to show "power"
	//created
	1: Magia -> Magnium -> Magianas -> Magianius
	{
		State: Slave AI
		Class: Medic.
		Ranged.
		Retreats from enemies.
		Battery: Buff's nearby Ranged npc's speed

		Stage 1: Done.
		Stage 2: Done.  . Gains the ability to fire a ICBM
		Stage 3: Done.	is just a stronger variant. Additionally: while the battery boost is active fired projectiles have homing
		Stage 4: Done.  is stronger

		Magnium:
		{
			Fire 2 projectils in a row, with a reload between them
			ICBM: Gains the ability to launch a "homing" projectile rocket.
			
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
		Stage 2: Done.	Is just stronger variant + Teleport deals damage to targets hit
		Stage 3: Done.	Is just stronger variant
		Stage 4: Done. Stronger and	Can heal other nearby lanius type npc's

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
		Stage 2: Done.	is just stronger variant
		Stage 3: Done. is just stronger variant
		Stage 4: Done. Class becomes sniper. Nearby npc's gain a 50% dmg bonus

	}
	//created
	4: Astria -> Astriana -> Astrianis -> Astrianious
	{
		state: Master AI.
		Class: Engie
		Slow itself, boots nearby npc speed passively.
		Battery: Nearby npc's gain the ability to teleport once. cannot have multiple "charges" (since its a bool)

		Stage 1: Done.
		Stage 2: Done.	is simply stronger.
		Stage 3: Done.  is simply stronger.
		Stage 4: Done. stronger
	}

	//created
	5: Europa -> Europis -> Eurainis -> Euranionis
	{
		State: Master AI.
		Class: Pyro.
		Summons "brainless" npc's
		Battery: Summons itself.

		Stage 1: Done.
		Stage 2: Done. can summon now includes Magia and Lanius from the previous stage.
		Stage 3: Done. stronger also when summoning itself, it boosts the speed of ruina npc's in a small radius. this is heavy boost, lasts for a while	
		Stage 4: Done. stronger
	}
	//created
	6: Daedalus -> Draedon -> Draeonis -> Draconia
	{
		State: Slave.
		Class: Scout
		Support: Shield.
		Battery: Provides shield to npc's within range.

		Stage 1: Done.
		Stage 2: Done. 	Its just a buffed version.
		Stage 3: Done. 	Its just a buffed version.
		Stage 4: Done.	Will be able to override the shield timeout

	}
	//created
	7: Aether -> Aetheria -> Aetherium -> Aetherianus
	{
		State: Slave - Indepentant Long range.
		Class: Sniper
		Ranged:

		Attacks from a far with artilery spells. basically the railgunners of this wave.

		Stage 1: Done.
		Stage 2: Done.	is just buffed variant
		Stage 3: Done.	battery: gains the ability to shoot a laser projectile of D00M
		Stage 4: Done.		Buff other nearby Aether class npc's dmg
	}
	//created
	8: Malius -> Maliana -> Malianium -> Malianius.
	{
		State: Master AI.
		Class: Engie
		Support: Battery
		Battery: Gives a set amt of battery to nearby npc's

		Stage 1: Done.
		Stage 2: Done.		Is a stronger variant, does an animation and stands still while casting the battery buff.
		Stage 3: Done. Is stronger.
		Stage 4: Done.		Once starting the animation, will fire an ion onto some random dude it can see.

	}
	//created
	
	9: Ruriana -> Ruianus -> Rulius -> Rulianius
	{
		State: Master AI.
		Class: Medic.
		Ranged, Melee.
		Passive: damage taken is healed to allies around.

		Stage 1: Done.
		Stage 2: Done. is just a stronger variant.
		Stage 3: Done.
			Every 20 seconds fire a fantasmal wave.
			This fantasmal wave can be dodged by simply jumping over it.
			Additionally, a portion of the damage dealt by this wave is transfered over to the healing amount.
		Stage 4: Done. Class becomes soldier. gains the ability to fire a laser every once in a while

	}
	10: Laz -> Lazius -> Lazines -> Lazurus
	{
		State: Master AI.
		Class: Demo.
		Ranged: Laser.

		Stage 1: Done.	Laz
		Stage 2: Done.	battery: shoot a stronger variant of the laser, has better homing too
		Stage 3: Done.	Lazines. is a stronger variant
		Stage 4: Done.	Lazurus is stronger.

	}
	//created
	11: Drone -> Dronian -> Dronis -> Dronianis
	{
		State: Melee AI.
		Class: Spy
		Melee.
		it only exists as a minnion to be spammed. it has nothing special for now

		Stage 1: Done.
		Stage 2: Done.	is just a stronger variant
		Stage 3: Done.	stronger.		(the shanker 9000)
		Stage 4: Done.	Stronger.		MORE SHANKING. EVEN DEADLIER also gives a 25% dmg bonus to everyone around it. self not included
	}

	Todo: Rewrite these.
	Valiant	//Gonna be set into special, like expi spies.
	{
		State: Independant
		Class: Engie
		Has the ability to build a special building that once built spawns drones
	}
	Building: "Magia Anchor"
	{
		spawns drones respective to the stage.
	
		they have the abiltiy to summon a "Stellar Weaver" once "power" hits 100%
	}
	Special: "Stellar Weaver":
	{
		A worm boss, it itself doesn't have a hitbox.

		Seems to be functional, it can handle situtations where the anchor doesn't exist, when one appears.
		its damage scales on wave count too.
	}


	Stage 1 specials:

	Adiantum - Boss. W14, W15.

	Theocracy - Boss. W15

	Stage 2 specials:

	Lex. - Boss. W30.
	Iana - Boss. W30.	

	Stage 3 specials:

	Ruliana - Boss W45 

	Stage 4 specials:

	Lancelot - W60 boss. 
	- Add sound effects for the various things


	Ruliana: - Blitzkrieg was based off of her. so has a similar-ish theme of rocket spam. but gonna need to do make it seems different so its not just a copy of blitz.
	Is a "super boss". so only one of her.
	Custom model somewhat goes into the hand, *hinting towards Reiuji*. see about making wings with a custom model too.
	Medic class.


	RAIDBOSS: Twirl.

	Core:

	High damage, low hp. like blitzkrieg

	Dual mode:
	If fighting a melee player, uses a melee weapon.
	If fighting a ranged player, uses a ranged weapon.

	Every 10th? ranged hit, fire a laser.	Hand throw anim, 0.5s duration. 0.0 turnrate.
	Every 10th? melee hit, fie an ION.		on target. 1.25 det time. 

	Stage 1:
	Retreat: Teleports in a random set direction, leaving behind a ION cannon.

	Stage 2:
	Retreat: Fires a ion on every player who is near the position she was at before teleporting.
	Laser Punch: Fires several lazius lasers, they all go towards the same target, no homing, no prediction. stagger fire.

	Stage 3:
	Retreat: the same.
	Laser Punch: the same
	Cosmic Gaze: MOOOOOOOOOOOOOOOOOOORTIS. punches and an explosion happens a second later where she was looking.

	Stage 4:
	Retreat: The same + upon retreating, fires a 2 second laser towards where she was. use z anim.
	Laser Punch: the same + wherever the projectile hits a ION strike happens a second later
	Cosmic Gaze: the same
	Lunar Radiance: shoots ions on every player that also predict's thier pos.

	
	FINAL TODO LIST:
	Make the cfg.


*/
void Lanius_Teleport_Effect(char[] type, float duration = 0.0, float start_point[3], float end_point[3])
{
	if(AtEdictLimit(EDICT_NPC))
		return;

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

/*
//stage1:
npc_ruina_magia
npc_ruina_lanius
npc_ruina_aether
npc_ruina_daedalus
npc_ruina_europa
npc_ruina_helia
npc_ruina_ruriana   1300
npc_ruina_laz
npc_ruina_astria
npc_ruina_malius
npc_ruina_adiantum
npc_ruina_theocracy
//stage2:
npc_ruina_magnium     500
npc_ruina_laniun      1000
npc_ruina_aetheria    700
npc_ruina_lazius      900
npc_ruina_europis     900
npc_ruina_heliara     1250
npc_ruina_draedon     900
npc_ruina_astriana    2600
npc_ruina_maliana     1200
npc_ruina_ruianus     3000
npc_ruina_iana        30000
npc_ruina_lex         
//stage3:
npc_ruina_magianas    1250
npc_ruina_loonaris    2500
npc_ruina_lazines     1800
npc_ruina_heliaris    3000
npc_ruina_rulius      5000
npc_ruina_eurainis    2000
npc_ruina_draeonis    2250
npc_ruina_malianium   2400
npc_ruina_aetherium   1500
npc_ruina_astrianis   4000
npc_ruina_ruliana     350000
//stage 4:
npc_ruina_magianius    6000
npc_ruina_loonarionus  7500
npc_ruina_heliarionus  6000
npc_ruina_euranionis   8000
npc_ruina_draconia     9000
npc_ruina_malianius    12500
npc_ruina_lazurus      8000
npc_ruina_aetherianus  9000
npc_ruina_rulianius    30000
npc_ruina_astrianious  20000
npc_ruina_lancelot
*/
