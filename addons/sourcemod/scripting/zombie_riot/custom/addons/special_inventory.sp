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
bool Inv_GalssCoil[MAXPLAYERS];
bool Inv_SuperFocusLens[MAXPLAYERS];
bool Inv_ExperimentalReactor[MAXPLAYERS];
bool Inv_StickyFullBurst[MAXPLAYERS];
bool Inv_CompressedExplosive[MAXPLAYERS];
float Inv_Nailgun_Slug_Ammo[MAXPLAYERS];
float Inv_Chaos_Coil_Delay[MAXPLAYERS];
int Inv_SpecialSandvichProgress[MAXPLAYERS];
int Inv_ChaosticGlass[MAXPLAYERS];
int Inv_Chaos_Coil[MAXPLAYERS];
int Inv_Box_Office_Max[MAXPLAYERS];

static float PreventSameFrameGivearmor[MAXPLAYERS];

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
	Inv_GalssCoil[client]=false;
	Inv_SuperFocusLens[client]=false;
	Inv_ExperimentalReactor[client]=false;
	Inv_StickyFullBurst[client]=false;
	Inv_CompressedExplosive[client]=false;
	if(Inv_Chaos_Coil[client])
	{
		int Chaos_Coil = EntRefToEntIndex(Inv_Chaos_Coil[client]);
		if(IsValidEntity(Chaos_Coil))
			Attributes_Set(Chaos_Coil, 489, 1.0);
		Inv_Chaos_Coil[client] = INVALID_ENT_REFERENCE;
	}
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
		case 1011:{if(IsValidEntity(entity))Inv_Chaos_Coil[client] = EntIndexToEntRef(entity);}
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
		case 1017:Inv_GalssCoil[client]=true;
		case 1018:Inv_SuperFocusLens[client]=true;
		case 1019:Inv_ExperimentalReactor[client]=true;
		case 1020:Inv_StickyFullBurst[client]=true;
		case 1021:Inv_CompressedExplosive[client]=true;
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
					case WEAPON_BOOMSTICK, WEAPON_IS_SHOTGUN, WEAPON_ANGELIC_SHOTGUN, WEAPON_IS_AUTOSHOTGUN:
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
							Attributes_Set(weapon, 45, 0.25);
							Pellets=RoundToCeil(4.0*ExtraPellets);
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
		/*else if(Inv_Dragon_Breath_Shell[client])
		{
			if(Attributes_Has(weapon, 71))
				Attributes_SetMulti(weapon, 71, 0.5);
			else
				Attributes_Set(weapon, 71, 0.5);
		}*/
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
		if(Store_HasNamedItem(client, "Grigori's Personal 12g Ammo"))
		{
			if(!Attributes_Has(weapon, 2))
				Attributes_Set(weapon, 2, 1.0);
			if(!Attributes_Has(weapon, Attrib_ArmorOnHitMax))
				Attributes_Set(weapon, Attrib_ArmorOnHitMax, 1.0);
			Attributes_SetMulti(weapon, 2, 0.8);
			switch(i_CustomWeaponEquipLogic[weapon])
			{
				case WEAPON_BOOMSTICK:
					Attributes_Set(weapon, Attrib_ArmorOnHitMax, 0.0);
				case WEAPON_IS_AUTOSHOTGUN:
					Attributes_SetMulti(weapon, Attrib_ArmorOnHitMax, 0.025);
				default:
					Attributes_SetMulti(weapon, Attrib_ArmorOnHitMax, 0.1);
			}
		}
	}
	if(i_CustomWeaponEquipLogic[weapon]==WEAPON_IS_HPR && Inv_ExperimentalReactor[client])
	{
		Attributes_SetMulti(weapon, 122, 0.75);
		Attributes_SetMulti(weapon, 4047, 1.35);
		Attributes_SetMulti(weapon, 4048, 0.35);
	}
	if(i_CustomWeaponEquipLogic[weapon]==WEAPON_IS_STICKYBOMB && Inv_StickyFullBurst[client])
		Attributes_Set(weapon, 119, 0.0);
	if(i_CustomWeaponEquipLogic[weapon]==WEAPON_VICTORIAN_LAUNCHER && Inv_CompressedExplosive[client])
		Attributes_SetMulti(weapon, 99, 1.33);
}

public void Custom_Inventory_WaveEnd(int client)
{
	int ThisWave = Waves_GetRoundScale()+1;
	if(!StrContains(WhatDifficultySetting_Internal, "Interitus Group"))
	{
		bool Chaostic = view_as<bool>(Store_HasNamedItem(client, "Glass Coil"));
		if(Chaostic)
		{
			Inv_ChaosticGlass[client]++;
			if(Inv_ChaosticGlass[client]>=46 && (ThisWave==40 || (ThisWave>=0 && ThisWave<=1)) &&!(Items_HasNamedItem(client, "Chaos Coil")))
			{
				Items_GiveNamedItem(client, "Chaos Coil");
				CPrintToChat(client, "%t", "Inv Chaos Coil Give");
			}
		}
		else
			Inv_ChaosticGlass[client]=0;
	}
	if(!StrContains(WhatDifficultySetting_Internal, "Sensal"))
	{
		bool bSandvich = view_as<bool>(Store_HasNamedItem(client, "Special Sandvich Recipe"));
		int building = EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
		if(building != -1)
		{
			if(bSandvich && Merchant_IsAMerchant(client) && StrEqual(c_NpcName[building], "Merchant Grill"))
			{
				Inv_SpecialSandvichProgress[client]++;
				if(Inv_SpecialSandvichProgress[client]>=44 && (ThisWave==40 || (ThisWave>=0 && ThisWave<=1)) &&!(Items_HasNamedItem(client, "Little Sandvich SafeHouse")))
				{
					Items_GiveNamedItem(client, "Little Sandvich SafeHouse");
					CPrintToChat(client, "%t", "Inv Little Sandvich SafeHouse Give");
				}
			}
			else
				Inv_SpecialSandvichProgress[client]=0;
		}
		else
			Inv_SpecialSandvichProgress[client]=0;
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
			Attributes_Set(Chaos_Coil, 489, 1.0+(0.01*float(GetRandomInt(5, 20))));
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

public float Custom_Inventory_PlayerOnTakeDamage(int victim, int attacker, float damage)
{
	if(!IsValidClient(victim) || CheckInHud())
		return damage;

	if(Inv_Chaos_Coil[victim])
	{
		int Chaos_Coil = EntRefToEntIndex(Inv_Chaos_Coil[victim]);
		if(IsValidEntity(Chaos_Coil))
		{
			Elemental_AddChaosDamage(victim, attacker, RoundToCeil(damage*1.2));
			if(Armor_Charge[victim] > 0)
			{
				Armor_Charge[victim]=0;
				f_Armor_BreakSoundDelay[victim] = GetGameTime() + 5.0;	
				EmitSoundToClient(victim, "npc/assassin/ball_zap1.wav", victim, SNDCHAN_STATIC, 60, _, 1.0, GetRandomInt(95,105));
			}
		}
		else Inv_Chaos_Coil[victim] = INVALID_ENT_REFERENCE;
	}
	else if(Inv_GalssCoil[victim] && Armor_Charge[victim] > 0)
	{
		Armor_Charge[victim]=0;
		f_Armor_BreakSoundDelay[victim] = GetGameTime() + 5.0;	
		EmitSoundToClient(victim, "npc/assassin/ball_zap1.wav", victim, SNDCHAN_STATIC, 60, _, 1.0, GetRandomInt(95,105));
	}
		
	return damage;
}

public float Custom_Inventory_NPCOnTakeDamage(int victim, int attacker, int inflictor, float &damage, int &damagetype, int weapon)
{
	if(!IsValidEntity(victim) || CheckInHud())
		return damage;

	if(IsValidClient(attacker))
	{
		if(Inv_Dragon_Breath_Shell[attacker] && Custom_Inventory_IsShotgun(weapon))
		{
			if(!(damagetype & DMG_TRUEDAMAGE) && !(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
			{
				float attackerPos[3], victimPos[3];
				GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", attackerPos);
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", victimPos);
				float Dist = GetVectorDistance(attackerPos, victimPos, true);
				float IgniteDMG = damage/10000.0;
				if(IgniteDMG<4.0)IgniteDMG=4.0;
				if(Dist<(1000.0*1000.0)) NPC_Ignite(victim, attacker, 3.0, weapon, IgniteDMG);
			}
		}
		if(Inv_MarketGardener_Uniform[attacker] && !(GetEntityFlags(attacker)&FL_ONGROUND))
		{
			float Speed = MoveSpeed(attacker, _, true);
			damage += Speed*0.25;
			damage *= 1.05;
		}
		if(Inv_DeathfromAbove[attacker])
		{
			float attackerPos[3], victimPos[3];
			GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", attackerPos);
			GetEntPropVector(victim, Prop_Send, "m_vecOrigin", victimPos);
			attackerPos[0]=victimPos[0];
			attackerPos[1]=victimPos[1];
			float YPOS = GetVectorDistance(attackerPos, victimPos);
			if(YPOS>100.0) damage *= 1.10;
		}
		if(Store_HasNamedItem(attacker, "Grigori's Personal 12g Ammo"))
		{
			float value = Attributes_Get(weapon, Attrib_ArmorOnHitMax, 0.0);
			if(PreventSameFrameGivearmor[attacker] == GetGameTime())
				value = 0.0;
				
			if(value)
			{
				PreventSameFrameGivearmor[attacker] = GetGameTime();
				if(b_thisNpcIsARaid[victim])
					value *= 2.0;
					
				float attackerPos[3], victimPos[3];
				GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", attackerPos);
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", victimPos);
				float Dist = GetVectorDistance(attackerPos, victimPos, true);
				if(Dist<202500.0) //450*450
				{
					float WeaponDamageFalloff = i_WeaponDamageFalloff[weapon];
					if(b_ProximityAmmo[attacker])
						WeaponDamageFalloff *= 0.8;
					if(f_TimeUntillNormalHeal[attacker] > GetGameTime())
						value *= 0.25;
					
					value = value*Pow(WeaponDamageFalloff, (Dist/160000.0)); //400*400
					GiveArmorViaPercentage(attacker, value, 0.5);
				}
			}
		}
	}
	return damage;
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
			case WEAPON_BOOMSTICK, WEAPON_IS_SHOTGUN, WEAPON_NAILGUN_SHOTGUN, WEAPON_ANGELIC_SHOTGUN, WEAPON_IS_AUTOSHOTGUN:return true;
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
			case WEAPON_BOOMSTICK, WEAPON_IS_SHOTGUN, WEAPON_NAILGUN_SHOTGUN, WEAPON_ANGELIC_SHOTGUN, WEAPON_IS_AUTOSHOTGUN:return 0.77;
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
			case WEAPON_BOOMSTICK, WEAPON_IS_SHOTGUN, WEAPON_NAILGUN_SHOTGUN, WEAPON_ANGELIC_SHOTGUN, WEAPON_IS_AUTOSHOTGUN:return 0.83;
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

float Barricade_Stabilizer_FeedBack(int client)
{
	float f_Resistance=0.95;
	
	if(Store_HasNamedItem(client, "Construction Novice"))
		f_Resistance*=0.98;
	
	if(Store_HasNamedItem(client, "Construction Apprentice"))
		f_Resistance*=0.97;
	
	if(Store_HasNamedItem(client, "Engineering Repair Handling book"))
		f_Resistance*=0.982;
	
	if(Store_HasNamedItem(client, "Construction Worker"))
		f_Resistance*=0.98;
		
	if(Store_HasNamedItem(client, "Alien Repair Handling book"))
		f_Resistance*=0.98;
		
	if(Store_HasNamedItem(client, "Construction Expert"))
		f_Resistance*=0.95;
	
	if(Store_HasNamedItem(client, "Cosmic Repair Handling book"))
		f_Resistance*=0.97;
		
	if(Store_HasNamedItem(client, "Construction Master"))
		f_Resistance*=0.97;
	
	if(Store_HasNamedItem(client, "Construction Killer"))
		f_Resistance*=0.97;

	if(Store_HasNamedItem(client, "Wildingen's Elite Building Components"))
		f_Resistance*=0.9;

	return f_Resistance;
}