#pragma semicolon 1
#pragma newdecls required

float f_Actualm_flNextPrimaryAttack[MAXENTITIES];

int i_EmptyBulletboop[MAXPLAYERS];

public void SemiAutoWeapon(int client, int buttons)
{
	static int holding_semiauto[MAXPLAYERS];
	if(buttons & IN_ATTACK)
	{
		if(!holding_semiauto[client])
		{
			int entity = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(IsValidEntity(entity))
			{
				if(i_SemiAutoWeapon[entity])
				{
					if(i_SemiAutoWeapon_AmmoCount[entity] > 0)
					{
						if(f_Actualm_flNextPrimaryAttack[entity] <= GetGameTime())
						{
							float Fire_rate = f_SemiAutoStats_FireRate[entity];
							
							Fire_rate *= Attributes_Get(entity, 6, 1.0);
		
							
							SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + Fire_rate);
							SetEntPropFloat(entity, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + Fire_rate);
							
							Attributes_Set(entity, 821, 1.0);
							holding_semiauto[client] = true;
						}
					}
					else
					{
						if(f_Actualm_flNextPrimaryAttack[entity] <= GetGameTime())
						{
							if(i_EmptyBulletboop[client] == 2)
							{
								SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + 0.2);
								SetEntPropFloat(entity, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.2);
								holding_semiauto[client] = true;
								EmitSoundToAll("weapons/shotgun_empty.wav", client, _, 70);
								Attributes_Set(entity, 821, 1.0);
								Reload_Me(client);
								i_EmptyBulletboop[client] = 0;
							}
							else if(i_EmptyBulletboop[client] == 1)
							{
								SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + 0.2);
								SetEntPropFloat(entity, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.2);
								holding_semiauto[client] = true;
								EmitSoundToAll("weapons/shotgun_empty.wav", client, _, 70);
								Attributes_Set(entity, 821, 1.0);
								i_EmptyBulletboop[client] += 1;
							}
							else
							{
								SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + 0.2);
								SetEntPropFloat(entity, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.2);
								holding_semiauto[client] = true;
								Attributes_Set(entity, 821, 1.0);
								i_EmptyBulletboop[client] = 1;
							}
						}
					}
				}
			}
		}
	}
	else
	{
		if(holding_semiauto[client])
		{
			int entity = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(IsValidEntity(entity))
			{
				if(i_SemiAutoWeapon[entity])
				{
					if(i_SemiAutoWeapon_AmmoCount[entity] > 0)
					{
						Attributes_Set(entity, 821, 0.0);
					}
				}
				holding_semiauto[client] = false;
			}
		}
	}
	static int holding_semiauto_reload[MAXPLAYERS];
	if(buttons & IN_RELOAD)
	{
		if(!holding_semiauto_reload[client])
		{
			Reload_Me(client);
			holding_semiauto_reload[client] = true;
		}
	}
	else
	{
		holding_semiauto_reload[client] = false;
	}
}

void Reload_Me(int client)
{
	int entity = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(IsValidEntity(entity))
	{
		if(i_SemiAutoWeapon[entity])
		{
			if(f_Actualm_flNextPrimaryAttack[entity] <= GetGameTime())
			{
				if(i_SemiAutoWeapon_AmmoCount[entity] < i_SemiAutoStats_MaxAmmo[entity])
				{
					i_SemiAutoWeapon_AmmoCount[entity] = i_SemiAutoStats_MaxAmmo[entity];
					
					
					DoReloadAnimation(client, entity);
						
					float Reload_Rate = f_SemiAutoStats_ReloadTime[entity];
						
					Reload_Rate *= Attributes_Get(entity, 97, 1.0);
	
						
					SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + Reload_Rate);
					SetEntPropFloat(entity, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + Reload_Rate);
							
					ShowClientManualAmmoCount(client, entity);
					Attributes_Set(entity, 821, 0.0);
					
				}
			}
		}	
	}
}

void ShowClientManualAmmoCount(int client, int weapon)
{
	char buffer[128];
	for(int i; i < i_SemiAutoWeapon_AmmoCount[weapon]; i++)
	{
		buffer[i] = '|';
	}

	PrintHintText(client, buffer);
	
}
/*
DataPack pack = new DataPack();
pack.WriteCell(EntIndexToEntRef(entity));
pack.WriteCell(EntIndexToEntRef(client));
pack.WriteFloat(Fire_rate);
RequestFrame(ApplyPrimaryAttackDelay, pack);
													
void ApplyPrimaryAttackDelay(DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell());
	float FireRate = pack.ReadFloat();
	
	if(IsValidEntity(entity) && IsValidClient(client))
	{
		SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + FireRate);
		SetEntPropFloat(entity, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + FireRate);
	}
	delete pack;
}
*/
//int animation_count_up;

void DoReloadAnimation(int attacker, int entity)
{
	
//	animation_count_up += 1;
	
	
	
	int viewmodel = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
	int melee = GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
	if(viewmodel>MaxClients && IsValidEntity(viewmodel))
	{
		int animation = 1;
		switch(melee)
		{
			case 199,1004,141,1141: 
				animation=6;
			
			case 449,773:
				animation = 20;
		}
	//	PrintToChatAll("%i",animation_count_up
		SetEntProp(viewmodel, Prop_Send, "m_nSequence", animation);
	}
	
}