#pragma semicolon 1
#pragma newdecls required

#define TINKER_LIMIT	50

enum struct TinkerEnum
{
	int AccountId;
	int StoreIndex;
	int Attrib[TINKER_LIMIT];
	float Value[TINKER_LIMIT];
}

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

		if(SmithLevel[client] > sizeof(MetalGain))
			SmithLevel[client] = 0;

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
		int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		if(weapon != -1)
		{
			if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BLACKSMITH)
			{
				if(!Waves_InSetup() && GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon)
				{
					SetAmmo(client, Ammo_Metal, GetAmmo(client, Ammo_Metal) + MetalGain[SmithLevel[client]]);
				}

				if(ParticleRef[client] == -1)
				{
					float pos[3]; WorldSpaceCenter(client, pos);
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
				for(int b; b < sizeof(tinker.Attrib); b++)
				{
					if(!tinker.Attrib[0])
					{
						found = a;
						break;
					}
				}

				if(found == -1)
				{
					ClientCommand(client, "playgamesound items/medshotno1.wav");
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Blacksmith Maxed");
					
					ApplyBuildingCollectCooldown(entity, client, 2.0);
					return;
				}
			}
		}
	}

	if(found == -1)
	{
		tinker.AccountId = account;
		tinker.StoreIndex = StoreWeapon[weapon];
		Zero(tinker.Attrib);
	}

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
			AddAttrib(list, weapon, 2, 1.01);
			AddAttrib(list, weapon, 4, 1.05);
			AddAttrib(list, weapon, 6, 0.99);
			AddAttrib(list, weapon, 8, 1.02);
			AddAttrib(list, weapon, 10, 1.05);
			AddAttrib(list, weapon, 45, 1.05);
			AddAttrib(list, weapon, 94, 1.05);
			AddAttrib(list, weapon, 97, 0.99);
			AddAttrib(list, weapon, 99, 1.05);
			AddAttrib(list, weapon, 101, 1.02);
			AddAttrib(list, weapon, 103, 1.02);
			AddAttrib(list, weapon, 287, 1.02);
			AddAttrib(list, weapon, 319, 1.05);
			AddAttrib(list, weapon, 343, 0.98);
			AddAttrib(list, weapon, 410, 1.01);
		}
		case 1:
		{
			AddAttrib(list, weapon, 26, 1.01);
			AddAttrib(list, 0, 205, 0.99);
			AddAttrib(list, 0, 206, 0.99);
			AddAttrib(list, weapon, 412, 0.99);
			
			AddAttrib(list, weapon, 1, 1.02);
			AddAttrib(list, weapon, 2, 1.02);
			AddAttrib(list, weapon, 3, 1.1);
			AddAttrib(list, weapon, 4, 1.1);
			AddAttrib(list, weapon, 5, 0.98);
			AddAttrib(list, weapon, 6, 0.98);
			AddAttrib(list, weapon, 8, 1.02);
			AddAttrib(list, weapon, 10, 1.05);
			AddAttrib(list, weapon, 45, 1.1);
			AddAttrib(list, weapon, 94, 1.1);
			AddAttrib(list, weapon, 96, 0.98);
			AddAttrib(list, weapon, 97, 0.98);
			AddAttrib(list, weapon, 99, 1.1);
			AddAttrib(list, weapon, 100, 1.1);
			AddAttrib(list, weapon, 101, 1.05);
			AddAttrib(list, weapon, 102, 1.05);
			AddAttrib(list, weapon, 103, 1.05);
			AddAttrib(list, weapon, 104, 1.05);
			AddAttrib(list, weapon, 287, 1.04);
			AddAttrib(list, weapon, 319, 1.1);
			AddAttrib(list, weapon, 343, 0.96);
			AddAttrib(list, weapon, 410, 1.02);
		}
		case 2:
		{
			AddAttrib(list, 0, 107, 1.01);
			AddAttrib(list, weapon, 149, 1.25);
			AddAttrib(list, 0, 208, 2.0);

			AddAttrib(list, weapon, 26, 1.03);
			AddAttrib(list, 0, 205, 0.98);
			AddAttrib(list, 0, 206, 0.98);
			AddAttrib(list, weapon, 412, 0.98);
			
			AddAttrib(list, weapon, 1, 1.04);
			AddAttrib(list, weapon, 2, 1.04);
			AddAttrib(list, weapon, 3, 1.2);
			AddAttrib(list, weapon, 4, 1.2);
			AddAttrib(list, weapon, 5, 0.96);
			AddAttrib(list, weapon, 6, 0.96);
			AddAttrib(list, weapon, 8, 1.04);
			AddAttrib(list, weapon, 10, 1.1);
			AddAttrib(list, weapon, 45, 1.2);
			AddAttrib(list, weapon, 94, 1.2);
			AddAttrib(list, weapon, 96, 0.95);
			AddAttrib(list, weapon, 97, 0.95);
			AddAttrib(list, weapon, 99, 1.2);
			AddAttrib(list, weapon, 100, 1.2);
			AddAttrib(list, weapon, 101, 1.1);
			AddAttrib(list, weapon, 102, 1.1);
			AddAttrib(list, weapon, 103, 1.1);
			AddAttrib(list, weapon, 104, 1.1);
			AddAttrib(list, weapon, 287, 1.08);
			AddAttrib(list, weapon, 319, 1.2);
			AddAttrib(list, weapon, 343, 0.92);
			AddAttrib(list, weapon, 410, 1.04);
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

	delete list;

	int pos = GetURandomInt() % list.Length;

	any values[2];
	list.GetArray(pos, values);
	int attrib = view_as<int>(values[0]);
	float value = view_as<float>(values[0]);

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
	}

	float cooldown = Cooldowns[SmithLevel[owner]];
	if(client != owner && Store_HasWeaponKit(client))
		cooldown *= 0.5;
	
	ApplyBuildingCollectCooldown(entity, client, cooldown);

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

	switch(attrib)
	{
		case 1:
			PrintToChat(client, "+%d%% Physical Damage", RoundFloat((value - 1.0) * 100.0));
		
		case 2:
			PrintToChat(client, "+%d%% Base Damage", RoundFloat((value - 1.0) * 100.0));
		
		case 3, 4:
			PrintToChat(client, "+%d%% Clip Size", RoundFloat((value - 1.0) * 100.0));
		
		case 5, 6:
			PrintToChat(client, "+%d%% Firing Speed", RoundFloat((1.0 / value) * 100.0));
		
		case 8:
			PrintToChat(client, "+%d%% Healing Rate", RoundFloat((value - 1.0) * 100.0));
		
		case 10:
			PrintToChat(client, "+%d%% ÜberCharge Rate", RoundFloat((value - 1.0) * 100.0));
		
		case 26:
			PrintToChat(client, "+%d%% Max Health Bonus", RoundFloat((value - 1.0) * 100.0));
		
		case 45:
			PrintToChat(client, "+%d%% Bullets Per Shot", RoundFloat((value - 1.0) * 100.0));
		
		case 94:
			PrintToChat(client, "+%d%% Repair Rate", RoundFloat((value - 1.0) * 100.0));
		
		case 96, 97:
			PrintToChat(client, "+%d%% Reload Speed", RoundFloat((1.0 / value) * 100.0));
		
		case 99, 100:
			PrintToChat(client, "+%d%% Blast Radius", RoundFloat((value - 1.0) * 100.0));
		
		case 101, 102:
			PrintToChat(client, "+%d%% Projectile Range", RoundFloat((value - 1.0) * 100.0));
		
		case 103, 104:
			PrintToChat(client, "+%d%% Projectile Speed", RoundFloat((value - 1.0) * 100.0));
		
		case 107:
			PrintToChat(client, "+%d%% Movement Speed", RoundFloat((value - 1.0) * 100.0));
		
		case 149:
			PrintToChat(client, "+%d%% Bleed Duration", RoundFloat((value - 1.0) * 100.0));
		
		case 205:
			PrintToChat(client, "+%d%% Ranged Damage Resistance", RoundFloat((1.0 / value) * 100.0));
		
		case 206:
			PrintToChat(client, "+%d%% Melee Damage Resistance", RoundFloat((1.0 / value) * 100.0));
		
		case 287:
			PrintToChat(client, "+%d%% Sentry Damage", RoundFloat((value - 1.0) * 100.0));
		
		case 319:
			PrintToChat(client, "+%d%% Buff Duration", RoundFloat((value - 1.0) * 100.0));
		
		case 343:
			PrintToChat(client, "+%d%% Sentry Firing Speed", RoundFloat((1.0 / value) * 100.0));
		
		case 410:
			PrintToChat(client, "+%d%% Base Damage", RoundFloat((value - 1.0) * 100.0));
		
		case 412:
			PrintToChat(client, "+%d%% Damage Resistance", RoundFloat((1.0 / value) * 100.0));
		
		default:
			PrintToChat(client, "+%d%% Chaos", RoundFloat((value - 1.0) * 100.0));
	}

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
			case 2:
			{
				ClientCommand(owner, "playgamesound ui/quest_status_tick_expert_friend.wav");
			}
		}
	}
}

static void AddAttrib(ArrayList list, int entity, int attrib, float multi)
{
	if(!entity || (Attributes_Has(entity, attrib) && Attributes_Get(entity, attrib, 1.0) > 0.0))
	{
		static any vals[2];
		vals[0] = attrib;
		vals[1] = multi;
		list.PushArray(vals);
	}
}
