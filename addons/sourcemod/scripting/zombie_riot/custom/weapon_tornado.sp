#pragma semicolon 1
#pragma newdecls required

static float fl_tornados_rockets_eated[MAXPLAYERS+1]={0.0, ...};
static int g_ProjectileModel;

public void Weapon_Tornado_Blitz_Precache()	//we use a custom model for the spam launcher to reduce clutter on screen.
{
	static char model[PLATFORM_MAX_PATH];
	model = "models/weapons/w_bullet.mdl";
	g_ProjectileModel = PrecacheModel(model);
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
		/*if(!TF2_IsPlayerInCondition(client, TFCond_RuneHaste))	//keeping this here incase haste with the launcher is a "bit" busted.
		{
			static float anglesB[3];
			GetClientEyeAngles(client, anglesB);
			static float velocity[3];
			GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(velocity, -350.0);
			if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
				velocity[2] = fmax(velocity[2], 250.0);
			else
				velocity[2] += 100.0; // a little boost to alleviate arcing issues
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
		}*/
		
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
			
		float positiveAngleModifier = 1.0;
		
		
		address = TF2Attrib_GetByDefIndex(weapon, 106);
		if(address != Address_Null)
			positiveAngleModifier *= TF2Attrib_GetValue(address);
		float fAng[3], fPos[3];
		
		GetClientEyeAngles(client, fAng);
		GetClientEyePosition(client, fPos);
	
		float nfAng[3], nfPos[3];
		float temp=GetRandomFloat(-10.0, 10.0);
		
		if(temp>0.0)
		{
			temp-positiveAngleModifier;
			if(temp<0.0)
				temp=0.0;
		}
		else
		{
			temp+positiveAngleModifier;
			if(temp>0.0)
				temp=0.0;
		}
		nfPos[0] = fPos[0]+temp;
		
		temp=GetRandomFloat(-10.0, 10.0);
		
		if(temp>0.0)
		{
			temp-positiveAngleModifier;
			if(temp<0.0)
				temp=0.0;
		}
		else
		{
			temp+positiveAngleModifier;
			if(temp>0.0)
				temp=0.0;
		}
		nfPos[1] = fPos[1]+temp;

		nfPos[2] = fPos[2];
	
		nfAng[0] = fAng[0];
		nfAng[1] = fAng[1];
		nfAng[2] = fAng[2];
		
		float vBuffer[3];
		GetAngleVectors(nfAng, vBuffer, NULL_VECTOR, NULL_VECTOR);
				
		vBuffer[0] *= speedMult;
		vBuffer[1] *= speedMult;
		vBuffer[2] *= speedMult;
		
		int projectile = -1;
		
		projectile = CreateEntityByName("tf_projectile_rocket");
				
		if(IsValidEntity(projectile))
		{
			b_RocketBoomEffect[projectile]=true;	//Removes explosion particles/sound.
			
			SetVariantInt(GetClientTeam(client));
			AcceptEntityInput(projectile, "TeamNum");
			SetVariantInt(GetClientTeam(client));
			AcceptEntityInput(projectile, "SetTeam"); 
			
			TeleportEntity(projectile, nfPos, nfAng, vBuffer);
			DispatchSpawn(projectile);
			TeleportEntity(projectile, nfPos, nfAng, vBuffer);
			
			SetEntPropEnt(projectile, Prop_Send, "m_hOwnerEntity",client);	
			SetEntityCollisionGroup(projectile, 27);
			SetEntDataFloat(projectile, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, dmgProjectile, true);	// Damage
			SetEntPropEnt(projectile, Prop_Send, "m_hOriginalLauncher", weapon);
			SetEntPropEnt(projectile, Prop_Send, "m_hLauncher", weapon);
			for(int i; i<4; i++)
			{
				SetEntProp(projectile, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModel, _, i);
			}
			SetEntPropFloat(projectile, Prop_Send, "m_flModelScale", 3.0);
		}
	}
}