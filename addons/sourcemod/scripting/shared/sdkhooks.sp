#pragma semicolon 1
#pragma newdecls required

static float i_WasInUber[MAXTF2PLAYERS] = {0.0,0.0,0.0};
static float i_WasInMarkedForDeath[MAXTF2PLAYERS] = {0.0,0.0,0.0};
static float i_WasInDefenseBuff[MAXTF2PLAYERS] = {0.0,0.0,0.0};
static float i_WasInJarate[MAXTF2PLAYERS] = {0.0,0.0,0.0};
static float f_EntityHazardCheckDelay[MAXTF2PLAYERS];

bool Client_Had_ArmorDebuff[MAXTF2PLAYERS];

#if defined ZR
int Armor_WearableModelIndex;
#endif

void SDKHooks_ClearAll()
{
#if defined ZR
	Zero(Armor_regen_delay);
#endif
	
	for (int client = 1; client <= MaxClients; client++)
	{
		i_WhatLevelForHudIsThisClientAt[client] = 2000000000; //two billion
	}
	Zero(f_EntityHazardCheckDelay);
	
	Zero(i_WasInUber);
	Zero(i_WasInMarkedForDeath);
	Zero(i_WasInDefenseBuff);
	Zero(i_WasInJarate);
	Zero(Client_Had_ArmorDebuff);
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
	
#if !defined NOG
	AddNormalSoundHook(SDKHook_NormalSHook);
#endif
}

void SDKHook_MapStart()
{
	Zero(f_EntityIsStairAbusing);
	#if defined ZR
	Zero(Mana_Loss_Delay);
	Zero(Mana_Regen_Block_Timer);
	Armor_WearableModelIndex = PrecacheModel("models/effects/resist_shield/resist_shield.mdl", true);
	int entity = FindEntityByClassname(-1, "tf_player_manager");
	if(entity != -1)
		SDKHook(entity, SDKHook_ThinkPost, SDKHook_ScoreThink);
	#endif
}


#if defined ZR
public void SDKHook_ScoreThink(int entity)
{
	static int offset = -1;
	
	static int offset_Damage = -1;
	static int offset_Damage_Boss = -1;
	static int offset_Cash = -1;
	static int offset_Healing = -1;


		
	if(offset == -1) 
		offset = FindSendPropInfo("CTFPlayerResource", "m_iTotalScore");

	//damage
	if(offset_Damage == -1) 
		offset_Damage = FindSendPropInfo("CTFPlayerResource", "m_iDamage");

	//tank
	if(offset_Damage_Boss == -1) 
		offset_Damage_Boss = FindSendPropInfo("CTFPlayerResource", "m_iDamageBoss");

	//Current cash (laugh at the horder)
	if(offset_Cash == -1) 
		offset_Cash = FindSendPropInfo("CTFPlayerResource", "m_iCurrencyCollected");

	int CashCurrentlyOwned[MAXTF2PLAYERS];
	for(int client=1; client<=MaxClients; client++)
	{
		CashCurrentlyOwned[client] = CurrentCash-CashSpent[client];
	}

	//healing done
	if(offset_Healing == -1) 
		offset_Healing = FindSendPropInfo("CTFPlayerResource", "m_iHealing");
	
	SetEntDataArray(entity, offset, PlayerPoints, MaxClients + 1);
	SetEntDataArray(entity, offset_Damage, i_Damage_dealt_in_total, MaxClients + 1);
	SetEntDataArray(entity, offset_Damage_Boss, i_PlayerDamaged, MaxClients + 1);
	SetEntDataArray(entity, offset_Healing, Healing_done_in_total, MaxClients + 1);
	SetEntDataArray(entity, offset_Cash, CashCurrentlyOwned, MaxClients + 1);

	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && !b_IsPlayerABot[client])
		{
			SetEntProp(client, Prop_Data, "m_iFrags", i_KillsMade[client]);
			SetEntProp(client, Prop_Send, "m_iHealPoints", Healing_done_in_total[client]);
			SetEntProp(client, Prop_Send, "m_iBackstabs", i_Backstabs[client]);
			SetEntProp(client, Prop_Send, "m_iHeadshots", i_Headshots[client]);
			SetEntProp(client, Prop_Send, "m_iDefenses", RoundToCeil(float(i_BarricadeHasBeenDamaged[client]) * 0.001));
		}
	}	
}
#endif

stock void SDKHook_HookClient(int client)
{
#if defined ZR
	SDKUnhook(client, SDKHook_PreThinkPost, OnPreThinkPost);
	SDKHook(client, SDKHook_PreThinkPost, OnPreThinkPost);
	SDKUnhook(client, SDKHook_PostThink, OnPostThink);
	SDKUnhook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost);
	SDKHook(client, SDKHook_PostThink, OnPostThink);
	SDKHook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost);

	SDKUnhook(client, SDKHook_PostThinkPost, OnPostThinkPost);
	SDKHook(client, SDKHook_PostThinkPost, OnPostThinkPost);
#endif

#if defined NOG
	SDKUnhook(client, SDKHook_PostThink, OnPostThink_OnlyHurtHud);
	SDKHook(client, SDKHook_PostThink, OnPostThink_OnlyHurtHud);
#endif

#if !defined RTS
	SDKUnhook(client, SDKHook_OnTakeDamageAlivePost, Player_OnTakeDamageAlivePost);
	SDKHook(client, SDKHook_OnTakeDamageAlivePost, Player_OnTakeDamageAlivePost);
	SDKUnhook(client, SDKHook_OnTakeDamage, Player_OnTakeDamage);
	SDKHook(client, SDKHook_OnTakeDamage, Player_OnTakeDamage);
#endif
}

#if defined ZR
public void OnPreThinkPost(int client)
{
	if(b_NetworkedCrouch[client])
	{
		SetEntProp(client, Prop_Send, "m_bAllowAutoMovement", 1);
	}
	if(CvarMpSolidObjects)
	{
		if(RaidbossIgnoreBuildingsLogic(1))
		{
			if(i_PreviousBuildingCollision[client] == -1)
			{
				i_PreviousBuildingCollision[client] = b_PhaseThroughBuildingsPerma[client];
			}
			b_PhaseThroughBuildingsPerma[client] = 2;
		}
		else
		{
			if(i_PreviousBuildingCollision[client] != -1)
			{
				if(i_PreviousBuildingCollision[client] != 2)
				{
					SDKUnhook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
					SDKHook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
				}
				b_PhaseThroughBuildingsPerma[client] = i_PreviousBuildingCollision[client];
			}
			i_PreviousBuildingCollision[client] = -1;
		}
		
		if(b_PhaseThroughBuildingsPerma[client] == 0)
		{
			CvarMpSolidObjects.IntValue	= b_PhasesThroughBuildingsCurrently[client] ? 0 : 1;
		}
		else
		{
			CvarMpSolidObjects.IntValue = 0;
		}
	}

	CvarAirAcclerate.FloatValue = b_AntiSlopeCamp[client] ? 2.0 : 10.0;
/*
#if defined ZR
	if(CvarSvRollagle)
	{
		CvarSvRollagle.IntValue = i_SvRollAngle[client];
	}
#endif
*/
}
#endif

#if defined NOG
public void OnPostThink_OnlyHurtHud(int client)
{
	if(b_DisplayDamageHud[client])
	{
		b_DisplayDamageHud[client] = false;
		if(zr_showdamagehud.BoolValue)
			Calculate_And_Display_HP_Hud(client);
	}
}

#endif

#if defined ZR
public void OnPostThink(int client)
{
	float GameTime = GetGameTime();
	if(b_EntityIsStairAbusing[client])
	{
		//damage is 50 to simulate a normal trigger hurt.
		if(f_EntityIsStairAbusing[client] < GetGameTime())
		{
			f_EntityIsStairAbusing[client] = GetGameTime() + 0.5;
			float damageTrigger = 5.0;
			NpcStuckZoneWarning(client, damageTrigger, 1);	
			if(damageTrigger > 1.0)
			{
				SDKHooks_TakeDamage(client, 0, 0, damageTrigger, DMG_DROWN|DMG_PREVENT_PHYSICS_FORCE, -1,_,_,_,ZR_STAIR_ANTI_ABUSE_DAMAGE);
			}
		}
	}

	if(GetTeam(client) == 2)
	{
		if(dieingstate[client] != 0 || TeutonType[client] != TEUTON_NONE)
		{
			if(f_EntityHazardCheckDelay[client] < GetGameTime())
			{
				EntityIsInHazard_Teleport(client);
				f_EntityHazardCheckDelay[client] = GetGameTime() + 0.25;
			}
		}
		SaveLastValidPositionEntity(client);
	
	}
	if(b_DisplayDamageHud[client])
	{
		b_DisplayDamageHud[client] = false;
		Calculate_And_Display_HP_Hud(client);
	}
	if(b_PhaseThroughBuildingsPerma[client] == 2)
	{
		if(ReplicateClient_Tfsolidobjects[client] != 0)
		{
			ReplicateClient_Tfsolidobjects[client] = 0;
			CvarMpSolidObjects.ReplicateToClient(client, "0");
		}
	}
	else
	{
		if(b_PhaseThroughBuildingsPerma[client] == 1)
		{
			b_PhaseThroughBuildingsPerma[client] = 0;
			if(ReplicateClient_Tfsolidobjects[client] != 1)
			{
				ReplicateClient_Tfsolidobjects[client] = 1;
				CvarMpSolidObjects.ReplicateToClient(client, "1"); //set replicate back to normal.
			}
		}
	}
	if(b_AntiSlopeCamp[client])
	{	
		if(ReplicateClient_Svairaccelerate[client] != 2.0)
		{
			ReplicateClient_Svairaccelerate[client] = 2.0;
			CvarAirAcclerate.ReplicateToClient(client, "2.0"); //set down
		}
	}
	else
	{
		if(ReplicateClient_Svairaccelerate[client] != 10.0)
		{
			ReplicateClient_Svairaccelerate[client] = 10.0;
			CvarAirAcclerate.ReplicateToClient(client, "10.0"); //set replicate back to normal.
		}
	}
		
	//Reduce knockback when airborn, this is to fix issues regarding flying way too high up, making it really easy to tank groups!
	bool WasAirborn = false;

	if (!(GetEntityFlags(client) & FL_ONGROUND))
	{
		WasAirborn = true;
	}
	else
	{
		int RefGround =  GetEntPropEnt(client, Prop_Send, "m_hGroundEntity");
		int GroundEntity = EntRefToEntIndex(RefGround);
		if(GroundEntity > 0 && GroundEntity < MAXENTITIES)
		{
			if(!b_NpcHasDied[GroundEntity])
			{
				WasAirborn = true;
			}
		}
	}

	if(WasAirborn && !b_PlayerWasAirbornKnockbackReduction[client])
	{
		int EntityWearable = EntRefToEntIndex(i_StickyAccessoryLogicItem[client]);
		if(EntityWearable > 0)
		{
			b_PlayerWasAirbornKnockbackReduction[client] = true;
			Attributes_Set(EntityWearable, 252, 0.5);
		}
	}
	else if(!WasAirborn && b_PlayerWasAirbornKnockbackReduction[client])
	{
		int EntityWearable = EntRefToEntIndex(i_StickyAccessoryLogicItem[client]);
		if(EntityWearable > 0)
		{
			b_PlayerWasAirbornKnockbackReduction[client] = false;
			Attributes_Set(EntityWearable, 252, 1.0);
		}
	}
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
					PercentageHealth *= 0.5;
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

			if(ReplicateClient_RollAngle[client] != i_SvRollAngle[client])
			{
				ReplicateClient_RollAngle[client] = i_SvRollAngle[client];
				char RollAngleValue[4];
				IntToString(i_SvRollAngle[client], RollAngleValue, sizeof(RollAngleValue));
				CvarSvRollagle.ReplicateToClient(client, RollAngleValue); //set replicate back to normal.
			}
		}
		else
		{
			RollAngle_Regen_Delay[client] = GameTime + 5.0;
			if(ReplicateClient_RollAngle[client] != 0)
			{
				ReplicateClient_RollAngle[client] = 0;
				CvarSvRollagle.ReplicateToClient(client, "0"); //set replicate back to normal.
			}
		}
	}

	if(Mana_Regen_Delay[client] < GameTime || (b_AggreviatedSilence[client] && Mana_Regen_Delay_Aggreviated[client] < GameTime))
	{
		Mana_Regen_Delay[client] = GameTime + 0.4;
		Mana_Regen_Delay_Aggreviated[client] = GameTime + 0.4;
			
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

		max_mana[client] = 400.0;
		mana_regen[client] = 10.0;
			
		if(LastMann)
		{
			if(!b_AggreviatedSilence[client])	
				mana_regen[client] *= 20.0; // 20x the regen to help last man mage cus they really suck otherwise alone.
			else
				mana_regen[client] *= 10.0; // only 10x the regen as they always regen.
		}
				
		if(i_CurrentEquippedPerk[client] == 4)
		{
			mana_regen[client] *= 1.35;
		}

		mana_regen[client] *= Mana_Regen_Level[client];
		max_mana[client] *= Mana_Regen_Level[client];

		if(b_AggreviatedSilence[client])	
		{
			mana_regen[client] *= 0.30;
		}
	
		if(Current_Mana[client] < RoundToCeil(max_mana[client]) && Mana_Regen_Block_Timer[client] < GameTime)
		{
			Current_Mana[client] += RoundToCeil(mana_regen[client]);
				
			if(Current_Mana[client] > RoundToCeil(max_mana[client])) //Should only apply during actual regen
				Current_Mana[client] = RoundToCeil(max_mana[client]);
		}
					
		Mana_Hud_Delay[client] = 0.0;
	}

	if(Current_Mana[client] > RoundToCeil(max_mana[client]+10.0))	//A part of Ruina's special mana "corrosion"
	{
		//the +10 is for rounding errors.
		if(Mana_Loss_Delay[client] < GameTime)
		{
			Mana_Loss_Delay[client] = GameTime + 0.4;
		
			float Mana_Loss = 10.0;
			if(Mana_Regen_Level[client])
				Mana_Loss *=Mana_Regen_Level[client];

			float OverMana_Ratio = Current_Mana[client]/max_mana[client];	//the more overmana you have the slower it decays!

			Mana_Loss /=OverMana_Ratio;

			if(has_mage_weapon[client])
			{
				Current_Mana[client] -= RoundToCeil(Mana_Loss);	//Passively lose your overmana! if you are a mage you lose this overmana slower
			}
			else
			{
				Current_Mana[client] -= RoundToCeil(Mana_Loss*1.5);	//Passively lose your overmana!	if your not a mage you lose it faster
			}

			if(Current_Mana[client] < RoundToCeil(max_mana[client])) //if the mana becomes less then the normal max mana due to mana loss, set it to max mana!
				Current_Mana[client] = RoundToCeil(max_mana[client]);

			//CPrintToChatAll("Regen neg1: %i", RoundToCeil(Mana_Loss));
			//CPrintToChatAll("Regen neg2: %i", RoundToCeil(Mana_Loss*1.5));
		}
		has_mage_weapon[client] = true;	//now force the mana hud even if your not a mage. this only applies to non mages if you got overmana, and the only way you can get overmana without a mage weapon is if you got hit by ruina's debuff.
	}

	if(Armor_regen_delay[client] < GameTime)
	{
		Armour_Level_Current[client] = 0;

		int healing_Amount;
		
		if(!Rogue_Paradox_JesusBlessing(client, healing_Amount))
		{
			if(Jesus_Blessing[client] == 1)
			{
				if(dieingstate[client] > 0)
				{
					healing_Amount = HealEntityGlobal(client, client, 3.0, 0.5, 0.0, HEAL_SELFHEAL);	
				}
				else
				{
					healing_Amount = HealEntityGlobal(client, client, float(SDKCall_GetMaxHealth(client)) / 100.0, 0.5, 0.0, HEAL_SELFHEAL);	
				}
			}
		}

		if(Saga_RegenHealth(client))
		{
			if(dieingstate[client] == 0)
			{
				healing_Amount += HealEntityGlobal(client, client, 10.0, 1.0, 0.0, HEAL_SELFHEAL);	
			}
		}
		
		if(dieingstate[client] == 0)
		{
			Rogue_HealingSalve(client);
			Rogue_HandSupport_HealTick(client);
			if(i_BadHealthRegen[client] == 1)
			{
				healing_Amount += HealEntityGlobal(client, client, 1.0, 1.0, 0.0, HEAL_SELFHEAL);
			}
			if(b_NemesisHeart[client])
			{
				healing_Amount += HealEntityGlobal(client, client, 1.0, 1.0, 0.0, HEAL_SELFHEAL);
			}
		}

		if(healing_Amount)
			ApplyHealEvent(client, healing_Amount);

		Armor_regen_delay[client] = GameTime + 1.0;
	}
	if(Mana_Hud_Delay[client] < GameTime)
	{
		SetGlobalTransTarget(client);
		char buffer[255];
		float HudY = 0.95;
		float HudX = -1.0;
	
		HudX += f_WeaponHudOffsetY[client];
		HudY += f_WeaponHudOffsetX[client];

		Mana_Hud_Delay[client] = GameTime + 0.4;
		static bool had_An_ability;

		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		
		if(IsValidEntity(weapon))
		{
			static float cooldown_time;
			had_An_ability = false;
			static bool IsReady;
			IsReady = false;

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
			if(had_An_ability)
			{
				HudY -= 0.035;
				Format(buffer, sizeof(buffer), "%s\n", buffer);
			}

			float percentage = 100.0;
			float percentage_Global = 1.0;
			float value = 1.0;

			percentage_Global *= ArmorPlayerReduction(client);
			percentage_Global *= Player_OnTakeDamage_Equipped_Weapon_Logic_Hud(client, weapon);
			
			if(IsInvuln(client, true) || f_ClientInvul[client] > GetGameTime())
			{
				percentage_Global = 0.0;
			}
			else if(RaidbossIgnoreBuildingsLogic(1))
			{
				if(TF2_IsPlayerInCondition(client, TFCond_Ubercharged))
				{
					percentage_Global *= 0.5;
				}
			}
			else
			{
				if(TF2_IsPlayerInCondition(client, TFCond_Ubercharged))
				{
					percentage_Global *= 0.0;
				}
			}

			value = Attributes_FindOnPlayerZR(client, 412, true);	// Overall damage resistance
			if(value)
				percentage_Global *= value;

			if(TF2_IsPlayerInCondition(client, TFCond_MarkedForDeathSilent))
			{
				percentage_Global *= 1.35;
			}
			if(TF2_IsPlayerInCondition(client, TFCond_Jarated))
			{
				percentage_Global *= 1.35;
			}
			if(TF2_IsPlayerInCondition(client, TFCond_DefenseBuffed))
			{
				percentage_Global *= 0.65;
			}
			if(f_MultiDamageTaken[client] != 1.0)
			{
				percentage_Global *= f_MultiDamageTaken[client];
			}
			if(f_MultiDamageTaken_Flat[client] != 1.0)
			{
				percentage_Global *= f_MultiDamageTaken_Flat[client];
			}
			if(f_BattilonsNpcBuff[client] > GameTime)
			{
				percentage_Global *= RES_BATTILONS;
			}	
			if(f_HussarBuff[client] > GameTime)
			{
				percentage_Global *= 0.90;
			}	
			if(f_EmpowerStateOther[client] > GameTime) //Allow stacking.
			{
				percentage_Global *= 0.93;
			}
			if(f_EmpowerStateSelf[client] > GameTime) //Allow stacking.
			{
				percentage_Global *= 0.9;
			}
			if(i_CurrentEquippedPerk[client] == 2)
			{
				percentage_Global *= 0.85;
			}
			if(Resistance_Overall_Low[client] > GameTime)
			{
				percentage_Global *= RES_MEDIGUN_LOW;
			}
			value = Attributes_FindOnPlayerZR(client, 206, true, 0.0, true, true);	// MELEE damage resistance
			if(value)
				percentage *= value;
			//melee res
			percentage *= percentage_Global;
			if(percentage != 100.0 && percentage > 0.0)
			{
				FormatEx(buffer, sizeof(buffer), "%s [♈ %.0f%%]", buffer, percentage);
				had_An_ability = true;
			}
			
			percentage = 100.0;
			percentage *= percentage_Global;
			value = Attributes_FindOnPlayerZR(client, 205, true, 0.0, true, true);	// MELEE damage resistance
			if(value)
				percentage *= value;

			if(percentage != 100.0 && percentage > 0.0)
			{
				FormatEx(buffer, sizeof(buffer), "%s [♐ %.0f%%]", buffer, percentage);
				had_An_ability = true;
			}
			if(percentage_Global <= 0.0)
			{
				FormatEx(buffer, sizeof(buffer), "%s %t",buffer, "Invulnerable Npc");
				had_An_ability = true;
			}
			if(had_An_ability)
			{
				HudY -= 0.035;
				Format(buffer, sizeof(buffer), "%s\n", buffer);
			}
			had_An_ability = false;
			switch(ClientHasBannersWithCD(client))
			{
				case BuffBanner,Battilons,AncientBanner:
				{
					had_An_ability = true;
					if(GetEntProp(client, Prop_Send, "m_bRageDraining"))
					{
						FormatEx(buffer, sizeof(buffer), "%s [⚐ %.1fs]", buffer, f_BannerAproxDur[client] - GetGameTime());
					}
					else
					{
						FormatEx(buffer, sizeof(buffer), "%s [⚐ %.0f%%]", buffer, GetEntPropFloat(client, Prop_Send, "m_flRageMeter"));
					}
				}
			}
			if(ClientHasUseableGrenadeOrDrink(client))
			{
				if(GetGameTime() > GrenadeApplyCooldownReturn(client))
				{
					FormatEx(buffer, sizeof(buffer), "%s [◈]", buffer);
				}
				else
				{
					FormatEx(buffer, sizeof(buffer), "%s [◈ %.1fs]", buffer, GrenadeApplyCooldownReturn(client) - GetGameTime());
				}
			}
			static int TaurusInt;
			TaurusInt = TaurusExistant(client);
			if(TaurusInt > 0)
			{
				int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
				int ammo = GetEntData(TaurusInt, iAmmoTable, 4);//Get ammo clip
				FormatEx(buffer, sizeof(buffer), "%s [T %i/%i]",buffer, ammo, TaurusMaxAmmo());
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
			if(had_An_ability)
			{
				HudY -= 0.035;
				Format(buffer, sizeof(buffer), "%s\n", buffer);
			}
			
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
				red 	= 200;
				green 	= 200;
				blue	= 200;

				#if defined ZR
				float OverMana_Ratio = Current_Mana[client]/max_mana[client];

				if(OverMana_Ratio > 1.05)
				{
					if(OverMana_Ratio < 2.0)
					{
						red = RoundToFloor(127*OverMana_Ratio); 
						green = 255 - RoundToFloor(255*(OverMana_Ratio-1.0));
						blue = 255 - RoundToFloor(255*(OverMana_Ratio-1.0));

						if(red>255)
							red=255;

						if(green<0)
							green=0;
						
						if(blue<0)
							blue=0;
					}
					else	//Player is DANGEROUSLY close to getting nuked due to overmana!
					{
						red 	= 255;
						green 	= 0;
						blue	= 0;
					}
				}
				#endif	//ZR

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

		had_An_ability = false;
		char bufferbuffs[64];
		//BUFFS!

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
		if(f_EmpowerStateSelf[client] > GameTime)
		{
			had_An_ability = true;
			Format(bufferbuffs, sizeof(bufferbuffs), "⍋%s", bufferbuffs);
		}
		if(f_EmpowerStateOther[client] > GameTime)
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
		if(buffer[0])
		{
			SetHudTextParams(HudX, HudY, 0.81, red, green, blue, 255);
			ShowSyncHudText(client,  SyncHud_WandMana, "%s", buffer);
		}
	}
	else if(delay_hud[client] < GameTime)	
	{
		delay_hud[client] = GameTime + 0.4;

		UpdatePlayerPoints(client);

		if(LastMann || dieingstate[client] > 0)
		{
			ApplyLastmanOrDyingOverlay(client);
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
			Armor_Max = MaxArmorCalculation(Armor_Level[client], client, 1.0);
		}

		int red = 255;
		int green = 255;
		int blue = 0;
		if(Armor_Charge[armorEnt] < 0)
		{
			switch(Armor_DebuffType[armorEnt])
			{
				case 1:
				{
					green = 0;
					blue = 255;
				}
				case 2:
				{
					red = 0;
					green = 255;
					blue = 255;
				}
			}
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
		ArmorDisplayClient(client);
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
				case BuildingBlacksmith:
				{
					if(Cooldowntocheck > 0.0)
					{
						Format(buffer, sizeof(buffer), "%.1f\nTI\n", Cooldowntocheck);
					}
					else
					{
						Format(buffer, sizeof(buffer), "\nTI\n", Cooldowntocheck);
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

			Format(HudBuffer, sizeof(HudBuffer), "%s\n%t\n%t\n%t", HudBuffer,
			"Credits_Menu_New", GlobalExtraCash + (Resupplies_Supplied[client] * 10) + CashRecievedNonWave[client],	
			"Ammo Crate Supplies", (Ammo_Count_Ready - Ammo_Count_Used[client]),
			PerkNames[i_CurrentEquippedPerk[client]]
			);

			if(b_LeftForDead[client])
			{
				Format(HudBuffer, sizeof(HudBuffer), "%s\n%t", HudBuffer,
					"Downs left", downsleft ? 1 : 0);
			}
			else
			{
				Format(HudBuffer, sizeof(HudBuffer), "%s\n%t", HudBuffer,
					"Downs left", downsleft);	
			}
			if(Store_ActiveCanMulti(client))
			{
				Format(HudBuffer, sizeof(HudBuffer), "%s\n\n%t", HudBuffer, "Press Button To Switch");
			}
		}
		else if (TeutonType[client] == TEUTON_DEAD)
		{
			Format(HudBuffer, sizeof(HudBuffer), "%s %t",HudBuffer, "You Died Teuton"
			);

		}
		else
		{
			Format(HudBuffer, sizeof(HudBuffer), "%s %t",HudBuffer, "You Wait Teuton"
			);
		}
		SetEntProp(client, Prop_Send, "m_nCurrency", CurrentCash-CashSpent[client]);
		
		//Todo: Only update when needed.
		SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDEHUD_BUILDING_STATUS | HIDEHUD_CLOAK_AND_FEIGN);
		if(HudBuffer[0])
			PrintKeyHintText(client,"%s", HudBuffer);
	}
	else if(f_DelayLookingAtHud[client] < GameTime)
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
	else
	{
		Store_TryRefreshMenu(client);
	}
	
	Music_PostThink(client);
}

public void OnPostThinkPost(int client)
{
	if(b_NetworkedCrouch[client])
	{
		SetEntProp(client, Prop_Send, "m_bAllowAutoMovement", 0);
	}
}
#endif	// ZR

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

public void Player_OnTakeDamageAlivePost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
#if defined ZR

	int i_damage = RoundToCeil(damage);
	if(!(damagetype & (DMG_DROWN|DMG_FALL)))
	{
		i_PlayerDamaged[victim] += i_damage;
	}
	
	if((damagetype & DMG_DROWN))
	{
		//the player has died to a stuckzone.
		if(dieingstate[victim] > 0)
		{
			TeleportBackToLastSavePosition(victim);
		}
	}
	RegainTf2Buffs(victim);

	Player_OnTakeDamage_Equipped_Weapon_Logic_Post(victim);
	ArmorDisplayClient(victim);
	
#endif
	i_HexCustomDamageTypes[victim] = 0;
}
#if defined ZR
void RegainTf2Buffs(int victim)
{
	if(i_WasInUber[victim])
	{
		TF2_AddCondition(victim, TFCond_Ubercharged, i_WasInUber[victim]);
	}
	if(i_WasInMarkedForDeath[victim])
	{
		TF2_AddCondition(victim, TFCond_MarkedForDeathSilent, i_WasInMarkedForDeath[victim]);
	}
	if(i_WasInJarate[victim])
	{
		TF2_AddCondition(victim, TFCond_Jarated, i_WasInJarate[victim]);
	}
	if(i_WasInDefenseBuff[victim])
	{
		TF2_AddCondition(victim, TFCond_DefenseBuffed, i_WasInDefenseBuff[victim]);
	}
	i_WasInUber[victim] = 0.0;
	i_WasInMarkedForDeath[victim] = 0.0;
	i_WasInDefenseBuff[victim] = 0.0;
	i_WasInJarate[victim] = 0.0;
}
static void Player_OnTakeDamage_Equipped_Weapon_Logic_Post(int victim)
{
	int Victim_weapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
	if(IsValidEntity(Victim_weapon))
	{
		switch(i_CustomWeaponEquipLogic[Victim_weapon])
		{
			case WEAPON_RED_BLADE:
			{
				WeaponRedBlade_OnTakeDamage_Post(victim, Victim_weapon);
			}
		}
	}
}
#endif
public Action Player_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
#if defined ZR
	i_WasInUber[victim] = 0.0;
	i_WasInMarkedForDeath[victim] = 0.0;
	i_WasInDefenseBuff[victim] = 0.0;
	if(TeutonType[victim])
		return Plugin_Handled;
#endif

	float GameTime = GetGameTime();

#if defined ZR
	if(f_ClientInvul[victim] > GameTime) //Treat this as if they were a teuton, complete and utter immunity to everything in existance.
	{
		return Plugin_Handled;
	}

	if(RaidbossIgnoreBuildingsLogic(1))
	{
		if(TF2_IsPlayerInCondition(victim, TFCond_Ubercharged))
		{
			i_WasInUber[victim] = TF2Util_GetPlayerConditionDuration(victim, TFCond_Ubercharged);
			TF2_RemoveCondition(victim, TFCond_Ubercharged);
			damage *= 0.5;
		}
	}
	if(damagetype & DMG_CRIT)
	{
		damagetype &= ~DMG_CRIT; //Remove Crit Damage at all times, it breaks calculations for no good reason.
	}

	if(!(damagetype & DMG_DROWN))
	{
		if(IsInvuln(victim))
		{
			f_TimeUntillNormalHeal[victim] = GameTime + 4.0;
			return Plugin_Continue;	
		}
	}
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
	float Replicated_Damage;
	Replicate_Damage_Medications(victim, damage, Replicated_Damage, damagetype);
	
	if(damagetype & DMG_FALL)
	{
		Replicated_Damage *= 0.45; //Reduce falldmg by passive overall
		damage *= 0.45;
		if(RaidbossIgnoreBuildingsLogic(1))
		{
			Replicated_Damage *= 0.75;
			damage *= 0.75;			
		}
		else if(i_SoftShoes[victim] == 1)
		{
			Replicated_Damage *= 0.9;
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
	
	if((damagetype & DMG_DROWN) && !b_ThisNpcIsSawrunner[attacker] && (!(i_HexCustomDamageTypes[victim] & ZR_STAIR_ANTI_ABUSE_DAMAGE)))
	{
		if(!b_ThisNpcIsSawrunner[attacker])
		{
			if(damage < 10000.0)
			{
				NpcStuckZoneWarning(victim, damage);
				Replicated_Damage = damage;
			}
			else
			{
				Replicated_Damage = damage;
			}
			//it will instakill otherwise.
		}
		else
		{
			damage *= 2.0;
			Replicated_Damage *= 2.0;
		}
	}
	f_TimeUntillNormalHeal[victim] = GameTime + 4.0;

	if(Medival_Difficulty_Level != 0.0)
	{
		float difficulty_math = Medival_Difficulty_Level;
		
		difficulty_math = 1.0 - difficulty_math;
		
		damage *= difficulty_math + 1.0; //More damage !! only upto double.
		Replicated_Damage *= difficulty_math + 1.0;
	}
	if(f_MultiDamageTaken[victim] != 1.0)
	{
		damage *= f_MultiDamageTaken[victim];
	}
	if(f_MultiDamageTaken_Flat[victim] != 1.0)
	{
		damage *= f_MultiDamageTaken_Flat[victim];
	}
	
	//freeplay causes more damage taken.
	if(f_FreeplayDamageExtra != 1.0 && !b_thisNpcIsARaid[attacker])
	{
		damage *= f_FreeplayDamageExtra;
		Replicated_Damage *= f_FreeplayDamageExtra;
	}
	int Victim_weapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
	if(!b_ThisNpcIsSawrunner[attacker])
#endif	// ZR
	
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
#endif	// ZR
		if(f_HussarBuff[attacker] > GameTime) //hussar!
		{
			damage *= 1.10;
#if defined ZR
			Replicated_Damage *= 1.10;
#endif
		}
		if(f_HussarBuff[victim] > GameTime) //hussar!
		{
			damage *= 0.90;
#if defined ZR
			Replicated_Damage *= 0.90;
#endif
		}
#if defined ZR
		if(f_PotionShrinkEffect[attacker] > GameTime || (IsValidEntity(inflictor) && f_PotionShrinkEffect[attacker] > GameTime))
		{
			damage *= 0.5; //half the damage when small.
			Replicated_Damage *= 0.5;
		}
#endif
		if(f_BattilonsNpcBuff[victim] > GameTime)
		{
			damage *= 0.8;
#if defined ZR
			Replicated_Damage *= 0.8;
#endif
		}
		damage *= fl_Extra_Damage[attacker];
#if defined ZR
		Replicated_Damage *= fl_Extra_Damage[attacker];
#endif
		
		//FOR ANY WEAPON THAT NEEDS CUSTOM LOGIC WHEN YOURE HURT!!
		//It will just return the same damage if nothing is done.
	
#if defined ZR
		if(RaidbossIgnoreBuildingsLogic(1) && i_HealthBeforeSuit[victim] > 0)
		{
			Replicated_Damage *= 3.0; //when a raid is alive, make quantum armor 8x as bad at tanking.
			damage *= 3.0;	
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

		if(Rogue_Mode())
		{
			int scale = Rogue_GetRoundScale();
			if(scale < 2)
			{
				Replicated_Damage *= 0.50;
				damage *= 0.50;
			}
			else if(scale < 4)
			{
				Replicated_Damage *= 0.75;
				damage *= 0.75;
			}
		}
#endif
			
#if defined ZR
	//	bool Though_Armor = false;
	
		if(i_CurrentEquippedPerk[victim] == 6)
		{

			//s	int flHealth = GetEntProp(victim, Prop_Send, "m_iHealth");
			int flMaxHealth = SDKCall_GetMaxHealth(victim);
		
			if((damage > float(flMaxHealth / 20) || flHealth < flMaxHealth / 5 || damage > 25.0) && f_WidowsWineDebuffPlayerCooldown[victim] < GameTime) //either too much dmg, or your health is too low.
			{
				f_WidowsWineDebuffPlayerCooldown[victim] = GameTime + 20.0;
				
				float vecVictim[3]; WorldSpaceCenter(victim, vecVictim);
				
				ParticleEffectAt(vecVictim, "peejar_impact_cloud_milk", 0.5);
				
				EmitSoundToAll("weapons/jar_explode.wav", victim, SNDCHAN_AUTO, 80, _, 1.0);
				
				Replicated_Damage *= 0.25;
				damage *= 0.25;
				for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
				{
					int baseboss_index = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
					if (IsValidEntity(baseboss_index))
					{
						if(!b_NpcHasDied[baseboss_index])
						{
							if (GetTeam(victim)!=GetTeam(baseboss_index)) 
							{
								float vecTarget[3]; WorldSpaceCenter(baseboss_index, vecTarget);
								
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
			Replicated_Damage *= RES_MEDIGUN_LOW;
#endif
			
			damage *= RES_MEDIGUN_LOW;
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
				float percentage = ArmorPlayerReduction(victim);
				damage *= percentage;
				Replicated_Damage *= percentage;
			}
			else
			{
				damage *= 0.65;
				Replicated_Damage *= 0.65;
			}
		}
#endif	// ZR
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
		else if((!LastMann && !b_IsAloneOnServer) || SpecterCheckIfAutoRevive(victim))
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
				// Trigger lastman
				CheckAlivePlayers(_, victim);

				// Die in Rogue, there's no lastman
				return Rogue_Mode() ? Plugin_Continue : Plugin_Handled;
			}
			
			i_AmountDowned[victim] += 1;
			if(SpecterCheckIfAutoRevive(victim) || (i_AmountDowned[victim] < 3 && !b_LeftForDead[victim]) || (i_AmountDowned[victim] < 2 && b_LeftForDead[victim]))
			{
				//https://github.com/lua9520/source-engine-2018-hl2_src/blob/3bf9df6b2785fa6d951086978a3e66f49427166a/game/shared/mp_shareddefs.cpp
				MakePlayerGiveResponseVoice(victim, 2); //dead!
			//	SetVariantString("TLK_DIED");
			//	AcceptEntityInput(victim, "SpeakResponseConcept");
				i_CurrentEquippedPerkPreviously[victim] = i_CurrentEquippedPerk[victim];
				if(!Rogue_Mode() && !SpecterCheckIfAutoRevive(victim))
				{
					i_CurrentEquippedPerk[victim] = 0;
				}
				SetEntityHealth(victim, 200);
				if(!b_LeftForDead[victim])
				{
					int speed = 10;
					Rogue_ReviveSpeed(speed);
					dieingstate[victim] = 2500 / speed;
				}
				else
				{
					dieingstate[victim] = 500;
				}
				ForcePlayerCrouch(victim, true);
				//cooldown for left for dead.
				SpecterResetHudTime(victim);
				ApplyLastmanOrDyingOverlay(victim);
				SetEntityCollisionGroup(victim, 1);
				CClotBody player = view_as<CClotBody>(victim);
				player.m_bThisEntityIgnored = true;
				Attributes_Set(victim, 489, 0.65);
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
					if(entity == EntRefToEntIndex(Armor_Wearable[victim]) || i_WeaponVMTExtraSetting[entity] != -1)
						continue;

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
void Replicate_Damage_Medications(int victim, float &damage, float &Replicated_Dmg, int damagetype)
{
	Replicated_Dmg = damage;
	if(TF2_IsPlayerInCondition(victim, TFCond_MarkedForDeathSilent))
	{
		i_WasInMarkedForDeath[victim] = TF2Util_GetPlayerConditionDuration(victim, TFCond_MarkedForDeathSilent);
		TF2_RemoveCondition(victim, TFCond_MarkedForDeathSilent);
		damage *= 1.35;
		Replicated_Dmg *= 1.35;
	}
	if(TF2_IsPlayerInCondition(victim, TFCond_Jarated))
	{
		i_WasInJarate[victim] = TF2Util_GetPlayerConditionDuration(victim, TFCond_Jarated);
		TF2_RemoveCondition(victim, TFCond_Jarated);
		damage *= 1.35;
		Replicated_Dmg *= 1.35;
	}
	if(TF2_IsPlayerInCondition(victim, TFCond_DefenseBuffed))
	{
		i_WasInDefenseBuff[victim] = TF2Util_GetPlayerConditionDuration(victim, TFCond_DefenseBuffed);
		TF2_RemoveCondition(victim, TFCond_DefenseBuffed);
		damage *= 0.65;
		Replicated_Dmg *= 0.65;
	}
	float value;
	if(damagetype & (DMG_CLUB|DMG_SLASH))
	{
		value = Attributes_FindOnPlayerZR(victim, 206, true, 0.0, true, true);	// MELEE damage resitance
		if(value)
		{
			Replicated_Dmg *= value;
			damage *= value;
		}
	}
	else if(!(damagetype & DMG_FALL))
	{
		value = Attributes_FindOnPlayerZR(victim, 205, true, 0.0, true, true);	// RANGED damage resistance
		if(value)
		{
			Replicated_Dmg *= value;
			damage *= value;
		}
		//Everything else should be counted as ranged reistance probably.
	}
		
	value = Attributes_FindOnPlayerZR(victim, 412, true);	// Overall damage resistance
	if(value)
	{
		Replicated_Dmg *= value;
		damage *= value;
	}	
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
#if defined ZR
			if(TeutonType[entity] != TEUTON_NONE)
			{
				bool Changed = TeutonSoundOverride(numClients, sample, 
				entity, channel, volume, level, pitch, flags,seed);
				
				if(Changed)
				{
					return Plugin_Changed;
				}
				else
				{
					return Plugin_Handled;
				}
				
			}
			if(b_IsPlayerNiko[entity])
			{
				return Plugin_Handled;
			}
#endif
		
		}
	}
	if(channel == SNDCHAN_WEAPON)
	{
		//this is only for other clients.
		if(entity > 0 && entity <= MaxClients)
		{
			bool ChangedSound = false;
			if(f_WeaponVolumeStiller[entity] != 1.0)
			{
				ChangedSound = true;
				volume *= f_WeaponVolumeStiller[entity];
			}
			if(f_WeaponVolumeSetRange[entity] != 1.0)
			{
				ChangedSound = true;
				level = RoundToNearest(float(level) * f_WeaponVolumeSetRange[entity]);	
			}
			if(ChangedSound)
				return Plugin_Changed;
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
#if defined ZR
		if(EntRefToEntIndex(i_PreviousWeapon[client]) != weapon)
			OnWeaponSwitchPre(client, EntRefToEntIndex(i_PreviousWeapon[client]));
#endif

		i_PreviousWeapon[client] = EntIndexToEntRef(weapon);
		
		char buffer[36];
		GetEntityClassname(weapon, buffer, sizeof(buffer));
		
#if defined ZR
		Building_WeaponSwitchPost(client, weapon, buffer);
#endif

#if defined ZR	
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
#endif
	}

#if defined ZR
	Store_WeaponSwitch(client, weapon);
	RequestFrame(OnWeaponSwitchFrame, GetClientUserId(client));
#endif

#if defined RPG
	//Attributes_Set(client, 698, 1.0);
	SetEntProp(client, Prop_Send, "m_bWearingSuit", false);
#endif

}

#if defined ZR
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
#endif	// Non-RTS

#if defined ZR
static float Player_OnTakeDamage_Equipped_Weapon_Logic(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, int equipped_weapon, float damagePosition[3])
{
	switch(i_CustomWeaponEquipLogic[equipped_weapon])
	{
		case WEAPON_ARK: // weapon_ark
		{
			return Player_OnTakeDamage_Ark(victim, damage, attacker, equipped_weapon, damagePosition);
		}
		case WEAPON_NEARL, WEAPON_FUSION_PAP2:
		{
			return Player_OnTakeDamage_Fusion(victim, damage, attacker, equipped_weapon, damagePosition);
		}
		case WEAPON_RIOT_SHIELD:
		{
			return Player_OnTakeDamage_Riot_Shield(victim, damage, attacker, equipped_weapon, damagePosition);
		}
		case WEAPON_MLYNAR: // weapon_ark
		{
			Player_OnTakeDamage_Mlynar(victim, damage, attacker, equipped_weapon);
		}
		case WEAPON_MLYNAR_PAP: // weapon_ark
		{
			Player_OnTakeDamage_Mlynar(victim, damage, attacker, equipped_weapon, 1);
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
		case WEAPON_LEPER_MELEE_PAP, WEAPON_LEPER_MELEE:
		{
			return WeaponLeper_OnTakeDamagePlayer(victim, damage, attacker, equipped_weapon, damagePosition);
		}
		case WEAPON_FLAGELLANT_MELEE, WEAPON_FLAGELLANT_HEAL:
		{
			Flagellant_OnTakeDamage(victim, damage);
		}
		case WEAPON_RAPIER:
		{
			Player_OnTakeDamage_Rapier(victim, attacker, damage);
		}
		case WEAPON_RED_BLADE:
		{
			WeaponRedBlade_OnTakeDamage(attacker, victim, damage);
		}
		case WEAPON_HEAVY_PARTICLE_RIFLE:
		{
			return Player_OnTakeDamage_Heavy_Particle_Rifle(victim, damage, attacker, equipped_weapon, damagePosition);
		}
	}
	return damage;
}


static float Player_OnTakeDamage_Equipped_Weapon_Logic_Hud(int victim,int &weapon)
{
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_OCEAN, WEAPON_SPECTER:
		{
			return Gladiia_OnTakeDamageAlly_Hud(victim);
		}
		case WEAPON_GLADIIA:
		{
			return Gladiia_OnTakeDamageSelf_Hud(victim);
		}
		case WEAPON_BLEMISHINE:
		{
			return Player_OnTakeDamage_Blemishine_Hud(victim);
		}
		case WEAPON_BOARD:
		{
			return Player_OnTakeDamage_Board_Hud(victim);
		}
		case WEAPON_LEPER_MELEE_PAP, WEAPON_LEPER_MELEE:
		{
			return WeaponLeper_OnTakeDamagePlayer_Hud(victim);
		}
		case WEAPON_RAPIER:
		{
			return Player_OnTakeDamage_Rapier_Hud(victim);
		}
		case WEAPON_RED_BLADE:
		{
			return WeaponRedBlade_OnTakeDamage_Hud(victim);
		}
	}
	return 1.0;
}

//problem: tf2 code lazily made it only work for clients, the server doesnt get this information updated all the time now.
#define SKIN_ZOMBIE			5
#define SKIN_ZOMBIE_SPY		SKIN_ZOMBIE + 18

void UpdatePlayerFakeModel(int client)
{
	int PlayerModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(PlayerModel > 0)
	{	
		SDKCall_RecalculatePlayerBodygroups(client);
		i_nm_body_client[client] = GetEntProp(client, Prop_Data, "m_nBody");
		SetEntProp(PlayerModel, Prop_Send, "m_nBody", i_nm_body_client[client]);
	}
}

void NpcStuckZoneWarning(int client, float &damage, int TypeOfAbuse = 0)
{
	SetGlobalTransTarget(client);
	switch(TypeOfAbuse)
	{
		case 0:
		{
			f_TimeUntillNormalHeal[client] = GetGameTime() + 4.0;
			PrintToChat(client, "%t", "Npc Stuck Spot Warning");
			damage = 0.0;
			if(f_ClientWasTooLongInsideHurtZone[client] < GetGameTime())
			{
				f_ClientWasTooLongInsideHurtZone[client] = GetGameTime() + 5.0;
				f_ClientWasTooLongInsideHurtZoneDamage[client] = float(SDKCall_GetMaxHealth(client)) * 0.025;
			}
			else if(f_ClientWasTooLongInsideHurtZone[client] <= GetGameTime() + 3.0)
			{
				f_ClientWasTooLongInsideHurtZone[client] = GetGameTime() + 3.0;
				damage = f_ClientWasTooLongInsideHurtZoneDamage[client];
				f_ClientWasTooLongInsideHurtZoneDamage[client] *= 2.0;
			}
		}
		case 1:
		{
			PrintToChat(client, "%t", "Npc Stuck Spot Warning Stairs");
			damage = 0.0;
			if(f_ClientWasTooLongInsideHurtZoneStairs[client] < GetGameTime())
			{
				f_ClientWasTooLongInsideHurtZoneStairs[client] = GetGameTime() + 5.0;
				f_ClientWasTooLongInsideHurtZoneDamageStairs[client] = float(SDKCall_GetMaxHealth(client)) * 0.025;
			}
			else if(f_ClientWasTooLongInsideHurtZoneStairs[client] <= GetGameTime() + 3.0)
			{
				f_ClientWasTooLongInsideHurtZoneStairs[client] = GetGameTime() + 3.0;
				damage = f_ClientWasTooLongInsideHurtZoneDamageStairs[client];
				f_ClientWasTooLongInsideHurtZoneDamageStairs[client] *= 2.0;
			}
		}
	}
}

void ApplyLastmanOrDyingOverlay(int client)
{
	DoOverlay(client, "debug/yuv");
	if(LastMann)
	{
		if(LastMannScreenEffect)
			DoOverlay(client, "zombie_riot/filmgrain/filmgrain_4", 1);
	}
}

void CauseFadeInAndFadeOut(int client = 0, float duration_in, float duration_hold, float duration_out)
{
	int SpawnFlags = 0;
	if(client != 0)
	{
		SpawnFlags = 4;
	}
	char Buffer[32];
	IntToString(SpawnFlags, Buffer, sizeof(Buffer));
	int FadeEntity = CreateEntityByName("env_fade");
	DispatchKeyValue(FadeEntity, "spawnflags", Buffer);
	DispatchKeyValue(FadeEntity, "rendercolor", "0 0 0");
	DispatchKeyValue(FadeEntity, "renderamt", "235");
	FloatToString(duration_hold * 3.0, Buffer, sizeof(Buffer));
	DispatchKeyValue(FadeEntity, "holdtime", Buffer);
	FloatToString(duration_in, Buffer, sizeof(Buffer));
	DispatchKeyValue(FadeEntity, "duration", Buffer);
	DispatchSpawn(FadeEntity);
	AcceptEntityInput(FadeEntity, "Fade");
	CreateTimer((duration_in + duration_hold), Timer_CauseFadeInAndFadeOut, duration_out);
}
public Action Timer_CauseFadeInAndFadeOut(Handle timer, float duration_out)
{
	/*
	int entity = -1;
	while((entity = FindEntityByClassname(entity, "env_fade")) != -1)
	{
		if (IsValidEntity(entity))
		{
			RemoveEntity(entity);
		}
	}
	*/
	Zero(delay_hud); //Allow the hud to immedietly update
	LastMannScreenEffect = true;
	int FadeEntity = CreateEntityByName("env_fade");
	DispatchKeyValue(FadeEntity, "spawnflags", "1");
	DispatchKeyValue(FadeEntity, "rendercolor", "0 0 0");
	DispatchKeyValue(FadeEntity, "renderamt", "235");
	DispatchKeyValue(FadeEntity, "holdtime", "0");
	char Buffer[32];
	FloatToString(duration_out, Buffer, sizeof(Buffer));
	DispatchKeyValue(FadeEntity, "duration", Buffer);
	DispatchSpawn(FadeEntity);
	AcceptEntityInput(FadeEntity, "Fade");
	CreateTimer(duration_out, Timer_CauseFadeInAndFadeDelete);
	return Plugin_Stop;
}
public Action Timer_CauseFadeInAndFadeDelete(Handle timer)
{
	int entity = -1;
	while((entity = FindEntityByClassname(entity, "env_fade")) != -1)
	{
		if (IsValidEntity(entity))
		{
			RemoveEntity(entity);
		}
	}
	return Plugin_Stop;
}
#endif	// ZR

stock void IncreaceEntityDamageTakenBy(int entity, float amount, float duration, bool Flat = false)
{
	if(!Flat)
		f_MultiDamageTaken[entity] *= amount;
	else
		f_MultiDamageTaken_Flat[entity] += amount;

	Handle pack;
	CreateDataTimer(duration, RevertDamageTakenAgain, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, EntIndexToEntRef(entity));
	WritePackCell(pack, Flat);
	WritePackFloat(pack, amount);
}

public Action RevertDamageTakenAgain(Handle final, any pack)
{
	ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	bool Flat = ReadPackCell(pack);
	float damagemulti = ReadPackFloat(pack);
	
	if (IsValidEntity(entity))
	{
		if(!Flat)
			f_MultiDamageTaken[entity] /= damagemulti;
		else
			f_MultiDamageTaken_Flat[entity] -= damagemulti;
	}
	return Plugin_Continue;
}

#if defined ZR
float ArmorPlayerReduction(int victim)
{
	switch(Armor_Level[victim])
	{
		case 50:
		{
			return 0.95;
		}
		case 100:
		{
			return 0.93;
		}
		case 150:
		{
			return 0.91;
		}
		case 200:
		{
			return 0.9;
		}
		default:
		{
			return 1.0;
		}
	}
}


void ArmorDisplayClient(int client, bool deleteOverride = false)
{
	int ShieldLogicDo;
	if(Armor_Charge[client] > 0)
	{
		ShieldLogicDo = 1;
	}
	if(Armor_Charge[client] < 0)
	{
		ShieldLogicDo = 2;
	}

	if(TeutonType[client] != TEUTON_NONE)
	{
		ShieldLogicDo = 0;
	}

	if(dieingstate[client] != 0)
	{
		ShieldLogicDo = 0;
	}

	if(!IsPlayerAlive(client))
	{
		ShieldLogicDo = 0;
	}
	int entity;
	if(deleteOverride)
	{
		if(IsValidEntity(Armor_Wearable[client]))
		{
			entity = EntRefToEntIndex(Armor_Wearable[client]);
			if(entity > MaxClients)
				TF2_RemoveWearable(client, entity);
		}
		return;
	}
	if(ShieldLogicDo == 2)
	{
		TF2_AddCondition(client, TFCond_Milked, 1.0);
		Client_Had_ArmorDebuff[client] = true;
		return;
	}
	if(Client_Had_ArmorDebuff[client])
	{
		Client_Had_ArmorDebuff[client] = false;
		TF2_RemoveCondition(client, TFCond_Milked);
	}

	if(ShieldLogicDo == 1)
	{
		if(IsValidEntity(Armor_Wearable[client]))
		{
			ArmorDisplayClientColor(client, EntRefToEntIndex(Armor_Wearable[client]));
			return;
		}
		entity = CreateEntityByName("tf_wearable");
		if(entity > MaxClients)
		{
			int team = GetClientTeam(client);
			SetEntProp(entity, Prop_Send, "m_nModelIndex", Armor_WearableModelIndex);

		//	SetEntProp(entity, Prop_Send, "m_fEffects", 129);
			SetTeam(entity, team);
			SetEntProp(entity, Prop_Send, "m_nSkin", team-2);
			SetEntProp(entity, Prop_Send, "m_usSolidFlags", 4);
			SetEntityCollisionGroup(entity, 11);
			SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", 1);
			
			DispatchSpawn(entity);
			SetVariantString("!activator");
			ActivateEntity(entity);

			Armor_Wearable[client] = EntIndexToEntRef(entity);
			SDKCall_EquipWearable(client, entity);

			SetEntProp(entity, Prop_Send, "m_fEffects", 0);
			SetVariantString("!activator");
			AcceptEntityInput(entity, "SetParent", client);
		//	SDKCall_SetLocalOrigin(entity, {0.0,0.0,0.0});

			ArmorDisplayClientColor(client, entity);
			i_OwnerEntityEnvLaser[entity] = EntIndexToEntRef(client);
			SDKHook(entity, SDKHook_SetTransmit, ShieldSetTransmit);
		}	
	}
	else
	{
		if(IsValidEntity(Armor_Wearable[client]))
		{
			entity = EntRefToEntIndex(Armor_Wearable[client]);
			if(entity > MaxClients)
				TF2_RemoveWearable(client, entity);
		}
	}
}

public Action ShieldSetTransmit(int entity, int client)
{
	if(client > 0 && client <= MaxClients)
	{
		if(!b_ArmorVisualiser[client])
		{
			return Plugin_Stop;
		}
		int owner = EntRefToEntIndex(i_OwnerEntityEnvLaser[entity]);
		if(owner == client)
		{
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

void ArmorDisplayClientColor(int client, int armor)
{
	int Armor_Max = MaxArmorCalculation(Armor_Level[client], client, 1.0);
	float Percentage = float(Armor_Charge[client]) / float(Armor_Max);

	Percentage *= 14.0;
	int Alpha = RoundToCeil(Percentage * Percentage);

	if(Alpha > 200)
	{
		Alpha = 200;
	}
	if(Alpha <= 30)
	{
		Alpha = 30;
	}
	int green = 0;
	int blue = 0;
	if(Percentage >= 13.95)
	{
		green = 125;
	}

	SetEntityRenderMode(armor, RENDER_TRANSCOLOR);
	SetEntityRenderColor(armor, green, green, blue, Alpha);
}
#endif