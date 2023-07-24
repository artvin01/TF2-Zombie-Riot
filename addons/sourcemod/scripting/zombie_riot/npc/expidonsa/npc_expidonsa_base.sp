#pragma semicolon 1
#pragma newdecls required

int i_ExpidonsaEnergyEffect[MAXENTITIES][10];

void ExpidonsaRemoveEffects(int iNpc)
{
	for(int loop = 0; loop<10; loop++)
	{
		int entity = EntRefToEntIndex(i_ExpidonsaEnergyEffect[iNpc][loop]);
		if(IsValidEntity(entity))
		{
			RemoveEntity(entity);
		}
	}
}