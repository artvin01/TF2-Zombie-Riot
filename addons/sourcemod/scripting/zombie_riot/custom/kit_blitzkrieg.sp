#pragma semicolon 1
#pragma newdecls required

static Handle h_TimerKitBlitzkriegManagement[MAXPLAYERS+1] = {null, ...};
static float fl_hud_timer[MAXPLAYERS+1];
static float fl_primary_reloading[MAXPLAYERS+1];
static int i_last_ammo[MAXPLAYERS+1];
static bool b_primary_lock[MAXPLAYERS+1];
static int i_ion_charge[MAXPLAYERS+1];

static int i_tornado_index[MAXENTITIES+1];
static int i_tornado_wep[MAXENTITIES+1];
static float fl_tornado_dmg[MAXENTITIES+1];
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
#define BLITZKRIEG_KIT_ION_EXPLOSION_SOUND "ambient/explosions/explode_9.wav"


public void Kit_Blitzkrieg_Precache()
{
	Zero(fl_primary_reloading);
	Zero(fl_hud_timer);
	Zero(i_ion_charge);
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

public void Blitzkrieg_Kit_OnBuy(int client)
{
	i_last_ammo[client]=0;
	fl_primary_reloading[client] = 0.0;
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
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon]==WEAPON_KIT_BLITZKRIEG_CORE)
	{
		DataPack pack;
		h_TimerKitBlitzkriegManagement[client] = CreateDataTimer(0.1, Timer_Management_KitBlitzkrieg, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
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
			BlitzHud(client, GameTime);

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
			BlitzHud(client, GameTime);
		}
		case 3: //melee 1
		{
			BlitzHud(client, GameTime);
		}
		default:	//weapon contains none of the apropriate id's kill it.
		{
			h_TimerKitBlitzkriegManagement[client] = null;
			CPrintToChatAll("Killed timer via default switch");
			return Plugin_Stop;
		}
	}
		
	return Plugin_Continue;
}

static void BlitzHud(int client, float GameTime)
{
	if(fl_hud_timer[client]>GameTime)
		return;
	
	fl_hud_timer[client]=GameTime+0.5;

	char HUDText[255] = "";

	Format(HUDText, sizeof(HUDText), "%sIon Charges: [%i/%i]", HUDText, i_ion_charge[client], BLITZKRIEG_KIT_MAX_ION_CHARGES);
	
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

	int Ammo_type = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
	int current_ammo = GetAmmo(client, Ammo_type);
	if(current_ammo < max_clip)	//abort abort!
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Insufficient Ammo to reload weapon!");
		return;
	}

	if(current_ammo==max_clip)	//why?
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Your Clip is already full!");
		return;
	}

	int ammo = i_last_ammo[client];

	int amt_reloaded = max_clip - i_last_ammo[client]+1;	//need to make it eat 1 extra due to stuff.

	//CPrintToChatAll("%i", max_clip);
	//CPrintToChatAll("%i", ammo);

	float ratio = 1.0-(float(ammo)/float(max_clip));	//what?

	//CPrintToChatAll("%f", ratio);

	float time = 30.0*ratio;
	if(time<=2.5)
		time=2.5;
	
	if(time>120.0)	//incase somehow it goes insanely high.
		time=30.0;

	fl_primary_reloading[client] = GameTime + time;

	i_last_ammo[client] = max_clip;

	//8 is rockets
	int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
	SetAmmo(client, Ammo_type, current_ammo-amt_reloaded);
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


static void Play_Proper_Sound(int client)
{
	switch(GetRandomInt(0, 2))
	{
		case 0: EmitSoundToAll(BLITZKRIEG_KIT_SHOOT_SOUND1, client, SNDCHAN_STATIC, GetRandomInt(80 , 100), _, 0.4, GetRandomInt(90, 110));
		case 1: EmitSoundToAll(BLITZKRIEG_KIT_SHOOT_SOUND2, client, SNDCHAN_STATIC, GetRandomInt(80 , 100), _, 0.4, GetRandomInt(90, 110));
		case 2: EmitSoundToAll(BLITZKRIEG_KIT_SHOOT_SOUND3, client, SNDCHAN_STATIC, GetRandomInt(80 , 100), _, 0.4, GetRandomInt(90, 110));
	}
}
public void Blitzkrieg_Kit_Primary_Fire(int client, int weapon, const char[] classname, bool &result)
{
	Play_Proper_Sound(client);
	Blitzkrieg_Kit_Rocket(client, weapon);
}


static void Blitzkrieg_Kit_Rocket(int client, int weapon)
{
	float speedMult = 1250.0;
	float dmgProjectile = 100.0;
		
	dmgProjectile *= Attributes_Get(weapon, 1, 1.0);

	dmgProjectile *= Attributes_Get(weapon, 2, 1.0);

	speedMult *= Attributes_Get(weapon, 103, 1.0);
		
	speedMult *= Attributes_Get(weapon, 104, 1.0);
	
	speedMult *= Attributes_Get(weapon, 475, 1.0);

	Blitzkrieg_Kit_Rocket_Fire(client, speedMult, dmgProjectile, weapon);
}

static void Blitzkrieg_Kit_Rocket_Fire(int client, float speed, float damage, int weapon)
{

	int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
	i_last_ammo[client] = GetEntData(weapon, iAmmoTable, 4);

	float fAng[3], fPos[3];
	GetClientEyeAngles(client, fAng);
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


	float fVel[3], fBuf[3];
	GetAngleVectors(fAng, fBuf, NULL_VECTOR, NULL_VECTOR);
	fVel[0] = fBuf[0]*speed;
	fVel[1] = fBuf[1]*speed;
	fVel[2] = fBuf[2]*speed;

	int entity = CreateEntityByName("zr_projectile_base");
	if(IsValidEntity(entity))
	{
		fl_tornado_dmg[entity]=damage;
		i_tornado_wep[entity]=EntIndexToEntRef(weapon);
		i_tornado_index[entity]=EntIndexToEntRef(client);
		b_EntityIsArrow[entity] = true;
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client); //No owner entity! woo hoo
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);
		SetEntProp(entity, Prop_Send, "m_iTeamNum", GetEntProp(client, Prop_Send, "m_iTeamNum"));
		int frame = GetEntProp(entity, Prop_Send, "m_ubInterpolationFrame");
		TeleportEntity(entity, fPos, fAng, NULL_VECTOR);
		DispatchSpawn(entity);
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, fVel);
		SetEntPropFloat(entity, Prop_Data, "m_flSimulationTime", GetGameTime());
		SetEntProp(entity, Prop_Send, "m_ubInterpolationFrame", frame);

		g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Blitzkrieg_Kit_RocketExplodePre);
		SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
		SDKHook(entity, SDKHook_StartTouch, Blitzkrieg_Kit_Rocket_StartTouch);

		ApplyCustomModelToWandProjectile(entity, BLITZKRIEG_KIT_ROCKET_MODEL, 1.0, "");
	}
	return;
}
public MRESReturn Blitzkrieg_Kit_RocketExplodePre(int entity)
{
	//CPrintToChatAll("explode pre");
	return MRES_Supercede;
}
public void Blitzkrieg_Kit_Rocket_StartTouch(int entity, int other)
{
	int target = Target_Hit_Wand_Detection(entity, other);
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		Entity_Position = WorldSpaceCenter(target);
		
		int owner = EntRefToEntIndex(i_tornado_index[entity]);
		int weapon = EntRefToEntIndex(i_tornado_wep[entity]);

		float pos1[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		TE_ParticleInt(g_particleImpactTornado, pos1);
		TE_SendToAll();

		SDKHooks_TakeDamage(target, owner, owner, fl_tornado_dmg[entity], DMG_BULLET, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position);	// 2048 is DMG_NOGIB?

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
		Explode_Logic_Custom(Iondamage, client, client, -1, startPosition, 400.0 , _ , _ , false);
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
					Client_Shake(i, 0, 10.0, 25.0, 7.5);
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

public void Blitzkrieg_Kit_Custom_Damage_Calc(int client, float &damage)
{
	float GameTime = GetGameTime();

	if(fl_primary_reloading[client]>GameTime)
	{
		damage *=1.25;

		fl_primary_reloading[client] -= BLITZKRIEG_KIT_RELOAD_COOLDOWN_REDUCTION;	//Reduce the cooldowns by a bit if you hit something!
	}
}