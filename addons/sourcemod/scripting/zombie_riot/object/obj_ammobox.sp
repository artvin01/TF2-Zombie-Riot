#pragma semicolon 1
#pragma newdecls required

void ObjectAmmobox_MapStart()
{
	PrecacheModel("models/items/ammocrate_smg1.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Ammo Box");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_ammobox");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);

	BuildingInfo build;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_ammobox");
	build.Cost = 600;
	build.Health = 50;
	build.Cooldown = 20.0;
	build.Func = ObjectGeneric_CanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectAmmobox(client, vecPos, vecAng);
}


methodmap ObjectAmmobox < ObjectGeneric
{
	public ObjectAmmobox(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectAmmobox npc = view_as<ObjectAmmobox>(ObjectGeneric(client, vecPos, vecAng, "models/items/ammocrate_smg1.mdl", _,"50", {20.0, 20.0, 33.0}, 15.0));
		
		npc.SetActivity("Idle", true);

		npc.FuncCanUse = ClotCanUse;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCThink[npc.index] = ClotThink;
		func_NPCInteract[npc.index] = ClotInteract;

		return npc;
	}
}

static void ClotThink(ObjectAmmobox npc)
{
	if(npc.m_flAttackHappens)
	{
		float gameTime = GetGameTime(npc.index);

		if(npc.m_flAttackHappens > 999999.9)
		{
			npc.SetActivity("Open", true);
			npc.SetPlaybackRate(0.5);	
			npc.m_flAttackHappens = gameTime + 0.6;
		}
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.SetActivity("Close", true);
			npc.SetPlaybackRate(0.5);
			npc.m_flAttackHappens = 0.0;
		}
	}
}

static bool ClotCanUse(ObjectAmmobox npc, int client)
{
	if(Building_Collect_Cooldown[npc.index][client] > GetGameTime())
		return false;
	
	if((Ammo_Count_Ready - Ammo_Count_Used[client]) < 1)
		return false;

	return true;
}

static void ClotShowInteractHud(ObjectAmmobox npc, int client)
{
	SetGlobalTransTarget(client);
	PrintCenterText(client, "%t", "Ammobox Tooltip", Ammo_Count_Ready - Ammo_Count_Used[client]);
}

static bool ClotInteract(int client, int weapon, ObjectAmmobox npc)
{
	if(ClotCanUse(npc, client))
	{
	//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
	//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
	//	ApplyBuildingCollectCooldown(npc.index, client, 5.0, true);
		
		//Trying to apply animations outside of clot think can fail to work.


	//	npc.SetActivity("Open", true);
	//	npc.SetPlaybackRate(0.5);
	//	npc.m_flAttackHappens = GetGameTime(npc.index) + 1.4;
		int UsedBoxLogic = AmmoboxUsed(client, npc.index);
		if(UsedBoxLogic >= 1)
		{
			int owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
			if(UsedBoxLogic >= 2)
			{
				Building_GiveRewardsUse(client, owner, 10, true, 0.35, true);
				Barracks_TryRegenIfBuilding(client);
			}
			Building_GiveRewardsUse(client, owner, 10, true, 0.35, true);
			Barracks_TryRegenIfBuilding(client);
		}
		npc.m_flAttackHappens = GetGameTime(npc.index) + 999999.4;
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
	}
	
	return true;
}


int AmmoboxUsed(int client, int entity)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	/*
	int ie, weapon1;
	while(TF2_GetItem(client, weapon1, ie))
	{
		if(IsValidEntity(weapon1))
		{
			int Ammo_type = GetAmmoType_WeaponPrimary(weapon1);
			if(Ammo_type > 0 && Ammo_type != Ammo_Potion_Supply && Ammo_type != Ammo_Hand_Grenade)
			{
				//found a weapon that has ammo.
				if(GetAmmo(client, Ammo_type) <= 0)
				{
					weapon = weapon1;
					break;
				}
			}
		}
	}
	*/

	if(IsValidEntity(weapon))
	{
		if(i_IsWandWeapon[weapon])
		{
			ManaCalculationsBefore(client);

		//	mana_regen_temp *= 0.5;
			
			if(Current_Mana[client] < RoundToCeil(max_mana[client] * 2.0))
			{
				Ammo_Count_Used[client] += 2;
				ClientCommand(client, "playgamesound items/ammo_pickup.wav");
				ClientCommand(client, "playgamesound items/ammo_pickup.wav");
				if(Current_Mana[client] < RoundToCeil(max_mana[client] * 2.0))
				{
					Current_Mana[client] += RoundToCeil(mana_regen[client] * 10.0);
					
					if(Current_Mana[client] > RoundToCeil(max_mana[client] * 2.0)) //Should only apply during actual regen
						Current_Mana[client] = RoundToCeil(max_mana[client] * 2.0);
				}

				ApplyBuildingCollectCooldown(entity, client, 5.0, true);
				Mana_Hud_Delay[client] = 0.0;
				return 2;
			}
			else
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Max Mana Reached");
			}
		}
		else
		{
			int Ammo_type = GetAmmoType_WeaponPrimary(weapon);
			int weaponindex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
			if (i_WeaponAmmoAdjustable[weapon])
			{
				ClientCommand(client, "playgamesound items/ammo_pickup.wav");
				ClientCommand(client, "playgamesound items/ammo_pickup.wav");
				AddAmmoClient(client, i_WeaponAmmoAdjustable[weapon] ,_,2.0);
				Ammo_Count_Used[client] += 1;
				for(int i; i<Ammo_MAX; i++)
				{
					CurrentAmmo[client][i] = GetAmmo(client, i);
				}
				ApplyBuildingCollectCooldown(entity, client, 5.0, true);
				return true;
			}
			else if(weaponindex == 211 || weaponindex == 998)
			{
				ClientCommand(client, "playgamesound items/ammo_pickup.wav");
				ClientCommand(client, "playgamesound items/ammo_pickup.wav");
				AddAmmoClient(client, 21 ,_,2.0);
				Ammo_Count_Used[client] += 1;
				for(int i; i<Ammo_MAX; i++)
				{
					CurrentAmmo[client][i] = GetAmmo(client, i);
				}	
				ApplyBuildingCollectCooldown(entity, client, 5.0, true);
				return true;
			}
			else if(weaponindex == 411)
			{
				ClientCommand(client, "playgamesound items/ammo_pickup.wav");
				ClientCommand(client, "playgamesound items/ammo_pickup.wav");
				AddAmmoClient(client, 22 ,_,2.0);
				Ammo_Count_Used[client] += 1;
				for(int i; i<Ammo_MAX; i++)
				{
					CurrentAmmo[client][i] = GetAmmo(client, i);
				}	
				ApplyBuildingCollectCooldown(entity, client, 5.0, true);
				return true;
			}
			else if(weaponindex == 441 || weaponindex == 35)
			{
				ClientCommand(client, "playgamesound items/ammo_pickup.wav");
				ClientCommand(client, "playgamesound items/ammo_pickup.wav");
				AddAmmoClient(client, 23 ,_,2.0);
				Ammo_Count_Used[client] += 1;
				for(int i; i<Ammo_MAX; i++)
				{
					CurrentAmmo[client][i] = GetAmmo(client, i);
				}		
				ApplyBuildingCollectCooldown(entity, client, 5.0, true);
				return true;
			}
			else if(AmmoBlacklist(Ammo_type) && i_OverrideWeaponSlot[weapon] != 2) //Disallow Ammo_Hand_Grenade, that ammo type is regenerative!, dont use jar, tf2 needs jar? idk, wierdshit.
			{
				ClientCommand(client, "playgamesound items/ammo_pickup.wav");
				ClientCommand(client, "playgamesound items/ammo_pickup.wav");
				AddAmmoClient(client, Ammo_type ,_,2.0);
				Ammo_Count_Used[client] += 1;
				for(int i; i<Ammo_MAX; i++)
				{
					CurrentAmmo[client][i] = GetAmmo(client, i);
				}
				ApplyBuildingCollectCooldown(entity, client, 5.0, true);
				return true;
			}
			else
			{
				int Armor_Max = 150;
			
				Armor_Max = MaxArmorCalculation(Armor_Level[client], client, 0.75);
					
				if(Armor_Charge[client] < Armor_Max)
				{
					GiveArmorViaPercentage(client, 0.1, 1.0);
					ApplyBuildingCollectCooldown(entity, client, 5.0, true);
					Ammo_Count_Used[client] += 1;
					
					ClientCommand(client, "playgamesound ambient/machines/machine1_hit2.wav");
					return true;
				}
				else
				{
					ClientCommand(client, "playgamesound items/medshotno1.wav");
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "%t" , "Armor Max Reached Ammo Box");
					return false;
				}
			}
		}
	}
	return false;
}