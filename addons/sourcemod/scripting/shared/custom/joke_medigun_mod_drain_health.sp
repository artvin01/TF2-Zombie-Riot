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

int MedigunModeSet[MAXTF2PLAYERS];

void Medigun_OnEntityCreated(int entity) 
{
//	g_DHookMedigunPrimary.HookEntity(Hook_Pre, entity, DHook_MedigunPrimaryAttack);
	DHookEntity(g_DHookWeaponPostFrame, true, entity, .callback = OnMedigunPostFramePost);
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
		if(What_type_Heal == 1.0 || What_type_Heal == 5.0 || What_type_Heal == 6.0)
		{
		//	bool is_uber_activated=view_as<bool>(GetEntProp(medigun, Prop_Send, "m_bChargeRelease"));
			if (target > 0 && target <= MaxClients)	//only allow player heal IF you have attribute.
			{
				DHookSetReturn(hReturn, true);
				return MRES_Supercede;
			}
			else if(!b_NpcHasDied[target] && GetTeam(target) == TFTeam_Red)
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
						bool team = GetTeam(owner)==GetTeam(target);
						if(drains && !team)
						{
							DHookSetReturn(hReturn, true);
							return MRES_Supercede;
						}
					}
				}
				else if(What_type_Heal == 3.0)
				{
					if(i_IsABuilding[target])
					{
						bool team = GetTeam(owner)==GetTeam(target);
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
	Zero(medigun_heal_delay);
	Zero(medigun_hud_delay);
	for(int entity; entity<MAXENTITIES; entity++)
    {
		target_sucked_long[entity] = 0.85;
	}
}

public MRESReturn OnMedigunPostFramePost(int medigun) {
	int owner = GetEntPropEnt(medigun, Prop_Send, "m_hOwnerEntity");
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
				bool team = GetTeam(owner)==GetTeam(healTarget);
				float flDrainRate = 500.0;
				if (b_thisNpcIsARaid[healTarget])
				{
					flDrainRate *= 0.65;
				}
				
				MedigunChargeUber(owner, medigun, 2.0);
				
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
							delete Revert_target_sucked_long_timer[healTarget];
						}
						Revert_target_sucked_long_timer[healTarget] = CreateTimer(1.0, Reset_suck_bonus, healTarget, TIMER_FLAG_NO_MAPCHANGE);
						Handle_on_target_sucked_long[healTarget] = true;
						
						flDrainRate *= target_sucked_long[healTarget];
						
						static float Entity_Position[3];
						WorldSpaceCenter(healTarget, Entity_Position );
						
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
							delete Revert_target_sucked_long_timer[healTarget];
						}
						Revert_target_sucked_long_timer[healTarget] = CreateTimer(1.0, Reset_suck_bonus, healTarget, TIMER_FLAG_NO_MAPCHANGE);
						Handle_on_target_sucked_long[healTarget] = true;
						
						flDrainRate *= target_sucked_long[healTarget];
						
						static float Entity_Position[3];
						WorldSpaceCenter(healTarget, Entity_Position );
						
						SDKHooks_TakeDamage(healTarget, medigun, owner, flDrainRate * GetGameFrameTime(), DMG_PLASMA, medigun, _, Entity_Position);
					}
					
					new_ammo -= 6;
					
					if(GetEntProp(healTarget, Prop_Data, "m_iHealth") <= 0 && !TF2_IsPlayerInCondition(owner, TFCond_Ubercharged) && !TF2_IsPlayerInCondition(owner, TFCond_MegaHeal))
					{
						MedigunChargeUber(owner, medigun, 7.0);
					}
					
				}
#if defined ZR						
				SetAmmo(owner, 22, new_ammo);
				CurrentAmmo[owner][22] = GetAmmo(owner, 22);
#endif					
			}
			if(medigun_hud_delay[owner] < GetGameTime())
			{
				PrintHintText(owner,"Medigun Fluid Capacity: %iml", new_ammo + 1);
				StopSound(owner, SNDCHAN_STATIC, "UI/hint.wav");
				medigun_hud_delay[owner] = GetGameTime() + 0.5;
			}
		}
		else if(What_type_Heal == 1.0 || What_type_Heal == 5.0 || What_type_Heal == 6.0)
		{
			int new_ammo = GetAmmo(owner, 21);
			if((IsValidClient(healTarget) && healTarget<=MaxClients && GetAmmo(owner, 21) > 0) || (IsValidEntity(healTarget) && !b_NpcHasDied[healTarget] && GetTeam(healTarget) == TFTeam_Red) && GetAmmo(owner, 21) > 0)
			{
				bool team = GetTeam(owner)==GetTeam(healTarget);
				if(team)
				{
					bool Is_Allied_Npc = false;
					MedigunChargeUber(owner, medigun, 1.0);
					
					float Healing_Value = Attributes_Get(medigun, 8, 1.0);
					Healing_Value *= Attributes_GetOnPlayer(owner, 8, true, true);
					
					float healing_Amount = Healing_Value;
					float healing_Amount_Self = Healing_Value;



					if(What_type_Heal == 5.0)
					{
						switch(MedigunModeSet[owner])
						{
							case 0:
							{
								Adaptive_MedigunBuff[owner][0] = GetGameTime() + 0.15;
								Adaptive_MedigunBuff[healTarget][0] = GetGameTime() + 0.15;
							}
							case 1:
							{
								Adaptive_MedigunBuff[owner][1] = GetGameTime() + 0.15;
								Adaptive_MedigunBuff[healTarget][1] = GetGameTime() + 0.15;
							}
							case 2:
							{
								Adaptive_MedigunBuff[owner][2] = GetGameTime() + 0.15;
								Adaptive_MedigunBuff[healTarget][2] = GetGameTime() + 0.15;
							}
						}
					}
#if defined ZR
					if(healTarget <= MaxClients && dieingstate[healTarget] > 0 && dieingstate[owner] == 0)
					{
						ReviveClientFromOrToEntity(healTarget, owner,_, 1);
					}
					else
#endif
					{
						if(i_targethealedLastBy[healTarget] != owner) //If youre healing someone thats already being healed, then the healing amount will be heavily reduced.
						{
							healing_Amount *= 0.25;
						}	

						if(f_TimeUntillNormalHeal[healTarget] - 2.0 > GetGameTime())
						{
							healing_Amount *= 0.33;
						}
						if(f_TimeUntillNormalHeal[owner] - 2.0 > GetGameTime())
						{
							healing_Amount_Self *= 0.33;
						}
#if defined ZR	
						if(owner <= MaxClients && dieingstate[owner] > 0)
						{
							healing_Amount_Self = 0.0;
						}
						if(healTarget <= MaxClients && dieingstate[healTarget] > 0)
						{
							healing_Amount = 0.0;
						}
#endif

						float flMaxHealth;
						//The healing is less then 1 ? Do own logic.
						if(!Is_Allied_Npc)
						{
							flMaxHealth = 1.5;
						}
						else
						{
							flMaxHealth = 1.25;
						}
						flMaxHealth *= Attributes_Get(medigun, 4002, 1.0);
#if defined ZR
						if(What_type_Heal == 6.0)
						{
							float Healing_GiveArmor = 0.35;

							if(healTarget <= MaxClients)
							{
								Healing_GiveArmor *= Healing_Value;

								if(f_TimeUntillNormalHeal[healTarget] > GetGameTime())
								{
									Healing_GiveArmor *= 0.33;
								}
								if(i_targethealedLastBy[healTarget] != owner) //If youre healing someone thats already being healed, then the healing amount will be heavily reduced.
								{
									Healing_GiveArmor *= 0.33;
								}	
								GiveArmorViaPercentage(healTarget, Healing_GiveArmor, 1.0, true);
							}

							
							Healing_GiveArmor = 0.35;

							Healing_GiveArmor *= Healing_Value;

							if(f_TimeUntillNormalHeal[owner] > GetGameTime())
							{
								Healing_GiveArmor *= 0.25;
							}
							GiveArmorViaPercentage(owner, Healing_GiveArmor, 1.0, true);
						}
#endif

						i_targethealedLastBy[healTarget] = owner;
						//self heal
						int ammoSubtract;
						ammoSubtract = HealEntityGlobal(owner, owner, healing_Amount_Self, 1.0, 0.0, _, new_ammo);
						new_ammo -= ammoSubtract;
						ApplyHealEvent(owner, ammoSubtract);

						//Ally Heal
						ammoSubtract = HealEntityGlobal(owner, healTarget, healing_Amount, flMaxHealth, 0.0, _, new_ammo);
						new_ammo -= ammoSubtract;

						if(!b_NpcHasDied[healTarget])
						{
							Calculate_And_Display_hp(owner, healTarget, 0.0, true);
						}
						else //is a player probably.
						{

							ApplyHealEvent(healTarget, ammoSubtract);
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
				}
#if defined ZR
				SetAmmo(owner, 21, new_ammo);
				CurrentAmmo[owner][21] = GetAmmo(owner, 21);
#endif
			}
			if(medigun_hud_delay[owner] < GetGameTime())
			{
				if(What_type_Heal != 5.0)
				{
					PrintHintText(owner,"Medigun Medicine Fluid: %iml", new_ammo);
				}
				else
				{
					switch(MedigunModeSet[owner])
					{
						case 0:
						{
							PrintHintText(owner,"Medigun Medicine Fluid: %iml\nMode: General", new_ammo);
						}
						case 1:
						{
							PrintHintText(owner,"Medigun Medicine Fluid: %iml\nMode: Melee", new_ammo);
						}
						case 2:
						{
							PrintHintText(owner,"Medigun Medicine Fluid: %iml\nMode: Ranged", new_ammo);
						}
					}
				}
				StopSound(owner, SNDCHAN_STATIC, "UI/hint.wav");
				medigun_hud_delay[owner] = GetGameTime() + 0.5;
			}
		}
		else if(What_type_Heal == 4.0 && GetAmmo(owner, 22) > 0)
		{
			if(IsValidEntity(healTarget) && healTarget>MaxClients)
			{
				bool team = GetTeam(owner)==GetTeam(healTarget);
				float flDrainRate = 500.0;
				if (b_thisNpcIsARaid[healTarget])
				{
					flDrainRate *= 0.65;
				}
				
				MedigunChargeUber(owner, medigun, 5.0);

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
						delete Revert_target_sucked_long_timer[healTarget];
					}
					Revert_target_sucked_long_timer[healTarget] = CreateTimer(1.0, Reset_suck_bonus, healTarget, TIMER_FLAG_NO_MAPCHANGE);
					Handle_on_target_sucked_long[healTarget] = true;
						
					flDrainRate *= target_sucked_long[healTarget];
						
					static float Entity_Position[3];
					WorldSpaceCenter(healTarget, Entity_Position );
						
					SDKHooks_TakeDamage(healTarget, medigun, owner, flDrainRate * GetGameFrameTime(), DMG_PLASMA, medigun, _, Entity_Position);
				}
				float flChargeLevel = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
				if (flChargeLevel==1.0) 
				{
					SetEntProp(medigun, Prop_Send, "m_bChargeRelease", 1);
				}
				new_ammo -= 6;

#if defined ZR
				SetAmmo(owner, 22, new_ammo);
				CurrentAmmo[owner][22] = GetAmmo(owner, 22);
#endif				
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
	float heatrefresh = 0.12;

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

void MedigunChargeUber(int owner, int medigun, float extra_logic, bool RespectUberDuration = false)
{
	if (IsInvuln(owner))
		return;
		
	float flChargeLevel = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");

	float HeatExtra = 0.10;

	if(RespectUberDuration)
		HeatExtra = HeatExtra / MedigunGetUberDuration(owner);

	flChargeLevel += (HeatExtra * GetGameFrameTime() * extra_logic);
	
	if (flChargeLevel > 1.0)
	{
		flChargeLevel = 1.0;
	}
	
	SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", flChargeLevel);
}

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



public void Adaptive_MedigunChangeBuff(int client, int weapon, bool crit, int slot)
{
	ClientCommand(client, "playgamesound weapons/vaccinator_toggle.wav");
	MedigunModeSet[client]++;
	if(MedigunModeSet[client] > 2)
	{
		MedigunModeSet[client] = 0;
	}
}
