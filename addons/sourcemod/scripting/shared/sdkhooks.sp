#pragma semicolon 1
#pragma newdecls required

static float i_WasInUber[MAXTF2PLAYERS] = {0.0,0.0,0.0};
static float i_WasInMarkedForDeath[MAXTF2PLAYERS] = {0.0,0.0,0.0};
static float i_WasInDefenseBuff[MAXTF2PLAYERS] = {0.0,0.0,0.0};
static float i_WasInJarate[MAXTF2PLAYERS] = {0.0,0.0,0.0};
static float f_EntityHazardCheckDelay[MAXTF2PLAYERS];
static float f_EntityOutOfNav[MAXTF2PLAYERS];

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
	Zero(f_EntityOutOfNav);
	
	Zero(i_WasInUber);
	Zero(i_WasInMarkedForDeath);
	Zero(i_WasInDefenseBuff);
	Zero(i_WasInJarate);
	Zero(Client_Had_ArmorDebuff);
}

void SDKHook_PluginStart()
{
#if defined ZR || defined RPG
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
#endif

#if defined ZR || defined RPG
	int entity = FindEntityByClassname(-1, "tf_player_manager");
	if(entity != -1)
		SDKHook(entity, SDKHook_ThinkPost, SDKHook_ScoreThink);
#endif
}


#if defined ZR || defined RPG
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
#if defined ZR
		CashCurrentlyOwned[client] = CurrentCash-CashSpent[client];
#else
		CashCurrentlyOwned[client] = TextStore_Cash(client);
#endif
	}

	//healing done
	if(offset_Healing == -1) 
		offset_Healing = FindSendPropInfo("CTFPlayerResource", "m_iHealing");
	
#if defined ZR
	SetEntDataArray(entity, offset, PlayerPoints, MaxClients + 1);
#else
	SetEntDataArray(entity, offset, Level, MaxClients + 1);
#endif

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

#if defined ZR
			SetEntProp(client, Prop_Send, "m_iDefenses", RoundToCeil(float(i_BarricadeHasBeenDamaged[client]) * 0.001));
#endif

		}
	}	
}
#endif

stock void SDKHook_HookClient(int client)
{
#if defined ZR || defined RPG
	SDKUnhook(client, SDKHook_PreThinkPost, OnPreThinkPost);
	SDKHook(client, SDKHook_PreThinkPost, OnPreThinkPost);
	SDKUnhook(client, SDKHook_PostThink, OnPostThink);
	SDKUnhook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost);
	SDKHook(client, SDKHook_PostThink, OnPostThink);
	SDKHook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost);

	SDKUnhook(client, SDKHook_PostThinkPost, OnPostThinkPost);
	SDKHook(client, SDKHook_PostThinkPost, OnPostThinkPost);
#if defined ZR
	SDKUnhook(client, SDKHook_WeaponCanSwitchTo, WeaponSwtichToWarning);
	SDKHook(client, SDKHook_WeaponCanSwitchTo, WeaponSwtichToWarning);
/*
	SDKUnhook(client, SDKHook_WeaponCanSwitchToPost, WeaponSwtichToWarningPost);
	SDKHook(client, SDKHook_WeaponCanSwitchToPost, WeaponSwtichToWarningPost);
*/
#endif
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

bool WeaponWasGivenAmmo[MAXENTITIES];

#if defined ZR 
void WeaponWeaponAdditionOnRemoved(int entity)
{
	WeaponWasGivenAmmo[entity] = false;
}

public Action WeaponSwtichToWarning(int client, int weapon)
{
	int Ammo_type = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
	if(Ammo_type > 0 && Ammo_type != Ammo_Potion_Supply && Ammo_type != Ammo_Hand_Grenade)
	{
		if(GetAmmo(client, Ammo_type) <= 0)
		{
			SetGlobalTransTarget(client);
			PrintToChat(client, "%t", "Warn Client Ammo None");
		}
	}

	/*
	int ie, weapon1;
	while(TF2_GetItem(client, weapon1, ie))
	{
		if(IsValidEntity(weapon1))
		{
			if(weapon == 0)
			{
				int weapon2 = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon2 == weapon1)
					continue;
			}
			
			if(f_TimeSinceLastGiveWeapon[weapon1] > GetGameTime())
				return Plugin_Continue;

			if(b_WeaponHasNoClip[weapon1] && !WeaponWasGivenAmmo[weapon1])
			{
				WeaponWasGivenAmmo[weapon1] = false;
			}
			
			int Ammo_type = GetEntProp(weapon1, Prop_Send, "m_iPrimaryAmmoType");
			if(Ammo_type > 0 && Ammo_type < Ammo_MAX)
			{
				//found a weapon that has ammo.
				if(CurrentAmmo[client][Ammo_type] <= 0)
				{
					if(b_WeaponHasNoClip[weapon1])
					{
						WeaponWasGivenAmmo[weapon1] = true;
						SetAmmo(client, Ammo_type, CurrentAmmo[client][Ammo_type] + 1);
						CurrentAmmo[client][Ammo_type] = GetAmmo(client, Ammo_type);
					}
					else
					{			
						int iAmmoTable = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
						int GetClip = GetEntData(weapon1, iAmmoTable, 4);
						if(GetClip == 0)
						{
							WeaponWasGivenAmmo[weapon1] = true;
							SetEntData(weapon1, iAmmoTable, 1);
							SetEntProp(weapon1, Prop_Send, "m_iClip1", 1); // weapon clip amount bullets	
						}
					}
					//we give these weapons atleast 1 clip, this is to ensure you can switch to them client side.
					//we also set WeaponWasGivenAmmo, so when you actually switch to the weapon, its clip gets set to 0.
				}
			}
		}
	}
	*/
	return Plugin_Continue;
}
/*
public Action ResetWeaponAmmoStatus(Handle cut_timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if (IsValidEntity(entity))
	{
		WeaponWasGivenAmmo[entity] = false;
	}
	return Plugin_Handled;
}
void WeaponSwtichToWarningPostDestroyed(int weapon)
{
	if(WeaponWasGivenAmmo[weapon])
	{
		int client = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
		WeaponSwtichToWarningPost(client, weapon);
	}
}

public Action WeaponSwtichToWarningPost(int client, int weapon)
{
	RequestFrame(WeaponSwtichToWarningPostFrame, EntIndexToEntRef(weapon));
	return Plugin_Continue;
}

void WeaponSwtichToWarningPostFrame(int ref)
{
	int weapon = EntRefToEntIndex(ref);
	if(weapon == -1)
		return;

	int client = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if(client == -1)
		return;

	int ie, weapon1;
	while(TF2_GetItem(client, weapon1, ie))
	{
		if(WeaponWasGivenAmmo[weapon1])
		{
			f_TimeSinceLastGiveWeapon[weapon1] = GetGameTime() + 0.05;
			if(b_WeaponHasNoClip[weapon1])
			{
				int Ammo_type = GetEntProp(weapon1, Prop_Send, "m_iPrimaryAmmoType");

				if(CurrentAmmo[client][Ammo_type] >= 1)
				{
					SetAmmo(client, Ammo_type, CurrentAmmo[client][Ammo_type] -1);
					CurrentAmmo[client][Ammo_type] = GetAmmo(client, Ammo_type);
				}
			}
			else
			{
				static int iAmmoTable;
				if(!iAmmoTable)
					iAmmoTable = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
				
				SetEntData(weapon1, iAmmoTable, 0);
				SetEntProp(weapon1, Prop_Send, "m_iClip1", 0); // weapon clip amount bullets
			}
			SetEntPropFloat(weapon1, Prop_Send, "m_flNextSecondaryAttack", FAR_FUTURE);
		}
		WeaponWasGivenAmmo[weapon1] = false;
	}
	RequestFrames(WeaponSwtichToWarningPostFrameRegive, 1, EntIndexToEntRef(client));
}
void WeaponSwtichToWarningPostFrameRegive(int ref)
{
	int client = EntRefToEntIndex(ref);
	if(client == -1)
		return;

	WeaponSwtichToWarning(client, 0);
}
*/
#endif
#if defined ZR || defined RPG
public void OnPreThinkPost(int client)
{
	if(b_NetworkedCrouch[client])
	{
		SetEntProp(client, Prop_Send, "m_bAllowAutoMovement", 1);
	}
	CvarAirAcclerate.FloatValue = b_AntiSlopeCamp[client] ? 2.0 : 10.0;
}
#endif	// ZR & RPG

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

#if defined ZR || defined RPG
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

#if defined ZR
			NpcStuckZoneWarning(client, damageTrigger, 1);	
#endif

			if(damageTrigger > 1.0)
			{
				SDKHooks_TakeDamage(client, 0, 0, damageTrigger, DMG_DROWN|DMG_PREVENT_PHYSICS_FORCE, -1,_,_,_,ZR_STAIR_ANTI_ABUSE_DAMAGE);
			}
		}
	}

	if(GetTeam(client) == 2)
	{

#if defined ZR
		if(dieingstate[client] != 0 || TeutonType[client] != TEUTON_NONE)
#endif
		{
			if(f_EntityHazardCheckDelay[client] < GetGameTime())
			{
				EntityIsInHazard_Teleport(client);
				f_EntityHazardCheckDelay[client] = GetGameTime() + 0.25;
			}
		}
#if defined ZR
		if(dieingstate[client] == 0 && TeutonType[client] == TEUTON_NONE)
#endif
		{
			if(f_EntityOutOfNav[client] < GetGameTime())
			{
				Spawns_CheckBadClient(client);
				f_EntityOutOfNav[client] = GetGameTime() + GetRandomFloat(0.9, 1.1);
			}
		}
		SaveLastValidPositionEntity(client);
	
	}
	if(b_DisplayDamageHud[client])
	{
		if(Calculate_And_Display_HP_Hud(client))
		{
			b_DisplayDamageHud[client] = false;
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
			f_ClientInAirSince[client] = GetGameTime() + 5.0;
			b_PlayerWasAirbornKnockbackReduction[client] = true;
			Attributes_Set(EntityWearable, 252, 0.5);
		}
	}
	else if(!WasAirborn && b_PlayerWasAirbornKnockbackReduction[client])
	{
		int EntityWearable = EntRefToEntIndex(i_StickyAccessoryLogicItem[client]);
		if(EntityWearable > 0)
		{
			//when they land, check if they are in a bad pos
			Spawns_CheckBadClient(client);
			//no need to recheck when they land
			f_EntityOutOfNav[client] = GetGameTime() + GetRandomFloat(0.9, 1.1);
			b_PlayerWasAirbornKnockbackReduction[client] = false;
			Attributes_Set(EntityWearable, 252, 1.0);
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

	bool Mana_Regen_Tick = false;

	if(Rogue_CanRegen() && (Mana_Regen_Delay[client] < GameTime || (b_AggreviatedSilence[client] && Mana_Regen_Delay_Aggreviated[client] < GameTime)))
	{
		Mana_Regen_Delay[client] = GameTime + 0.4;
		Mana_Regen_Delay_Aggreviated[client] = GameTime + 0.4;

		has_mage_weapon[client] = false;
		
		Mana_Regen_Tick = true;

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
	//A part of Ruina's special mana "corrosion"
	if(Current_Mana[client] > RoundToCeil(max_mana[client]+10.0))	
	{
		//if they are using a magic weapon, don't take away the overmana. can be both a good and bad thing, good in non ruina situations, possibly bad in ruina situations
		//the +10 is for rounding errors.
		//CPrintToChatAll("Overmana decay triggered");
		if(Mana_Loss_Delay[client] < GameTime && Mana_Regen_Tick)
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

	if(Rogue_CanRegen() && Armor_regen_delay[client] < GameTime)
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
					float MaxHealth = float(SDKCall_GetMaxHealth(client));
					if(MaxHealth > 3000)
						MaxHealth = 3000.0;
						
					healing_Amount = HealEntityGlobal(client, client, MaxHealth / 100.0, 0.5, 0.0, HEAL_SELFHEAL);	
				}
			}
		}

		float attrib = Attributes_GetOnPlayer(client, 57, false) +
				Attributes_GetOnPlayer(client, 190, false) +
				Attributes_GetOnPlayer(client, 191, false);
		
		if(attrib)
		{
			if(dieingstate[client] == 0)
			{
				healing_Amount += HealEntityGlobal(client, client, attrib, 1.0, 0.0, HEAL_SELFHEAL);	
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
			Rogue_HealingSalve(client, healing_Amount);
			Rogue_HandSupport_HealTick(client, healing_Amount);
			if(i_BadHealthRegen[client] == 1)
			{
				healing_Amount += HealEntityGlobal(client, client, 1.0, 1.0, 0.0, HEAL_SELFHEAL);
			}
			if(b_NemesisHeart[client])
			{
				float HealRate = 1.0;
				if(b_XenoVial[client])
					HealRate = 1.15;

				healing_Amount += HealEntityGlobal(client, client, HealRate, 1.0, 0.0, HEAL_SELFHEAL);
			}
		}

		if(healing_Amount)
			ApplyHealEvent(client, healing_Amount);

		Armor_regen_delay[client] = GameTime + 1.0;
	}
#endif	// ZR

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
#if defined RPG
		RPGRegenerateResource(client, false,true);
#endif
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
			
			if(had_An_ability)
			{
				HudY -= 0.035;
				Format(buffer, sizeof(buffer), "%s\n", buffer);
			}
#endif
			float percentage = 100.0;
			float percentage_Global = 1.0;
			float value = 1.0;

#if defined ZR
			percentage_Global *= ArmorPlayerReduction(client);
			percentage_Global *= Player_OnTakeDamage_Equipped_Weapon_Logic_Hud(client, weapon);
#endif
			
			if(IsInvuln(client, true) || f_ClientInvul[client] > GetGameTime())
			{
				percentage_Global = 0.0;
			}
#if defined ZR
			else if(RaidbossIgnoreBuildingsLogic(1))
			{
				if(TF2_IsPlayerInCondition(client, TFCond_Ubercharged))
				{
					percentage_Global *= 0.5;
				}
			}
#endif
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
#if defined RPG
			switch(BubbleProcStatusLogicCheck(client))
			{
				case -1:
				{
					percentage_Global *= 0.85;
				}
				case 1:
				{
					percentage_Global *= 1.15;
				}
			}
			if(TrueStength_ClientBuff(client))
			{
				percentage_Global *= 0.85;
			}
			if(WarCry_Enabled(client))
			{
				percentage_Global *= 0.75;
			}
			if(WarCry_Enabled_Buff(client))
			{
				percentage_Global *= WarCry_ResistanceBuff(client);
			}
			RPG_BobsPureRage(client, -1, percentage_Global);
#endif
			percentage_Global *= Attributes_Get(weapon, 4009, 1.0);
			value = Attributes_FindOnPlayerZR(client, 206, true, 0.0, true, true);	// MELEE damage resistance
			if(value)
				percentage *= value;
				
			value = Attributes_Get(weapon, 4007, 0.0);	// MELEE damage resitance
			if(value)
				percentage *= value;
			//melee res
			percentage *= percentage_Global;
			had_An_ability = false;
			
			int testvalue = 1;
			int DmgType = DMG_CLUB;
			OnTakeDamageResistanceBuffs(client, testvalue, testvalue, percentage, DmgType, testvalue, GetGameTime());
			if(percentage != 100.0 && percentage > 0.0)
			{
				if(percentage < 10.0)
				{
					FormatEx(buffer, sizeof(buffer), "%s [☛%.2f%%", buffer, percentage);
					had_An_ability = true;
				}
				else
				{

					FormatEx(buffer, sizeof(buffer), "%s [☛%.0f%%", buffer, percentage);
					had_An_ability = true;
				}
			}
			
			percentage = 100.0;
			percentage *= percentage_Global;
			value = Attributes_FindOnPlayerZR(client, 205, true, 0.0, true, true);	// MELEE damage resistance
			if(value)
				percentage *= value;

			value = Attributes_Get(weapon, 4008, 0.0);	// RANGED damage resistance
			if(value)
				percentage *= value;
			
			/*
			This ugly code is made so formatting it looks better, isntead of [res][res]
			itll be [res-res]
			So tis easier to read.

			*/
			DmgType = DMG_BULLET;
			OnTakeDamageResistanceBuffs(client, testvalue, testvalue, percentage, DmgType, testvalue, GetGameTime());
			if(percentage != 100.0 && percentage > 0.0)
			{
				if(had_An_ability)
				{
					FormatEx(buffer, sizeof(buffer), "%s|", buffer);
					if(percentage < 10.0)
					{
						FormatEx(buffer, sizeof(buffer), "%s➶%.2f%%]", buffer, percentage);
						had_An_ability = true;
					}
					else
					{
						FormatEx(buffer, sizeof(buffer), "%s➶%.0f%%]", buffer, percentage);
						had_An_ability = true;
					}
				}
				else
				{
					if(percentage < 10.0)
					{
						FormatEx(buffer, sizeof(buffer), "%s [➶%.2f%%]", buffer, percentage);
						had_An_ability = true;
					}
					else
					{
						FormatEx(buffer, sizeof(buffer), "%s [➶%.0f%%]", buffer, percentage);
						had_An_ability = true;
					}
				}
			}
			else
			{
				if(had_An_ability)
					FormatEx(buffer, sizeof(buffer), "%s]", buffer);
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
#if defined ZR
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
#endif

#if defined RPG
			if(ChronoShiftReady(client))
			{
				if(ChronoShiftReady(client) == 2)
				{
					had_An_ability = true;
					Format(buffer, sizeof(buffer), "%s [◈]", buffer);
				}
				else
				{
					had_An_ability = true;
					Format(buffer, sizeof(buffer), "%s [◈ %.1fs]", buffer, ChornoShiftCooldown(client));
				}
			}
#endif
		}
		 
		int red = 200;
		int green = 200;
		int blue = 200;
		int Alpha = 255;

#if defined ZR
		if(has_mage_weapon[client])
#endif
		{
			red = 255;
			green = 0;
			blue = 255;
			if(had_An_ability)
			{
				HudY -= 0.035;
				Format(buffer, sizeof(buffer), "%s\n", buffer);
			}
#if defined ZR
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
					else	//Player is DANGEROUSLY close to getting targeted by a ruina ion due to overmana!
					{
						red 	= 255;
						green 	= 0;
						blue	= 0;
					}
				}

			}
#endif

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
			
#if defined ZR
			Format(buffer, sizeof(buffer), "%t\n%s", "Current Mana", Current_Mana[client], max_mana[client], mana_regen[client], buffer);
#elseif defined RPG
			static Form form;
			Races_GetClientInfo(client, _, form);

			// form.Name
			red = 200;
			green = 200;
			blue = 255;
			Alpha = 255;
			if(i_TransformationLevel[client] > 0)
			{
				red = form.Form_RGBA[0];
				green = form.Form_RGBA[1];
				blue = form.Form_RGBA[2];
				Alpha = form.Form_RGBA[3];
			}
			
			char c_CurrentMana[255];
			IntToString(Current_Mana[client],c_CurrentMana, sizeof(c_CurrentMana));

			int offset = Current_Mana[client] < 0 ? 1 : 0;
			ThousandString(c_CurrentMana[offset], sizeof(c_CurrentMana) - offset);

			if(form.Name[0])
				Format(buffer, sizeof(buffer), "%s: %s\n%s", form.Name, c_CurrentMana, buffer);
			else
				Format(buffer, sizeof(buffer), "%t\n%s", "Capacity", Current_Mana[client], buffer);
#endif
		}

		//BUFFS!
		char Debuff_Adder_left[64];
		char Debuff_Adder_right[64];
		char Debuff_Adder[64];

		EntityBuffHudShow(client, -1, Debuff_Adder_left, Debuff_Adder_right);

		if(Debuff_Adder_left[0])
		{
			Format(Debuff_Adder, sizeof(Debuff_Adder), "%s%s", Debuff_Adder_left, Debuff_Adder);

			if(Debuff_Adder_right[0])
			{
				Format(Debuff_Adder, sizeof(Debuff_Adder), "%s|", Debuff_Adder);
			}
			Format(Debuff_Adder, sizeof(Debuff_Adder), "%s%s", Debuff_Adder, Debuff_Adder_right);
		}
		else
		{
			Format(Debuff_Adder, sizeof(Debuff_Adder), "%s%s", Debuff_Adder, Debuff_Adder_right);
		}

		if(Debuff_Adder[0])
		{
			Format(buffer, sizeof(buffer), "%s\n%s", Debuff_Adder, buffer);
			HudY += -0.0345; //correct offset
		}
		if(buffer[0])
		{
			SetHudTextParams(HudX, HudY, 0.81, red, green, blue, Alpha);
			ShowSyncHudText(client,  SyncHud_WandMana, "%s", buffer);
		}
	}
	else if(delay_hud[client] < GameTime)	
	{
		delay_hud[client] = GameTime + 0.4;

#if defined RPG
		RPG_UpdateHud(client);
		RPG_Sdkhooks_StaminaBar(client);
#endif

#if defined ZR
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
			Cooldowntocheck -= GetGameTime();

			if(Cooldowntocheck < 0.0)
			{
				Cooldowntocheck = 0.0;
			}

			char npc_classname[7];
			NPC_GetPluginById(i_NpcInternalId[converted_ref], npc_classname, sizeof(npc_classname));
			npc_classname[4] = CharToUpper(npc_classname[4]);
			npc_classname[5] = CharToUpper(npc_classname[5]);
			if(Cooldowntocheck > 0.0)
			{
				Format(buffer, sizeof(buffer), "%.1f\n%s\n", Cooldowntocheck, npc_classname[4]);
			}
			else
			{
				Format(buffer, sizeof(buffer), "%s\n", npc_classname[4]);
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
			if(Armor_Charge[armorEnt] == 0)
			{
				Format(buffer, sizeof(buffer), "%s%s", buffer, "--");
			}
			else if(armor >= Armor_Max*(i*0.1666) || (Armor_Regenerating && ArmorRegenCounter[client] == i))
			{
				Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_FULL);
			}
			else if(armor > Armor_Max*(i*0.1666 - 1.0/15.0))
			{
				Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_PARTFULL);
			}
			else if(armor > Armor_Max*(i*0.1666 - 1.0/10.0))
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
#endif
	}
#if defined ZR
	else if(f_DelayLookingAtHud[client] < GameTime)
	{
		//Reuse uhh
		//Doesnt reset often enough, fuck clientside.
		if (IsPlayerAlive(client))
		{
			int entity = GetClientPointVisible(client,70.0,_,_,_,1); //allow them to get info if they stare at something for abit long
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
#endif
}

public void OnPostThinkPost(int client)
{
	if(b_NetworkedCrouch[client])
	{
		SetEntProp(client, Prop_Send, "m_bAllowAutoMovement", 0);
	}
}
#endif	// ZR & RPG

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
#if defined RPG
	f_FlatDamagePiercing[attacker] = 1.0;
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
#endif

static stock void Player_OnTakeDamage_Equipped_Weapon_Logic_Post(int victim)
{
#if defined ZR
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
#endif
}

public Action Player_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
#if defined ZR
	i_WasInUber[victim] = 0.0;
	i_WasInMarkedForDeath[victim] = 0.0;
	i_WasInDefenseBuff[victim] = 0.0;
#endif

#if defined ZR
	if(TeutonType[victim])
	{
		//do not protect them.
		if(!(damagetype & DMG_CRUSH))
		{
			return Plugin_Handled;
		}
		else
		{
			return Plugin_Continue;
		}
	}
#endif

	float GameTime = GetGameTime();
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
	
	//Fall damage logic
	if(damagetype & DMG_FALL)
	{
#if defined RPG
		damage *= 400.0 / float(SDKCall_GetMaxHealth(victim));
#elseif defined ZR
		damage *= 0.45;	//Reduce falldmg by passive overall
		if(RaidbossIgnoreBuildingsLogic(1))
		{
			damage *= 0.75;			
		}
		else if(i_SoftShoes[victim] == 1)
		{
			damage *= 0.9;
		}
#endif
		if(f_ImmuneToFalldamage[victim] > GameTime)
		{
			damage = 0.0;
			return Plugin_Handled;	
		}
	}
	//Damage was done by a player
	else if(attacker <= MaxClients && attacker > 0 && attacker != 0)
	{
#if defined RPG
		if(!(RPGCore_PlayerCanPVP(attacker,victim)))
#endif
			return Plugin_Handled;	

#if defined RPG
		LastHitRef[victim] = EntIndexToEntRef(attacker);
#endif
	}
	else if (attacker != 0)
	{
		LastHitRef[victim] = EntIndexToEntRef(attacker);
	}
	
#if defined ZR
	if((damagetype & DMG_DROWN) && !b_ThisNpcIsSawrunner[attacker] && (!(i_HexCustomDamageTypes[victim] & ZR_STAIR_ANTI_ABUSE_DAMAGE)))
#else
	if((damagetype & DMG_DROWN) && (!(i_HexCustomDamageTypes[victim] & ZR_STAIR_ANTI_ABUSE_DAMAGE)))
#endif
	{
#if defined ZR
		if(!b_ThisNpcIsSawrunner[attacker])
		{
			if(damage < 10000.0)
			{
				NpcStuckZoneWarning(victim, damage);
			}
		}
		else
#endif
		{
			damage *= 2.0;
		}
	}
	f_TimeUntillNormalHeal[victim] = GameTime + 4.0;

	//dmg bonus before flat res!
	damage *= fl_Extra_Damage[attacker];
#if defined RPG
	if(Ability_TrueStrength_Shield_OnTakeDamage(victim))
	{
		return Plugin_Handled;	
	}
	f_InBattleDelay[victim] = GetGameTime() + 3.0;
#endif

#if defined ZR || defined RPG
	Replicate_Damage_Medications(victim, damage, damagetype);
#endif

	if(Damage_Modifiy(victim, attacker, inflictor, damage, damage, damagetype, weapon, damageForce, damagePosition, damagecustom))
	{
		return Plugin_Handled;
	}
	
#if defined ZR
	//damage is more then their health, they will die.
	if(RoundToCeil(damage) >= flHealth)
	{
		//the client has a suit, save them !!
		if(i_HealthBeforeSuit[victim] > 0)
		{
			damage = 0.0;
			TF2_AddCondition(victim, TFCond_UberchargedCanteen, 1.0);
			TF2_AddCondition(victim, TFCond_MegaHeal, 1.0);
			float startPosition[3];
			GetClientAbsOrigin(victim, startPosition);
			startPosition[2] += 25.0;
			makeexplosion(victim, victim, startPosition, "", 0, 0);
			GiveCompleteInvul(victim, 0.5);
			CreateTimer(0.0, QuantumDeactivate, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE); //early cancel out!, save the wearer!

			KillFeed_Show(victim, inflictor, attacker, 0, weapon, damagetype, true);
			return Plugin_Handled;
		}
		//the client was the last man on the server, or alone, give them spawn protection
		//dont do this if they are under specter saw revival
		else if((LastMann || b_IsAloneOnServer) && f_OneShotProtectionTimer[victim] < GameTime && !SpecterCheckIfAutoRevive(victim))
		{
			damage = 0.0;
			GiveCompleteInvul(victim, 2.0);
			EmitSoundToAll("misc/halloween/spell_overheal.wav", victim, SNDCHAN_STATIC, 80, _, 0.8);
			f_OneShotProtectionTimer[victim] = GameTime + 60.0; // 60 second cooldown

			return Plugin_Handled;
		}
		//if they were supposed to die, but had protection from the marchant kit, do this instead.
		else if(Merchant_OnLethalDamage(attacker, victim))
		{
			damage = 0.0;
			GiveCompleteInvul(victim, 0.1);
			KillFeed_Show(victim, inflictor, attacker, 0, weapon, damagetype, true);
			return Plugin_Handled;
		}
		//all checps passed, now go into here
		else if((!LastMann && !b_IsAloneOnServer) || SpecterCheckIfAutoRevive(victim))
		{
			//are they alone? is any player alive that isnt downed left?
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
			//there was no one left, they are the only one left, trigger last man.
			if(!Any_Left && !SpecterCheckIfAutoRevive(victim))
			{
				// Trigger lastman
				CheckAlivePlayers(_, victim);

				// Die in Rogue, there's no lastman
				return Rogue_NoLastman() ? Plugin_Continue : Plugin_Handled;
			}
			
			i_AmountDowned[victim] += 1;
			Rogue_PlayerDowned();
			
			//there are players still left, down them.
			if(SpecterCheckIfAutoRevive(victim) || (i_AmountDowned[victim] < 3 && !b_LeftForDead[victim]) || (i_AmountDowned[victim] < 2 && b_LeftForDead[victim]))
			{
				//https://github.com/lua9520/source-engine-2018-hl2_src/blob/3bf9df6b2785fa6d951086978a3e66f49427166a/game/shared/mp_shareddefs.cpp
				MakePlayerGiveResponseVoice(victim, 2); //dead!
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
				if(b_XenoVial[victim])
					Attributes_Set(victim, 489, 0.85);
				else
					Attributes_Set(victim, 489, 0.65);

				TF2_AddCondition(victim, TFCond_SpeedBuffAlly, 0.00001);
				int entity;

				bool autoRevive = (b_LeftForDead[victim] || SpecterCheckIfAutoRevive(victim));
				if(!autoRevive)
				{
					entity = EntRefToEntIndex(i_DyingParticleIndication[victim][0]);
					if(IsValidEntity(entity))
						RemoveEntity(entity);
					
					entity = EntRefToEntIndex(i_DyingParticleIndication[victim][1]);
					if(IsValidEntity(entity))
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

#if !defined RTS
	int ClientAttacker;
	if(IsValidClient(inflictor))
		ClientAttacker = inflictor;
	else if(IsValidClient(attacker))
		ClientAttacker = attacker;

	if(ClientAttacker > 0)
	{
		Calculate_And_Display_hp(ClientAttacker, victim, damage, false);
		if(IsValidEntity(weapon))
		{
			float KnockbackToGive = Attributes_Get(weapon, 4006, 0.0);
			Custom_Knockback(ClientAttacker, victim, KnockbackToGive, true);
		}
	}
#endif

	return Plugin_Changed;
}

#if defined ZR || defined RPG
void Replicate_Damage_Medications(int victim, float &damage, int damagetype)
{
	if(TF2_IsPlayerInCondition(victim, TFCond_MarkedForDeathSilent))
	{
		i_WasInMarkedForDeath[victim] = TF2Util_GetPlayerConditionDuration(victim, TFCond_MarkedForDeathSilent);
		TF2_RemoveCondition(victim, TFCond_MarkedForDeathSilent);
		damage *= 1.35;
	}
	if(TF2_IsPlayerInCondition(victim, TFCond_Jarated))
	{
		i_WasInJarate[victim] = TF2Util_GetPlayerConditionDuration(victim, TFCond_Jarated);
		TF2_RemoveCondition(victim, TFCond_Jarated);
		damage *= 1.35;
	}
	if(TF2_IsPlayerInCondition(victim, TFCond_DefenseBuffed))
	{
		i_WasInDefenseBuff[victim] = TF2Util_GetPlayerConditionDuration(victim, TFCond_DefenseBuffed);
		TF2_RemoveCondition(victim, TFCond_DefenseBuffed);
		damage *= 0.65;
	}
	float value;
	if(damagetype & (DMG_CLUB|DMG_SLASH))
	{
		value = Attributes_FindOnPlayerZR(victim, 206, true, 0.0, true, true);	// MELEE damage resitance
		if(value)
		{
			damage *= value;
		}
	}
	else if(!(damagetype & DMG_FALL))
	{
		value = Attributes_FindOnPlayerZR(victim, 205, true, 0.0, true, true);	// RANGED damage resistance
		if(value)
		{
			damage *= value;
		}
		//Everything else should be counted as ranged reistance probably.
	}
		
	value = Attributes_FindOnPlayerZR(victim, 412, true);	// Overall damage resistance
	if(value)
	{
		damage *= value;
	}	
	//only while active!
	int weapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
	if(weapon != -1)
	{
		damage *= Attributes_Get(weapon, 4009, 1.0);
		if(damagetype & (DMG_CLUB|DMG_SLASH))
		{
			value = Attributes_Get(weapon, 4007, 1.0);	// MELEE damage resitance
			if(value)
			{
				damage *= value;
			}
		}
		else if(!(damagetype & DMG_FALL))
		{
			value = Attributes_Get(weapon, 4008, 1.0);	// RANGED damage resistance
			if(value)
			{
				damage *= value;
			}
		}
	}
}
#endif	// ZR & RPG

public Action SDKHook_NormalSHook(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if(StrContains(sample, "#mvm/mvm_player_died.wav", true) != -1)
	{
		return Plugin_Handled;
	}
	if(StrContains(sample, "weapons/dispenser_idle.wav", true) != -1)
	{
		return Plugin_Handled;
	}
	if(StrContains(sample, "vo/halloween_scream", true) != -1)
	{
		return Plugin_Handled;
	}
	/*
	if(StrContains(sample, "sentry_", true) != -1)
	{
		volume *= 0.4;
		level = SNDLEVEL_NORMAL;
		
		if(StrContains(sample, "sentry_spot", true) != -1)
			volume *= 0.35;
			
		return Plugin_Changed;
	}
	*/
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

#if defined ZR || defined RPG
	Store_WeaponSwitch(client, weapon);
	RequestFrame(OnWeaponSwitchFrame, GetClientUserId(client));
#endif

#if defined RPG
	//Attributes_Set(client, 698, 1.0);
	SetEntProp(client, Prop_Send, "m_bWearingSuit", true); //Disables weapon switching????
#endif

}

#if defined ZR || defined RPG
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
//problem: tf2 code lazily made it only work for clients, the server doesnt get this information updated all the time now.
#define SKIN_ZOMBIE			5
#define SKIN_ZOMBIE_SPY		SKIN_ZOMBIE + 18

void UpdatePlayerFakeModel(int client)
{
	int PlayerModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(PlayerModel > 0)
	{	
#if defined ZR || defined RPG
		SDKCall_RecalculatePlayerBodygroups(client);
		i_nm_body_client[client] = GetEntProp(client, Prop_Data, "m_nBody");
		SetEntProp(PlayerModel, Prop_Send, "m_nBody", i_nm_body_client[client]);
#endif
	}
}


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

#if defined RPG
void RPGRegenerateResource(int client, bool ignoreRequirements = false, bool DrainForm = false)
{
	//Regenerate stamina over time at all times!
	if(i_TransformationLevel[client] > 0)
		RPGCore_StaminaAddition(client, i_MaxStamina[client] / 30);
	else
		RPGCore_StaminaAddition(client, i_MaxStamina[client] / 15);
	
	//firstly regen any resource!
	if(f_InBattleDelay[client] < GetGameTime() && f_TimeUntillNormalHeal[client] < GetGameTime())
	{
		//regen health if they werent in battle!
		int healing_Amount;
		
		if(i_TransformationLevel[client] > 0)
			healing_Amount = HealEntityGlobal(client, client, float(SDKCall_GetMaxHealth(client)) / 80.0, 1.0, 0.0, HEAL_SELFHEAL);	
		else
			healing_Amount = HealEntityGlobal(client, client, float(SDKCall_GetMaxHealth(client)) / 40.0, 1.0, 0.0, HEAL_SELFHEAL);	

		if(healing_Amount)
			ApplyHealEvent(client, healing_Amount);
	}
	if((f_TransformationDelay[client] < GetGameTime() && i_TransformationLevel[client] == 0 && f_InBattleDelay[client] < GetGameTime() && f_TimeUntillNormalHeal[client] < GetGameTime())  || ignoreRequirements)
	{
		//if outside of battle and not in transformations that drain resource, regenerate resource.
		if(i_TransformationLevel[client] > 0)
			RPGCore_ResourceAddition(client, RoundToCeil(max_mana[client] / 40.0));
		else
			RPGCore_ResourceAddition(client, RoundToCeil(max_mana[client] / 20.0));
	}
	else
	{
		//if they are in battle, regenerate resource much slower.
		if(i_TransformationLevel[client] > 0)
			RPGCore_ResourceAddition(client, RoundToCeil(max_mana[client] / 400.0));
		else
			RPGCore_ResourceAddition(client, RoundToCeil(max_mana[client] / 200.0));
	}

	if(DrainForm)
	{
		if(i_TransformationLevel[client] > 0)
		{
			//They are in a transformation!
			//do drain logic here!
			float Drain = 0.0;
			Form form;
			Races_GetClientInfo(client, _, form);
			Drain = form.GetFloatStat(Form::DrainRate, Stats_GetFormMastery(client, form.Name));
			Drain *= 0.015; //drains are too high!

			int StatsForDrainMulti;
			int StatsForDrainMultiAdd;
			Stats_Precision(client, StatsForDrainMultiAdd);
			StatsForDrainMulti += StatsForDrainMultiAdd;
			Stats_Strength(client, StatsForDrainMultiAdd);
			StatsForDrainMulti += StatsForDrainMultiAdd;
			Stats_Artifice(client, StatsForDrainMultiAdd);
			StatsForDrainMulti += StatsForDrainMultiAdd;
			Stats_Endurance(client, StatsForDrainMultiAdd);
			StatsForDrainMulti += StatsForDrainMultiAdd;

			//We take the base drain rate and multiply it by all the base stats.
			Drain *= float(StatsForDrainMulti);

			
			//if it isnt 0, do nothing
			//some forms may have generation! who knows.
			if(Drain != 0.0)
			{
				if(Drain > 0.0)
					RPGCore_ResourceReduction(client, RoundToNearest(Drain), true);
				else
					RPGCore_ResourceAddition(client, RoundToNearest(Drain * -1.0)); //the drain actually gives resource! inverse!
			}
		}
	}
}

/*
	#define CHAR_FULL	"█"
	#define CHAR_PARTFULL	"▓"
	#define CHAR_PARTEMPTY	"▒"
	#define CHAR_EMPTY	"░"
*/
void RPG_Sdkhooks_StaminaBar(int client)
{
	char buffer[32];
	int Stamina = i_CurrentStamina[client];
	int MaxStamina = i_MaxStamina[client];
	int MaxBars = 6;
	float BarPercentage;
	BarPercentage = 1.0 / float(MaxBars);
	//todo: Fix the bars being offset really wierdly
	for(int i=MaxBars; i>0; i--)
	{ 	
		if(Stamina >= MaxStamina*(i*BarPercentage))
		{
			Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_FULL);
		}
		else if(Stamina > MaxStamina*(i*BarPercentage - 1.0/15.0))
		{
			Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_PARTFULL);
		}
		else if(Stamina > MaxStamina*(i*BarPercentage - 1.0/10.0))
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
	int red = 255;
	int green = 165;
	int blue = 0;
	SetHudTextParams(0.175 + f_ArmorHudOffsetY[client], 0.925 + f_ArmorHudOffsetX[client], 0.81, red, green, blue, 255);
	ShowSyncHudText(client, SyncHud_ArmorCounter, "%s", buffer);
}
#endif