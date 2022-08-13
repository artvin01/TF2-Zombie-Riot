float f_Actualm_flNextPrimaryAttack[MAXENTITIES];

public void SemiAutoWeapon(int client, int buttons)
{
	static int holding_semiauto[MAXTF2PLAYERS];
	if(buttons & IN_ATTACK)
	{
		if(!holding_semiauto[client])
		{
			int entity = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(i_SemiAutoWeapon[entity])
			{
				char classname[64];
				GetEntityClassname(entity, classname, sizeof(classname));
				int slot = TF2_GetClassnameSlot(classname);
				if(i_SemiAutoWeapon_AmmoCount[client][slot] >= 0)
				{
					if(f_Actualm_flNextPrimaryAttack[entity] <= GetGameTime())
					{
						SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + 0.35);
						SetEntPropFloat(entity, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.35);
						PrintToChatAll("boo22");
						DataPack pack = new DataPack();
						pack.WriteCell(EntIndexToEntRef(entity));
						pack.WriteCell(EntIndexToEntRef(client));
						RequestFrame(ApplyPrimaryAttackDelay, pack);
						TF2Attrib_SetByDefIndex(entity, 821, 1.0);
						holding_semiauto[client] = true;
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
			if(i_SemiAutoWeapon[entity])
			{
				char classname[64];
				GetEntityClassname(entity, classname, sizeof(classname));
				int slot = TF2_GetClassnameSlot(classname);
			
				
				if(i_SemiAutoWeapon_AmmoCount[client][slot] > 0)
				{
					PrintToChatAll("Can attack again!");
					TF2Attrib_SetByDefIndex(entity, 821, 0.0);
				}
				else
				{
					PrintToChatAll("need reload");
				}
			}
			holding_semiauto[client] = false;
		}
	}
	
	if(buttons & IN_RELOAD)
	{
		int entity = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(i_SemiAutoWeapon[entity])
		{
			if(f_Actualm_flNextPrimaryAttack[entity] <= GetGameTime())
			{
				char classname[64];
				GetEntityClassname(entity, classname, sizeof(classname));
				int slot = TF2_GetClassnameSlot(classname);
				
				if(i_SemiAutoWeapon_AmmoCount[client][slot] < 10)
				{
					
					i_SemiAutoWeapon_AmmoCount[client][slot] = 10;
					
					DoReloadAnimation(client, slot);
						
					SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + 2.0);
					SetEntPropFloat(entity, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 2.0);
					TF2Attrib_SetByDefIndex(entity, 821, 0.0);
				}
			}
		}
	}
}

void ApplyPrimaryAttackDelay(DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell());
	
	if(IsValidEntity(entity) && IsValidClient(client))
	{
		SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + 0.35);
		SetEntPropFloat(entity, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.35);
	}
	delete pack;
}

void DoReloadAnimation(int attacker, int slot)
{
	int viewmodel = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
	int melee = GetIndexOfWeaponSlot(attacker, slot);
	if(viewmodel>MaxClients && IsValidEntity(viewmodel))
	{
		int animation = 1;
		switch(melee)
		{
			case 199,1004,141: 
				animation=6;
		}
		SetEntProp(viewmodel, Prop_Send, "m_nSequence", animation);
	}
	
}