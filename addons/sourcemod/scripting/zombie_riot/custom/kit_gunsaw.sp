#pragma semicolon 1
#pragma newdecls required

static const float MaxMulti = 3.0;	// Max health multi after cap (3.0 is x3 of HealthCap)
static const float SlowStack = 0.1;	// Decrease speed by this much every max health over cap (0.25 gives -25% speed at x2 HP)
static const float PropDamage = 3.0;	// Prop damage (Metal Cost * Building Damage * PropDamage)

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
/*static const float GunMulti[] =
{
	1.0,
	1.0,
	1.5,
	2.0,
	3.0,
	5.0,
	9.0
};*/

static const char TextSound[][] =
{
	"ui/buttonclick.wav",
	"ui/buttonclickrelease.wav",
	"ui/buttonrollover.wav"
};

enum
{
	Body_None = 0,
	Body_Scout,
	Body_Sniper,
	Body_Soldier,
	Body_DemoMan,
	Body_Medic,
	Body_Heavy,
	Body_Pyro,
	Body_Spy,
	Body_Engineer,
	Body_Combine,
	Body_Horse,
	Body_Human,
	Body_Zombie,
	Body_Robot,
	Body_Boss
}

//static ArrayList GunListing[2][5];
static int ModelHealth[MAXPLAYERS];
static float ModelMeleeRes[MAXPLAYERS];
static float ModelRangedRes[MAXPLAYERS];
static float ModelReloadTime[MAXPLAYERS];
static bool ModelRobot[MAXPLAYERS];
static int ModelEffect[MAXPLAYERS];
static DataPack ModelNPCName[MAXPLAYERS];
static ArrayList ModelModels[MAXPLAYERS];
static ArrayList ModelWearables[MAXPLAYERS];
static int WeaponLevel[MAXPLAYERS];
static float LastSwap[MAXPLAYERS];
static float LastMonologue[MAXPLAYERS];
static float MonologueSpeed[MAXPLAYERS];
static float MonologueShake[MAXPLAYERS];
static float MonologueMoodBonus[MAXPLAYERS];
static int DrugNerf[MAXPLAYERS];
//static int EquippedWeapons[MAXPLAYERS][2][2];
//static int NextWeapons[MAXPLAYERS][2][2];
//static Function OgEntityFuncAttack[MAXENTITIES][2];
static Handle WeaponTimer[MAXPLAYERS];
//static bool RecentlySwapped[MAXPLAYERS];
static bool DoneLastmanSecret;

static bool Precached = false;
//static int RandomSeed;

void Gunsaw_MapStart()
{
	Precached = false;
	DoneLastmanSecret = false;

	for(int i; i < MAXPLAYERS; i++)
	{
		LastMonologue[i] = 0.0;
		delete ModelModels[i];
		delete ModelNPCName[i];
	}
}

void Gunsaw_RoundStart()
{
	//RandomSeed = GetURandomInt() / 2;
}

void Gunsaw_Precache()
{
	if(!Precached)
	{
		PrecacheSoundArray(TextSound);
		PrecacheSound("weapons/physcannon/superphys_launch2.wav");
		PrecacheSoundCustom("#zombiesurvival/gunsaw_lastman.mp3",_ , 1);
		Precached = true;
	}
}
/*
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
	//AddGun(2, TFWeaponSlot_Primary, "Deagle", 2);
	//AddGun(2, TFWeaponSlot_Primary, "Deagle", 4);
	AddGun(2, TFWeaponSlot_Secondary, "Level 15 Peashooter", 3);
	AddGun(2, TFWeaponSlot_Primary, "Flamethrower", 1);
	AddGun(2, TFWeaponSlot_Primary, "Grenade Launcher", 1);
	AddGun(2, TFWeaponSlot_Primary, "Tommygun", 1);
	AddGun(2, TFWeaponSlot_Secondary, "Stickybomb Launcher", 1);
	AddGun(2, TFWeaponSlot_Primary, "Double Barrel Shotgun", 1);
	//AddGun(2, TFWeaponSlot_Primary, "Chemical Spewer", 0);

	AddGun(3, TFWeaponSlot_Primary, "Syringe Gun", 2);
	AddGun(3, TFWeaponSlot_Secondary, "Flaregun", 3);
	AddGun(3, TFWeaponSlot_Secondary, "USP", 3);
	AddGun(3, TFWeaponSlot_Primary, "Sniper Rifle", 2);
	AddGun(3, TFWeaponSlot_Primary, "Shotgun", 4);
	AddGun(3, TFWeaponSlot_Primary, "Shotgun", 7);
	AddGun(3, TFWeaponSlot_Secondary, "SMG", 3);
	AddGun(3, TFWeaponSlot_Primary, "Huntsman", 5);
	AddGun(3, TFWeaponSlot_Primary, "Deagle", 3);
	//AddGun(3, TFWeaponSlot_Primary, "Deagle", 6);
	//AddGun(3, TFWeaponSlot_Primary, "Deagle", 8);
	AddGun(3, TFWeaponSlot_Secondary, "Level 15 Peashooter", 4);
	AddGun(3, TFWeaponSlot_Primary, "Grenade Launcher", 3);
	AddGun(3, TFWeaponSlot_Primary, "Tommygun", 2);
	AddGun(3, TFWeaponSlot_Secondary, "Stickybomb Launcher", 2);
	AddGun(3, TFWeaponSlot_Primary, "Double Barrel Shotgun", 2);
	//AddGun(3, TFWeaponSlot_Primary, "Chemical Spewer", 1);

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
	//AddGun(4, TFWeaponSlot_Primary, "Deagle", 7);
	//AddGun(4, TFWeaponSlot_Primary, "Deagle", 9);
	AddGun(4, TFWeaponSlot_Secondary, "Level 15 Peashooter", 6);
	AddGun(4, TFWeaponSlot_Primary, "Grenade Launcher", 4);
	AddGun(4, TFWeaponSlot_Primary, "Tommygun", 3);
	AddGun(4, TFWeaponSlot_Secondary, "Stickybomb Launcher", 3);
	AddGun(4, TFWeaponSlot_Primary, "Double Barrel Shotgun", 3);
	//AddGun(4, TFWeaponSlot_Secondary, "Brick", 0);
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
*/
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

		Monologue_Intro(client);
	}
	else
	{
		if(ModelModels[client])
		{
			Attributes_SetMulti(weapon, 97, ModelReloadTime[client]);
			Attributes_SetMulti(weapon, 205, ModelRangedRes[client]);
			Attributes_SetMulti(weapon, 206, ModelMeleeRes[client]);

			if(i_WeaponArchetype[weapon] == 4)
			{
				// Pistol
				switch(ModelEffect[client])
				{
					case Body_Sniper:
					{
						Attributes_SetMulti(weapon, 106, 0.5);
						Attributes_SetMulti(weapon, 4043, 1.3);
					}
					case Body_Combine:
					{
						Attributes_SetMulti(weapon, 6, 0.8);
					}
				}
			}
			else
			{
				// Shotgun
				switch(ModelEffect[client])
				{
					case Body_Scout:
					{
						Attributes_SetMulti(weapon, 97, 0.7);
					}
					case Body_Combine:
					{
						Attributes_SetMulti(weapon, 6, 0.8);
					}
				}
			}
		}
	}
	/*
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
			Attributes_SetMulti(weapon, 97, ModelReloadTime[client]);
			Attributes_SetMulti(weapon, 205, ModelRangedRes[client]);
			Attributes_SetMulti(weapon, 206, ModelMeleeRes[client]);
		}
	}
	*/
}

void Gunsaw_PlayerDeath(int client)
{
	delete ModelModels[client];
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
			/*
			for(int i; i < sizeof(EquippedWeapons[]); i++)
			{
				if(i < 1 && WeaponLevel[client] < 1)
					continue;
				
				if(!EquippedWeapons[client][i][0])
				{
					RollNextGun(client, i);
					//SwapGunSlot(client, i, true);

					if(!EquippedWeapons[client][i][0])
					{
						LogStackTrace("No gun equipped?");
						continue;
					}
				}
			}
			*/

			Gunsaw_RemoveWearables(client);
			ModelWearables[client] = new ArrayList();

			if(ModelNPCName[client])
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

					if(a == -1)
						Attributes_Set(entity, 542, 5.0, true);

					SDKCall_EquipWearable(client, entity);
					ModelWearables[client].Push(EntIndexToEntRef(entity));
				}
			}
			
			if(ModelModels[client])
			{
				float melee = ModelMeleeRes[client];
				float ranged = ModelRangedRes[client];
				float reload = ModelReloadTime[client];

				// Count resistances towards our health cap
				float health = float(ModelHealth[client] - 100);
				float cap = HealthCap[WeaponLevel[client]] * MaxMulti / (melee * ranged * reload);
				if(health > cap)
					health = cap;
				
				if(ModelEffect[client] == Body_Boss)
					cap *= 1.4;

				// More effective health = more fat
				float fat = (health * MaxMulti / cap) - 1.0;
				if(fat < 0.0)
					fat = 0.0;
				
				float light = health / HealthCap[WeaponLevel[client]];
				if(light < 0.5)
					light = 0.5;

				switch(ModelEffect[client])
				{
					case Body_Soldier:
					{
						Panic_Attack[client] = 0.5;
					}
					case Body_Medic:
					{
						Attributes_Set(weapon, 8, 20.0);
					}
					case Body_Heavy:
					{
						light *= 2.0;
						ranged *= 0.9;
						melee *= 0.9;
					}
					case Body_Spy:
					{
						f_BackstabCooldown[weapon] = 1.5;
						f_BackstabDmgMulti[weapon] = 1.0;
					}
					case Body_Engineer:
					{
						Attributes_Set(weapon, 343, 0.7);
					}
					case Body_Combine:
					{
						Attributes_Set(weapon, 178, 0.2);
					}
					case Body_Horse:
					{
						fat -= 0.15;
						Attributes_Set(weapon, 443, 1.3);
					}
					case Body_Human:
					{
						health = health * 6 / 5;
					}
					case Body_Zombie:
					{
						Attributes_Set(weapon, 57, health / 50.0);
					}
				}
				
				Attributes_Set(weapon, 26, health);
				if(!LastMann)
					Attributes_Set(weapon, 107, 1.0 - (fat * SlowStack));
				
				Attributes_Set(weapon, 205, ranged);
				Attributes_Set(weapon, 206, melee);
				Attributes_Set(weapon, 252, 1.0 / light);
			}
			else
			{
				Attributes_Set(weapon, 26, 0.0);
				Attributes_Set(weapon, 107, 1.0);
				Attributes_Set(weapon, 205, 1.0);
				Attributes_Set(weapon, 206, 1.0);
				Attributes_Set(weapon, 252, ModelNPCName[client] ? 2.0 : 1.0);
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
	return (client > 0 && client <= MaxClients && WeaponTimer[client]);
}

bool Gunsaw_LastmanSecret()
{
	if(DoneLastmanSecret)
		return false;
	
	DoneLastmanSecret = true;
	return true;
}

void Gunsaw_NPCDeath(int entity)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(WeaponTimer[client] && dieingstate[client])
		{
			float pos1[3], pos2[3];
			GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos1);
			GetEntPropVector(client, Prop_Data, "m_vecOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) > 100000.0)
				continue;
			
			if(!ValidSwapTarget(entity, true))
			{
				if(GetClientHealth(client) < 200)
				{
					SetEntityHealth(client, 200);
					return;
				}

				break;
			}

			CNavArea endArea = TheNavMesh.GetNavArea(pos1);
			if(endArea == NULL_AREA)
				return;
			
			CNavArea startArea = TheNavMesh.GetNavAreaEntity(client, view_as<GetNavAreaFlags_t>(0));
			if(startArea == NULL_AREA)
				continue;
			
			if(TheNavMesh.BuildPath(startArea, endArea, pos1, .teamID = 2))
			{
				StealBodyForm(client, entity);
				return;
			}
		}
	}
}


void Gunsaw_TryBodySteal(int client, bool regen, float pos[3] = {0.0,0.0,0.0})
{
	if(WeaponTimer[client])
	{
		int target = GetClosestTarget(client, true, 1000.0, true, .EntityLocation = pos, .fldistancelimitAllyNPC = 1000.0, .IgnorePlayers = true, .ExtraValidityFunction = StealBodyFunc);
		if(target != -1)
		{
			StealBodyForm(client, target);

			view_as<CClotBody>(target).m_iHealthBar = 0;
			SetEntityHealth(target, 1);
			b_DissapearOnDeath[target] = true;
			RemoveSpecificBuff(target, "Infinite Will");
			SDKHooks_TakeDamage(target, client, client, GetRandomFloat(99999.0,9999999.0), DMG_BLAST, -1, {0.1,0.1,0.1}, _, _, ZR_SLAY_DAMAGE);

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
	ModelReloadTime[client] = clamp(f_AttackSpeedNpcIncrease[entity], 0.5, 2.0);

	char model[PLATFORM_MAX_PATH];

	delete ModelNPCName[client];
	ModelNPCName[client] = new DataPack();
	if(b_NameNoTranslation[entity])
	{
		ModelNPCName[client].WriteString(c_NpcName[entity]);
	}
	else
	{
		FormatEx(model, sizeof(model), "%T", c_NpcName[entity], client);
		ModelNPCName[client].WriteString(model);
	}

	delete ModelModels[client];
	ModelModels[client] = new ArrayList();
	LastSwap[client] = GetGameTime();

	TFClassType class;//, weapons;
	int effect;

	GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
	ReplaceString(model, sizeof(model), "\\", "/");

	if(StrContains(model, "combine_", false) != -1 || StrContains(model, "police.mdl", false) != -1)
	{
		class = TFClass_Pyro;
		ModelRobot[client] = false;
		effect = (GetEntProp(client, Prop_Send, "m_nBody") & 4) ? Body_Human : Body_Combine;
	}
	else if(ReplaceStringEx(model, sizeof(model), "models/player/", "", _, _, false) != -1)
	{
		int pos = FindCharInString(model, '.', true);
		if(pos != -1)
			model[pos] = '\0';

		class = TF2_GetClass(model);
		effect = view_as<int>(class);
		//weapons = class;
		ModelRobot[client] = false;
	}
	else if(ReplaceStringEx(model, sizeof(model), "models/bots/", "", _, _, false) != -1)
	{
		int pos = FindCharInString(model, '/', true);
		if(pos != -1)
			model[pos] = '\0';

		class = TF2_GetClass(model);
		effect = Body_Robot;
		//weapons = class;
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

		effect = Body_Zombie;
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
		UpdatePerkName(client);
	}
	
	for(int i; i < sizeof(i_Wearable[]); i++)
	{
		int wearable = EntRefToEntIndex(i_Wearable[entity][i]);
		if(wearable != -1 && HasEntProp(wearable, Prop_Send, "m_nModelIndex"))
		{
			int index = GetEntProp(wearable, Prop_Send, "m_nModelIndex");
			ModelIndexToString(index, model, sizeof(model));
			if(model[0] && StrContains(model, "player/items", false) != -1)
			{
				ModelModels[client].Push(index);

				if(StrContains(model, "hwn2022_pony_express", false) != -1)
				{
					effect = Body_Horse;
				}
			}
		}
	}

	if(b_thisNpcIsABoss[entity])
		effect = Body_Boss;

	ModelEffect[client] = effect;

	//RollNextGun(client, 1, entity, weapons);
	//if(WeaponLevel[client] > 0)
	//	RollNextGun(client, 0, entity, weapons);

	if(CurrentClass[client] != class)
	{
		TF2_SetPlayerClass_ZR(client, class);
		CurrentClass[client] = class;
	}
	
	float pos[3], ang[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
	GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);

	DataPack pack = new DataPack();
	pack.WriteCell(GetClientUserId(client));
	pack.WriteFloatArray(pos, sizeof(pos));
	pack.WriteFloat(ang[1]);
	RequestFrame(StealBodyFrame, pack);
}

static void StealBodyFrame(DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if(client)
	{
		FullyReviveClient(client, client);
		
		float pos[3], ang[3];
		pack.ReadFloatArray(pos, sizeof(pos));
		ang[1] = pack.ReadFloat();

		f_WasRecentlyRevivedViaNonWaveClassChange[client] = GetGameTime() + 0.5;
		f_WasRecentlyRevivedViaNonWave[client] = GetGameTime() + 0.5;

		TeleportEntity(client, pos, ang);

		Monologue_BodySwap(client);
	}

	delete pack;
}

static bool ValidSwapTarget(int entity, bool ignoreSome = false)
{
	if(ignoreSome)
	{
		if(b_thisNpcIsARaid[entity] ||
				b_thisNpcIsAMiniboss[entity] ||
				b_StaticNPC[entity] ||
				i_IsABuilding[entity] ||
				i_NpcIsABuilding[entity] ||
				GetTeam(entity) == TFTeam_Stalkers)
		{
			return false;
		}
	}
	else
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
	}
	
	char model[PLATFORM_MAX_PATH];
	GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
	ReplaceString(model, sizeof(model), "\\", "/");

	if(StrContains(model, "combine_", false) != -1 || StrContains(model, "police.mdl", false) != -1)
		return true;
	
	if(StrContains(model, "models/player/", false) != -1)
		return true;
	
	if(StrContains(model, "models/bots/", false) != -1)
		return true;
	
	if(StrContains(model, "models/zombie/", false) != -1)
		return true;
	
	if(StrContains(model, "models/infected/", false) != -1)
		return true;
	
	return false;
}
/*
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

	ArrayList list = GunListing[slot][rank];
	int data[2];

	int rand = RandomSeed;
	if(slot == 0 && class != TFClass_Unknown)
	{
		list = new ArrayList(sizeof(data));

		for(int i; i < length; i++)
		{
			GunListing[slot][rank].GetArray(i, data);
			if(Store_WeaponClass(data[0], data[1]) == class)
				list.PushArray(data);
		}

		int length2 = list.Length;
		if(length2 == 0)
		{
			delete list;
			list = GunListing[slot][rank];
		}
		else
		{
			length = length2;
			list.Sort(Sort_Random, Sort_Integer);
		}
	}
	
	rand += entity > MaxClients ? i_NpcInternalId[entity] : client;
	list.GetArray(rand % length, data);
	if(list != GunListing[slot][rank])
		delete list;

	NextWeapons[client][slot] = data;
	SwapGunSlot(client, slot, entity == -1);
}

static void SwapGunSlot(int client, int slot, bool first)
{
	if(!first)//!RecentlySwapped[client])
	{
		//RecentlySwapped[client] = true;

		int type = Store_GetAmmoType(NextWeapons[client][slot][0], NextWeapons[client][slot][1]);
		if(type > 0 && type < sizeof(CurrentAmmo[]))
		{
			AddAmmoClient(client, type, _, 8.0, true);
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
*/

static Action GunsawHudTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(GetClientOfUserId(pack.ReadCell()) == client)
	{
		int weapon = EntRefToEntIndex(pack.ReadCell());
		if(weapon != -1)
		{
			if(dieingstate[client])
			{
				PrintHintText(client, "Kill a nearby enemy to self-revive");
			}
			else
			{
				char name[64];

				if(ModelModels[client])
				{
					ModelNPCName[client].Reset();
					ModelNPCName[client].ReadString(name, sizeof(name));
				}
				else
				{
					strcopy(name, sizeof(name), ModelNPCName[client] ? "Abomination" : "Experiment");
				}

				//int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				//if(weapon == active)
				{
					char buffer[64] = " ";
					if(ModelModels[client] && ModelEffect[client] > 0)
					{
						FormatEx(buffer, sizeof(buffer), "Gunsaw Mercenary Effect %d", ModelEffect[client]);
						Format(buffer, sizeof(buffer), "%T", buffer, client);
					}
					
					PrintHintText(client, "%s\n%s\nMove Speed: %.0f％\nReload Speed: %.0f％\nKnockback Resistance: %.0f％", name, buffer, Attributes_Get(weapon, 107) * 100.0, (1.0 / (ModelModels[client] ? ModelReloadTime[client] : 1.0)) * 100.0, (1.0 / Attributes_Get(weapon, 252)) * 100.0);
				}
					/*
				else
				{
					char item1[64], item2[64];
					if(EquippedWeapons[client][0][0])
					{
						Store_GetItemName(abs(EquippedWeapons[client][0][0]), client, item1, sizeof(item1), _, EquippedWeapons[client][0][1]);
					}
					else
					{
						strcopy(item1, sizeof(item1), "None");
					}
					
					if(EquippedWeapons[client][1][0])
					{
						Store_GetItemName(abs(EquippedWeapons[client][1][0]), client, item2, sizeof(item2), _, EquippedWeapons[client][1][1]);
					}
					else
					{
						strcopy(item1, sizeof(item1), "None");
					}
					
					PrintHintText(client, "%s\n \nPrimary: %s\nSecondary: %s", name, item1, item2);
				}
					*/
			}

			if(ModelModels[client])
			{
				switch(ModelEffect[client])
				{
					case Body_Pyro:
					{
						if(IgniteFor[client])
							IgniteFor[client] = 1;
					}
					case Body_Zombie:
					{
						int maxhealth = ReturnEntityMaxHealth(client);
						if(GetClientHealth(client) < maxhealth)
							HealEntityGlobal(client, client, maxhealth * 0.01, 1.0, 0.5);
					}
					case Body_Robot:
					{
						int maxarmor = MaxArmorCalculation(Armor_Level[client], client, 1.0);
						if(Armor_Charge[client] < maxarmor)
							GiveArmorViaPercentage(client, 0.01, 1.0);
					}
					case Body_Boss:
					{
						int maxhealth = ReturnEntityMaxHealth(client);
						float decrease = (GetGameTime() - LastSwap[client]) / 1000.0;
						if(decrease > 0.5)
							decrease = 0.5;
						
						int health = GetClientHealth(client);
						int cap = RoundToCeil(maxhealth * (1.0 - decrease));
						if(health > cap)
						{
							health -= RoundToCeil(maxhealth * decrease * decrease);
							if(health < cap)
								health = cap;
							
							SetEntityHealth(client, health);
						}
					}
				}
			}

			if(DrugNerf[client] > 0)
			{
				DrugNerf[client]--;

				int health = GetClientHealth(client);
				int maxhealth = ReturnEntityMaxHealth(client);
				int overheal = maxhealth;// * 3 / 2;
				if(health > overheal)
				{
					health -= (maxhealth * (health / maxhealth) / 50);
					if(health < overheal)
						health = overheal;
					
					SetEntityHealth(client, health);
				}
				else if(GameRules_GetRoundState() != RoundState_ZombieRiot)
				{
					DrugNerf[client] -= 20;
					if(DrugNerf[client] < 0)
						DrugNerf[client] = 0;
				}

				maxhealth -= RoundFloat(Attributes_Get(weapon, 125, 0.0));
				Attributes_Set(weapon, 125, -(maxhealth * DrugNerf[client] / 1000.0));
			}
			
			if(MonologueMoodBonus[client] > 0.0)
			{
				MonologueMoodBonus[client] -= 0.01;
			}
			else if(MonologueMoodBonus[client] < 0.0)
			{
				MonologueMoodBonus[client] += 0.01;
			}

			if(dieingstate[client])
			{
				if(MonologueMoodBonus[client] > -50.0)
					MonologueMoodBonus[client] -= 0.1;
			}
			else if(GetClientHealth(client) >= ReturnEntityMaxHealth(client))
			{
				if(MonologueMoodBonus[client] < 50.0)
					MonologueMoodBonus[client] += 0.05;
			}
			else if(GetClientHealth(client) < (ReturnEntityMaxHealth(client) / 2))
			{
				if(MonologueMoodBonus[client] > -50.0)
					MonologueMoodBonus[client] -= 0.05;
			}

			Monologue_Idle(client);

			return Plugin_Continue;
		}
		//dont do timer stuff when player is dead
		if(!IsEntityAlive(client, false, true))
			return Plugin_Continue;
		if(TeutonType[client] != TEUTON_NONE)
			return Plugin_Continue;

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
	delete ModelNPCName[client];
/*
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
	*/
}
/*
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
*/

static float KnockbackRes(int client)
{
	int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if(weapon != -1)
		return Attributes_Get(weapon, 252, 1.0);
	
	return 1.0;
}

public void Weapon_GunsawShotgun_M1(int client, int weapon, bool crit, int slot)
{
	if(TF2_IsPlayerInCondition(client, TFCond_FocusBuff))
	{
		Rogue_OnAbilityUse(client, weapon);
		TF2_RemoveCondition(client, TFCond_FocusBuff);

		float ratio = BoomstickAdjustDamageAndAmmoCount(weapon, 1);
		float cooldown = 1.0 + (ratio * 0.5);
		Ability_Apply_Cooldown(client, 2, 1.25 * cooldown * cooldown);
		
		float vec[3], vel[3];
		GetClientEyePosition(client, vec);
		GetClientEyeAngles(client, vel);
		GetAngleVectors(vel, vel, NULL_VECTOR, NULL_VECTOR);
		float knockback = 35.0 * ratio * KnockbackRes(client);
		float stun = knockback / 150.0;

		if(knockback > 600.0)
			knockback = 600.0;
		
		ScaleVector(vel, -knockback);
		
		vec[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
		vec[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
		vec[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
		AddVectors(vel, vec, vel);
		TeleportEntity(client, _, _, vel);

		if(stun > 3.0)
		{
			SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + stun);
			ApplyStatusEffect(client, client, "Ragdolled", stun);
			FreezeNpcInTime(client, stun);
			Gunsaw_Monologue_OnTakeDamage(client, 999999.9);
		}

		float SoundRatio = 0.05 * ratio;
		if(SoundRatio > 1.0)
			SoundRatio = 1.0;

		EmitSoundToAll("weapons/shotgun/shotgun_dbl_fire.wav", client, SNDCHAN_STATIC, 80, _, SoundRatio);
		EmitSoundToAll("weapons/shotgun/shotgun_dbl_fire.wav", client, SNDCHAN_STATIC, 80, _, SoundRatio);
		float ShakeRatio = 0.5 * stun;
		if(ShakeRatio > 2.6)
			ShakeRatio = 2.6;
		Client_Shake(client, 0, 45.0 * ShakeRatio, 30.0 * ShakeRatio, 0.4 * stun);
	}
	else
	{
		Attributes_Set(weapon, 1, 1.0);
	}
}

public void Weapon_GunsawShotgun_M2(int client, int weapon, bool crit, int slot)
{
	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}
	
	if(TF2_IsPlayerInCondition(client, TFCond_FocusBuff))
	{
		TF2_RemoveCondition(client, TFCond_FocusBuff);
	}
	else
	{
		TF2_AddCondition(client, TFCond_FocusBuff, 4.0);
	}
}

public void Weapon_GunsawPistol_M2(int client, int weapon, bool crit, int slot)
{
	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	Rogue_OnAbilityUse(client, weapon);
	ClientCommand(client, "playgamesound items/powerup_pickup_plague_infected.wav");
	Ability_Apply_Cooldown(client, slot, 20.0);

	if(DrugNerf[client] > 798)
	{
		SDKHooks_TakeDamage(client, 0, 0, 999999.9, DMG_TRUEDAMAGE);
		return;
	}

	int health = ReturnEntityMaxHealth(client);
	HealEntityGlobal(client, client, float(health), 5.0, 1.5, HEAL_SELFHEAL);
	DrugNerf[client] += 200;
	Monologue_Drug(client);
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
	Ability_Apply_Cooldown(client, slot, 20.0);

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
		b_ThisEntityIgnoredByOtherNpcsAggro[building] = true;

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
		ScaleVector(vel, -0.3 * KnockbackRes(client));
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
		b_ThisEntityIgnoredByOtherNpcsAggro[entity] = false;
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
			damage = MetalSpendOnBuilding[building] * ZRRamMulti * PropDamage;
		
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

				if(ModelEffect[client] == Body_DemoMan)
					damage *= 1.4;

				i_ExplosiveProjectileHexArray[building] = EP_GENERIC;
				Explode_Logic_Custom(damage, client, building, -1, _, 150.0 * Attributes_GetOnPlayer(client, 344, true, true), .FunctionToCallOnHit = GunsawPropDebuff);
				i_ExplosiveProjectileHexArray[building] = type;

				DestroyBuildingDo(building);
				RemoveEntity(entity);
				return;
			}
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

static void GunsawPropDebuff(int prop, int victim, float damage, int weapon)
{
	int client = GetEntPropEnt(prop, Prop_Send, "m_hOwnerEntity");
	if(IsValidClient(client))
	{
		ApplyStatusEffect(client, victim, "Shrapnel", 4.0);

		if(ModelModels[client])
		{
			switch(ModelEffect[client])
			{
				case Body_Pyro:
				{
					NPC_Ignite(victim, client, 4.0, -1, damage * 0.2 / 8.0);
				}
			}
		}
	}
}
/*
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
*/

static void PlayMonologue(int client, const char[] text, bool fast = false, bool shake = false)
{
	if(!IsEntityAlive(client, false, true))
		return;
	float pain = 1.0 - (GetClientHealth(client) / float(ReturnEntityMaxHealth(client)));

	char buffer[256];
	if(pain > 0.85)
	{
		// Brain damage
		int size = strlen(text);
		for(int i; i < size; i++)
		{
			if(IsCharSpace(text[i]))
			{
				if(GetURandomFloat() < 0.18)
				{
					Format(buffer, sizeof(buffer), "%s.... ", buffer);
					continue;
				}
			}
			else
			{
				if(GetURandomFloat() < 0.12)
				{
					int rand = 1 + (GetURandomInt() % 3);
					for(int b; b < rand; b++)
					{
						Format(buffer, sizeof(buffer), "%s%c", buffer, text[i]);
					}
				}

				if(GetURandomFloat() < 0.12)
					Format(buffer, sizeof(buffer), "%s%c-", buffer, text[i]);
			}

			Format(buffer, sizeof(buffer), "%s%c", buffer, text[i]);
		}
	}
	else
	{
		strcopy(buffer, sizeof(buffer), text);
	}

	if(shake)
	{
		MonologueShake[client] = 0.05;
	}
	else if(pain > 0.75)
	{
		MonologueShake[client] = pain * 0.05;
	}
	else
	{
		MonologueShake[client] = 0.0;
	}

	if(pain > 0.5)
	{
		MonologueSpeed[client] = 0.1 * pain;

		if(fast)
			MonologueSpeed[client] *= 0.7;
	}
	else
	{
		MonologueSpeed[client] = fast ? 0.035 : 0.05;
	}

	LastMonologue[client] = GetGameTime();

	int entity = NpcSpeechBubble(client, buffer, 3, {255, 255, 200, 200}, {0.0, 0.0, 80.0}, "");
	if(entity != -1)
	{
		AddEntityToThirdPersonTransitMode(client, entity);
		SDKUnhook(client, SDKHook_PreThink, NpcSpeechBubbleTalk);
		SDKUnhook(client, SDKHook_PreThink, MonologueThink);
		SDKHook(client, SDKHook_PreThink, MonologueThink);
	}
}

static int MonologueMood(int client)
{
	int mood;
	
	if(LastMann)
	{
		if(!IsValidEntity(EntRefToEntIndex(RaidBossActive)))
			mood = -100;
	}
	else
	{
		int alive, total;
		for(int target = 1; target <= MaxClients; target++)
		{
			if(IsClientInGame(target) && GetClientTeam(target) == 2 && TeutonType[target] != TEUTON_WAITING)
			{
				total += 2;

				if(IsPlayerAlive(target) && TeutonType[target] == TEUTON_NONE)
				{
					alive += dieingstate[target] ? 1 : 2;
				}
			}
		}
		
		mood = (alive * 50 / total) - 30;
	}
	
	if(dieingstate[client])
		mood -= 30;

	return iClamp(RoundFloat(MonologueMoodBonus[client] + mood), -100, 100);
}

static int MonologueMoodLevel(int client)
{
	int mood = MonologueMood(client);

	if(mood > -10.0)
		return 0;
	
	if(mood > -30.0)
		return -1;
	
	if(mood > -50.0)
		return -2;
	
	if(mood > -75.0)
		return -3;
	
	return -4;
}

// 100 max, -100 min
void Gunsaw_Monologue_AddMood(int client, float amount)
{
	MonologueMoodBonus[client] += amount;
}

static void MonologueThink(int client)
{
	int text = EntRefToEntIndex(i_SpeechBubbleEntity[client]);
	if(text == -1)
	{
		SDKUnhook(client, SDKHook_PreThink, MonologueThink);
		return;
	}

	if(f_SpeechTickDelay[client] > GetGameTime())
		return;
	
	if(!f_SpeechDeleteAfter[client])
	{
		EmitSoundToAll(TextSound[GetURandomInt() % sizeof(TextSound)], client, _, 60, _, 0.8);
	}

	float y = 0.2;
	if(MonologueShake[client] > 0.75)
	{
		y += GetRandomFloat(-MonologueShake[client], MonologueShake[client]);
		
		float pos[3];
		GetEntPropVector(text, Prop_Data, "m_vecOrigin", pos);
		pos[0] += GetRandomFloat(-MonologueShake[client], MonologueShake[client]) * 40.0;
		pos[1] += GetRandomFloat(-MonologueShake[client], MonologueShake[client]) * 40.0;
		pos[2] += y * 40.0;
		TeleportEntity(text, pos);
	}

	NpcSpeechBubbleTalk(client);
	f_SpeechTickDelay[client] = GetGameTime() + MonologueSpeed[client];

	static Handle MonologueHud;
	if(!MonologueHud)
		MonologueHud = CreateHudSynchronizer();
	
	int size = i_SpeechBubbleTotalText_ScrollingPart[client];
	char[] buffer = new char[size + 1];
	Format(buffer, size, c_NpcName[text]);
	SetHudTextParams(-1.0, y, MonologueSpeed[client], 255, 255, 200, 255);
	ShowSyncHudText(client, MonologueHud, buffer);
}

static void Monologue_Intro(int client)
{
	if(!LastMonologue[client])
	{
		static const char dialogue[][] =
		{
			"We're here...",
			"Okay... Let's do this.",
			"I'm ready...",
			"I didn't want to do this...",
			"Let's go.",
			"Alright. Let's move fast.",
			"Ooh!",
			"I'm not ready for this...",
			"I hope this'll go well.",
			"Looks scary.",
			"Where am I now...?",
			"I'm not sure about this...",
			"...Hmmh...",
			"Alright...",
			"Let's move. Quickly.",
			"Aye! Let's not waste any time.",
			"*worried frown*",
			"I'm excited!",
			"Not excited for this.",
			"Better here than there...",
			"At least I had food and shelter up there...",
			"I'm already missing my peers from up there.",
			"I don't think they can monitor me down here... Right...?",
			"Awwa...?",
			"Hmm...",
			"Welp. I guess that's it.",
			"Aaannd we've arrived!",
			"It's nice not seeing white tiles around for once...",
			"At least I'm alive...",
			"..Mm. What a peculiar landscape...",
			"Let's hope I remember my training...",
			"My parent would be proud...",
			"Haven't seen those open in a while.",
			"God. This is going to be fucking horrible.",
			"This is gonna be fun."
		};

		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
	}
	else if((LastMonologue[client] + 50.0) < GetGameTime())
	{
		static const char dialogue[][] =
		{
			"What's happening...?",
			"Stay alert...",
			"Good morning...",
			"Here we go...",
			"Mmmmhhm...",
			"Alright...",
			"Back to it...",
			"Another day...",
			"Here we go again...",
			"Eyes open...",
			"Awake and alert...",
			"Hello, world...",
			"Again..."
		};

		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
	}
}

void Gunsaw_Monologue_UseFridge(int client)
{
	if(!Gunsaw_IsMerc(client))
		return;
	
	if(GetClientHealth(client) >= ReturnEntityMaxHealth(client))
	{
		static const char dialogue[][] =
		{
			"That's enough.",
			"Any more and I'll be sick.",
			"I'm full.",
			"I don't want to eat more.",
			"My belly's full.",
			"My stomach's full.",
			"I can't eat another bite...",
			"I feel like I'm about to burst.",
			"I can't eat any more...",
			"I need to stop eating.",
			"I'm going to gain weight at this point...",
			"I need to stop eating.",
			"No more!",
			"I'm gonna be sick at this rate.",
			"That's enough food.",
			"I'm gonna be sick...",
			"I think I'm gonna throw up...",
			"I'm full!"
		};
		
		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
	}
	else
	{
		static const char dialogue[][] =
		{
			"Mmm!",
			"Tasty.",
			"Tasty!",
			"Yum!",
			"Yummy.",
			"Mm...",
			"Neat!",
			"Yummy!",
			"Nice!",
			"Tasty treat...",
			"Delicious bite...",
			"Tastes great.",
			"Satisfying...",
			"That's the stuff...",
			"Fueling up...",
			"Yummy...",
			"That's pretty good...",
			"Not bad!...",
			"Yummers...",
			"Good for me...",
			"Mmmmm...",
			"Never enough of that...",
			"Yum! I feel better!",
			"Nom nom nom.",
			"That was amazing!",
			"Such good flavor...",
			"Flavourful!",
			"Enjoying this...",
			"More of this...",
			"Good food...",
			"Love this taste...",
			"Delicious...",
			"Mmm, nice...",
			"Just what I needed...",
			"Mmmmm..."
		};
		
		Gunsaw_Monologue_AddMood(client, 1.0);
		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
	}
}

void Gunsaw_Monologue_OnBleed(int client)
{
	if(!Gunsaw_IsMerc(client) || (LastMonologue[client] + 20.0) > GetGameTime())
		return;
	
	if(GetClientHealth(client) < ReturnEntityMaxHealth(client))
	{
		static const char dialogue[][] =
		{
			"I'm bleeding!",
			"Help! I'm bleeding!",
			"I'm losing blood!",
			"I'm spilling blood all over the place!",
			"I'm wounded!",
			"I need to patch myself up!",
			"Bleeding!",
			"This isn't great...",
			"Losing blood...",
			"I'm losin' my life juice!",
			"I'm bleeding.",
			"I'm bleeding! Help!",
			"Need a bandage!",
			"I don't like bleeding...",
			"I'm oozing blood...",
			"My blood... ",
			"That's my blood...",
			"Oh... that's blood...",
			"I need a patch-up.",
			"Oh! Blood! Shoot!",
			"Uh... blood? Not good...",
			"My blood, no!",
			"I need this bandaged. Fast...",
			"Crap, I'm bleeding!",
			"Bleeding...",
			"That's my blood... ouch..."
		};
		
		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
	}
}

void Gunsaw_Monologue_OnDowned(int client)
{
	if(!Gunsaw_IsMerc(client) || (LastMonologue[client] + 50.0) > GetGameTime())
		return;
	
	static const char dialogue[][] =
	{
		"There's so much blood...",
		"Fuck... I'm dying...",
		"Agghh...",
		"Help me! ...Please...",
		"Fuck, fuck, fuck... This is bad...",
		"Help me... Please...",
		"Shit. Oh no. Oh GOD.",
		"No no no no no. Oh my god...",
		"I don't want it to end like this... Help me...",
		"This requires urgent attention...",
		"HELP ME! PLEASE!",
		"I am bleeding the FUCK out...",
		"I-I'm not ready for t-this...",
		"This is bad. This is bad. This is BAD.",
		"Ain't this going... A-amazing...",
		"This is h-horrifying...",
		"Why... Why is... I... Need help...",
		"FUCK! FUCK! BANDAGE!",
		"HELP ME! I'M... Bleeding... Please...",
		"Are... Are these my last moments..?",
		"Focus... Focus... We can fix this...",
		"I can fix this... Come on... Fuck...",
		"This is a... fucking... nightmare...",
		"AHHHH! AAAAAHHHH!",
		"No, no no. No. Please. Fuck. FUCK. H-help me...",
		"*terrified*",
		"I-I-I... Oh... N-No... I... Oh g-god...",
		"I-is this it...",
		"F-fuck... Focus... I can s-salvage this...",
		"Oh god. Shit. I... I'm scared...",
		"My vision is all blurry...",
		"Bandage! U-urgent..."
	};
	
	PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)], _, true);
}

void Gunsaw_Monologue_PlayerDeath(const float pos[3])
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(!Gunsaw_IsMerc(client) || (LastMonologue[client] + 20.0) > GetGameTime())
			continue;

		float pos2[3];
		if(GetVectorDistance(pos, pos2, true) > 150000.0)
			continue;
		
		int mood = MonologueMoodLevel(client);
		if(mood < -3)
		{
			static const char dialogue[][] =
			{
                "I'll join you soon.",
                "Not long until I end up like that.",
                "I wish I was in their place.",
                "Everything will end soon.",
                "Maybe I wont be so miserable on the other side.",
                "God, I want to be fucking dead too...",
                "Being a corpse sounds very attractive right about now.",
                "At least you managed to escape...",
                "You've found your escape.",
                "I don't blame you.",
                "Any room for me...?",
                "Yeah, fuck this place, buddy. I'll be with you soon enough.",
                "I fucking hate this world.",
                "I'll end up like this soon enough.",
                "This brings me comfort. A reminder that it'll all end soon.",
                "You got lucky.",
                "I wish I was as lucky as you are.",
                "I agree.",
                "Yeah. This is a burden not worth carrying.",
                "I can't wait for when I get the guts to end it.",
                "I'm jealous."
			};
			
			PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
		}
		else if(mood < -2)
		{
			static const char dialogue[][] =
			{
                "And another...",
                "Mhm.",
                "There's so many...",
                "I think I'm getting used to the sight.",
                "I think this counts as genocide at this point...",
                "So many innocent lives lost...",
                "This one looks funny.",
                "I've seen a lot of these by now.",
                "This place is FILLED with corpses!",
                "That's gotta hurt.",
                "Not a good mortality rate in here.",
                "This place has taken so many lives...",
                "I'm better than this...",
                "That looks like it hurt.",
                "This one is still smiling!",
                "I already lost count.",
                "Someone ought to arrange a funeral for 'em...",
                "That sucks...",
                "I wonder if any of them can be saved.",
                "Hahaha...",
                "Hey! You! ...Yeah, they're not any different.",
                "Man, these guys must REALLY not like me... Not a single one even looked at me!",
                "Let's just move on.",
                "Survival of the fittest, I guess...",
                "Eugh.",
                "And another one.",
                "And another!",
                "Aaaannnd another one...",
                "So many dead guys...",
                "This is getting boring by now.",
                "I'm astonished how many of us have died here.",
                "....",
                "It's that time of the day again...",
                "I have a sneaking suspicion this one is dead.",
                "Fuck.",
                "Hey, little dead fella.",
                "This one looks funny. Haha!",
                "This one looks silly...",
                "They're smiling at me!",
                "Hey.",
                "Hello there!",
                "Such generosity.",
                "...And. That, ladies and gentlemen... Is another corpse.",
                "Ooh.",
                "That's not sanitary.",
                "I don't think they enjoyed their stay.",
                "Ough, you smell! Go take a shower...",
                "Mmh...",
                "Aaaanother...",
                "Seeing all of these is saddening.",
                "I'd make a joke, but I don't like disrespecting the dead.",
                "Yeah...",
                "Someone got unlucky."
			};
			
			PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
		}
		else
		{
			static const char dialogue[][] =
			{
                "Oh... Oh god.",
                "Shit.",
                "Better you than me, buddy...",
                "That's not very reassuring.",
                "Hey! Are you... O-oh...",
                "Fuck me man... That's a bad sight.",
                "No no no no. Oh god...",
                "I feel bad for them...",
                "I hope I won't end up like this.",
                "Yikes... Ew... Man.",
                "I don't think they're breathing...",
                "Yep, that's a corpse alright...",
                "I can't help but stare...",
                "Fuck that... Ough... That sucks.",
                "Poor little guy.",
                "Fuck...",
                "Awww... That's a sad sight.",
                "I knew there were more of us here...",
                "It's gonna be okay... It's gonna be okay.",
                "Oh fuck. They're dead...",
                "*gasp*",
                "*frown*",
                "Someone should give them a proper burial.",
                "I shouldn't touch them...",
                "God fucking damn it. Ugh. They're dead.",
                "I better not end up like this.",
                "...",
                "...!",
                "Oh damn it. Fuck. I hate that...",
                "I wish I could've given this guy a hug before they passed away.",
                "God...",
                "I want to leave this place... Fuck...",
                "That's a dead guy...",
                "I hope it wasn't painful, at least...",
                "Awww... Poor thing...",
                "I'm scared I'll meet the same fate...",
                "AHH! That's a corpse! Fuck...",
                "Oh fuck... That's one of our own... Ooohhh no...",
                "Well, that's demotivating.",
                "They're... They're not breathing..."
			};
			
			PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
		}
	}
}

static void Monologue_Drug(int client)
{
	int mood = MonologueMoodLevel(client);
	if(mood < -2)
	{
		static const char dialogue[][] =
		{
			"That's... much better.",
			"I can... relax now...",
			"Finally... a sense of peace...",
			"I really... needed that...",
			"I just need to relax... I just need to relax...",
			"This'll calm me down... this'll... oogh...",
			"I really need this.",
			"I feel at... ease...",
			"Distract me...",
			"I feel so much... better...",
			"That'll shut... me up...",
			"I feel better... Ohh... yes...",
			"Enough thinking...",
			"I could... do this more!...",
			"Freeeedooooommm...",
			"Thank you, silly stuff...",
			"I need to stop thinking... stop thinking...",
			"Just to... Get my mind off of these things...",
			"Clear my mind... clear my mind...",
			"No more... suffering...",
			"Ahhhhhh... good..."
		};

		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
	}
	else
	{
		static const char dialogue[][] =
		{
			"I think I'm drugged...",
			"I feel woooooozzzyyy...",
			"It's hard to focus...",
			"This feels gggreeatttt...",
			"This can't be good for me but I feel great.",
			"Ha-ha... I like this...",
			"What did I just put into my body...",
			"I feel... Sleepy...?",
			"I... Can't focus...",
			"I feel like something's in my lungs...",
			"It's a bit hard to breathe...",
			"I feel like I'm gonna pass out... And I love it...",
			"I feel funny...",
			"Ooggh... yeaaaahhh...",
			"I'm tingling...",
			"I love this... feeling?...",
			"I want more of this...",
			"I want more of whatever this is..."
		};

		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
	}
}

static void Monologue_Idle(int client)
{
	if(!Gunsaw_IsMerc(client) || (LastMonologue[client] + 80.0) > GetGameTime())
		return;
	
	int mood = MonologueMoodLevel(client);
	if(dieingstate[client])
	{
		static const char dialogue[][] =
		{
			"I don't... want to die... I don't want to die...",
			"Please... Please... Someone save... Save me...",
			"I don't want to die... Please... Please...",
			"Not... Not like this... Please... Help me...",
			"H-help... Someone... I don't w-want to die...",
			"I don't... I don't want to leave this world...",
			"Save me... Save me... S-save me... Please...",
			"This.. Is... H-h... Is this how... How it ends...",
			"All... Everything I've done... To... To lead up to t-this... Save m-me...",
			"No.. No.... N-no... Please... Please... I don't... I-I don't want to d-die... Help me...",
			"Ffhh... Gh.... Help me... Please... Anyone...",
			"Nhh... Not like t-this... Please... P-please... Save me...",
			"Please... I don't... I don't want to die... Save me... Anyone... Anything... I-I'm not r-ready...",
			"W-Will it be.. Over s-soon..?",
			"Stop... Stop... Stop... Please... S-stop... Not l-like this... Save me...",
			"Fuck... Fuck... Help me... I don't... Want to d-die... H-h.."
		};

		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)], _, true);
	}
	else if(GetClientHealth(client) < (ReturnEntityMaxHealth(client) / 6))
	{
		static const char dialogue[][] =
		{
			"I taste metal.",
			"Did I eat something metallic?",
			"I didn't know metal had a smell.",
			"There's a metal taste in my mouth...",
			"...Metal...?",
			"What     is  happening",
			"This      this  is    wrong .",
			"I'm smelling something REALLY weird...",
			"This isn't right. I feel a metallic taste...",
			"Nor something angrily nor blissfully few?",
			"An no one ourselves dry for invent by means of a most.",
			"Very Well! Dynamics two zero nine fourty-two thre two two eight two seven.",
			"Villa hastily the oho! Onto no one?",
			"Good! Certainty someone itself I urgently!",
			"For as oddly whom urgently him mate rats! Miner herself right on.",
			"Expand ptui!",
			"Travel truthfully deflation the improve which one another an a?",
			"I see shadows in my eyes...",
			"The colors of everything... It all tastes wrong...",
			"...Wh... ...What... Yeah... Yes!",
			"I smell copper.",
			"This smell does not smell possible...",
			"Si tir ti vucot svaklar si mi.",
			"The",
			"Ough! I taste metal... So much metal...",
			"Kovgam varmunch persvek sia narod!",
			"Since when does everything smell like this..?",
			"This tastes wrong. Very wrong... Am I sick..?",
			"Gh... Hh-h...",
			"What was that!?",
			"Am... Am I imagining things..?"
		};

		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
	}
	else if(DrugNerf[client] > 799)
	{
		static const char dialogue[][] =
		{
			"I can't breathe!",
			"I... can't breathe...",
			"Help... I'm suffocating...",
			"Cough! Cough! Ack!",
			"I'm passing out...",
			"What's happening... Help...",
			"Cough- H-help...",
			"I c-can't breathe...!",
			"I'm-... Suffocating!...",
			"Ahk! Cough!",
			"Need... Air!...",
			"M-My... neck!...",
			"I can't.... Cough! Hack!",
			"Help- Ack! Cough!",
			"H-help...",
			"My... chest...",
			"My... chest- Cough! Hack!",
			"My lungs...",
			"*gasping*",
			"I feel like I'm dying...",
			"I'm gonna... pass out...",
			"Can't... breathe...",
			"My insides..."
		};

		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)], _, true);
	}
	else if(DrugNerf[client] > 399)
	{
		static const char dialogue[][] =
		{
			"I... I need drugs...",
			"Opiates... Please...",
			"I-I really n-need more opiates...",
			"I'm all shaky...",
			"I could chug an entire b-bottle of painkillers...",
			"I think I'm going t-through withdrawal...",
			"I-I really n-need another shot...",
			"F-fuck... I feel terrible... I really need... something...",
			"I'm... I'm so shaky... I need some more...",
			"I feel terrible- I need... I need more of that stuff...",
			"It's getting to me... I'm shaky... Fuck.",
			"Need... more... opioids.",
			"I'm f-feeling so... terrible... I-I need more...",
			"Painkillers...",
			"I... I need something... I need that high...",
			"F-Fuck... uuggh... withdrawal...",
			"I'm- f-feeling like shit... I need a dose- NOW.",
			"I-I could use a dose right about now.",
			"I could u-use a dose.",
			"I'm... getting the shakes...",
			"I need to stop using this crap...",
			"All I can think a-about is another shot...",
			"Opioids...",
			"I'm so shaky and lightheaded... I-I need more opioids...",
			"Need more... D-drugs..."
		};

		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
	}
	else if(mood < -3)
	{
		static const char dialogue[][] =
		{
			"...Why am I trying this?",
			"I can't do this. I just can't.",
			"Was I born, to only feel pain?",
			"They won't get away with this.",
			"Make it stop... Make it stop...",
			"I am about to FUCKING snap.",
			"I'm completely hollow.",
			"This is not worth living through.",
			"STOP. THIS.",
			"I DON'T WANT TO FUCKING CONTINUE THIS.",
			"I am so fucking done with all of this.",
			"I'm not willing to walk another step.",
			"I'm going to DEVOUR whoever put me here.",
			"Is this a fucking joke?",
			"I. Am. Going. To. FUCKING. SNAP.",
			"WHY!?",
			"AAAHHHHHHH!",
			"HEELPPP!!! PLEASE!",
			"THIS IS TOO FUCKING MUCH.",
			"Ahahahah...",
			"Hmph.",
			"Ain't this just fucking lovely?",
			"Mhm.",
			"Okay.",
			"...",
			"FUCK. This.",
			"W-what's happening again?",
			"Hahaha...",
			"Ooohhh boy...",
			"I died the moment I arrived here."
		};

		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
	}
	else if(mood < -2)
	{
		static const char dialogue[][] =
		{
			"I can't take this anymore.",
			"...Why am I trying this?",
			"I should... just... let go...",
			"I can't keep going on like this...",
			"Should I... keep trying?",
			"There's no point to this...",
			"Please... anything to make me feel better...",
			"Can something ease my suffering? Anything?",
			"I just want this to stop.",
			"This is my life now... Great.",
			"I'm too pathetic for this...",
			"This place is going to tear me apart.",
			"I'm not going to make it through this.",
			"What am I going to do...",
			"I'll never get out of this.",
			"Fuck this.",
			"What's even the point anymore.",
			"I can't do this... much longer.",
			"I need something to help me forget this.",
			"I feel. Terrible.",
			"Why did they do this to me?",
			"Who dumped me here, just for me to suffer?...",
			"I wish I could just... understand this more.",
			"I need to distract myself.",
			"...Not....Okay....",
			"I feel genuinely horrible.",
			"DAMN it!",
			"I want to cry...",
			"Maaaannnnn...",
			"I'm struggling really bad...",
			"I'm going to fucking kill whoever is putting me through this.",
			"I am going to fucking snap.",
			"Oh... Oh no.",
			"...",
			"Damn it... DAMN IT!!! Why the FUCK am I HERE???",
			"Don't push me any fucking further.",
			"I don't... I don't want to die here...",
			"Someone... Anyone... Please, help me...",
			"HEEELPPP!!! ANYONE!? PLEASE!!!...",
			"There's no point to this, is there?",
			"All of this is fucking revolting.",
			"Life hates me.",
			"AAAHHH!!",
			"Hahahaha..."
		};

		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
	}
	else if(mood < -1)
	{
		static const char dialogue[][] =
		{
			"Things could be better.",
			"This is just... terrible.",
			"I hope things get better. Quick.",
			"This is going down hill...",
			"I'm getting tired of this.",
			"Ugh... this sucks...",
			"I'm not content with this.",
			"This can't get any worse.",
			"My patience is being tested...",
			"What's gonna happen now?...",
			"Can't give up yet...",
			"I have no luck at this point.",
			"I don't like where this is going.",
			"I hate this. Ugh.",
			"Feeling a bit under the weather.",
			"Recent events have been terrible.",
			"I wouldn't mind something fun right now.",
			"I need entertainment or something... ugh...",
			"Absolutely tired of this.",
			"Terrible. just... terrible...",
			"From one thing to another...",
			"Things better straighten up...",
			"Fuck this... Ugh!",
			"Morale's low.",
			"Ugh!",
			"I'm in the dumps.",
			"I feel really down.",
			"Man...",
			"I'm really scared...",
			"Fuck this, man... Ugh...",
			"I really want out of here.",
			"I'm unhappy."
		};

		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
	}
	else if(mood < 0)
	{
		static const char dialogue[][] =
		{
			"Things could be worse.",
			"Hmm...",
			"Am I doing things right?...",
			"I must keep going.",
			"Just need to keep going...",
			"This probably isn't so bad...",
			"What else could go wrong?",
			"Uhm... hmm...",
			"Ugh. C'mon...",
			"I've been through worse...",
			"Just worse than usual...",
			"I can do this... I can do this...",
			"Just breathe in, and breathe out...",
			"I could do better...",
			"Can't give up yet...",
			"This is my life now.",
			"Just keep moving.",
			"Getting a little tired of this.",
			"Not my lucky day.",
			"I can't let all of this get to me...",
			"Things are just rough sometimes... Yeah...",
			"Ugh.",
			"I feel down.",
			"I don't like what's happening.",
			"W-why am I even here?",
			"Why me?",
			"I'm scared.",
			"Is this what my life is going to be now?"
		};

		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
	}
	else
	{
		static const char dialogue[][] =
		{
			"*yawn*",
			"What time is it?",
			"I feel drowsy...",
			"I'm a little tired.",
			"I could go for a nap.",
			"Nap time is coming...",
			"I'm kinda tired.",
			"I'm getting sleepy.",
			"Resting myself sounds nice.",
			"Sleep sounds great right now.",
			"I should rest my head soon.",
			"Nap time...",
			"I'm sleepy.",
			"I need to sleep soon.",
			"Getting rest isn't a bad idea right now...",
			"I need a nice nap.",
			"Mmmm... tired...",
			"Getting a little drowsy.",
			"I kind-of want to lay down.",
			"Could do with a lay-down.",
			"I'm sleepy...",
			"Maybe that's enough for today...?",
			"Sleepy...",
			"I'm thirsty.",
			"I'd love a drink.",
			"I feel thirsty.",
			"I'm thirsty!",
			"Thirsty.",
			"Need water.",
			"I need water.",
			"I want a drink.",
			"My mouth's dry.",
			"Water would hit the spot.",
			"Mouth's a little dry.",
			"Bah... thirsty...",
			"I need a drink.",
			"Never enough water.",
			"Any water?",
			"Water?",
			"Could do with a drink.",
			"I'd love to quench my thirst.",
			"Could do with some water.",
			"It's cold in here.",
			"It's chilly!",
			"I feel cold.",
			"It's chilly in here.",
			"Just a hint... cold here.",
			"I'm starting to shiver.",
			"Hmph... cold.",
			"Is it me or is it cold?",
			"Feeling a little cold.",
			"Cold in here...",
			"I should try to stay warm.",
			"Brrr.",
			"I feel a little chilly.",
			"It's nippy in here!",
			"I'm cold.",
			"It's a little hot in here.",
			"I feel warm.",
			"I'm a little too warm.",
			"Too warm for comfort.",
			"I'd like to cool down.",
			"I'm starting to sweat a bunch.",
			"I need to cool off.",
			"I'm uncomfortably hot.",
			"I need to chill out- literally.",
			"Something to cool me off would be nice...",
			"I'm burning up...",
			"It's a little warm here...",
			"I'm sweating!",
			"I'd like to stop for a moment.",
			"What an exercise!",
			"Can we pause...",
			"I need a pause...",
			"Whew... i'm exhausted...",
			"I'm a bit drained...",
			"I need a break.",
			"I should stop a bit... I feel all flimsy.",
			"I need to take a moment...",
			"I need a moment to sit.",
			"I'm a little exerted...",
			"Gosh... so much work...",
			"I'm worn out...",
			"Taking a break sounds good...",
			"I feel exerted...",
			"Real workout over here!",
			"I want to rest!",
			"Let's sit down for a moment.",
			"Ugh... I'm so dirty!",
			"I really need a bath.",
			"I'm covered in bog.",
			"I'm all covered in dirt.",
			"I think I need a shower.",
			"It might just be me, but I think I'm starting to smell.",
			"All this dirt on me... I feel like an animal.",
			"This is not very hygienic...",
			"Can't I take a quick bath?",
			"I should clean myself.",
			"I need to clean off all this dirt.",
			"Way too dirty.",
			"Really should wash all the dirt off...",
			"Let's not get THIS unclean...",
			"Time for a bath!",
			"How'd I get so dirty?",
			"Gosh, I am COVERED in gunk!",
			"My fur is so yucky!",
			"Guh! I'm completely covered in filth.",
			"I feel filthy. I really need a bath, or something...",
			"Could do with a shower!",
			"Carrying a bit much.",
			"Do I need this much on me..?",
			"I'm kind of weighed down...",
			"I should drop some things...",
			"I should leave some of my belongings, they're really heavy...",
			"Ough, I'm way too weighed down.",
			"Carrying too much...",
			"I'm hoarding too much...",
			"As much as I feel like all of these things will be useful, I'm really weighed down...",
			"The load is a little much...",
			"I feel weighed down by all I am carrying.",
			"Let's lighten the load a little.",
			"I'm a bit overloaded with gear.",
			"Carrying uncomfortably much...",
			"I'd love to lessen the load a little...",
			"I need to leave some stuff behind, there's too much on me.",
			"I really should free up a hand or two. I'm carrying a lot...",
			"Ugh! Too much gear on me. I feel weighed down.",
			"Hoarding a little too much... All this gear is heavy."
		};

		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
		LastMonologue[client] = GetGameTime();
	}

	Citizen_LiveCitizenReaction(client);
}

void Gunsaw_Monologue_OnTakeDamage(int client, float damage)
{
	if(CheckInHud() || damage < 100.0 || !Gunsaw_IsMerc(client))
		return;
	
	int maxhealth = ReturnEntityMaxHealth(client);
	if(maxhealth < 300)
		maxhealth = 300;
	
	if(damage > maxhealth)
	{
		static const char dialogue[][] =
		{
			"OW!!!",
			"AGH!!!",
			"AUUGHH!",
			"AUUGHNN!",
			"OOAUAUGHHH!",
			"NHHGHH!",
			"FUUUCK!",
			"OOOWHHG!",
			"NHHGFFF!",
			"GAAH!",
			"HELP! AAHG!",
			"OWW!!!!",
			"OOUUUUCH!",
			"GGHHHBN...",
			"HEELPPP!",
			"AAAH!",
			"FUCK!",
			"CRAP!!!",
			"AHHH!!!",
			"HELP!!!",
			"NGHH!",
			"AGH...",
			"PLEASE!!",
			"STOP!!!",
			"DAMN IT!!!"
		};

		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)], true, true);
	}
	else if(damage > (maxhealth / 3))
	{
		static const char dialogue[][] =
		{
			"Agh!",
			"Gack!",
			"Fuck!",
			"Augh!",
			"Ghagh!",
			"Ugh!",
			"Ngghh!",
			"Ow!",
			"Gggouch!",
			"Argh!",
			"Nffgh...",
			"Aaawgh!",
			"Ngghhh...",
			"Ough!"
		};

		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)], true, true);
	}
}

void Gunsaw_Monologue_Pet(int client)
{
	if(!Gunsaw_IsMerc(client) || (LastMonologue[client] + 10.0) > GetGameTime())
		return;
	
	static const char dialogue[][] =
	{
		"Ahhh... Thank you, buddy.",
		"Ah! Mmhh... Thank you...",
		"Aw! You're so nice!",
		"...Thank you, I needed that."
	};

	PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
	Gunsaw_Monologue_AddMood(client, 10.0);
}

void Gunsaw_Monologue_LiveExpieReaction(int client, int entity)
{
	if(!Gunsaw_IsMerc(client) || (LastMonologue[client] + 5.0) > GetGameTime())
		return;
	
	if(entity <= MaxClients && Gunsaw_IsMerc(entity))
	{
		if(MonologueMoodLevel(entity) < 0)
		{
			static const char dialogue[][] =
			{
                "...Uh... ...Are you okay? You look a little... Disgruntled...?",
                "...? ...Um...  ...Hello..? ...You there..?",
                "...You look terrified. Are you okay? Hello...?",
                "Hey! How are yooouuuu......you don't look so well there, buddy... Uhm...",
                "Hey! ...What's with that piercing look? Uhm...",
                "...Calm down, please... It'll be fine...",
                "Hey, it's okay... You're still alive and kicking, right..."
			};

			PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
			return;
		}
		else if(!(GetURandomInt() % 9))
		{
			static const char dialogue[][] =
			{
                "There's a bunch of food out there, you know...",
                "I'd wager you can find some water out...",
                "Last I heard you can only go for three \"days\" without water, haha...",
                "...What?"
			};

			PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
			return;
		}
	}

	int mood = MonologueMoodLevel(client);
	if(mood > 1)
	{
		static const char dialogue[][] =
		{
			"Ah! Hi!!",
			"Hello! How are ya?",
			"Aah! Hello!! Hi!",
			"...Okay!",
			"Mmmmhmmm... Got it.",
			"I'll think about it.",
			"I'll consider...",
			"Y-yeah... Sure...",
			"Makes sense to me!",
			"Uh huh.",
			"Hmm... Okay."
		};

		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
	}
	else if(mood > -2)
	{
		static const char dialogue[][] =
		{
			"Hey!",
			"Hello!",
			"Oh! Heya.",
			"Hey, buddy.",
			"...Okay!",
			"Mmmmhmmm... Got it.",
			"I'll think about it.",
			"I'll consider...",
			"Y-yeah... Sure...",
			"Makes sense to me!",
			"Uh huh.",
			"Hmm... Okay.",
			"You didn't sound very convincing there.",
			"...No, thanks.",
			"Nuh uh.",
			"Not interested.",
			"What? Why would I do that..?",
			"Meeehhh... Another time.",
			"Meh.",
			"...Nhh...",
			"...Ugh. Sorry.",
			"...Huh? What? Is there something in your mouth? I can't understand you...",
			"Mmmff mff mmmmfff mhfff! That's what you sound like.",
			"I get that this is a bad scenario we're in, but you can\nat least put in some effort into speaking clearly..."
		};

		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
	}
	else
	{
		static const char dialogue[][] =
		{
			"Hheeyy...I dislike your presence..?",
			"H... Hello... Uhh...",
			"...Hey.",
			"...Hm. Hello.",
			"You didn't sound very convincing there.",
			"...No, thanks.",
			"Nuh uh.",
			"Not interested.",
			"What? Why would I do that..?",
			"Meeehhh... Another time.",
			"Meh.",
			"...Nhh...",
			"...Ugh. Sorry.",
			"...Huh? What? Is there something in your mouth? I can't understand you...",
			"Mmmff mff mmmmfff mhfff! That's what you sound like.",
			"I get that this is a bad scenario we're in, but you can\nat least put in some effort into speaking clearly..."
		};

		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
	}
}

void Gunsaw_Monologue_LoudPrefix()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(!Gunsaw_IsMerc(client) || (LastMonologue[client] + 20.0) > GetGameTime())
			continue;

		static const char dialogue[][] =
		{
			"FUCK! That was loud...",
			"GAH! Crap! My ears!",
			"AHHH! Fuck... My ears are ringing...",
			"CRAP! ... Ouuchhh... That was so loud...",
			"NO!!! Fuck me, man... Aghhh, that was loud..."
		};
		
		PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
	}
}

static void Monologue_BodySwap(int client)
{
	if(!Gunsaw_IsMerc(client) || (LastMonologue[client] + 10.0) > GetGameTime())
		return;
	
	static const char dialogue[][] =
	{
		"A feel a piece of my soul being left behind...",
		"This can't be good for me...",
		"Something gets left behind each time...",
		"Is this really worth it..?"
	};

	PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)]);
}

bool Gunsaw_KillBind(int client)
{
	if(!Gunsaw_IsMerc(client))
		return false;
	
	static float cooldown[MAXPLAYERS];
	if(fabs(cooldown[client] - GetGameTime()) < 3.0)
		return false;

	cooldown[client] = GetGameTime();
	static const char dialogue[][] =
	{
		"...Uuuhh... ...What is this beeping...?",
		"...Oh. Oh. OH. OH! NO. NO NO NO. WAIT. WHY? WHAT DID I DO!?",
		"...A-ah... Alright... W-well... G-goodbye, t-then..."
	};

	PlayMonologue(client, dialogue[GetURandomInt() % sizeof(dialogue)], true);

	EmitSoundToAll("mvm/sentrybuster/mvm_sentrybuster_spin.wav", client, _, 50, _, 0.7, 75);
	CreateTimer(2.3, Timer_Explode, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	return true;
}

static Action Timer_Explode(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE)
	{
		ClientCommand(client, "dsp_player %d", 35 + (GetURandomInt() % 3));

		float pos[3];
		WorldSpaceCenter(client, pos);
		TE_Particle("ExplosionCore_buildings", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
		ForcePlayerSuicide(client, true);
	}

	return Plugin_Continue;
}
