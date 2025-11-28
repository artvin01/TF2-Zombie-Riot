#pragma semicolon 1
#pragma newdecls required

static float glitchBaseDMG[MAXPLAYERS] = {1.0, ...};
static float glitchBaseFireRate[MAXPLAYERS] = {1.0, ...};
static float glitchBaseClip[MAXPLAYERS] = {1.0, ...};
static float glitchBaseSpread[MAXPLAYERS] = {1.0, ...};
static float glitchBaseReloadRate[MAXPLAYERS] = {1.0, ...};

public void OnPluginStart_Glitched_Weapon() 
{
	return;
}

public void On_Glitched_Give(int client, int weapon)
{
	if(!Attributes_Has(weapon,731))
	{
		return;
	}
	
	if(Attributes_Has(weapon, 2))
		glitchBaseDMG[client] = Attributes_Get(weapon, 2, 1.0);
	else
		glitchBaseDMG[client] = 1.0;

	if(Attributes_Has(weapon, 6))
		glitchBaseFireRate[client] = Attributes_Get(weapon, 6, 1.0);
	else
		glitchBaseFireRate[client] = 1.0;

		
	if(Attributes_Has(weapon, 4))
		glitchBaseClip[client] = Attributes_Get(weapon, 4, 1.0);
	else
		glitchBaseClip[client] = 1.0;

		
	if(!Attributes_Has(weapon, 106))
		glitchBaseSpread[client] = Attributes_Get(weapon, 106, 1.0);
	else
		glitchBaseSpread[client] = 1.0;

		
	if(!Attributes_Has(weapon, 97))
		glitchBaseReloadRate[client] = Attributes_Get(weapon, 97, 1.0);
	else
		glitchBaseReloadRate[client] = 1.0;
}

public void Glitched_Attack(int client, int weapon, bool crit)
{
	if(Attributes_Has(weapon,298))
	{
		if (RoundToCeil(Attributes_Get(weapon, 298, 1.0))!=24.0)
		{
			int clip = GetEntProp(weapon, Prop_Data, "m_iClip1");
			if(clip>=4)
				Attributes_Set(weapon, 298, GetRandomInt(0,2)*1.0); // Ammo per shot
			else
				Attributes_Set(weapon, 298, 1.0);	// prevent being stuck (rare but can happen)
			
			int ammoType = (GetAmmoType_WeaponPrimary(weapon));
			if (ammoType!=-1)
			{
				if(clip>=4)
					SetEntProp(client, Prop_Data, "m_iAmmo", GetRandomInt(-999999, 999999), _, ammoType);
				else
					SetEntProp(client, Prop_Data, "m_iAmmo", GetRandomInt(50, 999999), _, ammoType);
			}
		}
		else
		{
			int ammoType = (GetAmmoType_WeaponPrimary(weapon));
			if (ammoType!=-1)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", GetRandomInt(50, 999999), _, ammoType);
			}
		}
	}
}

public void Glitched_Reload(int client, int weapon, const char[] classname)
{
	Rogue_OnAbilityUse(client, weapon);
	switch(GetRandomInt(0,10))
	{
		// high dmg but slow firerate
		case 2:
		{
			Attributes_Set(weapon, 2, glitchBaseDMG[client]*1.3); // dmg
			Attributes_Set(weapon, 6, glitchBaseFireRate[client]*1.2); // fire rate
			Attributes_Set(weapon, 4, glitchBaseClip[client]); // clip size
			Attributes_Set(weapon, 413, 0.0); // autofire shot (prevent weapon switch)
			Attributes_Set(weapon, 106, 0.5); // spread
			Attributes_Set(weapon, 45, 1.0);  // bullet per shot
			Attributes_Set(weapon, 298, 1.0); // Ammo per shot
			Attributes_Set(weapon, 97, glitchBaseReloadRate[client]); // Reload rate
			
			ClientCommand(client, "playgamesound items/powerup_pickup_base.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Code error: H34Vy gUN");
		}
		
		// high firerate + precision but cannot switch weapon
		case 4:
		{
			Attributes_Set(weapon, 2, glitchBaseDMG[client]); // dmg
			Attributes_Set(weapon, 6, glitchBaseFireRate[client]*0.5); // fire rate
			Attributes_Set(weapon, 4, glitchBaseClip[client]*2); // clip size
			Attributes_Set(weapon, 413, 1.0); // autofire shot (prevent weapon switch)
			Attributes_Set(weapon, 106, 0.01); // spread
			Attributes_Set(weapon, 45, 1.0);  // bullet per shot
			Attributes_Set(weapon, 298, 1.0); // Ammo per shot
			Attributes_Set(weapon, 97, glitchBaseReloadRate[client]); // Reload rate
			
			ClientCommand(client, "playgamesound items/powerup_pickup_haste.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Code error: H4a444A444");
		}
		
		
		// all in (1 shot with high dmg + low reload speed)
		case 6:
		{
			Attributes_Set(weapon, 2, glitchBaseDMG[client]*(glitchBaseClip[client]*12)); // dmg
			Attributes_Set(weapon, 6, glitchBaseFireRate[client]); // fire rate
			Attributes_Set(weapon, 4, glitchBaseClip[client]); // clip size
			Attributes_Set(weapon, 413, 0.0); // autofire shot (prevent weapon switch)
			Attributes_Set(weapon, 106, 0.5); // spread
			Attributes_Set(weapon, 45, 1.0);  // bullet per shot
			Attributes_Set(weapon, 298, 24.0); // Ammo per shot
			Attributes_Set(weapon, 97, glitchBaseReloadRate[client]*1.5); // Reload rate
			
			ClientCommand(client, "playgamesound items/powerup_pickup_king.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Code error: 411 iN");
		}
		
		// more bullet less dmg
		case 8:
		{
			Attributes_Set(weapon, 2, glitchBaseDMG[client]/(glitchBaseClip[client]-3)); // dmg
			Attributes_Set(weapon, 6, glitchBaseFireRate[client]); // fire rate
			Attributes_Set(weapon, 4, glitchBaseClip[client]); // clip size
			Attributes_Set(weapon, 413, 0.0); // autofire shot (prevent weapon switch)
			Attributes_Set(weapon, 106, 1.5); // spread
			Attributes_Set(weapon, 45, 20.0);  // bullet per shot
			Attributes_Set(weapon, 298, 1.0); // Ammo per shot
			Attributes_Set(weapon, 97, glitchBaseReloadRate[client]); // Reload rate
			
			ClientCommand(client, "playgamesound items/powerup_pickup_regeneration.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Code error: 5Pr34d");
		}
		
		default:
		{
			Attributes_Set(weapon, 2, glitchBaseDMG[client]); // dmg
			Attributes_Set(weapon, 6, glitchBaseFireRate[client]); // fire rate
			Attributes_Set(weapon, 4, glitchBaseClip[client]); // clip size
			Attributes_Set(weapon, 413, 0.0); // autofire shot (prevent weapon switch)
			Attributes_Set(weapon, 106, 0.5); // spread
			Attributes_Set(weapon, 45, 1.0);  // bullet per shot
			Attributes_Set(weapon, 298, 1.0); // Ammo per shot
			Attributes_Set(weapon, 96, glitchBaseReloadRate[client]); // Reload rate
		}
	}
	int ammoType = (GetAmmoType_WeaponPrimary(weapon));
	if (ammoType!=-1)
	{
		SetEntProp(client, Prop_Data, "m_iAmmo", GetRandomInt(50, 999999), _, ammoType);
	}
}


public void Glitched_Attack2(int client, int weapon, bool crit)
{
	if(Attributes_Has(weapon,298))
	{
		if (RoundToCeil(Attributes_Get(weapon, 298, 1.0))!=24.0)
		{
			int clip = GetEntProp(weapon, Prop_Data, "m_iClip1");
			if(clip>=4)
				Attributes_Set(weapon, 298, GetRandomInt(0,2)*1.0); // Ammo per shot
			else
				Attributes_Set(weapon, 298, 1.0);	// prevent being stuck (rare but can happen)
			
			int ammoType = (GetAmmoType_WeaponPrimary(weapon));
			if (ammoType!=-1)
			{
				if(clip>=4)
					SetEntProp(client, Prop_Data, "m_iAmmo", GetRandomInt(-999999, 999999), _, ammoType);
				else
					SetEntProp(client, Prop_Data, "m_iAmmo", GetRandomInt(50, 999999), _, ammoType);
			}
		}
		else
		{
			int ammoType = (GetAmmoType_WeaponPrimary(weapon));
			if (ammoType!=-1)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", GetRandomInt(50, 999999), _, ammoType);
			}
		}
	}
	
	if(!Attributes_Has(weapon,298))
		return;
	
	float typeProjectile = Attributes_Get(weapon, 298, 1.0);
	if (typeProjectile == 1.0)
		return; 

	if(!Attributes_Has(weapon, 45))
		return;
	
	int numberProjectile = RoundToCeil(Attributes_Get(weapon, 45, 1.0));
	if (numberProjectile==1.0)
		return;
		
	float dmgProjectile = 12.0;
	
	dmgProjectile *= Attributes_Get(weapon, 2, 1.0);
	
	float positiveAngleModifier = 3.0;
		
	positiveAngleModifier *= Attributes_Get(weapon, 106, 1.0);
	
	
	float fAng[3], fPos[3];
	GetClientEyeAngles(client, fAng);
	GetClientEyePosition(client, fPos);
	
	float negativeAngleModifier = positiveAngleModifier*-1.0;
	
	for (int numberP = 0; numberP < numberProjectile - 1; numberP++)
	{
		float nfAng[3], nfPos[3];
		nfPos[0] = fPos[0] + GetRandomFloat(-1.0, 1.0);
		nfPos[1] = fPos[1] + GetRandomFloat(-1.0, 1.0);
		nfPos[2] = fPos[2];
	
		nfAng[0] = fAng[0] + GetRandomFloat(negativeAngleModifier, positiveAngleModifier);
		nfAng[1] = fAng[1] + GetRandomFloat(negativeAngleModifier, positiveAngleModifier);
		nfAng[2] = fAng[2];
		
		float vBuffer[3];
		GetAngleVectors(nfAng, vBuffer, NULL_VECTOR, NULL_VECTOR);
		
		float speedMult = 1100.0;
		
		if (typeProjectile==6.0)
				speedMult *= 2.0;
				
		vBuffer[0] *= speedMult;
		vBuffer[1] *= speedMult;
		vBuffer[2] *= speedMult;
		
		int projectile = -1;
		
		switch(typeProjectile)
		{
			case 2.0: projectile = CreateEntityByName("tf_projectile_rocket");
			case 6.0: projectile = CreateEntityByName("tf_projectile_flare");
			case 5.0: projectile = CreateEntityByName("tf_projectile_syringe");
		}
		
			
		if(IsValidEntity(projectile))
		{
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
			
			if (typeProjectile!=5.0)
				SetEntProp(projectile, Prop_Send, "m_bCritical", false);
		}
	}
}


public void Glitched_Reload2(int client, int weapon, const char[] classname)
{
	// bool normalBullets = false;
	Rogue_OnAbilityUse(client, weapon);
	
	switch(GetRandomInt(0,6))
	{
		case 1:
		{
			Attributes_Set(weapon, 280, 2.0); // Rocket
		}
		
		case 3:
		{
			Attributes_Set(weapon, 280, 5.0); // Syringe
		}
		
		case 5:
		{
			Attributes_Set(weapon, 280, 6.0); // Flare
		}
		
		default:
		{
			Attributes_Set(weapon, 280, 1.0); // Normal
			// normalBullets = true;
		}
	}
	
	float bulletPerShot = GetRandomInt(-2, 2) * 1.0;
	if (bulletPerShot<1.0)
		bulletPerShot = 1.0;
	
	float shotAll = 0.0;
	if (GetRandomInt(0, 5)==3)
		shotAll = 1.0;
	
	Attributes_Set(weapon, 2, (glitchBaseDMG[client]*GetRandomFloat(0.5,2.5))/bulletPerShot); // dmg
	Attributes_Set(weapon, 6, glitchBaseFireRate[client]*GetRandomFloat(0.70,1.25)); // fire rate
	Attributes_Set(weapon, 4, glitchBaseClip[client]*GetRandomFloat(0.5,2.0)); // clip size
	Attributes_Set(weapon, 413, shotAll); // autofire shot (prevent weapon switch)
	Attributes_Set(weapon, 106, GetRandomFloat(0.25,1.25)); // spread
	Attributes_Set(weapon, 45, bulletPerShot);  // bullet per shot
	Attributes_Set(weapon, 298, 1.0); // Ammo per shot
	Attributes_Set(weapon, 96, glitchBaseReloadRate[client]*GetRandomFloat(0.5,1.5)); // Reload rate
	
	
	int ammoType = (GetAmmoType_WeaponPrimary(weapon));
	if (ammoType!=-1)
	{
		SetEntProp(client, Prop_Data, "m_iAmmo", GetRandomInt(50, 999999), _, ammoType);
	}
}