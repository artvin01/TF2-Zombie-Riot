#pragma semicolon 1
#pragma newdecls required

/**
 * Monolith plugin for Karma Charger's Medick-Gun.
 * 
 * For damaging teammates to work properly, mp_friendlyfire must be set to 1.
 */


Handle g_DHookWeaponPostFrame;
//Handle g_SDKCallFindEntityInSphere;
//Handle g_SDKCallGetCombatCharacterPtr;
// read from CTFPlayer::DeathSound() disasm
//int offs_CTFPlayer_LastDamageType = 0x215C;

char g_MedicScripts[][] = {
	"medic_sf13_influx_big03",
	"medic_sf13_magic_reac07",
	"Medic.CritDeath",
};

void Medigun_PluginStart() {
	Handle hGameConf_med = LoadGameConfigFile("zombie_riot");
	if (!hGameConf_med) {
		SetFailState("Failed to load gamedata (zombie_riot).");
	}
/*
	StartPrepSDKCall(SDKCall_EntityList);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature,
			"CGlobalEntityList::FindEntityInSphere()");
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer,
			VDECODE_FLAG_ALLOWNULL | VDECODE_FLAG_ALLOWWORLD);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	g_SDKCallFindEntityInSphere = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual,
			"CBaseEntity::MyCombatCharacterPointer()");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_SDKCallGetCombatCharacterPtr = EndPrepSDKCall();
	*/
	Handle dtMedigunAllowedToHealTarget = DHookCreateFromConf(hGameConf_med,
			"CWeaponMedigun::AllowedToHealTarget()");
			
	DHookEnableDetour(dtMedigunAllowedToHealTarget, false, OnAllowedToHealTargetPre);
	
	
	g_DHookWeaponPostFrame = DHookCreateFromConf(hGameConf_med,
			"CBaseCombatWeapon::ItemPostFrame()");

	if (!g_DHookWeaponPostFrame) {
		SetFailState("Failed to setup detour for CBaseCombatWeapon::ItemPostFrame()");
	}

	
	int offslastDamage = FindSendPropInfo("CTFPlayer", "m_flMvMLastDamageTime");
	if (offslastDamage < 0) {
		SetFailState("Could not get offset for CTFPlayer::m_flMvMLastDamageTime");
	}
	
//	offs_CTFPlayer_LastDamageType = offslastDamage + 0x14;
	
	delete hGameConf_med;
}

void Medigun_PersonOnMapStart() {
	PrecacheScriptSound("MVM.BombExplodes");
	PrecacheSound("mvm/mvm_bomb_explode.wav");
	for (int i; i < sizeof(g_MedicScripts); i++) {
		PrecacheScriptSound(g_MedicScripts[i]);
	}
	
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "tf_weapon_medigun")) != -1) {
		DHookEntity(g_DHookWeaponPostFrame, true, entity, .callback = OnMedigunPostFramePost);
	}
	
}


void Medigun_OnEntityCreated(int entity) 
{
	g_DHookMedigunPrimary.HookEntity(Hook_Pre, entity, DHook_MedigunPrimaryAttack);
	DHookEntity(g_DHookWeaponPostFrame, true, entity, .callback = OnMedigunPostFramePost);
}

static float f_MedigunDelayAttackThink[MAXTF2PLAYERS]={0.0, ...};

public MRESReturn DHook_MedigunPrimaryAttack(int entity)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (0 < owner <= MaxClients)
	{
		if(f_MedigunDelayAttackThink[owner] < GetGameTime())
		{
			f_MedigunDelayAttackThink[owner] = GetGameTime() + 0.05;
		 	return MRES_Ignored;
		}
		else
		{
			return MRES_Supercede;	
		}
	}
	return MRES_Ignored;
}
//static bool s_ForceGibRagdoll;
static bool gb_medigun_on_reload[MAXTF2PLAYERS]={false, ...};

// setting this up as a post hook causes windows srcds to crash
public MRESReturn OnAllowedToHealTargetPre(int medigun, Handle hReturn, Handle hParams) {
	int target = DHookGetParam(hParams, 1);
	int owner = GetEntPropEnt(medigun, Prop_Send, "m_hOwnerEntity");
	float What_type_Heal = Attributes_Get(medigun, 2046, 1.0);
	
	
	if(owner > 0 && owner<=MaxClients && IsValidEntity(target))
	{
#if defined ZR
		if(dieingstate[owner] > 0)
		{
			DHookSetReturn(hReturn, false);
			return MRES_Supercede;	
		}
#endif
		if(What_type_Heal == 1.0)
		{
		//	bool is_uber_activated=view_as<bool>(GetEntProp(medigun, Prop_Send, "m_bChargeRelease"));
#if defined ZR
			if (target > 0 && target <= MaxClients && dieingstate[owner] == 0 && dieingstate[target] == 0)	//only allow player heal IF you have attribute.
			{
				DHookSetReturn(hReturn, true);
				return MRES_Supercede;
			}
#else
			if (target > 0 && target <= MaxClients)	//only allow player heal IF you have attribute.
			{
				DHookSetReturn(hReturn, true);
				return MRES_Supercede;
			}
#endif
			else if(b_IsAlliedNpc[target])
			{
				DHookSetReturn(hReturn, true);
				return MRES_Supercede;
			}
			else
			{
				DHookSetReturn(hReturn, false);
				return MRES_Supercede;				
			}
		}
		bool heals = true;
		bool drains = true;
		if(heals || drains)
		{
			if(target>MaxClients)	//only allow hurt enemy IF you have attribute.
			{
				if(What_type_Heal == 2.0 || (What_type_Heal == 4.0 && !gb_medigun_on_reload[owner] && GetEntProp(medigun, Prop_Send, "m_bChargeRelease")!=1))
				{
					static char buffer[64];
					GetEntityClassname(target, buffer, sizeof(buffer));
					if(!StrContains(buffer, "zr_base_npc", true))
					{
						bool team = GetEntProp(owner, Prop_Send, "m_iTeamNum")==GetEntProp(target, Prop_Send, "m_iTeamNum");
						if(drains && !team)
						{
							DHookSetReturn(hReturn, true);
							return MRES_Supercede;
						}
					}
				}
				else if(What_type_Heal == 3.0)
				{
					static char buffer[64];
					GetEntityClassname(target, buffer, sizeof(buffer));
					if(!StrContains(buffer, "obj_", true))
					{
						bool team = GetEntProp(owner, Prop_Send, "m_iTeamNum")==GetEntProp(target, Prop_Send, "m_iTeamNum");
						if((heals && team) || (drains && !team))
						{
							DHookSetReturn(hReturn, true);
							return MRES_Supercede;
						}
					}
				}
			}

			DHookSetReturn(hReturn, false);
			return MRES_Supercede;
		}
	}
	return MRES_Ignored;
}
static float medigun_heal_delay[MAXTF2PLAYERS];
static float medigun_hud_delay[MAXTF2PLAYERS];

static float f_IncrementalSmallHeal[MAXENTITIES];

static int i_targethealedLastBy[MAXENTITIES];

float target_sucked_long[MAXENTITIES]={0.85, ...};

static Handle Revert_target_sucked_long_timer[MAXENTITIES];
static bool Handle_on_target_sucked_long[MAXENTITIES]={false, ...};

stock float Target_Sucked_Long_Return(int entity)
{
	return target_sucked_long[entity];
}

public void Medigun_ClearAll()
{
	Zero(f_IncrementalSmallHeal); //Do not save the heal across stages of the game.
	Zero(f_MedigunDelayAttackThink);
	Zero(medigun_heal_delay);
	Zero(medigun_hud_delay);
	for(int entity; entity<MAXENTITIES; entity++)
    {
		target_sucked_long[entity] = 0.85;
	}
}

public MRESReturn OnMedigunPostFramePost(int medigun) {
	int owner = GetEntPropEnt(medigun, Prop_Send, "m_hOwnerEntity");
#if defined ZR
	if(dieingstate[owner] > 0)
	{
		return MRES_Ignored;	
	}
#endif
	if(medigun_heal_delay[owner] < GetGameTime())
	{
		medigun_heal_delay[owner] = GetGameTime() + 0.1;
		int healTarget = GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
		
		float What_type_Heal = Attributes_Get(medigun, 2046, 1.0);
		
		if(What_type_Heal == 2.0)
		{
			int new_ammo = GetAmmo(owner, 22);
			if(IsValidEntity(healTarget) && healTarget>MaxClients && GetAmmo(owner, 22) > 0)
			{
				bool team = GetEntProp(owner, Prop_Send, "m_iTeamNum")==GetEntProp(healTarget, Prop_Send, "m_iTeamNum");
				float flDrainRate = 500.0;
				
				float flChargeLevel = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
				
				if(!TF2_IsPlayerInCondition(owner, TFCond_Ubercharged) && !TF2_IsPlayerInCondition(owner, TFCond_MegaHeal))
				{
					flChargeLevel += 0.3*GetGameFrameTime();
					
					if (flChargeLevel > 1.0)
					{
						flChargeLevel = 1.0;
					}
					
					SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", flChargeLevel);
				}
				
				if (!team)
				{

					flDrainRate *= Attributes_Get(medigun, 8, 1.0);
					flDrainRate *= Attributes_GetOnPlayer(owner, 8, true, true);
#if defined ZR						
					if(LastMann)	
						flDrainRate *= 2.0;

#endif					
					if(TF2_IsPlayerInCondition(owner, TFCond_MegaHeal))
					{
						target_sucked_long[healTarget] += 0.21;
					
						if(target_sucked_long[healTarget] >= 4.0)
						{
							target_sucked_long[healTarget] = 4.0;
						}
						
						if(Handle_on_target_sucked_long[healTarget])
						{
							KillTimer(Revert_target_sucked_long_timer[healTarget]);
						}
						Revert_target_sucked_long_timer[healTarget] = CreateTimer(1.0, Reset_suck_bonus, healTarget, TIMER_FLAG_NO_MAPCHANGE);
						Handle_on_target_sucked_long[healTarget] = true;
						
						flDrainRate *= target_sucked_long[healTarget];
						
						static float Entity_Position[3];
						Entity_Position = WorldSpaceCenter(healTarget);
						
						SDKHooks_TakeDamage(healTarget, medigun, owner, flDrainRate * GetGameFrameTime() * 3.0, DMG_PLASMA, medigun, _, Entity_Position);
					}
					else
					{
						target_sucked_long[healTarget] += 0.07;
					
						if(target_sucked_long[healTarget] >= 4.0)
						{
							target_sucked_long[healTarget] = 4.0;
						}
						
						if(Handle_on_target_sucked_long[healTarget])
						{
							KillTimer(Revert_target_sucked_long_timer[healTarget]);
						}
						Revert_target_sucked_long_timer[healTarget] = CreateTimer(1.0, Reset_suck_bonus, healTarget, TIMER_FLAG_NO_MAPCHANGE);
						Handle_on_target_sucked_long[healTarget] = true;
						
						flDrainRate *= target_sucked_long[healTarget];
						
						static float Entity_Position[3];
						Entity_Position = WorldSpaceCenter(healTarget);
						
						SDKHooks_TakeDamage(healTarget, medigun, owner, flDrainRate * GetGameFrameTime(), DMG_PLASMA, medigun, _, Entity_Position);
					}
					
					new_ammo -= 6;
					
					if(GetEntProp(healTarget, Prop_Data, "m_iHealth") <= 0 && !TF2_IsPlayerInCondition(owner, TFCond_Ubercharged) && !TF2_IsPlayerInCondition(owner, TFCond_MegaHeal))
					{
						flChargeLevel += 0.1;
					
						if (flChargeLevel > 1.0)
						{
							flChargeLevel = 1.0;
						}
						
						SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", flChargeLevel);
						
					}
					
				}
				SetAmmo(owner, 22, new_ammo);
				CurrentAmmo[owner][22] = GetAmmo(owner, 22);
			}
			if(medigun_hud_delay[owner] < GetGameTime())
			{
				PrintHintText(owner,"Medigun Fluid Capacity: %iml", new_ammo + 1);
				StopSound(owner, SNDCHAN_STATIC, "UI/hint.wav");
				medigun_hud_delay[owner] = GetGameTime() + 0.5;
			}
		}
		else if(What_type_Heal == 3.0)
		{
			int new_ammo = GetAmmo(owner, 3);
			int medigun_mode = GetEntProp(medigun, Prop_Send, "m_nChargeResistType");
			/*
				0 = Bullet
				1 = Blast
				2 = Fire
			*/
			
			if(IsValidEntity(healTarget) && healTarget>MaxClients && GetAmmo(owner, 3) > 0)
			{
				bool team = GetEntProp(owner, Prop_Send, "m_iTeamNum")==GetEntProp(healTarget, Prop_Send, "m_iTeamNum");
		//		float flDrainRate = 100.0;
				
				float flChargeLevel = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
				
				int What_Uber_Type;
				
				if(TF2_IsPlayerInCondition(owner, TFCond_UberBulletResist))
					What_Uber_Type = 0;
					
				else if(TF2_IsPlayerInCondition(owner, TFCond_UberBlastResist))
					What_Uber_Type = 1;
					
				else if(TF2_IsPlayerInCondition(owner, TFCond_UberFireResist))
					What_Uber_Type = 2;
					
				else
					What_Uber_Type = -1;
						
				if(What_Uber_Type == -1)
				{
					flChargeLevel += 0.15*GetGameFrameTime();
					
					if (flChargeLevel > 1.0)
					{
						flChargeLevel = 1.0;
					}
					
					SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", flChargeLevel);
				}
				
				if(team)
				{
					float healing_Amount;
					float how_high_is_attribute_medigun = Attributes_Get(medigun, 95, 1.0);
					how_high_is_attribute_medigun *= Attributes_GetOnPlayer(owner, 95, true, true);
					
					if (how_high_is_attribute_medigun == 0.0)
						how_high_is_attribute_medigun = 1.0;
					
					if(medigun_mode == 0 || medigun_mode == 2)
					{
						if(What_Uber_Type == 0)
							healing_Amount = 36.0 * how_high_is_attribute_medigun;
						else if(What_Uber_Type == 2)
							healing_Amount = 15.0 * how_high_is_attribute_medigun;
						else if  (medigun_mode == 2)
							healing_Amount = 6.0 * how_high_is_attribute_medigun;
						else if  (medigun_mode == 0)
							healing_Amount = 12.0 * how_high_is_attribute_medigun;
					}
					else
						healing_Amount = 5.0 * how_high_is_attribute_medigun;
						
						
					if(medigun_mode == 1)
					{
				//		int Builder = GetEntPropEnt(healTarget, Prop_Send, "m_hBuilder");
						
						if(What_Uber_Type == 1)
							Increaced_Sentry_damage_High[healTarget] = GetGameTime() + 0.11;
							
						else
							Increaced_Sentry_damage_Low[healTarget] = GetGameTime() + 0.11;
					}
					/*
					else if(medigun_mode == 2)
					{
						
						if(What_Uber_Type == 2)
							Resistance_for_building_High[healTarget] = GetGameTime() + 0.11;
							
						else
							Resistance_for_building_Low[healTarget] = GetGameTime() + 0.11;
							
							
						int flHealth = GetEntProp(healTarget, Prop_Send, "m_iHealth");
						int Healing_Value = healing_Amount;
						int newHealth = flHealth + healing_Amount;
						
						int max_health = GetEntProp(healTarget, Prop_Send, "m_iMaxHealth");
						
						if(newHealth >= max_health)
						{
							healing_Amount -= newHealth - max_health;
							newHealth = max_health;
						}
						
					//	SetEntProp(healTarget, Prop_Send, "m_iHealth", newHealth);
						int Remove_Ammo = healing_Amount / 2;
						if(Remove_Ammo < 0)
						{
							Remove_Ammo = 0;
						}
						
						new_ammo -= Remove_Ammo;
						
						if(newHealth > 1 && Healing_Value > 1) //for some reason its able to set it to 1
						{
							SetVariantInt(Healing_Value);
							AcceptEntityInput(healTarget, "AddHealth");
					//		SetEntityHealth(healTarget, newHealth);
						//	SetEntProp(healTarget, Prop_Send, "m_iMaxHealth", max_health);
						}
					}
					*/
					
					int i_HealingAmount = RoundToCeil(healing_Amount);
					int flHealth = GetEntProp(healTarget, Prop_Send, "m_iHealth");
					int Healing_Value = i_HealingAmount;
					int newHealth = flHealth + i_HealingAmount;
					
					int max_health = GetEntProp(healTarget, Prop_Send, "m_iMaxHealth");
					
					if(newHealth >= max_health)
					{
						i_HealingAmount -= newHealth - max_health;
						newHealth = max_health;
					}
					
					int Remove_Ammo = i_HealingAmount / 3;
					
				//	SetEntProp(healTarget, Prop_Send, "m_iHealth", newHealth);
					if  (medigun_mode == 2)
					{
						Remove_Ammo = i_HealingAmount / 6;
					}
					
					if(Remove_Ammo < 0)
					{
						Remove_Ammo = 0;
					}
					
					new_ammo -= Remove_Ammo;
					
					if(newHealth > 1 && Healing_Value > 1) //for some reason its able to set it to 1
					{
						SetVariantInt(Healing_Value);
						AcceptEntityInput(healTarget, "AddHealth");
				//		SetEntityHealth(healTarget, newHealth);
					//	SetEntProp(healTarget, Prop_Send, "m_iMaxHealth", max_health);
					}
				}
				SetAmmo(owner, 3, new_ammo);
				CurrentAmmo[owner][3] = GetAmmo(owner, 3);
			}
			if(medigun_hud_delay[owner] < GetGameTime())
			{
				if(IsValidEntity(healTarget) && healTarget>MaxClients)
				{
					int healthbuilding = GetEntProp(healTarget, Prop_Data, "m_iHealth");
					if(medigun_mode == 0)
						PrintHintText(owner,"[Heal Mode] Metal: %i\nHealth [%i/%i]\nRepair Left: [%i]", new_ammo,healthbuilding,Building_Max_Health[healTarget],Building_Repair_Health[healTarget]);
					else if(medigun_mode == 1)
						PrintHintText(owner,"[Damage Mode] Metal: %i\nHealth [%i/%i]\nRepair Left: [%i]", new_ammo,healthbuilding,Building_Max_Health[healTarget],Building_Repair_Health[healTarget]);
					else if(medigun_mode == 2)
						PrintHintText(owner,"[Metal-Efficient Mode] Metal: %i\nHealth [%i/%i]\nRepair Left: [%i]", new_ammo,healthbuilding,Building_Max_Health[healTarget],Building_Repair_Health[healTarget]);
				}
				else
				{
					if(medigun_mode == 0)
						PrintHintText(owner,"[Heal Mode] Metal: %i", new_ammo);
					else if(medigun_mode == 1)
						PrintHintText(owner,"[Damage Mode] Metal: %i", new_ammo);
					else if(medigun_mode == 2)
						PrintHintText(owner,"[Metal-Efficient Mode] Metal: %i", new_ammo);
					
				}
						
				StopSound(owner, SNDCHAN_STATIC, "UI/hint.wav");
				medigun_hud_delay[owner] = GetGameTime() + 0.5;
			}
		}
		else if(What_type_Heal == 1.0)
		{
			int new_ammo = GetAmmo(owner, 21);
			if((IsValidClient(healTarget) && healTarget<=MaxClients && GetAmmo(owner, 21) > 0) || (IsValidEntity(healTarget) && b_IsAlliedNpc[healTarget]) && GetAmmo(owner, 21) > 0)
			{
				bool team = GetEntProp(owner, Prop_Data, "m_iTeamNum")==GetEntProp(healTarget, Prop_Data, "m_iTeamNum");
				if(team)
				{
					bool Is_Allied_Npc = false;
					if(b_IsAlliedNpc[healTarget]) //Give uber
					{
#if defined ZR
						float flChargeLevel = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
						
						flChargeLevel += 0.12*GetGameFrameTime();
					
						if (flChargeLevel > 1.0)
						{
							flChargeLevel = 1.0;
						}
						
						SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", flChargeLevel);
#endif
						Is_Allied_Npc = true;
					}
					
					float Healing_Value = Attributes_Get(medigun, 8, 1.0);
					Healing_Value *= Attributes_GetOnPlayer(owner, 8, true, true);
#if defined ZR					
					if(b_HealthyEssence)
						Healing_Value *= 1.25;
#endif
					float healing_Amount = Healing_Value;
					float healing_Amount_Self = Healing_Value;
						
					if(i_targethealedLastBy[healTarget] != owner) //If youre healing someone thats already being healed, then the healing amount will be heavily reduced.
					{
						healing_Amount *= 0.25;
					}
					
					i_targethealedLastBy[healTarget] = owner;
					
					if(f_TimeUntillNormalHeal[healTarget] > GetGameTime())
					{
						healing_Amount *= 0.25;
					}
					if(f_TimeUntillNormalHeal[owner] > GetGameTime())
					{
						healing_Amount_Self *= 0.25;
					}
					
					
					int i_SelfHealAmount;
					int i_TargetHealAmount;
					//The healing is less then 1 ? Do own logic.
					
					if (healing_Amount <= 1.0)
					{
						f_IncrementalSmallHeal[healTarget] += healing_Amount;
						
						if(f_IncrementalSmallHeal[healTarget] >= 1.0)
						{
							f_IncrementalSmallHeal[healTarget] -= 1.0;
							i_TargetHealAmount = 1;
						}
						else
						{
							if(b_IsAlliedNpc[healTarget])
							{
								Calculate_And_Display_hp(owner, healTarget, 0.0, true);
							}
							return MRES_Ignored;
						}
					}
					else
					{
						i_TargetHealAmount = RoundToFloor(healing_Amount);
						
						float Decimal_healing = FloatFraction(healing_Amount);
						
						
						f_IncrementalSmallHeal[healTarget] += Decimal_healing;
						
						if(f_IncrementalSmallHeal[healTarget] >= 1.0)
						{
							f_IncrementalSmallHeal[healTarget] -= 1.0;
							i_TargetHealAmount += 1;
						}
					}
					
					if (healing_Amount_Self <= 1.0)
					{
						f_IncrementalSmallHeal[owner] += healing_Amount_Self;
						
						if(f_IncrementalSmallHeal[owner] >= 1.0)
						{
							f_IncrementalSmallHeal[owner] -= 1.0;
							i_SelfHealAmount = 1;
						}
						else
						{
							if(b_IsAlliedNpc[healTarget])
							{
								Calculate_And_Display_hp(owner, healTarget, 0.0, true);
							}
							return MRES_Ignored;
						}
					}
					else
					{
						i_SelfHealAmount = RoundToFloor(healing_Amount_Self);
						
						float Decimal_healing = FloatFraction(healing_Amount_Self);
						
						
						f_IncrementalSmallHeal[owner] += Decimal_healing;
						
						if(f_IncrementalSmallHeal[owner] >= 1.0)
						{
							f_IncrementalSmallHeal[owner] -= 1.0;
							i_SelfHealAmount += 1;
						}
					}
					
					
					
					//HEALING STARTS NOW!
					
						
					int flHealth = GetEntProp(healTarget, Prop_Data, "m_iHealth");
					
					int Current_health_target = flHealth;
					
					int newHealth = flHealth + i_TargetHealAmount;
					
					int flMaxHealth;
					
					if(!Is_Allied_Npc)
					{
#if defined RPG
						flMaxHealth = SDKCall_GetMaxHealth(healTarget);
#else
						flMaxHealth = RoundToNearest(float(SDKCall_GetMaxHealth(healTarget)) * 1.5);
#endif
					}
					else
					{
						flMaxHealth = RoundToNearest(float(GetEntProp(healTarget, Prop_Data, "m_iMaxHealth")) * 1.25);
					}
					
					if(Current_health_target < flMaxHealth)
					{	
						//TARGET HEAL
						if(newHealth >= flMaxHealth)
						{
							i_TargetHealAmount -= newHealth - flMaxHealth;
							newHealth = flMaxHealth;
						}
						
						ApplyHealEvent(healTarget, i_TargetHealAmount);
						SetEntProp(healTarget, Prop_Data, "m_iHealth", newHealth);
						new_ammo -= i_TargetHealAmount;
#if defined ZR
						Healing_done_in_total[owner] += i_TargetHealAmount;
#endif
						if(!b_IsAlliedNpc[healTarget])
						{
							Give_Assist_Points(healTarget, owner);
						}
						//TARGET HEAL
					}
					if(b_IsAlliedNpc[healTarget])
					{
						Calculate_And_Display_hp(owner, healTarget, 0.0, true);
					}
					flHealth = GetEntProp(owner, Prop_Data, "m_iHealth");
					
					
					int Current_health_owner = flHealth;
					
					//SELF HEAL
					newHealth = flHealth + i_SelfHealAmount;
					
					flMaxHealth = SDKCall_GetMaxHealth(owner);
					
					if(Current_health_owner < flMaxHealth)
					{
						if(newHealth >= flMaxHealth)
						{
							i_SelfHealAmount -= newHealth - flMaxHealth;
							newHealth = flMaxHealth;
						}
						ApplyHealEvent(owner, i_SelfHealAmount);
						
						SetEntProp(owner, Prop_Data, "m_iHealth", newHealth);
						new_ammo -= i_SelfHealAmount;
#if defined ZR
						Healing_done_in_total[owner] += i_SelfHealAmount;
#endif						
						//SELF HEAL
						
					}
					float duration;

					duration = Increaced_Overall_damage_Low[owner] - GetGameTime();
					if(duration < 1.2)
					{
						Increaced_Overall_damage_Low[owner] = GetGameTime() + 1.0;
					}
					duration = Resistance_Overall_Low[owner] - GetGameTime();
					if(duration < 1.2)
					{
						Resistance_Overall_Low[owner] = GetGameTime() + 1.0;
					}
					duration = Increaced_Overall_damage_Low[healTarget] - GetGameTime();
					if(duration < 1.2)
					{
						Increaced_Overall_damage_Low[healTarget] = GetGameTime() + 1.0;
					}
					duration = Resistance_Overall_Low[healTarget] - GetGameTime();
					if(duration < 1.2)
					{
						Resistance_Overall_Low[healTarget] = GetGameTime() + 1.0;
					}
					
				}
				SetAmmo(owner, 21, new_ammo);
				CurrentAmmo[owner][21] = GetAmmo(owner, 21);
			}
			if(medigun_hud_delay[owner] < GetGameTime())
			{
				PrintHintText(owner,"Medigun Medicine Fluid: %iml", new_ammo);
				StopSound(owner, SNDCHAN_STATIC, "UI/hint.wav");
				medigun_hud_delay[owner] = GetGameTime() + 0.5;
			}
		}
		else if(What_type_Heal == 4.0 && GetAmmo(owner, 22) > 0)
		{
			if(IsValidEntity(healTarget) && healTarget>MaxClients)
			{
				bool team = GetEntProp(owner, Prop_Send, "m_iTeamNum")==GetEntProp(healTarget, Prop_Send, "m_iTeamNum");
				float flDrainRate = 500.0;
				
				float flChargeLevel = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
						
				
				flChargeLevel += 0.15*GetGameFrameTime();
				
				if (flChargeLevel > 1.0)
				{
					flChargeLevel = 1.0;
				}
				
				SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", flChargeLevel);
				int new_ammo = GetAmmo(owner, 22);
				
				if (!team)
				{

					flDrainRate *= Attributes_Get(medigun, 8, 1.0);
					flDrainRate *= Attributes_Get(medigun, 1, 1.0);
					flDrainRate *= Attributes_GetOnPlayer(owner, 8, true, true);
					//there are some updgras that require medigun damage only!
#if defined ZR
					if(LastMann)	
						flDrainRate *= 2.0;
#endif				
					target_sucked_long[healTarget] += 0.07;
					
					if(target_sucked_long[healTarget] >= 4.0)
					{
						target_sucked_long[healTarget] = 4.0;
					}
						
					if(Handle_on_target_sucked_long[healTarget])
					{
						KillTimer(Revert_target_sucked_long_timer[healTarget]);
					}
					Revert_target_sucked_long_timer[healTarget] = CreateTimer(1.0, Reset_suck_bonus, healTarget, TIMER_FLAG_NO_MAPCHANGE);
					Handle_on_target_sucked_long[healTarget] = true;
						
					flDrainRate *= target_sucked_long[healTarget];
						
					static float Entity_Position[3];
					Entity_Position = WorldSpaceCenter(healTarget);
						
					SDKHooks_TakeDamage(healTarget, medigun, owner, flDrainRate * GetGameFrameTime(), DMG_PLASMA, medigun, _, Entity_Position);
				}
				
				if (flChargeLevel==1.0) 
				{
					SetEntProp(medigun, Prop_Send, "m_bChargeRelease", 1);
				}
				new_ammo -= 6;

				SetAmmo(owner, 22, new_ammo);
				CurrentAmmo[owner][22] = GetAmmo(owner, 22);
				if(medigun_hud_delay[owner] < GetGameTime())
				{
					if(!gb_medigun_on_reload[owner])
					{
						PrintHintText(owner,"Medigun Medicine Fluid: %iml\n Press RELOAD to Enable Fast Cooldown system.\n Press M2 to Shoot Energy projectiles.", new_ammo);
					}
					else
					{
						PrintHintText(owner,"FASTER COOLING DOWN ON! Unable to attack untill fully Cooled down!");
					}
					StopSound(owner, SNDCHAN_STATIC, "UI/hint.wav");
					medigun_hud_delay[owner] = GetGameTime() + 0.5;
				}
			}
			else if (gb_medigun_on_reload[owner])
			{
				float flChargeLevel = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
						
				if (flChargeLevel > 0.0) 
				{
					float heatrefresh = 0.05;

					heatrefresh = heatrefresh / MedigunGetUberDuration(owner);
					
					flChargeLevel -= heatrefresh*0.1;
					
					if (flChargeLevel < 0.0)
					{
						flChargeLevel = 0.0;
					}
					
					SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", flChargeLevel);
				}
				else
				{
					
					gb_medigun_on_reload[owner] = false;
				}
			}
			else if (GetEntProp(medigun, Prop_Send, "m_bChargeRelease")==1)
			{
				float flChargeLevel = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
				if (flChargeLevel > 0.0) 
				{
					float heatrefresh = 0.05;

					heatrefresh = heatrefresh / MedigunGetUberDuration(owner);
					
					flChargeLevel -= heatrefresh*0.1;
					
					if (flChargeLevel < 0.0)
					{
						flChargeLevel = 0.0;
					}
					
					SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", flChargeLevel);
				}
			}
			else 
			{
				float flChargeLevel = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
						
				if (flChargeLevel > 0.0) 
				{
					float heatrefresh = 0.05;

					heatrefresh = heatrefresh / MedigunGetUberDuration(owner);

					flChargeLevel -= heatrefresh*0.1;

					if (flChargeLevel < 0.0)
					{
						flChargeLevel = 0.0;
					}
					
					SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", flChargeLevel);
				}
			}
		}
	}
	return MRES_Ignored;
}


public void GB_On_Reload(int client, int weapon, bool crit) {
	if (gb_medigun_on_reload[client] || GetEntProp(weapon, Prop_Send, "m_bChargeRelease")==1 || GetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel")==0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	PrintHintText(client,"FASTER COOLING DOWN ON! Unable to attack untill fully Cooled down!");
	StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
	SetEntProp(weapon, Prop_Send, "m_bChargeRelease", 1);
	gb_medigun_on_reload[client] = true;
}
#if defined ZR
public void GB_Check_Ball(int owner, int weapon, bool crit)
{
	if (gb_medigun_on_reload[owner] || GetEntProp(weapon, Prop_Send, "m_bChargeRelease")==1)
	{
		ClientCommand(owner, "playgamesound items/medshotno1.wav");
		return;
	}
	float heatrefresh = 0.06;

	heatrefresh = heatrefresh / MedigunGetUberDuration(owner);
	float flChargeLevel = GetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel")+heatrefresh;
						
	if (flChargeLevel >= 1.0) 
	{
		flChargeLevel = 1.0;
		SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", flChargeLevel);
		
		SetEntProp(weapon, Prop_Send, "m_bChargeRelease", 1);
	}
	else
		SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", flChargeLevel);
	
	Weapon_GB_Ball(owner, weapon, crit);
}
#endif

public Action Reset_suck_bonus(Handle cut_timer, int entity)
{
	target_sucked_long[entity] = 0.85;
	Handle_on_target_sucked_long[entity] = false;
	return Plugin_Handled;
}

stock int CreateParticleOnBackPack(const char[] sParticle, int client)
{
	float pos[3];
	
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
	
	int entity = CreateEntityByName("info_particle_system");
	TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchKeyValue(entity, "effect_name", sParticle);
	
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", client, entity, 0);
	
	SetVariantString("flag");
	AcceptEntityInput(entity, "SetParentAttachment", entity, entity, 0);
	
	char t_Name[128];
	Format(t_Name, sizeof(t_Name), "target%i", client);
	
	DispatchKeyValue(entity, "targetname", t_Name);
	
	DispatchSpawn(entity);
	ActivateEntity(entity);
	AcceptEntityInput(entity, "start");
	return entity;
}


float MedigunGetUberDuration(int owner)
{
	//so it starts at 1.0
	float Attribute = Attributes_GetOnPlayer(owner, 314, true, true) + 3.0;
	
	switch(Attribute)
	{
		case 1.0:
		{
			Attribute = 1.0;
		}
		case 2.0:
		{
			Attribute = 1.15;
		}
		case 3.0:
		{
			Attribute = 1.35;
		}
		case 4.0:
		{
			Attribute = 1.45;
		}
		case 5.0:
		{
			Attribute = 1.65;
		}
	}
	if(Attribute < 1.0)
	{
		Attribute = 1.0;
	}
	return Attribute;
}