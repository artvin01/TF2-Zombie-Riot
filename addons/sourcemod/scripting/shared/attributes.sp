#pragma semicolon 1
#pragma newdecls required

static StringMap WeaponAttributes[MAXENTITIES + 1];

bool Attribute_ServerSide(int attribute)
{
	switch(attribute)
	{
		case 206,205:
		{
			return true;
		}
		case 651,33,731,719,544,410,786,3002,3000,149,208,638,17:
		{
			return true;
		}
		/*
				Panic_Attack[entity] = Attributes_GetOnWeapon(client, entity, 651);
		i_SurvivalKnifeCount[entity] = RoundToCeil(Attributes_GetOnWeapon(client, entity, 33, false));
		i_GlitchedGun[entity] = RoundToCeil(Attributes_GetOnWeapon(client, entity, 731, false));
		i_AresenalTrap[entity] = RoundToCeil(Attributes_GetOnWeapon(client, entity, 719, false));
		i_ArsenalBombImplanter[entity] = RoundToCeil(Attributes_GetOnWeapon(client, entity, 544, false));
		i_NoBonusRange[entity] = RoundToCeil(Attributes_GetOnWeapon(client, entity, 410, false));
		i_BuffBannerPassively[entity] = RoundToCeil(Attributes_GetOnWeapon(client, entity, 786, false));
		
		i_LowTeslarStaff[entity] = RoundToCeil(Attributes_GetOnWeapon(client, entity, 3002, false));
		i_HighTeslarStaff[entity] = RoundToCeil(Attributes_GetOnWeapon(client, entity, 3000, false));

		
		i_BleedDurationWeapon[entity] = RoundToCeil(Attributes_GetOnWeapon(client, entity, 149, false));
		i_BurnDurationWeapon[entity] = RoundToCeil(Attributes_GetOnWeapon(client, entity, 208, false));
		i_ExtinquisherWeapon[entity] = RoundToCeil(Attributes_GetOnWeapon(client, entity, 638, false));
		f_UberOnHitWeapon[entity] = Attributes_GetOnWeapon(client, entity, 17, false);
		*/
	}
	return false;
}
/*
bool Attribute_ClientSide(int attribute)
{
	switch(attribute)
	{
		case 1,2,3,4,5,6,26,96,97,303,298,49,252,201,
		396,116,821,128,231,263,264,54,47,41,45,
		353,107,465,464,740,169,314,178,287:
		{
			return true;
		}
		
			This includes
			damage attributes					-ingame dmg code, can be fixed though.
			attackspeed
			clip size
			ammo override
			Max ammo override
			Reload speed
			no doublejump
			damage force reduction				- as its internal in tf2 too much
			Animation speed/gesture speed
			Buff banner type
			No_Attack
			provide on active
			Medigun provide						- due to speed and stuff, vaccinator too
			Attackrange and attack fatness		- due to clientside melee hit registration
			speed penalty
			Sniper charge
			Bullets per shot
		
	}
	return false;
}
*/
void Attributes_EntityDestroyed(int entity)
{
	delete WeaponAttributes[entity];
}

bool Attributes_RemoveAll(int entity)
{
	delete WeaponAttributes[entity];
	return TF2Attrib_RemoveAll(entity);
}

bool Attributes_Has(int entity, int attrib)
{
	if(!WeaponAttributes[entity])
		return false;
	
	char buffer[6];
	IntToString(attrib, buffer, sizeof(buffer));
	return WeaponAttributes[entity].ContainsKey(buffer);
}

float Attributes_Get(int entity, int attrib, float defaul = 1.0)
{
	if(WeaponAttributes[entity])
	{
		float value = defaul;

		char buffer[6];
		IntToString(attrib, buffer, sizeof(buffer));
		if(WeaponAttributes[entity].Get(buffer, value))
			return value;
	}
	
	return defaul;
}

void Attributes_Set(int entity, int attrib, float value)
{
	if(!WeaponAttributes[entity])
		WeaponAttributes[entity] = new StringMap();
	
	char buffer[6];
	IntToString(attrib, buffer, sizeof(buffer));
	WeaponAttributes[entity].Set(buffer, value);

	if(Attribute_ClientSide(attrib))
		Attributes_Set(entity, attrib, value);
}

void Attributes_SetAdd(int entity, int attrib, float amount)
{
	char buffer[6];
	IntToString(attrib, buffer, sizeof(buffer));

	float value = 0.0;

	if(WeaponAttributes[entity])
	{
		WeaponAttributes[entity].Get(buffer, value);
	}
	else
	{
		WeaponAttributes[entity] = new StringMap();
	}

	value += amount;

	WeaponAttributes[entity].Set(buffer, value);
	if(Attribute_ClientSide(attrib))
		Attributes_Set(entity, attrib, value);
}

void Attributes_SetMulti(int entity, int attrib, float amount)
{
	char buffer[6];
	IntToString(attrib, buffer, sizeof(buffer));

	float value = 1.0;

	if(WeaponAttributes[entity])
	{
		WeaponAttributes[entity].Get(buffer, value);
	}
	else
	{
		WeaponAttributes[entity] = new StringMap();
	}

	value *= amount;

	WeaponAttributes[entity].Set(buffer, value);
	if(Attribute_ClientSide(attrib))
		Attributes_Set(entity, attrib, value);
}

bool Attributes_GetString(int entity, int attrib, char[] value, int length, int &size = 0)
{
	if(!WeaponAttributes[entity])
		return false;

	float value = defaul;

	char buffer[6];
	IntToString(attrib, buffer, sizeof(buffer));
	return WeaponAttributes[entity].GetString(buffer, value, length, size);
}

void Attributes_SetString(int entity, int attrib, const char[] value)
{
	if(!WeaponAttributes[entity])
		WeaponAttributes[entity] = new StringMap();
	
	char buffer[6];
	IntToString(attrib, buffer, sizeof(buffer));
	WeaponAttributes[entity].SetString(buffer, value);
}

bool Attributes_Fire(int client, int weapon)
{
	int clip = GetEntProp(weapon, Prop_Data, "m_iClip1");
	if(clip > 0)
	{
		float gameTime = GetGameTime();
		if(gameTime < GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack"))
		{
			float value = Attributes_GetOnWeapon(client, weapon, 298, false);	// mod ammo per shot
			if(value && clip < RoundFloat(value))
			{
				SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", gameTime + 0.2);
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
	return RoundFloat(Attributes_GetOnWeapon(client, weapon, 250, false) + Attributes_GetOnPlayer(client, 393, false));	// air dash count, sniper rage DISPLAY ONLY
},
#endif

void Attributes_OnHit(int client, int victim, int weapon, float &damage, int& damagetype)
{
	/*
	if(GetClientTeam(client) == GetEntProp(victim, Prop_Send, "m_iTeamNum"))
	{
		float value = Attributes_GetOnWeapon(client, weapon, 251, false);	// speed buff ally
		if(value)
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 3.0);
	}
	else
	*/
	{
		if(weapon < 1)
		{
			return;
		}

		if(!(damagetype & DMG_SLASH)) //Exclude itself so it doesnt do inf repeats! no weapon uses slash so we will use slash for any debuffs onto zombies that stacks
		{
			float value;
			if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
			{

				value = Attributes_GetOnWeapon(client, weapon, , false) +
					Attributes_GetOnWeapon(client, weapon, 98, false) +
					Attributes_GetOnWeapon(client, weapon, 110, false) +
					Attributes_GetOnWeapon(client, weapon, 111, false);	// add_onhit_addhealth
					
				if(value)
					StartHealingTimer(client, 0.1, value > 0 ? 1.0 : -1.0, value > 0 ? RoundFloat(value) : RoundFloat(-value));
/*		
				value = Attributes_GetOnWeapon(client, weapon, 19, false);	//  tmp dmgbuff on hit
				if(value)
					TF2_AddCondition(client, TFCond_TmpDamageBonus, 0.2);	// TODO: Set this to 1.0 and remove on miss
*/
				value = float(i_BleedDurationWeapon[weapon]);	// bleeding duration
				if(value)
					StartBleedingTimer(victim, client, Attributes_GetOnWeapon(client, weapon, 2) * 4.0, RoundFloat(value * 2.0), weapon, damagetype);

					
				value = float(i_BurnDurationWeapon[weapon]);	// Set DamageType Ignite

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
				value = float(i_ExtinquisherWeapon[weapon]);	// Extinquisher
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
				value = f_UberOnHitWeapon[weapon];
				if(value)
				{
					if(!TF2_IsPlayerInCondition(client, TFCond_Ubercharged)) //No infinite uber chain.
					{
						// add uber charge on hit
						
						ArrayList list = new ArrayList();
							
						int entity, i;
						while(TF2_GetItem(client, entity, i))
						{
							if(b_IsAMedigun[entity])	//if(HasEntProp(entity, Prop_Send, "m_flChargeLevel"))
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
								if(Attributes_GetOnWeapon(client, entity, 2046) == 4.0)
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
			
/*			
				if(Attributes_GetOnWeapon(client, weapon, 368, false))	// rage on Hit
				{
					if(!GetEntProp(client, Prop_Send, "m_bRageDraining"))
					{
						float rage = GetEntPropFloat(client, Prop_Send, "m_flRageMeter")+0.5;
						if(rage > 100.0)
							rage = 100.0;
						
						SetEntPropFloat(client, Prop_Send, "m_flRageMeter", rage);
					}
				}
*/
			}
		}
		/*
		value = Attributes_GetOnWeapon(client, weapon, 166, false);	// add cloak on hit
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
		
		if(Attributes_GetOnWeapon(client, weapon, 540))	// add head on hit
			SetEntProp(client, Prop_Send, "m_iDecapitations", GetEntProp(client, Prop_Send, "m_iDecapitations")+1);
		*/
		float value = Attributes_GetOnWeapon(client, weapon, 877, false);	// speed_boost_on_hit_enemy
		if(value)
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, value);
		/*
		if(Attributes_GetOnPlayer(client, weapon, 2067))	// attack_minicrits_and_consumes_burning
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
	SetEntProp(client, Prop_Send, "m_iKills", GetEntProp(client, Prop_Send, "m_iKills") + 1);

	float value;
	/*
	float value = Attributes_GetOnPlayer(client, 203, false);	// drop health pack on kill
	if(value)
		StartHealingTimer(client, 0.1, 1, RoundToCeil(SDKCall_GetMaxHealth(client)*value/5.0));

	value = Attributes_GetOnPlayer(client, 296, false);	// sapper kills collect crits
	if(value)
		SetEntProp(client, Prop_Send, "m_iRevengeCrits", GetEntProp(client, Prop_Send, "m_iRevengeCrits")+RoundFloat(value));
	*/

	value = Attributes_GetOnPlayer(client, 387, false);	// rage on kill
	if(value)
	{
		float rage = GetEntPropFloat(client, Prop_Send, "m_flRageMeter") + value;
		if(rage > 100.0)
			rage = 100.0;
		
		SetEntPropFloat(client, Prop_Send, "m_flRageMeter", rage);
	}
	
//	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	/*
	if(Attributes_GetOnWeapon(client, weapon, 30))	// fists have radial buff
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
							Attributes_Set(entity, 28, 1.1);
						}
					}
				}
			}
		}
	}
	*/
	/*
	value = Attributes_GetOnWeapon(client, weapon, 31, false);	// critboost on kill
	if(value)
		TF2_AddCondition(client, TFCond_CritOnKill, value);
	
	value = Attributes_GetOnWeapon(client, weapon, false);	// add cloak on kill
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
		value = Attributes_GetOnWeapon(client, weapon, 180, false);	// heal on kill
		if(value)
			StartHealingTimer(client, 0.1, (value > 0) ? 1.0 : -1.0, (value > 0) ? RoundFloat(value) : RoundFloat(-value));
		
	}
	/*
	value = Attributes_GetOnWeapon(client, weapon, 220, false);	// restore health on kill
	if(value)
		StartHealingTimer(client, 0.1, 1, RoundFloat(float(SDKCall_GetMaxHealth(client))*value/100.0));
	*/
	/*
	if(weapon > MaxClients && Attributes_GetOnWeapon(client, weapon, 226))	// honorbound
	{
		SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
		SetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy", GetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy")+1);
	}
	
	if(Attributes_GetOnWeapon(client, weapon, 292) == 6.0)	// Eyelander
	{
		SetEntProp(client, Prop_Send, "m_iDecapitations", GetEntProp(client, Prop_Send, "m_iDecapitations")+1);
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
		TF2_AddCondition(client, TFCond_DemoBuff);
	}
	
	if(Attributes_GetOnWeapon(client, weapon, 409))	// kill forces attacker to laugh
		TF2_StunPlayer(client, 2.0, 1.0, TF_STUNFLAGS_NORMALBONK);
*/
	value = Attributes_GetOnWeapon(client, weapon, 613, false);	// minicritboost on kill
	if(value)
		TF2_AddCondition(client, TFCond_MiniCritOnKill, value);

	if(Attributes_GetOnWeapon(client, weapon, 644) || Attributes_GetOnWeapon(client, weapon, 807))	// clipsize increase on kill, add_head_on_kill
		SetEntProp(client, Prop_Send, "m_iDecapitations", GetEntProp(client, Prop_Send, "m_iDecapitations")+1);
/*
	value = Attributes_GetOnWeapon(client, weapon, 736);	// speed_boost_on_kill
	if(value)
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, value);
	
	value = Attributes_GetOnWeapon(client, weapon, 2025);	// killstreak tier
	if(value)
		SetEntProp(client, Prop_Send, "m_nStreaks", GetEntProp(client, Prop_Send, "m_nStreaks")+1);
	*/
	/*value = Attributes_GetOnWeapon(client, weapon, 2067);	// attack_minicrits_and_consumes_burning
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

float Attributes_GetOnPlayer(int client, int index, bool multi = true, bool noWeapons = false)
{
	float defaul = multi ? 1.0 : 0.0;
	float result = Attributes_Get(client, index, defaul);
	
	float value;
	int i = MaxClients + 1;
	while(TF2_GetWearable(client, i))
	{
		float value = Attributes_Get(i, index, defaul);
		if(value != defaul)
		{
			if(multi)
			{
				result *= value;
			}
			else
			{
				result += value;
			}
		}
	}
	
	if(!noWeapons)
	{
		int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		int i;
		while(TF2_GetItem(client, entity, i))
		{
			if(index != 128 && active != entity)
			{
				if(Attributes_Get(entity, 128, 0.0))
					continue;
			}
			
			float value = Attributes_Get(entity, index, defaul);
			if(value != defaul)
			{
				if(multi)
				{
					result *= value;
				}
				else
				{
					result += value;
				}
			}
		}
	}
	
	return value;
}

float Attributes_GetOnWeapon(int client, int entity, int index, bool multi = true)
{
	float defaul = multi ? 1.0 : 0.0;
	float result = Attributes_Get(client, index, defaul);
	
	int i = MaxClients + 1;
	while(TF2_GetWearable(client, i))
	{
		float value = Attributes_Get(i, index, defaul);
		if(value != defaul)
		{
			if(multi)
			{
				result *= value;
			}
			else
			{
				result += value;
			}
		}
	}
	
	if(entity > MaxClients)
	{
		float value = Attributes_Get(entity, index, defaul);
		if(value != defaul)
		{
			if(multi)
			{
				result *= value;
			}
			else
			{
				result += value;
			}
		}
	}
	
	return value;
}