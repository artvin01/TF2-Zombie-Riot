#pragma semicolon 1
#pragma newdecls required


#define QUINCY_BOW_HYPER_BARRAGE_DRAIN 10.0		//how much charge is drained per shot
#define QUINCY_BOW_HYPER_BARRAGE_MINIMUM 50.0	//what % of charge does the battery need to start firing
#define QUINCY_BOW_MAX_HYPER_BARRAGE 6			//how many maximum individual timers/origin points are shot, kinda like how many of them can be fired a second, this is the max amt
#define QUINCY_BOW_MULTI_SHOT_MINIMUM	50.0	//yada yada

#define QUINCY_BOW_ARROW_TOUCH_SOUND "friends/friend_online.wav"

#define QUINCY_BOW_HYPER_CHARGE	1500.0
#define QUINCY_BOW_ONHIT_GAIN	50.0
#define QUINCY_BOW_ONHIT_MULTI_ARROW 10.0
static float fl_hyper_arrow_charge[MAXPLAYERS];
static float fl_quincy_hyper_arrow_timeout[MAXPLAYERS];


#define QUINCY_ARROW_PARTICLE_LONGBOW 		""	//raygun_projectile_blue
#define QUINCY_ARROW_PARTICLE_BALISTA 		""
#define QUINCY_ARROW_PARTICLE_REPEATER 		""
#define QUINCY_ARROW_PARTICLE_PENETRATOR 	""

#define QUINCY_ARROW_TRAIL_LONGBOW 			BEAM_DIAMOND
#define QUINCY_ARROW_TRAIL_BALISTA 			BEAM_COMBINE_BLACK
#define QUINCY_ARROW_TRAIL_REPEATER 		BEAM_COMBINE_BLUE
#define QUINCY_ARROW_TRAIL_PENETRATOR 		BEAM_LIGHTNING_MODEL


static const char hyper_arrow_sounds[][] = {
	"ambient_mp3/halloween/thunder_01.mp3",
	"ambient_mp3/halloween/thunder_04.mp3",
	"ambient_mp3/halloween/thunder_06.mp3",
};

static const char Spark_Sound[][] = {
	"ambient/energy/spark1.wav",
	"ambient/energy/spark2.wav",
	"ambient/energy/spark3.wav",
	"ambient/energy/spark4.wav",
	"ambient/energy/spark5.wav",
	"ambient/energy/spark6.wav",
};
public void OnStore_QuincyBow1_Initialised(ItemInfo Store_Item)
{
	Store_Item.Weapon_Bodygroup 		= RUINA_QUINCY_BOW_1_VIEWMODEL;
	Store_Item.WeaponModelOverride 		= RUINA_CUSTOM_MODELS_4;
	Store_Item.WeaponModelIndexOverride = PrecacheModel(Store_Item.WeaponModelOverride);
}
public void OnStore_QuincyBow2_Initialised(ItemInfo Store_Item)
{
	Store_Item.Weapon_Bodygroup 		= RUINA_QUINCY_BOW_2_VIEWMODEL;
	Store_Item.WeaponModelOverride 		= RUINA_CUSTOM_MODELS_4;
	Store_Item.WeaponModelIndexOverride = PrecacheModel(Store_Item.WeaponModelOverride);
}
public void OnStore_QuincyBow3_Initialised(ItemInfo Store_Item)
{
	Store_Item.Weapon_Bodygroup 		= RUINA_QUINCY_BOW_3_VIEWMODEL;
	Store_Item.WeaponModelOverride 		= RUINA_CUSTOM_MODELS_4;
	Store_Item.WeaponModelIndexOverride = PrecacheModel(Store_Item.WeaponModelOverride);
}
static bool bIsQuincy(int weapon)
{
	return i_CustomWeaponEquipLogic[weapon] == WEAPON_QUINCY_BOW || i_CustomWeaponEquipLogic[weapon] == WEAPON_QUINCY_CROSSBOW;
}
static float fl_Quincy_Barrage_Firerate[MAXPLAYERS + 1][QUINCY_BOW_MAX_HYPER_BARRAGE+1];

static int g_particleImpactTornado;
static float fQuincyManaConsumedForCharge[MAXPLAYERS];
void QuincyMapStart()
{
	PrecacheSound(QUINCY_BOW_ARROW_TOUCH_SOUND);

	Zero(fQuincyManaConsumedForCharge);

	Zero(fl_hyper_arrow_charge);

	PrecacheSoundArray(Spark_Sound);
	PrecacheSoundArray(hyper_arrow_sounds);
	
	Zero(fl_quincy_hyper_arrow_timeout);
	Zero2(fl_Quincy_Barrage_Firerate);
	
	g_particleImpactTornado = PrecacheParticleSystem("lowV_debrischunks");
}
enum struct QuincyChargeEnum {
	int weapon_ref;
	int client_ref;

	float throttle;
	float last_known_timer;

	bool cannon;
	float mana_cost;
	float timer_base;
	void SetManaCost(int weapon)	//bug: taunting while charging and holding m1 breaks it, it doesn't wipe mana used up.
	{
		this.mana_cost = Attributes_Get(weapon, 733, 1.0) / (this.timer_base*66.0);
	}
}
public void Quincy_ChargeLoopOnEquip(int client, int weapon)
{
	int buttons = GetClientButtons(client);
	if(buttons & IN_ATTACK)
		Quincy_HookChargeLogic(client, weapon);
}
public void Quincy_HookChargeLogic(int client, int weapon)
{
	float timer_max, current, ratio;
	QuincyGetBowStats(weapon, timer_max, current, ratio);

	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(Current_Mana[client] < mana_cost * 0.1)
	{
		//m_bNoFire
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", RoundFloat(mana_cost * 0.1));

		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		SetEntProp(weapon, Prop_Send, "m_bNoFire", 1);
		return;
	}
	SDKhooks_SetManaRegenDelayTime(client, 1.0);
	SetEntProp(weapon, Prop_Send, "m_bNoFire", 0);

	QuincyChargeEnum Data;
	Data.cannon = false;
	Data.weapon_ref = EntIndexToEntRef(weapon);
	Data.client_ref = EntIndexToEntRef(client);
	Data.throttle	= 0.0;
	Data.timer_base = timer_max;
	Data.SetManaCost(weapon);
	Data.last_known_timer = 0.0;
	

	DataPack pack = new DataPack();
	pack.WriteCellArray(Data, sizeof(Data));
	RequestFrame(ChargeHook_Tick, pack);
}
static void PlayChargeSoundPassive(int client, int soundlevel = 80, float volume = 1.0, int pitch = 100) { EmitSoundToAll(Spark_Sound[GetRandomInt(0, sizeof(Spark_Sound) - 1)], client, SNDCHAN_STATIC, soundlevel, _, volume, pitch);}
static void ChargeHook_Tick(DataPack pack)
{
	pack.Reset();
	static QuincyChargeEnum Data; 
	pack.ReadCellArray(Data, sizeof(Data));
	delete pack;

	int client = EntRefToEntIndex(Data.client_ref);
	int weapon = EntRefToEntIndex(Data.weapon_ref);

	if(!IsValidEntity(weapon) || !IsValidClient(client))
	{
		return;
	}

	int buttons = GetClientButtons(client);
	int held_weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	if(buttons & IN_ATTACK2)
	{
		//We are retracting the bow.
		Current_Mana_DispalyOffeset[client] = 0;
		return;
	}

	//we want to fire. or somehow are nolonger holding our weapon.
	if(held_weapon != weapon || (!Data.cannon && GetEntProp(weapon, Prop_Send, "m_bNoFire")))
	{
		Current_Mana_DispalyOffeset[client] = 0;
		return;	//ATTACK!
	}

	float GameTime = GetGameTime();
	if(!(buttons & IN_ATTACK))
	{
		Current_Mana_DispalyOffeset[client] = 0;
		return;
	}
	if(GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack") > GameTime)
	{
		DataPack Pack = new DataPack();
		Pack.WriteCellArray(Data, sizeof(Data));
		RequestFrame(ChargeHook_Tick, Pack);
		return;
	}
	

	if(Data.last_known_timer <= Data.timer_base)
	{
		if(Current_Mana[client] <= RoundToCeil(fQuincyManaConsumedForCharge[client]))
		{
			if(Data.cannon)
				SetEntPropFloat(weapon, Prop_Send, "m_flDetonateTime", GameTime + Data.last_known_timer);	//lock the sniper charge bar in place.
			else 
				SetEntPropFloat(weapon, Prop_Send, "m_flChargeBeginTime", GameTime - Data.last_known_timer);	//lock the sniper charge bar in place.
		}
		else
		{
			fQuincyManaConsumedForCharge[client]+=Data.mana_cost;
			Current_Mana_DispalyOffeset[client] = -RoundToFloor(fQuincyManaConsumedForCharge[client]);
			if(Data.cannon)
				Data.last_known_timer = GameTime - GetEntPropFloat(weapon, Prop_Send, "m_flDetonateTime");
			else
				Data.last_known_timer = GameTime - GetEntPropFloat(weapon, Prop_Send, "m_flChargeBeginTime");
		}
	}
	
	if(Data.throttle > GameTime)
	{
		DataPack Pack = new DataPack();
		Pack.WriteCellArray(Data, sizeof(Data));
		RequestFrame(ChargeHook_Tick, Pack);
		return;
	}

	Data.throttle = GameTime + 0.1;

	float timer_max, ratio, current;
	QuincyGetBowStats(weapon, timer_max, current, ratio, Data.cannon);
	Data.timer_base = timer_max;
	Data.SetManaCost(weapon);	//update mana cost every 0.1s if we happened to get new data.
	SDKhooks_SetManaRegenDelayTime(client, 1.0);
	Mana_Hud_Delay[client] = 0.0;

	int pitch = RoundToFloor(25.0 + (60.0 - 25.0) * (1.0-ratio));
	if(pitch > TF2_MAX_PITCH)
		pitch = TF2_MAX_PITCH;
	if(pitch < 5)
		pitch = 5;

	PlayChargeSoundPassive(client, 80, 0.5, pitch);

	DataPack Pack = new DataPack();
	Pack.WriteCellArray(Data, sizeof(Data));
	RequestFrame(ChargeHook_Tick, Pack);
}
static void QuincyGetBowStats(int weapon, float &charge_max, float &charge_current, float &charge_ratio, bool cannon = false)
{
	if(cannon)
	{
		charge_current = GetEntPropFloat(weapon, Prop_Send, "m_flDetonateTime") - GetGameTime();
	}
	else
	{
		charge_current = GetGameTime() - GetEntPropFloat(weapon, Prop_Send, "m_flChargeBeginTime");
	}
	
 	charge_max = 1.0;	//https://github.com/ValveSoftware/source-sdk-2013/blob/22288b919617be6c8ca3cefd7cca979cbb39a88c/src/game/shared/tf/tf_weapon_compound_bow.cpp#L272

	charge_max *= Attributes_Get(weapon, 6, 1.0);
	charge_max *= Attributes_Get(weapon, 5, 1.0);
	charge_max *= Attributes_Get(weapon, 318, 1.0);
	
	if(cannon)
	{
		charge_max *= Attributes_Get(weapon, 466, 1.0);
	}

	if(charge_current > charge_max)
		charge_current = charge_max;

	if(cannon)
		charge_ratio = 1.0 - (charge_current / charge_max);
	else
		charge_ratio = (charge_current / charge_max);
}
public void Quincy_Generic_M1(int client, int weapon, bool crit, int slot)
{
	float timer_max, ratio, current;
	QuincyGetBowStats(weapon, timer_max, current, ratio);

	Current_Mana_DispalyOffeset[client] = 0;
	Current_Mana[client] -= RoundToFloor(fQuincyManaConsumedForCharge[client]);
	fQuincyManaConsumedForCharge[client] = 0.0;
	
	float damage = 100.0;
	damage *= Attributes_Get(weapon, 410, 1.0);

	float minmulti, maxmulti;
	maxmulti = Attributes_Get(weapon, Attrib_Weapon_MaxDmgMulti, 1.0);
	minmulti = Attributes_Get(weapon, Attrib_Weapon_MinDmgMulti, 1.0);

	float multi = (minmulti + (maxmulti - minmulti) * ratio);
	damage *=multi;

	float speed = 2500.0;
	float time = 2.5;

	speed *= Attributes_Get(weapon, 103, 1.0);
	speed *= Attributes_Get(weapon, 104, 1.0);
	speed *= Attributes_Get(weapon, 475, 1.0);

	time *= Attributes_Get(weapon, 101, 1.0);
	time *= Attributes_Get(weapon, 102, 1.0);

	float SpawnLoc[3];	GetClientEyePosition(client, SpawnLoc);
	float Angles[3]; 	GetClientEyeAngles(client, Angles);

	Offset_Vector({0.0, -8.0, -10.0}, Angles, SpawnLoc);
	Angles = AdjustAngleAimForOffset(client, SpawnLoc);

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, QUINCY_ARROW_PARTICLE_LONGBOW,
		.CustomAng = Angles,
		.CustomPos = SpawnLoc
	);
	if(!IsValidEntity(projectile))
		return;

	ApplyQuincyArrowTrail(projectile, Angles, QUINCY_ARROW_TRAIL_LONGBOW,
	.start = 5.0,
	.duration = 0.25,
	.alpha = 150
	);
	WandProjectile_ApplyFunctionToEntity(projectile, Quincy_Touch);
	ApplyQuincyArrowModel(projectile, 1);

	//use
	//Attrib_Weapon_MaxDmgMulti = 4047, 
	//Attrib_Weapon_MinDmgMulti = 4048, 

	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteFloat(1.0);	//wanted
	pack.WriteFloat(1.0);	//base
	RequestFrames(RF_OffsetNextAttack, 3, pack);
}

///BALISTA
public void OnStore_QuincyBallista1_Initialised(ItemInfo Store_Item)
{
	Store_Item.Weapon_Bodygroup 		= RUINA_QUINCY_BALISTA_HANDLE|RUINA_QUINCY_BALISTA_HEAD_1;	//tmp
	Store_Item.WeaponModelOverride 		= RUINA_CUSTOM_MODELS_4;
	Store_Item.WeaponModelIndexOverride = PrecacheModel(Store_Item.WeaponModelOverride);
}
public void Quincy_Balista_M1(int client, int weapon, bool crit, int slot)
{
	int iAmmoTable  = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
	int current 	= GetEntData(weapon, iAmmoTable, 4);
	SetEntData(weapon, iAmmoTable, 1, 4, true);

	float speed = 2000.0;
	float damage= 100.0;
	float time 	= 1.5;
	damage *= Attributes_Get(weapon, 410, 1.0);

	speed *= Attributes_Get(weapon, 103, 1.0);
	speed *= Attributes_Get(weapon, 104, 1.0);
	speed *= Attributes_Get(weapon, 475, 1.0);

	time *= Attributes_Get(weapon, 101, 1.0);
	time *= Attributes_Get(weapon, 102, 1.0);

	float distoffset = 100.0;
	float sideways_dist = 150.0;

	float Angles[3]; GetClientEyeAngles(client, Angles);
	float Origin[3]; GetClientEyePosition(client, Origin); Origin[2]-=20.0;

	Player_Laser_Logic Laser;
	Laser.client = client;
	Laser.DoForwardTrace_Basic(_, Player_Laser_BEAM_TraceWallsAndEnemiesOnly);

	float dist_add = (current > 1) ? (sideways_dist / float(current - 1)) : 0.0;
	for(int i = 0; i < current; i++)
	{
		float vecForward[3], vecRight[3];
		float spawnLoc[3];
		
		float SidewaysOffset = (current > 1) ? ((-0.5 * sideways_dist) + (dist_add * i)) : 0.0;
		float ExtraCalc = (current > 1) ? (float(i) / float(current - 1)) : 0.5;
		float ForwardSet = distoffset * Sine(FLOAT_PI * ExtraCalc);

		GetAngleVectors(Angles, vecForward, vecRight, NULL_VECTOR);
		ScaleVector(vecForward, ForwardSet);
		ScaleVector(vecRight, SidewaysOffset);
		
		AddVectors(Origin, vecForward, spawnLoc);
		AddVectors(spawnLoc, vecRight, spawnLoc);

		float SpawnAngles[3];
		MakeVectorFromPoints(spawnLoc, Laser.End_Point, SpawnAngles);
		GetVectorAngles(SpawnAngles, SpawnAngles);

		int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, QUINCY_ARROW_PARTICLE_BALISTA,
		.CustomAng = SpawnAngles,
		.CustomPos = spawnLoc
		);

		if(IsValidEntity(projectile))
		{
			ApplyQuincyArrowModel(projectile, 3);
			WandProjectile_ApplyFunctionToEntity(projectile, Quincy_Touch);  
			ApplyQuincyArrowTrail(projectile, Angles, QUINCY_ARROW_TRAIL_BALISTA,
			.start = 10.0,
			.duration = 2.5,
			.alpha = 150
			);
		}
	}
}
public void Quincy_Balista_M2(int client, int weapon, bool crit, int slot)
{
	if(GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack") > GetGameTime())
		return;

	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

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
	//868
	int iAmmoTable  = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
	int max_ammo 	= RoundFloat(Attributes_Get(weapon, 868, 1.0) * Attributes_Get(weapon, 4, 1.0));
	int current 	= GetEntData(weapon, iAmmoTable, 4);

	if(current >= max_ammo)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Clip Is Full");
		return;
	}

	float base_cd = 1.0;
	base_cd *= Attributes_Get(weapon, 6, 1.0);	//scale on attack rate rathen then reload rate for reloading
	base_cd *= Attributes_Get(weapon, 5, 1.0);

	//base_cd *= CooldownReductionAmount(client);

	Current_Mana[client] -=mana_cost;
	SDKhooks_SetManaRegenDelayTime(client, base_cd*2.0);
	Mana_Hud_Delay[client] = 0.0;
	Ability_Apply_Cooldown(client, slot, base_cd, _, true);

	SetEntData(weapon, iAmmoTable, current+1, 4, true);

	int viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	if(viewmodel>MaxClients && IsValidEntity(viewmodel))
	{
		int animation = 10;
		int was = 8;	//GetEntProp(viewmodel, Prop_Send, "m_nSequence");
		//CPrintToChatAll("was: %i",was);
		SetEntProp(viewmodel, Prop_Send, "m_nSequence", animation);

		DataPack pack = new DataPack();
		pack.WriteCell(EntIndexToEntRef(weapon));
		pack.WriteCell(EntIndexToEntRef(client));
		pack.WriteFloat(base_cd*0.8);
		pack.WriteFloat(0.8);
		RequestFrames(RF_OffsetNextAttack, 3, pack);

		pack = new DataPack();
		pack.WriteCell(EntIndexToEntRef(viewmodel));
		pack.WriteCell(was);
		RequestFrames(RF_SetSequence, RoundFloat(base_cd * 60), pack);
	}
}

////REPEATER
public void OnStore_QuincyRepeater1_Initialised(ItemInfo Store_Item)
{
	Store_Item.Weapon_Bodygroup 		= RUINA_QUINCY_BOW_REPEATER_1_VIEWMODEL;	
	Store_Item.WeaponModelOverride 		= RUINA_CUSTOM_MODELS_4;
	Store_Item.WeaponModelIndexOverride = PrecacheModel(Store_Item.WeaponModelOverride);
}
public void Quincy_Repeater_M1(int client, int weapon, bool crit, int slot)
{
	float timer_max, ratio, current;
	QuincyGetBowStats(weapon, timer_max, current, ratio);
	Current_Mana_DispalyOffeset[client] = 0;
	Current_Mana[client] -= RoundToFloor(fQuincyManaConsumedForCharge[client]);
	fQuincyManaConsumedForCharge[client] = 0.0;
	if(ratio < 0.2)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Your Weapon is not charged enough None");	
		return;
	}
	SDKhooks_SetManaRegenDelayTime(client, 2.0);

	float speed = 2000.0;
	float damage= 100.0;
	float time 	= 1.5;
	damage *= Attributes_Get(weapon, 410, 1.0);

	float minmulti, maxmulti;
	maxmulti = Attributes_Get(weapon, Attrib_Weapon_MaxDmgMulti, 1.0);
	minmulti = Attributes_Get(weapon, Attrib_Weapon_MinDmgMulti, 1.0);

	float multi = (minmulti + (maxmulti - minmulti) * ratio);
	damage *=multi;

	speed *= Attributes_Get(weapon, 103, 1.0);
	speed *= Attributes_Get(weapon, 104, 1.0);
	speed *= Attributes_Get(weapon, 475, 1.0);

	time *= Attributes_Get(weapon, 101, 1.0);
	time *= Attributes_Get(weapon, 102, 1.0);

	float SpawnLoc[3];	GetClientEyePosition(client, SpawnLoc);
	float Angles[3]; 	GetClientEyeAngles(client, Angles);

	Offset_Vector({0.0, -8.0, -10.0}, Angles, SpawnLoc);
	Angles = AdjustAngleAimForOffset(client, SpawnLoc);

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, QUINCY_ARROW_PARTICLE_REPEATER,
		.CustomAng = Angles,
		.CustomPos = SpawnLoc
	);

	if(IsValidEntity(projectile))
	{
		ApplyQuincyArrowModel(projectile, 1);
		WandProjectile_ApplyFunctionToEntity(projectile, Quincy_Touch);
		ApplyQuincyArrowTrail(projectile, Angles, QUINCY_ARROW_TRAIL_REPEATER);
	}

	float delay = Attributes_Get(weapon, 122, 0.1);
	int amt = RoundFloat(Attributes_Get(weapon, 868, 3.0));
	float penalty = Attributes_Get(weapon, Attrib_WeaponDedicated_1, 1.0);
	for(int i=1 ; i < amt ; i++)
	{
		DataPack pack = new DataPack();
		pack.WriteCell(EntIndexToEntRef(client));
		pack.WriteCell(EntIndexToEntRef(weapon));
		pack.WriteFloat(speed);
		pack.WriteFloat(time);
		pack.WriteFloat(damage * (float(i) * penalty));
		RequestFrames(RF_ShootExtraQuincyArrow, RoundToCeil(66.0 * (delay * i)), pack);
	}

	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteFloat(1.0);	//wanted
	pack.WriteFloat(1.0);	//base
	RequestFrames(RF_OffsetNextAttack, 3, pack);
}
static void RF_ShootExtraQuincyArrow(DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	float speed	= pack.ReadFloat();
	float time	= pack.ReadFloat();
	float damage= pack.ReadFloat();
	delete pack;

	if(!IsValidClient(client) || !IsValidEntity(weapon))
		return;

	float SpawnLoc[3];	GetClientEyePosition(client, SpawnLoc);
	float Angles[3]; 	GetClientEyeAngles(client, Angles);

	Offset_Vector({0.0, -8.0, -10.0}, Angles, SpawnLoc);
	Angles = AdjustAngleAimForOffset(client, SpawnLoc);

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, QUINCY_ARROW_PARTICLE_REPEATER,
		.CustomAng = Angles,
		.CustomPos = SpawnLoc
	);
	if(IsValidEntity(projectile))
	{
		ApplyQuincyArrowModel(projectile, 1);
		ApplyQuincyArrowTrail(projectile, Angles, QUINCY_ARROW_TRAIL_REPEATER);
		WandProjectile_ApplyFunctionToEntity(projectile, Quincy_Touch);
		
	}
}

///PENETRATOR 
public void OnStore_QuincyPenetrator1_Initialised(ItemInfo Store_Item)
{
	Store_Item.Weapon_Bodygroup 		= RUINA_QUINCY_BOW_REPEATER_1_VIEWMODEL;	
	Store_Item.WeaponModelOverride 		= RUINA_CUSTOM_MODELS_4;
	Store_Item.WeaponModelIndexOverride = PrecacheModel(Store_Item.WeaponModelOverride);
}
public void Quincy_Penetrator_M1(int client, int weapon, bool crit, int slot)
{
	float timer_max, ratio, current;
	QuincyGetBowStats(weapon, timer_max, current, ratio);
	Current_Mana_DispalyOffeset[client] = 0;
	Current_Mana[client] -= RoundToFloor(fQuincyManaConsumedForCharge[client]);
	fQuincyManaConsumedForCharge[client] = 0.0;
	if(ratio < 0.2)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Your Weapon is not charged enough None");	
		return;
	}
	SDKhooks_SetManaRegenDelayTime(client, 2.0);

	float speed = 2000.0;
	float damage= 100.0;
	float time 	= 1.5;
	damage *= Attributes_Get(weapon, 410, 1.0);

	float minmulti, maxmulti;
	maxmulti = Attributes_Get(weapon, Attrib_Weapon_MaxDmgMulti, 1.0);
	minmulti = Attributes_Get(weapon, Attrib_Weapon_MinDmgMulti, 1.0);

	float multi = (minmulti + (maxmulti - minmulti) * ratio);
	damage *=multi;

	speed *= Attributes_Get(weapon, 103, 1.0);
	speed *= Attributes_Get(weapon, 104, 1.0);
	speed *= Attributes_Get(weapon, 475, 1.0);

	time *= Attributes_Get(weapon, 101, 1.0);
	time *= Attributes_Get(weapon, 102, 1.0);

	float SpawnLoc[3];	GetClientEyePosition(client, SpawnLoc);
	float Angles[3]; 	GetClientEyeAngles(client, Angles);

	Offset_Vector({0.0, -8.0, -10.0}, Angles, SpawnLoc);
	Angles = AdjustAngleAimForOffset(client, SpawnLoc);

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, QUINCY_ARROW_PARTICLE_PENETRATOR,
		.CustomAng = Angles,
		.CustomPos = SpawnLoc
	);

	if(IsValidEntity(projectile))
	{
		ApplyQuincyArrowModel(projectile, 2);
		WandProjectile_ApplyFunctionToEntity(projectile, Quincy_Touch_Penetrator);
		ApplyQuincyArrowTrail(projectile, Angles, QUINCY_ARROW_TRAIL_PENETRATOR,
		.start = 10.0,
		.duration = 1.0,
		.alpha = 150
		);
	}

	float pen_multi = Attributes_Get(weapon, 122, 0.1);
	int penetration = RoundFloat(Attributes_Get(weapon, 868, 3.0));

	i_AmountProjectiles[projectile] = 0;
	i_NemesisEntitiesHitAoeSwing[projectile] = penetration;
	fl_BEAM_ThrottleTime[projectile][0] = pen_multi;

	

	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteFloat(1.0);	//wanted
	pack.WriteFloat(1.0);	//base
	RequestFrames(RF_OffsetNextAttack, 3, pack);
}
static void Quincy_Touch_Penetrator(int entity, int target)
{
	if(target < 0)
		return;

	if(target == 0)
	{
		float pos1[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		TE_ParticleInt(g_particleImpactTornado, pos1);
		TE_SendToAll();

		TE_Particle("mvm_soldier_shockwave", pos1, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);

		RemoveEntity(entity);
		return;
	}

	if(IsIn_HitDetectionCooldown(entity,target))
		return;
	
	Set_HitDetectionCooldown(entity, target, GetGameTime() + 0.25);

	

	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	static float angles[3], vecForward[3], targetVec[3];
	GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
	GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
	WorldSpaceCenter(target, targetVec);
	float damageForce[3]; CalculateDamageForce(vecForward, 10000.0, damageForce);

	float dmg_multi = 1.0;
	for(int i=0 ; i < i_AmountProjectiles[entity] ; i++)	//ass.
	{
		dmg_multi *= fl_BEAM_ThrottleTime[entity][0];
	}
	i_AmountProjectiles[entity]++;
	float damage = f_WandDamage[entity] * dmg_multi;

	//float damage = f_WandDamage[entity] * (fl_BEAM_ThrottleTime[entity][0] ^ view_as<float>(i_AmountProjectiles[entity]));

	SDKHooks_TakeDamage(target, owner, owner, damage, DMG_PLASMA, weapon, damageForce, targetVec);

	EmitSoundToAll(QUINCY_BOW_ARROW_TOUCH_SOUND, entity, SNDCHAN_STATIC, 70, _, 0.9);

	if(i_AmountProjectiles[entity] >= i_NemesisEntitiesHitAoeSwing[entity])
	{
		float pos1[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		TE_ParticleInt(g_particleImpactTornado, pos1);
		TE_SendToAll();

		TE_Particle("mvm_soldier_shockwave", pos1, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);

		RemoveEntity(entity);
	}
}

/// UTILS:
static void ApplyQuincyArrowModel(int projectile, int skin)
{
	int ModelApply = ApplyCustomModelToWandProjectile(projectile, RUINA_CUSTOM_MODELS_4, 2.0, "icbm_idle");
	if(IsValidEntity(ModelApply))
	{
		SetVariantInt(RUINA_QUINCY_ARROW);
		AcceptEntityInput(ModelApply, "SetBodyGroup");
		SetEntProp(ModelApply, Prop_Send, "m_nSkin", skin);
	}
}
static void ApplyQuincyArrowTrail(int projectile, float Angles[3], char[] trail, float start = 20.0, float end = 0.0, float duration = 1.0, int alpha = 255)
{
	if(!trail[0])
		return;

	int particle = Trail_Attach(projectile, trail, alpha, duration, start, end, 4);
	SDKCall_SetAbsAngle(particle, Angles);
	SetParent(projectile, particle);	
	SetEntityCollisionGroup(particle, 27);
	i_WandParticle[projectile] = EntIndexToEntRef(particle);
}
static void Quincy_Touch(int entity, int target)
{
	if(target < 0)
		return;

	if(target == 0)
	{
		EmitSoundToAll(QUINCY_BOW_ARROW_TOUCH_SOUND, entity, SNDCHAN_STATIC, 70, _, 0.9);
		float pos1[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		TE_ParticleInt(g_particleImpactTornado, pos1);
		TE_SendToAll();
		//TE_Particle("mvm_soldier_shockwave", pos1, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		RemoveEntity(entity);
		return;
	}

	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	static float angles[3], vecForward[3], targetVec[3];
	GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
	GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
	WorldSpaceCenter(target, targetVec);
	float damageForce[3]; CalculateDamageForce(vecForward, 10000.0, damageForce);

	SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, damageForce, targetVec);

	EmitSoundToAll(QUINCY_BOW_ARROW_TOUCH_SOUND, entity, SNDCHAN_STATIC, 70, _, 0.9);
	float pos1[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
	TE_ParticleInt(g_particleImpactTornado, pos1);
	TE_SendToAll();
	//TE_Particle("mvm_soldier_shockwave", pos1, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	RemoveEntity(entity);
}
float[] AdjustAngleAimForOffset(int client, float Start_Point[3], float range = -1.0, float End_Point[3] = {0.0, 0.0, 0.0})
{
	Player_Laser_Logic Laser;
	Laser.client = client;
	Laser.DoForwardTrace_Basic(range, Player_Laser_BEAM_TraceWallsAndEnemiesOnly);
	float SpawnAngles[3];
	End_Point = Laser.End_Point;
	MakeVectorFromPoints(Start_Point, Laser.End_Point, SpawnAngles);
	GetVectorAngles(SpawnAngles, SpawnAngles);
	return SpawnAngles;
}
static void RF_OffsetNextAttack(DataPack pack)
{
	pack.Reset();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell());
	float when = pack.ReadFloat();
	float base = pack.ReadFloat();
	delete pack;

	if(!IsValidClient(client))
		return;

	if(!IsValidEntity(weapon))
		return;

	float Ratio = (base / when);
	
	Ratio *=2.0;
	if(Ratio > 12.0)
		Ratio = 12.0;

	int viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	if(viewmodel>MaxClients && IsValidEntity(viewmodel))
	{
		DispatchKeyValueFloat(viewmodel, "playbackrate", Ratio);
	}

	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + when);
	DispatchKeyValueFloat(weapon, "playbackrate", Ratio);
}
static void RF_SetSequence(DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int seq = pack.ReadCell();
	delete pack;
	if(!IsValidEntity(entity))
		return;

	DispatchKeyValueFloat(entity, "playbackrate", 1.0);
	SetEntProp(entity, Prop_Send, "m_nSequence", seq);
}