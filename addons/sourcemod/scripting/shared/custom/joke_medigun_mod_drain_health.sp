#pragma semicolon 1
#pragma newdecls required

/**
 * Monolith plugin for Karma Charger's Medick-Gun.
 * 
 * For damaging teammates to work properly, mp_friendlyfire must be set to 1.
 */


static float medigun_heal_delay[MAXPLAYERS];
static float medigun_hud_delay[MAXPLAYERS];
Handle g_DHookWeaponPostFrame;

float f_MedigunDelayAttackThink[MAXENTITIES];

void Medigun_PluginStart() {
	Handle hGameConf_med = LoadGameConfigFile("zombie_riot");
	if (!hGameConf_med) {
		SetFailState("Failed to load gamedata (zombie_riot).");
	}

	Handle dtMedigunAllowedToHealTarget = DHookCreateFromConf(hGameConf_med,
			"CWeaponMedigun::AllowedToHealTarget()");
			
	DHookEnableDetour(dtMedigunAllowedToHealTarget, false, OnAllowedToHealTargetPre);
	
	
	g_DHookWeaponPostFrame = DHookCreateFromConf(hGameConf_med,
			"CBaseCombatWeapon::ItemPostFrame()");

	if (!g_DHookWeaponPostFrame) {
		SetFailState("Failed to setup detour for CBaseCombatWeapon::ItemPostFrame()");
	}
	Zero(f_MedigunDelayAttackThink);
	delete hGameConf_med;
}

int MedigunModeSet[MAXPLAYERS];
static bool b_MediunDamageModeSet[MAXENTITIES]={false, ...};

void MedigunPutInServerclient(int client)
{
	//false is default.
	b_MediunDamageModeSet[client] = false;
}
void Medigun_OnEntityCreated(int entity) 
{
	g_DHookMedigunPrimary.HookEntity(Hook_Pre, entity, DHook_MedigunPrimaryAttack);
	DHookEntity(g_DHookWeaponPostFrame, true, entity, .callback = OnMedigunPostFramePost);
}

public MRESReturn DHook_MedigunPrimaryAttack(int entity)
{
	if(f_MedigunDelayAttackThink[entity] < GetGameTime())
	{
		f_MedigunDelayAttackThink[entity] = GetGameTime() + 0.05;
		return MRES_Ignored;
	}
	else
	{
		return MRES_Supercede;	
	}
}

//static bool s_ForceGibRagdoll;
static bool gb_medigun_on_reload[MAXPLAYERS]={false, ...};

/*
	Battle medigun
	"pap_3_lag_comp" 						"1"
	"pap_3_lag_comp_collision" 		"1"
	"pap_3_lag_comp_extend_boundingbox" 		"0"
	"pap_3_lag_comp_dont_move_building" 	"0"
	"pap_3_lag_comp_block_internal" 	"1" 			//Idk why but i need this.
	"pap_3_no_clip"						"1"

*/

bool NeedCrouchAbility(int client)
{
	bool NeedCrouch = zr_interactforcereload.BoolValue;

	if(NeedCrouch)
	{
		NeedCrouch = !b_InteractWithReload[client];
	}
	else
	{
		NeedCrouch = b_InteractWithReload[client];
	}
	return NeedCrouch;
}
public void MedigunChangeModeR(int client, int weapon, bool crit, int slot)
{

	MedigunChangeModeRInternal(client, weapon, crit, slot, NeedCrouchAbility(client));
}
public void MedigunChangeModeRInternal(int client, int weapon, bool crit, int slot, bool checkCrouch)
{
	//only swithc with crouch R
	if(checkCrouch && !(GetClientButtons(client) & IN_DUCK))
		return;

	if(b_MediunDamageModeSet[client])
	{
		b_MediunDamageModeSet[client] = false;
		ClientCommand(client, "playgamesound misc/halloween/spelltick_01.wav");
 	}
	else
	{
		b_MediunDamageModeSet[client] = true;
		ClientCommand(client, "playgamesound misc/halloween/spelltick_02.wav");
	}
	Medigun_SetModeDo(client, weapon);
	medigun_hud_delay[client] = 0.0; //update hud fast
}
public void Medigun_SetModeDo(int client, int weapon)
{
	if(!b_IsAMedigun[weapon])
		return;

	if(b_MediunDamageModeSet[client])
	{
		//Battle medigun logic.
		b_Do_Not_Compensate[weapon] = true;
		b_Only_Compensate_CollisionBox[weapon] = true;
		b_Only_Compensate_AwayPlayers[weapon] = false;
		b_ExtendBoundingBox[weapon] = false;
		b_BlockLagCompInternal[weapon] = true;
		b_Dont_Move_Building[weapon] = false;
		b_Dont_Move_Allied_Npc[weapon] = false;

	}
	else
	{
		//Normal medigun
		b_Do_Not_Compensate[weapon] = false;
		b_Only_Compensate_CollisionBox[weapon] = true;
		b_Only_Compensate_AwayPlayers[weapon] = true;
		b_ExtendBoundingBox[weapon] = false;
		b_BlockLagCompInternal[weapon] = false;
		b_Dont_Move_Building[weapon] = false;
		b_Dont_Move_Allied_Npc[weapon] = true;
	}
	b_MediunDamageModeSet[weapon] = b_MediunDamageModeSet[client];
}

// setting this up as a post hook causes windows srcds to crash
public MRESReturn OnAllowedToHealTargetPre(int medigun, Handle hReturn, Handle hParams) {
	int target = DHookGetParam(hParams, 1);
	int owner = GetEntPropEnt(medigun, Prop_Send, "m_hOwnerEntity");
	PrevOwnerMedigun[medigun] = owner;
	float What_type_Heal = Attributes_Get(medigun, 2046, 1.0);
	if(owner > 0 && owner<=MaxClients)
	{
		if(f_PreventMedigunCrashMaybe[owner] > GetGameTime())
		{
			DHookSetReturn(hReturn, false);
			return MRES_Supercede;			
		}
		if(IsValidEntity(target))
		{
			if(!b_MediunDamageModeSet[medigun] && (What_type_Heal == 1.0 || What_type_Heal == 5.0 || What_type_Heal == 6.0))
			{

				if (target > 0 && target <= MaxClients)
				{
					//dont heal downed targets that have left for dead.
#if defined ZR
					if(b_LeftForDead[target] && dieingstate[target] > 0)
#endif
					{
						DHookSetReturn(hReturn, false);
						return MRES_Supercede;		

					}
#if defined ZR
					return MRES_Ignored;
#endif
					//This is just normal code, let it be itself.
				}
				else if(b_ThisWasAnNpc[target] && !b_NpcHasDied[target] && GetTeam(target) == TFTeam_Red)
				{
					//when healing an npc, make sure they are alive, and ontop of that, make sure that they are on red team.
					DHookSetReturn(hReturn, true);
					return MRES_Supercede;
				}
				else
				{
					DHookSetReturn(hReturn, false);
					return MRES_Supercede;				
				}
			}
			else if(target > MaxClients && b_MediunDamageModeSet[medigun])
			{
				//when having a medigun that atttacks enemies, make sure that it only targets enemy alive npcs.
				if(b_ThisWasAnNpc[target] && !b_NpcHasDied[target] && GetTeam(target) != TFTeam_Red)
				{
					DHookSetReturn(hReturn, true);
					return MRES_Supercede;
				}
			}
		}
		DHookSetReturn(hReturn, false);
		return MRES_Supercede;
	}
	else
	{
		DHookSetReturn(hReturn, false);
		return MRES_Supercede;		
	}
}

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
#define UBERCHARGE_BUFFDURATION 1.0

public void GiveMedigunBuffUber(int medigun, int owner, int receiver)
{
	NPCStats_RemoveAllDebuffs(receiver, UBERCHARGE_BUFFDURATION);
	switch(i_CustomWeaponEquipLogic[medigun])
	{
		case WEAPON_KRITZKRIEG:
		{
			if(IsValidClient(receiver))
			{
				
#if defined ZR
				Kritzkrieg_Magical(receiver, 0.05, true);
#endif
				TF2_AddCondition(receiver, TFCond_Kritzkrieged, UBERCHARGE_BUFFDURATION);
			}
			ApplyStatusEffect(owner, receiver, "Weapon Overclock", UBERCHARGE_BUFFDURATION);
		}
		default:
		{
			if(IsValidClient(receiver))
			{
				TF2_AddCondition(receiver, TFCond_UberBulletResist, UBERCHARGE_BUFFDURATION);
				TF2_AddCondition(receiver, TFCond_UberBlastResist, UBERCHARGE_BUFFDURATION);
				TF2_AddCondition(receiver, TFCond_UberFireResist, UBERCHARGE_BUFFDURATION);
			}
			ApplyStatusEffect(owner, receiver, "UBERCHARGED", UBERCHARGE_BUFFDURATION);
		}
	}
}
public MRESReturn OnMedigunPostFramePost(int medigun) {
	int owner = GetEntPropEnt(medigun, Prop_Send, "m_hOwnerEntity");
	if(medigun_heal_delay[owner] < GetGameTime())
	{
		if(GetEntProp(medigun, Prop_Send, "m_bChargeRelease"))
		{
			GiveMedigunBuffUber(medigun, owner, owner);
		}
		medigun_heal_delay[owner] = GetGameTime() + 0.1;
		int healTarget = GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
		
		float What_type_Heal = Attributes_Get(medigun, 2046, 1.0);
		if(b_MediunDamageModeSet[medigun])
		{
			//We hurt enemies, make sure all valid checks are the same as before.
			if(IsValidEntity(healTarget) && healTarget>MaxClients && GetAmmo(owner, 21) > 0 && b_ThisWasAnNpc[healTarget] && !b_NpcHasDied[healTarget] && GetTeam(healTarget) != TFTeam_Red)
			{
				bool team = GetTeam(owner)==GetTeam(healTarget);
				float flDrainRate = 500.0;
				if (b_thisNpcIsARaid[healTarget])
				{
					flDrainRate *= 0.65;
				}
				
				if(!TF2_IsPlayerInCondition(owner, TFCond_MegaHeal))
					MedigunChargeUber(owner, medigun, 1.0);
				
				if (!team)
				{
					float AttributeRate = Attributes_GetOnWeapon(owner, medigun, 8, true);
					AttributeRate *= Attributes_Get(medigun, 7, 1.0); //Extra damage
					flDrainRate *= AttributeRate; // We have to make it more exponential, damage scales much harder.
					target_sucked_long[healTarget] += 0.10;
				
					if(target_sucked_long[healTarget] >= 4.0)
					{
						target_sucked_long[healTarget] = 4.0;
					}
					
					if(Handle_on_target_sucked_long[healTarget])
					{
						delete Revert_target_sucked_long_timer[healTarget];
					}
					Revert_target_sucked_long_timer[healTarget] = CreateTimer(2.0, Reset_suck_bonus, healTarget, TIMER_FLAG_NO_MAPCHANGE);
					Handle_on_target_sucked_long[healTarget] = true;
					
					flDrainRate *= target_sucked_long[healTarget];
					
					static float Entity_Position[3];
					WorldSpaceCenter(healTarget, Entity_Position );
#if defined ZR
					AddHealthToUbersaw(owner, 1, 0.0005);
					HealPointToReinforce(owner, 1, 0.0005);
#endif		
					SDKHooks_TakeDamage(healTarget, medigun, owner, flDrainRate * GetGameFrameTime(), DMG_PLASMA, medigun, _, Entity_Position);
					
				}
			}
			if(medigun_hud_delay[owner] < GetGameTime())
			{
				PrintHintText(owner,"[DAMAGE MODE]");
				medigun_hud_delay[owner] = GetGameTime() + 0.5;
			}
		}
		else if(What_type_Heal == 1.0 || What_type_Heal == 5.0 || What_type_Heal == 6.0)
		{
			//we heal players or npcs, make sure we can heal them.
			if((IsValidClient(healTarget) && healTarget<=MaxClients && GetAmmo(owner, 21) > 0) || (IsValidEntity(healTarget) && !b_NpcHasDied[healTarget] && GetTeam(healTarget) == TFTeam_Red))
			{
				bool team = GetTeam(owner)==GetTeam(healTarget);
				if(team)
				{
					bool Is_Allied_Npc = false;
					MedigunChargeUber(owner, medigun, 1.0);
					
					float Healing_Value = Attributes_GetOnWeapon(owner, medigun, 8, true);
					
					float healing_Amount = Healing_Value;
					float healing_Amount_Self = Healing_Value;

					if(What_type_Heal == 5.0)
					{
						switch(MedigunModeSet[owner])
						{
							case 0:
							{
								ApplyStatusEffect(owner, owner, "Healing Adaptiveness Melee", 0.15);
								ApplyStatusEffect(owner, healTarget, "Healing Adaptiveness Melee", 0.15);
							}
							case 1:
							{
								ApplyStatusEffect(owner, owner, "Healing Adaptiveness Ranged", 0.15);
								ApplyStatusEffect(owner, healTarget, "Healing Adaptiveness Ranged", 0.15);
							}
						}
					}
#if defined ZR
					if(dieingstate[owner] == 0 && (Citizen_ThatIsDowned(healTarget) || healTarget <= MaxClients && dieingstate[healTarget] > 0))
					{
						if(healTarget <= MaxClients)
						{
							if(!b_LeftForDead[healTarget])
							{
								ReviveClientFromOrToEntity(healTarget, owner,_, 1);
							}
						}
						else
						{
							ReviveClientFromOrToEntity(healTarget, owner,_, 1);
						}
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

							Healing_GiveArmor *= Healing_Value;

							if(f_TimeUntillNormalHeal[healTarget] > GetGameTime())
							{
								Healing_GiveArmor *= 0.33;
							}
							if(i_targethealedLastBy[healTarget] != owner) //If youre healing someone thats already being healed, then the healing amount will be heavily reduced.
							{
								Healing_GiveArmor *= 0.33;
							}	
							if(healTarget <= MaxClients)
							{
								bool JustCuredArmor = false;
								if(Armor_Charge[healTarget] < 0)
								{
								//if under currosion. heal more
									JustCuredArmor = true;
									Healing_GiveArmor *= 4.0;
								}
								GiveArmorViaPercentage(healTarget, Healing_GiveArmor, 1.0, true,_,owner);

								if(JustCuredArmor && Armor_Charge[healTarget] > 0)
								{
									Armor_Charge[healTarget] = 0;
								}

							}
							else
							{
								GrantEntityArmor(healTarget, false, 0.25, 0.25, 0,
									flMaxHealth * Healing_GiveArmor, owner);
							}

							
							Healing_GiveArmor = 0.35;

							Healing_GiveArmor *= Healing_Value;

							if(f_TimeUntillNormalHeal[owner] > GetGameTime())
							{
								Healing_GiveArmor *= 0.25;
							}
							bool JustCuredArmor = false;
							if(Armor_Charge[owner] < 0)
							{
								//if under currosion. heal more
								JustCuredArmor = true;
								Healing_GiveArmor *= 4.0;
							}
							GiveArmorViaPercentage(owner, Healing_GiveArmor, 1.0, true,_,owner);
							
							if(JustCuredArmor && Armor_Charge[owner] > 0)
							{
								Armor_Charge[owner] = 0;
							}
						}
#endif

						i_targethealedLastBy[healTarget] = owner;
						//self heal
						HealEntityGlobal(owner, owner, healing_Amount_Self, 1.0, 0.0);

						//Ally Heal
						HealEntityGlobal(owner, healTarget, healing_Amount, flMaxHealth, 0.0);

						if(!b_NpcHasDied[healTarget])
						{
							Calculate_And_Display_hp(owner, healTarget, 0.0, true);
						}
						
						ApplyStatusEffect(owner, healTarget, "Healing Resolve", UBERCHARGE_BUFFDURATION);
						ApplyStatusEffect(owner, owner, "Healing Resolve", UBERCHARGE_BUFFDURATION);

						if(GetEntProp(medigun, Prop_Send, "m_bChargeRelease"))
						{
							GiveMedigunBuffUber(medigun, owner, healTarget);
						}

						if(i_CustomWeaponEquipLogic[medigun] == WEAPON_KRITZKRIEG)
						{
							ApplyStatusEffect(owner, healTarget, "Weapon Clocking", UBERCHARGE_BUFFDURATION);
							ApplyStatusEffect(owner, owner, "Weapon Clocking", UBERCHARGE_BUFFDURATION);
						}
					}
				}
				Set_HitDetectionCooldown(healTarget,owner, GetGameTime() + 0.25, SupportDisplayHurtHud);
			}
			if(medigun_hud_delay[owner] < GetGameTime())
			{
				if(What_type_Heal != 5.0)
				{
					PrintHintText(owner,"[HEALING MODE]");
				}
				else
				{
					switch(MedigunModeSet[owner])
					{
						case 0:
						{
							PrintHintText(owner,"[HEALING MODE]\nMode: Melee");
						}
						case 1:
						{
							PrintHintText(owner,"[HEALING MODE]\nMode: Ranged");
						}
					}
				}
				medigun_hud_delay[owner] = GetGameTime() + 0.5;
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
	if(IsInvuln(owner))
		return;
		
	if(GetEntProp(medigun, Prop_Send, "m_bChargeRelease"))
		return;

	float flChargeLevel = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");

	float HeatExtra = 0.10;
	
	HeatExtra *= TickrateModify; //incase tickrate is different.

	if(RespectUberDuration)
		HeatExtra = HeatExtra / MedigunGetUberDuration(owner);
	float UberchargeRate = Attributes_GetOnWeapon(owner, medigun, 9, true);

	if(UberchargeRate > 0.0 || UberchargeRate == -1.0)
		HeatExtra *= (UberchargeRate == -1.0 ? 0.0 : UberchargeRate);
		
	UberchargeRate = Attributes_GetOnWeapon(owner, medigun, 10, true);
	if(UberchargeRate > 0.0 || UberchargeRate == -1.0)
		HeatExtra *= (UberchargeRate == -1.0 ? 0.0 : UberchargeRate);
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
	//only swithc with crouch R
	if((GetClientButtons(client) & IN_DUCK))
	{
		ClientCommand(client, "playgamesound weapons/vaccinator_toggle.wav");
		MedigunModeSet[client]++;
		if(MedigunModeSet[client] > 1)
		{
			MedigunModeSet[client] = 0;
		}
		return;
	}
	MedigunChangeModeRInternal(client, weapon, crit, slot, true);
}


public void ReduceMediFluidCost(int client, int &cost)
{
	float Attribute = Attributes_GetOnPlayer(client, Attrib_ReduceMedifluidCost, true, true);
	if(Attribute == 1.0 || Attribute == 0.0)
	{
		return;
	}
	cost = RoundToNearest(float(cost) * Attribute);
	if(cost <= 1)
		cost = 1;
}

public void ReduceMetalCost(int client, int &cost)
{
	float Attribute = Attributes_GetOnPlayer(client, Attrib_ReduceMetalCost, true, false, 1.0); //Tinker needs to check weapons too!
	if(Attribute == 1.0 || Attribute == 0.0)
	{
		return;
	}
	cost = RoundToNearest(float(cost) * Attribute);
	if(cost <= 1)
		cost = 1;
}