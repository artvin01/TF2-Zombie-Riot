#pragma semicolon 1
#pragma newdecls required
//
#define MAX_EXPI_ENERGY_EFFECTS 71

int i_ExpidonsaEnergyEffect[MAXENTITIES][MAX_EXPI_ENERGY_EFFECTS];
int i_ExpidonsaShieldCapacity[MAXENTITIES];
int i_Expidonsa_ShieldEffect[MAXENTITIES];
float f_Expidonsa_ShieldBroke[MAXENTITIES];
bool b_ExpidonsaWasAttackingNonPlayer;

void ExpidonsaRemoveEffects(int iNpc)
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
	VausMagicaRemoveShield(iNpc);
}

bool VausMagicaShieldLogicEnabled(int victim)
{
	if(i_ExpidonsaShieldCapacity[victim] > 0)
		return true;

	return false;
}
int VausMagicaShieldLeft(int victim)
{
	return i_ExpidonsaShieldCapacity[victim];
}
void VausMagicaShieldLogicNpcOnTakeDamage(int victim, float &damage, int damagetype, int ZrDamageType)
{
	if(i_ExpidonsaShieldCapacity[victim] > 0 && (!(ZrDamageType & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED)))
	{
		i_ExpidonsaShieldCapacity[victim] -= 1;

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
		MaxShieldCapacity = 999;
	}
	if(f_Expidonsa_ShieldBroke[entity] > GetGameTime() && MaxShieldCapacity < 999)
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

