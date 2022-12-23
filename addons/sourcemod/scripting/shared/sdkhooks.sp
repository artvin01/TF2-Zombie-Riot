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
	
#if defined ZR
	if(CvarSvRollagle)
	{
		CvarSvRollagle.IntValue = i_SvRollAngle[client];
	}
#endif

#if defined RPG
	int maxhealth = SDKCall_GetMaxHealth(client);
	if(GetClientHealth(client) > maxhealth)
		SetEntityHealth(client, maxhealth);
#endif
}

public void OnPostThink(int client)
{
	float gameTime = GetGameTime();
#if !defined NoSendProxyClass
//	if(IsPlayerAlive(client)) //This isnt needed if you dont got send proxy 
#endif
	{
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
		if(CvarSvRollagle)
		{
			int flHealth = GetEntProp(client, Prop_Send, "m_iHealth");
			int flMaxHealth = SDKCall_GetMaxHealth(client);

			float PercentageHealth = float(flHealth) / float(flMaxHealth);

			if(TeutonType[client] == TEUTON_NONE && zr_viewshakeonlowhealth.BoolValue) //If the cvar is off, then the viewshake will not happen.
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

		//	PrintToChatAll("%s",RollAngleValue);

			CvarSvRollagle.ReplicateToClient(client, RollAngleValue); //set replicate back to normal.
		}
#endif	// ZR
		
		if(Mana_Regen_Delay[client] < gameTime)	
		{
			Mana_Regen_Delay[client] = gameTime + 0.4;
			
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
			if(!EscapeMode)
#endif
			
			{
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


				/*
				Current_Mana[client] += RoundToCeil(mana_regen[client]);
					
				if(Current_Mana[client] < RoundToCeil(max_mana[client]))
					Current_Mana[client] = RoundToCeil(max_mana[client]);
				*/
				
				if(Current_Mana[client] < RoundToCeil(max_mana[client]))
				{
					Current_Mana[client] += RoundToCeil(mana_regen[client]);
					
					if(Current_Mana[client] > RoundToCeil(max_mana[client])) //Should only apply during actual regen
						Current_Mana[client] = RoundToCeil(max_mana[client]);
				}
					
				Mana_Hud_Delay[client] = 0.0;
			}
			
#if defined ZR
			else
			{
			//	if(Mana_Regen_Level[weapon])
			//	{				
			//		has_mage_weapon[client] = true;
			//	}
				has_mage_weapon[client] = true;
				max_mana[client] = 1200.0;
				mana_regen[client] = 20.0;
				if(i_CurrentEquippedPerk[client] == 4)
				{
					mana_regen[client] *= 1.35;
				}
				Current_Mana[client] += RoundToCeil(mana_regen[client]);
					
				if(Current_Mana[client] > RoundToCeil(max_mana[client]))
					Current_Mana[client] = RoundToCeil(max_mana[client]);
				
				Mana_Hud_Delay[client] = 0.0;
			}
#endif
			
		}

#if defined ZR
		if(Armor_regen_delay[client] < gameTime)
		{
			Armour_Level_Current[client] = 0;
			int flHealth = GetEntProp(client, Prop_Send, "m_iHealth");
			int flMaxHealth = SDKCall_GetMaxHealth(client);
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
					int newHealth = flHealth + healing_Amount;
						
					if(newHealth >= flMaxHealthJesus)
					{
						healing_Amount -= newHealth - flMaxHealthJesus;
						newHealth = flMaxHealthJesus;
					}
					
					SetEntProp(client, Prop_Send, "m_iHealth", newHealth);
					flHealth = newHealth;
				}
			}
			if(dieingstate[client] == 0)
			{
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
						
						SetEntProp(client, Prop_Send, "m_iHealth", newHealth);
					}
					
				}
			}
			int Armor_Max = 50;
			int Extra = 0;
		
			Extra = Armor_Level[client];
				
			Armor_Max = MaxArmorCalculation(Extra, client, 0.25);
			
			if(Extra == 50)
			{
				Armour_Level_Current[client] = 1;
			}
			if(Extra == 100)
			{
				Armour_Level_Current[client] = 2;
			}
				
			if(Extra == 150)
			{
				Armour_Level_Current[client] = 3;
			}
			if(Extra == 200)
			{
				Armour_Level_Current[client] = 4;
			}
			
			if(Extra >= 50)
			{			
				if(Armor_Charge[client] < Armor_Max)
				{
					if(Extra == 50)
					{
						Armor_Charge[client] += 1;
					}
					else if(Extra == 100)
					{
						Armor_Charge[client] += 2;
					}
					else if(Extra == 150)
					{
						Armor_Charge[client] += 3;
					}
					else if(Extra == 200)
					{
						Armor_Charge[client] += 5;
					}
				}
			}
			Armor_regen_delay[client] = gameTime + 1.0;
		}
#endif	// ZR
		
	}
	
	if(Mana_Hud_Delay[client] < gameTime)	
	{
		Mana_Hud_Delay[client] = gameTime + 0.4;
		char buffer[255];
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		
		if(IsValidEntity(weapon))
		{
			float cooldown_time;
			bool had_An_ability = false;
			bool IsReady = false;
#if defined RPG		
			if(f_HealingPotionDuration[client] > gameTime) //Client has a buff, but which one?
			{
				float time_left = f_HealingPotionDuration[client] - gameTime;
				had_An_ability = true;
				switch(f_HealingPotionEffect[client])
				{
					case MELEE_BUFF_2:
					{
						Format(buffer, sizeof(buffer), "[STR! %.0fs] %s",time_left, buffer);
					}
					case RANGED_BUFF_2: 
					{
						Format(buffer, sizeof(buffer), "[DEX! %.0fs] %s",time_left, buffer);
					}
					case MAGE_BUFF_2:
					{
						Format(buffer, sizeof(buffer), "[INT! %.0fs] %s",time_left, buffer);
					}		
				}
			}
#endif
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
				cooldown_time = f_BuildingIsNotReady[client] - gameTime;
					
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
				Format(buffer, sizeof(buffer), "%s\n", buffer);
			}
		}
		 
		int red = 0;
		int green = 255;
		int blue = 0;
		
		if(has_mage_weapon[client])
		{
			red = 255;
			green = 0;
			blue = 255;
			
			red = Current_Mana[client] * 255  / (RoundToFloor(max_mana[client]) + 1); //DO NOT DIVIDE BY 0
			
			blue = Current_Mana[client] * 255  / (RoundToFloor(max_mana[client]) + 1);
			 
			red = 255 - red;
			
			if(red > 255)
				red = 255;
			
			if(blue > 255)
				blue = 255;
				
			if(red < 0)
				red = 0;
				
			if(blue < 0)
				blue = 0;
			
			
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
		SetHudTextParams(-1.0, 0.85, 0.81, red, green, blue, 255);
		ShowSyncHudText(client,  SyncHud_WandMana, "%s", buffer);
	}
	if(delay_hud[client] < gameTime)	
	{
		delay_hud[client] = gameTime + 0.4;
		
#if defined ZR
		UpdatePlayerPoints(client);
		
		if(LastMann || dieingstate[client] > 0)
		{
			DoOverlay(client, "debug/yuv");
		}
		//Removed "Medi-Kit Cooldown", Heal_CD
		/*
		float Heal_CD = healing_cooldown[client] - gameTime;
		
		if(Heal_CD <= 0.0)
			Heal_CD = 0.0;
		*/
		/*
		float Armor_CD = Armor_Ready[client] - gameTime;
		
		if(Armor_CD <= 0.0)
			Armor_CD = 0.0;
		*/
		bool Has_Wave_Showing = false;
		if(f_ClientServerShowMessages[client])
		{
			Has_Wave_Showing = true; //yay :)
			SetGlobalTransTarget(client);
			char WaveString[64];
			if(EscapeMode)
			{
				Format(WaveString, sizeof(WaveString), "Escape Mode"); 
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
			CloseHandle(hKv);
		}
		else
		{
			if(f_ShowHudDelayForServerMessage[client] < GetGameTime())
			{
				f_ShowHudDelayForServerMessage[client] = GetGameTime() + 300.0;
				PrintToChat(client,"If you wish to see the wave counter in a better way, set ''cl_showpluginmessages'' to 1 in the console!");
			}
		}
		//cl_showpluginmessages
	//	if(Waves_Started())
		{
			int Armor_Max = 50;
			int Extra = 0;
		
			Extra = Armor_Level[client];
				
			Armor_Max = MaxArmorCalculation(Extra, client, 1.0);
			
			int red = 255;
			int green = 255;
			int blue = 0;
			
			red = Armor_Charge[client] * 255  / Armor_Max;
		//	blue = GetEntProp(entity, Prop_Send, "m_iHealth") * 255  / Building_Max_Health[entity];
			green = Armor_Charge[client] * 255  / Armor_Max;
			
			red = 255 - red;
			
			char buffer[64];
			{
				for(int i=10; i>0; i--)
				{
					if(Armor_Charge[client] >= Armor_Max*(i*0.1))
					{
						Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_FULL);
					}
					else if(Armor_Charge[client] > Armor_Max*(i*0.1 - 1.0/60.0))
					{
						Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_PARTFULL);
					}
					else if(Armor_Charge[client] > Armor_Max*(i*0.1 - 1.0/30.0))
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
					float slowdown_amount = f_WidowsWineDebuffPlayerCooldown[client] - GetGameTime();
					
					if(slowdown_amount < 0.0)
					{
						slowdown_amount = 0.0;
					}
					Format(buffer, sizeof(buffer), "%s%.1f", buffer, slowdown_amount);
				}
				SetHudTextParams(0.175, 0.86, 0.81, red, green, blue, 255);
				ShowSyncHudText(client, SyncHud_ArmorCounter, "%s", buffer);
			}
			
		//	SetHudTextParams(0.165, 0.86, 3.01, red, green, blue, 255);
		//	ShowSyncHudText(client,  SyncHud_ArmorCounter, "|%i|", Armor_Charge[client]);
			
			
			
			
			if(!TeutonType[client])
			{
				if(Store_ActiveCanMulti(client))
				{
					if(Has_Wave_Showing)
					{
						PrintKeyHintText(client, "%t\n%t\n%t\n%t\n \n%t",
						"Credits_Menu", CurrentCash-CashSpent[client], (Resupplies_Supplied[client] * 10) + CashRecievedNonWave[client],	
					//	"Wave", CurrentRound+1, CurrentWave+1,
				//		"Armor Counter", Armor_Charge[client],
						"Ammo Crate Supplies", Ammo_Count_Ready[client], //This bugs in russian
				//		"Healing Done", Healing_done_in_total[client],
				//		"Damage Dealt", Damage_dealt_in_total[client],
						PerkNames[i_CurrentEquippedPerk[client]],
						"Zombies Left", Zombies_Currently_Still_Ongoing,
						"Press Button To Switch");
					}
					else
					{
						PrintKeyHintText(client, "%t\n%s | %t\n%t\n%t\n%t\n \n%t",
						"Credits_Menu", CurrentCash-CashSpent[client], (Resupplies_Supplied[client] * 10) + CashRecievedNonWave[client],	
						WhatDifficultySetting, "Wave", CurrentRound+1, CurrentWave+1,
			//			"Armor Counter", Armor_Charge[client],
						"Ammo Crate Supplies", Ammo_Count_Ready[client], 
			//			"Healing Done", Healing_done_in_total[client],
			//			"Damage Dealt", Damage_dealt_in_total[client],
						PerkNames[i_CurrentEquippedPerk[client]],
						"Zombies Left", Zombies_Currently_Still_Ongoing,
						"Press Button To Switch");	
					}
				}
				else if(Has_Wave_Showing)
				{
					PrintKeyHintText(client, "%t\n%t\n%t\n%t",
					"Credits_Menu", CurrentCash-CashSpent[client], (Resupplies_Supplied[client] * 10) + CashRecievedNonWave[client],	
				//	"Wave", CurrentRound+1, CurrentWave+1,
			//		"Armor Counter", Armor_Charge[client],
					"Ammo Crate Supplies", Ammo_Count_Ready[client], //This bugs in russian
			//		"Healing Done", Healing_done_in_total[client],
			//		"Damage Dealt", Damage_dealt_in_total[client],
					PerkNames[i_CurrentEquippedPerk[client]],
					"Zombies Left", Zombies_Currently_Still_Ongoing);
				}
				else
				{
					PrintKeyHintText(client, "%t\n%s | %t\n%t\n%t\n%t",
					"Credits_Menu", CurrentCash-CashSpent[client], (Resupplies_Supplied[client] * 10) + CashRecievedNonWave[client],	
					WhatDifficultySetting, "Wave", CurrentRound+1, CurrentWave+1,
		//			"Armor Counter", Armor_Charge[client],
					"Ammo Crate Supplies", Ammo_Count_Ready[client], 
		//			"Healing Done", Healing_done_in_total[client],
		//			"Damage Dealt", Damage_dealt_in_total[client],
					PerkNames[i_CurrentEquippedPerk[client]],
					"Zombies Left", Zombies_Currently_Still_Ongoing);	
				}
			}
			else if (TeutonType[client] == TEUTON_DEAD)
			{
				if(Has_Wave_Showing)
				{
				PrintKeyHintText(client, "%t\n%t","You Died Teuton",
				//							"Wave", CurrentRound+1, CurrentWave+1,
											"Zombies Left", Zombies_Currently_Still_Ongoing);
				}
				else
				{
					PrintKeyHintText(client, "%t\n%s | %t\n%t","You Died Teuton",
											WhatDifficultySetting, "Wave", CurrentRound+1, CurrentWave+1,
											"Zombies Left", Zombies_Currently_Still_Ongoing);				
				}
			}
			else
			{
				if(Has_Wave_Showing)
				{
				PrintKeyHintText(client, "%t\n%t","You Wait Teuton",
				//							"Wave", CurrentRound+1, CurrentWave+1,
											"Zombies Left", Zombies_Currently_Still_Ongoing);
				}
				else
				{
					PrintKeyHintText(client, "%t\n%s | %t\n%t","You Wait Teuton",
											WhatDifficultySetting, "Wave", CurrentRound+1, CurrentWave+1,
											"Zombies Left", Zombies_Currently_Still_Ongoing);				
				}
			}
		}
#endif	// ZR
		
#if defined RPG
		// RPG Level Stuff Here
#endif	// RPG
	}
	
#if defined ZR
	if(f_DelayLookingAtHud[client] < GetGameTime())
	{
		if (IsPlayerAlive(client))
		{
		//	StartPlayerOnlyLagComp(client, true); //do not lag compensate, its actually way too expensive, and it doesnt really matter most of the time.
			int entity = GetClientPointVisible(client); //allow them to get info if they stare at something for abit long
		//	EndPlayerOnlyLagComp(client);
			Building_ShowInteractionHud(client, entity);
			f_DelayLookingAtHud[client] = GetGameTime() + 0.2;	
		}
		else
		{
			f_DelayLookingAtHud[client] = GetGameTime() + 2.0;
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
				flPunchIdle[0] = Sine(gameTime * SF2_PLAYER_VIEWBOB_TIMER) * flSpeed/4 * SF2_PLAYER_VIEWBOB_SCALE_X / 1200.0;
				flPunchIdle[1] = Sine(2.0 * gameTime * SF2_PLAYER_VIEWBOB_TIMER) * flSpeed/4 * SF2_PLAYER_VIEWBOB_SCALE_Y / 1200.0;
				flPunchIdle[2] = Sine(1.6 * gameTime * SF2_PLAYER_VIEWBOB_TIMER) * flSpeed/4 * SF2_PLAYER_VIEWBOB_SCALE_Z / 1200.0;
					
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
static bool i_WasInUber;
public Action Player_OnTakeDamageAlivePost(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(i_WasInUber)
	{
		TF2_AddCondition(victim, TFCond_Ubercharged, -1.0);
	}
	i_WasInUber = false;
	return Plugin_Continue;
}
#endif

public Action Player_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
#if defined ZR
	if(TeutonType[victim])
		return Plugin_Handled;
#endif
	
	float gameTime = GetGameTime();

	if(f_ClientInvul[victim] > gameTime) //Treat this as if they were a teuton, complete and utter immunity to everything in existance.
	{
		return Plugin_Handled;
	}
	
#if defined ZR
	if(IsValidEntity(EntRefToEntIndex(RaidBossActive)))
	{
		if(TF2_IsPlayerInCondition(victim,TFCond_Ubercharged))
		{
			i_WasInUber = true;
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
			f_TimeUntillNormalHeal[victim] = gameTime + 4.0;
			return Plugin_Continue;	
		}
	}
		
#if defined ZR
	float Replicated_Damage;
	Replicated_Damage = Replicate_Damage_Medications(victim, damage, damagetype);
	
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
	{
		if(victim == attacker)
			return Plugin_Handled;
	}
#endif
	
	if(attacker <= MaxClients && attacker > 0)	
		return Plugin_Handled;	
		
		
	f_TimeUntillNormalHeal[victim] = gameTime + 4.0;
	
#if defined ZR
	if((damagetype & DMG_DROWN) && !b_ThisNpcIsSawrunner[attacker])
#endif
	
#if defined RPG
	if(damagetype & (DMG_DROWN|DMG_DROWNRECOVER))
#endif
	
	{
		
#if defined ZR
		Replicated_Damage *= 2.0;
		damage *= 2.0;
#endif
		
#if defined RPG
		damage *= 5.0;
#endif
		
		return Plugin_Changed;	
	}
	
#if defined ZR
	if(Medival_Difficulty_Level != 0.0)
	{
		float difficulty_math = Medival_Difficulty_Level;
		
		difficulty_math = 1.0 - difficulty_math;
		
		damage *= difficulty_math + 1.0; //More damage !! only upto double.
	}
	
	int Victim_weapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
	if(!b_ThisNpcIsSawrunner[attacker])
#endif
	
	{
		
#if defined ZR
		//FOR ANY WEAPON THAT NEEDS CUSTOM LOGIC WHEN YOURE HURT!!
	
		if(IsValidEntity(Victim_weapon))
		{
			float modified_damage = Player_OnTakeDamage_Equipped_Weapon_Logic(victim, attacker, inflictor, damage, damagetype, weapon, Victim_weapon, damagePosition);
			
			damage = modified_damage;
			Replicated_Damage = modified_damage;
		}
		
		//FOR ANY WEAPON THAT NEEDS CUSTOM LOGIC WHEN YOURE HURT!!
		//It will just return the same damage if nothing is done.
	
		if(IsValidEntity(EntRefToEntIndex(RaidBossActive)) && i_HealthBeforeSuit[victim] > 0)
		{
			if(damagetype & DMG_CLUB)
			{
				Replicated_Damage *= 4.0; //when a raid is alive, make quantum armor 2x as bad at tanking.
				damage *= 4.0;	
			}		
			else //If its melee dmg, 4x, else, 2x
			{
				Replicated_Damage *= 2.0; //when a raid is alive, make quantum armor 2x as bad at tanking.
				damage *= 2.0;	
			}
		}
		
		if(EscapeMode)
		{
			if(IsValidEntity(Victim_weapon))
			{
				if(!i_IsWandWeapon[Victim_weapon] && !i_IsWrench[Victim_weapon]) //Make sure its not wand.
				{
					char melee_classname[64];
					GetEntityClassname(Victim_weapon, melee_classname, 64);
					
					if (TFWeaponSlot_Melee == TF2_GetClassnameSlot(melee_classname))
					{
						Replicated_Damage *= 0.45;
						damage *= 0.45;
					}
				}
			}
		}
#endif
#if defined RPG
		if(f_HealingPotionDuration[victim] > gameTime) //Client has a buff, but which one?
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
		if(f_EmpowerStateOther[victim] > gameTime) //Allow stacking.
		{
			
#if defined ZR
			Replicated_Damage *= 0.93;
#endif
			
			damage *= 0.93;
		}
		if(f_EmpowerStateSelf[victim] > gameTime) //Allow stacking.
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
		
		if(damagetype & DMG_FALL)
		{
			
#if defined RPG
			damage *= 400.0 / float(SDKCall_GetMaxHealth(victim));
#endif
			
#if defined ZR
			Replicated_Damage *= 0.65; //Reduce falldmg by passive overall
			damage *= 0.65;
			if(IsValidEntity(EntRefToEntIndex(RaidBossActive)))
			{
				Replicated_Damage *= 0.2;
				damage *= 0.2;			
			}
			else if(i_SoftShoes[victim] == 1)
#endif
			
			if(i_SoftShoes[victim] == 1)
			{
				
#if defined ZR
				Replicated_Damage *= 0.65;
#endif
				
				damage *= 0.65;
			}
			if(f_ImmuneToFalldamage[victim] > GetGameTime())
			{
				damage = 0.0;
			}
		}
		else
		{
			
#if defined ZR
		//	bool Though_Armor = false;
		
			if(i_CurrentEquippedPerk[victim] == 6)
			{

				//s	int flHealth = GetEntProp(victim, Prop_Send, "m_iHealth");
				int flMaxHealth = SDKCall_GetMaxHealth(victim);
			
				if((damage > float(flMaxHealth / 20) || flHealth < flMaxHealth / 5 || damage > 25.0) && f_WidowsWineDebuffPlayerCooldown[victim] < GetGameTime()) //either too much dmg, or your health is too low.
				{
					f_WidowsWineDebuffPlayerCooldown[victim] = GetGameTime() + 20.0;
					
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
										f_WidowsWineDebuff[baseboss_index] = GetGameTime() + FL_WIDOWS_WINE_DURATION;
									}
								}
							}
						}
					}
				}
			}
#endif	// ZR
			
			if(Resistance_Overall_Low[victim] > gameTime)
			{
				
#if defined ZR
				Replicated_Damage *= 0.85;
#endif
				
				damage *= 0.85;
			}
			
#if defined ZR
			if(i_HealthBeforeSuit[victim] == 0)
			{
				if(Armor_Charge[victim] > 0)
				{
					int dmg_through_armour = RoundToCeil(Replicated_Damage * 0.1);
					
					if(RoundToCeil(Replicated_Damage * 0.9) >= Armor_Charge[victim])
					{
						int damage_recieved_after_calc;
						damage_recieved_after_calc = RoundToCeil(Replicated_Damage) - Armor_Charge[victim];
						Armor_Charge[victim] = 0;
						damage = float(damage_recieved_after_calc);
						Replicated_Damage  = float(damage_recieved_after_calc);
						EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, 60, _, 0.25);
					}
					else
					{
						Armor_Charge[victim] -= RoundToCeil(Replicated_Damage * 0.9);
						damage = 0.0;
						damage += float(dmg_through_armour);
						Replicated_Damage = 0.0;
						Replicated_Damage += float(dmg_through_armour);
				//		Though_Armor = true;
					}
				}
				switch(Armour_Level_Current[victim])
				{
					case 1:
					{
						damage *= 0.9;
						Replicated_Damage *= 0.9;
					//	if(Though_Armor)
					//		EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, 60, _, 0.15);
					}
					case 2:
					{
						damage *= 0.85;
						Replicated_Damage *= 0.85;
					//	if(Though_Armor)
					//		EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, 60, _, 0.15);
					}
					case 3:
					{
						damage *= 0.8;
						Replicated_Damage *= 0.80;
					//	if(Though_Armor)
					//		EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, 60, _, 0.15);
					}
					case 4:
					{
						damage *= 0.75;
						Replicated_Damage *= 0.75;
					//	if(Though_Armor)
					//		EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, 60, _, 0.15);
					}
					default:
					{
						damage *= 1.0;
						Replicated_Damage *= 1.0;
					}
				}
			}
#endif	// ZR
			
		}
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
			return Plugin_Changed;
		}
		else if((LastMann || b_IsAloneOnServer) && f_OneShotProtectionTimer[victim] < GetGameTime())
		{
			damage = float(flHealth - 1); //survive with 1 hp!
			GiveCompleteInvul(victim, 2.0);
			EmitSoundToAll("misc/halloween/spell_overheal.wav", victim, SNDCHAN_STATIC, 80, _, 0.8);
			f_OneShotProtectionTimer[victim] = gameTime + 60.0; // 60 second cooldown
			return Plugin_Changed;
		}
		else if(!LastMann && !b_IsAloneOnServer)
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
			
			if(!Any_Left)
			{
				CheckAlivePlayers(_, victim);
				return Plugin_Handled;
			}
			
			i_AmountDowned[victim] += 1;
			if((i_AmountDowned[victim] < 3 && !b_LeftForDead[victim]) || (i_AmountDowned[victim] < 2 && b_LeftForDead[victim]))
			{
				i_CurrentEquippedPerk[victim] = 0;
				SetEntityHealth(victim, 200);
				if(!b_LeftForDead[victim])
				{
					dieingstate[victim] = 250;
				}
				else
				{
					dieingstate[victim] = 500;
				}
				SetEntityCollisionGroup(victim, 1);
				CClotBody player = view_as<CClotBody>(victim);
				player.m_bThisEntityIgnored = true;
				TF2Attrib_SetByDefIndex(victim, 489, 0.15);
				TF2Attrib_SetByDefIndex(victim, 820, 1.0);
				TF2Attrib_SetByDefIndex(victim, 819, 1.0);	
				TF2_AddCondition(victim, TFCond_SpeedBuffAlly, 0.00001);
				int entity;
				if(!b_LeftForDead[victim])
				{
					entity = EntRefToEntIndex(i_DyingParticleIndication[victim]);
					if(entity > MaxClients)
						RemoveEntity(entity);
					
					entity = TF2_CreateGlow(victim);
					i_DyingParticleIndication[victim] = EntIndexToEntRef(entity);
					
					SetVariantColor(view_as<int>({0, 255, 0, 255}));
					AcceptEntityInput(entity, "SetGlowColor");
				}
				CreateTimer(0.1, Timer_Dieing, victim, TIMER_REPEAT);
				
				int i;
				while(TF2U_GetWearable(victim, entity, i))
				{
					if(!b_LeftForDead[victim])
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
				if(!b_LeftForDead[victim])
				{
					SetEntityRenderMode(victim, RENDER_TRANSCOLOR);
					SetEntityRenderColor(victim, 255, 255, 255, 125);
				}
				else
				{
					SetEntityRenderMode(victim, RENDER_TRANSCOLOR);
					SetEntityRenderColor(victim, 255, 255, 255, 10);
				}
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
		value = Attributes_FindOnPlayer(victim, 206);	// MELEE damage resitance
		if(value)
			damage *= value;
	}
	else
	{
		value = Attributes_FindOnPlayer(victim, 205);	// RANGED damage resistance
		if(value)
			damage *= value;
			//Everything else should be counted as ranged reistance probably.
	}
		
	value = Attributes_FindOnPlayer(victim, 412);	// Overall damage resistance
	if(value)
		damage *= value;	
		
	return damage;
}
#endif	// ZR

public Action SDKHook_NormalSHook(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if(StrContains(sample, "sentry_", true) != -1)
	{
		volume *= 0.4;
		level = SNDLEVEL_NORMAL;
		
		if(StrContains(sample, "sentry_spot", true) != -1)
			volume *= 0.35;
			
		return Plugin_Changed;
	}
	if(StrContains(sample, "misc/halloween/spell_") != -1)
	{
		volume *= 0.75;
		level = SNDLEVEL_NORMAL;
		return Plugin_Changed;
	}
	if(StrContains(sample, "vo/", true) != -1)
	{
		if(entity > 0 && entity <= MaxClients)
		{
			if(b_IsPlayerNiko[entity])
			{
				return Plugin_Handled;
			}
		}
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
		
		ViewChange_Switch(client, weapon, buffer);
		
		if(i_SemiAutoWeapon[weapon])
		{
			char classname[64];
			GetEntityClassname(weapon, classname, sizeof(classname));
			int slot = TF2_GetClassnameSlot(classname);
			if(i_SemiAutoWeapon_AmmoCount[client][slot] > 0)
			{
				TF2Attrib_SetByDefIndex(weapon, 821, 0.0);
			}
		}
	}

	Store_WeaponSwitch(client, weapon);

#if defined RPG
	RequestFrame(OnWeaponSwitchFrame, GetClientUserId(client));
	//TF2Attrib_SetByDefIndex(client, 698, 1.0);
	SetEntProp(client, Prop_Send, "m_bWearingSuit", false);
#endif

}

#if defined RPG
public void OnWeaponSwitchFrame(int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		TextStore_WeaponSwitch(client, weapon);
		Quests_WeaponSwitch(client, weapon);
	}
}
#endif

public void OnWeaponSwitchPre(int client, int weapon)
{
	if(weapon != -1)
	{
		if(i_SemiAutoWeapon[weapon])
		{
			TF2Attrib_SetByDefIndex(weapon, 821, 0.0);
		}
	}
}

/*
static void ClientViewPunch(int client, const float angleOffset[3])
{
	if (g_offsPlayerPunchAngleVel == -1) return;
	
	float flOffset[3];
	for (int i = 0; i < 3; i++) flOffset[i] = angleOffset[i];
	ScaleVector(flOffset, 20.0);
	
	
	if (!IsFakeClient(client))
	{
		// Latency compensation.
		float flLatency = GetClientLatency(client, NetFlow_Outgoing);
		float flLatencyCalcDiff = 60.0 * Pow(flLatency, 2.0);
		
		for (int i = 0; i < 3; i++) flOffset[i] += (flOffset[i] * flLatencyCalcDiff);
	}
	
	
	float flAngleVel[3];
	GetEntDataVector(client, g_offsPlayerPunchAngleVel, flAngleVel);
	AddVectors(flAngleVel, flOffset, flOffset);
	SetEntDataVector(client, g_offsPlayerPunchAngleVel, flOffset, true);
}
*/

#if defined ZR
static float Player_OnTakeDamage_Equipped_Weapon_Logic(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, int equipped_weapon, float damagePosition[3])
{
	switch(i_CustomWeaponEquipLogic[equipped_weapon])
	{
		case WEAPON_ARK: // weapon_ark
		{
			return Player_OnTakeDamage_Ark(victim, damage, attacker, equipped_weapon, damagePosition);
		}
	}
	return damage;
}
#endif