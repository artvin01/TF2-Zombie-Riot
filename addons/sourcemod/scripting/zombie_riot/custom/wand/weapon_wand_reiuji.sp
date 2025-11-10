#pragma semicolon 1
#pragma newdecls required

static Handle h_Reiuji_WeaponHudTimer[MAXPLAYERS] = {null, ...};
static float fl_hud_timer[MAXPLAYERS];
static float fl_ammo_timer[MAXPLAYERS];
static int i_ammo[MAXPLAYERS];
static int 		i_max_ammo				[6] = {10, 15, 20, 25, 30, 40};
static float 	fl_ammogain_timerbase	[6] = {1.0, 1.0, 0.8, 0.7, 0.6, 0.45};
static float 	fl_firerate_multi		[6] = {0.5, 0.45, 0.4, 0.3, 0.2, 0.2};

static int 		i_max_barage			[6] = {3, 4, 5, 6, 7, 9};
static float 	fl_barrage_angles		[6] = {45.0, 45.0, 45.0, 45.0, 45.0, 45.0};
static float 	fl_barrage_maxrange		[6] = {1250.0, 1250.0, 1250.0, 1250.0, 1250.0, 1250.0};
static float 	fl_barrage_maxcharge	[6] = {600.0, 750.0, 1000.0, 1250.0, 1500.0, 1500.0};

static int 		i_ALT_m1_amounts		[6] = {3, 3, 3, 4, 5, 6};

//charge gained will depend on mana consumed.
static float fl_barrage_charge[MAXPLAYERS];
static bool b_BarrageModeOn[MAXPLAYERS];


#define REIUJI_WAND_TOUCH_SOUND "friends/friend_online.wav"
#define REIUJI_WAND_M2_CAST_SOUND "weapons/cow_mangler_over_charge_shot.wav"
/*
	make mana cost on final pap roughly 50 per projectile
	make max ammo on final pap 30 shots
	make m2 use up a lot of mana on cast.

	initial:
		only has the ammo mechanic.

	pap1:
		gain extra ammo if above 50% mana

	pap2:
		gain barrage.

	pap3:
		gain homing if above 50% barrage.

	pap4:
		damage buff.

	pap5:
		damage buff
*/

static char WandAttackSounds[][] = {
	"ambient/energy/zap1.wav",
	"ambient/energy/zap2.wav",
	"ambient/energy/zap3.wav",
	"ambient/energy/zap5.wav",
	"ambient/energy/zap6.wav",
	"ambient/energy/zap7.wav",
	"ambient/energy/zap8.wav",
	"ambient/energy/zap9.wav"
};
void Reiuji_Wand_OnMapStart()
{
	Zero(i_ammo);
	Zero(fl_hud_timer);
	Zero(fl_ammo_timer);
	PrecacheSound(REIUJI_WAND_TOUCH_SOUND, true);
	PrecacheSound(REIUJI_WAND_M2_CAST_SOUND, true);
	PrecacheSoundArray(WandAttackSounds);
	Zero(b_BarrageModeOn);
}
static void PlayWandAttackSound(int client, int soundlevel = 80, float volume = 1.0, int pitch = 100) { EmitSoundToAll(WandAttackSounds[GetRandomInt(0, sizeof(WandAttackSounds) - 1)], client, SNDCHAN_VOICE, soundlevel, _, volume, pitch);}

void Enable_Reiuji_Wand(int client, int weapon)
{
	//not our weapon, abort.
	if(i_CustomWeaponEquipLogic[weapon] != WEAPON_REIUJI_WAND)
		return;

	fl_hud_timer[client] = 0.0;

	//timer already exists, kill it.
	if(h_Reiuji_WeaponHudTimer[client] != null)
		delete h_Reiuji_WeaponHudTimer[client];

	//create timer.
	DataPack pack;
	h_Reiuji_WeaponHudTimer[client] = CreateDataTimer(0.1, Timer_Reiuji_Wand, pack, TIMER_REPEAT);
	pack.WriteCell(client);
	pack.WriteCell(EntIndexToEntRef(weapon));
}
static int i_pap(int weapon) {return RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));}

static Action Timer_Reiuji_Wand(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_Reiuji_WeaponHudTimer[client] = null;
		return Plugin_Stop;
	}
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding != weapon) //Only show if the weapon is actually in your hand right now.
		return Plugin_Continue;

	float GameTime = GetGameTime();
	if(fl_ammo_timer[client] < GameTime)
	{
		int pap = i_pap(weapon_holding);

		if(Current_Mana[client] > max_mana[client]/2 && pap>0)
		{
			if(Current_Mana[client] > max_mana[client]*0.9)
				fl_ammo_timer[client] = GameTime + fl_ammogain_timerbase[pap]*0.25;
			else
				fl_ammo_timer[client] = GameTime + fl_ammogain_timerbase[pap]*0.7;
		}
		else
			fl_ammo_timer[client] = GameTime + fl_ammogain_timerbase[pap];
		

		if(i_ammo[client] < i_max_ammo[pap])
			i_ammo[client]++;
	}

	Hud(client, weapon_holding);

	return Plugin_Continue;
}
static void Hud(int client, int weapon)
{
	float GameTime = GetGameTime();
	if(fl_hud_timer[client] > GameTime)
		return;
	
	//faster then 0.5 and it starts to glitch out.
	fl_hud_timer[client] = GameTime + 0.5;

	char HUDText[255] = "";

	int pap = i_pap(weapon);

	if(i_ammo[client] > i_max_ammo[pap])
		i_ammo[client] = i_max_ammo[pap];

	if(i_ammo[client] < i_max_ammo[pap])
		Format(HUDText, sizeof(HUDText), "Ammo: [%i/%i] (%.1fs)", i_ammo[client], i_max_ammo[pap], fl_ammo_timer[client]-GameTime);
	else
		Format(HUDText, sizeof(HUDText), "Ammo: [%i/%i]", i_ammo[client], i_max_ammo[pap]);
	
	if(b_BarrageModeOn[client])
	{
		Format(HUDText, sizeof(HUDText), "%s\nAmmo Mode ON [R]", HUDText);
	}
	else
	{
		Format(HUDText, sizeof(HUDText), "%s\nAmmo Mode OFF [R]", HUDText);
	}

	if(pap>1)
	{
		if(fl_barrage_charge[client] > fl_barrage_maxcharge[pap])
			fl_barrage_charge[client] = fl_barrage_maxcharge[pap];

		Format(HUDText, sizeof(HUDText), "%s\nBarrage: [%.0f％]", HUDText, (fl_barrage_charge[client]/fl_barrage_maxcharge[pap]*100.0));
	}
		

	PrintHintText(client, HUDText);
}
public void Reiuji_Wand_Barrage_Attack_ALT(int client, int weapon, bool crit, int slot)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0)*10.0);

	if(Current_Mana[client] < mana_cost)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return;
	}

	if (Ability_Check_Cooldown(client, slot) > 0.0)
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		return;	
	}				

	int pap = i_pap(weapon);

	if(fl_barrage_charge[client] < fl_barrage_maxcharge[pap] && !CvarInfiniteCash.BoolValue)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Your Weapon is not charged enough", RoundToFloor(fl_barrage_charge[client]), RoundToFloor(fl_barrage_maxcharge[pap]));
		return;
	}

	int loop_for = i_max_barage[pap];
	float range = fl_barrage_maxrange[pap];

	int[] valid_targets = new int[loop_for];
	int targets_aquired = 0;

	float tolerance_angle = fl_barrage_angles[pap];

	float Origin[3]; GetClientEyePosition(client, Origin);
	Zero(i_Ruina_Laser_BEAM_HitDetected);
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	TR_EnumerateEntitiesSphere(Origin, range, PARTITION_NON_STATIC_EDICTS, TraceEntityEnumerator_Reiuji, client);
	FinishLagCompensation_Base_boss();

	for(int i=0 ; i < loop_for ; i++)
	{
		valid_targets[i] = -1;
	}

	for(int i=0; i < sizeof(i_Ruina_Laser_BEAM_HitDetected); i++)
	{
		int enemy = i_Ruina_Laser_BEAM_HitDetected[i];
		if(enemy <= 0)
			break;

		if(targets_aquired >= loop_for)
			break;


		//todo: this doesn't work as expected. why? dunno yet.
		//investigate
		float vecTarget[3]; GetAbsOrigin(enemy, vecTarget); vecTarget[2] +=35.0;
		float ProjLoc[3]; ProjLoc = GetReiujiBarrageSpecialLoc(client, targets_aquired, loop_for);
		float AttackAngles[3];
		MakeVectorFromPoints(Origin, ProjLoc, AttackAngles);
		GetVectorAngles(AttackAngles, AttackAngles);

		if(!IsLineOfSight_Vec(ProjLoc, AttackAngles, vecTarget, tolerance_angle, range, client))
			continue;

		valid_targets[targets_aquired] = enemy;
		targets_aquired++;
	}

	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, CvarInfiniteCash.BoolValue ? 0.0 : 10.0);

	float damage = 200.0 * Attributes_Get(weapon, 410, 1.0);
	float speed = 1100.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	speed *= Attributes_Get(weapon, 104, 1.0);
	speed *= Attributes_Get(weapon, 475, 1.0);

	float time = fl_barrage_maxrange[i_pap(weapon)]/speed;
	time *= Attributes_Get(weapon, 101, 1.0);
	time *= Attributes_Get(weapon, 102, 1.0);

	float Linger_Time = 150.0 / speed;

	for(int i=0 ; i < loop_for ; i++)
	{
		float ProjLoc[3]; ProjLoc = GetReiujiBarrageSpecialLoc(client, i, loop_for);
		float AttackAngles[3];
		MakeVectorFromPoints(Origin, ProjLoc, AttackAngles);
		GetVectorAngles(AttackAngles, AttackAngles);
		int projectile = FireBarrageProjectile_ALT(client, weapon, damage, time + Linger_Time, speed, AttackAngles);
		if(projectile == -1)
			continue;

		DataPack Pack;
		CreateDataTimer(Linger_Time, ReiujiBarrage_OffsetProj, Pack, TIMER_FLAG_NO_MAPCHANGE);
		Pack.WriteCell(EntIndexToEntRef(projectile));
		Pack.WriteFloat(speed);
		Pack.WriteCell(valid_targets[i] > 0 ? EntIndexToEntRef(valid_targets[i]) : -1);
	}


	fl_barrage_charge[client] -= fl_barrage_maxcharge[pap] * (float(targets_aquired)/float(loop_for));
	Current_Mana[client] -= RoundToFloor(mana_cost * (float(targets_aquired)/float(loop_for)));

	SDKhooks_SetManaRegenDelayTime(client, 2.0);
	Mana_Hud_Delay[client] = 0.0;
	delay_hud[client] = 0.0;

	EmitSoundToAll(REIUJI_WAND_M2_CAST_SOUND, client, _, 65, _, 1.0, SNDPITCH_NORMAL);

	if(fl_barrage_charge[client] < 0.0)
	{
		//CPrintToChatAll("barrage went beyond 0.0, correcting: %.3f", fl_barrage_charge[client]);
		fl_barrage_charge[client] = 0.0;
	}
	
}
static Action ReiujiBarrage_OffsetProj(Handle Timer, DataPack pack)
{
	pack.Reset();
	int projectile 	= EntRefToEntIndex(pack.ReadCell());
	float Speed 	= 				   pack.ReadFloat();
	int enemy 		= EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(projectile))
	{
		return Plugin_Stop;
	}
	float GoAngles[3];
	float ProjLoc[3]; GetAbsOrigin(projectile, ProjLoc);
	int owner = EntRefToEntIndex(i_WandOwner[projectile]);
	if(!IsValidClient(owner))
	{
		return Plugin_Stop;
	}
	if(!IsValidEntity(enemy))
	{
		GetClientEyeAngles(owner, GoAngles);
		enemy = -1;
	}
	else
	{
		float EnemyLoc[3];
		GetAbsOrigin(enemy, EnemyLoc); EnemyLoc[2]+=55.0;
		MakeVectorFromPoints(ProjLoc, EnemyLoc, GoAngles);
		GetVectorAngles(GoAngles, GoAngles);
	}

	ReplaceWandParticle(projectile, "drg_manmelter_trail_red");

	float 	Homing_Power = 5.0,
			Homing_Lockon = 45.0;

	Initiate_HomingProjectile(projectile,
	owner,
	Homing_Lockon,			// float lockonAngleMax,
	Homing_Power,			// float homingaSec,
	true,					// bool LockOnlyOnce,
	true,					// bool changeAngles,
	GoAngles,
	enemy);

	CreateTimer(1.5, KillProjectileHoming, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);

	SetProjectileSpeed(projectile, Speed, GoAngles);
	TeleportEntity(projectile, NULL_VECTOR, GoAngles, NULL_VECTOR);

	//only bother rendering this if we are fine on edicts
	if(AtEdictLimit(EDICT_PLAYER) || enemy == -1)
		return Plugin_Stop;

	int color[4];
	Ruina_Color(color);
	int laser = ConnectWithBeam(projectile, enemy, color[0], color[1], color[2], 5.0, 2.5, 0.25, BEAM_COMBINE_BLUE);
	CreateTimer(0.2, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);

	i_OwnerEntityEnvLaser[laser] = EntIndexToEntRef(owner);
	SDKHook(laser, SDKHook_SetTransmit, SetTransmitHarvester);

	
	return Plugin_Stop;
}
static float[] GetReiujiBarrageSpecialLoc(int client, int i, int loop_for)
{
	float BarrageAngles[3];
	float EndLoc[3];
	GetClientEyeAngles(client, BarrageAngles);
	GetAbsOrigin(client, EndLoc);
	BarrageAngles[0] = (loop_for*2.0 + 25.0) * -1.0;
	BarrageAngles[1] += (360.0 / loop_for) * i;	//yaw

	float ReturnVal[3];
	Get_Fake_Forward_Vec(250.0, BarrageAngles, ReturnVal, EndLoc);

	return ReturnVal;
}
static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}
static bool Check_Line_Of_Sight_Vector(float pos_npc[3], float Enemy_Loc[3], int attacker = -1)
{
	float vecAngles[3];
	//get the enemy gamer's location.
	//get the angles from the current location of the crystal to the enemy gamer
	MakeVectorFromPoints(pos_npc, Enemy_Loc, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);
	//get the estimated distance to the enemy gamer,
	float Dist = GetVectorDistance(Enemy_Loc, pos_npc);
	//do a trace from the current location of the crystal to the enemy gamer.

	//Both are basically identical, its just one has lag comp and the other doesn't
	//why didn't I just merge them. aaa
	if(attacker > 0)
	{
		Player_Laser_Logic Laser;
		Laser.client = attacker;	//this only matter ons player laser logic since it has lag comp. while ruina laser logic doesn't have lag comp. and in this case we are not using the entity index for anything.
		Laser.Start_Point = pos_npc;
	
		Laser.DoForwardTrace_Custom(vecAngles, pos_npc, Dist);	//alongside that, use the estimated distance so that our end location from the trace is where the player is.

		//see if the vectors match up, if they do we can safely say the target is in line of sight of the origin npc/loc
		return Similar_Vec(Laser.End_Point, Enemy_Loc);
	}
	else
	{
		Ruina_Laser_Logic Laser;
		Laser.Start_Point = pos_npc;
		Laser.DoForwardTrace_Custom(vecAngles, pos_npc, Dist);	//alongside that, use the estimated distance so that our end location from the trace is where the player is.

		//see if the vectors match up, if they do we can safely say the target is in line of sight of the origin npc/loc
		return Similar_Vec(Laser.End_Point, Enemy_Loc);
	}
	
}
static bool TraceEntityEnumerator_Reiuji(int entity, int client)
{
	//This will automatically take care of all the checks, very handy.
	if(!IsValidEnemy(client, entity, true)) //Must detect camo.
		return true;
	
	for(int i=0; i < sizeof(i_Ruina_Laser_BEAM_HitDetected); i++)
	{
		if(i_Ruina_Laser_BEAM_HitDetected[i] == entity)
			break;

		if(!i_Ruina_Laser_BEAM_HitDetected[i])
		{
			i_Ruina_Laser_BEAM_HitDetected[i] = entity;
			break;
		}
	}
	//always keep going!
	return true;
}
public void Reiuji_Wand_Barrage_Attack(int client, int weapon, bool crit, int slot)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0)*10.0);

	if(Current_Mana[client] < mana_cost)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return;
	}

	if (Ability_Check_Cooldown(client, slot) > 0.0)
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		return;	
	}				

	int pap = i_pap(weapon);

	if(fl_barrage_charge[client] < fl_barrage_maxcharge[pap] && !CvarInfiniteCash.BoolValue)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Your Weapon is not charged enough", RoundToFloor(fl_barrage_charge[client]), RoundToFloor(fl_barrage_maxcharge[pap]));
		return;
	}


	int loop_for = i_max_barage[pap];
	float tolerance_angle = fl_barrage_angles[pap];
	float range = fl_barrage_maxrange[pap];

	int[] valid_targets = new int[loop_for];
	int targets_aquired = 0;

	for(int a; a < i_MaxcountNpcTotal; a++)
	{
		if(targets_aquired >= loop_for)
			break;

		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[a]);

		if(!IsValidEnemy(client, entity))
			continue;

		int target = IsLineOfSight(client, entity, tolerance_angle, range);

		if(IsValidEnemy(client, target))
		{
			//CPrintToChatAll("2 valid target: %i", target);
			valid_targets[targets_aquired] = target;
			targets_aquired++;
		}
	}

	if(targets_aquired == 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "No Targets Detected");
		return;
	}

	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, CvarInfiniteCash.BoolValue ? 0.0 : 5.0);
	
	float Origin[3];
	WorldSpaceCenter(client, Origin);

	for(int i=0 ; i < targets_aquired ; i++)
	{
		int victim = valid_targets[i];

		float VicPos[3], AttackAngles[3];
		WorldSpaceCenter(victim, VicPos);

		MakeVectorFromPoints(Origin, VicPos, AttackAngles);
		GetVectorAngles(AttackAngles, AttackAngles);

		FireBarrageProjectile(client, weapon, AttackAngles, victim);

		//only bother rendering this if we are fine on edicts
		if(AtEdictLimit(EDICT_PLAYER))
			continue;

		int color[4];
		Ruina_Color(color);
		int laser = ConnectWithBeam(client, victim, color[0], color[1], color[2], 5.0, 2.5, 0.25, BEAM_COMBINE_BLUE);
		CreateTimer(0.2, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);

		i_OwnerEntityEnvLaser[laser] = EntIndexToEntRef(client);
		SDKHook(laser, SDKHook_SetTransmit, SetTransmitHarvester);
	}

	fl_barrage_charge[client] -= fl_barrage_maxcharge[pap] * (float(targets_aquired)/float(loop_for));
	Current_Mana[client] -= RoundToFloor(mana_cost * (float(targets_aquired)/float(loop_for)));

	SDKhooks_SetManaRegenDelayTime(client, 2.0);
	Mana_Hud_Delay[client] = 0.0;
	delay_hud[client] = 0.0;

	EmitSoundToAll(REIUJI_WAND_M2_CAST_SOUND, client, _, 65, _, 1.0, SNDPITCH_NORMAL);

	if(fl_barrage_charge[client] < 0.0)
	{
		//CPrintToChatAll("barrage went beyond 0.0, correcting: %.3f", fl_barrage_charge[client]);
		fl_barrage_charge[client] = 0.0;
	}
}
static int IsLineOfSight_Vec(float npc_pos[3], float eyeAngles[3], float Vic_Pos[3], float AnglesMax, float Range, int client = -1)
{
	// need position of either the inflictor or the attacker
	float angle[3];
	float Dist = GetVectorDistance(Vic_Pos, npc_pos, true);
	if(Dist > Range*Range)
		return 0;
	
	GetVectorAnglesTwoPoints(npc_pos, Vic_Pos, angle);

	// need the yaw offset from the player's POV, and set it up to be between (-180.0..180.0]
	float yawOffset = fixAngle(angle[1]) - fixAngle(eyeAngles[1]);
	if (yawOffset <= -180.0)
		yawOffset += 360.0;
	else if (yawOffset > 180.0)
		yawOffset -= 360.0;

	float MaxYaw = AnglesMax;
	float MinYaw = -AnglesMax;
		
	// now it's a simple check
	if ((yawOffset >= MinYaw && yawOffset <= MaxYaw))	//first check position before doing a trace checking line of sight.
	{					
		TE_SetupBeamPoints(npc_pos, Vic_Pos, g_Ruina_BEAM_Laser, 0, 0, 0, 5.0, 15.0, 15.0, 0, 0.1, {255, 255, 255,255}, 3);
		TE_SendToAll();
		return Check_Line_Of_Sight_Vector(npc_pos, Vic_Pos, client);
	}
	return false;
}
static int IsLineOfSight(int client, int Target, float AnglesMax, float Range)
{
	// need position of either the inflictor or the attacker
	float Vic_Pos[3];
	WorldSpaceCenter(Target, Vic_Pos);
	float npc_pos[3];
	float angle[3];
	float eyeAngles[3];
	WorldSpaceCenter(client, npc_pos);

	float Dist = GetVectorDistance(Vic_Pos, npc_pos, true);
	if(Dist > Range*Range)
		return 0;
	
	GetVectorAnglesTwoPoints(npc_pos, Vic_Pos, angle);
	GetEntPropVector(client, Prop_Data, "m_angRotation", eyeAngles);

	// need the yaw offset from the player's POV, and set it up to be between (-180.0..180.0]
	float yawOffset = fixAngle(angle[1]) - fixAngle(eyeAngles[1]);
	if (yawOffset <= -180.0)
		yawOffset += 360.0;
	else if (yawOffset > 180.0)
		yawOffset -= 360.0;

	float MaxYaw = AnglesMax;
	float MinYaw = -AnglesMax;
		
	// now it's a simple check
	if ((yawOffset >= MinYaw && yawOffset <= MaxYaw))	//first check position before doing a trace checking line of sight.
	{					
		return Can_I_See_Enemy(client, Target);
	}
	return 0;
}

public void Reiuji_Wand_AmmoMode(int client, int weapon, bool crit, int slot)
{
	if(b_BarrageModeOn[client])
	{
		b_BarrageModeOn[client] = false;
		ClientCommand(client, "playgamesound misc/halloween/spelltick_01.wav");
	}
	else
	{
		b_BarrageModeOn[client] = true;
		ClientCommand(client, "playgamesound misc/halloween/spelltick_02.wav");
	}
	Reiuji_Wand_AmmomodeInternal(client, weapon, true);
}
public void Reiuji_Wand_AmmoMode_ALT(int client, int weapon, bool crit, int slot)
{
	b_BarrageModeOn[client] = !b_BarrageModeOn[client];
	ClientCommand(client, b_BarrageModeOn[client] ? "playgamesound misc/halloween/spelltick_01.wav" : "playgamesound misc/halloween/spelltick_02.wav");
}

void Reiuji_Wand_AmmomodeInternal(int client, int weapon, bool Toggle = false)
{
	int pap = i_pap(weapon);

	if(i_ammo[client] > 0 && b_BarrageModeOn[client])
	{
		if(!Toggle)
		{
			fl_ammo_timer[client] = GetGameTime() + fl_ammogain_timerbase[pap]*1.25;
			i_ammo[client]--;
		}

		if(i_ammo[client] > 0)
			Attributes_Set(weapon, 5, fl_firerate_multi[pap]);
		else
			Attributes_Set(weapon, 5, 1.0);
	}
	else 
	{
		Attributes_Set(weapon, 5, 1.0);
		if(!Toggle)
		{
			float Offset = 0.35;
			float GameTime = GetGameTime();
			if(fl_ammo_timer[client] < GameTime + Offset)
			{
				fl_ammo_timer[client] = GameTime + Offset;
			}
		}
	}
}
public void Reiuji_Wand_Primary_Attack_ALT(int client, int weapon, bool crit, int slot)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(Current_Mana[client] < mana_cost)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return;
	}

	PlayWandAttackSound(client, 60, 0.5, GetRandomInt(120, 150));

	//rest the ammo gain timer when firing.
	int pap = i_pap(weapon);

	float damage = 125.0 * Attributes_Get(weapon, 410, 1.0);
		
	float speed = 1100.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	speed *= Attributes_Get(weapon, 104, 1.0);
	speed *= Attributes_Get(weapon, 475, 1.0);

	float time = 1000.0/speed;
	time *= Attributes_Get(weapon, 101, 1.0);
	time *= Attributes_Get(weapon, 102, 1.0);

	int projectile_amt = i_ALT_m1_amounts[pap];

	if(b_BarrageModeOn[client])
	{
		if(i_ammo[client] < projectile_amt)
			Reiuji_Wand_AmmoMode_ALT(client, 0, 0, 0);
		else
		{
			int sub_mana_cost = projectile_amt * mana_cost;
			if(sub_mana_cost > Current_Mana[client])
			{
				SetDefaultHudPosition(client, _, _, _, 3.0);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Reiuji Not Enough Mana", sub_mana_cost);
				Reiuji_Wand_AmmoMode_ALT(client, 0, 0, 0);
			}
			else
			{
				mana_cost = sub_mana_cost;
				fl_ammo_timer[client] = GetGameTime() + fl_ammogain_timerbase[pap]*2.0;
			}
		}
		
	}

	Current_Mana[client] -= mana_cost;
	SDKhooks_SetManaRegenDelayTime(client, 2.0);
	Mana_Hud_Delay[client] = 0.0;
	delay_hud[client] = 0.0;

	//no barrage, do normal stuff!
	if(!b_BarrageModeOn[client])
	{
		int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, "drg_manmelter_trail_blue");

		if(!IsValidEntity(projectile))
			return;

		WandProjectile_ApplyFunctionToEntity(projectile, Projectile_Touch);

		fl_ruina_Projectile_radius[projectile] = 0.0;
		fl_ruina_Projectile_bonus_dmg[projectile] = float(mana_cost);
		return;
	}

	float Angles[3]; GetClientEyeAngles(client, Angles);
	float Origin[3]; GetClientEyePosition(client, Origin);

	float Adjusted_Angle = 180.0/projectile_amt;
	float BaseAdd = Adjusted_Angle / 2.0;

	////get where the player is looking at
	//Player_Laser_Logic Laser;
	//Laser.client = client;
	////make sure the range is the exact same as what the projectile would theoretically be able to achive if it flew in a straight line
	//Laser.DoForwardTrace_Basic(time * speed);

	fl_BEAM_ThrottleTime[client] = speed * time;				//save what speed it had alongside time

	float Travel_Relative = 400.0;	//how much to travel before redirecting

	
	float Pre_Redirect_Time = (Travel_Relative/speed)*0.9;
	float Redirect_Time = Travel_Relative/speed;
	//a failsafe cause timers are not perfectly accurate.
	//since the PRE MUST HAPPEN FIRST!!
	if(Redirect_Time - 0.1 > Pre_Redirect_Time)
		Redirect_Time +=0.1;
	//this gets the relative location of where the client is looking just before the projectiles turn towards it.
	CreateTimer(Pre_Redirect_Time, Redirect_Reiuji_Projectile_HandleVecPre, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);

	float Proj_manaGive = float(mana_cost) / float(projectile_amt) * 0.5;

	for(int i=0 ; i < projectile_amt ; i++)
	{
		float ProjectileAngles[3]; 
		ProjectileAngles = Angles;
		ProjectileAngles[1] += Adjusted_Angle * i - 90.0 + BaseAdd;	//fancy vector math

		int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, "raygun_projectile_blue", ProjectileAngles);

		if(!IsValidEntity(projectile))
			return;
		//doing this makes the particle effect for some unknown reason go balistic when entering a wall.
		//guess this will be one of the major downsides: it doesn't work well in enclosed spaces.
		//SetEntityMoveType(projectile, MOVETYPE_NOCLIP);	
		//MakeObjectIntangeable(projectile);

		i_ammo[client]--;
		fl_BEAM_ThrottleTime[projectile] = speed;
		WandProjectile_ApplyFunctionToEntity(projectile, Projectile_Touch);
		fl_ruina_Projectile_radius[projectile] = 0.0;			//related to the projectile touch
		fl_ruina_Projectile_bonus_dmg[projectile] = Proj_manaGive;	//same thing.

		//the rough amount of time needed to travel 400 HU's
		//ON REDIRECT PROJECTILE DMG IS BUFFED BY 20% AND SPEED BY 25%
		CreateTimer(Redirect_Time, Redirect_Reiuji_Projectile, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
	}
}
static void ReplaceWandParticle(int projectile, const char[] particle_string)
{
	int particle = EntRefToEntIndex(i_WandParticle[projectile]);
	if(IsValidEntity(particle))
		RemoveEntity(particle);

	float ProjLoc[3];
	WorldSpaceCenter(projectile, ProjLoc);
	particle = ParticleEffectAt(ProjLoc, particle_string, 0.0); //Inf duartion
	i_WandParticle[projectile]= EntIndexToEntRef(particle);
	SetParent(projectile, particle);	
}

//only do the trace ONCE. and not evert time a projectile is redirected.
//saves on performance
static Action Redirect_Reiuji_Projectile_HandleVecPre(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(!IsValidClient(client))
		return Plugin_Stop;

	//get where the player is looking at
	Player_Laser_Logic Laser;
	Laser.client = client;
	//make sure the range is the exact same as what the projectile would theoretically be able to achive if it flew in a straight line
	i_maxtargets_hit = 3;
	Zero(i_Ruina_Laser_BEAM_HitDetected);
	Laser.DoForwardTrace_Basic(fl_BEAM_ThrottleTime[client], RayCastTraceEnemies);	//so if we find an enemy across our trace path. attach the vector to their abs location.
	for(int i = 0 ; i < sizeof(i_Ruina_Laser_BEAM_HitDetected) ; i++)
	{
		int enemy = i_Ruina_Laser_BEAM_HitDetected[i];
		if(enemy > 0)
		{
			float EnemyLoc[3];
			WorldSpaceCenter(enemy, EnemyLoc);
			fl_AbilityVectorData[client] = EnemyLoc;
			return Plugin_Stop;
		}
		if(i > i_maxtargets_hit)
			break;
	}
	//otherwise where the client is looking at.
	fl_AbilityVectorData[client] = Laser.End_Point;

	return Plugin_Stop;
}
static Action Redirect_Reiuji_Projectile(Handle timer, int ref)
{
	int projectile = EntRefToEntIndex(ref);
	if(!IsValidEntity(projectile))
		return Plugin_Stop;

	int owner = EntRefToEntIndex(i_WandOwner[projectile]);

	if(!IsValidClient(owner))
		return Plugin_Stop;

	float Origin[3]; GetAbsOrigin(projectile, Origin);
	float EndLoc[3]; EndLoc = fl_AbilityVectorData[owner];

	ReplaceWandParticle(projectile, "drg_manmelter_trail_blue");

	f_WandDamage[projectile] *=1.2;

	float Angles[3];
	MakeVectorFromPoints(Origin, EndLoc, Angles);
	GetVectorAngles(Angles, Angles);
	SetProjectileSpeed(projectile, fl_BEAM_ThrottleTime[projectile] * 1.25, Angles);


	return Plugin_Stop;
}
public void Reiuji_Wand_Primary_Attack(int client, int weapon, bool crit, int slot)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(Current_Mana[client] < mana_cost)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return;
	}

	PlayWandAttackSound(client, 60, 0.5, GetRandomInt(120, 150));

	Current_Mana[client] -= mana_cost;
	SDKhooks_SetManaRegenDelayTime(client, 2.0);
	Mana_Hud_Delay[client] = 0.0;
	delay_hud[client] = 0.0;
	
	/*
		So, what we want is this:
		We want the weapon to kind of have a form of "ammo", while this ammo is above 1 you can shoot the wand REALLY fast.
		otherwise its a slower shooting wand.

		you would simply gain ammo via time?

		How to do this:

		idea 1:
			Forcibly set the fl_nextprimary attack thing to 0.2 or something.

		idea 2:
			Set the firerate attribute to something very low. until the final shot, then make it a high attribute.
			//the fun part about this one is that attack speed upgrades would stack with this. which would lead to minigun levels of firerate.

			We'll use attribute 5, since its a "static" attribute that nothing should modify. probably...
	*/

	Reiuji_Wand_AmmomodeInternal(client, weapon);

	//rest the ammo gain timer when firing.
	int pap = i_pap(weapon);

	float damage = 125.0 * Attributes_Get(weapon, 410, 1.0);
		
	float speed = 1100.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	speed *= Attributes_Get(weapon, 104, 1.0);
	speed *= Attributes_Get(weapon, 475, 1.0);

	float time = 1000.0/speed;
	time *= Attributes_Get(weapon, 101, 1.0);
	time *= Attributes_Get(weapon, 102, 1.0);

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, "drg_manmelter_trail_blue");

	if(!IsValidEntity(projectile))
		return;

	WandProjectile_ApplyFunctionToEntity(projectile, Projectile_Touch);

	fl_ruina_Projectile_radius[projectile] = 0.0;
	fl_ruina_Projectile_bonus_dmg[projectile] = float(mana_cost);

	if(fl_barrage_charge[client] < fl_barrage_maxcharge[pap]*0.5 || pap <= 2)
		return;

	float 	Homing_Power = 1.75 * pap,
			Homing_Lockon = 45.0,
			AttackAngles[3];

	GetClientEyeAngles(client, AttackAngles);

	Initiate_HomingProjectile(projectile,
	client,
	Homing_Lockon,			// float lockonAngleMax,
	Homing_Power,			// float homingaSec,
	true,					// bool LockOnlyOnce,
	true,					// bool changeAngles,
	AttackAngles
	);
}
static int FireBarrageProjectile(int client, int weapon, float Angles[3], int victim)
{
	float damage = 200.0 * Attributes_Get(weapon, 410, 1.0);
	float radius = 250.0;
	float speed = 1100.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	speed *= Attributes_Get(weapon, 104, 1.0);
	speed *= Attributes_Get(weapon, 475, 1.0);

	float time = fl_barrage_maxrange[i_pap(weapon)]/speed;
	time *= Attributes_Get(weapon, 101, 1.0);
	time *= Attributes_Get(weapon, 102, 1.0);

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, "drg_manmelter_trail_red", Angles);
	WandProjectile_ApplyFunctionToEntity(projectile, Projectile_Touch);

	if(!IsValidEntity(projectile))
		return -1;

	fl_ruina_Projectile_bonus_dmg[projectile] = 0.0;
	fl_ruina_Projectile_radius[projectile] = radius;

	int ModelApply = ApplyCustomModelToWandProjectile(projectile, RUINA_CUSTOM_MODELS_1, 1.0, "icbm_idle");
	if(IsValidEntity(ModelApply))
	{
		SetVariantInt(RUINA_ICBM);
		AcceptEntityInput(ModelApply, "SetBodyGroup");
	}

	if(victim == -1)
		return projectile;


	float 	Homing_Power = 5.0,
			Homing_Lockon = 45.0;

	Initiate_HomingProjectile(projectile,
	client,
	Homing_Lockon,			// float lockonAngleMax,
	Homing_Power,			// float homingaSec,
	true,					// bool LockOnlyOnce,
	true,					// bool changeAngles,
	Angles,
	victim);

	CreateTimer(1.5, KillProjectileHoming, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);

	return projectile;
}
static int FireBarrageProjectile_ALT(int client, int weapon, float damage, float time, float speed, float Angles[3])
{
	float radius = 250.0;

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, "raygun_projectile_red_crit", Angles);
	WandProjectile_ApplyFunctionToEntity(projectile, Projectile_Touch);

	if(!IsValidEntity(projectile))
		return -1;

	fl_ruina_Projectile_bonus_dmg[projectile] = 0.0;
	fl_ruina_Projectile_radius[projectile] = radius;

	int ModelApply = ApplyCustomModelToWandProjectile(projectile, RUINA_CUSTOM_MODELS_1, 1.0, "icbm_idle");
	if(IsValidEntity(ModelApply))
	{
		SetVariantInt(RUINA_ICBM);
		AcceptEntityInput(ModelApply, "SetBodyGroup");
	}
	return projectile;
}
static void Projectile_Touch(int entity, int target)
{
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	int particle = EntRefToEntIndex(i_WandParticle[entity]);

	//do nothing.
	if(target < 0)
		return;

	//we hit the world, fizzle out and do nothing.
	if(target == 0)
	{
		if(IsValidEntity(particle))
			RemoveEntity(particle);
		RemoveEntity(entity);
		return;
	}
	//now only valid targets are left.

	EmitSoundToAll(REIUJI_WAND_TOUCH_SOUND, entity, SNDCHAN_STATIC, 70, _, 0.9);

	fl_barrage_charge[owner]+=fl_ruina_Projectile_bonus_dmg[entity];

	//Code to do damage position and ragdolls
	float angles[3];
	GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
	float vecForward[3];
	GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
	float Entity_Position[3];
	WorldSpaceCenter(target, Entity_Position);

	if(fl_ruina_Projectile_radius[entity] > 0.0)
	{
		i_ammo[owner]+=2;	//barrage gives a bit of ammo back

		i_ExplosiveProjectileHexArray[owner] = EP_DEALS_PLASMA_DAMAGE;
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(owner);
		Explode_Logic_Custom(f_WandDamage[entity], owner, owner, -1, Entity_Position, fl_ruina_Projectile_radius[entity]);
		FinishLagCompensation_Base_boss();
	}
	else
	{
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?
	}
	

	if(IsValidEntity(particle))
		RemoveEntity(particle);

	RemoveEntity(entity);
}
