#pragma semicolon 1
#pragma newdecls required

static float fl_tornados_rockets_eated[MAXPLAYERS+1]={0.0, ...};

#define SOUND_IMPACT_1 					"physics/flesh/flesh_impact_bullet1.wav"	//We hit flesh, we are also kinetic, yes.
#define SOUND_IMPACT_2 					"physics/flesh/flesh_impact_bullet2.wav"
#define SOUND_IMPACT_3 					"physics/flesh/flesh_impact_bullet3.wav"
#define SOUND_IMPACT_4 					"physics/flesh/flesh_impact_bullet4.wav"
#define SOUND_IMPACT_5 					"physics/flesh/flesh_impact_bullet5.wav"

#define SOUND_IMPACT_CONCRETE_1			"physics/concrete/concrete_impact_bullet1.wav"//we hit the ground? HOW DARE YOU MISS?
#define SOUND_IMPACT_CONCRETE_2 		"physics/concrete/concrete_impact_bullet2.wav"
#define SOUND_IMPACT_CONCRETE_3 		"physics/concrete/concrete_impact_bullet3.wav"
#define SOUND_IMPACT_CONCRETE_4 		"physics/concrete/concrete_impact_bullet4.wav"

public void Weapon_Tornado_Blitz_Precache()
{
	PrecacheSound(SOUND_IMPACT_CONCRETE_1);
	PrecacheSound(SOUND_IMPACT_CONCRETE_2);
	PrecacheSound(SOUND_IMPACT_CONCRETE_3);
	PrecacheSound(SOUND_IMPACT_CONCRETE_4);
	
	PrecacheSound(SOUND_IMPACT_1);
	PrecacheSound(SOUND_IMPACT_2);
	PrecacheSound(SOUND_IMPACT_3);
	PrecacheSound(SOUND_IMPACT_4);
	PrecacheSound(SOUND_IMPACT_5);
}

public void Weapon_tornado_launcher_Spam(int client, int weapon, const char[] classname, bool &result)
{
	if(fl_tornados_rockets_eated[client]>3.0)	//Every 3rd rocket is free. or there abouts.
	{
		Add_Back_One_Rocket(weapon);
		fl_tornados_rockets_eated[client]=-3.0;
	}
	else
	{
		fl_tornados_rockets_eated[client]+=1.25;
	}
	Weapon_Tornado_Launcher_Spam_Fire_Rocket(client, weapon);
}

public void Weapon_tornado_launcher_Spam_Pap1(int client, int weapon, const char[] classname, bool &result)
{
	if(fl_tornados_rockets_eated[client]<0.49)	//2 rockets eated, 1 free.
	{
		Add_Back_One_Rocket(weapon);
		fl_tornados_rockets_eated[client]++;
	}
	else
	{
		fl_tornados_rockets_eated[client]-=0.5;
	}
	Weapon_Tornado_Launcher_Spam_Fire_Rocket(client, weapon);
}

public void Weapon_tornado_launcher_Spam_Pap2(int client, int weapon, const char[] classname, bool &result)
{
	if(fl_tornados_rockets_eated[client]<1.0)	//Half rockets eated, other half free
	{
		Add_Back_One_Rocket(weapon);
		fl_tornados_rockets_eated[client]++;
	}
	else
	{
		fl_tornados_rockets_eated[client]=0.0;
	}
	Weapon_Tornado_Launcher_Spam_Fire_Rocket(client, weapon);
}

public void Weapon_tornado_launcher_Spam_Pap3(int client, int weapon, const char[] classname, bool &result)
{
	if(fl_tornados_rockets_eated[client]<2.0)	//4x clip size, basically, most of it being free.
	{
		Add_Back_One_Rocket(weapon);
		fl_tornados_rockets_eated[client]++;
	}
	else
	{
		fl_tornados_rockets_eated[client]=0.0;
	}
	Weapon_Tornado_Launcher_Spam_Fire_Rocket(client, weapon);
}

void Add_Back_One_Rocket(int entity)
{
	if(IsValidEntity(entity))
	{
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		int ammo = GetEntData(entity, iAmmoTable, 4);
		ammo += 1;

		SetEntData(entity, iAmmoTable, ammo, 4, true);
	}
}
void Weapon_Tornado_Launcher_Spam_Fire_Rocket(int client, int weapon)
{
	if(weapon >= MaxClients)
	{
		
		float speedMult = 1250.0;
		float dmgProjectile = 100.0;
		
		
		//note: redo attributes for better customizability
		Address address = TF2Attrib_GetByDefIndex(weapon, 2);
		if(address != Address_Null)
			dmgProjectile *= TF2Attrib_GetValue(address);
			
		address = TF2Attrib_GetByDefIndex(weapon, 103);
		if(address != Address_Null)
			speedMult *= TF2Attrib_GetValue(address);
		
		address = TF2Attrib_GetByDefIndex(weapon, 104);
		if(address != Address_Null)
			speedMult *= TF2Attrib_GetValue(address);
		
		address = TF2Attrib_GetByDefIndex(weapon, 475);
		if(address != Address_Null)
			speedMult *= TF2Attrib_GetValue(address);
			
		float damage=dmgProjectile;
		
		float time = 10.0; //Eternal life, muhahahaha
			
		Wand_Projectile_Spawn(client, speedMult, time, damage, 11/*Tornado Blitz*/, weapon, "teleporter_arms_circle_red" , _ , true);
	}
}
public void Gun_Tornado_Blitz_Touch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
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

		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_BULLET, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position);	// 2048 is DMG_NOGIB?
		switch(GetRandomInt(1,5)) 
		{
			case 1:EmitSoundToAll(SOUND_IMPACT_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 2:EmitSoundToAll(SOUND_IMPACT_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 3:EmitSoundToAll(SOUND_IMPACT_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_IMPACT_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 5:EmitSoundToAll(SOUND_IMPACT_5, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
	   	}

		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		switch(GetRandomInt(1,4)) 
		{
			case 1:EmitSoundToAll(SOUND_IMPACT_CONCRETE_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 2:EmitSoundToAll(SOUND_IMPACT_CONCRETE_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 3:EmitSoundToAll(SOUND_IMPACT_CONCRETE_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_IMPACT_CONCRETE_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
		}
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
}