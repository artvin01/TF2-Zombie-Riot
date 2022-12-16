#pragma semicolon 1
#pragma newdecls required

bool Attributes_Fire(int client, int weapon)
{
	int clip = GetEntProp(weapon, Prop_Data, "m_iClip1");
	if(clip > 0)
	{
		float gameTime = GetGameTime();
		if(gameTime < GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack"))
		{
			float value = Attributes_FindOnWeapon(client, weapon, 298, true);	// mod ammo per shot
			if(value && clip < RoundFloat(value))
			{
				SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", gameTime+0.2);
				return true;
			}
		}
	}
	return false;
}

#if defined RPG
int Attributes_Airdashes(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	return RoundFloat(Attributes_FindOnWeapon(client, weapon, 250) + Attributes_FindOnPlayer(client, 393));	// air dash count, sniper rage DISPLAY ONLY
}
#endif

void Attributes_OnHit(int client, int victim, int weapon, float &damage, int& damagetype)
{
	if(GetClientTeam(client) == GetEntProp(victim, Prop_Send, "m_iTeamNum"))
	{
		float value = Attributes_FindOnWeapon(client, weapon, 251);	// speed buff ally
		if(value)
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 3.0);
	}
	else
	{
		float value = Attributes_FindOnWeapon(client, weapon, 16) +
			Attributes_FindOnWeapon(client, weapon, 98) +
			Attributes_FindOnWeapon(client, weapon, 110) +
			Attributes_FindOnWeapon(client, weapon, 111);	// add_onhit_addhealth
			
		if(value)
			StartHealingTimer(client, 0.1, value > 0 ? 1 : -1, value > 0 ? RoundFloat(value) : RoundFloat(-value));
		
		value = Attributes_FindOnWeapon(client, weapon, 19);	//  tmp dmgbuff on hit
		if(value)
			TF2_AddCondition(client, TFCond_TmpDamageBonus, 0.2);	// TODO: Set this to 1.0 and remove on miss
		
		if(!(damagetype & DMG_SLASH)) //Exclude itself so it doesnt do inf repeats! no weapon uses slash so we will use slash for any debuffs onto zombies that stacks
		{
			value = Attributes_FindOnWeapon(client, weapon, 149);	// bleeding duration
			if(value)
				StartBleedingTimer(victim, client, Attributes_FindOnWeapon(client, weapon, 2, true, 1.0)*4.0, RoundFloat(value*2.0), weapon);
			
			value = Attributes_FindOnWeapon(client, weapon, 208);	// Set DamageType Ignite

			int itemdefindex = 0;
			if(IsValidEntity(weapon))
			{
				itemdefindex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
			}
			
			if(value || (itemdefindex ==  594 || itemdefindex == 208)) //Either this attribute, or burn damamage!
			{

				if(value == 1.0)
					value = 7.5;

				if(value < 1.0)
					value = 2.0;
				
				NPC_Ignite(victim, client, value, weapon);
			}
			value = Attributes_FindOnWeapon(client, weapon, 638);	// Extinquisher
			if(value)
			{
				if(value == 1.0)
				{
					if(IgniteFor[victim] > 0)
					{
						damage *= 1.5;
						DisplayCritAboveNpc(victim, client, true);
					}
				}
				//dont actually extinquish, just give them more damage.
			}
			if(!TF2_IsPlayerInCondition(client, TFCond_Ubercharged)) //No infinite uber chain.
			{
				value = Attributes_FindOnWeapon(client, weapon, 17);	// add uber charge on hit
				if(value)
				{
					ArrayList list = new ArrayList();
					
					int entity, i;
					while(TF2_GetItem(client, entity, i))
					{
						if(HasEntProp(entity, Prop_Send, "m_flChargeLevel"))
							list.Push(entity);
					}

					int length = list.Length;
					if(length)
					{
						value /= float(length);
						float extra;
						for(i = length - 1; i >= 0; i--)
						{
							entity = list.Get(i);
							float uber = GetEntPropFloat(entity, Prop_Send, "m_flChargeLevel");
							if(Attributes_FindOnWeapon(client, entity, 2046) == 4.0)
							{
								uber -= value + extra;
							}
							else
							{
								uber += value + extra;
							}
								
							if(uber > 1.0)
							{
								extra = uber - 1.0;
								uber = 1.0;
							}
							else if(uber < 0.0)
							{
								extra = -uber;
								uber = 0.0;
							}
							else
							{
								extra = 0.0;
							}
								
							SetEntPropFloat(entity, Prop_Send, "m_flChargeLevel", uber);
						}
					}
					
					delete list;
				}
			}
			
			if(Attributes_FindOnWeapon(client, weapon, 368))	// rage on Hit
			{
				if(!GetEntProp(client, Prop_Send, "m_bRageDraining"))
				{
					float rage = GetEntPropFloat(client, Prop_Send, "m_flRageMeter")+0.5;
					if(rage > 100.0)
						rage = 100.0;
					
					SetEntPropFloat(client, Prop_Send, "m_flRageMeter", rage);
				}
			}
		}
		/*
		value = Attributes_FindOnWeapon(client, weapon, 166);	// add cloak on hit
		if(value)
		{
			float cloak = GetEntPropFloat(client, Prop_Send, "m_flCloakMeter") + value*100.0;
			if(cloak > 100.0)
			{
				cloak = 100.0;
			}
			else if(cloak < 0.0)
			{
				cloak = 0.0;
			}
			
			SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", cloak);
		}
		*/
		/*
		if(Attributes_FindOnWeapon(client, weapon, 540))	// add head on hit
			SetEntProp(client, Prop_Send, "m_iDecapitations", GetEntProp(client, Prop_Send, "m_iDecapitations")+1);
		
		value = Attributes_FindOnWeapon(client, weapon, 877);	// speed_boost_on_hit_enemy
		if(value)
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, value);
		
		if(Attributes_FindOnWeapon(client, weapon, 2067))	// attack_minicrits_and_consumes_burning
		{
			int ticks = NPC_Extinguish(victim);
			if(ticks)
			{
				EmitGameSoundToClient(client, "TFPlayer.FlameOut", victim);
				damage += ticks*4.0;
				TF2_AddCondition(client, TFCond_NoHealingDamageBuff, 0.1);
			}
		}
		*/
	}
}

void Attributes_OnKill(int client, int weapon)
{
	
	SetEntProp(client, Prop_Send, "m_iKills", GetEntProp(client, Prop_Send, "m_iKills")+1);
	float value;
	/*
	float value = Attributes_FindOnPlayer(client, 203);	// drop health pack on kill
	if(value)
		StartHealingTimer(client, 0.1, 1, RoundToCeil(SDKCall_GetMaxHealth(client)*value/5.0));

	value = Attributes_FindOnPlayer(client, 296);	// sapper kills collect crits
	if(value)
		SetEntProp(client, Prop_Send, "m_iRevengeCrits", GetEntProp(client, Prop_Send, "m_iRevengeCrits")+RoundFloat(value));
	
	if(Attributes_FindOnPlayer(client, 387))	// rage on kill
	{
		float rage = GetEntPropFloat(client, Prop_Send, "m_flRageMeter")+34.0;
		if(rage > 100.0)
			rage = 100.0;
		
		SetEntPropFloat(client, Prop_Send, "m_flRageMeter", rage);
	}
	*/
//	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	/*
	if(Attributes_FindOnWeapon(client, weapon, 30))	// fists have radial buff
	{
		int entity;
		float pos1[3], pos2[3];
		GetClientAbsOrigin(client, pos1);
		for(int target=1; target<=MaxClients; target++)
		{
			if(client!=target && IsClientInGame(target) && IsPlayerAlive(target))
			{
				GetClientAbsOrigin(target, pos2);
				if(GetVectorDistance(pos1, pos2, true) < 249999)
				{
					StartHealingTimer(target, 0.1, 1, 50);
					
					int i;
					while(TF2_GetItem(client, entity, i))
					{
						Address attrib = TF2Attrib_GetByDefIndex(entity, 28);
						if(attrib != Address_Null)
						{
							TF2Attrib_SetValue(attrib, TF2Attrib_GetValue(attrib)*1.1);
						}
						else
						{
							TF2Attrib_SetByDefIndex(entity, 28, 1.1);
						}
					}
				}
			}
		}
	}
	*/
	/*
	value = Attributes_FindOnWeapon(client, weapon, 31);	// critboost on kill
	if(value)
		TF2_AddCondition(client, TFCond_CritOnKill, value);
	
	value = Attributes_FindOnWeapon(client, weapon, 158);	// add cloak on kill
	if(value)
	{
		float cloak = GetEntPropFloat(client, Prop_Send, "m_flCloakMeter") + value*100.0;
		if(cloak > 100)
		{
			cloak = 100.0;
		}
		else if(cloak < 0.0)
		{
			cloak = 0.0;
		}
		
		SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", cloak);
	}
	*/
	if(IsValidEntity(weapon) && weapon > MaxClients)
	{
		value = Attributes_FindOnWeapon(client, weapon, 180);	// heal on kill
		if(value)
			StartHealingTimer(client, 0.1, value > 0 ? 1 : -1, value > 0 ? RoundFloat(value) : RoundFloat(-value));
		
#if defined ZR
		if(EscapeMode)
		{
			if(!IsWandWeapon(weapon))
			{
				char melee_classname[64];
				GetEntityClassname(weapon, melee_classname, 64);
					
				if (TFWeaponSlot_Melee == TF2_GetClassnameSlot(melee_classname))
					StartHealingTimer(client, 0.1, 1, 5, true);
			}
		}
#endif
		
	}
	/*
	value = Attributes_FindOnWeapon(client, weapon, 220, true);	// restore health on kill
	if(value)
		StartHealingTimer(client, 0.1, 1, RoundFloat(float(SDKCall_GetMaxHealth(client))*value/100.0));
	*/
	/*
	if(weapon > MaxClients && Attributes_FindOnWeapon(client, weapon, 226))	// honorbound
	{
		SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
		SetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy", GetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy")+1);
	}
	
	if(Attributes_FindOnWeapon(client, weapon, 292) == 6.0)	// Eyelander
	{
		SetEntProp(client, Prop_Send, "m_iDecapitations", GetEntProp(client, Prop_Send, "m_iDecapitations")+1);
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
		TF2_AddCondition(client, TFCond_DemoBuff);
	}
	
	if(Attributes_FindOnWeapon(client, weapon, 409))	// kill forces attacker to laugh
		TF2_StunPlayer(client, 2.0, 1.0, TF_STUNFLAGS_NORMALBONK);

	value = Attributes_FindOnWeapon(client, weapon, 613);	// minicritboost on kill
	if(value)
		TF2_AddCondition(client, TFCond_MiniCritOnKill, value);

	if(Attributes_FindOnWeapon(client, weapon, 644) || Attributes_FindOnWeapon(client, weapon, 807))	// clipsize increase on kill, add_head_on_kill
		SetEntProp(client, Prop_Send, "m_iDecapitations", GetEntProp(client, Prop_Send, "m_iDecapitations")+1);

	value = Attributes_FindOnWeapon(client, weapon, 736);	// speed_boost_on_kill
	if(value)
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, value);
	
	value = Attributes_FindOnWeapon(client, weapon, 2025);	// killstreak tier
	if(value)
		SetEntProp(client, Prop_Send, "m_nStreaks", GetEntProp(client, Prop_Send, "m_nStreaks")+1);
	*/
	/*value = Attributes_FindOnWeapon(client, weapon, 2067);	// attack_minicrits_and_consumes_burning
	if(value)
	{
		char buffer[16];
		if(GetCustomKeyValue(victim, "m_flIgniteFor", buffer, sizeof(buffer)))
		{
			float gameTime = GetGameTime();
			float time = StringToFloat(buffer);
			if(time >= gameTime)
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 4.0);
		}
	}*/
}

float Attributes_FindOnPlayer(int client, int index, bool multi=false, float defaul=0.0, bool IgnoreWeaponsEquipped = false, bool DoNotIngoreEquippedWeapon = false)
{
	bool found;
	float value = defaul;
	Address attrib = TF2Attrib_GetByDefIndex(client, index);
	if(attrib != Address_Null)
	{
		value = TF2Attrib_GetValue(attrib);
		found = true;
	}
	int entity = MaxClients+1;
	while(TF2_GetWearable(client, entity))
	{
		attrib = TF2Attrib_GetByDefIndex(entity, index);
		if(attrib != Address_Null)
		{
			if(!found)
			{
				value = TF2Attrib_GetValue(attrib);
				found = true;
			}
			else if(multi)
			{
				value *= TF2Attrib_GetValue(attrib);
			}
			else
			{
				value += TF2Attrib_GetValue(attrib);
			}
		}
	}
	
	if(!IgnoreWeaponsEquipped)
	{
		int i;
		while(TF2_GetItem(client, entity, i))
		{
			if(index != 128)
			{
				attrib = TF2Attrib_GetByDefIndex(entity, 128);
				if(attrib!=Address_Null && TF2Attrib_GetValue(attrib) && entity!=GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
					continue;
			}
			
			attrib = TF2Attrib_GetByDefIndex(entity, index);
			if(attrib != Address_Null)
			{
				if(!found)
				{
					value = TF2Attrib_GetValue(attrib);
					found = true;
				}
				else if(multi)
				{
					value *= TF2Attrib_GetValue(attrib);
				}
				else
				{
					value += TF2Attrib_GetValue(attrib);
				}
			}
		}
	}
	else if(DoNotIngoreEquippedWeapon)
	{
		int i;
		while(TF2_GetItem(client, entity, i))
		{
			if(entity!=GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon")) //Must be same weapon.
				continue;

			attrib = TF2Attrib_GetByDefIndex(entity, index);
			if(attrib != Address_Null)
			{
				if(!found)
				{
					value = TF2Attrib_GetValue(attrib);
					found = true;
				}
				else if(multi)
				{
					value *= TF2Attrib_GetValue(attrib);
				}
				else
				{
					value += TF2Attrib_GetValue(attrib);
				}
			}
		}
	}
	
	return value;
}

float Attributes_FindOnWeapon(int client, int entity, int index, bool multi=false, float defaul=0.0)
{
	bool found;
	float value = defaul;
	Address attrib = TF2Attrib_GetByDefIndex(client, index);
	if(attrib != Address_Null)
	{
		value = TF2Attrib_GetValue(attrib);
		found = true;
	}
	
	int wear = MaxClients+1;
	while(TF2_GetWearable(client, wear))
	{
		attrib = TF2Attrib_GetByDefIndex(wear, index);
		if(attrib != Address_Null)
		{
			if(!found)
			{
				value = TF2Attrib_GetValue(attrib);
				found = true;
			}
			else if(multi)
			{
				value *= TF2Attrib_GetValue(attrib);
			}
			else
			{
				value += TF2Attrib_GetValue(attrib);
			}
		}
	}
	
	if(entity > MaxClients)
	{
		attrib = TF2Attrib_GetByDefIndex(entity, index);
		if(attrib != Address_Null)
		{
			if(!found)
			{
				value = TF2Attrib_GetValue(attrib);
			}
			else if(multi)
			{
				value *= TF2Attrib_GetValue(attrib);
			}
			else
			{
				value += TF2Attrib_GetValue(attrib);
			}
		}
	}
	
	return value;
}