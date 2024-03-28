#pragma semicolon 1
#pragma newdecls required

static Handle h_TimerKitBlitzkriegManagement[MAXPLAYERS+1] = {null, ...};
static float fl_hud_timer[MAXPLAYERS+1];
static float fl_primary_reloading[MAXPLAYERS+1];
static bool b_primary_lock[MAXPLAYERS+1];
static int i_ion_charge[MAXPLAYERS+1];
static int i_patten_type[MAXPLAYERS+1];
static float fl_ammo_efficiency[MAXPLAYERS+1];
static int i_ion_effects[MAXPLAYERS+1];
static float fl_ion_timer_recharge[MAXPLAYERS+1];

static bool b_was_lastman[MAXPLAYERS+1];

static int g_particleImpactTornado;

static char gExplosive1;
static char gLaser1;

#define BLITZKRIEG_KIT_MAX_ION_CHARGES 256
#define BLITZKREIG_KIT_ION_COST_CHARGE 128
#define BLITZKRIEG_KIT_RELOAD_COOLDOWN_REDUCTION 1.0

#define BLITZKRIEG_KIT_ION_CHARGE_TIME 3.5
#define BLITZKRIEG_KIT_ION_RADIUS 300.0
#define BLITZKRIEG_KIT_ION_COOLDOWN 30.0

#define BLITZKRIEG_KIT_ROCKET_MODEL "models/weapons/w_models/w_rocket_airstrike/w_rocket_airstrike.mdl"
#define BLITZKRIEG_KIT_SHOOT_SOUND1 "weapons/airstrike_fire_01.wav"
#define BLITZKRIEG_KIT_SHOOT_SOUND2 "weapons/airstrike_fire_03.wav"
#define BLITZKRIEG_KIT_SHOOT_SOUND3 "weapons/airstrike_fire_03.wav"

#define BLITZKRIEG_KIT_ION_PASIVE_SOUND "ambient/energy/weld1.wav" 
#define BLITZKRIEG_KIT_ION_EXPLOSION_SOUND "misc/doomsday_missile_explosion.wav"

public void Kit_Blitzkrieg_Precache()
{
	Zero(fl_primary_reloading);
	Zero(fl_hud_timer);
	Zero(i_ion_charge);
	Zero(fl_ammo_efficiency);
	Zero(fl_ion_timer_recharge);
	Zero(b_was_lastman);
	g_particleImpactTornado = PrecacheParticleSystem("lowV_debrischunks");
	PrecacheModel(BLITZKRIEG_KIT_ROCKET_MODEL);
	PrecacheSound(BLITZKRIEG_KIT_SHOOT_SOUND1);
	PrecacheSound(BLITZKRIEG_KIT_SHOOT_SOUND2);
	PrecacheSound(BLITZKRIEG_KIT_SHOOT_SOUND3);

	PrecacheSound(BLITZKRIEG_KIT_ION_PASIVE_SOUND);
	PrecacheSound(BLITZKRIEG_KIT_ION_EXPLOSION_SOUND);


	gLaser1 = PrecacheModel("materials/sprites/laser.vmt", true);
}

public void Enable_Blitzkrieg_Kit(int client, int weapon)
{
	if (h_TimerKitBlitzkriegManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon]==WEAPON_KIT_BLITZKRIEG_CORE)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerKitBlitzkriegManagement[client];
			h_TimerKitBlitzkriegManagement[client] = null;
			DataPack pack;
			h_TimerKitBlitzkriegManagement[client] = CreateDataTimer(0.1, Timer_Management_KitBlitzkrieg, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));

			if(fl_primary_reloading[client]>GetGameTime())
			{
				b_primary_lock[client]=true;
			}
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon]==WEAPON_KIT_BLITZKRIEG_CORE)
	{
		DataPack pack;
		h_TimerKitBlitzkriegManagement[client] = CreateDataTimer(0.1, Timer_Management_KitBlitzkrieg, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		if(fl_primary_reloading[client]>GetGameTime()+100.0)//somehow the timer we got is WAAAAY too high. reset it
		{
			fl_primary_reloading[client]=0.0;	
		}
		if(fl_primary_reloading[client]>GetGameTime())
		{
			b_primary_lock[client]=true;
		}
		i_patten_type[client]=0;
		b_was_lastman[client]=false;
	}
}

static int Pap(int weapon)
{
	return RoundFloat(Attributes_Get(weapon, 122, 0.0));
}


public Action Timer_Management_KitBlitzkrieg(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerKitBlitzkriegManagement[client] = null;
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");   //get current active weapon. we don't actually use the original weapon, its there as a way to tell if something went wrong

	if(!IsValidEntity(weapon_holding))  //held weapon is somehow invalid, keep on looping...
		return Plugin_Continue;

	float GameTime = GetGameTime();

	if(LastMann)	//if lastman triggers and we happen to be reloading, insta reload it!
	{
		if(!b_was_lastman[client])
		{
			b_was_lastman[client]=true;
			if(fl_primary_reloading[client]>GameTime)
			{
				fl_primary_reloading[client]=0.0;
			}
		}
	}
	else
	{
		if(b_was_lastman[client])
		{
			b_was_lastman[client]=false;
		}
	}

	switch(Pap(weapon_holding))
	{
		case 1: //primary 1
		{
			BlitzHud(client, GameTime, 1);

			if(b_primary_lock[client])
			{
				if(fl_primary_reloading[client]<=GameTime)
				{
					b_primary_lock[client]=false;
					Attributes_Set(weapon_holding, 821, 0.0);
				}
				else if(RoundFloat(Attributes_Get(weapon_holding, 821, 0.0))==0)
				{
					Attributes_Set(weapon_holding, 821, 1.0);
					b_primary_lock[client]=true;
				}
			}
			else
			{
				if(RoundFloat(Attributes_Get(weapon_holding, 821, 0.0))==1)
				{
					b_primary_lock[client]=true;
				}
			}
		}
		case 2: //secondary 1
		{
			BlitzHud(client, GameTime, 2);
		}
		case 3: //melee 1
		{
			BlitzHud(client, GameTime, 3);
		}
	}
		
	return Plugin_Continue;
}

static void BlitzHud(int client, float GameTime, int wep)
{
	if(fl_hud_timer[client]>GameTime)
		return;
	
	fl_hud_timer[client]=GameTime+0.5;

	char HUDText[255] = "";

	Format(HUDText, sizeof(HUDText), "%sIon Charge: [%i/%i]", HUDText, i_ion_charge[client], BLITZKRIEG_KIT_MAX_ION_CHARGES);
	
	if(wep==1)
	{
		switch(i_patten_type[client])
		{
			case 0:
			{
				Format(HUDText, sizeof(HUDText), "%s\nPattern: Alpha", HUDText);
			}
			case 1:
			{
				Format(HUDText, sizeof(HUDText), "%s\nPattern: Beta", HUDText);
			}
		}
	}

	if(fl_ion_timer_recharge[client]>GameTime)
	{
		float Duration = fl_ion_timer_recharge[client] - GameTime;
		Format(HUDText, sizeof(HUDText), "%s\nION Recharging... [%.1f]", HUDText, Duration);
	}
	
	
	if(fl_primary_reloading[client]>GameTime)
	{
		float Duration = fl_primary_reloading[client] - GameTime;
		Format(HUDText, sizeof(HUDText), "%s\nPrimary Reloading... [%.1f]", HUDText, Duration);
	}


	PrintHintText(client, HUDText);
	StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
}
public void Blitzkrieg_Kit_Primary_Reload(int client, int weapon, const char[] classname, bool &result)
{
	float GameTime = GetGameTime();

	if(fl_primary_reloading[client]>GameTime)
		return;

	int max_clip = RoundFloat(Attributes_Get(weapon, 868, 40.0));

	int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
	int Ammo_type = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");	//ammo type
	int reserve_ammo = GetAmmo(client, Ammo_type);							//reserve
	int ammo = GetEntData(weapon, iAmmoTable, 4);							//clip
	if(reserve_ammo < max_clip)	//abort abort!
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Insufficient Ammo to Fully reload weapon!");
		return;
	}

	if(ammo>=max_clip)	//why?
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Your Clip is already full!");
		return;
	}

	int amt_reloaded = max_clip - ammo;

	//CPrintToChatAll("%i", max_clip);
	//CPrintToChatAll("%i", ammo);

	float ratio = 1.0-(float(ammo)/float(max_clip));	//what?

	//CPrintToChatAll("%f", ratio);

	float time = 30.0*ratio;	//30

	time *=Attributes_Get(weapon, 97, 1.0);

	if(time<=2.5)
		time=2.5;
	
	if(time>120.0)	//incase somehow it goes insanely high.
		time=30.0;

	if(LastMann)
		time /=4.0;

	fl_primary_reloading[client] = GameTime + time;

	//8 is rockets ammo
	SetAmmo(client, Ammo_type, reserve_ammo-amt_reloaded);
	SetEntData(weapon, iAmmoTable, max_clip, 4, true);

	b_primary_lock[client]=true;
	Attributes_Set(weapon, 821, 1.0);

	//fl_primary_reloading[client]=0;

	int viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	if(viewmodel>MaxClients && IsValidEntity(viewmodel))
	{
		int animation = 10;
		SetEntProp(viewmodel, Prop_Send, "m_nSequence", animation);
	}

	ClipSaveSingle(client, weapon);
}
public void Blitzkrieg_Kit_Switch_Mode(int client, int weapon, const char[] classname, bool &result)
{
	if(i_patten_type[client])
		i_patten_type[client]=0;
	else
		i_patten_type[client]=1;
}
public void Blitzkrieg_Kit_Primary_Fire_1(int client, int weapon, const char[] classname, bool &result)
{
	Blitzkrieg_Kit_Rocket(client, weapon, 0.2, 3, 19.0);
}
public void Blitzkrieg_Kit_Primary_Fire_2(int client, int weapon, const char[] classname, bool &result)
{
	Blitzkrieg_Kit_Rocket(client, weapon, 0.35, 3, 19.0);
}
public void Blitzkrieg_Kit_Primary_Fire_3(int client, int weapon, const char[] classname, bool &result)
{
	Blitzkrieg_Kit_Rocket(client, weapon, 0.40, 5, 14.0);
}
public void Blitzkrieg_Kit_Primary_Fire_4(int client, int weapon, const char[] classname, bool &result)
{
	Blitzkrieg_Kit_Rocket(client, weapon, 0.55, 7, 10.0);
}
public void Blitzkrieg_Kit_Primary_Fire_5(int client, int weapon, const char[] classname, bool &result)
{
	Blitzkrieg_Kit_Rocket(client, weapon, 0.65, 7, 10.0);
}
public void Blitzkrieg_Kit_Primary_Fire_6(int client, int weapon, const char[] classname, bool &result)
{
	Blitzkrieg_Kit_Rocket(client, weapon, 0.7, 7, 10.0);
}
public void Blitzkrieg_Kit_Primary_Fire_7(int client, int weapon, const char[] classname, bool &result)
{
	Blitzkrieg_Kit_Rocket(client, weapon, 0.75, 9, 7.0);
}




static void Blitzkrieg_Kit_Rocket(int client, int weapon, float efficiency, int spread, float spacing)
{
	
	float speedMult = 1000.0;
	float dmgProjectile = 100.0;
		
	dmgProjectile *= Attributes_Get(weapon, 1, 1.0);

	dmgProjectile *= Attributes_Get(weapon, 2, 1.0);

	speedMult *= Attributes_Get(weapon, 103, 1.0);
		
	speedMult *= Attributes_Get(weapon, 104, 1.0);
	
	speedMult *= Attributes_Get(weapon, 475, 1.0);

	float fAng[3];
	GetClientEyeAngles(client, fAng);

	if(fl_ammo_efficiency[client]>=1.0)
	{
		Add_One_Ammo(weapon);
		fl_ammo_efficiency[client]-=1.0;
	}
	else
	{
		fl_ammo_efficiency[client]+=efficiency;
	}

	float fPos[3];
	GetClientEyePosition(client, fPos);

	float tmp[3];
	float actualBeamOffset[3];
	float BEAM_BeamOffset[3];
	BEAM_BeamOffset[0] = 0.0;
	BEAM_BeamOffset[1] = -8.0;
	BEAM_BeamOffset[2] = -10.0;

	tmp[0] = BEAM_BeamOffset[0];
	tmp[1] = BEAM_BeamOffset[1];
	tmp[2] = 0.0;
	VectorRotate(tmp, fAng, actualBeamOffset);
	actualBeamOffset[2] = BEAM_BeamOffset[2];
	fPos[0] += actualBeamOffset[0];
	fPos[1] += actualBeamOffset[1];
	fPos[2] += actualBeamOffset[2];

	switch(i_patten_type[client])
	{
		case 0:
		{
			int type=3;
			for(int i=0 ; i<spread ; i++)
			{
				float end_vec[3];
				Do_Vector_Stuff(i, fPos, end_vec, fAng, spread, type, spacing);
				Blitzkrieg_Kit_Rocket_Fire(client, speedMult, dmgProjectile, weapon, fAng, end_vec);
				if(type==3)
					type=1;
				else
					type=3;
			}
		}
		case 1:
		{
			int type=3;
			Handle swingTrace;
			float vecSwingForward[3] , vec[3];
					
			b_LagCompNPC_No_Layers = true;
			StartLagCompensation_Base_Boss(client);
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9999.9, false, 45.0, false); //infinite range, and (doesn't)ignore walls!	
			FinishLagCompensation_Base_boss();

			int target = TR_GetEntityIndex(swingTrace);	
			if(IsValidEnemy(client, target))
			{
				WorldSpaceCenter(target, vec);
			}
			else
			{
				TR_GetEndPosition(vec, swingTrace);
			}
			delete swingTrace;
			for(int i=0 ; i<spread ; i++)
			{
				float end_vec[3];
				Do_Vector_Stuff(i, fPos, end_vec, fAng, spread, type, spacing*1.25);
				float ang_Look[3];
				MakeVectorFromPoints(end_vec, vec, ang_Look);
				GetVectorAngles(ang_Look, ang_Look);

				Blitzkrieg_Kit_Rocket_Fire(client, speedMult, dmgProjectile, weapon, ang_Look, end_vec);
				if(type==3)
					type=1;
				else
					type=3;
			}
		}
	}
}

static void Do_Vector_Stuff(int cycle, float start_pos[3], float end_Pos[3], float angles[3], int loop_for, int type, float spacing)
{	

	float tempAngles[3], Direction[3], buffer_loc[3];
		
	tempAngles[0] = angles[0];
	tempAngles[1] = angles[1];
	tempAngles[2] = angles[2]+90.0*type;

	if(type==1)
		cycle+=1;
							
	GetAngleVectors(tempAngles, Direction, NULL_VECTOR, Direction);
	ScaleVector(Direction, spacing*cycle);
	AddVectors(start_pos, Direction, buffer_loc);

	float dist = (spacing*loop_for) - GetVectorDistance(start_pos, buffer_loc);

	Get_Fake_Forward_Vec(dist, angles, end_Pos, buffer_loc);
}

static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}
static void Add_One_Ammo(int entity)
{
	if(IsValidEntity(entity))
	{
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		int ammo = GetEntData(entity, iAmmoTable, 4);
		ammo += 1;
		SetEntData(entity, iAmmoTable, ammo, 4, true);
	}
}

static void Blitzkrieg_Kit_Rocket_Fire(int client, float speed, float damage, int weapon, float fAng[3], float fPos[3])
{
	int projectile = Wand_Projectile_Spawn(client, speed, 30.0, damage, WEAPON_KIT_BLITZKRIEG_CORE, weapon, "", fAng, false , fPos);

	ApplyCustomModelToWandProjectile(projectile, BLITZKRIEG_KIT_ROCKET_MODEL, 1.0, "");
}


public void Blitzkrieg_Kit_Rocket_StartTouch(int entity, int target)
{
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);
		
		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		float pos1[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		TE_ParticleInt(g_particleImpactTornado, pos1);
		TE_SendToAll();
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_BULLET, weapon, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?

		if(IsValidClient(owner))
		{
			i_ion_charge[owner]++;

			if(BLITZKRIEG_KIT_MAX_ION_CHARGES <= i_ion_charge[owner])
			{
				i_ion_charge[owner] = BLITZKRIEG_KIT_MAX_ION_CHARGES;
			}
		}	
		
		switch(GetRandomInt(1,5)) 
		{
			case 1:EmitSoundToAll(SOUND_IMPACT_1, entity, SNDCHAN_STATIC, 80, _, 0.9);

			case 2:EmitSoundToAll(SOUND_IMPACT_2, entity, SNDCHAN_STATIC, 80, _, 0.9);

			case 3:EmitSoundToAll(SOUND_IMPACT_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_IMPACT_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 5:EmitSoundToAll(SOUND_IMPACT_5, entity, SNDCHAN_STATIC, 80, _, 0.9);

	   	}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		float pos1[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		TE_ParticleInt(g_particleImpactTornado, pos1);
		TE_SendToAll();
		switch(GetRandomInt(1,4)) 
		{
			case 1:EmitSoundToAll(SOUND_IMPACT_CONCRETE_1, entity, SNDCHAN_STATIC, 80, _, 0.9);

			case 2:EmitSoundToAll(SOUND_IMPACT_CONCRETE_2, entity, SNDCHAN_STATIC, 80, _, 0.9);

			case 3:EmitSoundToAll(SOUND_IMPACT_CONCRETE_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_IMPACT_CONCRETE_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
		}
		RemoveEntity(entity);
	}
	return;
}
public void Blitzkrieg_Kit_Seconadry_Ion_1(int client, int weapon, bool &result, int slot)
{
	Blitzkrieg_Kit_ion_trace(client, 3, weapon);
}
public void Blitzkrieg_Kit_Seconadry_Ion_2(int client, int weapon, bool &result, int slot)
{
	Blitzkrieg_Kit_ion_trace(client, 4, weapon);
}
public void Blitzkrieg_Kit_Seconadry_Ion_3(int client, int weapon, bool &result, int slot)
{
	Blitzkrieg_Kit_ion_trace(client, 5, weapon);
}
public void Blitzkrieg_Kit_Seconadry_Ion_4(int client, int weapon, bool &result, int slot)
{
	Blitzkrieg_Kit_ion_trace(client, 6, weapon);
}
public void Blitzkrieg_Kit_Seconadry_Ion_5(int client, int weapon, bool &result, int slot)
{
	Blitzkrieg_Kit_ion_trace(client, 7, weapon);
}
public void Blitzkrieg_Kit_Seconadry_Ion_6(int client, int weapon, bool &result, int slot)
{
	Blitzkrieg_Kit_ion_trace(client, 8, weapon);
}
public void Blitzkrieg_Kit_Seconadry_Ion_7(int client, int weapon, bool &result, int slot)
{
	Blitzkrieg_Kit_ion_trace(client, 9, weapon);
}
public void Blitzkrieg_Kit_Seconadry_Ion_8(int client, int weapon, bool &result, int slot)
{
	Blitzkrieg_Kit_ion_trace(client, 13, weapon);
}

static void Blitzkrieg_Kit_ion_trace(int client, int patern, int weapon)
{

	if(i_ion_charge[client]<BLITZKREIG_KIT_ION_COST_CHARGE)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Your Weapon is not charged enough.\n[%i/%i]", i_ion_charge[client], BLITZKREIG_KIT_ION_COST_CHARGE);
		return;
	}
	float GameTime = GetGameTime();
	if (fl_ion_timer_recharge[client]>GameTime)
	{
		float Ability_CD =fl_ion_timer_recharge[client]-GameTime;
				
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
					
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		return;
	}

	i_ion_effects[client] = patern;

	Rogue_OnAbilityUse(weapon);

	float damage = Attributes_Get(weapon, 868, 1000.0);

	damage *= Attributes_Get(weapon, 1, 1.0);

	damage *= Attributes_Get(weapon, 2, 1.0);
			

	float vAngles[3];
	float vOrigin[3];
	float vEnd[3];
			
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	b_LagCompNPC_ExtendBoundingBox = true;
	StartLagCompensation_Base_Boss(client);
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);

	if(TR_DidHit(trace))
	{   
		TR_GetEndPosition(vEnd, trace);
		vEnd[2]+=10.0;
			
		Blitzkrieg_Kit_IOC_Invoke(client, vEnd, damage);
	}
	delete trace;
	FinishLagCompensation_Base_boss();
}

static int i_colour[MAXTF2PLAYERS+1][4];
static float fl_ion_chargeup[MAXTF2PLAYERS+1];
static float fl_ion_loc[MAXTF2PLAYERS+1][3];
static float fl_ion_throttle[MAXTF2PLAYERS+1];
static float fl_ion_damage[MAXTF2PLAYERS+1];

public void Blitzkrieg_Kit_IOC_Invoke(int client, float vecTarget[3], float ion_damage)	//Ion cannon from above
{

	EmitSoundToClient(client, NEUVELLETE_ION_CAST_SOUND, _, SNDCHAN_STATIC, 100, _, SNDVOL_NORMAL, SNDPITCH_NORMAL); 
	EmitSoundToClient(client, NEUVELLETE_ION_EXTRA_SOUND0, _, SNDCHAN_STATIC, 100, _, SNDVOL_NORMAL, SNDPITCH_NORMAL); 

	fl_ion_loc[client] = vecTarget;

	fl_ion_damage[client] = ion_damage;

	float GameTime = GetGameTime();

	i_ion_charge[client] -=BLITZKREIG_KIT_ION_COST_CHARGE;

	fl_ion_timer_recharge[client] = GameTime +BLITZKRIEG_KIT_ION_COOLDOWN;

	fl_ion_chargeup[client] = GameTime + BLITZKRIEG_KIT_ION_CHARGE_TIME;

	fl_ion_throttle[client]=0.0;

	SDKUnhook(client, SDKHook_PreThink, Blitzkrieg_Kit_Ion);
	SDKHook(client, SDKHook_PreThink, Blitzkrieg_Kit_Ion);

	if(Store_HasNamedItem(client, "Blitzkrieg's Army"))
	{
		i_colour[client]={185, 205, 237, 255};
	}
	else
	{
		i_colour[client]={145, 47, 47, 200};
	}
}

public Action Blitzkrieg_Kit_Ion(int client)
{
	float GameTime = GetGameTime();

	if(fl_ion_throttle[client]>GameTime)
		return Plugin_Continue;

	fl_ion_throttle[client] = GameTime+0.075;

	float vec[3]; vec = fl_ion_loc[client];
	float sky_vec[3]; sky_vec = vec;
	sky_vec[2]+=9999.0;

	int color[4]; color = i_colour[client];

	if(GameTime>fl_ion_chargeup[client])	//fire!
	{

		Explode_Logic_Custom(fl_ion_damage[client], client, client, -1, vec, BLITZKRIEG_KIT_ION_RADIUS);

		EmitSoundToAll(BLITZKRIEG_KIT_ION_EXPLOSION_SOUND, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vec); //fl_ion_damage[client]

		float vClientPosition[3];
		float dist;
		for (int i = 1; i <= MaxClients; i++)
		{
			if(IsValidClient(i))
			{	
				GetClientEyePosition(i, vClientPosition);
	
				dist = GetVectorDistance(vClientPosition, vec, false);
				if(dist < BLITZKRIEG_KIT_ION_RADIUS*2.0)
				{
					Client_Shake(i, 0, 10.0, 17.5, 3.0);
				}
			}
		}

		TE_SetupExplosion(vec, gExplosive1, 10.0, 1, 0, 0, 0);
		TE_SendToAll();

		spawnRing_Vector(vec, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt" , color[0], color[1], color[2], color[3], 1, 0.10, 5.0, 1.25, 1 , BLITZKRIEG_KIT_ION_RADIUS*3.25);
		spawnRing_Vector(vec, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt" , color[0], color[1], color[2], color[3], 1, 0.2, 5.0, 1.25, 1 , BLITZKRIEG_KIT_ION_RADIUS*2.0);
		spawnRing_Vector(vec, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt" , color[0], color[1], color[2], color[3], 1, 0.35, 5.0, 1.25, 1 , BLITZKRIEG_KIT_ION_RADIUS*1.75);
				
		vec[2]-=100.0;
		TE_SetupBeamPoints(vec, sky_vec, gLaser1, 0, 0, 0, 2.2, 30.0, 30.0, 0, 1.0, color, 3);
		TE_SendToAll();
		TE_SetupBeamPoints(vec, sky_vec, gLaser1, 0, 0, 0, 2.1, 50.0, 50.0, 0, 1.0, color, 3);
		TE_SendToAll();
		TE_SetupBeamPoints(vec, sky_vec, gLaser1, 0, 0, 0, 2.0, 80.0, 80.0, 0, 1.0, color, 3);
		TE_SendToAll();
		TE_SetupBeamPoints(vec, sky_vec, gLaser1, 0, 0, 0, 1.9, 100.0, 100.0, 0, 1.0, color, 3);
		TE_SendToAll();

		SDKUnhook(client, SDKHook_PreThink, Blitzkrieg_Kit_Ion);
		return Plugin_Stop;

	}

	float duration = fl_ion_chargeup[client] - GameTime;
	float radius = BLITZKRIEG_KIT_ION_RADIUS * (duration/BLITZKRIEG_KIT_ION_CHARGE_TIME);

	int amt=i_ion_effects[client];

	for(int ion=1 ; ion <=amt  ; ion++)
	{
		float tempAngles[3], Direction[3], EndLoc[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = (float(ion) * (360.0/amt));
		tempAngles[2] = 0.0;
			
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, radius);
		AddVectors(vec, Direction, EndLoc);

		sky_vec = EndLoc;
		sky_vec[2]+=1000.0;
		EndLoc[2]-=100.0;

		TE_SetupBeamPoints(EndLoc, sky_vec, gLaser1, 0, 0, 0, 0.08, 15.0, 45.0, 0, 0.75, color, 3);
		TE_SendToAll();

	}

	return Plugin_Continue;
}



public void Blitzkrieg_Kit_Custom_Melee_Logic(int client, float &CustomMeleeRange, float &CustomMeleeWide, int &enemies_hit_aoe)
{
	float GameTime = GetGameTime();

	if(fl_primary_reloading[client]>GameTime)
	{
		enemies_hit_aoe = 5;
		CustomMeleeRange = 64.0*1.25;		//ah, if only the defines reached here
		CustomMeleeWide = 22.0*1.25;
	}
}

public void Blitzkrieg_Kit_OnHitEffect(int client, int weapon, float &damage)
{
	float GameTime = GetGameTime();

	if(fl_primary_reloading[client]>GameTime)
	{
		damage *=1.25;

		if(LastMann)
		{
			fl_ion_timer_recharge[client] -=BLITZKRIEG_KIT_RELOAD_COOLDOWN_REDUCTION*2.0;
			fl_primary_reloading[client] -= BLITZKRIEG_KIT_RELOAD_COOLDOWN_REDUCTION*2.0;	//Reduce the cooldowns by a bit if you hit something!
		}
		else
		{
			fl_ion_timer_recharge[client] -=BLITZKRIEG_KIT_RELOAD_COOLDOWN_REDUCTION;
			fl_primary_reloading[client] -= BLITZKRIEG_KIT_RELOAD_COOLDOWN_REDUCTION;	//Reduce the cooldowns by a bit if you hit something!
		}
		
	}
}
static void spawnRing_Vector(float center[3], float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0) //Spawns a TE beam ring at a client's/entity's location
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