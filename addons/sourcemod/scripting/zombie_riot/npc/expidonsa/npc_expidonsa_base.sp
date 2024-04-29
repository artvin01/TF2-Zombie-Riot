#pragma semicolon 1
#pragma newdecls required
//

#define MAX_EXPI_ENERGY_EFFECTS 71

int i_ExpidonsaEnergyEffect[MAXENTITIES][MAX_EXPI_ENERGY_EFFECTS];
int i_ExpidonsaShieldCapacity[MAXENTITIES];
int i_ExpidonsaShieldCapacity_Mini[MAXENTITIES];
int i_Expidonsa_ShieldEffect[MAXENTITIES];
float f_Expidonsa_ShieldBroke[MAXENTITIES];

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
	f_Expidonsa_ShieldBroke[iNpc] = 0.0;
	i_ExpidonsaShieldCapacity[iNpc] = 0;
	i_ExpidonsaShieldCapacity_Mini[iNpc] = 0;
	VausMagicaRemoveShield(iNpc);
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
void VausMagicaShieldLogicNpcOnTakeDamage(int attacker, int victim, float &damage, int damagetype, int ZrDamageType)
{
	if(i_ExpidonsaShieldCapacity[victim] > 0 && (!(ZrDamageType & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED)))
	{
#if defined ZR
		if(attacker <=MaxClients && TeutonType[attacker] != TEUTON_NONE)
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

		if(!(damagetype & DMG_SLASH))
			damage *= 0.25;

		if(i_ExpidonsaShieldCapacity[victim] <= 0)
		{
			f_Expidonsa_ShieldBroke[victim] = GetGameTime() + 5.0;
			VausMagicaRemoveShield(victim);
		}
		else
		{
			VausMagicaGiveShield(victim, 0); //update shield ocapacity
		}
	}
}

void VausMagicaGiveShield(int entity, int amount)
{
	int MaxShieldCapacity = 5;
	if(b_thisNpcIsABoss[entity])
	{
		MaxShieldCapacity = 10;
	}
	if(b_thisNpcIsARaid[entity])
	{
		MaxShieldCapacity = 250;
	}
	if(f_Expidonsa_ShieldBroke[entity] > GetGameTime() && MaxShieldCapacity < 250)
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
	if(IsValidEntity(i_Expidonsa_ShieldEffect[entity]))
	{
		int Shield = EntRefToEntIndex(i_Expidonsa_ShieldEffect[entity]);
		SetEntityRenderMode(Shield, RENDER_TRANSCOLOR);
		SetEntityRenderColor(Shield, 255, 255, 255, alpha);
		return;
	}

	CClotBody npc = view_as<CClotBody>(entity);
	int Shield = npc.EquipItem("root", "models/effects/resist_shield/resist_shield.mdl");
	if(b_IsGiant[entity])
		SetVariantString("1.35");
	else
		SetVariantString("1.0");

	AcceptEntityInput(Shield, "SetModelScale");
	SetEntityRenderMode(Shield, RENDER_TRANSCOLOR);
	
	SetEntityRenderColor(Shield, 255, 255, 255, alpha);
	SetEntProp(Shield, Prop_Send, "m_nSkin", 1);

	i_Expidonsa_ShieldEffect[entity] = EntIndexToEntRef(Shield);
}

void VausMagicaRemoveShield(int entity)
{
	if(!IsValidEntity(i_Expidonsa_ShieldEffect[entity]))
		return;

	RemoveEntity(EntRefToEntIndex(i_Expidonsa_ShieldEffect[entity]));
	i_Expidonsa_ShieldEffect[entity] = INVALID_ENT_REFERENCE;
}


float f_Expidonsa_HealingAmmount[MAXENTITIES];
int i_Expidonsa_HealingCount[MAXENTITIES];
float f_Expidonsa_HealingOverheal[MAXENTITIES];
bool b_Expidonsa_Selfheal[MAXENTITIES];
Function func_Expidonsa_Heal_After[MAXENTITIES] = {INVALID_FUNCTION, ...};
Function func_Expidonsa_Heal_Before[MAXENTITIES] = {INVALID_FUNCTION, ...};
stock void ExpidonsaGroupHeal(int HealingNpc, float RangeDistance, int MaxAlliesHealed, float HealingAmmount,
 float Expidonsa_HealingOverheal, bool Selfheal, Function Function_HealBefore = INVALID_FUNCTION , Function Function_HealAfter = INVALID_FUNCTION)
{
	b_Expidonsa_Selfheal[HealingNpc] = Selfheal;
	i_Expidonsa_HealingCount[HealingNpc] = MaxAlliesHealed;
	f_Expidonsa_HealingAmmount[HealingNpc] = HealingAmmount;
	f_Expidonsa_HealingOverheal[HealingNpc] = Expidonsa_HealingOverheal;
	func_Expidonsa_Heal_Before[HealingNpc] = Function_HealBefore;
	func_Expidonsa_Heal_After[HealingNpc] = Function_HealAfter;

	b_NpcIsTeamkiller[HealingNpc] = true;
	Explode_Logic_Custom(0.0,
	HealingNpc,
	HealingNpc,
	-1,
	_,
	RangeDistance,
	_,
	_,
	true,
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
	if(GetTeam(HealerNpc) != GetTeam(victim))
		return;

	//team red, npc or 
	if(GetTeam(HealerNpc) == TFTeam_Red && (!b_NpcHasDied[victim] || victim <= MaxClients))
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
		Call_Finish(CancelHeal);
	}
	if(CancelHeal)
		return;

	int HealingDone = HealEntityGlobal(HealerNpc, victim, heal, f_Expidonsa_HealingOverheal[HealerNpc],_,_);
	if(HealingDone <= 0)
		return;
	
	i_Expidonsa_HealingCount[HealerNpc] -= 1;
	float ProjLoc[3];
	GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", ProjLoc);
	ProjLoc[2] += 100.0;
	TE_Particle("healthgained_blu", ProjLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	Function func2 = func_Expidonsa_Heal_After[HealerNpc];
	if(func2 && func2 != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func2);
		Call_PushCell(HealerNpc);
		Call_PushCell(victim);
		Call_Finish();
	}
}
stock bool Expidonsa_DontHealSameIndex(int entity, int victim)
{
	if(i_NpcInternalId[entity] == i_NpcInternalId[victim])
		return true;

	return false;
}