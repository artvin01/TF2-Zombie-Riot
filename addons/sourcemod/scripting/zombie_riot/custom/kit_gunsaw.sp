#pragma semicolon 1
#pragma newdecls required

static const float MaxMulti = 3.0;	// Max health multi after cap (3.0 is x3 of HealthCap)
static const float MaxSlow = 2.0;	// Max speed nerf at max health	(2.0 is -50% speed)

// Health cap before speed nerf
static const int HealthCap[] =
{
	200,
	300,
	450,
	600,
	850,
	1450,
	2050
};

// Gun damage increase (ranged upgrades)
static const float GunMulti[] =
{
	1.0,
	1.0,
	1.5,
	2.0,
	3.0,
	5.0,
	9.0
};

static ArrayList GunListing[2][5];
static int ModelHealth[MAXPLAYERS];
static float ModelMeleeRes[MAXPLAYERS];
static float ModelRangedRes[MAXPLAYERS];
static bool ModelRobot[MAXPLAYERS];
static ArrayList ModelModels[MAXPLAYERS];
static int WeaponLevel[MAXPLAYERS];
static int EquippedWeapons[MAXPLAYERS][2][2];
static int NextWeapons[MAXPLAYERS][2][2];
static Function OgEntityFuncAttack[MAXENTITIES][2];
static Handle WeaponTimer[MAXPLAYERS];
static bool RecentlySwapped[MAXPLAYERS];

static int LaserIndex;
static bool Precached = false;

void Gunsaw_MapStart()
{
	LaserIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
	Precached = false;

	for(int i; i < sizeof(ModelModels); i++)
	{
		delete ModelModels[i];
	}
}

void Gunsaw_Precache()
{
	if(!Precached)
	{
		PrecacheSoundCustom("#zombiesurvival/flaggilant_lastman.mp3",_,1);
		Precached = true;
	}
}

static void PrecacheStore()
{
	if(GunListing[0][0])
		return;
	
	for(int a; a < sizeof(GunListing); a++)
	{
		for(int b; b < sizeof(GunListing[]); b++)
		{
			GunListing[a][b] = new ArrayList(2);
		}
	}

	AddGun(0, TFWeaponSlot_Primary, "Syringe Gun", 0);
	AddGun(0, TFWeaponSlot_Secondary, "Flaregun", 0);
	AddGun(0, TFWeaponSlot_Secondary, "USP", 0);
	AddGun(0, TFWeaponSlot_Secondary, "The Righteous Bison", 0);
	AddGun(0, TFWeaponSlot_Primary, "Sniper Rifle", 0);
	AddGun(0, TFWeaponSlot_Primary, "Shotgun", 0);
	AddGun(0, TFWeaponSlot_Secondary, "SMG", 0);
	AddGun(0, TFWeaponSlot_Primary, "Deagle", 0);

	AddGun(1, TFWeaponSlot_Primary, "Syringe Gun", 1);
	AddGun(1, TFWeaponSlot_Secondary, "Flaregun", 1);
	AddGun(1, TFWeaponSlot_Secondary, "USP", 1);
	AddGun(1, TFWeaponSlot_Primary, "The Righteous Bison", 1);
	AddGun(1, TFWeaponSlot_Primary, "Sniper Rifle", 1);
	AddGun(1, TFWeaponSlot_Primary, "Shotgun", 1);
	AddGun(1, TFWeaponSlot_Primary, "Shotgun", 2);
	AddGun(1, TFWeaponSlot_Secondary, "SMG", 1);
	AddGun(1, TFWeaponSlot_Primary, "Huntsman", 1);
	AddGun(1, TFWeaponSlot_Primary, "Deagle", 1);
	AddGun(1, TFWeaponSlot_Primary, "Flamethrower", 0);
	AddGun(1, TFWeaponSlot_Primary, "Grenade Launcher", 0);
	AddGun(1, TFWeaponSlot_Primary, "Tommygun", 0);
	AddGun(1, TFWeaponSlot_Secondary, "Stickybomb Launcher", 0);
	AddGun(1, TFWeaponSlot_Primary, "Double Barrel Shotgun", 0);

	AddGun(2, TFWeaponSlot_Primary, "Syringe Gun", 1);
	AddGun(2, TFWeaponSlot_Secondary, "Flaregun", 2);
	AddGun(2, TFWeaponSlot_Secondary, "USP", 2);
	AddGun(2, TFWeaponSlot_Primary, "The Righteous Bison", 2);
	AddGun(2, TFWeaponSlot_Primary, "Sniper Rifle", 1);
	AddGun(2, TFWeaponSlot_Primary, "Shotgun", 3);
	AddGun(2, TFWeaponSlot_Primary, "Shotgun", 6);
	AddGun(2, TFWeaponSlot_Secondary, "SMG", 2);
	AddGun(2, TFWeaponSlot_Primary, "Huntsman", 1);
	AddGun(2, TFWeaponSlot_Primary, "Deagle", 2);
	AddGun(2, TFWeaponSlot_Primary, "Deagle", 4);
	AddGun(2, TFWeaponSlot_Primary, "Flamethrower", 1);
	AddGun(2, TFWeaponSlot_Primary, "Grenade Launcher", 1);
	AddGun(2, TFWeaponSlot_Primary, "Tommygun", 1);
	AddGun(2, TFWeaponSlot_Secondary, "Stickybomb Launcher", 1);
	AddGun(2, TFWeaponSlot_Primary, "Double Barrel Shotgun", 1);

	AddGun(3, TFWeaponSlot_Primary, "Syringe Gun", 2);
	AddGun(3, TFWeaponSlot_Secondary, "Flaregun", 3);
	AddGun(3, TFWeaponSlot_Secondary, "USP", 3);
	AddGun(3, TFWeaponSlot_Primary, "Sniper Rifle", 2);
	AddGun(3, TFWeaponSlot_Primary, "Shotgun", 4);
	AddGun(3, TFWeaponSlot_Primary, "Shotgun", 7);
	AddGun(3, TFWeaponSlot_Secondary, "SMG", 3);
	AddGun(3, TFWeaponSlot_Primary, "Huntsman", 5);
	AddGun(3, TFWeaponSlot_Primary, "Deagle", 3);
	AddGun(3, TFWeaponSlot_Primary, "Deagle", 6);
	AddGun(3, TFWeaponSlot_Primary, "Deagle", 8);
	AddGun(3, TFWeaponSlot_Primary, "Grenade Launcher", 3);
	AddGun(3, TFWeaponSlot_Primary, "Tommygun", 2);
	AddGun(3, TFWeaponSlot_Secondary, "Stickybomb Launcher", 2);
	AddGun(3, TFWeaponSlot_Primary, "Double Barrel Shotgun", 2);

	AddGun(4, TFWeaponSlot_Primary, "Syringe Gun", 3);
	AddGun(4, TFWeaponSlot_Secondary, "Flaregun", 4);
	AddGun(4, TFWeaponSlot_Secondary, "USP", 4);
	AddGun(4, TFWeaponSlot_Primary, "The Righteous Bison", 4);
	AddGun(4, TFWeaponSlot_Primary, "Sniper Rifle", 3);
	AddGun(4, TFWeaponSlot_Primary, "Shotgun", 5);
	AddGun(4, TFWeaponSlot_Primary, "Shotgun", 8);
	AddGun(4, TFWeaponSlot_Secondary, "SMG", 4);
	AddGun(4, TFWeaponSlot_Secondary, "SMG", 5);
	AddGun(4, TFWeaponSlot_Secondary, "SMG", 6);
	AddGun(4, TFWeaponSlot_Primary, "Huntsman", 6);
	AddGun(4, TFWeaponSlot_Primary, "Deagle", 5);
	AddGun(4, TFWeaponSlot_Primary, "Deagle", 7);
	AddGun(4, TFWeaponSlot_Primary, "Deagle", 9);
	AddGun(4, TFWeaponSlot_Primary, "Grenade Launcher", 4);
	AddGun(4, TFWeaponSlot_Primary, "Tommygun", 3);
	AddGun(4, TFWeaponSlot_Secondary, "Stickybomb Launcher", 3);
	AddGun(4, TFWeaponSlot_Primary, "Double Barrel Shotgun", 3);
	AddGun(4, TFWeaponSlot_Secondary, "Brick", 0);
}

void Gunsaw_StoreReloaded()
{
	for(int a; a < sizeof(GunListing); a++)
	{
		for(int b; b < sizeof(GunListing[]); b++)
		{
			delete GunListing[a][b];
		}
	}
}

bool Gunsaw_CanPapItem(int client, int index)
{
	for(int i; i < sizeof(EquippedWeapons[]); i++)
	{
		if(index == EquippedWeapons[client][i][0])
			return false;
	}

	return true;
}

void Gunsaw_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_GUNSAW)
	{
		WeaponLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));
		if(WeaponLevel[client] < 0)
		{
			WeaponLevel[client] = 0;
		}
		else if(WeaponLevel[client] >= sizeof(HealthCap))
		{
			WeaponLevel[client] = sizeof(HealthCap) - 1;
		}

		Gunsaw_Precache();

		for(int i; i < sizeof(EquippedWeapons[]); i++)
		{
			if(i < WeaponLevel[client])
				continue;
			
			if(!EquippedWeapons[client][i])
			{
				RollNextGun(client, i);
				SwapGunSlot(client, i, true);
				RollNextGun(client, i);
			}
			else if(!NextWeapons[client][i])
			{
				RollNextGun(client, i);
			}
		}

		RequestFrame(ApplyGunsawStats, EntIndexToEntRef(weapon));

		delete WeaponTimer[client];

		DataPack pack;
		WeaponTimer[client] = CreateDataTimer(0.2, GunsawHudTimer, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(GetClientUserId(client));
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
	else if(EquippedWeapons[client][0][0] || EquippedWeapons[client][1][0])
	{
		i_Hex_WeaponUsesTheseAbilities[weapon] |= ABILITY_M2;
		OgEntityFuncAttack[weapon][0] = EntityFuncAttack2[weapon];
		EntityFuncAttack2[weapon] = Weapon_GunsawRanged_M2;

		i_Hex_WeaponUsesTheseAbilities[weapon] |= ABILITY_R;
		OgEntityFuncAttack[weapon][1] = EntityFuncAttack3[weapon];
		EntityFuncAttack3[weapon] = Weapon_GunsawRanged_R;

		Attributes_SetMulti(weapon, 2, GunMulti[WeaponLevel[client]]);
		
		if(ModelModels[client])
		{
			Attributes_SetMulti(weapon, 205, ModelRangedRes[client]);
			Attributes_SetMulti(weapon, 206, ModelMeleeRes[client]);
		}
	}
}

static void ApplyGunsawStats(int ref)
{
	int weapon = EntRefToEntIndex(ref);
	if(weapon != -1)
	{
		int client = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
		if(client != -1 && ModelModels[client])
		{
			char model[PLATFORM_MAX_PATH];

			int entity, a, b;
			while(TF2U_GetWearable(client, entity, a))
			{
				if(ViewChange_IsViewmodelRef(EntIndexToEntRef(entity)))
					continue;
				
				int index = (b < ModelModels[client].Length) ? ModelModels[client].Get(b) : -1;
				if(index > 0)
				{
					GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
				}
				else
				{
					model[0] = 0;
				}

				SetEntityModel(entity, model[0] ? model : "models/empty.mdl");
			}
			
			float melee = ModelMeleeRes[client];
			float ranged = ModelRangedRes[client];

			// Count resistances towards our health cap
			float health = float(ModelHealth[client] - 100);
			float cap = HealthCap[WeaponLevel[client]] * MaxMulti / (melee * ranged);
			if(health > cap)
				health = cap;

			// More effective health = more fat
			float fat = ((health / cap) * (MaxSlow / MaxMulti)) - 1.0;
			if(fat < 1.0)
				fat = 1.0;
			
			Attributes_Set(weapon, 26, health);
			Attributes_Set(weapon, 107, 1.0 / fat);
			Attributes_Set(weapon, 205, ranged);
			Attributes_Set(weapon, 206, melee);
		}
	}
}

void Gunsaw_PlayerModel(int client, bool &robot)
{
	if(i_HealthBeforeSuit[client] || !ModelModels[client])
		return;
	
	robot = ModelRobot[client];
}

bool Gunsaw_IsMerc(int client)
{
	return view_as<bool>(WeaponTimer[client]);
}

void Gunsaw_TryBodySteal(int client, bool regen)
{
	if(WeaponTimer[client])
	{
		int target = GetClosestTarget(client, true, 1000.0, true, .fldistancelimitAllyNPC = 1000.0, .IgnorePlayers = true, .ExtraValidityFunction = StealBodyFunc);
		if(target != -1)
		{
			StealBodyForm(client, target);

			float pos[3], ang[3];
			GetEntPropVector(target, Prop_Data, "m_vecOrigin", pos);
			GetEntPropVector(target, Prop_Data, "m_angRotation", ang);

			view_as<CClotBody>(target).m_iHealthBar = 0;
			SetEntityHealth(target, 1);
			b_DissapearOnDeath[target] = true;
			RemoveSpecificBuff(target, "Infinite Will");
			SDKHooks_TakeDamage(target, client, client, GetRandomFloat(99999.0,9999999.0), DMG_BLAST, -1, {0.1,0.1,0.1}, _, _, ZR_SLAY_DAMAGE);

			TeleportEntity(client, pos, ang);
		}
		
		if(regen)
			RequestFrame(SetHealthAfterReviveRaid, EntIndexToEntRef(client));
	}
}

static bool StealBodyFunc(int client, int target)
{
	if(!ValidSwapTarget(target))
		return false;
	
	CNavArea startArea = TheNavMesh.GetNavAreaEntity(client, view_as<GetNavAreaFlags_t>(0));
	if(startArea == NULL_AREA)
		return false;
	
	CNavArea endArea = TheNavMesh.GetNavAreaEntity(target, view_as<GetNavAreaFlags_t>(0));
	if(endArea == NULL_AREA)
		return false;
	
	float pos[3];
	GetEntPropVector(target, Prop_Data, "m_vecOrigin", pos);
	return TheNavMesh.BuildPath(startArea, endArea, pos, .teamID = 2);
}

static void StealBodyForm(int client, int entity)
{
	ModelHealth[client] = GetEntProp(entity, Prop_Data, "m_iMaxHealth") / 10;
	if(ModelHealth[client] < 0)
		ModelHealth[client] = 0;
	
	ModelMeleeRes[client] = clamp(fl_MeleeArmor[client] * fl_Extra_MeleeArmor[client], 0.5, 2.0);
	ModelRangedRes[client] = clamp(fl_RangedArmor[client] * fl_Extra_RangedArmor[client], 0.5, 2.0);

	delete ModelModels[client];
	ModelModels[client] = new ArrayList();

	TFClassType class;

	char model[PLATFORM_MAX_PATH];
	GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
	ReplaceString(model, sizeof(model), "\\", "/");

	if(StrContains(model, "combine_attachment_police", false) != -1)
	{
		class = TFClass_Pyro;
		ModelRobot[client] = false;
	}
	else if(ReplaceStringEx(model, sizeof(model), "models/player/", "", _, _, false) != -1)
	{
		int pos = FindCharInString(model, '.', true);
		if(pos != -1)
			model[pos] = '\0';

		class = TF2_GetClass(model);
		ModelRobot[client] = false;
	}
	else if(ReplaceStringEx(model, sizeof(model), "models/bots/", "", _, _, false) != -1)
	{
		int pos = FindCharInString(model, '/', true);
		if(pos != -1)
			model[pos] = '\0';

		class = TF2_GetClass(model);
		ModelRobot[client] = true;
	}
	else if(StrContains(model, "models/zombie/", false) != -1)
	{
		if(StrContains(model, "fast", false) != -1)
		{
			class = TFClass_Scout;
		}
		else if(StrContains(model, "poison", false) != -1)
		{
			class = TFClass_Heavy;
		}
		else
		{
			class = TFClass_Sniper;
		}

		ModelRobot[client] = false;
	}

	if(class == TFClass_Unknown)
	{
		class = CurrentClass[client];
	}
	else if(!i_CurrentEquippedPerk[client])
	{
		switch(class)
		{
			case TFClass_Scout:
				i_CurrentEquippedPerk[client] = PERK_HASTY_HOPS;
			
			case TFClass_Soldier:
				i_CurrentEquippedPerk[client] = PERK_TESLAR_MULE;
			
			case TFClass_Pyro:
				i_CurrentEquippedPerk[client] = PERK_ENERGY_DRINK;
			
			case TFClass_DemoMan:
				i_CurrentEquippedPerk[client] = PERK_MORNING_COFFEE;
			
			case TFClass_Heavy:
				i_CurrentEquippedPerk[client] = PERK_OBSIDIAN;
			
			case TFClass_Engineer:
				i_CurrentEquippedPerk[client] = PERK_STOCKPILE_STOUT;
			
			case TFClass_Medic:
				i_CurrentEquippedPerk[client] = PERK_REGENE;
			
			case TFClass_Sniper:
				i_CurrentEquippedPerk[client] = PERK_MARKSMAN_BEER;
			
			case TFClass_Spy:
				i_CurrentEquippedPerk[client] = PERK_BLOODY;
		}

		i_CurrentEquippedPerkPreviously[client] = i_CurrentEquippedPerk[client];
	}
	
	Format(model, sizeof(model), "models/workshop/player/items/all_class/dec23_cozy_coverup_style3/dec23_cozy_coverup_style3_%s.mdl", g_RandomizerClasses[class]);
	int index = PrecacheModel(model);
	if(index)
		ModelModels[client].Push(index);

	for(int i; i < sizeof(i_Wearable[]); i++)
	{
		int wearable = EntRefToEntIndex(i_Wearable[entity][i]);
		if(wearable != -1)
		{
			index = GetEntProp(entity, Prop_Send, "m_nModelIndex");
			ModelIndexToString(index, model, sizeof(model));
			if(model[0] && StrContains(model, "player/items", false) != -1)
			{
				ModelModels[client].Push(index);
			}
		}
	}

	if(CurrentClass[client] != class)
	{
		CurrentClass[client] = class;
		TF2_SetPlayerClass_ZR(client, class);
	}

	Store_ApplyAttribs(client);
	Store_GiveAll(client, GetClientHealth(client));
}

static bool ValidSwapTarget(int entity)
{
	if(IsInvuln(entity) ||
			b_thisNpcIsABoss[entity] ||
			b_thisNpcIsARaid[entity] ||
			b_thisNpcIsAMiniboss[entity] ||
			b_IsGiant[entity] ||
			b_StaticNPC[entity] ||
			i_IsABuilding[entity] ||
			i_NpcIsABuilding[entity] ||
			GetTeam(entity) == TFTeam_Stalkers)
	{
		return false;
	}
	
	char model[PLATFORM_MAX_PATH];
	GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
	ReplaceString(model, sizeof(model), "\\", "/");

	if(StrContains(model, "combine_attachment_police", false) != -1)
		return true;
	
	if(StrContains(model, "models/player/", false) != -1)
		return true;
	
	if(StrContains(model, "models/bots/", false) != -1)
		return true;
	
	if(StrContains(model, "models/zombie/", false) != -1)
		return true;
	
	return false;
}

static void RollNextGun(int client, int slot)
{
	PrecacheStore();

	int rank = WeaponLevel[client];
	if(rank >= sizeof(GunListing[]))
		rank = sizeof(GunListing[]) - 1;
	
	int length = GunListing[slot][rank].Length;
	int rand = GetURandomInt() % length;
	int data[2];
	GunListing[slot][rank].GetArray(rand, data);
	
	if(data[0] == EquippedWeapons[client][slot][0])
	{
		rand++;
		if(rand >= length)
			rand = length;
		
		GunListing[slot][rank].GetArray(rand, data);
	}
	
	if(data[0] == NextWeapons[client][slot][0])
	{
		rand++;
		if(rand >= length)
			rand = length;
		
		GunListing[slot][rank].GetArray(rand, data);
	}

	NextWeapons[client][slot] = data;
}

static void SwapGunSlot(int client, int slot, bool first = false)
{
	if(!RecentlySwapped[client])
	{
		RecentlySwapped[client] = true;

		int type = Store_GetAmmoType(client, NextWeapons[client][slot][0], NextWeapons[client][slot][1]);
		if(type > 0 && type < sizeof(CurrentAmmo[]))
			AddAmmoClient(client, type, _, 4.0, true);
	}
	
	for(int i; i < sizeof(EquippedWeapons[]); i++)
	{
		if(abs(EquippedWeapons[client][i][0]) == NextWeapons[client][slot][0])
			return;
	}

	if(EquippedWeapons[client][slot][0])
	{
		if(EquippedWeapons[client][slot][0] > 0)
		{
			Store_RemoveSpecificItem(client, NULL_STRING, _, EquippedWeapons[client][slot][0]);
		}
		else
		{
			Store_Unequip(client, abs(EquippedWeapons[client][slot][0]));
		}
		
		EquippedWeapons[client][slot][0] = 0;
	}

	if(Store_HasIndexItem(client, NextWeapons[client][slot][0]))
	{
		Store_Equip(client, NextWeapons[client][slot][0]);
		EquippedWeapons[client][slot][0] = -NextWeapons[client][slot][0];
		EquippedWeapons[client][slot][1] = 0;
	}
	else
	{
		Store_GiveSpecificItem(client, NULL_STRING, _, NextWeapons[client][slot][0], NextWeapons[client][slot][1] + 1);
		EquippedWeapons[client][slot] = NextWeapons[client][slot];
	}

	if(GameRules_GetRoundState() == RoundState_ZombieRiot)
	{
		Store_ApplyCooldownIndex(client, NextWeapons[client][slot][0], 3, 50.0 + (slot * 30.0));
		RecentlySwapped[client] = !first;
	}
	else
	{
		Store_ApplyCooldownIndex(client, NextWeapons[client][slot][0], 3, 10.0);
	}
}

static Action GunsawHudTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(GetClientOfUserId(pack.ReadCell()) == client)
	{
		int weapon = EntRefToEntIndex(pack.ReadCell());
		if(weapon != -1)
		{
			int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(weapon == active)
			{
				PrintHintText(client, "");
			}
			else
			{
				int slot = active == GetPlayerWeaponSlot(client, TFWeaponSlot_Primary) ? 0 : (active == GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary) ? 1 : 2);
				if(slot < sizeof(EquippedWeapons))
				{
					char item1[64], item2[64];
					Store_GetItemName(abs(EquippedWeapons[client][slot][0]), client, item1, sizeof(item1), _, EquippedWeapons[client][slot][1]);
					Store_GetItemName(abs(NextWeapons[client][slot][0]), client, item2, sizeof(item2), _, NextWeapons[client][slot][1]);
					
					PrintHintText(client, "Current: %s\nNext: %s\nM2 to Change - R to Swap", item1, item2);
				}	
			}
			
			return Plugin_Continue;
		}

		WeaponTimer[client] = null;
		Weapon_GunsawMelee_Unequip(client);
	}
	
	WeaponTimer[client] = null;
	return Plugin_Stop;
}

public void Weapon_GunsawMelee_Unequip(int client)
{
	delete WeaponTimer[client];
	delete ModelModels[client];

	for(int i; i < sizeof(EquippedWeapons[]); i++)
	{
		if(EquippedWeapons[client][i][0])
		{
			if(EquippedWeapons[client][i][0] > 0)
				Store_RemoveSpecificItem(client, NULL_STRING, _, EquippedWeapons[client][i][0]);
			
			EquippedWeapons[client][i][0] = 0;
		}
	}
}

public void Weapon_GunsawRanged_M2(int client, int weapon, bool crit, int slot)
{
	if(!(GetClientButtons(client) & IN_DUCK))
	{
		if(OgEntityFuncAttack[weapon][0] && OgEntityFuncAttack[weapon][0] != INVALID_FUNCTION)
		{
			Call_StartFunction(null, OgEntityFuncAttack[weapon][0]);
			Call_PushCell(client);
			Call_PushCell(weapon);
			Call_PushCell(crit);
			Call_PushCell(slot);
			Call_Finish();
			return;
		}

		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "Hold crouch to switch the next gun");
		return;
	}

	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	ClientCommand(client, "playgamesound misc/halloween/spelltick_0%d.wav", 1 + (GetURandomInt() % 2));
	if(GameRules_GetRoundState() == RoundState_ZombieRiot)
		Ability_Apply_Cooldown(client, slot, 15.0);

	RollNextGun(client, slot);
}

public void Weapon_GunsawRanged_R(int client, int weapon, bool crit, int slot)
{
	if(!(GetClientButtons(client) & IN_DUCK))
	{
		if(OgEntityFuncAttack[weapon][0] && OgEntityFuncAttack[weapon][0] != INVALID_FUNCTION)
		{
			Call_StartFunction(null, OgEntityFuncAttack[weapon][0]);
			Call_PushCell(client);
			Call_PushCell(weapon);
			Call_PushCell(crit);
			Call_PushCell(slot);
			Call_Finish();
			return;
		}

		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "Hold crouch to swap to the next gun");
		return;
	}

	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}
	
	Rogue_OnAbilityUse(client, weapon);

	int wslot = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary) == weapon ? 0 : 1;
	SwapGunSlot(client, wslot);
	RollNextGun(client, wslot);
}

public void Weapon_GunsawMelee_M1(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 44.0);

	// Throw prop
}

public void Weapon_GunsawMelee_M2(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 44.0);

	// Pickup prop
}

static void AddGun(int rank, int slot, const char[] name, int level)
{
	int index = Store_GetItemIndex(name);
	if(index != -1)
	{
		int data[2];
		data[0] = index;
		data[1] = level;
		GunListing[slot][rank].PushArray(data);
	}
}