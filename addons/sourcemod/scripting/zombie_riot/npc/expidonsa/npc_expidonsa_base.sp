#pragma semicolon 1
#pragma newdecls required
#define MAX_EXPI_ENERGY_EFFECTS 20

int i_ExpidonsaEnergyEffect[MAXENTITIES][MAX_EXPI_ENERGY_EFFECTS];
int i_ExpidonsaShieldCapacity[MAXENTITIES];
int i_Expidonsa_ShieldEffect[MAXENTITIES];

void ExpidonsaRemoveEffects(int iNpc)
{
	for(int loop = 0; loop<MAX_EXPI_ENERGY_EFFECTS; loop++)
	{
		int entity = EntRefToEntIndex(i_ExpidonsaEnergyEffect[iNpc][loop]);
		if(IsValidEntity(entity))
		{
			RemoveEntity(entity);
		}
	}
}

void Expidonsa_SetToZero(int iNpc)
{
	i_ExpidonsaShieldCapacity[iNpc] = 0;
	VausMagicaRemoveShield(iNpc);
}


void VausMagicaShieldLogicNpcOnTakeDamage(int victim, float &damage)
{
	if(i_ExpidonsaShieldCapacity[victim] > 0)
	{
		i_ExpidonsaShieldCapacity[victim] -= 1;
		damage *= 0.25;
		if(i_ExpidonsaShieldCapacity[victim] <= 0)
		{
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
	i_ExpidonsaShieldCapacity[entity] += amount;
	if(i_ExpidonsaShieldCapacity[entity] >= 50)
	{
		i_ExpidonsaShieldCapacity[entity] = 50;
	}
	int alpha = i_ExpidonsaShieldCapacity[entity];
	alpha = alpha * 10;
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
}

