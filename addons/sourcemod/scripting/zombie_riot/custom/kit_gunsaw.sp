#pragma semicolon 1
#pragma newdecls required

static const float MaxMulti = 3.0;	// Max health multi after cap (3.0 is x3 of HealthCap)
static const float SlowStack = 0.25;	// Decrease speed by this much every max health over cap (0.25 gives -25% speed at x2 HP)
static const float PropDamage = 0.5;	// Prop damage (Metal Cost * Building Damage * PropDamage)

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
static ArrayList ModelWearables[MAXPLAYERS];
static int WeaponLevel[MAXPLAYERS];
static int EquippedWeapons[MAXPLAYERS][2][2];
static int NextWeapons[MAXPLAYERS][2][2];
static Function OgEntityFuncAttack[MAXENTITIES][2];
static Handle WeaponTimer[MAXPLAYERS];
static bool RecentlySwapped[MAXPLAYERS];
static bool DoneLastmanSecret;

static bool Precached = false;
static int RandomSeed;

void Gunsaw_MapStart()
{
	Precached = false;
	DoneLastmanSecret = false;

	for(int i; i < sizeof(ModelModels); i++)
	{
		delete ModelModels[i];
	}
}

void Gunsaw_RoundStart()
{
	RandomSeed = GetURandomInt() / 2;
}

void Gunsaw_Precache()
{
	if(!Precached)
	{
		PrecacheSound("weapons/physcannon/superphys_launch2.wav");
		PrecacheSoundCustom("#zombiesurvival/gunsaw_lastman.mp3",_ , 1);
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

	// Can be existing weapons or custom weapons made just for this
	AddGun(0, TFWeaponSlot_Primary, "Syringe Gun", 0);
	AddGun(0, TFWeaponSlot_Secondary, "Flaregun", 0);
	AddGun(0, TFWeaponSlot_Secondary, "USP", 0);
	AddGun(0, TFWeaponSlot_Secondary, "The Righteous Bison", 0);
	AddGun(0, TFWeaponSlot_Primary, "Sniper Rifle", 0);
	AddGun(0, TFWeaponSlot_Primary, "Shotgun", 0);
	AddGun(0, TFWeaponSlot_Secondary, "SMG", 0);
	AddGun(0, TFWeaponSlot_Primary, "Deagle", 0);
	AddGun(0, TFWeaponSlot_Secondary, "Nail Gun", 0);
	AddGun(0, TFWeaponSlot_Secondary, "Level 15 Peashooter", 1);

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
	AddGun(1, TFWeaponSlot_Secondary, "Level 15 Peashooter", 2);
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
	AddGun(2, TFWeaponSlot_Secondary, "Level 15 Peashooter", 3);
	AddGun(2, TFWeaponSlot_Primary, "Flamethrower", 1);
	AddGun(2, TFWeaponSlot_Primary, "Grenade Launcher", 1);
	AddGun(2, TFWeaponSlot_Primary, "Tommygun", 1);
	AddGun(2, TFWeaponSlot_Secondary, "Stickybomb Launcher", 1);
	AddGun(2, TFWeaponSlot_Primary, "Double Barrel Shotgun", 1);
	AddGun(2, TFWeaponSlot_Primary, "Chemical Spewer", 0);

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
	AddGun(3, TFWeaponSlot_Secondary, "Level 15 Peashooter", 4);
	AddGun(3, TFWeaponSlot_Primary, "Grenade Launcher", 3);
	AddGun(3, TFWeaponSlot_Primary, "Tommygun", 2);
	AddGun(3, TFWeaponSlot_Secondary, "Stickybomb Launcher", 2);
	AddGun(3, TFWeaponSlot_Primary, "Double Barrel Shotgun", 2);
	AddGun(3, TFWeaponSlot_Primary, "Chemical Spewer", 1);

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
	AddGun(4, TFWeaponSlot_Secondary, "Level 15 Peashooter", 6);
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

int Gunsaw_Additional_SupportBuildings(int client)
{
	return WeaponTimer[client] ? (WeaponLevel[client] + 1) : 0;
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

		RequestFrame(ApplyGunsawStats, EntIndexToEntRef(weapon));

		delete WeaponTimer[client];

		DataPack pack;
		WeaponTimer[client] = CreateDataTimer(0.5, GunsawHudTimer, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(GetClientUserId(client));
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
	else if(EquippedWeapons[client][0][0] || EquippedWeapons[client][1][0])
	{
		/*
		i_Hex_WeaponUsesTheseAbilities[weapon] |= ABILITY_M2;
		OgEntityFuncAttack[weapon][0] = EntityFuncAttack2[weapon];
		EntityFuncAttack2[weapon] = Weapon_GunsawRanged_M2;

		i_Hex_WeaponUsesTheseAbilities[weapon] |= ABILITY_R;
		OgEntityFuncAttack[weapon][1] = EntityFuncAttack3[weapon];
		EntityFuncAttack3[weapon] = Weapon_GunsawRanged_R;
		*/

		Attributes_SetMulti(weapon, 2, GunMulti[WeaponLevel[client]]);
		
		if(ModelModels[client])
		{
			Attributes_SetMulti(weapon, 205, ModelRangedRes[client]);
			Attributes_SetMulti(weapon, 206, ModelMeleeRes[client]);
		}
	}
}

void Gunsaw_RemoveWearables(int client)
{
	if(ModelWearables[client])
	{
		int length = ModelWearables[client].Length;
		for(int i; i < length; i++)
		{
			int entity = EntRefToEntIndex(ModelWearables[client].Get(i));
			if(entity != -1)
				TF2_RemoveWearable(client, entity);
		}

		delete ModelWearables[client];
	}
}

static void ApplyGunsawStats(int ref)
{
	int weapon = EntRefToEntIndex(ref);
	if(weapon != -1)
	{
		int client = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
		if(client != -1)
		{
			for(int i; i < sizeof(EquippedWeapons[]); i++)
			{
				if(i < 1 && WeaponLevel[client] < 1)
					continue;
				
				if(!EquippedWeapons[client][i][0])
				{
					RollNextGun(client, i);
					SwapGunSlot(client, i, true);

					if(!EquippedWeapons[client][i][0])
					{
						LogStackTrace("No gun equipped?");
						continue;
					}
				}
			}

			Gunsaw_RemoveWearables(client);
			ModelWearables[client] = new ArrayList();

			if(ModelModels[client] || WeaponLevel[client] > 0)
			{
				int entity, a;
				while(TF2U_GetWearable(client, entity, a))
				{
					if(ViewChange_IsViewmodelRef(EntIndexToEntRef(entity)))
						continue;
					
					TF2_RemoveWearable(client, a);
				}
			}

			char model[PLATFORM_MAX_PATH];
			Format(model, sizeof(model), "models/workshop/player/items/all_class/dec23_cozy_coverup_style3/dec23_cozy_coverup_style3_%s.mdl", g_RandomizerClasses[CurrentClass[client]]);
			int device = PrecacheModel(model);

			int team = 2;
			ViewChange_TeamOverride(team);

			int length = ModelModels[client] ? ModelModels[client].Length : 0;
			for(int a = -1; a < length; a++)
			{
				int index = device;
				if(a != -1)
					index = ModelModels[client].Get(a);

				int entity = CreateEntityByName("tf_wearable");
				if(entity != -1)
				{
					if(a == -1)
					{
						SetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex", 31416);
						SetEntProp(entity, Prop_Send, "m_bInitialized", true);
						SetEntProp(entity, Prop_Send, "m_iEntityQuality", 1);
						SetEntProp(entity, Prop_Send, "m_iEntityLevel", 1);
					}
					
					SetEntProp(entity, Prop_Send, "m_nModelIndex", index);
					SetEntProp(entity, Prop_Send, "m_fEffects", 129);
					SetTeam(entity, team);
					SetEntProp(entity, Prop_Send, "m_nSkin", a == -1 ? 0 : (team - 2));
					SetEntProp(entity, Prop_Send, "m_usSolidFlags", 4);
					SetEntityCollisionGroup(entity, 11);
					SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", true);
					DispatchSpawn(entity);
					SetVariantString("!activator");
					ActivateEntity(entity);
					SDKCall_EquipWearable(client, entity);

					ModelWearables[client].Push(EntIndexToEntRef(entity));
				}
			}
			
			if(ModelModels[client])
			{
				float melee = ModelMeleeRes[client];
				float ranged = ModelRangedRes[client];

				// Count resistances towards our health cap
				float health = float(ModelHealth[client] - 100);
				float cap = HealthCap[WeaponLevel[client]] * MaxMulti / (melee * ranged);
				if(health > cap)
					health = cap;

				// More effective health = more fat
				float fat = (health * MaxMulti / cap) - 1.0;
				if(fat < 0.0)
					fat = 0.0;
				
				Attributes_Set(weapon, 26, health);
				Attributes_Set(weapon, 107, 1.0 - (fat * SlowStack));
				Attributes_Set(weapon, 205, ranged);
				Attributes_Set(weapon, 206, melee);
			}
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

bool Gunsaw_LastmanSecret()
{
	if(DoneLastmanSecret)
		return false;
	
	DoneLastmanSecret = true;
	return true;
}

void Gunsaw_TryBodySteal(int client, bool regen, float pos[3] = {0.0,0.0,0.0})
{
	if(WeaponTimer[client] && WeaponLevel[client] > 0)
	{
		int target = GetClosestTarget(client, true, 1000.0, true, .EntityLocation = pos, .fldistancelimitAllyNPC = 1000.0, .IgnorePlayers = true, .ExtraValidityFunction = StealBodyFunc);
		if(target != -1)
		{
			StealBodyForm(client, target);

			float ang[3];
			GetEntPropVector(target, Prop_Data, "m_vecOrigin", pos);
			GetEntPropVector(target, Prop_Data, "m_angRotation", ang);
			ang[0] = 0.0;
			ang[2] = 0.0;

			view_as<CClotBody>(target).m_iHealthBar = 0;
			SetEntityHealth(target, 1);
			b_DissapearOnDeath[target] = true;
			RemoveSpecificBuff(target, "Infinite Will");
			SDKHooks_TakeDamage(target, client, client, GetRandomFloat(99999.0,9999999.0), DMG_BLAST, -1, {0.1,0.1,0.1}, _, _, ZR_SLAY_DAMAGE);

			TeleportEntity(client, pos, ang);
			f_InBattleHudDisableDelay[client] = GetGameTime() + 1.0; 
		}
		else
		{
			delete ModelModels[client];

			float SubjectAbsVelocity[3];
			float clientvec[3];
			float clientveceye[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", clientvec);
			GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", SubjectAbsVelocity);
			GetClientEyeAngles(client, clientveceye);
			f_WasRecentlyRevivedViaNonWaveClassChange[client] = GetGameTime() + 0.5;
			f_WasRecentlyRevivedViaNonWave[client] = GetGameTime() + 0.5;
			DHook_RespawnPlayer(client);
			Store_GiveAll(client, GetClientHealth(client));
			TeleportEntity(client, clientvec, clientveceye, SubjectAbsVelocity);
			f_InBattleHudDisableDelay[client] = GetGameTime() + 1.0; 
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
	
	ModelMeleeRes[client] = clamp(fl_MeleeArmor[entity] * fl_Extra_MeleeArmor[entity], 0.5, 2.0);
	ModelRangedRes[client] = clamp(fl_RangedArmor[entity] * fl_Extra_RangedArmor[entity], 0.5, 2.0);

	delete ModelModels[client];
	ModelModels[client] = new ArrayList();

	TFClassType class, weapons;

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
		weapons = class;
		ModelRobot[client] = false;
	}
	else if(ReplaceStringEx(model, sizeof(model), "models/bots/", "", _, _, false) != -1)
	{
		int pos = FindCharInString(model, '/', true);
		if(pos != -1)
			model[pos] = '\0';

		class = TF2_GetClass(model);
		weapons = class;
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
	else
	{
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
	
	for(int i; i < sizeof(i_Wearable[]); i++)
	{
		int wearable = EntRefToEntIndex(i_Wearable[entity][i]);
		if(wearable != -1)
		{
			int index = GetEntProp(wearable, Prop_Send, "m_nModelIndex");
			ModelIndexToString(index, model, sizeof(model));
			if(model[0] && StrContains(model, "player/items", false) != -1)
			{
				ModelModels[client].Push(index);
			}
		}
	}

	RollNextGun(client, 0, entity, weapons);
	RollNextGun(client, 1, entity, weapons);

	if(CurrentClass[client] != class)
	{
		TF2_SetPlayerClass_ZR(client, class);
		CurrentClass[client] = class;
	}

	f_WasRecentlyRevivedViaNonWaveClassChange[client] = GetGameTime() + 0.5;
	f_WasRecentlyRevivedViaNonWave[client] = GetGameTime() + 0.5;
	DHook_RespawnPlayer(client);
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

static void RollNextGun(int client, int slot, int entity = -1, TFClassType class = TFClass_Unknown)
{
	PrecacheStore();

	int rank = WeaponLevel[client];
	if(rank >= sizeof(GunListing[]))
		rank = sizeof(GunListing[]) - 1;
	
	int length = GunListing[slot][rank].Length;
	if(!length)
	{
		LogStackTrace("Gun list empty in slot %d for rank %d", slot, rank);
		return;
	}

	int data[2];

	int rand = RandomSeed;
	if(slot == 0 && class != TFClass_Unknown)
	{
		int start = rand % length;
		for(int i = start + 1; i != start; i++)
		{
			if(i >= length)
			{
				i = -1;
				continue;
			}

			GunListing[slot][rank].GetArray(i, data);
			if(Store_WeaponClass(data[0], data[1]) == class)
			{
				NextWeapons[client][slot] = data;
				return;
			}
		}
	}
	else
	{
		rand += entity > MaxClients ? i_NpcInternalId[entity] : client;
	}

	GunListing[slot][rank].GetArray(rand % length, data);

	NextWeapons[client][slot] = data;
	SwapGunSlot(client, slot);
}

static void SwapGunSlot(int client, int slot, bool first = false)
{
	if(!RecentlySwapped[client])
	{
		RecentlySwapped[client] = true;

		int type = Store_GetAmmoType(NextWeapons[client][slot][0], NextWeapons[client][slot][1]);
		if(type > 0 && type < sizeof(CurrentAmmo[]))
		{
			AddAmmoClient(client, type, _, 4.0, true);
			CurrentAmmo[client][type] = GetAmmo(client, type);
		}
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

		int oldWeapon = GetPlayerWeaponSlot(client, slot);
		if(oldWeapon != -1)
			TF2_RemoveItem(client, oldWeapon);
		
		EquippedWeapons[client][slot][0] = 0;
	}

	if(Store_HasIndexItem(client, NextWeapons[client][slot][0]))
	{
		EquippedWeapons[client][slot][0] = -NextWeapons[client][slot][0];
		EquippedWeapons[client][slot][1] = 0;
		Store_Equip(client, NextWeapons[client][slot][0], _, true);
	}
	else
	{
		EquippedWeapons[client][slot] = NextWeapons[client][slot];
		Store_GiveSpecificItem(client, NULL_STRING, _, NextWeapons[client][slot][0], NextWeapons[client][slot][1] + 1, -2);
	}

	if(GameRules_GetRoundState() == RoundState_ZombieRiot)
	{
		Store_ApplyCooldownIndex(client, NextWeapons[client][slot][0], 3, 80.0 - (slot * 30.0));
		RecentlySwapped[client] = first;
	}
	else
	{
		Store_ApplyCooldownIndex(client, NextWeapons[client][slot][0], 3, 10.0);
	}

	// Bug: Using Store_Equip/Store_GiveSpecificItem on clipless weapons don't have their ammo set correctly
	Manual_Impulse_101(client, GetClientHealth(client));
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
				PrintHintText(client, " ");
			}
			else
			{
				int slot = active == GetPlayerWeaponSlot(client, TFWeaponSlot_Primary) ? 0 : (active == GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary) ? 1 : 2);
				if(slot < sizeof(EquippedWeapons[]))
				{
					char item1[64], item2[64];
					Store_GetItemName(abs(EquippedWeapons[client][slot][0]), client, item1, sizeof(item1), _, EquippedWeapons[client][slot][1]);
					Store_GetItemName(abs(NextWeapons[client][slot][0]), client, item2, sizeof(item2), _, NextWeapons[client][slot][1]);
					
					PrintHintText(client, "Current: %s\nNext: %s\nM2 to Reroll - R to Swap", item1, item2);
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
	Gunsaw_RemoveWearables(client);

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

	RequestFrame(ReequipFrame, GetClientUserId(client));
}

static void ReequipFrame(int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		Store_ApplyAttribs(client);
		Store_GiveAll(client, GetClientHealth(client));
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
		ShowSyncHudText(client, SyncHud_Notifaction, "Hold crouch to reroll the next gun");
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

	int wslot = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary) == weapon ? 0 : 1;
	RollNextGun(client, wslot);
	TriggerTimer(WeaponTimer[client], true);
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
	
	ClientCommand(client, "playgamesound misc/halloween/spelltick_set.wav");
	Rogue_OnAbilityUse(client, weapon);

	int wslot = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary) == weapon ? 0 : 1;
	SwapGunSlot(client, wslot);
	RollNextGun(client, wslot);
	TriggerTimer(WeaponTimer[client], true);
}

public void Weapon_GunsawMelee_M1(int client, int weapon, bool &crit, int slot)
{
	int building = GetCarryingObject(client);
	if(building <= MaxClients)
		return;
	
	if(view_as<ObjectGeneric>(building).m_bConstructBuilding)
	{
		ClientCommand(client, "playgamesound weapons/physcannon/physcannon_tooheavy.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "Can not throw constructs");
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
	Ability_Apply_Cooldown(client, slot, 30.0);

	float pos[3], ang[3];
	GetEntPropVector(building, Prop_Data, "m_vecAbsOrigin", pos);
	GetEntPropVector(building, Prop_Data, "m_angRotation", ang);

	float scale = GetEntPropFloat(building, Prop_Send, "m_flModelScale");
	char model[PLATFORM_MAX_PATH];
	GetEntPropString(building, Prop_Data, "m_ModelName", model, sizeof(model));

	EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", client);
	
	// Spawn prop
	int prop = CreateEntityByName("prop_physics_multiplayer");
	if(prop != -1)
	{
		// Allow picking the building back up, ignore the physics prop in traces
		SDKUnhook(building, SDKHook_Think, BuildingPickUp);
		ResetPlayer_BuildingBeingCarried(client);
		Building_BuildingBeingCarried[building] = 0;
		b_ThisEntityIgnored[building] = false;

		i_TraceToInstead[prop] = building;

		char buffer[PLATFORM_MAX_PATH];
		strcopy(buffer, sizeof(buffer), model);
		ReplaceString(buffer, sizeof(buffer), ".mdl", ".phy", false);
		if(FileExists(buffer, true))
		{
			DispatchKeyValue(prop, "model", model);
		}
		else
		{
			DispatchKeyValue(prop, "model", "models/props_spytech/computer_low.mdl");
		}

		DispatchKeyValueFloat(prop, "modelscale", scale);
		DispatchKeyValue(prop, "physicsmode", "2");
		DispatchKeyValue(prop, "massscale", "10000");
		DispatchSpawn(prop);

		SetEntityRenderMode(prop, RENDER_TRANSCOLOR);
		SetEntityRenderColor(prop, _, _, _, 0);

		SetEntPropEnt(prop, Prop_Send, "m_hOwnerEntity", client);

		// Throw prop
		float vec[3], vel[3];
		GetClientEyePosition(client, vec);
		GetClientEyeAngles(client, vel);
		GetAngleVectors(vel, vel, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(vel, 1000.0);

		TeleportEntity(prop, pos, ang, vel);
		
		view_as<ObjectGeneric>(prop).m_iWearable1 = building;
		SetParent(prop, building);

		// Self knockback
		ScaleVector(vel, -0.6);
		TeleportEntity(client, _, _, vel);

		// Delete timer
		fl_AbilityOrAttack[prop][0] = GetGameTime() + 60.0;

		GunsawPropThink(EntIndexToEntRef(prop));
	}
}

public void Weapon_GunsawMelee_M2(int client, int weapon, bool &crit, int slot)
{
	if(GetClientButtons(client) & IN_DUCK)
	{
		MountBuildingToBack(client, weapon, crit);
		return;
	}

	Building_Pickup(client, 300.0);
}

static float ZRRamMulti;
static void GunsawPropThink(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity == -1)
		return;
	
	int building = view_as<ObjectGeneric>(entity).m_iWearable1;
	if(building == -1)
	{
		RemoveEntity(entity);
		return;
	}

	if(BuildingIsBeingCarried(building))
	{
		AcceptEntityInput(building, "ClearParent");
		RemoveEntity(entity);
		return;
	}
	
	if(fl_AbilityOrAttack[entity][0] < GetGameTime())
	{
		int builder = GetEntPropEnt(building, Prop_Send, "m_hOwnerEntity");
		if(builder > 0 && builder <= MaxClients)
			DeleteAndRefundBuilding(builder, building);

		int dissolver = CreateEntityByName("env_entity_dissolver");
		if(dissolver != -1)
		{
			DispatchKeyValue(dissolver, "dissolvetype", "1");
			DispatchKeyValue(dissolver, "magnitude", "200");
			DispatchKeyValue(dissolver, "target", "!activator");
			
			AcceptEntityInput(dissolver, "Dissolve", entity);
			AcceptEntityInput(dissolver, "Kill");
		}
		return;
	}
	
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(client != -1)
	{
		float vel[3];
		SDKCall_GetSmoothedVelocity(entity, vel);

		float damage;
		
		if(GetVectorLength(vel, true) > 49999.0)
		{
			ZRRamMulti = Attributes_GetOnPlayer(client, 287, true) / Attributes_GetOnPlayer(client, 343, true, true);
			
			// 1000 Metal = 500 base damage
			damage = MetalSpendOnBuilding[building] * ZRRamMulti * PropDamage;
		}
		else
		{
			ZRRamMulti = 1.0;
			damage = 0.0;
		}

		int type = i_ExplosiveProjectileHexArray[building];
		i_ExplosiveProjectileHexArray[building] = EP_GENERIC;
		Explode_Logic_Custom(damage, client, building, -1, _, 60.0, 1.0, 1.0, _, 99, false, 0.2, GunsawPropDamagePost, GunsawPropDamagePre);
		i_ExplosiveProjectileHexArray[building] = type;

		if(ZRRamMulti == -1.0)
		{
			// Building broke, explode
			int repair = GetEntProp(building, Prop_Data, "m_iRepair");
			int maxrepair = GetEntProp(building, Prop_Data, "m_iRepairMax");
			if(maxrepair < 1)
				maxrepair = 1;
			
			// Metal Cost * Damage * Repair HP Ratio
			damage = MetalSpendOnBuilding[building] * PropDamage * 1.5 * Attributes_GetOnPlayer(client, 287, true) / Attributes_GetOnPlayer(client, 343, true, true) * float(repair) / float(maxrepair);
			//PrintToChatAll("%f x (%d x %.2f) = %.0f", repair / maxrepair, MetalSpendOnBuilding[entity], Attributes_GetOnPlayer(client, 287, true), damage);

			i_ExplosiveProjectileHexArray[building] = EP_GENERIC;
			Explode_Logic_Custom(damage, client, building, -1, _, 150.0 * Attributes_GetOnPlayer(client, 344, true, true));
			i_ExplosiveProjectileHexArray[building] = type;

			DestroyBuildingDo(building);
			RemoveEntity(entity);
			return;
		}
	}

	RequestFrame(GunsawPropThink, ref);
}

static float GunsawPropDamagePre(int prop, int victim, float &damage, int weapon)
{
	if(damage < 1.0 || ZRRamMulti == -1.0 || IsIn_HitDetectionCooldown(prop, victim))
	{
		damage = 0.0;
		return 0.0;
	}

	damage *= GetEntProp(prop, Prop_Data, "m_iHealth") / float(ReturnEntityMaxHealth(prop));
	//PrintToChatAll("%f x (%d x ?) = %.0f", GetEntProp(prop, Prop_Data, "m_iHealth") / float(ReturnEntityMaxHealth(prop)), MetalSpendOnBuilding[prop], damage);
	return 0.0;
}

static void GunsawPropDamagePost(int prop, int victim, float damage, int weapon)
{
	Set_HitDetectionCooldown(prop, victim, GetGameTime() + 1.0);
	if(damage < 1.0)
		return;
	
	int health = GetEntProp(victim, Prop_Data, "m_iHealth");
	if(health > 0)
	{
		// Victim still alive, break the prop
		ZRRamMulti = -1.0;
	}
	else
	{
		// Victim died, lose prop health
		int prophp = GetEntProp(prop, Prop_Data, "m_iHealth");
		float propmax = float(ReturnEntityMaxHealth(prop));
		float totalDamage = MetalSpendOnBuilding[prop] * PropDamage;

		float dealt = (health + damage) / ZRRamMulti;
		
		// Example: Decrease health by 20% damage dealt
		prophp -= RoundFloat(propmax * dealt / totalDamage);
		if(prophp < 1)
		{
			ZRRamMulti = -1.0;
			prophp = 0;
		}
		
		SetEntProp(prop, Prop_Data, "m_iHealth", prophp);
	}
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