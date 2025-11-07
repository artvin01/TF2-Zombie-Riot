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
static int Glaives_Currently_Shot[MAXPLAYERS+1] = {0, ...};
static int ability_timer_times_repeated[MAXPLAYERS+1] = {0, ...};
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
	PrintToChatAll("Current pap [%d]", i_Current_Pap[client]);
	switch (i_Current_Pap[client])
	{
		case 0: //base pap
		{
			if (Glaives_Currently_Shot[client] == 0)
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

				float fPos[3];
				GetClientEyePosition(client, fPos);

				int projectile = Wand_Projectile_Spawn(client, speed, time, damage, -1, weapon, "", fAng, false , fPos);
				WandProjectile_ApplyFunctionToEntity(projectile, Weapon_Boomerang_Touch);
				HitsLeft[projectile] = 1; //only 1 hit allowed

				//store_owner = GetClientUserId(client);
				ApplyCustomModelToWandProjectile(projectile, WOODEN_BOOMERANG_MODEL, 1.0, "");
				b_NpcIsTeamkiller[projectile] = true; //allows self hitting
				Glaives_Currently_Shot[client] += 1;
				
			}
			else
			{
				ShowSyncHudText(client,  SyncHud_Notifaction, "No Boomerangs available");
			}
		}
		case 1: //Whirling Blade
		{
			if (Glaives_Currently_Shot[client] == 0)
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

				float fPos[3];
				GetClientEyePosition(client, fPos);

				int projectile = Wand_Projectile_Spawn(client, speed, time, damage, -1, weapon, "", fAng, false , fPos);
				WandProjectile_ApplyFunctionToEntity(projectile, Weapon_Boomerang_Touch);

				HitsLeft[projectile] = 7; //7 hits allowed

				ApplyCustomModelToWandProjectile(projectile, METAL_BOOMERANG_MODEl, 1.0, "");
				b_NpcIsTeamkiller[projectile] = true; //allows self hitting
				Glaives_Currently_Shot[client] += 1;
				Times_Damage_Got_Reduced[projectile] = 0;
			}
			else
			{
				ShowSyncHudText(client,  SyncHud_Notifaction, "No Boomerangs available");
			}
		}
		case 2: //Kylie Boomerang
		{
			if (Glaives_Currently_Shot[client] == 0)
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

				float fPos[3];
				GetClientEyePosition(client, fPos);

				int projectile = Wand_Projectile_Spawn(client, speed, time, damage, -1, weapon, "", fAng, false , fPos);
				WandProjectile_ApplyFunctionToEntity(projectile, Weapon_Boomerang_Touch);

				HitsLeft[projectile] = 5; //only 1 hit allowed

				ApplyCustomModelToWandProjectile(projectile, WOODEN_BOOMERANG_MODEL, 1.45, "");
				b_NpcIsTeamkiller[projectile] = true; //allows self hitting
				Glaives_Currently_Shot[client] += 1;
			}
			else
			{
				ShowSyncHudText(client,  SyncHud_Notifaction, "No Boomerangs available");
			}
		}
		case 3: //Whirlwind Rang
		{
			if (Glaives_Currently_Shot[client] <= 1)
			{
				float damage = 65.0;
				damage *= Attributes_Get(weapon, 2, 1.0);
				delay_hud[client] = 0.0;

				float speed = 1500.0;
				speed *= Attributes_Get(weapon, 103, 1.0);
				speed *= Attributes_Get(weapon, 104, 1.0);

				float time = 3000.0 / speed;
				time *= Attributes_Get(weapon, 101, 1.0);
				time *= Attributes_Get(weapon, 102, 1.0);

				float fAng[3];
				GetClientEyeAngles(client, fAng);

				float fPos[3];
				GetClientEyePosition(client, fPos);

				for (int i = 1; i <= 2; i++)
				{
					//fAng[2] += GetRandomFloat(-7.0, 7.0);//changes horizontal, can use this to fix the sawblade model from tf2
					if (i == 1)
					{
						fAng[1] += 5.0;
					}
					else if(i == 2)
					{
						fAng[1] -= 10.0;//double the last one so it doesnt just come back to 0
					}
					int projectile = Wand_Projectile_Spawn(client, speed, time, damage, -1, weapon, "", fAng, false , fPos);
					WandProjectile_ApplyFunctionToEntity(projectile, Weapon_Boomerang_Touch);
					ApplyCustomModelToWandProjectile(projectile, WOODEN_BOOMERANG_MODEL, 1.0, "");
					b_NpcIsTeamkiller[projectile] = true; //allows self hitting
					HitsLeft[projectile] = 1; //only 1 hit allowed
					Glaives_Currently_Shot[client] += 1;
				}
			}
			else
			{
				ShowSyncHudText(client,  SyncHud_Notifaction, "No Boomerangs available");
			}
		}
		case 4: //Glaive Lord
		{
			if (Glaives_Currently_Shot[client] <= 1)// 2 projectiles active at once
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

				float fPos[3];
				GetClientEyePosition(client, fPos);

				int projectile = Wand_Projectile_Spawn(client, speed, time, damage, -1, weapon, "", fAng, false , fPos);
				WandProjectile_ApplyFunctionToEntity(projectile, Weapon_Boomerang_Touch);

				HitsLeft[projectile] = 16; //funi

				ApplyCustomModelToWandProjectile(projectile, METAL_BOOMERANG_MODEl, 1.0, "");
				b_NpcIsTeamkiller[projectile] = true; //allows self hitting
				Glaives_Currently_Shot[client] += 1;
				Times_Damage_Got_Reduced[projectile] = 0;
			}
			else
			{
				ShowSyncHudText(client,  SyncHud_Notifaction, "No Boomerangs available");
			}
		}
		case 5: //Nightmare
		{
			if (Glaives_Currently_Shot[client] == 0)
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
				fAng[2] += 90.0;

				float fPos[3];
				GetClientEyePosition(client, fPos);

				int projectile = Wand_Projectile_Spawn(client, speed, time, damage, -1, weapon, "", fAng, false , fPos);
				WandProjectile_ApplyFunctionToEntity(projectile, Weapon_Boomerang_Touch);

				HitsLeft[projectile] = 8; //8 hits allowed

				ApplyCustomModelToWandProjectile(projectile, LARGE_METAL_BOOMERANG_MODEL, 0.5, "");
				b_NpcIsTeamkiller[projectile] = true; //allows self hitting
				Glaives_Currently_Shot[client] += 1;
				Times_Damage_Got_Reduced[projectile] = 0;
			}
			else
			{
				ShowSyncHudText(client,  SyncHud_Notifaction, "No Boomerangs available");
			}
		}
		case 6: //Sunswallower
		{
			if (Glaives_Currently_Shot[client] == 0)
			{
				float damage = 65.0;
				damage *= Attributes_Get(weapon, 2, 1.0);
				delay_hud[client] = 0.0;

				float speed = 1100.0;
				speed *= Attributes_Get(weapon, 103, 1.0);
				speed *= Attributes_Get(weapon, 104, 1.0);

				float time = 1700.0 / speed;
				time *= Attributes_Get(weapon, 101, 1.0);
				time *= Attributes_Get(weapon, 102, 1.0);

				float fAng[3];
				GetClientEyeAngles(client, fAng);

				float fPos[3];
				GetClientEyePosition(client, fPos);

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
					int projectile = Wand_Projectile_Spawn(client, speed, time, damage, -1, weapon, "", fAng, false , fPos);
					WandProjectile_ApplyFunctionToEntity(projectile, Weapon_Boomerang_Touch);
					ApplyCustomModelToWandProjectile(projectile, WOODEN_BOOMERANG_MODEL, 1.0, "");
					b_NpcIsTeamkiller[projectile] = true; //allows self hitting
					HitsLeft[projectile] = 1; //only 1 hit allowed
					Glaives_Currently_Shot[client] += 1;
				}
			}
			else
			{
				ShowSyncHudText(client,  SyncHud_Notifaction, "No Boomerangs available");
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
			CreateTimer(0.1, Timer_Multiple_Boomerangs, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			ability_timer_times_repeated[client] = 0;
		}
	}
}

public Action Timer_Multiple_Boomerangs(Handle timer, int client)
{
	if (ability_timer_times_repeated[client] >= 5)
	{
		return Plugin_Stop;
	}
	else
	{
		ability_timer_times_repeated[client] += 1;
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		float damage = 65.0;
		damage *= Attributes_Get(weapon, 2, 1.0);
		delay_hud[client] = 0.0;

		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		speed *= Attributes_Get(weapon, 104, 1.0);

		float time = 800.0 / speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		time *= Attributes_Get(weapon, 102, 1.0);

		float fAng[3];
		GetClientEyeAngles(client, fAng);

		float fPos[3];
		GetClientEyePosition(client, fPos);
		for (int i = 1; i <= 3; i++)//each call fires 3 projectiles
			{
				GetClientEyeAngles(client, fAng);
				fAng[0] += GetRandomFloat(-9.0, 9.0); //vertical spread
				fAng[1] += GetRandomFloat(-9.0, 9.0);
				fAng[2] += GetRandomFloat(-45.0, 45.0); //projectile spin
				//fAng[2] += GetRandomFloat(-7.0, 7.0);//changes horizontal, can use this to fix the sawblade model from tf2
				int projectile = Wand_Projectile_Spawn(client, speed, time, damage, -1, weapon, "", fAng, false , fPos);
				WandProjectile_ApplyFunctionToEntity(projectile, Weapon_Boomerang_Touch);
				ApplyCustomModelToWandProjectile(projectile, WOODEN_BOOMERANG_MODEL, 1.0, "");
				b_NpcIsTeamkiller[projectile] = true; //allows self hitting
				HitsLeft[projectile] = 1; //only 1 hit allowed
			}
		EmitSoundToClient(client, "player/taunt_jackhammer_down_swoosh.wav", client, SNDCHAN_AUTO, 80, _, 1.0, 110);
	}
	return Plugin_Continue;
}

public void Weapon_Boomerang_Touch(int entity, int target)
{
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if(owner < 0)
	{
		//owner doesnt exist???
		//suicide.
		//dont bother with coding these annyoing exceptions.
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
			PrintToChatAll("wood Sound");
			EmitSoundToClient(owner, BOOMERANG_HIT_SOUND_WOOD, owner, SNDCHAN_AUTO, 80, _, 1.0, 110);
		}
		else if(i_Current_Pap[owner] == 1 || i_Current_Pap[owner] == 4)
		{
			PrintToChatAll("metal Sound");
			EmitSoundToClient(owner, BOOMERANG_HIT_SOUND_METAL, owner, SNDCHAN_AUTO, 80, _, 1.0, 110);
		}
		else if(i_Current_Pap[owner] == 2 || i_Current_Pap[owner] == 5)
		{
			PrintToChatAll("metal Sound");
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
		RemoveEntity(entity);
		Glaives_Currently_Shot[owner] -= 1;
		if(Glaives_Currently_Shot[owner] < 0)
		{
			Glaives_Currently_Shot[owner] = 0;
		}
		return;
	}

	if(target == 0)
	{
		/*
			hit world, go back home.
		*/
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

public void Weapon_Boomerang_TempFix(int client, int weapon, bool crit)
{
	Glaives_Currently_Shot[client] = 0;
}