#pragma semicolon 1
#pragma newdecls required

//static float i_WasInUber[MAXPLAYERS] = {0.0,0.0,0.0};
static float i_WasInMarkedForDeathSilent[MAXPLAYERS] = {0.0,0.0,0.0};
static float i_WasInMarkedForDeath[MAXPLAYERS] = {0.0,0.0,0.0};
static float i_WasInDefenseBuff[MAXPLAYERS] = {0.0,0.0,0.0};
static float i_WasInJarate[MAXPLAYERS] = {0.0,0.0,0.0};
static float f_EntityHazardCheckDelay[MAXPLAYERS];
static float f_EntityOutOfNav[MAXPLAYERS];
static float f_LatestDamageRes[MAXPLAYERS];
static float f_TimeSinceLastRegenStop[MAXPLAYERS];
static bool b_GaveMarkForDeath[MAXPLAYERS];
static char MaxAsignPerkNames[MAXPLAYERS][8];

//With high ping our method to change weapons with a click of a button or whtaever breaks.
//This will be used as a timer to fix this issue
static float f_CheckWeaponDouble[MAXPLAYERS];

bool Client_Had_ArmorDebuff[MAXPLAYERS];

#if defined ZR
int Armor_WearableModelIndex;
int Wing_WearlbeIndex;
#endif

bool ClientPassAliveCheck[MAXPLAYERS];

void SDKHooks_ClearAll()
{
#if defined ZR
	Zero(Armor_regen_delay);
#endif
	
	for (int client = 1; client <= MaxClients; client++)
	{
		i_WhatLevelForHudIsThisClientAt[client] = 2000000000; //two billion
	}
	Zero(f_ReceivedTruedamageHit);
	Zero(f_EntityHazardCheckDelay);
	Zero(f_EntityOutOfNav);
	
//	Zero(i_WasInUber);
	Zero(i_WasInMarkedForDeathSilent);
	Zero(i_WasInMarkedForDeath);
	Zero(i_WasInDefenseBuff);
	Zero(i_WasInJarate);
	Zero(i_WasInResPowerup);
	Zero(Client_Had_ArmorDebuff);
	Zero(f_TimeSinceLastRegenStop);
	Zero(b_GaveMarkForDeath);
	Zero(f_CheckWeaponDouble);
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
	
#if defined ZR
	for(int client = 1; client < sizeof(RecentSoundList); client++)
	{
		RecentSoundList[client] = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	}
#endif

#if !defined NOG
	AddNormalSoundHook(SDKHook_NormalSHook);
	AddAmbientSoundHook(SDKHook_AmbientSoundHook);
#endif
}
void SDKHook_MapStart()
{
	Zero(f_EntityIsStairAbusing);
#if defined ZR
	Zero(Mana_Loss_Delay);
	Zero(Mana_Regen_Block_Timer);
	Armor_WearableModelIndex = PrecacheModel("models/effects/resist_shield/resist_shield.mdl", true);
	Wing_WearlbeIndex = PrecacheModel(WINGS_MODELS_1, true);
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
	static int offset_Class = -1;
	static int offset_Team = -1;

	#if defined ZR
	static int offset_Alive = -1;
	#endif


		
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

	//Class
	if(offset_Class == -1) 
		offset_Class = FindSendPropInfo("CTFPlayerResource", "m_iPlayerClass");

	//Class
	if(offset_Team == -1) 
		offset_Team = FindSendPropInfo("CTFPlayerResource", "m_iTeam");

	#if defined ZR
	//Alive
	if(offset_Alive == -1) 
		offset_Alive = FindSendPropInfo("CTFPlayerResource", "m_bAlive");
	
	bool[] alive = new bool[MaxClients+1];
	#endif

	int[] CashCurrentlyOwned = new int[MaxClients+1];
	int[] class = new int[MaxClients+1];
	int[] team = new int[MaxClients+1];
	for(int client=1; client<=MaxClients; client++)
	{
	#if defined ZR
		CashCurrentlyOwned[client] = CurrentCash-CashSpent[client];
		alive[client] = (TeutonType[client] == TEUTON_NONE && IsClientInGame(client) && IsPlayerAlive(client));
	#else
		CashCurrentlyOwned[client] = TextStore_Cash(client);
	#endif

		class[client] = i_PlayerModelOverrideIndexWearable[client] >= 0 ? 0 : view_as<int>(CurrentClass[client]);
		
		if(IsClientInGame(client))
			team[client] = IsFakeClient(client) ? KillFeed_GetBotTeam(client) : GetClientTeam(client);
	}

	//healing done
	if(offset_Healing == -1) 
		offset_Healing = FindSendPropInfo("CTFPlayerResource", "m_iHealing");
	
	#if defined ZR
	SetEntDataArray(entity, offset, PlayerPoints, MaxClients + 1);
	SetEntDataArray(entity, offset_Alive, alive, MaxClients + 1);
	#else
	SetEntDataArray(entity, offset, Level, MaxClients + 1);
	#endif

	SetEntDataArray(entity, offset_Damage, i_Damage_dealt_in_total, MaxClients + 1);
	SetEntDataArray(entity, offset_Damage_Boss, i_PlayerDamaged, MaxClients + 1);
	SetEntDataArray(entity, offset_Healing, Healing_done_in_total, MaxClients + 1);
	SetEntDataArray(entity, offset_Cash, CashCurrentlyOwned, MaxClients + 1);
	SetEntDataArray(entity, offset_Class, class, MaxClients + 1);
	SetEntDataArray(entity, offset_Team, team, MaxClients + 1);

	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && !b_IsPlayerABot[client])
		{
			SetEntProp(client, Prop_Data, "m_iFrags", i_KillsMade[client]);
			SetEntProp(client, Prop_Send, "m_iHealPoints", Healing_done_in_total[client]);
			SetEntProp(client, Prop_Send, "m_iBackstabs", i_Backstabs[client]);
			SetEntProp(client, Prop_Send, "m_iHeadshots", i_Headshots[client]);

	#if defined ZR
			SetEntProp(client, Prop_Send, "m_iDefenses", RoundToCeil(float(i_BarricadeHasBeenDamaged[client]) * 0.01));
	#endif

		}
	}	
}
#endif	// ZR & RPG

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

	SDKUnhook(client, SDKHook_WeaponCanSwitchToPost, WeaponSwtichToWarningPost);
	SDKHook(client, SDKHook_WeaponCanSwitchToPost, WeaponSwtichToWarningPost);

#endif
#endif


	SDKUnhook(client, SDKHook_OnTakeDamageAlivePost, Player_OnTakeDamageAlivePost);
	SDKHook(client, SDKHook_OnTakeDamageAlivePost, Player_OnTakeDamageAlivePost);
	SDKUnhook(client, SDKHook_OnTakeDamage, Player_OnTakeDamage);
	SDKHook(client, SDKHook_OnTakeDamage, Player_OnTakeDamage);
	SDKUnhook(client, SDKHook_OnTakeDamageAlive, Player_OnTakeDamageAlive_DeathCheck);
	SDKHook(client, SDKHook_OnTakeDamageAlive, Player_OnTakeDamageAlive_DeathCheck);
	

}

public void CheckWeaponAmmoLogicExternal(DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(client) && IsValidEntity(weapon))
		IsWeaponEmptyCompletly(client, weapon);
		
	delete pack;
}
bool WeaponWasGivenInfiniteDelay[MAXENTITIES];

void WeaponWeaponAdditionOnRemoved(int entity)
{
	WeaponWasGivenInfiniteDelay[entity] = false;
}

bool IsWeaponEmptyCompletly(int client, int weapon, bool CheckOnly = false)
{
	int Ammo_type = GetAmmoType_WeaponPrimary(weapon);
	if(Ammo_type > 3)
	{
		if(GetAmmo(client, Ammo_type) <= 0)
		{
			if(b_WeaponHasNoClip[weapon])
			{
				if(!CheckOnly)
				{
					SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", FAR_FUTURE);
					WeaponWasGivenInfiniteDelay[weapon] = true;
				}
				return true;
			}
			else
			{
				//We check for clip.
				int iAmmoTable = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
				int GetClip = GetEntData(weapon, iAmmoTable, 4);
				if(GetClip <= 0)
				{
					if(!CheckOnly)
					{
						SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", FAR_FUTURE);
						WeaponWasGivenInfiniteDelay[weapon] = true;
					}
					return true;
				}
			}
		}
	}
	return false;
}

public Action WeaponSwtichToWarning(int client, int weapon)
{
	/*
	int Ammo_type = GetAmmoType_WeaponPrimary(weapon);
	if(Ammo_type > 0 && Ammo_type != Ammo_Potion_Supply && Ammo_type != Ammo_Hand_Grenade)
	{
		if(GetAmmo(client, Ammo_type) <= 0)
		{
			SetGlobalTransTarget(client);
			PrintToChat(client, "%t", "Warn Client Ammo None");
		}
	}
	*/

	
//	int WeaponToForce;
	int ie, weapon1;
	while(TF2_GetItem(client, weapon1, ie))
	{
		//make sure to not brick melees...
		if(IsValidEntity(weapon1) && GetAmmoType_WeaponPrimary(weapon1) > 2)
		{
			if(IsWeaponEmptyCompletly(client, weapon1, true))
				SetEntProp(weapon1, Prop_Send, "m_iPrimaryAmmoType", 1);
		}
	}
	return Plugin_Continue;
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

	int WeaponToForce;
	int ie, weapon1;
	while(TF2_GetItem(client, weapon1, ie))
	{
		//make sure to not brick melees...
		if(IsValidEntity(weapon1) && GetAmmoType_WeaponPrimary(weapon1) > 3)
		{
			if(weapon == 0)
			{
				int weapon2 = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon2 == weapon1)
				{
					WeaponToForce = weapon2;
					continue;
				}
			}
			else
			{
				WeaponToForce = weapon;
				continue;
			}
		}
	}
	if(GetAmmoType_WeaponPrimary(WeaponToForce) > 3)
	{
		IsWeaponEmptyCompletly(client, WeaponToForce);
		//Swtiched to the active weapon!!!! yippie!!
		SetEntProp(WeaponToForce, Prop_Send, "m_iPrimaryAmmoType", GetAmmoType_WeaponPrimary(WeaponToForce));
	}
}

#if defined ZR || defined RPG
public void OnPreThinkPost(int client)
{
	if(b_NetworkedCrouch[client])
	{
		SetEntProp(client, Prop_Send, "m_bAllowAutoMovement", 1);
	}
	Cvar_clamp_back_speed.FloatValue = f_Client_BackwardsWalkPenalty[client];
	Cvar_LoostFooting.FloatValue = f_Client_LostFriction[client];
	sv_gravity.IntValue = i_Client_Gravity[client];
}
#endif	// ZR & RPG

#if defined NOG
public void OnPostThink_OnlyHurtHud(int client)
{
	//cooldown to prevent hud issues
	if(f_DisplayDamageHudCooldown[client] > GetGameTime())
		return;

	if(b_DisplayDamageHud[client][0])
	{
		b_DisplayDamageHud[client][0] = false;
		b_DisplayDamageHud[client][1] = false;
		if(zr_showdamagehud.BoolValue)
			Calculate_And_Display_HP_Hud(client);

		f_DisplayDamageHudCooldown[client] = GetGameTime() + 0.2;
	}
}

#endif

#if defined ZR || defined RPG
public void OnPostThink(int client)
{
//	Profiler profiler = new Profiler();
//	profiler.Start();
	float GameTime = GetGameTime();
	bool OnlyOneAtATime = false;
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
				SDKHooks_TakeDamage(client, 0, 0, damageTrigger, DMG_OUTOFBOUNDS, -1,_,_,_,ZR_STAIR_ANTI_ABUSE_DAMAGE);
			}
		}
	}
#if defined ZR
	if(SkillTree_InMenu(client))
	{
		TreeMenu(client,_, false);
	}
#endif
	if(GetTeam(client) == 2)
	{
#if defined ZR
		if(dieingstate[client] != 0 || TeutonType[client] != TEUTON_NONE)
#endif
		{
			//they are a teuton, or dying, teleport them out of bad places.
			if(f_EntityHazardCheckDelay[client] < GetGameTime())
			{
				//We have to use this logic instead of the trigger touch method
				//as these dying players or teutons dont interact with these objects.
				float flPos[3];
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
				if(IsPointHazard(flPos))
				{
					TeleportBackToLastSavePosition(client);
				}
				f_EntityHazardCheckDelay[client] = GetGameTime() + 0.25;
			}
		}
#if defined ZR
		if(dieingstate[client] == 0 && TeutonType[client] == TEUTON_NONE)
#endif
		{
			//they are alive, but somehow in a bad position, check and teleport them out of there.
			if(f_EntityOutOfNav[client] < GetGameTime())
			{
				Spawns_CheckBadClient(client);
				f_EntityOutOfNav[client] = GetGameTime() + GetRandomFloat(0.9, 1.1);
			}
		}
		//save the last safe position to teleport back to.
		SaveLastValidPositionEntity(client);
	
	}
	if(b_DisplayDamageHud[client][0] || b_DisplayDamageHud[client][1])
	{
		//damage hud
#if defined ZR
		if(!SkillTree_InMenu(client) && Calculate_And_Display_HP_Hud(client, b_DisplayDamageHud[client][1]))
#else
		if(Calculate_And_Display_HP_Hud(client, b_DisplayDamageHud[client][1]))
#endif
		{
			if(b_DisplayDamageHud[client][1])
				b_DisplayDamageHud[client][1] = false;
			else
				b_DisplayDamageHud[client][0] = false;
		}
	}
	if(ReplicateClient_BackwardsWalk[client] != f_Client_BackwardsWalkPenalty[client])
	{
		char IntToStringDo[4];
		FloatToString(f_Client_BackwardsWalkPenalty[client], IntToStringDo, sizeof(IntToStringDo));
		Cvar_clamp_back_speed.ReplicateToClient(client, IntToStringDo); //set down
		ReplicateClient_BackwardsWalk[client] = f_Client_BackwardsWalkPenalty[client];
	}
	if(ReplicateClient_LostFooting[client] != f_Client_LostFriction[client])
	{
		char IntToStringDo[4];
		FloatToString(f_Client_LostFriction[client], IntToStringDo, sizeof(IntToStringDo));
		Cvar_LoostFooting.ReplicateToClient(client, IntToStringDo); //set down
		ReplicateClient_LostFooting[client] = f_Client_LostFriction[client];
	}
	if(ReplicateClient_Gravity[client] != i_Client_Gravity[client])
	{
		char IntToStringDo[4];
		IntToString(i_Client_Gravity[client], IntToStringDo, sizeof(IntToStringDo));
		sv_gravity.ReplicateToClient(client, IntToStringDo); //set down
		ReplicateClient_Gravity[client] = i_Client_Gravity[client];
	}

#if defined ZR
	CorrectClientsideMultiweapon(client, 2);
#endif
	//Reduce knockback when airborn, this is to fix issues regarding flying way too high up, making it really easy to tank groups!
	int WasAirbornType = 0;
	if (!(GetEntityFlags(client) & FL_ONGROUND))
	{
		WasAirbornType = 1;
	}
	else
	{
		int RefGround =  GetEntPropEnt(client, Prop_Send, "m_hGroundEntity");
		int GroundEntity = EntRefToEntIndex(RefGround);
		if(GroundEntity > 0 && GroundEntity < MAXENTITIES)
		{
			if(b_ThisWasAnNpc[GroundEntity])
			{
				//when standing on an npc you gain less knockack reduction
				WasAirbornType = 1;
				if(b_thisNpcIsARaid[GroundEntity])
					WasAirbornType = 2;
				//when ontop of a raidboss, gain no knockback reduction.
			}
		}
	}

	if(WasAirbornType == 1 && !b_PlayerWasAirbornKnockbackReduction[client])
	{
		int EntityWearable = EntRefToEntIndex(i_StickyAccessoryLogicItem[client]);
		if(EntityWearable > 0)
		{
			f_ClientInAirSince[client] = GetGameTime() + 5.0;
			b_PlayerWasAirbornKnockbackReduction[client] = true;
			Attributes_Set(EntityWearable, 252, 0.5);
		}
	}
	else if((WasAirbornType == 0 || WasAirbornType == 2) && b_PlayerWasAirbornKnockbackReduction[client])
	{
		int EntityWearable = EntRefToEntIndex(i_StickyAccessoryLogicItem[client]);
		if(EntityWearable > 0)
		{
			//when they land, check if they are in a bad pos
			Spawns_CheckBadClient(client/*, 2*/);
			//no need to recheck when they land
			f_EntityOutOfNav[client] = GetGameTime() + GetRandomFloat(0.9, 1.1);
			b_PlayerWasAirbornKnockbackReduction[client] = false;
			Attributes_Set(EntityWearable, 252, 1.0);
		}
	}
#if defined ZR
	bool Mana_Regen_Tick = false;

	if(Rogue_CanRegen() && (Mana_Regen_Delay[client] < GameTime || (b_AggreviatedSilence[client] && Mana_Regen_Delay_Aggreviated[client] < GameTime)))
	{
		Mana_Regen_Delay[client] = GameTime + 0.4;
		Mana_Regen_Delay_Aggreviated[client] = GameTime + 0.4;

		has_mage_weapon[client] = false;
		
		Mana_Regen_Tick = true;

		ManaCalculationsBefore(client);
	
		if(Current_Mana[client] < RoundToCeil(max_mana[client]) && Mana_Regen_Block_Timer[client] < GameTime)
		{
			Current_Mana[client] += RoundToCeil(mana_regen[client]);
				
			if(Current_Mana[client] > RoundToCeil(max_mana[client])) //Should only apply during actual regen
			{
				Current_Mana[client] = RoundToCeil(max_mana[client]);
				mana_regen[client] = 0.0;
			}
		}
		else
		{
			mana_regen[client] = 0.0;
		}
		if(HasSpecificBuff(client, "Dimensional Turbulence"))
		{
			Current_Mana[client] = 9999999;
			mana_regen[client] = 9999999.9;
			max_mana[client] = 9999999.9;
		}
					
		Mana_Hud_Delay[client] = 0.0;
	}
	//A part of Ruina's special mana "corrosion"
	if(Current_Mana[client] > RoundToCeil(max_mana[client]+10.0))	
	{
		//if they are using a magic weapon, don't take away the overmana. can be both a good and bad thing, good in non ruina situations, possibly bad in ruina situations
		//the +10 is for rounding errors.
		//CPrintToChatAll("Overmana decay triggered");
		if(Current_Mana[client] > RoundToCeil(max_mana[client] * 2.1))
		{
			//cant be above max.
			Current_Mana[client] = RoundToCeil(max_mana[client] * 2.1);
		}
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

	if(f_TimerStatusEffectsDo[client] < GetGameTime())
	{
		//re using NPC value.
		StatusEffect_TimerCallDo(client);
		f_TimerStatusEffectsDo[client] = GetGameTime() + 0.4;
	}
	if(Rogue_CanRegen() && Armor_regen_delay[client] < GameTime)
	{
		Armour_Level_Current[client] = 0;
		if(f_LivingArmorPenalty[client] < GetGameTime() && Attributes_Get(client, Attrib_Armor_AliveMode, 0.0) != 0.0)
		{
			//regen armor if out of battle
			if(f_TimeUntillNormalHeal[client] < GetGameTime() && dieingstate[client] == 0)
			{
				if(Armor_Charge[client] >= 0)
				{
					float DefaultRegenArmor = 0.06666;
					GiveArmorViaPercentage(client, DefaultRegenArmor, 1.0);
				}
			}
		}

		
		if(!Rogue_Paradox_GrigoriBlessing(client))
		{
			if(Grigori_Blessing[client] == 1)
			{
				if(dieingstate[client] > 0)
				{
					HealEntityGlobal(client, client, 3.0, 0.5, 0.0, HEAL_SELFHEAL|HEAL_PASSIVE_NO_NOTIF);	
				}
				else
				{
					float MaxHealth = float(SDKCall_GetMaxHealth(client));
					if(MaxHealth > 3000.0)
						MaxHealth = 3000.0;

						
					if(Rogue_Rift_HolyBlessing())
						MaxHealth *= 2.0;
					HealEntityGlobal(client, client, MaxHealth / 100.0, Rogue_Rift_HolyBlessing() ? 1.0 : 0.5, 0.0, HEAL_SELFHEAL|HEAL_PASSIVE_NO_NOTIF);	
					
					float attrib = Attributes_Get(client, Attrib_BlessingBuff, 1.0);
					if(f_TimeUntillNormalHeal[client] < GetGameTime())
					{
					//	float DefaultRegenArmor = 0.05;
						if(attrib >= 1.0)
						{
							attrib -= 1.0; //1.0 is default
							if(Rogue_Rift_HolyBlessing())
								MaxHealth *= 0.5;
							HealEntityGlobal(client, client, (MaxHealth * attrib), Rogue_Rift_HolyBlessing() ? 1.0 : 0.5, 0.0, HEAL_SELFHEAL|HEAL_PASSIVE_NO_NOTIF);	
					//		DefaultRegenArmor += attrib;
						}
					//	if(Armor_Charge[client] >= 0)
					//		GiveArmorViaPercentage(client, DefaultRegenArmor, 0.25);
					}
				}
			}
		}

		float attrib;
		
		attrib = Attributes_GetOnPlayer(client, Attrib_SlowImmune, false);
		if(attrib)
		{
			ApplyStatusEffect(client, client, "Fluid Movement", 1.0);
		}

		attrib = Attributes_Get(client, 57, 0.0);
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon != -1)
		{
			attrib += Attributes_Get(weapon, 57, 0.0);
		}
		//Players should always have atleast 1 HP regen!
		attrib += 1.0;
		if(Saga_RegenHealth(client))
			attrib += 10.0;

		if(dieingstate[client] == 0)
		{
			if(attrib)
				HealEntityGlobal(client, client, attrib, 1.0, 0.0, HEAL_SELFHEAL|HEAL_PASSIVE_NO_NOTIF);

			//This heal will show in the hud.
			attrib = Attributes_GetOnPlayer(client, Attrib_RegenHpOutOfBattle_MaxHealthScaling, true,_, 0.0);	// rage on kill
			if(attrib)
			{
				if(f_TimeUntillNormalHeal[client] < GetGameTime())
				{
					float MaxHealth = float(SDKCall_GetMaxHealth(client));
					if(MaxHealth > 3000.0)
						MaxHealth = 3000.0;
					//show this healing.
					HealEntityGlobal(client, client, MaxHealth * attrib, 1.0, 0.0, HEAL_SELFHEAL);	
				}
			}
			attrib = 0.0;
			if(ClientPossesesVoidBlade(client) >= 2 && (NpcStats_WeakVoidBuff(client) || NpcStats_StrongVoidBuff(client)))
			{
				attrib += float(ReturnEntityMaxHealth(client)) * 0.01;

				if(NpcStats_StrongVoidBuff(client))
					attrib *= 1.5;
			}
			if(HasSpecificBuff(client, "Regenerating Therapy"))
			{
				attrib += float(ReturnEntityMaxHealth(client)) * 0.01;
			}
			if(attrib)
			{
				HealEntityGlobal(client, client, attrib, 1.25, 0.0, HEAL_SELFHEAL);
			}
			
		}
		
		Armor_regen_delay[client] = GameTime + 1.0;
		SDkHooks_Think_TutorialStepsDo(client);
	}
#endif	// ZR
	if(Mana_Hud_Delay[client] < GameTime)
	{
		OnlyOneAtATime = true;
		SetGlobalTransTarget(client);

#if defined ZR
		if(BetWar_ShowStatus(client))
		{
			Mana_Hud_Delay[client] = GameTime + 0.1;
		}
		else
#endif	// ZR
		{
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
				AllowWeaponFireAfterEmpty(client, weapon);
				static float cooldown_time;
				had_An_ability = false;
				static bool IsReady;
				IsReady = false;

				had_An_ability = false;
				
				if(c_WeaponUseAbilitiesHud[weapon][0])
				{
					if(had_An_ability)
					{
						Format(buffer, sizeof(buffer), "| %s", buffer);
					}
					had_An_ability = true;
						
					Format(buffer, sizeof(buffer), "%s %s", c_WeaponUseAbilitiesHud[weapon], buffer);
					IsReady = false;
				}
				if(i_Hex_WeaponUsesTheseAbilities[weapon] & ABILITY_M1)
				{
					cooldown_time = Ability_Check_Cooldown(client, 1);

					if(had_An_ability)
					{
						Format(buffer, sizeof(buffer), "| %s", buffer);
					}
					had_An_ability = true;
					if(cooldown_time < 0.0 || cooldown_time > 99999.9)
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
					if(cooldown_time < 0.0 || cooldown_time > 99999.9)
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
					if(cooldown_time < 0.0 || cooldown_time > 99999.9)
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
					
					if(cooldown_time < 0.0 || cooldown_time > 99999.9)
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
				
				if(IsValidEntity(i_PlayerToCustomBuilding[client]))
				{
					cooldown_time = f_BuildingIsNotReady[client] - GameTime;
						
					if(had_An_ability)
					{
						Format(buffer, sizeof(buffer), "| %s", buffer);
					}	
					if(cooldown_time < 0.0 || cooldown_time > 99999.9)
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
				
				if(Store_ActiveCanMulti(client))
				{
					if(had_An_ability)
					{
						Format(buffer, sizeof(buffer), "| %s", buffer);
					}	
					if(!b_GivePlayerHint[client])
					{
						SPrintToChat(client, "%t","Hint Change Multislot");
						b_GivePlayerHint[client] = true;
					}
					Format(buffer, sizeof(buffer), "[Multi Slot] %s", buffer);
					IsReady = false;
					had_An_ability = true;
				}
	#endif
				
				if(had_An_ability)
				{
					HudY -= 0.035;
					Format(buffer, sizeof(buffer), "%s\n", buffer);
				}
				float percentage_melee = 100.0;
				float percentage_ranged = 100.0;
				int i_TheWorld = 0;
				int testvalue = 1;
				float testvalue1[3];
				CheckInHudEnable(1);
				int DmgType = DMG_CLUB;
				Player_OnTakeDamage(client, i_TheWorld, i_TheWorld, percentage_melee, DmgType, weapon, testvalue1, testvalue1,testvalue);
				DmgType = DMG_BULLET;
				Player_OnTakeDamage(client, i_TheWorld, i_TheWorld, percentage_ranged, DmgType, weapon, testvalue1, testvalue1,testvalue);
				CheckInHudEnable(0);

				had_An_ability = false;
				if(percentage_melee <= 0.0 && percentage_ranged <= 0.0)
				{
					FormatEx(buffer, sizeof(buffer), "%s %t",buffer, "Invulnerable Npc");
					had_An_ability = true;
				}
				else
				{
					if(percentage_melee != 100.0 && percentage_melee > 0.0)
					{
						static char NumberAdd[32];
						had_An_ability = true;
						if(percentage_melee < 10.0)
						{
							Format(NumberAdd, sizeof(NumberAdd), "[☛%.2f％", percentage_melee);
						}
						else
						{
							Format(NumberAdd, sizeof(NumberAdd), "[☛%.0f％", percentage_melee);
						}
						
						if(f_ClientDoDamageHud_Hurt[client][0] > GetGameTime())
							Npcs_AddUnderscoreToText(NumberAdd, sizeof(NumberAdd));

						Format(buffer, sizeof(buffer), "%s%s", buffer, NumberAdd);
					}
					
					if(percentage_ranged != 100.0 && percentage_ranged > 0.0)
					{
						static char NumberAdd[32];
						if(had_An_ability)
						{
							if(percentage_ranged < 10.0)
							{
								FormatEx(NumberAdd, sizeof(NumberAdd), "|➶%.2f％", percentage_ranged);
							}
							else
							{
								FormatEx(NumberAdd, sizeof(NumberAdd), "|➶%.0f％", percentage_ranged);
							}
						}
						else
						{
							if(percentage_ranged < 10.0)
							{
								FormatEx(NumberAdd, sizeof(NumberAdd), "[➶%.2f％", percentage_ranged);
							}
							else
							{
								FormatEx(NumberAdd, sizeof(NumberAdd), "[➶%.0f％", percentage_ranged);
							}
						}

						had_An_ability = true;
						if(f_ClientDoDamageHud_Hurt[client][1] > GetGameTime())
							Npcs_AddUnderscoreToText(NumberAdd, sizeof(NumberAdd));

						Format(buffer, sizeof(buffer), "%s%s", buffer, NumberAdd);
						Format(buffer, sizeof(buffer), "%s]", buffer);
					}
					else
					{
						if(had_An_ability)
							FormatEx(buffer, sizeof(buffer), "%s]", buffer);
					}
				}
				
	#if defined RPG
				//Form res
				float percentage = 1.0;
				float value = Attributes_GetOnPlayer(client, Attrib_FormRes, true, true, 0.0);
				if(value)
					percentage *= value;

				if(percentage != 1.0 && percentage > 0.0)
				{
					percentage = 1.0 / percentage;
					FormatEx(buffer, sizeof(buffer), "%s[HP x%.1f]", buffer, percentage);
					had_An_ability = true;
				}
	#endif
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
							FormatEx(buffer, sizeof(buffer), "%s [⚐ %.0f％]", buffer, GetEntPropFloat(client, Prop_Send, "m_flRageMeter"));
						}
					}
				}
				if(ClientHasUseableGrenadeOrDrink(client))
				{
					had_An_ability = true;
					if(GetGameTime() > GrenadeApplyCooldownReturn(client))
					{
						FormatEx(buffer, sizeof(buffer), "%s [◈]", buffer);
					}
					else
					{
						FormatEx(buffer, sizeof(buffer), "%s [◈ %.1fs]", buffer, GrenadeApplyCooldownReturn(client) - GetGameTime());
					}
				}
				if(Purnell_Existant(client))
				{
					had_An_ability = true;
					int Reolver = EntRefToEntIndex(Purnell_ReturnRevolver(client));
					if(IsValidEntity(Reolver))
					{
						int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
						int ammo = GetEntData(Reolver, iAmmoTable, 4);//Get ammo clip
						FormatEx(buffer, sizeof(buffer), "%s [%i/%i]", buffer,ammo,Purnell_RevolverFull(Reolver));
					}
				}
				if(SuperUbersaw_Existant(client))
				{
					had_An_ability = true;
					FormatEx(buffer, sizeof(buffer), "%s [ÜS %0.f％]",buffer, SuperUbersawPercentage(client) * 100.0);
				}
				if(b_Reinforce[client])
				{
					had_An_ability = true;
					if(MaxRevivesReturn() >= MaxRevivesAllowed())
					{
						FormatEx(buffer, sizeof(buffer), "%s [▼ MAX]",buffer);
					}
					else
					{
						FormatEx(buffer, sizeof(buffer), "%s [▼ %0.f％]",buffer, ReinforcePoint(client) * 100.0);
					}
				}
				if(GetAbilitySlotCount(client) == 8)
				{
					had_An_ability = true;
					if(MorphineMaxed(client))
					{
						FormatEx(buffer, sizeof(buffer), "%s [Ḿ MAX]",buffer);
					}
					else
					{
						FormatEx(buffer, sizeof(buffer), "%s [Ḿ %0.f％]",buffer, MorphineChargeFunc(client) * 100.0);
					}
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

				bool InfMana = false;
				if(HasSpecificBuff(client, "Dimensional Turbulence"))
					InfMana = true;

				if(!InfMana)
				{
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
				}
					
				SetGlobalTransTarget(client);
	#if defined ZR
				if(!InfMana)
					Format(buffer, sizeof(buffer), "%t\n%s", "Current Mana", Current_Mana[client], max_mana[client], mana_regen[client], buffer);
				else
					Format(buffer, sizeof(buffer), "%t\n%s", "Current Mana Inf", buffer);
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
				
				static char c_CurrentMana[64];
				IntToString(Current_Mana[client],c_CurrentMana, sizeof(c_CurrentMana));

				int offset = Current_Mana[client] < 0 ? 1 : 0;
				ThousandString(c_CurrentMana[offset], sizeof(c_CurrentMana) - offset);

				if(form.Name[0])
				{
					static char NameOverride[64];
					NameOverride = form.Name;
					if(form.Func_FormNameOverride != INVALID_FUNCTION && form.Func_FormNameOverride) //somehow errors with 0, i dont know, whatever.
					{
						Call_StartFunction(null, form.Func_FormNameOverride);
						Call_PushCell(client);
						Call_PushStringEx(NameOverride, sizeof(NameOverride), SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
						Call_Finish();
					}
					Format(buffer, sizeof(buffer), "%s: %s\n%s", NameOverride, c_CurrentMana, buffer);

				}
				else
					Format(buffer, sizeof(buffer), "%t\n%s", "Capacity", Current_Mana[client], buffer);
	#endif
			}
			//BUFFS!
			static char Debuff_Adder_left[64];
			static char Debuff_Adder_right[64];
			static char Debuff_Adder[64];
			EntityBuffHudShow(client, -1, Debuff_Adder_left, Debuff_Adder_right, sizeof(Debuff_Adder));

			if(Debuff_Adder_left[0])
			{
				strcopy(Debuff_Adder, sizeof(Debuff_Adder), Debuff_Adder_left);

				if(Debuff_Adder_right[0])
				{
					Format(Debuff_Adder, sizeof(Debuff_Adder), "%s|", Debuff_Adder);
				}
				Format(Debuff_Adder, sizeof(Debuff_Adder), "%s%s", Debuff_Adder, Debuff_Adder_right);
			}
			else
			{
				strcopy(Debuff_Adder, sizeof(Debuff_Adder), Debuff_Adder_right);
			}

			if(Debuff_Adder[0])
			{
				Format(buffer, sizeof(buffer), "%s\n%s", Debuff_Adder, buffer);
				HudY += -0.0345; //correct offset
			}
	#if defined ZR
			if(!SkillTree_InMenu(client) && !Rogue_ShowStatus(client) && buffer[0])
	#else
			if(buffer[0])
	#endif
			{
				SetHudTextParams(HudX, HudY, 0.81, red, green, blue, Alpha);
				ShowSyncHudText(client,  SyncHud_WandMana, "%s", buffer);
			}
		}
	}

	if(!OnlyOneAtATime && delay_hud[client] < GameTime)	
	{
		OnlyOneAtATime = true;
		delay_hud[client] = GameTime + 0.4;
		SetGlobalTransTarget(client);

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

		int Armor_Max = 10000;
		int vehicleSlot;
		int vehicle = Vehicle_Driver(client, vehicleSlot);
		int armorEnt = client;
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
				//necrosis
				case Element_Necrosis:
				{
					red = 255;
					green = 50;
					blue = 50;
				}
				//chaos
				case Element_Chaos:
				{
					red = 0;
					green = 255;
					blue = 255;
				}
				//void
				case Element_Void:
				{
					red = 179;
					green = 8;
					blue = 209;
				}
				//matrix
				case Element_Corruption:
				{
					red = 54;
					green = 77;
					blue = 43;
				}
				//plasma
				case Element_Plasma:
				{
					red = 235;
					green = 75;
					blue = 215;
				}
				case Element_Warped:
				{
					red = 55 + abs(200 - (GetTime() % 400));
					green = 55 + abs(200 - (RoundFloat(GetGameTime()) % 400));
					blue = 55 + abs(200 - (RoundFloat(GetEngineTime()) % 400));
				}
				//seaborn
				default:
				{
					red = 150;
					green = 143;
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
		if(client == armorEnt && FullMoonIs(client))
		{
			if(Armor_Charge[armorEnt] > 0)
			{
				Armor_Charge[armorEnt] = 0;
			}
		}

		ArmorDisplayClient(client);

		static char buffer[24]; //armor
		static char buffer2[24];	//perks and stuff
		bool Armor_Regenerating = false;
		static int ArmorRegenCounter[MAXPLAYERS];
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
		if(Armor_Charge[armorEnt] >= 0)
		{	
			if(Attributes_Get(client, Attrib_Armor_AliveMode, 0.0) != 0.0)
			{
				if(armor > 0)
				{
					if(armor > Armor_Max)
						Format(buffer, sizeof(buffer), "⛊ ", buffer);
					else
						Format(buffer, sizeof(buffer), "⛨ ", buffer);
				}
				else
				{
					Format(buffer, sizeof(buffer), "⛨ ", buffer);
				}			
			}
			else
			{
				if(armor > 0)
				{
					if(armor > Armor_Max)
						Format(buffer, sizeof(buffer), "⛊ ", buffer);
					else
						Format(buffer, sizeof(buffer), "⛉ ", buffer);
				}
				else
				{
					Format(buffer, sizeof(buffer), "⛉ ", buffer);
				}
			}

			static char c_ArmorCurrent[64];
			if(vehicle != -1)
			{
				if(Armor_Charge[armorEnt] < 1)
				{
					Format(buffer, sizeof(buffer), "%s------\nREPAIR\n------\n", buffer);
				}
			}
			if(Armor_Charge[armorEnt] >= 0)
			{
				IntToString(armor,c_ArmorCurrent, sizeof(c_ArmorCurrent));
				int offset = armor < 0 ? 1 : 0;
				ThousandString(c_ArmorCurrent[offset], sizeof(c_ArmorCurrent) - offset);
				Format(buffer, sizeof(buffer), "%s%s", buffer, c_ArmorCurrent);
			}
		}
		else
		{
			if(Armor_DebuffType[armorEnt] == Element_Warped)
				armor /= 4;
			
			Format(buffer, sizeof(buffer), "⛛ ", buffer);
			for(int i=1; i<5; i++)
			{
				if(armor >= Armor_Max*(float(i)*0.2))
				{
					Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_FULL);
				}
				else if(armor > Armor_Max*((float(i)*0.2) - (1.0/15.0)) || (Armor_Regenerating && ArmorRegenCounter[client] == i))
				{
					Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_PARTFULL);
				}
				else if(armor > Armor_Max*((float(i)*0.2) - (2.0/15.0)))
				{
					Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_PARTEMPTY);
				}
				else
				{
					Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_EMPTY);
				}
			}
		}
		if(vehicle != -1)
		{
			Format(buffer2, sizeof(buffer2), "%s", vehicleSlot == -1 ? "DRI" : "PAS");
		}
		else if(IsValidEntity(Building_Mounted[client]))
		{
			int converted_ref = EntRefToEntIndex(Building_Mounted[client]);
			float Cooldowntocheck =	Building_Collect_Cooldown[converted_ref][client];
			Cooldowntocheck -= GetGameTime();
			//add 1 second so it doesnt just show 0

			if(Cooldowntocheck < 0.0)
			{
				Cooldowntocheck = 0.0;
			}
			else
			{
				Cooldowntocheck += 0.999;
			}

			char npc_classname[7];
			NPC_GetPluginById(i_NpcInternalId[converted_ref], npc_classname, sizeof(npc_classname));
			npc_classname[4] = CharToUpper(npc_classname[4]);
			npc_classname[5] = CharToUpper(npc_classname[5]);
			if(Cooldowntocheck > 99.9)
				Cooldowntocheck = 99.9;
			if(Cooldowntocheck > 0.0)
			{
				//add one second so it itll never show 0 in there, thats stupid.
				Format(buffer2, sizeof(buffer2), "%s:%1.f",npc_classname[4], Cooldowntocheck);
			}
			else
			{
				Format(buffer2, sizeof(buffer2), "%s",npc_classname[4]);
			}
		}
		else
		{
			//no mount or anything
			Format(buffer2, sizeof(buffer2), "---");
		}
		if(i_CurrentEquippedPerk[client] != PERK_NONE)
		{
			Format(buffer2, sizeof(buffer2), "%s|", buffer2);
			if(i_CurrentEquippedPerk[client] & PERK_TESLAR_MULE)
			{
				float slowdown_amount = f_WidowsWineDebuffPlayerCooldown[client] - GameTime;
				
				if(slowdown_amount < 0.0)
				{
					Format(buffer2, sizeof(buffer2), "%s%s", buffer2,MaxAsignPerkNames[client]);
				}
				else
				{
					Format(buffer2, sizeof(buffer2), "%s%.1f", buffer2, slowdown_amount);
				}
			}
			else
			{
				Format(buffer2, sizeof(buffer2), "%s%s", buffer2,MaxAsignPerkNames[client]);
			}
		}
		else
		{
			Format(buffer2, sizeof(buffer2), "%s|---",buffer2);
		}
		
		if(!SkillTree_InMenu(client) && !BetWar_Mode() && GetTeam(client) == TFTeam_Red && TeutonType[client] == TEUTON_NONE)
		{
			SetHudTextParams(0.175 + f_ArmorHudOffsetY[client], 0.9 + f_ArmorHudOffsetX[client], 0.81, red, green, blue, 255);
			ShowSyncHudText(client, SyncHud_ArmorCounter, "%s\n%s", buffer, buffer2);
		}
			
		//only for red.
		if(GetTeam(client) == 2)
		{
			char HudBuffer[256];
			if(!TeutonType[client])
			{
				int downsleft;
				downsleft = 2;
				if(ZR_Get_Modifier() == PREFIX_ONESTAND)
					downsleft = 3;

				downsleft -= i_AmountDowned[client];
				SDKHooks_UpdateMarkForDeath(client);
				
				if(!HudBuffer[0] && CashSpent[client] < 1)
				{
					Format(HudBuffer, sizeof(HudBuffer), "%t", "Press To Open Store");
				}
				if(b_EnableCountedDowns[client])
				{
					Format(HudBuffer, sizeof(HudBuffer), "%s\n%t", HudBuffer,
					"Downs left", downsleft
					);
				}
				if(b_EnableRightSideAmmoboxCount[client])
				{
					Format(HudBuffer, sizeof(HudBuffer), "%s\n%t", HudBuffer,
					"Ammo Crate Supplies", Ammo_Count_Ready - Ammo_Count_Used[client]
					);
				}
			}
			else if (TeutonType[client] == TEUTON_DEAD)
			{
				if(WasHereSinceStartOfWave(client))
				{
					Format(HudBuffer, sizeof(HudBuffer), "%s %t",HudBuffer, "You Died Teuton"
					);
				}

			}
			else
			{
				Format(HudBuffer, sizeof(HudBuffer), "%s %t",HudBuffer, "You Wait Teuton"
				);
			}
			SetEntProp(client, Prop_Send, "m_nCurrency", CurrentCash-CashSpent[client]);
			
			if(HudBuffer[0])
				PrintKeyHintText(client,"%s", HudBuffer);
		}
#endif	// ZR
	}
#if defined ZR
	if(!OnlyOneAtATime && f_DelayLookingAtHud[client] < GameTime)
	{
		//Reuse uhh
		//Doesnt reset often enough, fuck clientside.
		if (IsPlayerAlive(client))
		{
			int entity = GetClientPointVisible(client,70.0,_,_,_,1); //allow them to get info if they stare at something for abit long
			Building_ShowInteractionHud(client, entity);	
			f_DelayLookingAtHud[client] = GameTime + 0.5;	
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
	
//	delete profiler;
#endif	// ZR
}

public void OnPostThinkPost(int client)
{
	if(b_NetworkedCrouch[client])
	{
		SetEntProp(client, Prop_Send, "m_bAllowAutoMovement", 0);
	}
	if(f_UpdateModelIssues[client] && f_UpdateModelIssues[client] < GetGameTime())
	{
#if defined ZR
		SDKHooks_UpdateMarkForDeath(client, true);
		SDKHooks_UpdateMarkForDeath(client);
#endif	// ZR & RPG
		f_UpdateModelIssues[client] = 0.0;
	}
	//HARDCODED GRAVITY VALUE.
	sv_gravity.IntValue = 800;
}
#endif	// ZR & RPG

public void Player_OnTakeDamageAlivePost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
#if defined ZR
	TakeDamage_EnableMVM();
	//PrintToConsole(victim, "[ZR] THIS IS DEBUG! IGNORE! Player_OnTakeDamageAlivePost");
	if(!(damagetype & (DMG_OUTOFBOUNDS|DMG_FALL)))
	{
		int i_damage = RoundToCeil(damage / f_LatestDamageRes[victim]);
		//dont credit for more then 4k damage at once.
		if(i_damage >= 4000)
			i_damage = 4000;

		if(IsValidEnemy(attacker, victim, true, true))
		{
			i_PlayerDamaged[victim] += i_damage;
		}
	}
	
	if((damagetype & DMG_OUTOFBOUNDS))
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
	StatusEffect_OnTakeDamagePostVictim(victim, attacker, damage, damagetype);
	StatusEffect_OnTakeDamagePostAttacker(victim, attacker, damage, damagetype);
	
#endif
#if defined RPG
	f_FlatDamagePiercing[attacker] = 1.0;
#endif
	i_HexCustomDamageTypes[victim] = 0;
}

#if defined ZR
void RegainTf2Buffs(int victim)
{
//	if(i_WasInUber[victim])
//	{
//		TF2_AddCondition(victim, TFCond_Ubercharged, i_WasInUber[victim]);
//	}
	if(i_WasInMarkedForDeath[victim])
	{
		TF2_AddCondition(victim, TFCond_MarkedForDeath, i_WasInMarkedForDeath[victim]);
	}
	if(i_WasInMarkedForDeathSilent[victim])
	{
		TF2_AddCondition(victim, TFCond_MarkedForDeathSilent, i_WasInMarkedForDeathSilent[victim]);
	}
	if(i_WasInJarate[victim])
	{
		TF2_AddCondition(victim, TFCond_Jarated, i_WasInJarate[victim]);
	}
	if(i_WasInDefenseBuff[victim])
	{
		TF2_AddCondition(victim, TFCond_DefenseBuffed, i_WasInDefenseBuff[victim]);
	}
	if(i_WasInResPowerup[victim])
	{
		TF2_AddCondition(victim, TFCond_RuneResist, i_WasInResPowerup[victim]);
	}
//	i_WasInUber[victim] = 0.0;
	i_WasInMarkedForDeathSilent[victim] = 0.0;
	i_WasInDefenseBuff[victim] = 0.0;
	i_WasInJarate[victim] = 0.0;
	i_WasInResPowerup[victim] = 0.0;
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
				WeaponRedBlade_OnTakeDamage_Post(victim);
			}
		}
	}
#endif
}

//This is so it doesnt set anything or so
int CheckInHudTest;
void CheckInHudEnable(int ModeSet)
{
	CheckInHudTest = ModeSet;
}
int CheckInHud()
{
	return CheckInHudTest;
}

public Action Player_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(!CheckInHud())
	{
		TakeDamage_DisableMVM();
		ClientPassAliveCheck[victim] = false;
#if defined ZR
	//	i_WasInUber[victim] = 0.0;
		i_WasInMarkedForDeathSilent[victim] = 0.0;
		i_WasInMarkedForDeath[victim] = 0.0;
		i_WasInDefenseBuff[victim] = 0.0;
#endif
	}
	//dmg bonus before everything!
	//This is for players in specific, both handle it here!
	if(attacker > 0 && attacker <= MAXENTITIES)
		damage *= fl_Extra_Damage[attacker];
#if defined RPG
	if(!CheckInHud() && attacker <= MaxClients)
	{
		//in pvp, we half the damage. this is also BEFORE flat resistance.
		damage *= 0.5;
	}
	//needs to be above everything aside extra damage
	if(!CheckInHud())
	{
		if(!(damagetype & (DMG_FALL|DMG_OUTOFBOUNDS|DMG_TRUEDAMAGE)))
		{
			RPG_FlatRes(victim, attacker, weapon, damage);
		}
	}
	float value;
	if(!CheckInHud())
	{
		value = Attributes_GetOnPlayer(victim, Attrib_FormRes, true, true, 0.0);
		if(value)
		{
			damage *= value;
		}
	}
#endif
	
#if defined ZR
	if(TeutonType[victim])
	{
		//do not protect them.
		//i.e. something crushes them, die.
		if(!(damagetype & DMG_CRUSH))
		{
			damage = 0.0;
			TakeDamage_EnableMVM();
			return Plugin_Handled;
		}
		else
		{
			if(!CheckInHud())
			{
				ClientPassAliveCheck[victim] = true;
			}
			return Plugin_Continue;
		}
	}
#endif

	float GameTime = GetGameTime();
	if(f_ClientInvul[victim] > GameTime) //Treat this as if they were a teuton, complete and utter immunity to everything in existance.
	{
		damage = 0.0;
		TakeDamage_EnableMVM();
		return Plugin_Handled;
	}
	if(IsInvuln(victim, true))
	{
		if(!(damagetype & DMG_OUTOFBOUNDS))
		{
			if(!CheckInHud())
			{
				f_TimeUntillNormalHeal[victim] = GameTime + 4.0;
				ClientPassAliveCheck[victim] = true;
			}
			damage = 0.0;
			TakeDamage_EnableMVM();
			return Plugin_Handled;	
		}
	}
	
	if(!CheckInHud() && HasSpecificBuff(victim, "Archo's Posion"))
	{
		if(!(damagetype & (DMG_FALL|DMG_OUTOFBOUNDS|DMG_TRUEDAMAGE)))
		{
			damagetype = DMG_TRUEDAMAGE;
		}
	}
	if(damagetype & DMG_CRIT)
	{
		damagetype &= ~DMG_CRIT; //Remove Crit Damage at all times, it breaks calculations for no good reason.
	}

	if(!CheckInHud())
	{
#if defined ZR
		if(dieingstate[victim] > 0)
		{
			if(GetEntProp(victim, Prop_Send, "m_iHealth") < 1)
			{
				//This kills the target.
				MakePlayerGiveResponseVoice(victim, 2); //dead!
				//PrintToConsole(victim, "[ZR] THIS IS DEBUG! IGNORE! Player_OnTakeDamage 1");
				damage = 2.0;
				ClientPassAliveCheck[victim] = true;
				TakeDamage_EnableMVM();
				return Plugin_Changed;	
			}
			TakeDamage_EnableMVM();
			return Plugin_Handled;
		}
		else
#endif
		{
			if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_ALLOW_SELFHURT) && victim == attacker)
			{
				TakeDamage_EnableMVM();
				return Plugin_Handled;
			}
		}
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
			TakeDamage_EnableMVM();
			return Plugin_Handled;	
		}
	}
	//Damage was done by a player
	else if(attacker <= MaxClients && attacker > 0 && attacker != 0)
	{
#if defined RPG
		if(!(RPGCore_PlayerCanPVP(attacker,victim)))
		{
			TakeDamage_EnableMVM();
			return Plugin_Handled;	
		}
		else
		{
			if(attacker == victim)
			{
				TakeDamage_EnableMVM();
				return Plugin_Handled;	
			}
		}
#else
		if((i_HexCustomDamageTypes[victim] & ZR_DAMAGE_ALLOW_SELFHURT) && victim == attacker)
		{

		}
		else
		{
			if(attacker == victim)
			{
				TakeDamage_EnableMVM();
				return Plugin_Handled;	
			}
		}
#endif


#if defined RPG		
		if(!CheckInHud())
			LastHitRef[victim] = EntIndexToEntRef(attacker);
#endif
	}
	else if (attacker != 0)
	{
		if(!CheckInHud())
			LastHitRef[victim] = EntIndexToEntRef(attacker);
	}
	
#if defined ZR
	if((damagetype & DMG_OUTOFBOUNDS) && (!(i_HexCustomDamageTypes[victim] & ZR_STAIR_ANTI_ABUSE_DAMAGE)))
	{
		if(damage < 10000.0)
		{
			if(!CheckInHud())
				NpcStuckZoneWarning(victim, damage);
		}
	}
#endif
#if defined RPG
	if((damagetype & DMG_OUTOFBOUNDS) && (!(i_HexCustomDamageTypes[victim] & ZR_STAIR_ANTI_ABUSE_DAMAGE)))
	{
		if(damage < 1000.0)
		{
			damage = 1000.0;
		}
	}
#endif
	if(!CheckInHud())
		f_TimeUntillNormalHeal[victim] = GameTime + 4.0;

#if defined ZR
	if((damagetype & DMG_OUTOFBOUNDS))
	{
		//NOTHING blocks it.
		return Plugin_Changed;
	}
#endif

#if defined RPG
	if(!CheckInHud() && Ability_TrueStrength_Shield_OnTakeDamage(victim))
	{
		damage = 0.0;
		TakeDamage_EnableMVM();
		return Plugin_Handled;	
	}
	if(!CheckInHud())
		f_InBattleDelay[victim] = GetGameTime() + 3.0;
#endif
	float GetCurrentDamage = damage;
	f_LatestDamageRes[victim] = 1.0;
#if defined ZR || defined RPG
	Replicate_Damage_Medications(victim, damage, damagetype);
#endif
	
	if(Damage_Modifiy(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom))
	{
		TakeDamage_EnableMVM();
		return Plugin_Handled;
	}
	
	if(damagetype & DMG_TRUEDAMAGE)
	{
		if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
		{
			if(f_ReceivedTruedamageHit[victim] < GetGameTime())
			{
				f_ReceivedTruedamageHit[victim] = GetGameTime() + 0.5;
				ClientCommand(victim, "playgamesound player/crit_received%d.wav", (GetURandomInt() % 3) + 1);
			}
		}
	}
	f_LatestDamageRes[victim] = damage / GetCurrentDamage;

#if !defined RTS
	int ClientAttacker;
	if(IsValidClient(inflictor))
		ClientAttacker = inflictor;
	else if(IsValidClient(attacker))
		ClientAttacker = attacker;

	if(!CheckInHud())
	{
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
#if defined RPG
		if(i_TransformationLevel[victim] > 0)
		{
			Race race;
			if(Races_GetRaceByIndex(RaceIndex[victim], race) && race.Forms)
			{
				Form form;
				race.Forms.GetArray(i_TransformationLevel[victim] - 1, form);
				
				if(form.Func_FormTakeDamage != INVALID_FUNCTION)
				{
					Call_StartFunction(null, form.Func_FormTakeDamage);
					Call_PushCell(victim);
					Call_PushCellRef(attacker);
					Call_PushCellRef(inflictor);
					Call_PushFloatRef(damage);
					Call_PushCellRef(damagetype);
					Call_PushCellRef(weapon);
					Call_PushArrayEx(damageForce, sizeof(damageForce), SM_PARAM_COPYBACK);
					Call_PushArrayEx(damagePosition, sizeof(damagePosition), SM_PARAM_COPYBACK);
					Call_PushCell(damagecustom);
					Call_Finish();

					if(damage <= 0.0)
					{
						return Plugin_Handled;
					}
				}
			}
		}
#endif	
	}
	return Plugin_Changed;
}

	
public Action Player_OnTakeDamageAlive_DeathCheck(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//PrintToConsole(victim, "[ZR] THIS IS DEBUG! IGNORE! Player_OnTakeDamageAlive_DeathCheck 1");
	//in on take damage, the client shouldnt be reciving this down phase, kill em.
	TakeDamage_EnableMVM();
	if(ClientPassAliveCheck[victim])
	{	
		ClientPassAliveCheck[victim] = false;
		return Plugin_Continue;
	}
#if defined ZR
	float GameTime = GetGameTime();
	int flHealth = GetEntProp(victim, Prop_Send, "m_iHealth");
	//damage is more then their health, they will die.
	//PrintToConsole(victim, "[ZR] THIS IS DEBUG! IGNORE! Player_OnTakeDamageAlive_DeathCheck 2, Health: %i, damage float %f damage int:%i ",flHealth, damage,RoundToCeil(damage));
	if(RoundToCeil(damage) >= flHealth)
	{
		//PrintToConsole(victim, "[ZR] THIS IS DEBUG! IGNORE! Player_OnTakeDamageAlive_DeathCheck 3");
		//the client has a suit, save them !!
		if(HasSpecificBuff(victim, "Infinite Will"))
		{
			//I AM IMMORTAL!!!!!!!!!!!!!!!!!!
			SetEntProp(victim, Prop_Data, "m_iHealth", 1);
			damage = 0.0;
			return Plugin_Handled;
		}
		if(HasSpecificBuff(victim, "Blessing of Stars"))
		{
			HealEntityGlobal(victim, victim, float(ReturnEntityMaxHealth(victim) / 4), 1.0, 1.0, HEAL_ABSOLUTE);
			TF2_AddCondition(victim, TFCond_UberchargedCanteen, 1.0);
			TF2_AddCondition(victim, TFCond_MegaHeal, 1.0);
			SetEntProp(victim, Prop_Data, "m_iHealth", 1);
			RemoveSpecificBuff(victim, "Blessing of Stars");
			EmitSoundToAll("misc/halloween/spell_overheal.wav", victim, SNDCHAN_STATIC, 80, _, 0.8);
			damage = 0.0;
			return Plugin_Handled;
		}
		if(i_HealthBeforeSuit[victim] > 0)
		{
			//PrintToConsole(victim, "[ZR] THIS IS DEBUG! IGNORE! Player_OnTakeDamageAlive_DeathCheck 4");
			damage = 0.0;
			TF2_AddCondition(victim, TFCond_UberchargedCanteen, 1.0);
			TF2_AddCondition(victim, TFCond_MegaHeal, 1.0);
			float startPosition[3];
			GetClientAbsOrigin(victim, startPosition);
			startPosition[2] += 25.0;
			makeexplosion(victim, startPosition, 0, 0);
			GiveCompleteInvul(victim, 0.5);
			CreateTimer(0.0, QuantumDeactivate, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE); //early cancel out!, save the wearer!

			KillFeed_Show(victim, inflictor, attacker, 0, weapon, damagetype, true);
			return Plugin_Handled;
		}
		else if(TF2_IsPlayerInCondition(victim, TFCond_PreventDeath))
		{
			TF2_RemoveCondition(victim, TFCond_PreventDeath);

			damage = 0.0;
			SetEntityHealth(victim, 1);
			GiveCompleteInvul(victim, 0.1);
			return Plugin_Handled;
		}
		//if they were supposed to die, but had protection from the marchant kit, do this instead.
		else if(Merchant_OnLethalDamage(attacker, victim))
		{
			//PrintToConsole(victim, "[ZR] THIS IS DEBUG! IGNORE! Player_OnTakeDamageAlive_DeathCheck 6");
			//PrintToConsole(victim, "[ZR] THIS IS DEBUG! IGNORE! Player_OnTakeDamageAlive_DeathCheck 7");
			damage = 0.0;
			GiveCompleteInvul(victim, 0.1);
			KillFeed_Show(victim, inflictor, attacker, 0, weapon, damagetype, true);
			return Plugin_Handled;
		}
		//the client was the last man on the server, or alone, give them spawn protection
		//dont do this if they are under specter saw revival
		else if(!Rogue_NoLastman() && b_IsAloneOnServer && !applied_lastmann_buffs_once && i_AmountDowned[victim] != 999)
		{
			//lastman for being alone!
			//force lastman if alone, give inf downs to indicate DEATH.
			i_AmountDowned[victim] = 999;
			//magic number 999 is used to detect if lastman happend
			CheckAlivePlayers(0,_,_,victim);
			damage = 0.0;
			return Plugin_Handled;
		}
		else if((LastMann || b_IsAloneOnServer) && f_OneShotProtectionTimer[victim] < GameTime && !SpecterCheckIfAutoRevive(victim))
		{
			damage = 0.0;
			GiveCompleteInvul(victim, 2.0);
			EmitSoundToAll("misc/halloween/spell_overheal.wav", victim, SNDCHAN_STATIC, 80, _, 0.8);
			f_OneShotProtectionTimer[victim] = GameTime + 60.0; // 60 second cooldown
			//PrintToConsole(victim, "[ZR] THIS IS DEBUG! IGNORE! Player_OnTakeDamageAlive_DeathCheck 5");
			return Plugin_Handled;
		}
		//all checks passed, now go into here
		else if((!LastMann && !b_IsAloneOnServer) || SpecterCheckIfAutoRevive(victim))
		{
			//PrintToConsole(victim, "[ZR] THIS IS DEBUG! IGNORE! Player_OnTakeDamageAlive_DeathCheck 9");
			//are they alone? is any player alive that isnt downed left?
			bool Any_Left = false;
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client) && GetTeam(client)==2 && !IsFakeClient(client) && TeutonType[client] != TEUTON_WAITING)
				{
					if(victim != client && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE && dieingstate[client] == 0)
					{
						Any_Left = true;
					}
				}
			}
			//PrintToConsole(victim, "[ZR] THIS IS DEBUG! IGNORE! Player_OnTakeDamageAlive_DeathCheck 10");
			//there was no one left, they are the only one left, trigger last man.
			//make sure they are in a wave.
			if(!Any_Left && !SpecterCheckIfAutoRevive(victim) && GameRules_GetRoundState() == RoundState_ZombieRiot)
			{
				// Trigger lastman
				CheckAlivePlayers(_, victim);

				if(Construction_Mode())
					return Plugin_Changed;

				// Die in Rogue, there's no lastman
				return Rogue_NoLastman() ? Plugin_Changed : Plugin_Handled;
			}
			//this updates it .
			//PrintToConsole(victim, "[ZR] THIS IS DEBUG! IGNORE! Player_OnTakeDamageAlive_DeathCheck 11");
			
			Rogue_PlayerDowned(victim);	
			
			//there are players still left, down them.
			if((SpecterCheckIfAutoRevive(victim) || i_AmountDowned[victim] < (2 + Dungeon_DownedBonus())) && !HasSpecificBuff(victim, "Nightmare Terror"))
			{
				//PrintToConsole(victim, "[ZR] THIS IS DEBUG! IGNORE! Player_OnTakeDamageAlive_DeathCheck 12");
				//https://github.com/lua9520/source-engine-2018-hl2_src/blob/3bf9df6b2785fa6d951086978a3e66f49427166a/game/shared/mp_shareddefs.cpp
				MakePlayerGiveResponseVoice(victim, 2); //dead!
				i_CurrentEquippedPerkPreviously[victim] = i_CurrentEquippedPerk[victim];
				if(!Rogue_Mode() && !SpecterCheckIfAutoRevive(victim))
				{
					i_CurrentEquippedPerk[victim] = 0;
				}

				/*
				if(!SpecterCheckIfAutoRevive(victim) && b_LeftForDead[victim])
				{
					//left for dead actives, no more revives.
					i_AmountDowned[victim] = 99;
				}
				*/

				Dungeon_PlayerDowned(victim);
				
				ApplyRapidSuturing(victim);
				ExtinguishTargetDebuff(victim);
				if(!Waves_InSetup() || Dungeon_Started())
					i_AmountDowned[victim]++;
				
				if(Rogue_Rift_VialityThing())
					SetEntityHealth(victim, 300);
				else
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
			
				f_DisableDyingTimer[victim] = 0.0;
				dieingstate[victim] -= RoundToNearest(Attributes_GetOnPlayer(victim, Attrib_ReviveTimeCut, false,_, 0.0));
				Vehicle_Exit(victim);
				ForcePlayerCrouch(victim, true);
				SDKHooks_UpdateMarkForDeath(victim, true);
				//cooldown for left for dead.
				SpecterResetHudTime(victim);
				ApplyLastmanOrDyingOverlay(victim);
				SetEntityCollisionGroup(victim, 1);
				CClotBody player = view_as<CClotBody>(victim);
				player.m_bThisEntityIgnored = true;
				if(Rogue_Rift_VialityThing())
					Attributes_SetMulti(victim, 442, 0.85);
				else
					Attributes_SetMulti(victim, 442, 0.65);

				Rogue_Rift_FlashVest_StunEnemies(victim);

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

					entity = SpawnFormattedWorldText("DOWNED", {0.0,0.0,70.0}, 10, {0, 255, 0, 255}, victim);
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
						SetEntityRenderMode(entity, RENDER_NORMAL);
						SetEntityRenderColor(entity, 255, 125, 125, 255);
					}
					else
					{
						SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
						SetEntityRenderColor(entity, 255, 255, 255, 10);
					}
				}
				if(!autoRevive)
				{
					SetEntityRenderMode(victim, RENDER_NORMAL);
					SetEntityRenderColor(victim, 255, 125, 125, 255);
				}
				else
				{
					SetEntityRenderMode(victim, RENDER_TRANSCOLOR);
					SetEntityRenderColor(victim, 255, 255, 255, 10);
				}

				KillFeed_Show(victim, inflictor, attacker, 0, weapon, damagetype, autoRevive);
				CheckLastMannStanding(victim);
				return Plugin_Handled;
			}
			else
			{
				//PrintToConsole(victim, "[ZR] THIS IS DEBUG! IGNORE! Player_OnTakeDamageAlive_DeathCheck 13");
				damage = 99999.9;
				CheckLastMannStanding(victim);
				return Plugin_Changed;
			}
		}
	}
	//PrintToConsole(victim, "[ZR] THIS IS DEBUG! IGNORE! Player_OnTakeDamageAlive_DeathCheck 14");
#endif	// ZR
	return Plugin_Changed;
}

#if defined ZR || defined RPG
void Replicate_Damage_Medications(int victim, float &damage, int damagetype)
{
	if(!CheckInHud() && TF2_IsPlayerInCondition(victim, TFCond_MarkedForDeath))
	{
		i_WasInMarkedForDeath[victim] = TF2Util_GetPlayerConditionDuration(victim, TFCond_MarkedForDeath);
		TF2_RemoveCondition(victim, TFCond_MarkedForDeath);
	}
	if(!CheckInHud() && TF2_IsPlayerInCondition(victim, TFCond_MarkedForDeathSilent))
	{
		i_WasInMarkedForDeathSilent[victim] = TF2Util_GetPlayerConditionDuration(victim, TFCond_MarkedForDeathSilent);
		TF2_RemoveCondition(victim, TFCond_MarkedForDeathSilent);
	}
	if(TF2_IsPlayerInCondition(victim, TFCond_Jarated))
	{
		if(!CheckInHud())
		{
			i_WasInJarate[victim] = TF2Util_GetPlayerConditionDuration(victim, TFCond_Jarated);
			TF2_RemoveCondition(victim, TFCond_Jarated);
		}
		damage *= 1.35;
	}
	if(TF2_IsPlayerInCondition(victim, TFCond_DefenseBuffed))
	{
		if(!CheckInHud())
		{
			i_WasInDefenseBuff[victim] = TF2Util_GetPlayerConditionDuration(victim, TFCond_DefenseBuffed);
			TF2_RemoveCondition(victim, TFCond_DefenseBuffed);
		}
		if(!(damagetype & DMG_TRUEDAMAGE))
			damage *= 0.65;
	}
	if(!CheckInHud() && TF2_IsPlayerInCondition(victim, TFCond_RuneResist))
	{
		i_WasInResPowerup[victim] = TF2Util_GetPlayerConditionDuration(victim, TFCond_RuneResist);
		TF2_RemoveCondition(victim, TFCond_RuneResist);
		//This is purely visual, it doesnt grant anything by itself.
	}
	if(damagetype & DMG_TRUEDAMAGE)
		return;
		
	int weapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
	float value;
	if(damagetype & (DMG_CLUB))
	{
		value = Attributes_GetOnPlayer(victim, 206, true, true, 1.0); //Melee dmg res
		if(weapon != -1)
			value *= Attributes_Get(weapon, 206, 1.0);
		damage *= value;
	}
	else if(!(damagetype & DMG_FALL))
	{
		value = Attributes_GetOnPlayer(victim, 205, true, true, 1.0);	// RANGED damage resistance
		if(weapon != -1)
			value *= Attributes_Get(weapon, 205, 1.0);

		damage *= value;
		//Everything else should be counted as ranged reistance probably.
	}
			
	value = Attributes_GetOnPlayer(victim, 412, true, false, 1.0);	// Overall damage resistance

	damage *= value;

	if(weapon != -1)
	{
		//This is mostly used for RPG.
		//unsure why i made them seperate, though.
		//only while active!
		damage *= Attributes_Get(weapon, 4009, 1.0);
		if(damagetype & (DMG_CLUB))
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

#if defined ZR
Action Timer_RecentSoundRemove(Handle timer, int client)
{
	RecentSoundList[client].Erase(0);
	return Plugin_Continue;
}
#endif
public Action SDKHook_AmbientSoundHook(char sample[PLATFORM_MAX_PATH], int &entity,float &volume, int &level, int &pitch, float pos[3], int &flags, float &delay)
{
	if(StrContains(sample, "pipe_bomb", true) != -1)
	{
		if(EnableSilentMode)
		{
			volume *= 0.8;
			level = level - 5;
			//Explosions are too loud, silence them.
		}
		return Plugin_Changed;
	}
	if(StrContains(sample, "explode", true) != -1)
	{
		if(EnableSilentMode)
		{
			volume *= 0.8;
			level = level - 5;
			//Explosions are too loud, silence them.
		}
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

bool LouderSoundStop = false;
public Action SDKHook_NormalSHook(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH],
	  int &entity, int &channel, float &volume, int &level, int &pitch, int &flags,
	  char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	/*
	if(b_IsAmbientGeneric[entity])
	{
		if(StrContains(sample, "#", true) != -1)
		{
			//loop through all clients it tries to play to
			//but also make sure it doesnt play to clients who didnt get info from the database.
			for(int loop1=0; loop1<numClients; loop1++)
			{
				int listener = clients[loop1];
				if(b_IgnoreMapMusic[listener] || !Database_IsCached(listener))
				{
					//replace client with client one up so the array doesnt mess up!
					for(int loop2 = loop1; loop2 < numClients-1; loop2++)
					{
						clients[loop2] = clients[loop2+1];
					}
					//we move the array one down!
					loop1--;
					numClients--;
				}
			}
			return Plugin_Changed;
		}
	}
	*/

#if defined ZR

	if(StrContains(sample, "#", true) != -1)
	{
		
	}
	else
	{
		if(!LouderSoundStop && entity != -1 && HasSpecificBuff(entity, "Loud Prefix"))
		{
			level += 50;
			LouderSoundStop = true;
			for(int loop1=0; loop1<numClients; loop1++)
			{
				int listener = clients[loop1];
				EmitSoundToClient(listener,sample,entity,SNDCHAN_STATIC,level,flags,volume,pitch,_,_,_,_,_);
				EmitSoundToClient(listener,sample,entity,SNDCHAN_STATIC,level,flags,volume,pitch,_,_,_,_,_);
				EmitSoundToClient(listener,sample,entity,SNDCHAN_STATIC,level,flags,volume,pitch,_,_,_,_,_);
				EmitSoundToClient(listener,sample,entity,SNDCHAN_STATIC,level,flags,volume,pitch,_,_,_,_,_);
				EmitSoundToClient(listener,sample,entity,SNDCHAN_STATIC,level,flags,volume,pitch,_,_,_,_,_);
				EmitSoundToClient(listener,sample,entity,SNDCHAN_STATIC,level,flags,volume,pitch,_,_,_,_,_);
				EmitSoundToClient(listener,sample,entity,SNDCHAN_STATIC,level,flags,volume,pitch,_,_,_,_,_);
				EmitSoundToClient(listener,sample,entity,SNDCHAN_STATIC,level,flags,volume,pitch,_,_,_,_,_);
				EmitSoundToClient(listener,sample,entity,SNDCHAN_STATIC,level,flags,volume,pitch,_,_,_,_,_);
				EmitSoundToClient(listener,sample,entity,SNDCHAN_STATIC,level,flags,volume,pitch,_,_,_,_,_);
				EmitSoundToClient(listener,sample,entity,SNDCHAN_STATIC,level,flags,volume,pitch,_,_,_,_,_);
				EmitSoundToClient(listener,sample,entity,SNDCHAN_STATIC,level,flags,volume,pitch,_,_,_,_,_);
			}
			LouderSoundStop = false;
		}
	}
/*
	if(EnableSilentMode && entity > MaxClients && entity < MAXENTITIES && !b_NpcHasDied[entity] && !(flags & SND_STOP))
	{
		if(!b_thisNpcIsARaid[entity])
		{
			if(RecentSoundList[0].FindString(sample) != -1)
				return Plugin_Handled;
			
			RecentSoundList[0].PushString(sample);
			CreateTimer(0.1, Timer_RecentSoundRemove, 0);
		}
	}
*/
	
	if(BetWar_Mode())
	{
		if(entity <= MaxClients && entity > 0)
		{
			if(StrContains(sample, "#", true) != -1)
			{
				//if its music, dont do anything.
			}
			else
				return Plugin_Handled;
		}
	}
#endif

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
	if(StrContains(sample, "misc/halloween/spell_stealth.wav", true) != -1)
	{
		return Plugin_Handled;
	}
	if(StrContains(sample, "weapons/quake_explosion_remastered.wav", true) != -1)
	{
		volume *= 0.8;
		level = 80;
		if(EnableSilentMode)
		{
			volume *= 0.6;
			level = 70;
		}

		//Very loud. 
		//need to reduce.
		return Plugin_Changed;
	}
	else if(EnableSilentMode && StrContains(sample, "explode", true) != -1)
	{
		volume *= 0.6;
		level = level - 5;
		//Explosions are too loud, silence them.
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
			else if(i_CustomModelOverrideIndex[entity] >= 0)
			{
				bool Changed;
				switch(i_CustomModelOverrideIndex[entity])
				{
					case BARNEY:
					{
						Changed = BarneySoundOverride(numClients, sample, 
						entity, channel, volume, level, pitch, flags,seed);
					}
					//nothing for niko. silent!
					case NIKO_2:
					{

					}
					//todo: add stuff!
					case SKELEBOY:
					{
						pitch -= 20;
						return Plugin_Changed;
					}
					case KLEINER:
					{
						Changed = KleinerSoundOverride(numClients, sample, 
						entity, channel, volume, level, pitch, flags,seed);
					}
				}
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
			if(EnableSilentMode)
			{
				ChangedSound = true;
				volume *= 0.4;
				level = RoundToNearest(float(level) * 0.85);	
			}
			if(ChangedSound)
				return Plugin_Changed;
		}
	}
	if(StrContains(sample, "misc/halloween/spell_") != -1)
	{
		volume *= 0.75;
		level = 85;
		return Plugin_Changed;
	}
	if(StrContains(sample, ")weapons/capper_shoot.wav", true) != -1)
	{
		volume *= 0.45;
		level = 65;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

static int i_PreviousWeapon[MAXPLAYERS];

public void OnWeaponSwitchPost(int client, int weapon)
{
	if(weapon != -1)
	{
		int PreviousWeapon = EntRefToEntIndex(i_PreviousWeapon[client]);
#if defined ZR
		if(PreviousWeapon != weapon)
			OnWeaponSwitchPre(client, EntRefToEntIndex(i_PreviousWeapon[client]));

		if(IsValidEntity(PreviousWeapon))
		{
			char buffer[36];
			GetEntityClassname(PreviousWeapon, buffer, sizeof(buffer));
			int PreviousSlot = TF2_GetClassnameSlot(buffer, PreviousWeapon);
			GetEntityClassname(weapon, buffer, sizeof(buffer));
			int CurrentSlot = TF2_GetClassnameSlot(buffer, weapon);

			if(PreviousSlot != CurrentSlot) //Set back the previous active slot to what it was before.
			{
				int WeaponValidCheck = -1;

				while(WeaponValidCheck != PreviousWeapon)
				{
					WeaponValidCheck = Store_CycleItems(client, PreviousSlot);
					if(WeaponValidCheck == -1)
						break;
				}
				//only if switching to different slot.
				CorrectClientsideMultiweapon(client, 1);
			}
			Store_CycleItems(client, CurrentSlot);
		}
#endif
		i_PreviousWeapon[client] = EntIndexToEntRef(weapon);
		
		static char buffer[36];
		GetEntityClassname(weapon, buffer, sizeof(buffer));

#if defined ZR
		if(i_SemiAutoWeapon[weapon])
		{
			if(i_SemiAutoWeapon_AmmoCount[weapon] > 0)
			{
				Attributes_Set(weapon, 821, 0.0);
			}
		}
		
		if(IsValidEntity(Cosmetic_WearableExtra[client]))
		{
			int entity = EntRefToEntIndex(Cosmetic_WearableExtra[client]);
			if(GetEntProp(entity, Prop_Send, "m_nBody") == WINGS_FUSION)
			{
				if(weapon > 0 && i_WeaponVMTExtraSetting[weapon] != -1)
				{
					SetEntityRenderColor(entity, 255, 255, 255, i_WeaponVMTExtraSetting[weapon]);
					i_WeaponVMTExtraSetting[entity] = i_WeaponVMTExtraSetting[weapon]; //This makes sure to not reset the alpha.
				}
			}
		}
		b_CanSeeBuildingValues[client] = b_CanSeeBuildingValues[weapon];
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
		ViewChange_Update(client, false);
		// We delay ViewChange_Switch by a frame so it doesn't mess with the regenerate process
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

void ApplyLastmanOrDyingOverlay(int client)
{
	if(LastMann)
	{
		switch(Yakuza_Lastman())
		{
			case 1,2,3,4,7,9:
			{
				return;
			}
			case 8:
			{
				if(!HasSpecificBuff(client, "Death is comming."))
					return;
			}
		}
	}
	
	DoOverlay(client, "debug/yuv");
	if(LastMann)
	{
		if(LastMannScreenEffect)
			DoOverlay(client, "zombie_riot/filmgrain/filmgrain_4", 1);
	}
}

char SetRenderDo[MAXPLAYERS][8];
void CauseFadeInAndFadeOut(int client = 0, float duration_in, float duration_hold, float duration_out, const char[] RenderAmtDo)
{
	int SpawnFlags = 0;
	if(client != 0)
	{
		SpawnFlags = 4;
	}
	static char Buffer[32];
	IntToString(SpawnFlags, Buffer, sizeof(Buffer));
	int FadeEntity = CreateEntityByName("env_fade");
	DispatchKeyValue(FadeEntity, "spawnflags", Buffer);
	DispatchKeyValue(FadeEntity, "rendercolor", "0 0 0");
	DispatchKeyValue(FadeEntity, "renderamt", RenderAmtDo);
	Format(SetRenderDo[client], sizeof(SetRenderDo[]),RenderAmtDo);
	FloatToString(duration_hold * 3.0, Buffer, sizeof(Buffer));
	DispatchKeyValue(FadeEntity, "holdtime", Buffer);
	FloatToString(duration_in, Buffer, sizeof(Buffer));
	DispatchKeyValue(FadeEntity, "duration", Buffer);
	DispatchSpawn(FadeEntity);
	AcceptEntityInput(FadeEntity, "Fade");
	CreateTimer((duration_in + duration_hold), Timer_CauseFadeInAndFadeOut, duration_out);
}

static int Building_particle_Owner[MAXENTITIES];
void SDKHooks_UpdateMarkForDeath(int client, bool force_Clear = false)
{
//	if(!b_GaveMarkForDeath[client])
//		return;

	if(!IsValidClient(client))
	{
		/*
		int entity = EntRefToEntIndex(i_DyingParticleIndication[client][2]);
		if(entity > MaxClients)
			RemoveEntity(entity);
		*/	
		return;
	}
	if (GetTeam(client) != TFTeam_Red)
		force_Clear = true;

	if (dieingstate[client] != 0)
		force_Clear = true;
		
	if (TeutonType[client] != TEUTON_NONE)
		force_Clear = true;

	int downsleft;
	downsleft = 2;
	if(ZR_Get_Modifier() == PREFIX_ONESTAND)
		downsleft = 3;
	downsleft -= i_AmountDowned[client];
	downsleft += Dungeon_DownedBonus();
	if(HasSpecificBuff(client, "Nightmare Terror"))
		downsleft = 0;
	if(!force_Clear && downsleft <= 0 && !SpecterCheckIfAutoRevive(client))
	{
		if(!b_GaveMarkForDeath[client])
		{
			TF2_AddCondition(client, TFCond_MarkedForDeathSilent, 9999999.9);
			b_GaveMarkForDeath[client] = true;
		}
	}
	else
	{
		if(force_Clear || b_GaveMarkForDeath[client])
		{
			TF2_RemoveCondition(client, TFCond_MarkedForDeathSilent);
			b_GaveMarkForDeath[client] = false;
		}
	}
}

public Action SDKHooks_TransmitDoDeathMark(int entity, int client)
{
	if(client == Building_particle_Owner[entity])
		return Plugin_Handled;

	return Plugin_Continue;
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
	DispatchKeyValue(FadeEntity, "renderamt", SetRenderDo[0]);
	DispatchKeyValue(FadeEntity, "holdtime", "0");
	static char Buffer[32];
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
	if(GetEntityMoveType(client) == MOVETYPE_NOCLIP)
	{
		damage = 0.0;
		return;
	}
	
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

#if defined RPG
	float value = Attributes_GetOnPlayer(client, Attrib_FormRes, true, true, 0.0);
	if(value)
	{
		damage *= value;
	}
#endif
}
//problem: tf2 code lazily made it only work for clients, the server doesnt get this information updated all the time now.
#define SKIN_ZOMBIE			5
#define SKIN_ZOMBIE_SPY		SKIN_ZOMBIE + 18

void UpdatePlayerFakeModel(int client)
{
#if defined ZR
	if(TeutonType[client] != TEUTON_NONE)
	{
		return;
	}
#endif
	int PlayerModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(PlayerModel > 0)
	{	
#if defined ZR || defined RPG
		if(i_PlayerModelOverrideIndexWearable[client] >= 0)
		{
			SetEntProp(PlayerModel, Prop_Send, "m_nBody", PlayerCustomModelBodyGroup[i_PlayerModelOverrideIndexWearable[client]]);
			return;
		}
		SDKCall_RecalculatePlayerBodygroups(client);
		i_nm_body_client[client] = GetEntProp(client, Prop_Data, "m_nBody");
		SetEntProp(PlayerModel, Prop_Send, "m_nBody", i_nm_body_client[client]);
#endif
	}
}

stock void IncreaseEntityDamageTakenBy(int entity, float amount, float duration, bool Flat = false)
{
	if(!Flat)
	{
		if(amount > 1.0)
			ApplyStatusEffect(entity, entity, "Heavy Laccerations", duration);
	}
	else
	{
		if(amount > 0.0)
			ApplyStatusEffect(entity, entity, "Heavy Laccerations", duration);
	}
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

stock void IncreaseEntityDamageDealtBy(int entity, float amount, float duration)
{
	f_MultiDamageDealt[entity] *= amount;
	
	Handle pack;
	CreateDataTimer(duration, RevertDamageDealtAgain, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, EntIndexToEntRef(entity));
	WritePackFloat(pack, amount);
}

public Action RevertDamageDealtAgain(Handle final, any pack)
{
	ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	float damagemulti = ReadPackFloat(pack);
	
	if (IsValidEntity(entity))
	{
		f_MultiDamageDealt[entity] /= damagemulti;
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
		case 250:
		{
			return 0.88;
		}
		default:
		{
			return 1.0;
		}
	}
}

void DisplayCosmeticExtraClient(int client, bool deleteOverride = false)
{
	int entity;
	//no wings as teuton
	if(TeutonType[client] != TEUTON_NONE)
		deleteOverride = true;
	
	if(deleteOverride)
	{
		if(IsValidEntity(Cosmetic_WearableExtra[client]))
		{
			entity = EntRefToEntIndex(Cosmetic_WearableExtra[client]);
			if(entity > MaxClients)
				TF2_RemoveWearable(client, entity);
		}
		return;
	}
	int SettingDo;
	if(MagiaWingsDo(client))	//do we even have the wings item?
		SettingDo = MagiaWingsType(client);	//we do, what type of wings do we want?
	if(SilvesterWingsDo(client))
		SettingDo = WINGS_FUSION;

	if(SettingDo == 0)
		return;

	if(IsValidEntity(Cosmetic_WearableExtra[client]))
	{
		entity = Cosmetic_WearableExtra[client];
		if(GetEntProp(entity, Prop_Send, "m_nBody") != SettingDo)
		{
			switch(SettingDo)
			{
				case WINGS_FUSION:
				{
					SetEntProp(entity, Prop_Send, "m_nBody", WINGS_FUSION);
				}
				case WINGS_TWIRL, WINGS_RULIANA, WINGS_LANCELOT, WINGS_STELLA, WINGS_KARLAS:
				{
					SetEntProp(entity, Prop_Send, "m_nBody", SettingDo);
				}
			}
		}
		return;
	}

	entity = CreateEntityByName("tf_wearable");
	if(entity > MaxClients)
	{
		int team = GetClientTeam(client);
		SetEntProp(entity, Prop_Send, "m_nModelIndex", Wing_WearlbeIndex);

		SetEntityRenderColor(entity, 255, 255, 255, 100);
		i_WeaponVMTExtraSetting[entity] = 100; //This makes sure to not reset the alpha.
		switch(SettingDo)
		{
			case WINGS_FUSION:
			{
				SetEntProp(entity, Prop_Send, "m_nBody", WINGS_FUSION);
				SetEntityRenderColor(entity, 255, 255, 255, 3);
				i_WeaponVMTExtraSetting[entity] = 3; //This makes sure to not reset the alpha.
				int weapon2 = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon2 > 0 && i_WeaponVMTExtraSetting[weapon2] != -1)
				{
					SetEntityRenderColor(entity, 255, 255, 255, i_WeaponVMTExtraSetting[weapon2]);
					i_WeaponVMTExtraSetting[entity] = i_WeaponVMTExtraSetting[weapon2]; //This makes sure to not reset the alpha.
				}
			}
			case WINGS_TWIRL, WINGS_RULIANA, WINGS_LANCELOT, WINGS_STELLA, WINGS_KARLAS:
			{
				SetEntProp(entity, Prop_Send, "m_nBody", SettingDo);
			}
		}
		SetTeam(entity, team);
		SetEntProp(entity, Prop_Send, "m_nSkin", team-2);
		SetEntProp(entity, Prop_Send, "m_usSolidFlags", 4);
		SetEntityCollisionGroup(entity, 11);
		SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", 1);
		
		DispatchSpawn(entity);
		SetVariantString("!activator");
		ActivateEntity(entity);

		Cosmetic_WearableExtra[client] = EntIndexToEntRef(entity);
		SDKCall_EquipWearable(client, entity);

		SetEntProp(entity, Prop_Send, "m_fEffects", 129);
		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", client);
	//	SetEntityRenderMode(entity, RENDER_NORMAL);
	}	
}

void ArmorDisplayClient(int client, bool deleteOverride = false)
{
	//update aswell.
	DisplayCosmeticExtraClient(client, deleteOverride);
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
		Force_ExplainBuffToClient(client, "Elemental Damage");
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
		if(i_TransformationLevel[client] > 0)
		{
			if(ArmorCorrosion[client] > 0)
				ArmorCorrosion[client] = ArmorCorrosion[client] * 9 / 10;
			
			HealEntityGlobal(client, client, float(SDKCall_GetMaxHealth(client)) / 80.0, 1.0, 0.0, HEAL_SELFHEAL);	
		}
		else
		{
			if(ArmorCorrosion[client] > 0)
				ArmorCorrosion[client] = ArmorCorrosion[client] * 2 / 3;
			
			HealEntityGlobal(client, client, float(SDKCall_GetMaxHealth(client)) / 40.0, 1.0, 0.0, HEAL_SELFHEAL);	
		}
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
			Drain = form.GetFloatStat(-1, Form::DrainRate, Stats_GetFormMastery(client, form.Name));
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

			if(form.Func_ExtraDrainLogic != INVALID_FUNCTION)
			{
				Call_StartFunction(null, form.Func_ExtraDrainLogic);
				Call_PushCell(client);
				Call_PushFloatRef(Drain);
				Call_Finish();
			}

			
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
	static char buffer[32];
	buffer[0] = 0;
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

	if(ArmorCorrosion[client] > 0)
	{
		int endurance = Stats_Endurance(client) + ArmorCorrosion[client];

		float precent = float(ArmorCorrosion[client]) / float(endurance);
		if(precent > 1.0)
			precent = 1.0;

		red -= RoundToFloor(255 * precent);
		green -= RoundToFloor(165 * precent);
		blue = RoundToFloor(255 * precent);
	}

	SetHudTextParams(0.175 + f_ArmorHudOffsetY[client], 0.925 + f_ArmorHudOffsetX[client], 0.81, red, green, blue, 255);
	ShowSyncHudText(client, SyncHud_ArmorCounter, "%s", buffer);
}

#endif
stock void SDKhooks_SetManaRegenDelayTime(int client, float time)
{
	Mana_Hud_Delay[client] = 0.0;
#if defined ZR
	if(Mana_Regen_Delay[client] < GetGameTime() + time)
		Mana_Regen_Delay[client] = GetGameTime() + time;

	if(f_TimeSinceLastRegenStop[client] < GetGameTime() + time)
		f_TimeSinceLastRegenStop[client] = GetGameTime() + time;
		
	//Set to 0 so hud is good
	if(!b_AggreviatedSilence[client])
		mana_regen[client] = 0.0;
#endif
}

#if defined ZR
void SDkHooks_Think_TutorialStepsDo(int client)
{
	DoTutorialStep(client, true);
}
#endif
void AllowWeaponFireAfterEmpty(int client, int weapon)
{
	if(WeaponWasGivenInfiniteDelay[weapon] && !IsWeaponEmptyCompletly(client, weapon, true))
	{
		//tiny delay to prevent abuse?
		if(Attributes_Get(weapon, 4015, 0.0) == 0.0)
		{
			SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.5);
			SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + 0.5);
		}
		WeaponWasGivenInfiniteDelay[weapon] = false;
	}
}



#if defined ZR
void ManaCalculationsBefore(int client)
{
	has_mage_weapon[client] = false;
	int i, entity;
	float ManaRegen = 12.0;
	float ManaMaxExtra = 500.0;
	
	while(TF2_GetItem(client, entity, i))
	{
		if(i_IsWandWeapon[entity])
		{
			has_mage_weapon[client] = true;
			ManaMaxExtra *= Attributes_Get(entity, 4019, 1.0);
			ManaRegen *= Attributes_Get(entity, 4020, 1.0);
		}
	}
	max_mana[client] = ManaMaxExtra;
	mana_regen[client] = ManaRegen;
			
	if(i_CurrentEquippedPerk[client] & PERK_HASTY_HOPS)
	{
		mana_regen[client] *= 1.35;
	}

	if(Classic_Mode())
	{
		mana_regen[client] *= 0.7;
	}
	

	mana_regen[client] *= Mana_Regen_Level[client];
	max_mana[client] *= Mana_Regen_Level[client];
	/*
	if(b_TwirlHairpins[client])
	{
		mana_regen[client] *= 1.05;
		max_mana[client] *= 1.05;
	}
	*/

	if(b_AggreviatedSilence[client])	
	{
		mana_regen[client] *= 0.35;
	}
	else
	{
		float MultiplyRegen =  GetGameTime() - f_TimeSinceLastRegenStop[client];
	//	MultiplyRegen *= 0.85;
		if(MultiplyRegen < 1.0)
			MultiplyRegen = 1.0;

		if(MultiplyRegen >= 6.0)
			MultiplyRegen = 6.0;

		mana_regen[client] *= MultiplyRegen;
	}
}
#endif



void CorrectClientsideMultiweapon(int client, int Mode)
{
	switch(Mode)
	{
		//We just switched, we want to check if they have the correct weapon after htier ping plus more
		case 1:
		{
			// correct is the amout of time we have to correct game time
			float correct = GetClientLatency(client, NetFlow_Outgoing);

			correct = clamp(correct, 0.0, 1.0);

			f_CheckWeaponDouble[client] = GetGameTime() + (correct * 2.0);
			//Give abit of extra leeway.
			//double beacuse of information being send back and forth.
		}
		case 2:
		{
			if(!f_CheckWeaponDouble[client])
				return;

			if(f_CheckWeaponDouble[client] > GetGameTime())
				return;


			//Compare active weapon to weapon that in "myweapons"

			
			f_CheckWeaponDouble[client] = 0.0;
			//check every 0.5 seconds.

			int weaponAm = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(!IsValidEntity(weaponAm))
				return;
			
			char buffer[36];
			GetEntityClassname(weaponAm, buffer, sizeof(buffer));
			int CurrentSlot = TF2_GetClassnameSlot(buffer, weaponAm);

			int WeaponValidCheck = Store_CycleItems(client, CurrentSlot, false);

			int Maxloop = 1;
			while(WeaponValidCheck == weaponAm && Maxloop < 10) //dont be on same weapon!
			{
				//Prevent inf loop.
				Maxloop++;
				WeaponValidCheck = Store_CycleItems(client, CurrentSlot);
				if(WeaponValidCheck == -1)
					break;
			}
		}
	}

}



#if defined ZR
//this code is ass
void UpdatePerkName(int client)
{
	char buffer[4];
	if(i_CurrentEquippedPerk[client] == PERK_NONE)
	{
		Format(MaxAsignPerkNames[client], sizeof(MaxAsignPerkNames[]), "%s", PerkNames_two_Letter[0]);
		return;
	}
	if(i_CurrentEquippedPerk[client] & PERK_REGENE)
		Format(buffer, sizeof(buffer), "%s%s", PerkNames_two_Letter[1],buffer);
	if(i_CurrentEquippedPerk[client] & PERK_OBSIDIAN)
		Format(buffer, sizeof(buffer), "%s%s", PerkNames_two_Letter[2],buffer);
	if(i_CurrentEquippedPerk[client] & PERK_MORNING_COFFEE)
		Format(buffer, sizeof(buffer), "%s%s", PerkNames_two_Letter[3],buffer);
	if(i_CurrentEquippedPerk[client] & PERK_HASTY_HOPS)
		Format(buffer, sizeof(buffer), "%s%s", PerkNames_two_Letter[4],buffer);
	if(i_CurrentEquippedPerk[client] & PERK_MARKSMAN_BEER)
		Format(buffer, sizeof(buffer), "%s%s", PerkNames_two_Letter[5],buffer);
	if(i_CurrentEquippedPerk[client] & PERK_TESLAR_MULE)
		Format(buffer, sizeof(buffer), "%s%s", PerkNames_two_Letter[6],buffer);
	if(i_CurrentEquippedPerk[client] & PERK_STOCKPILE_STOUT)
		Format(buffer, sizeof(buffer), "%s%s", PerkNames_two_Letter[7],buffer);
	if(i_CurrentEquippedPerk[client] & PERK_ENERGY_DRINK)
		Format(buffer, sizeof(buffer), "%s%s", PerkNames_two_Letter[8],buffer);

	Format(MaxAsignPerkNames[client], sizeof(MaxAsignPerkNames[]), "%s",buffer);
}
#endif