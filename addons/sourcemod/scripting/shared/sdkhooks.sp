#pragma semicolon 1
#pragma newdecls required
/*
static const float ViewHeights[] =
{
	75.0,
	65.0,
	75.0,
	68.0,
	68.0,
	75.0,
	75.0,
	68.0,
	75.0,
	68.0
};
*/
//static int g_offsPlayerPunchAngleVel = -1;

void SDKHooks_ClearAll()
{
#if defined ZR
	Zero(Armor_regen_delay);
#endif
	
	for (int client = 1; client <= MaxClients; client++)
	{
		i_WhatLevelForHudIsThisClientAt[client] = 2000000000; //two billion
	}
}

void SDKHook_PluginStart()
{
#if defined ZR
	/*
	g_offsPlayerPunchAngleVel = FindSendPropInfo("CBasePlayer", "m_vecPunchAngleVel");
	if (g_offsPlayerPunchAngleVel == -1) LogError("Couldn't find CBasePlayer offset for m_vecPunchAngleVel!");
	*/
	SyncHud_ArmorCounter = CreateHudSynchronizer();
#endif
	
	AddNormalSoundHook(SDKHook_NormalSHook);
}

void SDKHook_MapStart()
{
	int entity = FindEntityByClassname(MaxClients+1, "tf_player_manager");
	if(entity != -1)
		SDKHook(entity, SDKHook_ThinkPost, SDKHook_ScoreThink);
}

public void SDKHook_ScoreThink(int entity)
{
	static int offset = -1;
	
#if defined ZR
	static int offset_Damage = -1;
	static int offset_damageblocked = -1;
//	static int offset_bonus = -1;
#endif
	
	if(offset == -1) 
		offset = FindSendPropInfo("CTFPlayerResource", "m_iTotalScore");

#if defined ZR
	if(offset_Damage == -1) 
		offset_Damage = FindSendPropInfo("CTFPlayerResource", "m_iDamage");

	if(offset_damageblocked == -1) 
		offset_damageblocked = FindSendPropInfo("CTFPlayerResource", "m_iDamageBlocked");

//	if(offset_bonus == -1) 
//		offset_bonus = FindSendPropInfo("CTFPlayerResource", "m_iCurrencyCollected");
#endif
	
#if defined ZR
	SetEntDataArray(entity, offset, PlayerPoints, MaxClients + 1);
	SetEntDataArray(entity, offset_Damage, i_Damage_dealt_in_total, MaxClients + 1);
//	SetEntDataArray(entity, offset_bonus, i_BarricadeHasBeenDamaged, MaxClients + 1);
#endif
	
#if defined RPG
	SetEntDataArray(entity, offset, Level, MaxClients + 1);
#endif
	
#if defined ZR
	int Conversion_ExtraPoints[MAXTF2PLAYERS];
	for(int client=1; client<=MaxClients; client++)
	{
		Conversion_ExtraPoints[client] = RoundToCeil(float(i_ExtraPlayerPoints[client]) * 0.5);
	}

	SetEntDataArray(entity, offset_damageblocked, Conversion_ExtraPoints, MaxClients + 1);

	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && !b_IsPlayerABot[client])
		{
			SetEntProp(client, Prop_Data, "m_iFrags", i_KillsMade[client]);
			SetEntProp(client, Prop_Send, "m_iHealPoints", Healing_done_in_total[client]);
			SetEntProp(client, Prop_Send, "m_iBackstabs", i_Backstabs[client]);
			SetEntProp(client, Prop_Send, "m_iHeadshots", i_Headshots[client]);
			SetEntProp(client, Prop_Send, "m_iDefenses", RoundToCeil(float(i_BarricadeHasBeenDamaged[client]) * 0.001));


		//	m_iHealPoints
		}
	}	
#endif
}

void SDKHook_HookClient(int client)
{
	SDKUnhook(client, SDKHook_PostThink, OnPostThink);
	SDKUnhook(client, SDKHook_PreThinkPost, OnPreThinkPost);
	SDKUnhook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost);
	SDKUnhook(client, SDKHook_OnTakeDamage, Player_OnTakeDamage);
	
	SDKHook(client, SDKHook_PostThink, OnPostThink);
	SDKHook(client, SDKHook_PreThinkPost, OnPreThinkPost);
	SDKHook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost);
	SDKHook(client, SDKHook_OnTakeDamage, Player_OnTakeDamage);
	
	#if defined ZR
	SDKUnhook(client, SDKHook_OnTakeDamageAlivePost, Player_OnTakeDamageAlivePost);
	SDKHook(client, SDKHook_OnTakeDamageAlivePost, Player_OnTakeDamageAlivePost);
	#endif
	
	#if !defined NoSendProxyClass
	SDKUnhook(client, SDKHook_PostThinkPost, OnPostThinkPost);
	SDKHook(client, SDKHook_PostThinkPost, OnPostThinkPost);
	#endif
}

public void OnPreThinkPost(int client)
{
	if(CvarMpSolidObjects)
	{
		if(b_PhaseThroughBuildingsPerma[client] == 0)
		{
			CvarMpSolidObjects.IntValue	= b_PhasesThroughBuildingsCurrently[client] ? 0 : 1;
		}
		else
		{
			CvarMpSolidObjects.IntValue = 0;
		}
	}
/*
#if defined ZR
	if(CvarSvRollagle)
	{
		CvarSvRollagle.IntValue = i_SvRollAngle[client];
	}
#endif
*/
#if defined RPG
	int maxhealth = SDKCall_GetMaxHealth(client);
	if(GetClientHealth(client) > maxhealth)
		SetEntityHealth(client, maxhealth);
#endif
}

public void OnPostThink(int client)
{
	
	float GameTime = GetGameTime();
	if(b_DisplayDamageHud[client])
	{
		b_DisplayDamageHud[client] = false;
		Calculate_And_Display_HP_Hud(client);
	}
#if !defined NoSendProxyClass
	if(WeaponClass[client]!=TFClass_Unknown)
	{
		TF2_SetPlayerClass(client, WeaponClass[client], false, false);
		if(GetEntPropFloat(client, Prop_Send, "m_vecViewOffset[2]") > 64.0)	// Otherwise, shaking
			SetEntPropFloat(client, Prop_Send, "m_vecViewOffset[2]", ViewHeights[WeaponClass[client]]);
	}
#endif

	if(b_PhaseThroughBuildingsPerma[client] == 2)
	{
		CvarMpSolidObjects.ReplicateToClient(client, "0");
	}
	else
	{
		if(b_PhaseThroughBuildingsPerma[client] == 1)
		{
			b_PhaseThroughBuildingsPerma[client] = 0;
			CvarMpSolidObjects.ReplicateToClient(client, "1"); //set replicate back to normal.
		}
	}
		
#if defined ZR
	if(RollAngle_Regen_Delay[client] < GameTime)	
	{
		RollAngle_Regen_Delay[client] = GameTime + 0.5;
		
		if(CvarSvRollagle && zr_viewshakeonlowhealth.BoolValue && b_HudLowHealthShake[client])
		{
			int flHealth = GetEntProp(client, Prop_Send, "m_iHealth");
			int flMaxHealth = SDKCall_GetMaxHealth(client);

			float PercentageHealth = float(flHealth) / float(flMaxHealth);

			if(TeutonType[client] == TEUTON_NONE) //If the cvar is off, then the viewshake will not happen.
			{
				if(PercentageHealth > 0.35)
				{
					i_SvRollAngle[client] = 0;
				}
				else
				{
					PercentageHealth *= 2.857142858142857; // 1 / 0.35
					PercentageHealth = PercentageHealth - 1.0;
					PercentageHealth *= -1.0; //convert to positive
					PercentageHealth *= 125.0; // we want the full number! this only works in big ones. also divitde by 4
					i_SvRollAngle[client] = RoundToCeil(PercentageHealth);

					if(i_SvRollAngle[client] < 0)
					{
						i_SvRollAngle[client] = 0;
					}
				}
			}
			else
			{
				i_SvRollAngle[client] = 0;
			}

			char RollAngleValue[4];

			IntToString(i_SvRollAngle[client], RollAngleValue, sizeof(RollAngleValue));

			CvarSvRollagle.ReplicateToClient(client, RollAngleValue); //set replicate back to normal.
		}
		else
		{
			RollAngle_Regen_Delay[client] = GameTime + 5.0;
			CvarSvRollagle.ReplicateToClient(client, "0"); //set replicate back to normal.
		}
	}
#endif	// ZR
	if(Mana_Regen_Delay[client] < GameTime)	
	{
		Mana_Regen_Delay[client] = GameTime + 0.4;
			
		has_mage_weapon[client] = false;

		int i, entity;
		while(TF2_GetItem(client, entity, i))
		{
			if(i_IsWandWeapon[entity])
			{
				has_mage_weapon[client] = true;
				break;
			}
		}

#if defined ZR
		max_mana[client] = 400.0;
		mana_regen[client] = 10.0;
			
		if(LastMann)
			mana_regen[client] *= 20.0; // 20x the regen to help last man mage cus they really suck otherwise alone.
				
		if(i_CurrentEquippedPerk[client] == 4)
		{
			mana_regen[client] *= 1.35;
		}
#endif
				
#if defined RPG
		max_mana[client] = 40.0;
		mana_regen[client] = 1.0;
#endif
					
		mana_regen[client] *= Mana_Regen_Level[client];
		max_mana[client] *= Mana_Regen_Level[client];	
			
		if(Current_Mana[client] < RoundToCeil(max_mana[client]))
		{
			Current_Mana[client] += RoundToCeil(mana_regen[client]);
				
			if(Current_Mana[client] > RoundToCeil(max_mana[client])) //Should only apply during actual regen
				Current_Mana[client] = RoundToCeil(max_mana[client]);
		}
					
		Mana_Hud_Delay[client] = 0.0;
	}

#if defined ZR
	if(Armor_regen_delay[client] < GameTime)
	{
		Armour_Level_Current[client] = 0;
		int flHealth = GetEntProp(client, Prop_Send, "m_iHealth");
		int flMaxHealth = SDKCall_GetMaxHealth(client);
		if(Saga_RegenHealth(client))
		{
			if(dieingstate[client] == 0 && flHealth < flMaxHealth)
			{
				int healing_Amount = 10;
					
				int newHealth = flHealth + healing_Amount;
							
				if(newHealth >= flMaxHealth)
				{
					healing_Amount -= newHealth - flMaxHealth;
					newHealth = flMaxHealth;
				}
				ApplyHealEvent(client, healing_Amount);
				SetEntProp(client, Prop_Send, "m_iHealth", newHealth);
				flHealth = newHealth;	
			}
		}
		if (Jesus_Blessing[client] == 1)
		{	
			int flMaxHealthJesus;
				
			flMaxHealthJesus = flMaxHealth;
				
			flMaxHealthJesus /= 2;
				
			if(flHealth < flMaxHealthJesus)
			{
					
				int healing_Amount = flMaxHealthJesus / 50;
					
				if(dieingstate[client] > 0)
				{
					healing_Amount = 3;
				}
				else
				{
					if(b_HealthyEssence)
						healing_Amount = RoundToCeil(float(healing_Amount) * 1.25);
				}
				int newHealth = flHealth + healing_Amount;


				if(newHealth >= flMaxHealthJesus)
				{
					healing_Amount -= newHealth - flMaxHealthJesus;
					newHealth = flMaxHealthJesus;
				}
				ApplyHealEvent(client, healing_Amount);
				SetEntProp(client, Prop_Send, "m_iHealth", newHealth);
				flHealth = newHealth;
			}
		}
		if(dieingstate[client] == 0)
		{
			Rogue_HealingSalve(client,flHealth,flMaxHealth );
			if(i_BadHealthRegen[client] == 1)
			{
				if(flHealth < flMaxHealth)
				{
					int healing_Amount = 1;
					
					int newHealth = flHealth + healing_Amount;
						
					if(newHealth >= flMaxHealth)
					{
						healing_Amount -= newHealth - flMaxHealth;
						newHealth = flMaxHealth;
					}
					ApplyHealEvent(client, healing_Amount);
						
					SetEntProp(client, Prop_Send, "m_iHealth", newHealth);
				}				
			}
		}
		Armor_regen_delay[client] = GameTime + 1.0;
	}
#endif	// ZR
	
	if(Mana_Hud_Delay[client] < GameTime)	
	{
		char buffer[255];
#if defined RPG		
		float HudY = 0.95;
#else
		float HudY = 0.90;
#endif
		float HudX = -1.0;
	
		HudX += f_WeaponHudOffsetY[client];
		HudY += f_WeaponHudOffsetX[client];

		Mana_Hud_Delay[client] = GameTime + 0.4;

		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		
		if(IsValidEntity(weapon))
		{
			static float cooldown_time;
			static bool had_An_ability;
			had_An_ability = false;
			static bool IsReady;
			IsReady = false;

			if(had_An_ability) //There was a debuff or buff create new inline.
			{
				Format(buffer, sizeof(buffer), "\n%s", buffer);
			}

			had_An_ability = false;
			
			if(i_Hex_WeaponUsesTheseAbilities[weapon] & ABILITY_M1)
			{
				
				cooldown_time = Ability_Check_Cooldown(client, 1);

				if(had_An_ability)
				{
					Format(buffer, sizeof(buffer), "| %s", buffer);
				}
				had_An_ability = true;
				if(cooldown_time < 0.0)
				{
					IsReady = true;
					cooldown_time = 0.0;
				}
					
				if(IsReady)
				{
					Format(buffer, sizeof(buffer), "[M1] %s", buffer);
				}
				else
				{
					Format(buffer, sizeof(buffer), "M1 : %.1f %s", cooldown_time, buffer);
				}
				IsReady = false;
			}
			if(i_Hex_WeaponUsesTheseAbilities[weapon] & ABILITY_M2)
			{
				cooldown_time = Ability_Check_Cooldown(client, 2);
				
				if(had_An_ability)
				{
					Format(buffer, sizeof(buffer), "| %s", buffer);
				}
				if(cooldown_time < 0.0)
				{
					IsReady = true;
					cooldown_time = 0.0;
				}
					
				if(IsReady)
				{
					Format(buffer, sizeof(buffer), "[M2] %s", buffer);
				}
				else
				{
					Format(buffer, sizeof(buffer), "M2 : %.1f %s", cooldown_time, buffer);
				}
				had_An_ability = true;
				IsReady = false;
				
			}
			if(i_Hex_WeaponUsesTheseAbilities[weapon] & ABILITY_R)
			{
				cooldown_time = Ability_Check_Cooldown(client, 3);
				
				if(had_An_ability)
				{
					Format(buffer, sizeof(buffer), "| %s", buffer);
				}	
				if(cooldown_time < 0.0)
				{
					IsReady = true;
					cooldown_time = 0.0;
				}
					
				if(IsReady)
				{
					Format(buffer, sizeof(buffer), "[R] %s", buffer);
				}
				else
				{
					Format(buffer, sizeof(buffer), "R : %.1f %s", cooldown_time, buffer);
				}
				had_An_ability = true;
				IsReady = false;
			}
			
#if defined ZR
			if(GetAbilitySlotCount(client) > 0)
			{
				cooldown_time = GetAbilityCooldownM3(client);
					
				if(had_An_ability)
				{
					Format(buffer, sizeof(buffer), "| %s", buffer);
				}	
				
				if(cooldown_time < 0.0)
				{	
					IsReady = true;
					cooldown_time = 0.0;
				}
					
				if(IsReady)
				{
					Format(buffer, sizeof(buffer), "[M3] %s", buffer);
				}
				else
				{
					Format(buffer, sizeof(buffer), "M3 : %.1f %s", cooldown_time, buffer);
				}
				
				had_An_ability = true;
				IsReady = false;
					
			}
			
			int obj=EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
			if(IsValidEntity(obj) && obj>MaxClients)
			{
				cooldown_time = f_BuildingIsNotReady[client] - GameTime;
					
				if(had_An_ability)
				{
					Format(buffer, sizeof(buffer), "| %s", buffer);
				}	
				if(cooldown_time < 0.0)
				{
					IsReady = true;
					cooldown_time = 0.0;
				}
					
				if(IsReady)
				{
					Format(buffer, sizeof(buffer), "[E] %s", buffer);
				}
				else
				{
					Format(buffer, sizeof(buffer), "E : %.1f %s", cooldown_time, buffer);
				}
				IsReady = false;
				had_An_ability = true;
			}
#endif	// ZR
			if(had_An_ability)
			{
				HudY -= 0.035;
				Format(buffer, sizeof(buffer), "%s\n", buffer);
			}
		}
		 
		int red = 200;
		int green = 200;
		int blue = 200;
		
		if(has_mage_weapon[client])
		{
			red = 255;
			green = 0;
			blue = 255;
			
			if(Current_Mana[client] < max_mana[client])
			{
				red = Current_Mana[client] * 255  / (RoundToFloor(max_mana[client]) + 1); //DO NOT DIVIDE BY 0
				
				blue = Current_Mana[client] * 255  / (RoundToFloor(max_mana[client]) + 1);
				
				red = 255 - red;
				
				if(red > 255)
					red = 255;
				
				if(blue > 200) //dont want full blue. bad.
					blue = 200;
					
				if(red < 0)
					red = 0;
					
				if(blue < 0)
					blue = 0;
							
			}
			else
			{
				blue = 200;
				green = 200;
				red = 200;
			}
			
			
			for(int i=1; i<21; i++)
			{
				if(Current_Mana[client] >= max_mana[client]*(i*0.05))
				{
					Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_FULL);
				}
				else if(Current_Mana[client] > max_mana[client]*(i*0.05 - 1.0/60.0))
				{
					Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_PARTFULL);
				}
				else if(Current_Mana[client] > max_mana[client]*(i*0.05 - 1.0/30.0))
				{
					Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_PARTEMPTY);
				}
				else
				{
					Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_EMPTY);
				}
			}
				
			SetGlobalTransTarget(client);
			
			Format(buffer, sizeof(buffer), "%t\n%s", "Current Mana", Current_Mana[client], max_mana[client], mana_regen[client], buffer);
		}

		static bool had_An_ability;
		had_An_ability = false;
		char bufferbuffs[64];
		//BUFFS!
#if defined RPG		
		if(f_HealingPotionDuration[client] > GameTime) //Client has a buff, but which one?
		{
			float time_left = f_HealingPotionDuration[client] - GameTime;
			had_An_ability = true;
			switch(f_HealingPotionEffect[client])
			{
				case MELEE_BUFF_2:
				{
					Format(bufferbuffs, sizeof(bufferbuffs), "[STR! %.0fs] %s",time_left, bufferbuffs);
				}
				case RANGED_BUFF_2: 
				{
					Format(bufferbuffs, sizeof(bufferbuffs), "[DEX! %.0fs] %s",time_left, bufferbuffs);
				}
				case MAGE_BUFF_2:
				{
					Format(bufferbuffs, sizeof(bufferbuffs), "[INT! %.0fs] %s",time_left, bufferbuffs);
				}		
			}
		}
#endif
#if defined ZR	
		if(Wands_Potions_HasBuff(client))
		{
			had_An_ability = true;
			Format(bufferbuffs, sizeof(bufferbuffs), "⌂%s", bufferbuffs);
		}
		if(Wands_Potions_HasTonicBuff(client))
		{
			had_An_ability = true;
			Format(bufferbuffs, sizeof(bufferbuffs), "⌇%s", bufferbuffs);
		}

/*
#define VILLAGE_000	(1 << 0)	// Projectile Speed
#define VILLAGE_200	(1 << 2)	// Fire Rate Bonus
#define VILLAGE_030	(1 << 8)	// MIB
#define VILLAGE_040	(1 << 9)	// Call of Arms
#define VILLAGE_050	(1 << 10)	// Homeland Defense
*/
		static int VillageBuffs;
		VillageBuffs = Building_GetClientVillageFlags(client);

		if(VillageBuffs & VILLAGE_000)
		{
			had_An_ability = true;
			Format(bufferbuffs, sizeof(bufferbuffs), "⌒%s", bufferbuffs);
		}
		if(VillageBuffs & VILLAGE_200)
		{
			had_An_ability = true;
			Format(bufferbuffs, sizeof(bufferbuffs), "⌭%s", bufferbuffs);
		}
		if(VillageBuffs & VILLAGE_030)
		{
			had_An_ability = true;
			Format(bufferbuffs, sizeof(bufferbuffs), "⌬%s", bufferbuffs);
		}
		if(VillageBuffs & VILLAGE_050) //This has priority.
		{
			had_An_ability = true;
			Format(bufferbuffs, sizeof(bufferbuffs), "⍣%s", bufferbuffs);
		}
		else if(VillageBuffs & VILLAGE_040)
		{
			had_An_ability = true;
			Format(bufferbuffs, sizeof(bufferbuffs), "⍤%s", bufferbuffs);
		}
		if(VillageBuffs & VILLAGE_005) //This has priority.
		{
			had_An_ability = true;
			Format(bufferbuffs, sizeof(bufferbuffs), "i%s", bufferbuffs);
		}
#endif
		if(Increaced_Overall_damage_Low[client] > GameTime)
		{
			had_An_ability = true;
			Format(bufferbuffs, sizeof(bufferbuffs), "⌃%s", bufferbuffs);
		}
		if(Resistance_Overall_Low[client] > GameTime)
		{
			had_An_ability = true;
			Format(bufferbuffs, sizeof(bufferbuffs), "⌅%s", bufferbuffs);
		}
		if(f_EmpowerStateOther[client] > GameTime) //Do not show fusion self buff.
		{
			had_An_ability = true;
			Format(bufferbuffs, sizeof(bufferbuffs), "⍋%s", bufferbuffs);
		}
		if(f_HussarBuff[client] > GameTime) //hussar!
		{
			had_An_ability = true;
			Format(bufferbuffs, sizeof(bufferbuffs), "ᐩ%s", bufferbuffs);
		}
		if(f_Ocean_Buff_Stronk_Buff[client] > GameTime) //hussar!
		{
			had_An_ability = true;
			Format(bufferbuffs, sizeof(bufferbuffs), "⍟%s", bufferbuffs);
		}
		else if(f_Ocean_Buff_Weak_Buff[client] > GameTime) //hussar!
		{
			had_An_ability = true;
			Format(bufferbuffs, sizeof(bufferbuffs), "⌾%s", bufferbuffs);
		}
		if(f_BuffBannerNpcBuff[client] > GameTime) //hussar!
		{
			had_An_ability = true;
			Format(bufferbuffs, sizeof(bufferbuffs), "↖%s", bufferbuffs);
		}
		if(f_BattilonsNpcBuff[client] > GameTime) 
		{
			had_An_ability = true;
			Format(bufferbuffs, sizeof(bufferbuffs), "⛨%s", bufferbuffs);
		}
		if(f_AncientBannerNpcBuff[client] > GameTime) 
		{
			had_An_ability = true;
			Format(bufferbuffs, sizeof(bufferbuffs), "➤%s", bufferbuffs);
		}
		if(had_An_ability)
		{
			Format(buffer, sizeof(buffer), "%s\n%s", bufferbuffs, buffer);
			HudY += -0.0345; //correct offset
		}
#if defined RPG
		int xpLevel = LevelToXp(Level[client]);
		int xpNext = LevelToXp(Level[client]+1);
			
		int extra = XP[client]-xpLevel;
		int nextAt = xpNext-xpLevel;
			
	

		if(Tier[client])
		{
			Format(buffer, sizeof(buffer), "%s\n%d | Elite %d Level %d",buffer, extra, Tier[client], Level[client] - GetLevelCap(Tier[client] - 1));
		}
		else
		{
			Format(buffer, sizeof(buffer), "%s\n%d | Level %d",buffer,extra, Level[client]);
		}


		if(Level[client] >= CURRENT_MAX_LEVEL || Level[client] == GetLevelCap(Tier[client]))
		{
			Format(buffer, sizeof(buffer), "%s | E%d\n", buffer, Tier[client] + 1);

			for(int i=1; i<21; i++)
			{
				Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_FULL);
			}

		}
		else
		{
			Format(buffer, sizeof(buffer), "%s | %d\n", buffer, xpNext - XP[client]);
			for(int i=1; i<21; i++)
			{
				if(extra > nextAt*(i*0.05))
				{
					Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_FULL);
				}
				else if(extra > nextAt*(i*0.05 - 1.0/60.0))
				{
					Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_PARTFULL);
				}
				else if(extra > nextAt*(i*0.05 - 1.0/30.0))
				{
					Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_PARTEMPTY);
				}
				else
				{
					Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_EMPTY);
				}
			}
			Format(buffer, sizeof(buffer), "%s\n", buffer);
		}
#endif
		if(buffer[0])
		{
			SetHudTextParams(HudX, HudY, 0.81, red, green, blue, 255);
			ShowSyncHudText(client,  SyncHud_WandMana, "%s", buffer);
		}
	}
	if(delay_hud[client] < GameTime)	
	{
		delay_hud[client] = GameTime + 0.4;

#if defined RPG
		RPG_UpdateHud(client);
#endif

#if defined ZR
		UpdatePlayerPoints(client);
		
		if(LastMann || dieingstate[client] > 0)
		{
			DoOverlay(client, "debug/yuv");
		}

		bool Has_Wave_Showing = false;
		
		if(f_ClientServerShowMessages[client])
		{
			if(GameRules_GetRoundState() != RoundState_TeamWin)
			{
				Has_Wave_Showing = true; //yay :)
				SetGlobalTransTarget(client);
				char WaveString[64];
				if(Rogue_Mode() && Rogue_InSetup())
				{
					Format(WaveString, sizeof(WaveString), "%s | %t", WhatDifficultySetting, "Stage", Rogue_GetRound()+1, Rogue_GetWave()+1); 
				}
				else
				{
					Format(WaveString, sizeof(WaveString), "%s | %t", WhatDifficultySetting, "Wave", CurrentRound+1, CurrentWave+1); 
				}
				i_WhatLevelForHudIsThisClientAt[client] -= 1;
				Handle hKv = CreateKeyValues("Stuff", "title", WaveString);
				KvSetColor(hKv, "color", 0, 255, 0, 255); //green
				KvSetNum(hKv,   "level", i_WhatLevelForHudIsThisClientAt[client]); //im not sure..
				KvSetNum(hKv,   "time",  10); // how long? 
				//	CreateDialog(client, hKv, DialogType_Text); //Cool hud stuff!
				CreateDialog(client, hKv, DialogType_Msg);
				delete hKv;
			}
		}
		else if(f_ShowHudDelayForServerMessage[client] < GetGameTime())
		{
			f_ShowHudDelayForServerMessage[client] = GameTime + 300.0;
			SetGlobalTransTarget(client);
			PrintToChat(client,"%t", "Show Plugin Messages Hint");
		}

		int Armor_Max = 100000;
		int armorEnt = client;
		int vehicle = GetEntPropEnt(client, Prop_Data, "m_hVehicle");
		if(vehicle != -1)
		{
			armorEnt = vehicle;
		}
		else
		{
			int Extra = Armor_Level[client];
			Armor_Max = MaxArmorCalculation(Extra, client, 1.0);
		}

		int red = 255;
		int green = 255;
		int blue = 0;
		if(Armor_Charge[armorEnt] < 0)
		{
			green = 0;
			blue = 255;
		}
		else if(Armor_Charge[armorEnt] < Armor_Max)
		{
			red = Armor_Charge[armorEnt] * 255  / Armor_Max;
			green = Armor_Charge[armorEnt] * 255  / Armor_Max;
				
			red = 255 - red;
		}
		else if(Armor_Charge[armorEnt] > Armor_Max)
		{
			red = 0;
			green = 0;
			blue = 255;
		}
		else
		{
			blue = 255;
		}
		char buffer[64];
		int converted_ref = EntRefToEntIndex(Building_Mounted[client]);
		if(IsValidEntity(converted_ref))
		{	
			float Cooldowntocheck =	Building_Collect_Cooldown[converted_ref][client];
			bool DoSentryCheck = false;
			switch(BuildingIconType(client))
			{
				case 3,4,8,9:
					DoSentryCheck = true;
			}

			if(DoSentryCheck) //all non supportive, like sentry and so on.
			{
				Cooldowntocheck = f_BuildingIsNotReady[client];
			}

			Cooldowntocheck -= GetGameTime();

			if(Cooldowntocheck < 0.0)
			{
				Cooldowntocheck = 0.0;
			}

			switch(BuildingIconType(client))
			{
				case 1: //armor table
				{
					if(Cooldowntocheck > 0.0)
					{
						Format(buffer, sizeof(buffer), "%.1f\nAR\n", Cooldowntocheck);
					}
					else
					{
						Format(buffer, sizeof(buffer), "\nAR\n", Cooldowntocheck);
					}
				}
				case 2: //Ammo box
				{
					if(Cooldowntocheck > 0.0)
					{
						Format(buffer, sizeof(buffer), "%.1f\nAM\n", Cooldowntocheck);
					}
					else
					{
						Format(buffer, sizeof(buffer), "\nAM\n", Cooldowntocheck);
					}
				}
				case 3: //Mortar
				{
					if(Cooldowntocheck > 0.0)
					{
						Format(buffer, sizeof(buffer), "%.1f\nMO\n", Cooldowntocheck);
					}
					else
					{
						Format(buffer, sizeof(buffer), "\nMO\n", Cooldowntocheck);
					}
				}
				case 4: //Railgun
				{
					if(Cooldowntocheck > 0.0)
					{
						Format(buffer, sizeof(buffer), "%.1f\nRA\n", Cooldowntocheck);
					}
					else
					{
						Format(buffer, sizeof(buffer), "\nRA\n", Cooldowntocheck);
					}
				}
				case 5: //Perk
				{
					if(Cooldowntocheck > 0.0)
					{
						Format(buffer, sizeof(buffer), "%.1f\nPE\n", Cooldowntocheck);
					}
					else
					{
						Format(buffer, sizeof(buffer), "\nPE\n", Cooldowntocheck);
					}
				}
				case 6: //pack a punch
				{
					if(Cooldowntocheck > 0.0)
					{
						Format(buffer, sizeof(buffer), "%.1f\nPA\n", Cooldowntocheck);
					}
					else
					{
						Format(buffer, sizeof(buffer), "\nPA\n", Cooldowntocheck);
					}
				}
				case 7: //Healing Station
				{
					if(Cooldowntocheck > 0.0)
					{
						Format(buffer, sizeof(buffer), "%.1f\nHE\n", Cooldowntocheck);
					}
					else
					{
						Format(buffer, sizeof(buffer), "\nHE\n", Cooldowntocheck);
					}
				}
				case 8: //Village
				{
					if(Cooldowntocheck > 0.0)
					{
						Format(buffer, sizeof(buffer), "%.1f\nVI\n", Cooldowntocheck);
					}
					else
					{
						Format(buffer, sizeof(buffer), "\nVI\n", Cooldowntocheck);
					}
				}
				case 9: //Barracks
				{
					if(Cooldowntocheck > 0.0)
					{
						Format(buffer, sizeof(buffer), "%.1f\nBA\n", Cooldowntocheck);
					}
					else
					{
						Format(buffer, sizeof(buffer), "\nBA\n", Cooldowntocheck);
					}
				}
			}
		}
		else
		{
			Format(buffer, sizeof(buffer), "\n\n");	 //so the spacing stays!
		}
		bool Armor_Regenerating = false;
		static int ArmorRegenCounter[MAXTF2PLAYERS];
		if(armorEnt == client && f_ClientArmorRegen[client] > GetGameTime())
		{
			Armor_Regenerating = true;
		}
		if(Armor_Regenerating)
		{
			ArmorRegenCounter[client]++;
			if(ArmorRegenCounter[client] > 3)
			{
				ArmorRegenCounter[client] = 0;
			}
		}
		int armor = abs(Armor_Charge[armorEnt]);
		for(int i=6; i>0; i--)
		{
			if(armor >= Armor_Max*(i*0.1666) || (Armor_Regenerating && ArmorRegenCounter[client] == i))
			{
				Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_FULL);
			}
			else if(armor > Armor_Max*(i*0.1666 - 1.0/60.0))
			{
				Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_PARTFULL);
			}
			else if(armor > Armor_Max*(i*0.1666 - 1.0/30.0))
			{
				Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_PARTEMPTY);
			}
			else
			{
				Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_EMPTY);
			}
			
			if((i % 2) == 1)
			{
				Format(buffer, sizeof(buffer), "%s\n", buffer);
			}
		}
			
		if(i_CurrentEquippedPerk[client] == 6)
		{
			static float slowdown_amount;
			slowdown_amount = f_WidowsWineDebuffPlayerCooldown[client] - GameTime;
			
			if(slowdown_amount < 0.0)
			{
				Format(buffer, sizeof(buffer), "%sWI", buffer, slowdown_amount);
			}
			else
			{
				Format(buffer, sizeof(buffer), "%s%.1f", buffer, slowdown_amount);
			}
		}
		SetHudTextParams(0.175 + f_ArmorHudOffsetY[client], 0.925 + f_ArmorHudOffsetX[client], 0.81, red, green, blue, 255);
		ShowSyncHudText(client, SyncHud_ArmorCounter, "%s", buffer);
			
			
		char HudBuffer[256];
		
		if(!TeutonType[client])
		{
			int downsleft;

			if(b_LeftForDead[client])
			{
				downsleft = 1;
			}
			else
			{
				downsleft = 2;
			}

			downsleft -= i_AmountDowned[client];

			if(Rogue_Mode() && Rogue_InSetup())
			{
				Format(HudBuffer, sizeof(HudBuffer), "%s\n%t\n%t\n%t\n%t", HudBuffer,
				"Credits_Menu", CurrentCash-CashSpent[client], (Resupplies_Supplied[client] * 10) + CashRecievedNonWave[client],	
				"Ammo Crate Supplies", (Ammo_Count_Ready - Ammo_Count_Used[client]),
				PerkNames[i_CurrentEquippedPerk[client]],
				"Australium Ingots", Rogue_GetIngots()
				);
			}
			else
			{
				Format(HudBuffer, sizeof(HudBuffer), "%s\n%t\n%t\n%t\n%t", HudBuffer,
				"Credits_Menu", CurrentCash-CashSpent[client], (Resupplies_Supplied[client] * 10) + CashRecievedNonWave[client],	
				"Ammo Crate Supplies", (Ammo_Count_Ready - Ammo_Count_Used[client]),
				PerkNames[i_CurrentEquippedPerk[client]],
				"Zombies Left", Zombies_Currently_Still_Ongoing
				);
				
			}

			if(f_LeftForDead_Cooldown[client] > GameTime)
			{
				Format(HudBuffer, sizeof(HudBuffer), "%s\n%t", HudBuffer, "Down Cooldown", f_LeftForDead_Cooldown[client] - GameTime);	
			}
			else
			{
				Format(HudBuffer, sizeof(HudBuffer), "%s\n%t", HudBuffer,
					"Downs left", downsleft);	
			}
			if(!Has_Wave_Showing && !Rogue_Mode())
			{
				Format(HudBuffer, sizeof(HudBuffer), "%s\n%s | %t", HudBuffer, WhatDifficultySetting, "Wave", CurrentRound+1, CurrentWave+1);
			}
			if(Store_ActiveCanMulti(client))
			{
				Format(HudBuffer, sizeof(HudBuffer), "%s\n\n%t", HudBuffer, "Press Button To Switch");
			}
		}
		else if (TeutonType[client] == TEUTON_DEAD)
		{
			Format(HudBuffer, sizeof(HudBuffer), "%s %t\n%t",HudBuffer, "You Died Teuton",
				"Zombies Left", Zombies_Currently_Still_Ongoing
			);

			if(!Has_Wave_Showing && !Rogue_Mode())
			{
				Format(HudBuffer, sizeof(HudBuffer), "%s%s | %t",HudBuffer,WhatDifficultySetting, "Wave", CurrentRound+1, CurrentWave+1);		
			}
		}
		else
		{
			Format(HudBuffer, sizeof(HudBuffer), "%s %t\n%t",HudBuffer, "You Wait Teuton",
				"Zombies Left", Zombies_Currently_Still_Ongoing
			);

			if(!Has_Wave_Showing && !Rogue_Mode())
			{
				Format(HudBuffer, sizeof(HudBuffer), "%s%s | %t",HudBuffer,WhatDifficultySetting, "Wave", CurrentRound+1, CurrentWave+1);		
			}
		}
		PrintKeyHintText(client,"%s", HudBuffer);
#endif	// ZR
	}

		
#if defined RPG
		// RPG Level Stuff Here
#endif	// RPG
		
#if defined ZR
	if(f_DelayLookingAtHud[client] < GameTime)
	{
		//Reuse uhh
		//Doesnt reset often enough, fuck clientside.
		if (IsPlayerAlive(client))
		{
			static int entity;
			entity = GetClientPointVisible(client,_,_,_,_,1); //allow them to get info if they stare at something for abit long
			Building_ShowInteractionHud(client, entity);	
			f_DelayLookingAtHud[client] = GameTime + 0.25;	
		}
		else
		{
			f_DelayLookingAtHud[client] = GameTime + 2.0;
		}
	}
	
	Music_PostThink(client);
#endif
}

#if !defined NoSendProxyClass
public void OnPostThinkPost(int client)
{
	if(IsPlayerAlive(client) && CurrentClass[client]!=TFClass_Unknown)
		TF2_SetPlayerClass(client, CurrentClass[client], false, false);
}
#endif

/*
public void OnPreThink(int client)
{
	
	float flPunchVel[3];
	float flHealth = float(GetEntProp(client, Prop_Send, "m_iHealth"));
	float flpercenthpfrommax = flHealth / 200.0;
	
	if(flpercenthpfrommax < 0.25 || LastMann)
	{
		if(flpercenthpfrommax < 0.25 && !is_low_hp[client])
		{
			is_low_hp[client] = true;
			CreateTimer(0.1, Timer_EnableFp_Force, client);	
		}
		
		if(LastMann && flpercenthpfrommax > 0.25)
			flHealth = 100.0;
			
		if (GetEntityFlags(client) & FL_ONGROUND)
		{
			float flVelocity[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", flVelocity);
			float flSpeed = GetVectorLength(flVelocity);
			
			float flPunchIdle[3];
			
			if (flSpeed > 0.0)
			{	
				flPunchIdle[0] = Sine(GameTime * SF2_PLAYER_VIEWBOB_TIMER) * flSpeed/4 * SF2_PLAYER_VIEWBOB_SCALE_X / 1200.0;
				flPunchIdle[1] = Sine(2.0 * GameTime * SF2_PLAYER_VIEWBOB_TIMER) * flSpeed/4 * SF2_PLAYER_VIEWBOB_SCALE_Y / 1200.0;
				flPunchIdle[2] = Sine(1.6 * GameTime * SF2_PLAYER_VIEWBOB_TIMER) * flSpeed/4 * SF2_PLAYER_VIEWBOB_SCALE_Z / 1200.0;
					
				AddVectors(flPunchVel, flPunchIdle, flPunchVel);
				
				// Calculate roll.
				float flForward[3], flVelocityDirection[3];
				GetClientEyeAngles(client, flForward);
				GetVectorAngles(flVelocity, flVelocityDirection);
						
				float flYawDiff = AngleDiff(flForward[1], flVelocityDirection[1]);
				if (FloatAbs(flYawDiff) > 90.0) flYawDiff = AngleDiff(flForward[1] + 180.0, flVelocityDirection[1]) * -1.0;
						
				float flWalkSpeed = 300.0;
				float flRollScalar = flSpeed / flWalkSpeed;
				if (flRollScalar > 1.0) flRollScalar = 1.0;
						
				float flRollScale = (flYawDiff / 90.0) * 0.25 * flRollScalar;
				flPunchIdle[0] = 0.0;
				flPunchIdle[1] = 0.0;
				flPunchIdle[2] = flRollScale * -1.0;
						
				AddVectors(flPunchVel, flPunchIdle, flPunchVel);
			}
		}
		ClientViewPunch(client, flPunchVel);
	}
	else if (flpercenthpfrommax >= 0.25 && is_low_hp[client])
	{
		is_low_hp[client] = false;
		if(thirdperson[client])
		{
			CreateTimer(0.1, Timer_EnableTp_Force, client);	
		}
	}
	
}
*/

#if defined ZR
static float i_WasInUber;
public Action Player_OnTakeDamageAlivePost(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(!(damagetype & DMG_DROWN|DMG_FALL))
	{
		i_PlayerDamaged[victim] += RoundToCeil(damage);
	}
	if(i_WasInUber)
	{
		TF2_AddCondition(victim, TFCond_Ubercharged, i_WasInUber);
	}
	i_WasInUber = 0.0;
	return Plugin_Continue;
}
#endif
public Action Player_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
#if defined ZR
	if(TeutonType[victim])
		return Plugin_Handled;
#endif

	float GameTime = GetGameTime();

	if(f_ClientInvul[victim] > GameTime) //Treat this as if they were a teuton, complete and utter immunity to everything in existance.
	{
		return Plugin_Handled;
	}

#if defined ZR
	if(IsValidEntity(EntRefToEntIndex(RaidBossActive)))
	{
		if(TF2_IsPlayerInCondition(victim, TFCond_Ubercharged))
		{
			i_WasInUber = TF2Util_GetPlayerConditionDuration(victim, TFCond_Ubercharged);
			TF2_RemoveCondition(victim, TFCond_Ubercharged);
			damage *= 0.5;
		}
	}
	if(damagetype & DMG_CRIT)
	{
		damagetype &= ~DMG_CRIT; //Remove Crit Damage at all times, it breaks calculations for no good reason.
	}
#endif

	if(!(damagetype & DMG_DROWN))
	{
		if(IsInvuln(victim))
		{
			f_TimeUntillNormalHeal[victim] = GameTime + 4.0;
			return Plugin_Continue;	
		}
	}
#if defined ZR
	int flHealth = GetEntProp(victim, Prop_Send, "m_iHealth");
	if(dieingstate[victim] > 0)
	{
		if(flHealth < 1)
		{
			if(!(damagetype & DMG_DROWN))
			{
				SDKHooks_TakeDamage(victim, victim, victim, 9999.0, DMG_DROWN, _, _, _, true);
			}
			damage = 9999.0;
			return Plugin_Continue;	
		}
		return Plugin_Handled;
	}
	else
#endif	
	{
		if(victim == attacker)
			return Plugin_Handled;
	}	
#if defined ZR
	float Replicated_Damage;
	Replicated_Damage = Replicate_Damage_Medications(victim, damage, damagetype);
#endif
	
	if(damagetype & DMG_FALL)
	{
			
#if defined RPG
		damage *= 400.0 / float(SDKCall_GetMaxHealth(victim));
#endif
			
#if defined ZR
		Replicated_Damage *= 0.45; //Reduce falldmg by passive overall
		damage *= 0.45;
		if(IsValidEntity(EntRefToEntIndex(RaidBossActive)))
		{
			Replicated_Damage *= 0.75;
			damage *= 0.75;			
		}
		else if(i_SoftShoes[victim] == 1)
#else
		if(i_SoftShoes[victim] == 1)
#endif
		{
				
#if defined ZR
			Replicated_Damage *= 0.9;
#endif
				
			damage *= 0.9;
		}
		if(f_ImmuneToFalldamage[victim] > GameTime)
		{
			damage = 0.0;
		}
	}
	else if(attacker <= MaxClients && attacker > 0 && attacker != 0)
	{
		return Plugin_Handled;	
	}
	else if (attacker != 0)
	{
		LastHitRef[victim] = EntIndexToEntRef(attacker);
	}
		

#if defined RPG	
	if(Ability_Mudrock_Shield_OnTakeDamage(victim))
	{
		damage = 0.0;
		return Plugin_Handled;
	}
#endif
	
#if defined ZR
	if((damagetype & DMG_DROWN) && !b_ThisNpcIsSawrunner[attacker])
#endif
	
#if defined RPG
	if(damagetype & (DMG_DROWN|DMG_DROWNRECOVER))
#endif
	
	{
#if defined ZR
		if(!b_ThisNpcIsSawrunner[attacker])
		{
			NpcStuckZoneWarning(victim, damage);
			Replicated_Damage = damage;
		}
		else
		{
			damage *= 2.0;
			Replicated_Damage *= 2.0;
		}
#endif
	}
	f_TimeUntillNormalHeal[victim] = GameTime + 4.0;
#if defined ZR
	if(Medival_Difficulty_Level != 0.0)
	{
		float difficulty_math = Medival_Difficulty_Level;
		
		difficulty_math = 1.0 - difficulty_math;
		
		damage *= difficulty_math + 1.0; //More damage !! only upto double.
		Replicated_Damage *= difficulty_math + 1.0;
	}
	//freeplay causes more damage taken.
	if(f_FreeplayDamageExtra != 1.0)
	{
		damage *= f_FreeplayDamageExtra;
		Replicated_Damage *= f_FreeplayDamageExtra;
	}
	int Victim_weapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
	if(!b_ThisNpcIsSawrunner[attacker])
#endif
	
	{
		
#if defined ZR
		//FOR ANY WEAPON THAT NEEDS CUSTOM LOGIC WHEN YOURE HURT!!
	
		if(IsValidEntity(Victim_weapon))
		{
			OnTakeDamage_ProvokedAnger(Victim_weapon);
			float modified_damage = Player_OnTakeDamage_Equipped_Weapon_Logic(victim, attacker, inflictor, damage, damagetype, weapon, Victim_weapon, damagePosition);
			
			damage = modified_damage;
			Replicated_Damage = modified_damage;
		}
		if(OnTakeDamage_ShieldLogic(victim, damagetype))
		{
			return Plugin_Handled;
		}
		if(!(damagetype & (DMG_CLUB|DMG_SLASH))) //if its not melee damage
		{
			if(i_CurrentEquippedPerk[attacker] == 5)
			{
				damage *= 1.25;
				Replicated_Damage *= 1.25;
			}
		}
		if(f_HussarBuff[attacker] > GameTime) //hussar!
		{
			damage *= 1.10;
			Replicated_Damage *= 1.10;
		}
		if(f_HussarBuff[victim] > GameTime) //hussar!
		{
			damage *= 0.90;
			Replicated_Damage *= 0.90;
		}
		if(f_PotionShrinkEffect[attacker] > GameTime || (IsValidEntity(inflictor) && f_PotionShrinkEffect[attacker] > GameTime))
		{
			damage *= 0.5; //half the damage when small.
			Replicated_Damage *= 0.5;
		}
		damage *= fl_Extra_Damage[attacker];
		Replicated_Damage *= fl_Extra_Damage[attacker];
		
		//FOR ANY WEAPON THAT NEEDS CUSTOM LOGIC WHEN YOURE HURT!!
		//It will just return the same damage if nothing is done.
	
		if(IsValidEntity(EntRefToEntIndex(RaidBossActive)) && i_HealthBeforeSuit[victim] > 0)
		{
			Replicated_Damage *= 5.0; //when a raid is alive, make quantum armor 8x as bad at tanking.
			damage *= 5.0;	
		}
#endif
#if defined RPG
		if(f_HealingPotionDuration[victim] > GameTime) //Client has a buff, but which one?
		{
			switch(f_HealingPotionEffect[victim])
			{
				case MELEE_BUFF_2: //Take less damage.
				{
					damage *= 0.85;
				}
				default: //Nothing.
				{
					damage *= 1.0;
				}
			}
		}

#endif
		if(f_EmpowerStateOther[victim] > GameTime) //Allow stacking.
		{
			
#if defined ZR
			Replicated_Damage *= 0.93;
#endif
			
			damage *= 0.93;
		}
		if(f_EmpowerStateSelf[victim] > GameTime) //Allow stacking.
		{
			
#if defined ZR
			Replicated_Damage *= 0.9;
#endif
			
			damage *= 0.9;
		}

#if defined ZR
		if(i_CurrentEquippedPerk[victim] == 2)
		{
			Replicated_Damage *= 0.85;
			damage *= 0.85;
		}
#endif
		{
			
#if defined ZR
		//	bool Though_Armor = false;
		
			if(i_CurrentEquippedPerk[victim] == 6)
			{

				//s	int flHealth = GetEntProp(victim, Prop_Send, "m_iHealth");
				int flMaxHealth = SDKCall_GetMaxHealth(victim);
			
				if((damage > float(flMaxHealth / 20) || flHealth < flMaxHealth / 5 || damage > 25.0) && f_WidowsWineDebuffPlayerCooldown[victim] < GameTime) //either too much dmg, or your health is too low.
				{
					f_WidowsWineDebuffPlayerCooldown[victim] = GameTime + 20.0;
					
					float vecVictim[3]; vecVictim = WorldSpaceCenter(victim);
					
					ParticleEffectAt(vecVictim, "peejar_impact_cloud_milk", 0.5);
					
					EmitSoundToAll("weapons/jar_explode.wav", victim, SNDCHAN_AUTO, 80, _, 1.0);
					
					Replicated_Damage *= 0.25;
					damage *= 0.25;
					for(int entitycount; entitycount<i_MaxcountNpc; entitycount++)
					{
						int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs[entitycount]);
						if (IsValidEntity(baseboss_index))
						{
							if(!b_NpcHasDied[baseboss_index])
							{
								if (GetEntProp(victim, Prop_Send, "m_iTeamNum")!=GetEntProp(baseboss_index, Prop_Send, "m_iTeamNum")) 
								{
									float vecTarget[3]; vecTarget = WorldSpaceCenter(baseboss_index);
									
									float flDistanceToTarget = GetVectorDistance(vecVictim, vecTarget, true);
									if(flDistanceToTarget < 90000)
									{
										ParticleEffectAt(vecTarget, "peejar_impact_cloud_milk", 0.5);
										f_WidowsWineDebuff[baseboss_index] = GameTime + FL_WIDOWS_WINE_DURATION;
									}
								}
							}
						}
					}
				}
			}
#endif	// ZR
			
			if(Resistance_Overall_Low[victim] > GameTime)
			{
				
#if defined ZR
				Replicated_Damage *= 0.85;
#endif
				
				damage *= 0.85;
			}
#if defined ZR
			if(i_HealthBeforeSuit[victim] == 0)
			{
				int armorEnt = victim;
				int vehicle = GetEntPropEnt(victim, Prop_Data, "m_hVehicle");
				if(vehicle != -1)
					armorEnt = vehicle;

				if(Armor_Charge[armorEnt] > 0)
				{
					int dmg_through_armour = RoundToCeil(Replicated_Damage * 0.1);
					switch(GetRandomInt(1,3))
					{
						case 1:
							EmitSoundToClient(victim, "physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, 60, _, 0.25, GetRandomInt(95,105));
						
						case 2:
							EmitSoundToClient(victim, "physics/metal/metal_box_impact_bullet2.wav", victim, SNDCHAN_STATIC, 60, _, 0.25, GetRandomInt(95,105));
						
						case 3:
							EmitSoundToClient(victim, "physics/metal/metal_box_impact_bullet3.wav", victim, SNDCHAN_STATIC, 60, _, 0.25, GetRandomInt(95,105));
					}						
					if(RoundToCeil(Replicated_Damage * 0.9) >= Armor_Charge[armorEnt])
					{
						int damage_recieved_after_calc;
						damage_recieved_after_calc = RoundToCeil(Replicated_Damage) - Armor_Charge[armorEnt];
						Armor_Charge[armorEnt] = 0;
						damage = float(damage_recieved_after_calc);
						Replicated_Damage  = float(damage_recieved_after_calc);
					}
					else
					{
						Armor_Charge[armorEnt] -= RoundToCeil(Replicated_Damage * 0.9);
						damage = 0.0;
						damage += float(dmg_through_armour);
						Replicated_Damage = 0.0;
						Replicated_Damage += float(dmg_through_armour);
				//		Though_Armor = true;
					}
				}

				if(armorEnt == victim)
				{
					switch(Armour_Level_Current[victim])
					{
						case 1:
						{
							damage *= 0.9;
							Replicated_Damage *= 0.9;
						}
						case 2:
						{
							damage *= 0.85;
							Replicated_Damage *= 0.85;
						}
						case 3:
						{
							damage *= 0.8;
							Replicated_Damage *= 0.80;
						}
						case 4:
						{
							damage *= 0.75;
							Replicated_Damage *= 0.75;
						}
						default:
						{
							damage *= 1.0;
							Replicated_Damage *= 1.0;
						}
					}
				}
				else
				{
					damage *= 0.65;
					Replicated_Damage *= 0.65;
				}
			}
#endif	// ZR
			
		}
#if defined RPG		
		damage = BeserkHealthArmor_OnTakeDamage(victim, damage);

		damage = RpgCC_ContractExtrasPlayerOnTakeDamage(victim, attacker, damage, damagetype);
#endif
	}
	
#if defined ZR
	if(RoundToCeil(Replicated_Damage) >= flHealth || RoundToCeil(damage) >= flHealth)
	{
		if(i_HealthBeforeSuit[victim] > 0)
		{
			damage = float(flHealth - 1); //survive with 1 hp!, and return their hp later
			TF2_AddCondition(victim, TFCond_UberchargedCanteen, 1.0);
			TF2_AddCondition(victim, TFCond_MegaHeal, 1.0);
			float startPosition[3];
			GetClientAbsOrigin(victim, startPosition);
			startPosition[2] += 25.0;
			makeexplosion(victim, victim, startPosition, "", 0, 0);
			CreateTimer(0.0, QuantumDeactivate, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE); //early cancel out!, save the wearer!

			KillFeed_Show(victim, inflictor, attacker, 0, weapon, damagetype, true);
			return Plugin_Changed;
		}
		else if((LastMann || b_IsAloneOnServer) && f_OneShotProtectionTimer[victim] < GameTime && !SpecterCheckIfAutoRevive(victim))
		{
			damage = float(flHealth - 1); //survive with 1 hp!
			GiveCompleteInvul(victim, 2.0);
			EmitSoundToAll("misc/halloween/spell_overheal.wav", victim, SNDCHAN_STATIC, 80, _, 0.8);
			f_OneShotProtectionTimer[victim] = GameTime + 60.0; // 60 second cooldown

			KillFeed_Show(victim, inflictor, attacker, 0, weapon, damagetype, true);
			return Plugin_Changed;
		}
		else if(!LastMann && !b_IsAloneOnServer || SpecterCheckIfAutoRevive(victim))
		{
			bool Any_Left = false;
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client) && GetClientTeam(client)==2 && !IsFakeClient(client) && TeutonType[client] != TEUTON_WAITING)
				{
					if(victim != client && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE && dieingstate[client] == 0)
					{
						Any_Left = true;
					}
				}
			}
			
			if(!Any_Left && !SpecterCheckIfAutoRevive(victim))
			{
				CheckAlivePlayers(_, victim);

				KillFeed_Show(victim, inflictor, attacker, 0, weapon, damagetype, true);
				return Plugin_Handled;
			}
			
			i_AmountDowned[victim] += 1;
			if(SpecterCheckIfAutoRevive(victim) || (i_AmountDowned[victim] < 3 && !b_LeftForDead[victim] && f_LeftForDead_Cooldown[victim] < GameTime) || (i_AmountDowned[victim] < 2 && b_LeftForDead[victim] && f_LeftForDead_Cooldown[victim] < GameTime))
			{
				//https://github.com/lua9520/source-engine-2018-hl2_src/blob/3bf9df6b2785fa6d951086978a3e66f49427166a/game/shared/mp_shareddefs.cpp
				MakePlayerGiveResponseVoice(victim, 2); //dead!
			//	SetVariantString("TLK_DIED");
			//	AcceptEntityInput(victim, "SpeakResponseConcept");
				if(!Rogue_Mode() && !SpecterCheckIfAutoRevive(victim))
				{
					i_CurrentEquippedPerk[victim] = 0;
				}
				SetEntityHealth(victim, 200);
				if(!b_LeftForDead[victim])
				{
					dieingstate[victim] = 250 / Rogue_ReviveSpeed();
				}
				else
				{
					if(!SpecterCheckIfAutoRevive(victim)) //only if they dont get revived via this perk
					{
						f_LeftForDead_Cooldown[victim] = GameTime + 300.0;
					}
					dieingstate[victim] = 500;
				}
				//cooldown for left for dead.
				SpecterResetHudTime(victim);
				DoOverlay(victim, "debug/yuv");
				SetEntityCollisionGroup(victim, 1);
				CClotBody player = view_as<CClotBody>(victim);
				player.m_bThisEntityIgnored = true;
				Attributes_Set(victim, 489, 0.15);
			//	Attributes_Set(victim, 820, 1.0);
			//	Attributes_Set(victim, 819, 1.0);	
				TF2_AddCondition(victim, TFCond_SpeedBuffAlly, 0.00001);
				int entity;

				bool autoRevive = (b_LeftForDead[victim] || SpecterCheckIfAutoRevive(victim));
				if(!autoRevive)
				{
					entity = EntRefToEntIndex(i_DyingParticleIndication[victim][0]);
					if(entity > MaxClients)
						RemoveEntity(entity);
					
					entity = EntRefToEntIndex(i_DyingParticleIndication[victim][1]);
					if(entity > MaxClients)
						RemoveEntity(entity);


					
					entity = TF2_CreateGlow(victim);
					i_DyingParticleIndication[victim][0] = EntIndexToEntRef(entity);
					SetVariantColor(view_as<int>({0, 255, 0, 255}));
					AcceptEntityInput(entity, "SetGlowColor");

					entity = SpawnFormattedWorldText("DOWNED [R]", {0.0,0.0,90.0}, 10, {0, 255, 0, 255}, victim);
					i_DyingParticleIndication[victim][1] = EntIndexToEntRef(entity);
					b_DyingTextOff[victim] = false;
					
				}
				CreateTimer(0.1, Timer_Dieing, victim, TIMER_REPEAT);
				
				int i;
				while(TF2U_GetWearable(victim, entity, i))
				{
					if(!autoRevive)
					{
						SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
						SetEntityRenderColor(entity, 255, 255, 255, 125);
					}
					else
					{
						SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
						SetEntityRenderColor(entity, 255, 255, 255, 10);
					}
				}
				if(!autoRevive)
				{
					SetEntityRenderMode(victim, RENDER_TRANSCOLOR);
					SetEntityRenderColor(victim, 255, 255, 255, 125);
				}
				else
				{
					SetEntityRenderMode(victim, RENDER_TRANSCOLOR);
					SetEntityRenderColor(victim, 255, 255, 255, 10);
				}

				KillFeed_Show(victim, inflictor, attacker, 0, weapon, damagetype, autoRevive);
				return Plugin_Handled;
			}
			else
			{
				damage = 99999.9;
				i_AmountDowned[victim] = 0;
				return Plugin_Changed;
			}
		}
	}
#endif	// ZR
	
	return Plugin_Changed;
}
#if defined ZR
float Replicate_Damage_Medications(int victim, float damage, int damagetype)
{
	if(TF2_IsPlayerInCondition(victim, TFCond_MarkedForDeathSilent))
	{
		if(!(damagetype & (DMG_CRIT)))
		{
			damage *= 1.35; //Remove crit shit from the calcs!, there are no minicrits here, so i dont have to care
		}
	}
	if(TF2_IsPlayerInCondition(victim, TFCond_DefenseBuffed))
	{
		if(damagetype & (DMG_CRIT))
		{
			damage /= 3.0; //Remove crit shit from the calcs!, there are no minicrits here, so i dont have to care
		}
		damage *= 0.65;
	}
	float value;

	if(damagetype & (DMG_CLUB|DMG_SLASH))
	{
		value = Attributes_FindOnPlayerZR(victim, 206);	// MELEE damage resitance
		if(value)
			damage *= value;
	}
	else
	{
		value = Attributes_FindOnPlayerZR(victim, 205);	// RANGED damage resistance
		if(value)
			damage *= value;
			//Everything else should be counted as ranged reistance probably.
	}
		
	value = Attributes_FindOnPlayerZR(victim, 412);	// Overall damage resistance
	if(value)
		damage *= value;	
		
	return damage;
}
#endif	// ZR

public Action SDKHook_NormalSHook(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if(StrContains(sample, "weapons/dispenser_idle.wav", true) != -1)
	{
		return Plugin_Handled;
	}
	if(StrContains(sample, "vo/halloween_scream", true) != -1)
	{
		return Plugin_Handled;
	}

	if(StrContains(sample, "sentry_", true) != -1)
	{
#if defined ZR
		if(StrContains(sample, "weapons/sentry_scan.wav", true) != -1)
		{
			if(b_SentryIsCustom[entity])
			{
				return Plugin_Handled;
			}
		}
#endif
		volume *= 0.4;
		level = SNDLEVEL_NORMAL;
		
		if(StrContains(sample, "sentry_spot", true) != -1)
			volume *= 0.35;
			
		return Plugin_Changed;
	}
	if(StrContains(sample, "misc/halloween/spell_") != -1)
	{
		volume *= 0.75;
		level = 85;
		return Plugin_Changed;
	}
	if(StrContains(sample, "vo/", true) != -1)
	{
		if(entity > 0 && entity <= MaxClients)
		{
			if(StrContains(sample, "specialcompleted", true) != -1) //These voicelines dont get translated to the correct class!
			{
				return Plugin_Handled;
			}
			if(b_IsPlayerNiko[entity])
			{
				return Plugin_Handled;
			}
		}
	}
	if(StrContains(sample, ")weapons/capper_shoot.wav", true) != -1)
	{
		volume *= 0.45;
		level = 65;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

static int i_PreviousWeapon[MAXTF2PLAYERS];

public void OnWeaponSwitchPost(int client, int weapon)
{
	if(weapon != -1)
	{
		if(EntRefToEntIndex(i_PreviousWeapon[client]) != weapon)
			OnWeaponSwitchPre(client, EntRefToEntIndex(i_PreviousWeapon[client]));
		
		i_PreviousWeapon[client] = EntIndexToEntRef(weapon);
		
		char buffer[36];
		GetEntityClassname(weapon, buffer, sizeof(buffer));
		
#if defined ZR
		Building_WeaponSwitchPost(client, weapon, buffer);
#endif
		
		if(i_SemiAutoWeapon[weapon])
		{
			char classname[64];
			GetEntityClassname(weapon, classname, sizeof(classname));
			int slot = TF2_GetClassnameSlot(classname);
			if(i_SemiAutoWeapon_AmmoCount[client][slot] > 0)
			{
				Attributes_Set(weapon, 821, 0.0);
			}
		}
	}

	Store_WeaponSwitch(client, weapon);

	RequestFrame(OnWeaponSwitchFrame, GetClientUserId(client));

#if defined RPG
	//Attributes_Set(client, 698, 1.0);
	SetEntProp(client, Prop_Send, "m_bWearingSuit", false);
#endif

}

public void OnWeaponSwitchFrame(int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		if(weapon != -1)
		{
			char buffer[36];
			GetEntityClassname(weapon, buffer, sizeof(buffer));
			ViewChange_Switch(client, weapon, buffer);
			// We delay ViewChange_Switch by a frame so it doesn't mess with the regenerate process
		}

#if defined RPG
		TextStore_WeaponSwitch(client, weapon);
		Quests_WeaponSwitch(client, weapon);
#endif

	}
}

public void OnWeaponSwitchPre(int client, int weapon)
{
	if(weapon != -1)
	{
		if(i_SemiAutoWeapon[weapon])
		{
			Attributes_Set(weapon, 821, 0.0);
		}
	}
}

#if defined ZR
static float Player_OnTakeDamage_Equipped_Weapon_Logic(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, int equipped_weapon, float damagePosition[3])
{
	switch(i_CustomWeaponEquipLogic[equipped_weapon])
	{
		case WEAPON_ARK: // weapon_ark
		{
			return Player_OnTakeDamage_Ark(victim, damage, attacker, equipped_weapon, damagePosition);
		}
		case WEAPON_RIOT_SHIELD:
		{
			return Player_OnTakeDamage_Riot_Shield(victim, damage, attacker, equipped_weapon, damagePosition);
		}
		case WEAPON_MLYNAR: // weapon_ark
		{
			return Player_OnTakeDamage_Mlynar(victim, damage, attacker, equipped_weapon);
		}
		case WEAPON_MLYNAR_PAP: // weapon_ark
		{
			return Player_OnTakeDamage_Mlynar(victim, damage, attacker, equipped_weapon, 1);
		}
		case WEAPON_OCEAN, WEAPON_SPECTER:
		{
			return Gladiia_OnTakeDamageAlly(victim, attacker, damage);
		}
		case WEAPON_GLADIIA:
		{
			return Gladiia_OnTakeDamageSelf(victim, attacker, damage);
		}
		case WEAPON_BLEMISHINE:
		{
			return Player_OnTakeDamage_Blemishine(victim, attacker, damage);
		}
		case WEAPON_BOARD:
		{
			return Player_OnTakeDamage_Board(victim, damage, attacker, equipped_weapon, damagePosition);
		}
	}
	return damage;
}
#endif

//problem: tf2 code lazily made it only work for clients, the server doesnt get this information updated all the time now.

void UpdatePlayerFakeModel(int client)
{
	int PlayerModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(PlayerModel > 0)
	{
		//setclass to actual class
	//	TF2_SetPlayerClass(client, CurrentClass[client]);
		SDKCall_RecalculatePlayerBodygroups(client);
		//set back to simulate viewmodel
	//	TF2_SetPlayerClass(client, WeaponClass[client]);
		i_nm_body_client[client] = GetEntProp(client, Prop_Data, "m_nBody");
		SetEntProp(PlayerModel, Prop_Send, "m_nBody", i_nm_body_client[client]);
	}
}

void NpcStuckZoneWarning(int client, float &damage)
{
	SetGlobalTransTarget(client);
	PrintToChat(client, "%t", "Npc Stuck Spot Warning");
	f_TimeUntillNormalHeal[client] = GetGameTime() + 4.0;
	//deduct healing already.
	//first recorded instance of getting stuck after 2 seconds of nnot being stuck.
	damage = 0.0;
	if(f_ClientWasTooLongInsideHurtZone[client] < GetGameTime())
	{
		f_ClientWasTooLongInsideHurtZone[client] = GetGameTime() + 5.0;
		f_ClientWasTooLongInsideHurtZoneDamage[client] = float(SDKCall_GetMaxHealth(client)) * 0.025;
	}
	else if(f_ClientWasTooLongInsideHurtZone[client] <= GetGameTime() + 3.0)
	{
		f_ClientWasTooLongInsideHurtZone[client] = GetGameTime() + 3.0;
		f_ClientWasTooLongInsideHurtZoneDamage[client] *= 2.0;
		damage = f_ClientWasTooLongInsideHurtZoneDamage[client];
	}
}