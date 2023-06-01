#pragma semicolon 1
#pragma newdecls required

static float glitchBaseDMG[MAXTF2PLAYERS] = {1.0, ...};
static float glitchBaseFireRate[MAXTF2PLAYERS] = {1.0, ...};
static float glitchBaseClip[MAXTF2PLAYERS] = {1.0, ...};
static float glitchBaseSpread[MAXTF2PLAYERS] = {1.0, ...};
static float glitchBaseReloadRate[MAXTF2PLAYERS] = {1.0, ...};

public void OnPluginStart_Glitched_Weapon() 
{
	return;
}

public void On_Glitched_Give(int client, int weapon)
{
	Address address = TF2Attrib_GetByDefIndex(weapon, 731);
	if (address == Address_Null)
		return;
	
	
	address = TF2Attrib_GetByDefIndex(weapon, 2);
	if(address != Address_Null)
		glitchBaseDMG[client] = TF2Attrib_GetValue(address);
	else
		glitchBaseDMG[client] = 1.0;
		
	address = TF2Attrib_GetByDefIndex(weapon, 6);
	if(address != Address_Null)
		glitchBaseFireRate[client] = TF2Attrib_GetValue(address);
	else
		glitchBaseFireRate[client] = 1.0;
		
	address = TF2Attrib_GetByDefIndex(weapon, 4);
	if(address != Address_Null)
		glitchBaseClip[client] = TF2Attrib_GetValue(address);
	
	address = TF2Attrib_GetByDefIndex(weapon, 106);
	if(address != Address_Null)
		glitchBaseSpread[client] = TF2Attrib_GetValue(address);
	
	address = TF2Attrib_GetByDefIndex(weapon, 97);
	if(address != Address_Null)
		glitchBaseReloadRate[client] = TF2Attrib_GetValue(address);
	else
		glitchBaseReloadRate[client] = 1.0;
}

public void Glitched_Attack(int client, int weapon, bool crit)
{
	Address address = TF2Attrib_GetByDefIndex(weapon, 298);
	if(address != Address_Null)
	{
		if (RoundToCeil(TF2Attrib_GetValue(address))!=24.0)
		{
			int clip = GetEntProp(weapon, Prop_Data, "m_iClip1");
			if(clip>=4)
				TF2Attrib_SetByDefIndex(weapon, 298, GetRandomInt(0,2)*1.0); // Ammo per shot
			else
				TF2Attrib_SetByDefIndex(weapon, 298, 1.0);	// prevent being stuck (rare but can happen)
			
			int ammoType = (GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType"));
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
			int ammoType = (GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType"));
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
			TF2Attrib_SetByDefIndex(weapon, 2, glitchBaseDMG[client]*1.3); // dmg
			TF2Attrib_SetByDefIndex(weapon, 6, glitchBaseFireRate[client]*1.2); // fire rate
			TF2Attrib_SetByDefIndex(weapon, 4, glitchBaseClip[client]); // clip size
			TF2Attrib_SetByDefIndex(weapon, 413, 0.0); // autofire shot (prevent weapon switch)
			TF2Attrib_SetByDefIndex(weapon, 106, 0.5); // spread
			TF2Attrib_SetByDefIndex(weapon, 45, 1.0);  // bullet per shot
			TF2Attrib_SetByDefIndex(weapon, 298, 1.0); // Ammo per shot
			TF2Attrib_SetByDefIndex(weapon, 97, glitchBaseReloadRate[client]); // Reload rate
			
			ClientCommand(client, "playgamesound items/powerup_pickup_base.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Code error: H34Vy gUN");
		}
		
		// high firerate + precision but cannot switch weapon
		case 4:
		{
			TF2Attrib_SetByDefIndex(weapon, 2, glitchBaseDMG[client]); // dmg
			TF2Attrib_SetByDefIndex(weapon, 6, glitchBaseFireRate[client]*0.5); // fire rate
			TF2Attrib_SetByDefIndex(weapon, 4, glitchBaseClip[client]*2); // clip size
			TF2Attrib_SetByDefIndex(weapon, 413, 1.0); // autofire shot (prevent weapon switch)
			TF2Attrib_SetByDefIndex(weapon, 106, 0.01); // spread
			TF2Attrib_SetByDefIndex(weapon, 45, 1.0);  // bullet per shot
			TF2Attrib_SetByDefIndex(weapon, 298, 1.0); // Ammo per shot
			TF2Attrib_SetByDefIndex(weapon, 97, glitchBaseReloadRate[client]); // Reload rate
			
			ClientCommand(client, "playgamesound items/powerup_pickup_haste.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Code error: H4a444A444");
		}
		
		
		// all in (1 shot with high dmg + low reload speed)
		case 6:
		{
			TF2Attrib_SetByDefIndex(weapon, 2, glitchBaseDMG[client]*(glitchBaseClip[client]*12)); // dmg
			TF2Attrib_SetByDefIndex(weapon, 6, glitchBaseFireRate[client]); // fire rate
			TF2Attrib_SetByDefIndex(weapon, 4, glitchBaseClip[client]); // clip size
			TF2Attrib_SetByDefIndex(weapon, 413, 0.0); // autofire shot (prevent weapon switch)
			TF2Attrib_SetByDefIndex(weapon, 106, 0.5); // spread
			TF2Attrib_SetByDefIndex(weapon, 45, 1.0);  // bullet per shot
			TF2Attrib_SetByDefIndex(weapon, 298, 24.0); // Ammo per shot
			TF2Attrib_SetByDefIndex(weapon, 97, glitchBaseReloadRate[client]*1.5); // Reload rate
			
			ClientCommand(client, "playgamesound items/powerup_pickup_king.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Code error: 411 iN");
		}
		
		// more bullet less dmg
		case 8:
		{
			TF2Attrib_SetByDefIndex(weapon, 2, glitchBaseDMG[client]/(glitchBaseClip[client]-3)); // dmg
			TF2Attrib_SetByDefIndex(weapon, 6, glitchBaseFireRate[client]); // fire rate
			TF2Attrib_SetByDefIndex(weapon, 4, glitchBaseClip[client]); // clip size
			TF2Attrib_SetByDefIndex(weapon, 413, 0.0); // autofire shot (prevent weapon switch)
			TF2Attrib_SetByDefIndex(weapon, 106, 1.5); // spread
			TF2Attrib_SetByDefIndex(weapon, 45, 20.0);  // bullet per shot
			TF2Attrib_SetByDefIndex(weapon, 298, 1.0); // Ammo per shot
			TF2Attrib_SetByDefIndex(weapon, 97, glitchBaseReloadRate[client]); // Reload rate
			
			ClientCommand(client, "playgamesound items/powerup_pickup_regeneration.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Code error: 5Pr34d");
		}
		
		default:
		{
			TF2Attrib_SetByDefIndex(weapon, 2, glitchBaseDMG[client]); // dmg
			TF2Attrib_SetByDefIndex(weapon, 6, glitchBaseFireRate[client]); // fire rate
			TF2Attrib_SetByDefIndex(weapon, 4, glitchBaseClip[client]); // clip size
			TF2Attrib_SetByDefIndex(weapon, 413, 0.0); // autofire shot (prevent weapon switch)
			TF2Attrib_SetByDefIndex(weapon, 106, 0.5); // spread
			TF2Attrib_SetByDefIndex(weapon, 45, 1.0);  // bullet per shot
			TF2Attrib_SetByDefIndex(weapon, 298, 1.0); // Ammo per shot
			TF2Attrib_SetByDefIndex(weapon, 96, glitchBaseReloadRate[client]); // Reload rate
		}
	}
	int ammoType = (GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType"));
	if (ammoType!=-1)
	{
		SetEntProp(client, Prop_Data, "m_iAmmo", GetRandomInt(50, 999999), _, ammoType);
	}
}


public void Glitched_Attack2(int client, int weapon, bool crit)
{
	Address address = TF2Attrib_GetByDefIndex(weapon, 298);
	if(address != Address_Null)
	{
		if (RoundToCeil(TF2Attrib_GetValue(address))!=24.0)
		{
			int clip = GetEntProp(weapon, Prop_Data, "m_iClip1");
			if(clip>=4)
				TF2Attrib_SetByDefIndex(weapon, 298, GetRandomInt(0,2)*1.0); // Ammo per shot
			else
				TF2Attrib_SetByDefIndex(weapon, 298, 1.0);	// prevent being stuck (rare but can happen)
			
			int ammoType = (GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType"));
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
			int ammoType = (GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType"));
			if (ammoType!=-1)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", GetRandomInt(50, 999999), _, ammoType);
			}
		}
	}
	
	address = TF2Attrib_GetByDefIndex(weapon, 280);
	if (address == Address_Null)
		return;
	
	float typeProjectile = TF2Attrib_GetValue(address);
	if (typeProjectile==1)
		return; 
	
	address = TF2Attrib_GetByDefIndex(weapon, 45);
	if (address == Address_Null)
		return;
	
	int numberProjectile = RoundToCeil(TF2Attrib_GetValue(address));
	if (numberProjectile==1.0)
		return;
		
	float dmgProjectile = 12.0;
	
	address = TF2Attrib_GetByDefIndex(weapon, 2);
	if(address != Address_Null)
		dmgProjectile *= TF2Attrib_GetValue(address);
	
	float positiveAngleModifier = 3.0;
	address = TF2Attrib_GetByDefIndex(weapon, 106);
	if(address != Address_Null)
		positiveAngleModifier *= TF2Attrib_GetValue(address);
	
	
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
			TF2Attrib_SetByDefIndex(weapon, 280, 2.0); // Rocket
		}
		
		case 3:
		{
			TF2Attrib_SetByDefIndex(weapon, 280, 5.0); // Syringe
		}
		
		case 5:
		{
			TF2Attrib_SetByDefIndex(weapon, 280, 6.0); // Flare
		}
		
		default:
		{
			TF2Attrib_SetByDefIndex(weapon, 280, 1.0); // Normal
			// normalBullets = true;
		}
	}
	
	float bulletPerShot = GetRandomInt(-5, 5) * 1.0;
	if (bulletPerShot<1.0)
		bulletPerShot = 1.0;
	
	float shotAll = 0.0;
	if (GetRandomInt(0, 5)==3)
		shotAll = 1.0;
	
	TF2Attrib_SetByDefIndex(weapon, 2, (glitchBaseDMG[client]*GetRandomFloat(0.5,2.5))/bulletPerShot); // dmg
	TF2Attrib_SetByDefIndex(weapon, 6, glitchBaseFireRate[client]*GetRandomFloat(0.70,1.25)); // fire rate
	TF2Attrib_SetByDefIndex(weapon, 4, glitchBaseClip[client]*GetRandomFloat(0.5,2.0)); // clip size
	TF2Attrib_SetByDefIndex(weapon, 413, shotAll); // autofire shot (prevent weapon switch)
	TF2Attrib_SetByDefIndex(weapon, 106, GetRandomFloat(0.25,1.25)); // spread
	TF2Attrib_SetByDefIndex(weapon, 45, bulletPerShot);  // bullet per shot
	TF2Attrib_SetByDefIndex(weapon, 298, 1.0); // Ammo per shot
	TF2Attrib_SetByDefIndex(weapon, 96, glitchBaseReloadRate[client]*GetRandomFloat(0.5,1.5)); // Reload rate
	
	
	int ammoType = (GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType"));
	if (ammoType!=-1)
	{
		SetEntProp(client, Prop_Data, "m_iAmmo", GetRandomInt(50, 999999), _, ammoType);
	}
}