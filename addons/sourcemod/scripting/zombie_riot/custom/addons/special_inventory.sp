#pragma semicolon 1
#pragma newdecls required

bool Inv_Golden_Crown[MAXENTITIES];
bool Inv_Mining_Foreman_Hat[MAXPLAYERS];
bool Inv_LSandvich_SafeHouse[MAXPLAYERS];
bool Inv_Slug_Shell_Pouch[MAXPLAYERS];
bool Inv_Scrap_Backpack[MAXPLAYERS];
bool Inv_Dragon_Breath_Shell[MAXPLAYERS];
bool Inv_Mini_Shell[MAXPLAYERS];
bool Inv_Barrack_Backup[MAXENTITIES];
bool Inv_MarketGardener_Uniform[MAXPLAYERS];
bool Inv_Barricade_Stabilizer[MAXPLAYERS];
bool Inv_Leaders_Belt[MAXENTITIES];
bool Inv_Box_Office[MAXPLAYERS];
bool Inv_Grigori_Antidote[MAXPLAYERS];
bool Inv_Rose_Of_SelfHarm[MAXPLAYERS];
bool Inv_DeathfromAbove[MAXPLAYERS];
bool Inv_UGotMetalPipe[MAXPLAYERS];
float Inv_Nailgun_Slug_Ammo[MAXPLAYERS];
float Inv_Chaos_Coil_Delay[MAXPLAYERS];
int Inv_ChaosticGlass[MAXPLAYERS];
int Inv_Chaos_Coil[MAXPLAYERS];
int Inv_Box_Office_Max[MAXPLAYERS];

public void Custom_Inventory_Reset(int client)
{
	/*초기화*/
	Inv_Golden_Crown[client]=false;
	Inv_LSandvich_SafeHouse[client]=false;
	Inv_Slug_Shell_Pouch[client]=false;
	Inv_Mining_Foreman_Hat[client]=false;
	Inv_Scrap_Backpack[client]=false;
	Inv_Dragon_Breath_Shell[client]=false;
	Inv_Mini_Shell[client]=false;
	Inv_Barrack_Backup[client]=false;
	Inv_MarketGardener_Uniform[client]=false;
	Inv_Barricade_Stabilizer[client]=false;
	Inv_Leaders_Belt[client]=false;
	Inv_Box_Office[client]=false;
	Inv_Rose_Of_SelfHarm[client]=false;
	Inv_Grigori_Antidote[client]=false;
	Inv_DeathfromAbove[client]=false;
	Inv_Chaos_Coil[client]=0;
	Inv_Nailgun_Slug_Ammo[client]=1.0;
}

stock bool Custom_Inventory_Enable(int client, int entity, int Attribute)
{
	switch(Attribute)
	{
		case 1000:Inv_Golden_Crown[client]=true;
		case 1001:Inv_LSandvich_SafeHouse[client]=true;
		case 1002:Inv_Slug_Shell_Pouch[client]=true;
		case 1003:Inv_Mining_Foreman_Hat[client]=true;
		case 1004:Inv_Scrap_Backpack[client]=true;
		case 1005:Inv_Dragon_Breath_Shell[client]=true;
		case 1006:Inv_Mini_Shell[client]=true;
		case 1007:Inv_Barrack_Backup[client]=true;
		case 1008:Inv_MarketGardener_Uniform[client]=true;
		case 1009:
		{
			Inv_Barricade_Stabilizer[client]=true;
			ApplyStatusEffect(client, client, "Barricade Stabilizer", 9999.0);
		}
		case 1010:Inv_Leaders_Belt[client]=true;
		case 1011:
		{
			if(IsValidEntity(entity))Inv_Chaos_Coil[client] = EntIndexToEntRef(entity);
			ApplyStatusEffect(client, client, "Chaos Coil Speed", 9999.0);
		}
		case 1012:Inv_Box_Office[client]=true;
		case 1013:Inv_Rose_Of_SelfHarm[client]=true;
		case 1014:Inv_Grigori_Antidote[client]=true;
		case 1015:Inv_DeathfromAbove[client]=true;
		case 1016:
		{
			if(!Inv_UGotMetalPipe[client])
			{
				for(int all=1; all<=MaxClients; all++)
				{
					if(IsValidClient(all) && !IsFakeClient(all))
						EmitCustomToClient(all, "#baka_zr/metal_pipe.mp3", all, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				}
				TF2_StunPlayer(client, 1.0, 0.0, TF_STUNFLAG_BONKSTUCK|TF_STUNFLAG_SOUND, 0);
				StopSound(client, SNDCHAN_STATIC, "player/pl_impact_stun.wav");
			}
			Inv_UGotMetalPipe[client] = true;
		}
	}
	return false;
}

public void Custom_Inventory_Attribute(int client, int weapon)
{
	if(i_WeaponArchetype[weapon] == Archetype_Charger && Custom_Inventory_IsShotgun(weapon))
	{
		if(Inv_Slug_Shell_Pouch[client])
		{
			int Pellets = 10;
			float ExtraPellets=0.0;
			if(Attributes_Has(weapon, 45))
				ExtraPellets=Attributes_Get(weapon, 45, 0.0);
				
			if(ExtraPellets)
				Pellets=RoundToCeil(float(Pellets)*ExtraPellets);
		
			if(Pellets>1)
			{
				switch(i_CustomWeaponEquipLogic[weapon])
				{
					case WEAPON_BOOMSTICK, WEAPON_IS_SHOTGUN:
					{
						Attributes_Set(weapon, 45, 0.1);
						Attributes_SetMulti(weapon, 2, float(Pellets));
						if(i_WeaponDamageFalloff[weapon]==1.0)
							i_WeaponDamageFalloff[weapon]=0.99;
						else
							i_WeaponDamageFalloff[weapon]-=0.01;
					}
					case WEAPON_NAILGUN_SHOTGUN:
					{
						Attributes_Set(weapon, 45, 0.1);
						Inv_Nailgun_Slug_Ammo[client]=float(Pellets);
						if(i_WeaponDamageFalloff[weapon]==1.0)
							i_WeaponDamageFalloff[weapon]=0.99;
						else
							i_WeaponDamageFalloff[weapon]-=0.01;
					}
					case WEAPON_RIOT_SHIELD:
					{
						if(ExtraPellets)
						{
							Attributes_Set(weapon, 45, 0.1);
							Attributes_SetMulti(weapon, 2, float(Pellets));
							if(i_WeaponDamageFalloff[weapon]==1.0)
								i_WeaponDamageFalloff[weapon]=0.99;
							else
								i_WeaponDamageFalloff[weapon]-=0.01;
						}
					}
				}
			}
		}
		else if(Inv_Dragon_Breath_Shell[client])
		{
			if(Attributes_Has(weapon, 71))
				Attributes_SetMulti(weapon, 71, 0.5);
			else
				Attributes_Set(weapon, 71, 0.5);
		}
		else if(Inv_Mini_Shell[client])
		{
			if(!Attributes_Has(weapon, 45))
				Attributes_Set(weapon, 45, 1.0);
			if(!Attributes_Has(weapon, 36))
				Attributes_Set(weapon, 36, 1.0);
			if(!Attributes_Has(weapon, 104))
				Attributes_Set(weapon, 104, 1.0);
			if(!Attributes_Has(weapon, 2))
				Attributes_Set(weapon, 2, 1.0);
			Attributes_SetMulti(weapon, 36, 1.3);
			Attributes_SetMulti(weapon, 104, 0.5);
			Attributes_SetMulti(weapon, 45, 0.8);
			Attributes_SetMulti(weapon, 2, 0.7);
			
			if(!Attributes_Has(weapon, 4))
				Attributes_Set(weapon, 4, 1.0);
			if(!Attributes_Has(weapon, 97))
				Attributes_Set(weapon, 97, 1.0);
			Attributes_SetMulti(weapon, 4, 1.5);
			Attributes_SetMulti(weapon, 97, 0.95);
			if(i_WeaponDamageFalloff[weapon]==1.0)
				i_WeaponDamageFalloff[weapon]=0.99;
			else
				i_WeaponDamageFalloff[weapon]-=0.01;
		}
	}
}

public void Custom_Inventory_WaveEnd(int client)
{
	if(!StrContains(WhatDifficultySetting_Internal, "Interitus Group"))
	{
		bool Chaostic = view_as<bool>(Store_HasNamedItem(client, "Glass Coil [Common]"));
		if(Chaostic)
		{
			Inv_ChaosticGlass[client]++;
			int ThisWave = Waves_GetRoundScale()+1;
			if(Inv_ChaosticGlass[client]>=33 && ThisWave>=30 && ThisWave<31 &&!(Items_HasNamedItem(client, "Chaos Coil [Rare]")))
			{
				Items_GiveNamedItem(client, "Chaos Coil [Rare]");
				CPrintToChat(client, "%t", "Inv Chaos Coil Give");
			}
		}
		else
			Inv_ChaosticGlass[client]=0;
	}
	Inv_Box_Office_Max[client]=0;
}

public void Custom_Inventory_Think(int client, float GameTime)
{
	if(IsValidClient(client) && Inv_Chaos_Coil[client] && GameTime > Inv_Chaos_Coil_Delay[client])
	{
		int Chaos_Coil = EntRefToEntIndex(Inv_Chaos_Coil[client]);
		if(IsValidEntity(Chaos_Coil))
		{
			Attributes_Set(Chaos_Coil, 107, 1.0+(0.01*float(GetRandomInt(0, 20))));
			SDKCall_SetSpeed(client);
			Inv_Chaos_Coil_Delay[client] = GameTime + 3.0;
		}
	}
}

public void Custom_Inventory_NPCKill(int attacker)
{
	if(!IsValidClient(attacker))
		return;

	if(Inv_Box_Office[attacker] && !Waves_InSetup())
	{
		if(Inv_Box_Office_Max[attacker]<500)
		{
			CashReceivedNonWave[attacker] += 1;
			CashSpent[attacker] -= 1;
			Inv_Box_Office_Max[attacker]++;
		}
	}
}

bool Inv_Grigori_Antidote_Enable(int client)
{
	return Inv_Grigori_Antidote[client];
}

bool Inv_Mining_Foreman_Hat_Enable(int client)
{
	return Inv_Mining_Foreman_Hat[client];
}

bool Custom_Inventory_IsShotgun(int weapon)
{
	if(i_WeaponArchetype[weapon] == Archetype_Charger)
	{
		switch(i_CustomWeaponEquipLogic[weapon])
		{
			case WEAPON_BOOMSTICK, WEAPON_IS_SHOTGUN, WEAPON_NAILGUN_SHOTGUN:return true;
			case WEAPON_RIOT_SHIELD:
			{
				if(Attributes_Has(weapon, 45))
					return true;
			}
		}
	}
	return false;
}

float Custom_Inventory_Falloff(int attacker, int weapon)
{
	if(Inv_Slug_Shell_Pouch[attacker] && i_WeaponArchetype[weapon] == Archetype_Charger)
	{
		switch(i_CustomWeaponEquipLogic[weapon])
		{
			case WEAPON_BOOMSTICK, WEAPON_IS_SHOTGUN, WEAPON_NAILGUN_SHOTGUN:return 0.77;
			case WEAPON_RIOT_SHIELD:
			{
				if(Attributes_Has(weapon, 45))
					return 0.77;
			}
		}
	}
	if(Inv_Mini_Shell[attacker] && i_WeaponArchetype[weapon] == Archetype_Charger)
	{
		switch(i_CustomWeaponEquipLogic[weapon])
		{
			case WEAPON_BOOMSTICK, WEAPON_IS_SHOTGUN, WEAPON_NAILGUN_SHOTGUN:return 0.83;
			case WEAPON_RIOT_SHIELD:
			{
				if(Attributes_Has(weapon, 45))
					return 0.83;
			}
		}
	}
	return 1.0;
}

float MoveSpeed(int client, bool maxspeed = false, bool upspeed = false)
{
	float Fvel[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", Fvel);

	float Speed;
	if(upspeed)
		Speed = SquareRoot(Pow(Fvel[0],2.0)+Pow(Fvel[1],2.0)+Pow(Fvel[2],2.0));
	else
		Speed = SquareRoot(Pow(Fvel[0],2.0)+Pow(Fvel[1],2.0));

	if(maxspeed && Speed > 520.0)
		Speed = 520.0;

	return Speed;
}