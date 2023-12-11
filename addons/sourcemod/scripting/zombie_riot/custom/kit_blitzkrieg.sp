#pragma semicolon 1
#pragma newdecls required

static Handle h_TimerKitBlitzkriegManagement[MAXPLAYERS+1] = {null, ...};
static float fl_hud_timer[MAXPLAYERS+1];
static float fl_primary_reloading[MAXPLAYERS+1];
static bool b_primary_lock[MAXPLAYERS+1];
static int i_ion_charge[MAXPLAYERS+1];
static float fl_primary_dmg_amt[MAXPLAYERS+1];
static int i_barrage[MAXPLAYERS+1];
static float fl_ammo_efficiency[MAXPLAYERS+1];

static int g_particleImpactTornado;

static char gGlow1;
static char gExplosive1;
static char gLaser1;

#define BLITZKRIEG_KIT_MAX_ION_CHARGES 128
#define BLITZKREIG_KIT_ION_COST_CHARGE 64
#define BLITZKRIEG_KIT_RELOAD_COOLDOWN_REDUCTION 0.5

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
	Zero(i_barrage);
	Zero(fl_ammo_efficiency);
	g_particleImpactTornado = PrecacheParticleSystem("lowV_debrischunks");
	PrecacheModel(BLITZKRIEG_KIT_ROCKET_MODEL);
	PrecacheSound(BLITZKRIEG_KIT_SHOOT_SOUND1);
	PrecacheSound(BLITZKRIEG_KIT_SHOOT_SOUND2);
	PrecacheSound(BLITZKRIEG_KIT_SHOOT_SOUND3);

	PrecacheSound(BLITZKRIEG_KIT_ION_PASIVE_SOUND);
	PrecacheSound(BLITZKRIEG_KIT_ION_EXPLOSION_SOUND);


	gLaser1 = PrecacheModel("materials/sprites/laser.vmt", true);
	gGlow1 = PrecacheModel("sprites/blueglow2.vmt", true);
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
			fl_primary_reloading[client] = 0.0;
			i_barrage[client]=0;
			b_primary_lock[client]=true;	//we have to reload it due to an update removing our entire clip
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon]==WEAPON_KIT_BLITZKRIEG_CORE)
	{
		DataPack pack;
		h_TimerKitBlitzkriegManagement[client] = CreateDataTimer(0.1, Timer_Management_KitBlitzkrieg, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		fl_primary_reloading[client] = 0.0;
		fl_primary_dmg_amt[client] = 100.0;
		i_barrage[client]=0;
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
	if(i_barrage[client] && wep==1)
	{
		Format(HUDText, sizeof(HUDText), "%s\nBarrage Active!", HUDText);
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

	float time = 10.0*ratio;	//30

	time *=Attributes_Get(weapon, 97, 1.0);

	if(time<=2.5)
		time=2.5;
	
	if(time>120.0)	//incase somehow it goes insanely high.
		time=30.0;

	fl_primary_reloading[client] = GameTime + time;

	//8 is rockets
	SetAmmo(client, Ammo_type, reserve_ammo-amt_reloaded);
	SetEntData(weapon, iAmmoTable, max_clip, 4, true);

	b_primary_lock[client]=true;
	Attributes_Set(weapon, 821, 1.0);

	int viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	if(viewmodel>MaxClients && IsValidEntity(viewmodel))
	{
		int animation = 10;
		SetEntProp(viewmodel, Prop_Send, "m_nSequence", animation);
	}
}
public void Blitzkrieg_Kit_Barrage_1(int client, int weapon, const char[] classname, bool &result)
{
	if(i_barrage[client])
	{
		i_barrage[client]=0;
	}
	else
	{
		i_barrage[client]=1;
	}
}
public void Blitzkrieg_Kit_Barrage_2(int client, int weapon, const char[] classname, bool &result)
{
	if(i_barrage[client])
	{
		i_barrage[client]=0;
	}
	else
	{
		i_barrage[client]=2;
	}
}
public void Blitzkrieg_Kit_Primary_Fire_1(int client, int weapon, const char[] classname, bool &result)
{
	Blitzkrieg_Kit_Rocket(client, weapon, 0.25);
}
public void Blitzkrieg_Kit_Primary_Fire_2(int client, int weapon, const char[] classname, bool &result)
{
	Blitzkrieg_Kit_Rocket(client, weapon, 0.4);
}
public void Blitzkrieg_Kit_Primary_Fire_3(int client, int weapon, const char[] classname, bool &result)
{
	Blitzkrieg_Kit_Rocket(client, weapon, 0.55);
}
public void Blitzkrieg_Kit_Primary_Fire_4(int client, int weapon, const char[] classname, bool &result)
{
	Blitzkrieg_Kit_Rocket(client, weapon, 0.7);
}


static void Blitzkrieg_Kit_Rocket(int client, int weapon, float efficiency)
{
	float speedMult = 1250.0;
	float dmgProjectile = 100.0;
		
	dmgProjectile *= Attributes_Get(weapon, 1, 1.0);

	dmgProjectile *= Attributes_Get(weapon, 2, 1.0);

	speedMult *= Attributes_Get(weapon, 103, 1.0);
		
	speedMult *= Attributes_Get(weapon, 104, 1.0);
	
	speedMult *= Attributes_Get(weapon, 475, 1.0);

	fl_primary_dmg_amt[client] = dmgProjectile;

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




	float GameTime = GetGameTime();

	if(i_barrage[client])
	{
		dmgProjectile *=0.9;
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		int ammo = GetEntData(weapon, iAmmoTable, 4);
		if(ammo<10)
		{
			i_barrage[client]=0;	//no more barrage, too low ammo
		}
	}
	switch(i_barrage[client])
	{
		case 0:
		{
			Blitzkrieg_Kit_Rocket_Fire(client, speedMult, dmgProjectile, weapon, fAng);
		}
		case 1:
		{
			for(int rocket=1 ; rocket < 3 ; rocket++)	//fire off 3 rockets.
			{
				float angles[3]; angles=fAng;
				angles[0] = angles[0]+GetRandomFloat(-5.0,5.0);
				angles[1] = angles[1]+GetRandomFloat(-5.0,5.0);
				angles[2] = angles[2]+GetRandomFloat(-0.25,0.25);
				Remove_One_Ammo(weapon);
				Blitzkrieg_Kit_Rocket_Fire(client, speedMult, dmgProjectile, weapon, angles);			
			}
			fAng[0] +=GetRandomFloat(-5.0,5.0);
			fAng[1] +=GetRandomFloat(-5.0,5.0);
			fAng[2] +=GetRandomFloat(-0.25,0.25);
			Blitzkrieg_Kit_Rocket_Fire(client, speedMult, dmgProjectile, weapon, fAng);
		}
		case 2:
		{
			for(int rocket=1 ; rocket < 5 ; rocket++)	//fire off 5 rockets.
			{
				float angles[3]; angles=fAng;
				angles[0] = angles[0]+GetRandomFloat(-5.0,5.0);
				angles[1] = angles[1]+GetRandomFloat(-5.0,5.0);
				angles[2] = angles[2]+GetRandomFloat(-0.25,0.25);
				Remove_One_Ammo(weapon);
				Blitzkrieg_Kit_Rocket_Fire(client, speedMult, dmgProjectile, weapon, angles);			
			}
			fAng[0] +=GetRandomFloat(-5.0,5.0);
			fAng[1] +=GetRandomFloat(-5.0,5.0);
			fAng[2] +=GetRandomFloat(-0.25,0.25);
			Blitzkrieg_Kit_Rocket_Fire(client, speedMult, dmgProjectile, weapon, fAng);
		}
	}
}

static void Remove_One_Ammo(int entity)
{
	if(IsValidEntity(entity))
	{
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		int ammo = GetEntData(entity, iAmmoTable, 4);
		ammo -= 1;
		SetEntData(entity, iAmmoTable, ammo, 4, true);
	}
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

static void Blitzkrieg_Kit_Rocket_Fire(int client, float speed, float damage, int weapon, float fAng[3])
{

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

	int projectile = Wand_Projectile_Spawn(client, speed, 30.0, damage, WEAPON_KIT_BLITZKRIEG_CORE, weapon, "", fAng, false , fPos);

	ApplyCustomModelToWandProjectile(projectile, BLITZKRIEG_KIT_ROCKET_MODEL, 1.0, "");
}
public void Blitzkrieg_Kit_Rocket_StartTouch(int entity, int other)
{
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		Entity_Position = WorldSpaceCenter(target);
		
		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		float pos1[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		TE_ParticleInt(g_particleImpactTornado, pos1);
		TE_SendToAll();

		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_BULLET, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position);	// 2048 is DMG_NOGIB?

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

public void Blitzkrieg_Kit_Seconadry_Ion(int client, int weapon, bool &result, int slot)
{
	if(i_ion_charge[client]<BLITZKREIG_KIT_ION_COST_CHARGE)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Your Weapon is not charged enough.\n[%i/%i]", i_ion_charge[client], BLITZKREIG_KIT_ION_COST_CHARGE);
		return;
	}
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		i_ion_charge[client] -=BLITZKREIG_KIT_ION_COST_CHARGE;
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, 15.0);

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

			vEnd[2]+=25.0;
			
			Blitzkrieg_Kit_IOC_Invoke(client, vEnd, damage);
		}
		delete trace;
		FinishLagCompensation_Base_boss();

	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
				
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
					
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

static int i_colour[MAXTF2PLAYERS+1][4];

public void Blitzkrieg_Kit_IOC_Invoke(int client, float vecTarget[3], float ion_damage)	//Ion cannon from above
{
	float distance=200.0; // /29 for duartion till boom
	float IOCDist=350.0;
	float IOCdamage=ion_damage;
		
	Handle data = CreateDataPack();
	WritePackFloat(data, vecTarget[0]);
	WritePackFloat(data, vecTarget[1]);
	WritePackFloat(data, vecTarget[2]);
	WritePackCell(data, distance); // Distance
	WritePackFloat(data, 0.0); // nphi
	WritePackCell(data, IOCDist); // Range
	WritePackCell(data, IOCdamage); // Damge
	WritePackCell(data, EntIndexToEntRef(client));
	ResetPack(data);
	Blitzkrieg_Kit_IonAttack(data);

	if(Store_HasNamedItem(client, "Blitzkrieg's Army"))
	{
		i_colour[client]={185, 205, 237, 255};
	}
	else
	{
		i_colour[client]={145, 47, 47, 255};
	}
}
public Action Blitzkrieg_Kit_DrawIon(Handle Timer, any data)
{
	Blitzkrieg_Kit_IonAttack(data);
		
	return (Plugin_Stop);
}
	
public void Blitzkrieg_Kit_DrawIonBeam(float startPosition[3], const int color[4])
{
	float position[3];
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] = startPosition[2] + 3000.0;	
	
	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 0.15, 25.0, 25.0, 0, 1.0, color, 3 );
	TE_SendToAll();
	position[2] -= 1490.0;
	TE_SetupGlowSprite(startPosition, gGlow1, 0.5, 1.0, 255);
	TE_SendToAll();
}

public void Blitzkrieg_Kit_IonAttack(Handle &data)
{
	float startPosition[3];
	float position[3];
	startPosition[0] = ReadPackFloat(data);
	startPosition[1] = ReadPackFloat(data);
	startPosition[2] = ReadPackFloat(data);
	float Iondistance = ReadPackCell(data);
	float nphi = ReadPackFloat(data);
	float Ionrange = ReadPackCell(data);
	float Iondamage = ReadPackCell(data);
	int client = EntRefToEntIndex(ReadPackCell(data));

	if(!IsValidClient(client))
	{
		delete data;
		return;
	}

		
	if (Iondistance > 0)
	{
		EmitSoundToAll(BLITZKRIEG_KIT_ION_PASIVE_SOUND, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
			
		// Stage 1

		int loop =3;

		for(int amt=0 ; amt < loop ; amt++)
		{
			float s=Sine((nphi+(360.0/loop)*amt)/360*6.28)*Iondistance;
			float c=Cosine((nphi+(360.0/loop)*amt)/360*6.28)*Iondistance;
				
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[2] = startPosition[2];
				
			position[0] += s;
			position[1] += c;
			Blitzkrieg_Kit_DrawIonBeam(position, i_colour[client]);
		
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			Blitzkrieg_Kit_DrawIonBeam(position, i_colour[client]);
		}
	
		if (nphi >= 360)
			nphi = 0.0;
		else
			nphi += 5.0;
	}
	Iondistance -= 10;

	delete data;
		
	Handle nData = CreateDataPack();
	WritePackFloat(nData, startPosition[0]);
	WritePackFloat(nData, startPosition[1]);
	WritePackFloat(nData, startPosition[2]);
	WritePackCell(nData, Iondistance);
	WritePackFloat(nData, nphi);
	WritePackCell(nData, Ionrange);
	WritePackCell(nData, Iondamage);
	WritePackCell(nData, EntIndexToEntRef(client));
	ResetPack(nData);
		
	if (Iondistance > -30)
		CreateTimer(0.1, Blitzkrieg_Kit_DrawIon, nData, TIMER_FLAG_NO_MAPCHANGE);
	else
	{

		startPosition[2] += 25.0;
		Explode_Logic_Custom(Iondamage, client, client, -1, startPosition, 300.0 , _ , _ , false);
		startPosition[2] -= 25.0;
					
		TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
		TE_SendToAll();
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[2] += startPosition[2] + 900.0;
		startPosition[2] += -200;
		TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 30.0, 30.0, 0, 1.0, i_colour[client], 3);
		TE_SendToAll();
		TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 50.0, 50.0, 0, 1.0, i_colour[client], 3);
		TE_SendToAll();
		TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 80.0, 80.0, 0, 1.0, i_colour[client], 3);
		TE_SendToAll();
		TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 100.0, 100.0, 0, 1.0, i_colour[client], 3);
		TE_SendToAll();
		
		position[2] = startPosition[2] + 50.0;
		// Sound
		EmitSoundToAll(BLITZKRIEG_KIT_ION_EXPLOSION_SOUND, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
				
		float vClientPosition[3];
		float dist;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientConnected(i) && IsClientInGame(i) && IsPlayerAlive(i))
			{	
				GetClientEyePosition(i, vClientPosition);
		
				dist = GetVectorDistance(vClientPosition, position, false);
				if (dist < 500.0)
				{
					Client_Shake(i, 0, 10.0, 25.0, 3.75);
				}
			}
		}	
	}
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

public void Blitzkrieg_Kit_Custom_Damage_Calc(int client, int weapon, float &damage)
{
	float GameTime = GetGameTime();

	damage = fl_primary_dmg_amt[client];

	damage *= Attributes_Get(weapon, 868, 1.0);

	if(fl_primary_reloading[client]>GameTime)
	{
		damage *=1.25;

		fl_primary_reloading[client] -= BLITZKRIEG_KIT_RELOAD_COOLDOWN_REDUCTION;	//Reduce the cooldowns by a bit if you hit something!
	}
}