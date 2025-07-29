#pragma semicolon 1
#pragma newdecls required

#define PILLAR_SPACING 170.0
#define PILLAR_MODEL "models/props_wasteland/rockcliff06d.mdl"

static int Icicle_TE_Used;
static bool Cryo_Frozen[MAXENTITIES]={false, ...}; //Is this zombie frozen?
static bool Cryo_Slowed[MAXENTITIES]={false, ...}; //Is this zombie frozen?

#define SOUND_WAND_ATTACKSPEED_ABILITY "weapons/physcannon/energy_disintegrate4.wav"
#define WAND_TELEPORT_SOUND "misc/halloween/spell_teleport.wav"


void Wand_IcicleShard_Map_Precache()
{
	PrecacheSound(WAND_TELEPORT_SOUND);
	PrecacheSound(SOUND_WAND_ATTACKSPEED_ABILITY);
	PrecacheSound("weapons/icicle_melt_01.wav");
	PrecacheModel(PILLAR_MODEL);
}

public float AbilityIcicleShard(int client, int index, char name[48])
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(IsValidEntity(weapon))
		{
			static char classname[36];
			GetEntityClassname(weapon, classname, sizeof(classname));
			if (i_IsWandWeapon[weapon])
			{
				if(Stats_Intelligence(client) >= 25)
				{
					float time = Weapon_Wand_IcicleShard(client, weapon, 1);
					return (GetGameTime() + time);
				}
				else
				{
					ClientCommand(client, "playgamesound items/medshotno1.wav");
					ShowGameText(client,"leaderboard_streak", 0, "You do not have enough Intelligence [25]");
					return 0.0;
				}
			}
			else
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Magic Wand.");
				return 0.0;
			}
		}

	//	if(kv.GetNum("consume", 1))

	}
	return 0.0;
}

float Weapon_Wand_IcicleShard(int client, int weapon, int level)
{
	float damage;
	
	damage = Config_GetDPSOfEntity(weapon);

	damage *= 2.5;	

	int MaxCount = (7 * level);
	float DelayPillars = 0.25;
	float DelaybewteenPillars = 0.1;
	float ang_Look[3]; GetClientEyeAngles(client, ang_Look);
	float pos[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos);
	float Scale = 0.5;

	ang_Look[0] = 0.0;
	ang_Look[2] = 0.0;
	Icicle_Damaging_Pillars_Ability(client,
	weapon,
	damage,				 	//damage
	MaxCount, 	//how many
	DelayPillars,									//Delay untill hit
	DelaybewteenPillars,									//Extra delay between each
	ang_Look 								/*2 dimensional plane*/,
	pos,
	1.0,
	Scale);									//volume
	return 25.0;
}








void Icicle_Damaging_Pillars_Ability(int entity,
int weapon,
float damage,
int count,
float delay,
float delay_PerPillar,
float direction[3] /*2 dimensional plane*/,
float origin[3],
float volume = 0.7,
float Scale = 1.0)
{
	float timerdelay = GetGameTime() + delay;
	DataPack pack;
	CreateDataTimer(delay_PerPillar, Icicle_DamagingPillar, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity)); 	//who this attack belongs to
	pack.WriteCell(EntIndexToEntRef(weapon)); 	//who this attack belongs to
	pack.WriteCell(damage);
	pack.WriteCell(0);						//how many pillars, this counts down with each pillar made
	pack.WriteCell(count);						//how many pillars, this counts down with each pillar made
	pack.WriteCell(timerdelay);					//Delay for each initial pillar
	pack.WriteCell(direction[0]);
	pack.WriteCell(direction[1]);
	pack.WriteCell(direction[2]);
	pack.WriteCell(origin[0]);
	pack.WriteCell(origin[1]);
	pack.WriteCell(origin[2]);
	pack.WriteCell(volume);
	pack.WriteCell(Scale);
	Icicle_TE_Used = 0;
	float origin_altered[3];
	origin_altered = origin;

	for(int Repeats; Repeats < count; Repeats++)
	{
		float VecForward[3];
		float vecRight[3];
		float vecUp[3];
				
		GetAngleVectors(direction, VecForward, vecRight, vecUp);
		
		float vecSwingEnd[3];
		vecSwingEnd[0] = origin_altered[0] + VecForward[0] * (PILLAR_SPACING * Scale);
		vecSwingEnd[1] = origin_altered[1] + VecForward[1] * (PILLAR_SPACING * Scale);
		vecSwingEnd[2] = origin[2];/*+ VecForward[2] * (100);*/

		origin_altered = vecSwingEnd;

		//Clip to ground, its like stepping on stairs, but for these rocks.

		float BoundingBox[3];
		BoundingBox[0] = (24.0* Scale);
		BoundingBox[1] = (24.0* Scale);
		BoundingBox[2] = (24.0* Scale);

		Icicle_ClipPillarToGround(BoundingBox, 100.0, origin_altered);
		float Range = 100.0;

		Range += (float(Repeats) * 10.0);
		
		Range *= Scale;
		
		Icicle_TE_Used += 1;
		if(Icicle_TE_Used > 31)
		{
			int DelayFrames = (Icicle_TE_Used / 32);
			DelayFrames *= 2;
			DataPack pack_TE = new DataPack();
			pack_TE.WriteCell(origin_altered[0]);
			pack_TE.WriteCell(origin_altered[1]);
			pack_TE.WriteCell(origin_altered[2]);
			pack_TE.WriteCell(Range);
			pack_TE.WriteCell(delay + (delay_PerPillar * float(Repeats)));
			RequestFrames(Icicle_DelayTE, DelayFrames, pack_TE);
			//Game cannot send more then 31 te's in the same frame, a fix is too just delay it.
		}
		else
		{
			spawnRing_Vectors(origin_altered, Range * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 125, 125, 255, 200, 1, delay + (delay_PerPillar * float(Repeats)), 5.0, 0.0, 1);	
		}
		/*
		int laser;
		RaidbossIcicle npc = view_as<RaidbossIcicle>(entity);

		int red = 212;
		int green = 155;
		int blue = 0;

		laser = ConnectWithBeam(npc.m_iWearable6, -1, red, green, blue, 5.0, 5.0, 0.0, LINKBEAM,_, origin_altered);

		CreateTimer(delay, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
		*/

	}
}

void Icicle_ClipPillarToGround(float vecHull[3], float StepHeight, float vecorigin[3])
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
	trace = TR_TraceHullFilterEx( startPostionTrace, endPostionTrace, vecHullMins, vecHull, MASK_PLAYERSOLID,HitOnlyWorld, 0);
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
			
public void Icicle_DelayTE(DataPack pack)
{
	pack.Reset();
	float Origin[3];
	Origin[0] = pack.ReadCell();
	Origin[1] = pack.ReadCell();
	Origin[2] = pack.ReadCell();
	float Range = pack.ReadCell();
	float Delay = pack.ReadCell();
	spawnRing_Vectors(Origin, Range * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 125, 125, 255, 200, 1, Delay, 5.0, 0.0, 1);	
		
	delete pack;
}

public Action Icicle_DamagingPillar(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	float damage = pack.ReadCell();
	DataPackPos countPos = pack.Position;
	int count = pack.ReadCell();
	int countMax = pack.ReadCell();
	float delayUntillImpact = pack.ReadCell();
	float direction[3];
	direction[0] = pack.ReadCell();
	direction[1] = pack.ReadCell();
	direction[2] = pack.ReadCell();
	float origin[3];
	DataPackPos originPos = pack.Position;
	origin[0] = pack.ReadCell();
	origin[1] = pack.ReadCell();
	origin[2] = pack.ReadCell();
	float volume = pack.ReadCell();
	float Scale = pack.ReadCell();

	//Timers have a 0.1 impresicison logic, accont for it.
	if(delayUntillImpact - 0.1 > GetGameTime())
	{
		return Plugin_Continue;
	}

	count += 1;
	pack.Position = countPos;
	pack.WriteCell(count, false);
	if(IsValidEntity(entity) && IsValidEntity(weapon))
	{
		float VecForward[3];
		float vecRight[3];
		float vecUp[3];
				
		GetAngleVectors(direction, VecForward, vecRight, vecUp);
		
		float vecSwingEnd[3];
		vecSwingEnd[0] = origin[0] + VecForward[0] * (PILLAR_SPACING * Scale);
		vecSwingEnd[1] = origin[1] + VecForward[1] * (PILLAR_SPACING * Scale);
		vecSwingEnd[2] = origin[2];/*+ VecForward[2] * (100);*/

		float BoundingBox[3];
		BoundingBox[0] = (24.0 * Scale);
		BoundingBox[1] = (24.0 * Scale);
		BoundingBox[2] = (24.0 * Scale);

		Icicle_ClipPillarToGround(BoundingBox, 100.0, vecSwingEnd);


		
		int prop = CreateEntityByName("prop_physics_multiplayer");
		if(IsValidEntity(prop))
		{

		//	float vel[3];
		//	vel[2] = 750.0;
			float SpawnPropPos[3];
			float SpawnParticlePos[3];

			SpawnPropPos = vecSwingEnd;
			SpawnParticlePos = vecSwingEnd;

			SpawnParticlePos[2] += 5.0;

			DispatchKeyValue(prop, "model", PILLAR_MODEL);
			DispatchKeyValue(prop, "physicsmode", "2");
			DispatchKeyValue(prop, "solid", "0");
			DispatchKeyValue(prop, "massScale", "1.0");
			DispatchKeyValue(prop, "spawnflags", "6");


			float SizeScale = 0.9;
			SizeScale += (count * 0.1);
			SizeScale *= Scale;

			char FloatString[8];
			FloatToString(SizeScale, FloatString, sizeof(FloatString));

			DispatchKeyValue(prop, "modelscale", FloatString);
			DispatchKeyValueVector(prop, "origin",	 SpawnPropPos);
			direction[2] -= 180.0;
			direction[1] -= 180.0;
			direction[0] = -40.0;
			DispatchKeyValueVector(prop, "angles",	 direction);
			DispatchSpawn(prop);
		//	TeleportEntity(prop, NULL_VECTOR, NULL_VECTOR, vel);
			SetEntityRenderMode(prop, RENDER_TRANSCOLOR);
			SetEntityRenderColor(prop, 125, 125, 255, 200);
			SetEntityCollisionGroup(prop, 1); //COLLISION_GROUP_DEBRIS_TRIGGER
			SetEntProp(prop, Prop_Send, "m_usSolidFlags", 12); 
			SetEntProp(prop, Prop_Data, "m_nSolidType", 6); 
			SetEntityMoveType(prop, MOVETYPE_NONE);

			float Range = 100.0;

			Range += (float(count) * 10.0);

			Range *= Scale;
			
			Explode_Logic_Custom(damage, entity, entity, weapon, SpawnParticlePos, Range, _, _, false, _, _, _, Cryo_FreezeZombie);
			
			if(volume == 0.25)
			{
				EmitSoundToAll("weapons/icicle_melt_01.wav", 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, volume, SNDPITCH_NORMAL, -1, SpawnParticlePos);		
			}
			else
			{
				EmitSoundToAll("weapons/icicle_melt_01.wav", 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, volume, SNDPITCH_NORMAL, -1, SpawnParticlePos);
				EmitSoundToAll("weapons/icicle_melt_01.wav", 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, volume, SNDPITCH_NORMAL, -1, SpawnParticlePos);
			}
		
			spawnRing_Vectors(SpawnParticlePos, 0.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 125, 125, 255, 200, 1, 0.5, 12.0, 6.1, 1,Range * 2.0);
			
			TE_Particle("xms_snowburst_child01", SpawnParticlePos, NULL_VECTOR, NULL_VECTOR, prop, _, _, _, _, _, _, _, _, _, 0.0);

			CreateTimer(2.0, Timer_RemoveEntity, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
		}
		
		pack.Position = originPos;
		pack.WriteCell(vecSwingEnd[0], false);
		pack.WriteCell(vecSwingEnd[1], false);
		pack.WriteCell(origin[2], false);
		//override origin, we have a new origin.
	}
	else
	{
		return Plugin_Stop; //cancel.
	}

	if(count >= countMax)
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public void Cryo_FreezeZombie(int client, int zombie, float damage, int weapon)
{
	if (!IsValidEntity(zombie))
		return;

	if(!Cryo_Slowed[zombie] && !Cryo_Frozen[zombie])
	{
		CClotBody ZNPC = view_as<CClotBody>(zombie);
		Cryo_Frozen[zombie] = true;
		float FreezeDuration;

		FreezeDuration = 1.5;

		CreateTimer(FreezeDuration, Cryo_Unfreeze, EntIndexToEntRef(zombie), TIMER_FLAG_NO_MAPCHANGE);
		FreezeNpcInTime(zombie, FreezeDuration);

		SetEntityRenderMode(zombie, RENDER_NORMAL, false, 1, false, true);
		SetEntityRenderColor(zombie, 0, 0, 255, 255, false, false, true);
		float position[3];
		GetEntPropVector(zombie, Prop_Data, "m_vecAbsOrigin", position);
		
		ApplyStatusEffect(client, zombie, "Near Zero", 8.0 + FreezeDuration);

		//Un-comment the following line if you want a particle to appear on frozen zombies:
		//int particle = ParticleEffectAt(position, CRYO_FREEZE_PARTICLE, Cryo_FreezeDuration);
			
	}
}



public Action Cryo_Unfreeze(Handle Unfreeze, int ref)
{
	int zombie = EntRefToEntIndex(ref);
	
	if (!IsValidEntity(zombie))
	return Plugin_Continue;
	
	if (Cryo_Frozen[zombie])
	{
		Cryo_Frozen[zombie] = false;
		Cryo_Slowed[zombie] = true;
		CClotBody ZNPC = view_as<CClotBody>(zombie);
		CreateTimer(8.0, Cryo_Unslow, EntIndexToEntRef(zombie), TIMER_FLAG_NO_MAPCHANGE);
		
		SetEntityRenderMode(zombie, i_EntityRenderMode[zombie], true, 2, false, true);
		SetEntityRenderColor(zombie, i_EntityRenderColour1[zombie], i_EntityRenderColour2[zombie], i_EntityRenderColour3[zombie], i_EntityRenderColour4[zombie], true, false, true);
	}
	
	return Plugin_Continue;
}



public Action Cryo_Unslow(Handle Unslow, int ref)
{
	int zombie = EntRefToEntIndex(ref);
	
	if (!IsValidEntity(zombie))
	return Plugin_Continue;
	
	Cryo_Slowed[zombie] = false;
	
	return Plugin_Continue;
}

public void CleanAllApplied_Cryo(int entity)
{
	Cryo_Frozen[entity] = false;
	Cryo_Slowed[entity] = false;
}


public float FireBallBonusDamage(int client, int zombie, float damage, int weapon)
{
	if (Cryo_Frozen[zombie])
	{
		damage *= 1.35;
		DisplayCritAboveNpc(zombie, client, true); //Display crit above head
	}
	return damage;
}