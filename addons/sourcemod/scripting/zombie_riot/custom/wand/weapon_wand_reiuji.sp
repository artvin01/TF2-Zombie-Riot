#pragma semicolon 1
#pragma newdecls required

static Handle h_Reiuji_WeaponHudTimer[MAXTF2PLAYERS] = {null, ...};
static float fl_hud_timer[MAXTF2PLAYERS];
static float fl_ammo_timer[MAXTF2PLAYERS];
static int i_ammo[MAXTF2PLAYERS];
static int i_max_ammo = 15;
static float fl_ammogain_timerbase = 1.0;

static int i_max_barage = 7;
static float fl_barrage_angles = 60.0;
static float fl_barrage_maxrange = 2500.0;

//charge gained will depend on mana consumed.
static float fl_barrage_charge[MAXTF2PLAYERS];
static float fl_barrage_maxcharge = 300.0;

#define REIUJI_WAND_TOUCH_SOUND "friends/friend_online.wav"
void Reiuji_Wand_OnMapStart()
{
	Zero(i_ammo);
	Zero(fl_hud_timer);
	PrecacheSound(REIUJI_WAND_TOUCH_SOUND, true);
}

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
static int i_pap(int weapon) {return RoundFloat(Attributes_Get(weapon, 122, 0.0));}

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
	float GameTime = GetGameTime();
	if(fl_ammo_timer[client] < GameTime)
	{
		fl_ammo_timer[client] = GameTime + fl_ammogain_timerbase;

		if(i_ammo[client] < i_max_ammo)
			i_ammo[client]++;
	}

	Hud(client);

	return Plugin_Continue;
}
static void Hud(int client)
{
	float GameTime = GetGameTime();
	if(fl_hud_timer[client] > GameTime)
		return;
	
	//faster then 0.5 and it starts to glitch out.
	fl_hud_timer[client] = GameTime + 0.5;

	char HUDText[255] = "";

	if(i_ammo[client] < i_max_ammo)
		Format(HUDText, sizeof(HUDText), "Ammo: [%i/%i] (%.1fs)", i_ammo[client], i_max_ammo, fl_ammo_timer[client]-GameTime);
	else
		Format(HUDText, sizeof(HUDText), "Ammo: [%i/%i]", i_ammo[client], i_max_ammo);

	Format(HUDText, sizeof(HUDText), "%s\nBarrage: [%.0f％]", HUDText, (fl_barrage_charge[client]/fl_barrage_maxcharge*100.0));

	PrintHintText(client, HUDText);
}
public void Reiuji_Wand_Barrage_Attack(int client, int weapon, bool crit, int slot)
{
	if(fl_barrage_charge[client] < fl_barrage_maxcharge && !CvarInfiniteCash.BoolValue)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Your Weapon is not charged enough.");
		return;
	}

	int loop_for = i_max_barage;
	float tolerance_angle = fl_barrage_angles;
	float range = fl_barrage_maxrange;

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
		ShowSyncHudText(client,  SyncHud_Notifaction, "No Targets Detected");
		return;
	}
		

	float Origin[3];
	WorldSpaceCenter(client, Origin);
	
	float HandPos[3]; 
	GetAttachment(client, "effect_hand_r", HandPos, NULL_VECTOR);

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
		int laser = ConnectWithBeam(weapon, victim, color[0], color[1], color[2], 5.0, 2.5, 0.25, BEAM_COMBINE_BLUE);
		CreateTimer(0.2, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);

		i_OwnerEntityEnvLaser[laser] = EntIndexToEntRef(client);
		SDKHook(laser, SDKHook_SetTransmit, SetTransmitHarvester);
	}

	fl_barrage_charge[client] -= fl_barrage_maxcharge * (float(targets_aquired)/float(loop_for));

	if(fl_barrage_charge[client] < 0.0)
	{
		CPrintToChatAll("barrage went beyond 0.0, correcting: %.3f", fl_barrage_charge[client]);
		fl_barrage_charge[client] = 0.0;
	}

	
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
	Current_Mana[client] -= mana_cost;
	SDKhooks_SetManaRegenDelayTime(client, 1.0);
	Mana_Hud_Delay[client] = 0.0;
	delay_hud[client] = 0.0;

	fl_barrage_charge[client]+=mana_cost;

	if(fl_barrage_charge[client] > fl_barrage_maxcharge)
		fl_barrage_charge[client] = fl_barrage_maxcharge;
	
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
	if(i_ammo[client] > 0)
	{
		i_ammo[client]--;

		if(i_ammo[client] > 0)
			Attributes_Set(weapon, 5, 0.25);
		else
			Attributes_Set(weapon, 5, 1.0);
	}

	//rest the ammo gain timer when firing.
	fl_ammo_timer[client] = GetGameTime() + fl_ammogain_timerbase;

	float damage = 100.0 * Attributes_Get(weapon, 410, 1.0);
		
	float speed = 1100.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	speed *= Attributes_Get(weapon, 104, 1.0);
	speed *= Attributes_Get(weapon, 475, 1.0);

	float time = 1000.0/speed;
	time *= Attributes_Get(weapon, 101, 1.0);
	time *= Attributes_Get(weapon, 102, 1.0);

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, "raygun_projectile_blue");

	if(!IsValidEntity(projectile))
		return;

	WandProjectile_ApplyFunctionToEntity(projectile, Projectile_Touch);

	fl_ruina_Projectile_radius[projectile] = 0.0;

	if(fl_barrage_charge[client] < fl_barrage_maxcharge*0.5)
		return;

	float 	Homing_Power = 5.0,
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
static void FireBarrageProjectile(int client, int weapon, float Angles[3], int victim)
{
	float damage = 200.0 * Attributes_Get(weapon, 410, 1.0);
	float radius = 250.0;
	float speed = 1100.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	speed *= Attributes_Get(weapon, 104, 1.0);
	speed *= Attributes_Get(weapon, 475, 1.0);

	float time = 1500.0/speed;
	time *= Attributes_Get(weapon, 101, 1.0);
	time *= Attributes_Get(weapon, 102, 1.0);

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, "raygun_projectile_blue_crit", Angles);
	WandProjectile_ApplyFunctionToEntity(projectile, Projectile_Touch);

	if(!IsValidEntity(projectile))
		return;

	fl_ruina_Projectile_radius[projectile] = radius;
	
	//so since the ICBM model isn't correctly orientated, I need to do this wonky trick
	int ModelApply = ApplyCustomModelToWandProjectile(projectile, RUINA_CUSTOM_MODELS_1, 2.0, "icbm_idle");
	if(IsValidEntity(ModelApply))
	{
		float angles[3];
		GetEntPropVector(ModelApply, Prop_Data, "m_angRotation", angles);
		angles[1]+=90.0;
		TeleportEntity(ModelApply, NULL_VECTOR, angles, NULL_VECTOR);
		SetVariantInt(RUINA_ICBM);
		AcceptEntityInput(ModelApply, "SetBodyGroup");
	}

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

	//Code to do damage position and ragdolls
	float angles[3];
	GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
	float vecForward[3];
	GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
	float Entity_Position[3];
	WorldSpaceCenter(target, Entity_Position);

	if(fl_ruina_Projectile_radius[entity] > 0.0)
	{
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
