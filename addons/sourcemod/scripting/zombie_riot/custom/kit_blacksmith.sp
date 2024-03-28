#pragma semicolon 1
#pragma newdecls required

#define TINKER_LIMIT	4

enum struct TinkerEnum
{
	int AccountId;
	int StoreIndex;
	int Attrib[TINKER_LIMIT];
	float Value[TINKER_LIMIT];
	float Luck[TINKER_LIMIT];
}

static const int SupportBuildings[] = { 2, 5, 9, 14, 14, 15 };
static const int MetalGain[] = { 10, 25, 50, 100, 200, 300 };
static const float Cooldowns[] = { 180.0, 150.0, 120.0, 90.0, 60.0, 30.0 };
static int SmithLevel[MAXTF2PLAYERS] = {-1, ...};
static int i_AdditionalSupportBuildings[MAXTF2PLAYERS] = {0, ...};

static int ParticleRef[MAXTF2PLAYERS] = {-1, ...};
static Handle EffectTimer[MAXTF2PLAYERS];

static ArrayList Tinkers;

void Blacksmith_RoundStart()
{
	Zero(i_AdditionalSupportBuildings);
	delete Tinkers;
}

int Blacksmith_Additional_SupportBuildings(int client)
{
	return i_AdditionalSupportBuildings[client];
}

bool Blacksmith_HasTinker(int client, int index)
{
	if(Tinkers)
	{
		int account = GetSteamAccountID(client, false);
		if(account)
		{
			static TinkerEnum tinker;
			int length = Tinkers.Length;
			for(int a; a < length; a++)
			{
				Tinkers.GetArray(a, tinker);
				if(tinker.AccountId == account && tinker.StoreIndex == index)
					return true;
			}
		}
	}
	
	return false;
}

void Blacksmith_ExtraDesc(int client, int index)
{
	if(Tinkers)
	{
		int account = GetSteamAccountID(client, false);
		if(account)
		{
			static TinkerEnum tinker;
			int length = Tinkers.Length;
			for(int a; a < length; a++)
			{
				Tinkers.GetArray(a, tinker);
				if(tinker.AccountId == account && tinker.StoreIndex == index)
				{
					for(int b; b < sizeof(tinker.Attrib); b++)
					{
						if(!tinker.Attrib[b])
							break;
						
						PrintAttribValue(client, tinker.Attrib[b], tinker.Value[b], tinker.Luck[b]);
					}

					break;
				}
			}
		}
	}
}

void Blacksmith_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BLACKSMITH)
	{
		SmithLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));

		if(SmithLevel[client] >= sizeof(MetalGain))
			SmithLevel[client] = sizeof(MetalGain) - 1;

		delete EffectTimer[client];
		EffectTimer[client] = CreateTimer(0.5, Blacksmith_TimerEffect, client, TIMER_REPEAT);

		i_AdditionalSupportBuildings[client] = SupportBuildings[SmithLevel[client]];
	}

	if(Tinkers)
	{
		int account = GetSteamAccountID(client, false);
		if(account)
		{
			static TinkerEnum tinker;
			int length = Tinkers.Length;
			for(int a; a < length; a++)
			{
				Tinkers.GetArray(a, tinker);
				if(tinker.AccountId == account && tinker.StoreIndex == StoreWeapon[weapon])
				{
					for(int b; b < sizeof(tinker.Attrib); b++)
					{
						if(!tinker.Attrib[b])
							break;
						
						Attributes_SetMulti(weapon, tinker.Attrib[b], tinker.Value[b]);
					}

					break;
				}
			}
		}
	}
}

public Action Blacksmith_TimerEffect(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		if(!dieingstate[client] && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE && i_HealthBeforeSuit[client] == 0)
		{
			int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			if(weapon != -1)
			{
				if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BLACKSMITH)
				{
					if(!Waves_InSetup() && GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon)
					{
						SetAmmo(client, Ammo_Metal, GetAmmo(client, Ammo_Metal) + MetalGain[SmithLevel[client]]);
					}

					i_AdditionalSupportBuildings[client] = SupportBuildings[SmithLevel[client]];

					if(ParticleRef[client] == -1)
					{
						float pos[3]; GetClientAbsOrigin(client, pos);
						pos[2] += 1.0;

						int entity = ParticleEffectAt(pos, "utaunt_hellpit_firering", -1.0);
						if(entity > MaxClients)
						{
							SetParent(client, entity);
							ParticleRef[client] = EntIndexToEntRef(entity);
						}
					}
					
					return Plugin_Continue;
				}
			}
			i_AdditionalSupportBuildings[client] = 0;
			SmithLevel[client] = -1;
		}
		
		if(ParticleRef[client] != -1)
		{
			int entity = EntRefToEntIndex(ParticleRef[client]);
			if(entity > MaxClients)
			{
				TeleportEntity(entity, OFF_THE_MAP);
				RemoveEntity(entity);
			}

			ParticleRef[client] = -1;
		}

		return Plugin_Continue;
	}

	SmithLevel[client] = -1;
		
	if(ParticleRef[client] != -1)
	{
		int entity = EntRefToEntIndex(ParticleRef[client]);
		if(entity > MaxClients)
		{
			TeleportEntity(entity, OFF_THE_MAP);
			RemoveEntity(entity);
		}
		
		ParticleRef[client] = -1;
	}
	i_AdditionalSupportBuildings[client] = 0;
	EffectTimer[client] = null;
	return Plugin_Stop;
}

public void Weapon_BlacksmithMelee_M2(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	Rogue_OnAbilityUse(weapon);
	Ability_Apply_Cooldown(client, slot, 10.0);

	ClientCommand(client, "playgamesound weapons/gunslinger_three_hit.wav");

	ApplyTempAttrib(weapon, 2, 2.0, 2.0);
	ApplyTempAttrib(weapon, 6, 0.25, 2.0);
}

public Action Blacksmith_BuildingTimer(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity == -1)
		return Plugin_Stop;
	
	int maxRepair = Building_Max_Health[entity] * 2;

	if(Building_cannot_be_repaired[entity])
	{
		int maxhealth = GetEntProp(entity, Prop_Data, "m_iMaxHealth") + (maxRepair / 1500);
		if(maxhealth >= Building_Max_Health[entity])
		{
			Building_Repair_Health[entity] += Building_Max_Health[entity] - maxhealth;
			if(Building_Repair_Health[entity] >= maxRepair)
				Building_Repair_Health[entity] = maxRepair - 1;
			
			maxhealth = Building_Max_Health[entity];
			Building_cannot_be_repaired[entity] = false;
		}

		SetEntProp(entity, Prop_Data, "m_iMaxHealth", maxhealth);
	}
	else if(Building_Repair_Health[entity] < maxRepair)
	{
		Building_Repair_Health[entity] += (maxRepair / 1500);
		if(Building_Repair_Health[entity] > maxRepair)
			Building_Repair_Health[entity] = maxRepair;
		
		int progress = (Building_Repair_Health[entity] - 1) * 100 / Building_Max_Health[entity];
		SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", progress + 1);
	}

	return Plugin_Continue;
}

void Blacksmith_BuildingUsed(int entity, int client, int owner)
{
	if(owner == -1 || SmithLevel[owner] < 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ApplyBuildingCollectCooldown(entity, client, FAR_FUTURE);
		return;
	}

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon == -1)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ApplyBuildingCollectCooldown(entity, client, 1.0);
		return;
	}
	
	int account = GetSteamAccountID(client, false);
	if(!account)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ApplyBuildingCollectCooldown(entity, client, 3.0);
		return;
	}

	TinkerEnum tinker;
	int found = -1;
	if(Tinkers)
	{
		int length = Tinkers.Length;
		for(int a; a < length; a++)
		{
			Tinkers.GetArray(a, tinker);
			if(tinker.AccountId == account && tinker.StoreIndex == StoreWeapon[weapon])
			{
				found = a;
				break;
			}
		}
	}

	if(found == -1)
	{
		tinker.AccountId = account;
		tinker.StoreIndex = StoreWeapon[weapon];
	}
	
	Zero(tinker.Attrib);

	int rarity;
	if(GetClientButtons(client) & IN_DUCK)
	{
		SetGlobalTransTarget(client);
		
		if(found == -1)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Blacksmith No Attribs");

			ApplyBuildingCollectCooldown(entity, client, 2.0);
			return;
		}

		rarity = -1;
		Tinkers.Erase(found);
		PrintToChat(client, "%t", "Removed Tinker Attributes");
	}
	else
	{
		switch(SmithLevel[owner])
		{
			case 0, 1:
			{
				
			}
			case 2:
			{
				if((GetURandomInt() % 4) == 0)
					rarity = 1;
			}
			case 3:
			{
				int rand = GetURandomInt();
				if((rand % 7) == 0)
				{
					rarity = 2;
				}
				else if((rand % 3) == 0)
				{
					rarity = 1;
				}
			}
			case 4:
			{
				int rand = GetURandomInt();
				if((rand % 5) == 0)
				{
					rarity = 2;
				}
				else if((rand % 2) == 0)
				{
					rarity = 1;
				}
			}
			default:
			{
				if((GetURandomInt() % 3) == 0)
				{
					rarity = 2;
				}
				else
				{
					rarity = 1;
				}
			}
		}

		for(int i; i < sizeof(tinker.Luck); i++)
		{
			tinker.Luck[i] = GetURandomFloat();
		}

		char classname[64];
		GetEntityClassname(weapon, classname, sizeof(classname));
		int slot = TF2_GetClassnameSlot(classname);
		
		if(slot == TFWeaponSlot_Melee)
		{
			if(i_IsWrench[entity])
			{
				// Wrench Weapon
			}
			else if(i_IsWandWeapon[entity])
			{
				// Mage Weapon
			}
			else
			{
				// Melee Weapon
				switch(GetURandomInt() % 2)
				{
					case 0:
						TinkerGlassy(rarity, tinker);
					
					case 1:
						TinkerGlassy(rarity, tinker);
				}
			}
		}
		else if(slot < TFWeaponSlot_Melee)
		{
			if(Attributes_Has(weapon, 101) || Attributes_Has(weapon, 102) || Attributes_Has(weapon, 103) || Attributes_Has(weapon, 104))
			{
				// Projectile Weapon
			}
			else
			{
				// Hitscan Weapon
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Blacksmith Underleveled");

			ApplyBuildingCollectCooldown(entity, client, 2.0);
			return;
		}

		for(int i; i < sizeof(tinker.Attrib); i++)
		{
			if(!tinker.Attrib[i])
				break;
			
			PrintAttribValue(client, tinker.Attrib[i], tinker.Value[i], tinker.Luck[i]);
		}

		if(found == -1)
		{
			if(!Tinkers)
				Tinkers = new ArrayList(sizeof(TinkerEnum));
			
			Tinkers.PushArray(tinker);
		}
		else
		{
			Tinkers.SetArray(found, tinker);
		}
	}

	Store_ApplyAttribs(client);
	Store_GiveAll(client, GetClientHealth(client));	

	switch(rarity)
	{
		case -1:
		{
			ClientCommand(client, "playgamesound ui/quest_decode.wav");
		}
		case 0:
		{
			ClientCommand(client, "playgamesound ui/quest_status_tick_novice.wav");
		}
		case 1:
		{
			ClientCommand(client, "playgamesound ui/quest_status_tick_advanced.wav");
		}
		case 2:
		{
			ClientCommand(client, "playgamesound ui/quest_status_tick_expert.wav");
		}
	}

	float cooldown = Cooldowns[SmithLevel[owner]];
	if(client != owner && Store_HasWeaponKit(client))
		cooldown *= 0.5;
	
	ApplyBuildingCollectCooldown(entity, client, cooldown);

	if(!Rogue_Mode() && owner != client)
	{
		if(i_Healing_station_money_limit[owner][client] < 20)
		{
			i_Healing_station_money_limit[owner][client]++;
			Resupplies_Supplied[owner] += 2;
			GiveCredits(owner, 20, true);
			SetDefaultHudPosition(owner);
			SetGlobalTransTarget(owner);
			ShowSyncHudText(owner, SyncHud_Notifaction, "%t", "Blacksmith Used");
		}

		switch(rarity)
		{
			case 0:
			{
				ClientCommand(owner, "playgamesound ui/quest_status_tick_novice_friend.wav");
			}
			case 1:
			{
				ClientCommand(owner, "playgamesound ui/quest_status_tick_advanced_friend.wav");
			}
			default:
			{
				ClientCommand(owner, "playgamesound ui/quest_status_tick_expert_friend.wav");
			}
		}
	}
}

static bool AttribIsInverse(int attrib)
{
	switch(attrib)
	{
		case 5, 6, 96, 97, 205, 206, 343, 412:
			return true;
	}

	return false;
}

static void PrintAttribValue(int client, int attrib, float value, float luck)
{
	bool inverse = AttribIsInverse(attrib);
	
	char buffer[16];
	if(value < 1.0)
	{
		FormatEx(buffer, sizeof(buffer), "%d%% ", RoundToCeil((1.0 - value) * 100.0));
	}
	else
	{
		FormatEx(buffer, sizeof(buffer), "%d%% ", RoundToCeil((value - 1.0) * 100.0));
	}

	if(((value < 1.0) ^ inverse))
	{
		Format(buffer, sizeof(buffer), "{crimson}-%s", buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "{green}+%s", buffer);
	}

	switch(attrib)
	{
		case 1:
			Format(buffer, sizeof(buffer), "%sPhysical Damage", buffer);
		
		case 2:
			Format(buffer, sizeof(buffer), "%sBase Damage", buffer);
		
		case 3, 4:
			Format(buffer, sizeof(buffer), "%sClip Size", buffer);
		
		case 5, 6:
			Format(buffer, sizeof(buffer), "%sFiring Speed", buffer);
		
		case 8:
			Format(buffer, sizeof(buffer), "%sHealing Rate", buffer);
		
		case 10:
			Format(buffer, sizeof(buffer), "%sÜberCharge Rate", buffer);
		
		case 26:
			Format(buffer, sizeof(buffer), "%sMax Health Bonus", buffer);
		
		case 45:
			Format(buffer, sizeof(buffer), "%sBullets Per Shot", buffer);
		
		case 94:
			Format(buffer, sizeof(buffer), "%sRepair Rate", buffer);
		
		case 96, 97:
			Format(buffer, sizeof(buffer), "%sReload Speed", buffer);
		
		case 99, 100:
			Format(buffer, sizeof(buffer), "%sBlast Radius", buffer);
		
		case 101, 102:
			Format(buffer, sizeof(buffer), "%sProjectile Range", buffer);
		
		case 103, 104:
			Format(buffer, sizeof(buffer), "%sProjectile Speed", buffer);
		
		case 107:
			Format(buffer, sizeof(buffer), "%sMovement Speed", buffer);
		
		case 149:
			Format(buffer, sizeof(buffer), "%sBleed Duration", buffer);
		
		case 205:
			Format(buffer, sizeof(buffer), "%sRanged Damage Resistance", buffer);
		
		case 206:
			Format(buffer, sizeof(buffer), "%sMelee Damage Resistance", buffer);
		
		case 287:
			Format(buffer, sizeof(buffer), "%sSentry Damage", buffer);
		
		case 319:
			Format(buffer, sizeof(buffer), "%sBuff Duration", buffer);
		
		case 343:
			Format(buffer, sizeof(buffer), "%sSentry Firing Speed", buffer);
		
		case 410:
			Format(buffer, sizeof(buffer), "%sBase Damage", buffer);
		
		case 412:
			Format(buffer, sizeof(buffer), "%sDamage Resistance", buffer);
	}

	CPrintToChat(client, "%s {yellow}(%d%%)", buffer, RoundToCeil(luck * 100.0));
}

static void TinkerGlassy(int rarity, TinkerEnum tinker)
{
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 205;
	tinker.Attrib[2] = 206;

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.1 + (0.1 * tinker.Luck[0]);
			tinker.Value[1] = 1.05 + (0.05 * tinker.Luck[1]);
			tinker.Value[2] = 1.05 + (0.05 * tinker.Luck[2]);
		}
		case 1:
		{
			tinker.Value[0] = 1.15 + (0.1 * tinker.Luck[0]);
			tinker.Value[1] = 1.05 + (0.05 * tinker.Luck[1]);
			tinker.Value[2] = 1.05 + (0.05 * tinker.Luck[2]);
		}
		case 2:
		{
			tinker.Value[0] = 1.2 + (0.1 * tinker.Luck[0]);
			tinker.Value[1] = 1.05 + (0.05 * tinker.Luck[1]);
			tinker.Value[2] = 1.05 + (0.05 * tinker.Luck[2]);
		}
	}
}
