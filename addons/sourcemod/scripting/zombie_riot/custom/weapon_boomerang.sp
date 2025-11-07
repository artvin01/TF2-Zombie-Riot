#pragma semicolon 1
#pragma newdecls required

//#define BOOMERANG_MODEL "models/props_forest/saw_blade.mdl"
#define METAL_BOOMERANG_MODEl "models/props_junk/sawblade001a.mdl"
#define WOODEN_BOOMERANG_MODEL "models/workshop/weapons/c_models/c_wheel_shield/c_wheel_shield.mdl"
#define LARGE_METAL_BOOMERANG_MODEL "models/props_forest/saw_blade_large.mdl"
#define BOOMERANG_HIT_SOUND_WOOD "player/footsteps/woodpanel4.wav"
#define BOOMERANG_HIT_SOUND_METAL "weapons/metal_hit_hand3.wav"
#define BOOMERANG_FIRE_SOUND "passtime/projectile_swoosh2.wav"

static int HitsLeft[MAXENTITIES]={0, ...};
static int i_Current_Pap[MAXPLAYERS+1] = {0, ...};
static int Times_Damage_Got_Reduced[MAXENTITIES]={0, ...};

void WeaponBoomerang_MapStart()
{
	PrecacheSound(BOOMERANG_HIT_SOUND_WOOD);
	PrecacheSound(BOOMERANG_HIT_SOUND_METAL);
	PrecacheSound(BOOMERANG_FIRE_SOUND);
	PrecacheSound("player/taunt_jackhammer_down_swoosh.wav");
}

public void Weapon_Boomerang_Attack(int client, int weapon, bool crit)
{
	i_Current_Pap[client] = Boomerang_Get_Pap(weapon); //i am so happy i dont have to write 12 seperate attack functions
	switch (i_Current_Pap[client])
	{
		case 0: //base pap
		{
			BoomerRangThrow(client, weapon, WOODEN_BOOMERANG_MODEL);
		}
		case 1: //Whirling Blade
		{
			BoomerRangThrow(client, weapon, METAL_BOOMERANG_MODEl, 7);
		}
		case 2: //Kylie Boomerang
		{
			BoomerRangThrow(client, weapon, WOODEN_BOOMERANG_MODEL, 5, 1.45);
		}
		case 3: //Whirlwind Rang
		{
			float fAng[3];
			GetClientEyeAngles(client, fAng);
			for (int i = 1; i <= 2; i++)
			{
				if (i == 1)
				{
					fAng[1] += 5.0;
				}
				else if(i == 2)
				{
					fAng[1] -= 10.0;//double the last one so it doesnt just come back to 0
				}
				BoomerRangThrow(client, weapon, WOODEN_BOOMERANG_MODEL, 1, 1.0, fAng);
			}
		}
		case 4: //Glaive Lord
		{
		//	if (Glaives_Currently_Shot[client] <= 1)// 2 projectiles active at once
			BoomerrangFireMultiple(client, weapon, 2);
		}
		case 5: //Nightmare
		{
			BoomerRangThrow(client, weapon, LARGE_METAL_BOOMERANG_MODEL, 8, 0.5);
		}
		case 6: //Sunswallower
		{
			float fAng[3];
			GetClientEyeAngles(client, fAng);


			for (int i = 1; i <= 3; i++)//fire 3 projectiles
			{
				//fAng[2] += GetRandomFloat(-7.0, 7.0);//changes horizontal, can use this to fix the sawblade model from tf2
				if (i == 1)
				{
					fAng[1] += 5.0;
				}
				else if(i == 2)
				{
					fAng[1] -= 5.0;
				}
				else if(i == 3)
				{
					fAng[1] -= 5.0;
				}
				BoomerRangThrow(client, weapon, WOODEN_BOOMERANG_MODEL, 1, 1.0, fAng);
			}
		}
	}
	EmitSoundToClient(client, BOOMERANG_FIRE_SOUND, client, SNDCHAN_AUTO, 80, _, 0.8, 110);
}
public void Weapon_Boomerang_Ability(int client, int weapon, bool crit)
{
	i_Current_Pap[client] = Boomerang_Get_Pap(weapon);
	switch (i_Current_Pap[client])
	{
		case 4: //Glaive Lord
		{
			//artvin pls help with spinning glaives
		}
		case 5: //Nightmare
		{
			//idk yet
		}
		case 6: //Sunswallower
		{
			DataPack pack;
			CreateDataTimer(0.1, Timer_Multiple_Boomerangs, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(EntIndexToEntRef(client));
			pack.WriteCell(EntIndexToEntRef(weapon));
			pack.WriteCell(4);
		}
	}
}

public Action Timer_Multiple_Boomerangs(Handle timer, DataPack pack)
{
	
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	//am i alive
	if(!IsEntityAlive(client))
	{
		return Plugin_Stop;
	}
	//does my weapon exist still
	if(!IsValidEntity(weapon))
	{
		return Plugin_Stop;
	}
	//if we hit 0, stop.
	int TimesRemain = pack.ReadCell();
	if(TimesRemain < 0)
		return Plugin_Stop;
	pack.Position--;
	pack.WriteCell(TimesRemain-1, false);
	//is my active weapon the weapon i used it with
	int weaponActive = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon != weaponActive)
	{
		return Plugin_Stop;
	}

	for (int i = 1; i <= 3; i++)//each call fires 3 projectiles
	{
		float fAng[3];
		GetClientEyeAngles(client, fAng);
		fAng[0] += GetRandomFloat(-9.0, 9.0); //vertical spread
		fAng[1] += GetRandomFloat(-9.0, 9.0);
		fAng[2] += GetRandomFloat(-45.0, 45.0); //projectile spin
		BoomerRangThrow(client, weapon, WOODEN_BOOMERANG_MODEL, 1, 1.0, fAng);
	}
	EmitSoundToClient(client, "player/taunt_jackhammer_down_swoosh.wav", client, SNDCHAN_AUTO, 80, _, 1.0, 110);
	return Plugin_Continue;
}

public void Weapon_Boomerang_Touch(int entity, int target)
{
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	int Trail = EntRefToEntIndex(f_ArrowTrailParticle[entity]);
	if(owner < 0)
	{
		//owner doesnt exist???
		//suicide.
		//dont bother with coding these annyoing exceptions.
		if(IsValidEntity(Trail))
			RemoveEntity(Trail);
		RemoveEntity(entity);
		return;
	}
			
	//we dont want it to count allies as enemies so we temp set it to false.
	b_NpcIsTeamkiller[entity] = false;
	//we have found a valid target.
	if(IsValidEnemy(entity,target, true, true) 
	&& !IsIn_HitDetectionCooldown(entity,target, Boomerang) 
	&& HitsLeft[entity] > 0)
	{
		//we also want to never try to rehit the same target we already have hit.
		//we found a valid target.

		//Code to do damage position and ragdolls
		static float angles[3];
		GetRocketAngles(entity, angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);

		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);

		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_BULLET, weapon, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?
		if(i_Current_Pap[owner] == 0 || i_Current_Pap[owner] == 3 || i_Current_Pap[owner] == 6)
		{
			EmitSoundToClient(owner, BOOMERANG_HIT_SOUND_WOOD, owner, SNDCHAN_AUTO, 80, _, 1.0, 110);
		}
		else if(i_Current_Pap[owner] == 1 || i_Current_Pap[owner] == 4)
		{
			EmitSoundToClient(owner, BOOMERANG_HIT_SOUND_METAL, owner, SNDCHAN_AUTO, 80, _, 1.0, 110);
		}
		else if(i_Current_Pap[owner] == 2 || i_Current_Pap[owner] == 5)
		{
			EmitSoundToClient(owner, BOOMERANG_HIT_SOUND_METAL, owner, SNDCHAN_AUTO, 80, _, 1.0, 110);
		}
		//it may say "wand" but its just the name, its used for any type of projectile at this point.
		//This is basically like saying a bool got hit and so on, this just saves those massive arrays.
		Set_HitDetectionCooldown(entity, target, FAR_FUTURE, Boomerang);
		if (i_Current_Pap[owner] == 1 && Times_Damage_Got_Reduced[entity] < 4 || i_Current_Pap[owner] == 4 && Times_Damage_Got_Reduced[entity] < 4) //prob an ugly way to reduce damage but idk how else to do it :p
		{
			f_WandDamage[entity] *= 0.7;
			Times_Damage_Got_Reduced[entity] += 1;
		}
		HitsLeft[entity]--;

		if(HitsLeft[entity] > 0 && i_Current_Pap[owner] != 2 && i_Current_Pap[owner] != 5)
		{
			//we can still hit new targets, cycle through the closest enemy!
			int EnemyFound = GetClosestTarget(entity,
			true,
			300.0, //mas distanec of 500 i'd say. | 500 is too much, 300 seems to be the sweet spot, maybe increase to 500 for paragon or final pap
			true,
			false,
			-1, 
			_,
			true, //only targts we can see should be homed to.
			_,
			_,
			true,
			_,
			view_as<Function>(Boomerang_ValidTargetCheck));

			if(!IsValidEntity(EnemyFound))
			{
				//noone was found... return to owner
				HitsLeft[entity] = 0;
			}
			else
			{
				float ang[3];
				GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
				b_ProjectileCollideIgnoreWorld[entity] = true;
				SetEntityMoveType(entity, MOVETYPE_NOCLIP);
				Initiate_HomingProjectile(entity, 
				owner, 
				180.0, 
				180.0, 
				true, 
				true, 
				ang, 
				EnemyFound);
				SetEntityMoveType(entity, MOVETYPE_NOCLIP);
				//make it phase through everything to get to its owner.
			}
		}
		if(HitsLeft[entity] <= 0)
		{
			/*
				we have hit enough targets.... we need to go back without damaging any other targets,
				see above asto why i used HitsLeft[entity] there.
				we want to back to the owner, so just fly towards them.
			*/
			b_ProjectileCollideIgnoreWorld[entity] = true;
			SetEntityMoveType(entity, MOVETYPE_NOCLIP);
			float ang[3];
			GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
			Initiate_HomingProjectile(entity, 
			owner, 
			180.0, 
			180.0, 
			true, 
			true, 
			ang, 
			owner);
		}
		//set it back to true once done so it can get us again.
		b_NpcIsTeamkiller[entity] = true;
		return;
	}
	if(HitsLeft[entity] <= 0 && target == owner)
	{
		//back home!
		if(IsValidEntity(Trail))
			CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(Trail), TIMER_FLAG_NO_MAPCHANGE);

		//Delay deletion for particles to not break.
		WandProjectile_ApplyFunctionToEntity(entity, INVALID_FUNCTION);
		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		SetEntityRenderMode(entity, RENDER_NONE);
		SetEntityMoveType(entity, MOVETYPE_NONE);
		
		//delete extra model aswell
		int extra_index = EntRefToEntIndex(iref_PropAppliedToRocket[entity]);
		if(IsValidEntity(extra_index))
			RemoveEntity(extra_index);

		return;
	}

	if(target == 0)
	{
		/*
			hit world, go back home.
		*/
		b_ProjectileCollideIgnoreWorld[entity] = true;
		SetEntityMoveType(entity, MOVETYPE_NOCLIP);
		HitsLeft[entity] = 0;
		float ang[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
		Initiate_HomingProjectile(entity, 
		owner, 
		180.0, 
		180.0, 
		true, 
		true, 
		ang, 
		owner);
	}

	b_NpcIsTeamkiller[entity] = true;

}

bool Boomerang_ValidTargetCheck(int projectile, int Target)
{
	if(IsIn_HitDetectionCooldown(projectile,Target, Boomerang))
	{
		return false;
		//we have already hit this target, skip.
	}
	return true;
}

static int Boomerang_Get_Pap(int weapon)
{
	int pap=0;
	pap = RoundFloat(Attributes_Get(weapon, 122, 0.0));
	return pap;
}


static void BoomerRangThrow(int client, int weapon, char[] modelstringname = WOODEN_BOOMERANG_MODEL,int hitsleft = 1, float Size = 1.0,float fAngOver[3] = {0.0,0.0,0.0})
{
	float damage = 65.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
	delay_hud[client] = 0.0;

	float speed = 1100.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	speed *= Attributes_Get(weapon, 104, 1.0);

	float time = 2500.0 / speed;
	time *= Attributes_Get(weapon, 101, 1.0);
	time *= Attributes_Get(weapon, 102, 1.0);

	time *= 5.0;
	float fAng[3];
	GetClientEyeAngles(client, fAng);
	if(!AreVectorsEqual(fAngOver, view_as<float>({0.0,0.0,0.0})))
	{
		fAng = fAngOver;
	}

	float fPos[3];
	GetClientEyePosition(client, fPos);

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, -1, weapon, "", fAng, false , fPos);
	WandProjectile_ApplyFunctionToEntity(projectile, Weapon_Boomerang_Touch);
	HitsLeft[projectile] = hitsleft; //only 1 hit allowed
	int trail = Trail_Attach(projectile, ARROW_TRAIL_RED, 255, 0.2, 6.0, 6.0, 5);
	f_ArrowTrailParticle[projectile] = EntIndexToEntRef(trail);

	//store_owner = GetClientUserId(client);
	ApplyCustomModelToWandProjectile(projectile, modelstringname, Size, "");
	b_NpcIsTeamkiller[projectile] = true; //allows self hitting
	Times_Damage_Got_Reduced[projectile] = 0;
}



public void BoomerrangFireMultiple(int client, int weapon, int FireMultiple)
{		
	int FrameDelayAdd = 10;
	float Attackspeed = Attributes_Get(weapon, 6, 1.0);
	Attackspeed *= 0.5;

	FrameDelayAdd = RoundToNearest(float(FrameDelayAdd) * Attackspeed);
	for(int LoopFire ; LoopFire <= FireMultiple; LoopFire++)
	{
		DataPack pack = new DataPack();
		pack.WriteCell(EntIndexToEntRef(client));
		pack.WriteCell(EntIndexToEntRef(weapon));
		if(LoopFire == 0)
			pack.WriteCell(0);
		else
			pack.WriteCell(1);

		if(LoopFire == 0)
			Weapon_Boomerrang_FireInternal(pack);
		else
			RequestFrames(Weapon_Boomerrang_FireInternal, RoundToNearest(float(FrameDelayAdd) * LoopFire), pack);
	}
}
public void Weapon_Boomerrang_FireInternal(DataPack DataDo)
{		
	DataDo.Reset();
	int client = EntRefToEntIndex(DataDo.ReadCell());
	int weapon = EntRefToEntIndex(DataDo.ReadCell());
	bool soundDo = DataDo.ReadCell();
	delete DataDo;

	if(!IsValidEntity(weapon) || !IsValidClient(client))
		return;

	if(soundDo)
		EmitSoundToClient(client, BOOMERANG_FIRE_SOUND, client, SNDCHAN_AUTO, 80, _, 0.8, 110);

	BoomerRangThrow(client, weapon, METAL_BOOMERANG_MODEl, 16, 1.0);
}