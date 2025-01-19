#pragma semicolon 1
#pragma newdecls required

static bool b_EntitiesHasKritzkrieg[MAXENTITIES] = {false};
static float Kritzkrieg_Buff2[MAXENTITIES];
static float Kritzkrieg_Buff3[MAXENTITIES];
//static Handle OC_Timer = null;

bool KritzkriegBuffOnline(int client)
{
	if(HasSpecificBuff(client, "Weapon Overclock"))
	{
		if(b_EntitiesHasKritzkrieg[client])
		{
			if(IsValidClient(client))ModifyKritzkriegBuff(client, 1, 0.7, true, 5.0, 2.0);
			else ModifyKritzkriegBuff(client, 2, 0.7, true, 5.0, 2.0);
			return true;
		}
		else
		{
			if(IsValidClient(client)) ModifyKritzkriegBuff(client, 1, 0.7, false, 5.0, 2.0);
			else ModifyKritzkriegBuff(client, 2, 0.7, false, 5.0, 2.0);
			return false;
		}
	}
	return false;
}

public void Kritzkrieg_OnMapStart()
{
	Zero(b_EntitiesHasKritzkrieg);
	HookEvent("player_chargedeployed", OnKritzkriegDeployed);
}

static void OnKritzkriegDeployed(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!IsValidClient(client) || !IsPlayerAlive(client))return;
	int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if(!IsValidEntity(medigun))
		return;
	if(i_CustomWeaponEquipLogic[medigun]!=WEAPON_KRITZKRIEG)
		return;
	CreateTimer(0.1, Timer_Kritzkrieg, EntIndexToEntRef(medigun), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	int target = GetHealingTarget(client);
	if(IsValidClient(target) && IsPlayerAlive(target)) GiveArmorViaPercentage(target, 0.5, 1.0);
	GiveArmorViaPercentage(client, 0.5, 1.0);
}

static Action Timer_Kritzkrieg(Handle timer, any medigunid)
{
	int medigun = EntRefToEntIndex(medigunid);
	if(!IsValidEntity(medigun))return Plugin_Stop;
	int client = GetEntPropEnt(medigun, Prop_Send, "m_hOwnerEntity");
	int target = GetHealingTarget(client);
	float charge = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
	for(int NonHealingTarget=1; NonHealingTarget<=MaxClients; NonHealingTarget++)
	{
		if(!IsValidClient(NonHealingTarget))
			continue;
		b_EntitiesHasKritzkrieg[NonHealingTarget]=false;
	}
	for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
	{
		int ally = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
		if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == TFTeam_Red)
		{
			b_EntitiesHasKritzkrieg[ally]=false;
		}
	}
	if((!IsValidClient(client) && !IsPlayerAlive(client))||charge <= 0.05)
		return Plugin_Stop;
	if(IsValidClient(target) && IsPlayerAlive(target))
	{
		ApplyStatusEffect(client, target, "Weapon Overclock", 1.0);
		b_EntitiesHasKritzkrieg[target]=true;
		Kritzkrieg_Magical(target, 0.2, true);
	}
	else if(target != INVALID_ENT_REFERENCE && IsEntityAlive(target) && GetTeam(client) == GetTeam(target))
	{
		ApplyStatusEffect(client, target, "Weapon Overclock", 1.0);
		b_EntitiesHasKritzkrieg[target]=true;
	}
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		ApplyStatusEffect(client, client, "Weapon Overclock", 1.0);
		b_EntitiesHasKritzkrieg[client]=true;
		Kritzkrieg_Magical(client, 0.2, true);
	}
	return Plugin_Continue;
}

static int GetHealingTarget(int client, bool checkgun=false)
{
	int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if(!checkgun)
	{
		if(GetEntProp(medigun, Prop_Send, "m_bHealing"))
			return GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");

		return -1;
	}

	if(IsValidEntity(medigun))
	{
		static char classname[64];
		GetEntityClassname(medigun, classname, sizeof(classname));
		if(StrEqual(classname, "tf_weapon_medigun", false))
		{
			if(GetEntProp(medigun, Prop_Send, "m_bHealing"))
				return GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
		}
	}
	return -1;
}

static void Kritzkrieg_Magical(int client, float Scale, bool apply)
{
	int primary = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	int secondary = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	int melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	bool Magical;
	if((IsValidEntity(primary) && i_IsWandWeapon[primary])
	||(IsValidEntity(secondary) && i_IsWandWeapon[secondary])
	||(IsValidEntity(melee) && i_IsWandWeapon[melee])) Magical=true;
	if(Magical)
	{
		int MaxMana = RoundToCeil((800.0*Mana_Regen_Level[client]));
		if(apply)
		{
			int AddMana = Current_Mana[client]+RoundToCeil(MaxMana*Scale);
			if(AddMana>MaxMana)
				AddMana=MaxMana;
			Current_Mana[client]=AddMana;
			return;
		}
		Current_Mana[client]=RoundToCeil(MaxMana*Scale);
	}
}

static void ModifyKritzkriegBuff(int entity, int type, float buffammount, bool GrantBuff = true, float buffammount2, float buffammount3)
{
	float BuffValueDo = MaxNumBuffValue(buffammount, 1.0, PlayerCountBuffAttackspeedScaling);
	float BuffValueDo2 = MaxNumBuffValue(buffammount2, 1.0, PlayerCountBuffAttackspeedScaling);
	float BuffValueDo3 = MaxNumBuffValue(buffammount3, 1.0, PlayerCountBuffAttackspeedScaling);
	if(type == 1)
	{
		int i, weapon;
		while(TF2_GetItem(entity, weapon, i))
		{
			if(Kritzkrieg_Buff[weapon] == 0.0 && !i_IsWandWeapon[weapon])
			{
				if(GrantBuff)
				{
					Kritzkrieg_Buff[weapon] = BuffValueDo;
					Kritzkrieg_Buff2[weapon] = BuffValueDo2;
					Kritzkrieg_Buff3[weapon] = BuffValueDo3;
					if(Attributes_Has(weapon, 6))
						Attributes_SetMulti(weapon, 6, BuffValueDo);	// Fire Rate
					
					if(Attributes_Has(weapon, 97))
						Attributes_SetMulti(weapon, 97, BuffValueDo);	// Reload Time
						
					if(Attributes_Has(weapon, 670))
						Attributes_SetMulti(weapon, 670, BuffValueDo);	// SpinUP
					
					if(Attributes_Has(weapon, 87))
						Attributes_SetMulti(weapon, 87, BuffValueDo);	// BOMB Charge Rate
					
					if(Attributes_Has(weapon, 343))
						Attributes_SetMulti(weapon, 343, BuffValueDo);	// Sentry Fire Rate
					
					if(Attributes_Has(weapon, 344))
						Attributes_SetMulti(weapon, 344, BuffValueDo2);	// Sentry Range
					
					if(Attributes_Has(weapon, 287))
						Attributes_SetMulti(weapon, 287, BuffValueDo2);	// Sentry DMG
					
					if(Attributes_Has(weapon, 41))
						Attributes_SetMulti(weapon, 41, BuffValueDo2);	// Sniper Charge Rate
					
					if(Attributes_Has(weapon, 99))
						Attributes_SetMulti(weapon, 99, BuffValueDo2);	// BlastRadius
						
					if(Attributes_Has(weapon, 103))
						Attributes_SetMulti(weapon, 103, BuffValueDo3);	// SpinUP
					
					if(Attributes_Has(weapon, 45))
						Attributes_SetMulti(weapon, 45, BuffValueDo3);	// PerShot
				}
			}
			else
			{
				if(!GrantBuff)
				{
					if(Kritzkrieg_Buff[weapon] != 0.0 && !i_IsWandWeapon[weapon])
					{
						if(Attributes_Has(weapon, 6))
							Attributes_SetMulti(weapon, 6, 1.0 / (Kritzkrieg_Buff[weapon]));	// Fire Rate
						
						if(Attributes_Has(weapon, 97))
							Attributes_SetMulti(weapon, 97, 1.0 / (Kritzkrieg_Buff[weapon]));	// Reload Time
							
						if(Attributes_Has(weapon, 670))
							Attributes_SetMulti(weapon, 670, 1.0 / (Kritzkrieg_Buff[weapon]));	// SpinUP
						
						if(Attributes_Has(weapon, 87))
							Attributes_SetMulti(weapon, 87, 1.0 / (Kritzkrieg_Buff[weapon]));	// BOMB Charge Rate
						
						if(Attributes_Has(weapon, 343))
							Attributes_SetMulti(weapon, 343, 1.0 / (Kritzkrieg_Buff[weapon]));	// Sentry Fire Rate
						
						if(Attributes_Has(weapon, 344))
							Attributes_SetMulti(weapon, 344, 1.0 / (Kritzkrieg_Buff2[weapon]));	// Sentry Range
						
						if(Attributes_Has(weapon, 287))
							Attributes_SetMulti(weapon, 287, 1.0 / (Kritzkrieg_Buff2[weapon]));	// Sentry DMG
						
						if(Attributes_Has(weapon, 41))
							Attributes_SetMulti(weapon, 41, 1.0 / (Kritzkrieg_Buff2[weapon]));	// Sniper Charge Rate
						
						if(Attributes_Has(weapon, 99))
							Attributes_SetMulti(weapon, 99, 1.0 / (Kritzkrieg_Buff2[weapon]));	// BlastRadius
							
						if(Attributes_Has(weapon, 103))
							Attributes_SetMulti(weapon, 103, 1.0 / (Kritzkrieg_Buff3[weapon]));	// SpinUP
						
						if(Attributes_Has(weapon, 45))
							Attributes_SetMulti(weapon, 45, 1.0 / (Kritzkrieg_Buff3[weapon]));	// PerShot

						Kritzkrieg_Buff[weapon] = 0.0;
					}
				}
			}
		}
	}
	else if(type == 2)
	{
		char npc_classname[60];
		NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
		if(StrEqual(npc_classname, "npc_citizen"))
		{
			Citizen npc = view_as<Citizen>(entity);
			if(Kritzkrieg_Buff[entity] == 0.0)
			{
				if(GrantBuff)
				{
					Kritzkrieg_Buff[entity] = BuffValueDo;
					npc.m_fGunFirerate *= BuffValueDo;
					npc.m_fGunReload *= BuffValueDo;
				}
			}
			else
			{
				if(!GrantBuff)
				{
					npc.m_fGunFirerate /= (Kritzkrieg_Buff[entity]);
					npc.m_fGunReload /= (Kritzkrieg_Buff[entity]);
					Kritzkrieg_Buff[entity] = 0.0;
				}
			}
		}
		else if(entity > MaxClients)
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(Kritzkrieg_Buff[entity] == 0.0)
			{
				if(GrantBuff)
				{
					Kritzkrieg_Buff[entity] = BuffValueDo;
					npc.BonusFireRate *= BuffValueDo;
				}
			}
			else
			{
				if(!GrantBuff)
				{
					npc.BonusFireRate /= (Kritzkrieg_Buff[entity]);
					Kritzkrieg_Buff[entity] = 0.0;
				}
			}
		}
	}
}