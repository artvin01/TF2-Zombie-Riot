#pragma semicolon 1
#pragma newdecls required
//

#define MAX_EXPI_ENERGY_EFFECTS 26



#if defined ZR
float f_HealCooldownSetDoGlobal[MAXENTITIES];
int i_ExpidonsaEnergyEffect[MAXENTITIES][MAX_EXPI_ENERGY_EFFECTS];
int i_ExpidonsaShieldCapacity[MAXENTITIES];
int i_ExpidonsaShieldCapacity_Mini[MAXENTITIES];
int i_Expidonsa_ShieldEffect[MAXENTITIES];
float f_Expidonsa_ShieldBroke[MAXENTITIES];
bool EnemyShieldCantBreak[MAXENTITIES];

stock void ExpidonsaRemoveEffects(int iNpc)
{
	for(int loop = 0; loop<MAX_EXPI_ENERGY_EFFECTS; loop++)
	{
		int entity = EntRefToEntIndex(i_ExpidonsaEnergyEffect[iNpc][loop]);
		if(IsValidEntity(entity))
		{
			RemoveEntity(entity);
		}
		i_ExpidonsaEnergyEffect[iNpc][loop] = INVALID_ENT_REFERENCE;
	}
}

void Expidonsa_SetToZero(int iNpc)
{
	f_HealCooldownSetDoGlobal[iNpc] = 0.0;
	f_Expidonsa_ShieldBroke[iNpc] = 0.0;
	i_ExpidonsaShieldCapacity[iNpc] = 0;
	i_ExpidonsaShieldCapacity_Mini[iNpc] = 0;
	VausMagicaRemoveShield(iNpc);
	EnemyShieldCantBreak[iNpc] = false;
}
bool ExpidonsaDepletedShieldShow(int victim)
{
	//false means delete shield.
	if(b_thisNpcIsARaid[victim])
		return false;
	
	if(ExpidonsanShieldBroke(victim) > GetGameTime())
	{
		if(IsValidEntity(i_Expidonsa_ShieldEffect[victim]))
		{
			int Shield = EntRefToEntIndex(i_Expidonsa_ShieldEffect[victim]);
			SetEntityRenderColor(Shield, 50, 50, 50, 50);	
			SetEntityRenderFx(Shield, RENDERFX_FLICKER_FAST);
		}
		return true;
	}
	else
	{
		return false;
	}
}
stock bool VausMagicaShieldLogicEnabled(int victim)
{
	if(i_ExpidonsaShieldCapacity[victim] > 0)
		return true;

	return false;
}
stock int VausMagicaShieldLeft(int victim)
{
	return i_ExpidonsaShieldCapacity[victim];
}
void VausMagicaShieldLogicNpcOnTakeDamage(int attacker, int victim, float &damage,int damagetype, int ZrDamageType, int weapon)
{
	if(i_ExpidonsaShieldCapacity[victim] > 0)
	{
		bool DrainShield = true;
		if(IsEntitySentrygun(attacker))
			DrainShield = false;
		
		if((ZrDamageType & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
			DrainShield = false;
		
		if(!CheckInHud() && DrainShield)
		{
#if defined ZR
			if(HasSpecificBuff(victim, "Zilius Prime Technology") || attacker <= MaxClients && TeutonType[attacker] != TEUTON_NONE || (weapon > MaxClients && i_CustomWeaponEquipLogic[weapon] == WEAPON_MG42))
#else
			if(attacker <=MaxClients)
#endif
			{
				i_ExpidonsaShieldCapacity_Mini[victim]++;
				if(i_ExpidonsaShieldCapacity_Mini[victim] <= 1)
					return;

				i_ExpidonsaShieldCapacity_Mini[victim] = 0;
				i_ExpidonsaShieldCapacity[victim] -= 1;
			}
			else
			{
				i_ExpidonsaShieldCapacity[victim] -= 1;
			}
		}

		if(!(damagetype & (DMG_TRUEDAMAGE)))
			damage *= 0.25;
			
		if(!CheckInHud())
		{
			if(i_ExpidonsaShieldCapacity[victim] <= 0)
			{
				if(!EnemyShieldCantBreak[victim])
					f_Expidonsa_ShieldBroke[victim] = GetGameTime() + 5.0;

				VausMagicaRemoveShield(victim);
			}
			else
			{
				VausMagicaGiveShield(victim, 0); //update shield ocapacity
			}
		}
	}
}
#define DEFAULTMAXRAID_SHIELDCAP 250
void VausMagicaGiveShield(int entity, int amount, bool ignorecooldown = false)
{
	float CapacityMaxMulti = float(CountPlayersOnRed(_, true)) / 7.0;
	int MaxShieldCapacity = RoundToNearest(5.0 * CapacityMaxMulti);
	if(b_thisNpcIsABoss[entity])
	{
		MaxShieldCapacity = RoundToNearest(10.0 * CapacityMaxMulti);
	}
	if(b_thisNpcIsARaid[entity])
	{
		MaxShieldCapacity = DEFAULTMAXRAID_SHIELDCAP;
		if(amount >= DEFAULTMAXRAID_SHIELDCAP)
			MaxShieldCapacity = amount;
		if(Construction_Mode())
			MaxShieldCapacity = 99999999; //no limit.
	}
	if(HasSpecificBuff(entity, "Zilius Prime Technology"))
	{
		MaxShieldCapacity *= 2;
	}
	if(MaxShieldCapacity < 1)
		MaxShieldCapacity = 1;

	if((f_Expidonsa_ShieldBroke[entity] > GetGameTime() && !ignorecooldown) && MaxShieldCapacity < DEFAULTMAXRAID_SHIELDCAP)
	{
		return; //do not give shield.
	}
	i_ExpidonsaShieldCapacity[entity] += amount;
	if(i_ExpidonsaShieldCapacity[entity] >= MaxShieldCapacity)
	{
		i_ExpidonsaShieldCapacity[entity] = MaxShieldCapacity;
	}
	int alpha = i_ExpidonsaShieldCapacity[entity];
	alpha = alpha * 20;
	if(alpha > 255)
	{
		alpha = 255;
	}
	CClotBody npc = view_as<CClotBody>(entity);
	if(IsValidEntity(i_Expidonsa_ShieldEffect[entity]))
	{
		int Shield = EntRefToEntIndex(i_Expidonsa_ShieldEffect[entity]);
		SetEntityRenderFx(Shield, RENDERFX_NONE);
		if(npc.m_iBleedType == BLEEDTYPE_VOID)
		{
			SetEntityRenderColor(Shield, 255, 0, 255, alpha);	
		}
		else
		{
			SetEntityRenderColor(Shield, 255, 255, 255, alpha);	
		}
		return;
	}
	int Shield = npc.EquipItem("", "models/effects/resist_shield/resist_shield.mdl");

	if(b_IsGiant[entity])
		SetVariantString("1.35");
	else
		SetVariantString("1.0");

	AcceptEntityInput(Shield, "SetModelScale");
	if(alpha == 255)
		SetEntityRenderMode(Shield, RENDER_NORMAL);
	else
		SetEntityRenderMode(Shield, RENDER_TRANSCOLOR);
	
	SetEntityRenderFx(Shield, RENDERFX_NONE);
	if(npc.m_iBleedType == BLEEDTYPE_VOID)
	{
		SetEntProp(Shield, Prop_Send, "m_nSkin", 1);
		SetEntityRenderColor(Shield, 255, 0, 255, alpha);	
	}
	else
	{
		SetEntProp(Shield, Prop_Send, "m_nSkin", 1);
		SetEntityRenderColor(Shield, 255, 255, 255, alpha);	
	}

	i_Expidonsa_ShieldEffect[entity] = EntIndexToEntRef(Shield);
}

void VausMagicaRemoveShield(int entity, bool force = false)
{
	if(!IsValidEntity(i_Expidonsa_ShieldEffect[entity]))
		return;
		
	if(!force && VausMagicaShieldLeft(entity) >= 1)
		return;

	if(force || !ExpidonsaDepletedShieldShow(entity))
	{
		RemoveEntity(EntRefToEntIndex(i_Expidonsa_ShieldEffect[entity]));
		i_Expidonsa_ShieldEffect[entity] = INVALID_ENT_REFERENCE;
	}
}
#endif


float f_Expidonsa_HealingAmmount[MAXENTITIES];
int i_Expidonsa_HealingCount[MAXENTITIES];
float f_Expidonsa_HealingOverheal[MAXENTITIES];
bool b_Expidonsa_Selfheal[MAXENTITIES];
Function func_Expidonsa_Heal_After[MAXENTITIES] = {INVALID_FUNCTION, ...};
Function func_Expidonsa_Heal_Before[MAXENTITIES] = {INVALID_FUNCTION, ...};
bool DontAllowAllyHeal[MAXENTITIES];
stock void ExpidonsaGroupHeal(int HealingNpc, float RangeDistance, int MaxAlliesHealed, float HealingAmmount,
 float Expidonsa_HealingOverheal, bool Selfheal, Function Function_HealBefore = INVALID_FUNCTION , Function Function_HealAfter = INVALID_FUNCTION, bool AnyHeal = false, bool LOS = true)
{
	b_Expidonsa_Selfheal[HealingNpc] = Selfheal;
	i_Expidonsa_HealingCount[HealingNpc] = MaxAlliesHealed;
	f_Expidonsa_HealingAmmount[HealingNpc] = HealingAmmount;
	f_Expidonsa_HealingOverheal[HealingNpc] = Expidonsa_HealingOverheal;
	func_Expidonsa_Heal_Before[HealingNpc] = Function_HealBefore;
	func_Expidonsa_Heal_After[HealingNpc] = Function_HealAfter;
	DontAllowAllyHeal[HealingNpc] = AnyHeal;

	b_NpcIsTeamkiller[HealingNpc] = true;
	Explode_Logic_Custom(0.0,
	HealingNpc,
	HealingNpc,
	-1,
	_,
	RangeDistance,
	_,
	_,
	LOS,
	99,
	false,
	_,
	Expidonsa_AllyHeal);
	b_NpcIsTeamkiller[HealingNpc] = false;
}

static void Expidonsa_AllyHeal(int HealerNpc, int victim, float damage, int weapon)
{
	if(HealerNpc == victim)
	{
		if(b_Expidonsa_Selfheal[HealerNpc])
		{
			if(GetTeam(HealerNpc) == TFTeam_Red)
			{
				i_Expidonsa_HealingCount[HealerNpc] += 1;
				Expidonsa_AllyHealInternal(HealerNpc, victim, f_Expidonsa_HealingAmmount[HealerNpc] * 0.05);
			}
			else
			{
				i_Expidonsa_HealingCount[HealerNpc] += 1;
				Expidonsa_AllyHealInternal(HealerNpc, victim, f_Expidonsa_HealingAmmount[HealerNpc]);
			}
		}
		return;
	}
	if(i_Expidonsa_HealingCount[HealerNpc] <= 0)
	{
		return;
	}
	//cant heal enemies.
	if(GetTeam(HealerNpc) != GetTeam(victim) && !DontAllowAllyHeal[HealerNpc])
		return;

	//team red, npc or 
	if((!DontAllowAllyHeal[HealerNpc] && GetTeam(HealerNpc) == TFTeam_Red && (!b_NpcHasDied[victim] || victim <= MaxClients)) ||
	 (DontAllowAllyHeal[HealerNpc] && GetTeam(victim) == TFTeam_Red && (!b_NpcHasDied[victim] || victim <= MaxClients)))
	{
		Expidonsa_AllyHealInternal(HealerNpc, victim, f_Expidonsa_HealingAmmount[HealerNpc] * 0.05);
	}
	else
	{
		if (!i_IsABuilding[victim] && !b_NpcHasDied[victim])
		{
			Expidonsa_AllyHealInternal(HealerNpc, victim, f_Expidonsa_HealingAmmount[HealerNpc]);
		}
	}
}

static void Expidonsa_AllyHealInternal(int HealerNpc, int victim, float heal)
{
	bool CancelHeal = false;
	Function func = func_Expidonsa_Heal_Before[HealerNpc];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(HealerNpc);
		Call_PushCell(victim);
		Call_PushFloatRef(heal);
		Call_Finish(CancelHeal);
	}
	if(CancelHeal)
		return;

	int HealingDone = HealEntityGlobal(HealerNpc, victim, heal, f_Expidonsa_HealingOverheal[HealerNpc],_,_);
	if(HealingDone <= 0)
		return;
	
	i_Expidonsa_HealingCount[HealerNpc] -= 1;
	Function func2 = func_Expidonsa_Heal_After[HealerNpc];
	if(func2 && func2 != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func2);
		Call_PushCell(HealerNpc);
		Call_PushCell(victim);
		Call_Finish();
	}
}
stock bool Expidonsa_DontHealSameIndex(int entity, int victim, float &healingammount)
{
	if(i_NpcInternalId[entity] == i_NpcInternalId[victim])
		return true;

	return false;
}
#if defined ZR
#define IBERIA_BARRACKS_COOLDOWN_HEAL 2.0
stock bool IberiaBarracks_HealSelfLimitCD(int entity, int victim, float &healingammount)
{
	if(f_HealCooldownSetDoGlobal[victim] > GetGameTime())
		return true;

	f_HealCooldownSetDoGlobal[victim] = GetGameTime() + IBERIA_BARRACKS_COOLDOWN_HEAL;

	return false;
}
float ExpidonsanShieldBroke(int entity)
{
	return(f_Expidonsa_ShieldBroke[entity]);
}
#endif