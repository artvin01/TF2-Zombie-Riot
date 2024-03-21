#pragma semicolon 1
#pragma newdecls required

#define TINKER_LIMIT	4

enum struct TinkerEnum
{
	int AccountId;
	int StoreIndex;
	int Attrib[TINKER_LIMIT];
	float Value[TINKER_LIMIT];
}

static const int SupportBuildings[] = { 2, 5, 9, 14, 14, 15 };
static const int MetalGain[] = { 10, 25, 50, 100, 200, 300 };
static const float Cooldowns[] = { 180.0, 150.0, 120.0, 90.0, 60.0, 30.0 };
static int SmithLevel[MAXTF2PLAYERS] = {-1, ...};

static int ParticleRef[MAXTF2PLAYERS] = {-1, ...};
static Handle EffectTimer[MAXTF2PLAYERS];

static ArrayList Tinkers;

void Blacksmith_RoundStart()
{
	delete Tinkers;
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
		if(!dieingstate[client] && IsPlayerAlive(client))
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

					i_MaxSupportBuildingsLimit[client] = SupportBuildings[SmithLevel[client]];

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

	ArrayList list = new ArrayList(2);
	
	switch(rarity)
	{
		case 0:
		{
			AddAttrib(list, weapon, 2, 0.95, 1.05);
			AddAttrib(list, weapon, 4, 0.9, 1.1);
			AddAttrib(list, weapon, 6, 0.97, 1.03);
			AddAttrib(list, weapon, 8, 0.95, 1.05);
			AddAttrib(list, weapon, 10, 0.9, 1.1);
			AddAttrib(list, weapon, 45, 0.9, 1.1);
			AddAttrib(list, weapon, 94, 0.9, 1.1);
			AddAttrib(list, weapon, 97, 0.95, 1.05);
			AddAttrib(list, weapon, 99, 0.95, 1.05);
			AddAttrib(list, weapon, 101, 0.95, 1.05);
			AddAttrib(list, weapon, 103, 0.95, 1.05);
			AddAttrib(list, weapon, 287, 0.95, 1.05);
			AddAttrib(list, weapon, 319, 0.9, 1.1);
			AddAttrib(list, weapon, 343, 0.97, 1.03);
			AddAttrib(list, weapon, 410, 0.95, 1.05);
		}
		case 1:
		{
			AddAttrib(list, weapon, 26, 0.9625, 1.05);
			AddAttrib(list, 0, 205, 0.98, 1.015);
			AddAttrib(list, 0, 206, 0.98, 1.015);
			AddAttrib(list, weapon, 412, 0.98, 1.015);
			
			AddAttrib(list, weapon, 1, 0.925, 1.1);
			AddAttrib(list, weapon, 2, 0.925, 1.1);
			AddAttrib(list, weapon, 3, 0.85, 1.2);
			AddAttrib(list, weapon, 4, 0.85, 1.2);
			AddAttrib(list, weapon, 5, 0.96, 1.03);
			AddAttrib(list, weapon, 6, 0.96, 1.03);
			AddAttrib(list, weapon, 8, 0.925, 1.1);
			AddAttrib(list, weapon, 10, 0.85, 1.2);
			AddAttrib(list, weapon, 45, 0.85, 1.2);
			AddAttrib(list, weapon, 94, 0.85, 1.2);
			AddAttrib(list, weapon, 96, 0.9, 1.075);
			AddAttrib(list, weapon, 97, 0.9, 1.075);
			AddAttrib(list, weapon, 99, 0.925, 1.1);
			AddAttrib(list, weapon, 100, 0.925, 1.1);
			AddAttrib(list, weapon, 101, 0.925, 1.1);
			AddAttrib(list, weapon, 102, 0.925, 1.1);
			AddAttrib(list, weapon, 103, 0.925, 1.1);
			AddAttrib(list, weapon, 104, 0.925, 1.1);
			AddAttrib(list, weapon, 287, 0.925, 1.1);
			AddAttrib(list, weapon, 319, 0.85, 1.2);
			AddAttrib(list, weapon, 343, 0.97, 1.04);
			AddAttrib(list, weapon, 410, 0.925, 1.1);
		}
		case 2:
		{
			AddAttrib(list, 0, 107, 0.99, 1.01);
			AddAttrib(list, weapon, 149, 0.8, 1.5);

			AddAttrib(list, weapon, 26, 0.9625, 1.05);
			AddAttrib(list, 0, 205, 0.98, 1.015);
			AddAttrib(list, 0, 206, 0.98, 1.015);
			AddAttrib(list, weapon, 412, 0.98, 1.015);
			
			AddAttrib(list, weapon, 1, 0.95, 1.1);
			AddAttrib(list, weapon, 2, 0.95, 1.1);
			AddAttrib(list, weapon, 3, 0.875, 1.2);
			AddAttrib(list, weapon, 4, 0.875, 1.2);
			AddAttrib(list, weapon, 5, 0.96, 1.02);
			AddAttrib(list, weapon, 6, 0.96, 1.02);
			AddAttrib(list, weapon, 8, 0.95, 1.1);
			AddAttrib(list, weapon, 10, 0.875, 1.2);
			AddAttrib(list, weapon, 45, 0.875, 1.2);
			AddAttrib(list, weapon, 94, 0.875, 1.2);
			AddAttrib(list, weapon, 96, 0.925, 1.075);
			AddAttrib(list, weapon, 97, 0.925, 1.075);
			AddAttrib(list, weapon, 99, 0.95, 1.1);
			AddAttrib(list, weapon, 100, 0.95, 1.1);
			AddAttrib(list, weapon, 101, 0.95, 1.1);
			AddAttrib(list, weapon, 102, 0.95, 1.1);
			AddAttrib(list, weapon, 103, 0.95, 1.1);
			AddAttrib(list, weapon, 104, 0.95, 1.1);
			AddAttrib(list, weapon, 287, 0.95, 1.1);
			AddAttrib(list, weapon, 319, 0.875, 1.2);
			AddAttrib(list, weapon, 343, 0.96, 1.02);
			AddAttrib(list, weapon, 410, 0.95, 1.1);
		}
	}

	if(list.Length == 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Blacksmith Underleveled");

		delete list;
		ApplyBuildingCollectCooldown(entity, client, 2.0);
		return;
	}

	any values[3];

	for(int i = 0; i < (rarity + 2); i++)
	{
		list.GetArray(GetURandomInt() % list.Length, values);
		tinker.Attrib[i] = view_as<int>(values[0]);

		float minVal = view_as<float>(values[1]);
		float maxVal = view_as<float>(values[2]);

		switch(i)
		{
			case 0:	// Always Good
			{
				if(AttribIsInverse(tinker.Attrib[i]))
				{
					maxVal = 0.99;
				}
				else
				{
					minVal = 1.01;
				}
			}
			case 1:	// Always Bad
			{
				if(AttribIsInverse(tinker.Attrib[i]))
				{
					minVal = 1.01;
				}
				else
				{
					maxVal = 0.99;
				}
			}
		}

		tinker.Value[i] = GetRandomFloat(minVal, maxVal);

		PrintAttribValue(client, tinker.Attrib[i], tinker.Value[i]);
	}

	delete list;

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

	Store_ApplyAttribs(client);
	Store_GiveAll(client, GetClientHealth(client));	

	switch(rarity)
	{
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
		case 3:
		{
			ClientCommand(client, "playgamesound ui/quest_status_tick_bonus_complete_halloween.wav");
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

static void AddAttrib(ArrayList list, int entity, int attrib, float low, float high)
{
	if(!entity || (Attributes_Has(entity, attrib) && Attributes_Get(entity, attrib, 1.0) > 0.0))
	{
		static any vals[3];
		vals[0] = attrib;
		vals[1] = low;
		vals[2] = high;
		list.PushArray(vals);
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

static void PrintAttribValue(int client, int attrib, float value)
{
	bool inverse = AttribIsInverse(attrib);
	
	char num[16];
	if(value < 1.0)
	{
		FormatEx(num, sizeof(num), " %d%% ", RoundFloat(((1.0 / value) - 1.0) * 100.0));
	}
	else
	{
		FormatEx(num, sizeof(num), " %d%% ", RoundFloat((value - 1.0) * 100.0));
	}

	num[0] = ((value < 1.0) ^ inverse) ? '-' : '+';

	switch(attrib)
	{
		case 1:
			PrintToChat(client, "%sPhysical Damage", num);
		
		case 2:
			PrintToChat(client, "%sBase Damage", num);
		
		case 3, 4:
			PrintToChat(client, "%sClip Size", num);
		
		case 5, 6:
			PrintToChat(client, "%sFiring Speed", num);
		
		case 8:
			PrintToChat(client, "%sHealing Rate", num);
		
		case 10:
			PrintToChat(client, "%sÜberCharge Rate", num);
		
		case 26:
			PrintToChat(client, "%sMax Health Bonus", num);
		
		case 45:
			PrintToChat(client, "%sBullets Per Shot", num);
		
		case 94:
			PrintToChat(client, "%sRepair Rate", num);
		
		case 96, 97:
			PrintToChat(client, "%sReload Speed", num);
		
		case 99, 100:
			PrintToChat(client, "%sBlast Radius", num);
		
		case 101, 102:
			PrintToChat(client, "%sProjectile Range", num);
		
		case 103, 104:
			PrintToChat(client, "%sProjectile Speed", num);
		
		case 107:
			PrintToChat(client, "%sMovement Speed", num);
		
		case 149:
			PrintToChat(client, "%sBleed Duration", num);
		
		case 205:
			PrintToChat(client, "%sRanged Damage Resistance", num);
		
		case 206:
			PrintToChat(client, "%sMelee Damage Resistance", num);
		
		case 287:
			PrintToChat(client, "%sSentry Damage", num);
		
		case 319:
			PrintToChat(client, "%sBuff Duration", num);
		
		case 343:
			PrintToChat(client, "%sSentry Firing Speed", num);
		
		case 410:
			PrintToChat(client, "%sBase Damage", num);
		
		case 412:
			PrintToChat(client, "%sDamage Resistance", num);
	}
}
