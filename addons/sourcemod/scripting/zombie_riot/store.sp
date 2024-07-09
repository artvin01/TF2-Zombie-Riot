#pragma semicolon 1
#pragma newdecls required

#define SELL_AMOUNT 0.9

static const int SlotLimits[] =
{
	1,	// 0	Head
	1,	// 1	Chest
	1,	// 2	Leggings
	1,	// 3	Shoes
	1,	// 4	Monkey Knowledge
	1,	// 5
	1,	// 6	Extra Gear
	1,	// 7	Grenade/Potion
	1,	// 8	Buildings
	1,	// 9
	1,	// 10
	1,	// 11
	1,	// 12
	1,	// 13
	1,	// 14
	1,	// 15
	1	// 16
};

enum struct ItemInfo
{
	int Cost;
	int Cost_Unlock;
	char Desc[256];
	char Rogue_Desc[256];
	char ExtraDesc[256];
	char ExtraDesc_1[256];
	
	bool HasNoClip;
	bool SemiAuto;
	
	bool SemiAuto_SingularReload;
	
	bool NoHeadshot;
	
	float SemiAutoStats_FireRate;
	int SemiAutoStats_MaxAmmo;
	float SemiAutoStats_ReloadTime;
	
	bool NoLagComp;
	bool OnlyLagCompCollision;
	bool OnlyLagCompAwayEnemy;
	bool ExtendBoundingBox;
	bool DontMoveBuildingComp;
	bool DontMoveAlliedNpcs;
	bool BlockLagCompInternal;

	int IsWand;
	bool IsWrench;
	bool IsAlone;
	bool InternalMeleeTrace;
	
	char Classname[36];
	char Custom_Name[64];

	int Index;
	int Attrib[16];
	float Value[16];
	int Attribs;

	int Index2;
	int Attrib2[16];
	float Value2[16];
	int Attribs2;

	int Ammo;
	int AmmoBuyMenuOnly;
	
	int Reload_ModeForce;

	float DamageFallOffForWeapon; //Can this accept reversed?

	float BackstabCD;
	float BackstabDMGMulti;
	float BackstabHealOverThisTime;
	float BackstabHealTotal;
	bool BackstabLaugh;
	bool NoRefundWanted;
	float BackstabDmgPentalty;
	
	Function FuncAttack;
	Function FuncAttackInstant;
	Function FuncAttack2;
	Function FuncAttack3;
	Function FuncReload4;
	Function FuncOnDeploy;
	Function FuncOnHolster;
	int WeaponSoundIndexOverride;
	int WeaponModelIndexOverride;
	float WeaponSizeOverride;
	float WeaponSizeOverrideViewmodel;
	char WeaponModelOverride[128];
	char WeaponSoundOverrideString[255];
	float ThirdpersonAnimModif;
	int WeaponVMTExtraSetting;
	int Weapon_Bodygroup;
	float WeaponVolumeStiller;
	float WeaponVolumeRange;
	
	int Attack3AbilitySlot;
	bool VisualDescOnly;
	
	int SpecialAdditionViaNonAttribute; //better then spamming attribs.
	int SpecialAdditionViaNonAttributeInfo; //better then spamming attribs.

	int SpecialAttribRules;
	int SpecialAttribRules_2;

	int WeaponArchetype;
	int WeaponForceClass;
	
	int CustomWeaponOnEquip;
	int Weapon_Override_Slot;
	int Melee_AttackDelayFrame;
	bool Melee_Allows_Headshots;
	
	int ScrapCost;
	int UnboxRarity;
	bool CannotBeSavedByCookies;
	Function FuncOnBuy;
	int PackBranches;
	int PackSkip;

	void Self(ItemInfo info)
	{
		info = this;
	}
	
	bool SetupKV(KeyValues kv, const char[] name, const char[] prefix="")
	{
		static char buffer[512];
		
		Format(buffer, sizeof(buffer), "%scost", prefix);
		this.Cost = kv.GetNum(buffer, -1);
		if(this.Cost < 0)
			return false;

		Format(buffer, sizeof(buffer), "%scost_unlock", prefix);
		this.Cost_Unlock = kv.GetNum(buffer, this.Cost);
		
		Format(buffer, sizeof(buffer), "%sdesc", prefix);
		kv.GetString(buffer, this.Desc, 256);

		Format(buffer, sizeof(buffer), "%sextra_desc", prefix);
		kv.GetString(buffer, this.ExtraDesc, 256);

		Format(buffer, sizeof(buffer), "%sextra_desc_more", prefix);
		kv.GetString(buffer, this.ExtraDesc_1, 256);

		Format(buffer, sizeof(buffer), "%srogue_desc", prefix);
		kv.GetString(buffer, this.Rogue_Desc, 256);
		
		Format(buffer, sizeof(buffer), "%sclassname", prefix);
		kv.GetString(buffer, this.Classname, 36);

		Format(buffer, sizeof(buffer), "%sindex", prefix);
		this.Index = kv.GetNum(buffer);

		Format(buffer, sizeof(buffer), "%sindex_2", prefix);
		this.Index2 = kv.GetNum(buffer);
		
		Format(buffer, sizeof(buffer), "%sammo", prefix);
		this.Ammo = kv.GetNum(buffer);

		Format(buffer, sizeof(buffer), "%sammoBuyOnly", prefix);
		this.AmmoBuyMenuOnly = kv.GetNum(buffer);
		
		Format(buffer, sizeof(buffer), "%sreload_mode", prefix);
		this.Reload_ModeForce = kv.GetNum(buffer);

		Format(buffer, sizeof(buffer), "%sdamage_falloff", prefix);
		this.DamageFallOffForWeapon		= kv.GetFloat(buffer, 0.9);
		
		Format(buffer, sizeof(buffer), "%sbackstab_cd", prefix);
		this.BackstabCD				= kv.GetFloat(buffer, 1.5);
		
		Format(buffer, sizeof(buffer), "%sbackstab_dmg_multi", prefix);
		this.BackstabDMGMulti		= kv.GetFloat(buffer, 0.0);
		
		Format(buffer, sizeof(buffer), "%sheal_over_this_time", prefix);
		this.BackstabHealOverThisTime		= kv.GetFloat(buffer, 0.0);

		Format(buffer, sizeof(buffer), "%sbackstab_total_heal", prefix);
		this.BackstabHealTotal		= kv.GetFloat(buffer, 0.0);

		Format(buffer, sizeof(buffer), "%sbackstab_laugh", prefix);
		this.BackstabLaugh		= view_as<bool>(kv.GetNum(buffer, 0));

		Format(buffer, sizeof(buffer), "%sno_refund_allowed", prefix);
		this.NoRefundWanted = view_as<bool>(kv.GetNum(buffer));

		//Format(buffer, sizeof(buffer), "%ssniperfix", prefix);
		//this.SniperBugged = view_as<bool>(kv.GetNum(buffer));
		
		/*
		
			//LagCompArgs, instead of harcoding indexes i will use bools and shit.
				
			"lag_comp" 						"0"
			"lag_comp_comp_collision" 		"0"
			"lag_comp_ignore_player" 		"0"
			"lag_comp_dont_move_building" 	"1"
				
			//These are the defaults for anything that shouldnt trigger lag comp at all.
				
		*/
		
		Format(buffer, sizeof(buffer), "%slag_comp", prefix);
		this.NoLagComp				= view_as<bool>(kv.GetNum(buffer));
		
		Format(buffer, sizeof(buffer), "%slag_comp_collision", prefix);
		this.OnlyLagCompCollision	= view_as<bool>(kv.GetNum(buffer));
		
		Format(buffer, sizeof(buffer), "%slag_comp_away_everything_enemy", prefix);
		this.OnlyLagCompAwayEnemy	= view_as<bool>(kv.GetNum(buffer));
		
		Format(buffer, sizeof(buffer), "%slag_comp_extend_boundingbox", prefix);
		this.ExtendBoundingBox		= view_as<bool>(kv.GetNum(buffer));
		
		Format(buffer, sizeof(buffer), "%slag_comp_dont_move_building", prefix);
		this.DontMoveBuildingComp	= view_as<bool>(kv.GetNum(buffer));
	
		Format(buffer, sizeof(buffer), "%slag_comp_dont_allied_npc", prefix);
		this.DontMoveAlliedNpcs	= view_as<bool>(kv.GetNum(buffer));
		
		Format(buffer, sizeof(buffer), "%slag_comp_block_internal", prefix);
		this.BlockLagCompInternal	= view_as<bool>(kv.GetNum(buffer));
		
		Format(buffer, sizeof(buffer), "%sno_clip", prefix);
		this.HasNoClip				= view_as<bool>(kv.GetNum(buffer));
		
		Format(buffer, sizeof(buffer), "%ssemi_auto", prefix);
		this.SemiAuto				= view_as<bool>(kv.GetNum(buffer));
		
		Format(buffer, sizeof(buffer), "%sno_headshot", prefix);
		this.NoHeadshot				= view_as<bool>(kv.GetNum(buffer));

		Format(buffer, sizeof(buffer), "%sis_a_wand", prefix);
		this.IsWand	= view_as<int>(kv.GetNum(buffer));

		Format(buffer, sizeof(buffer), "%sis_a_wrench", prefix);
		this.IsWrench	= view_as<bool>(kv.GetNum(buffer));

		Format(buffer, sizeof(buffer), "%signore_upgrades", prefix);
		this.IsAlone	= view_as<bool>(kv.GetNum(buffer));

		Format(buffer, sizeof(buffer), "%sinternal_melee_trace", prefix);
		this.InternalMeleeTrace	= view_as<bool>(kv.GetNum(buffer, 1));
		
		Format(buffer, sizeof(buffer), "%ssemi_auto_stats_fire_rate", prefix);
		this.SemiAutoStats_FireRate				= kv.GetFloat(buffer);
		
		Format(buffer, sizeof(buffer), "%ssemi_auto_stats_maxAmmo", prefix);
		this.SemiAutoStats_MaxAmmo				= kv.GetNum(buffer);
		
		Format(buffer, sizeof(buffer), "%ssemi_auto_stats_reloadtime", prefix);
		this.SemiAutoStats_ReloadTime			= kv.GetFloat(buffer);
	
		Format(buffer, sizeof(buffer), "%sweapon_sound_index_override", prefix);
		this.WeaponSoundIndexOverride	= view_as<bool>(kv.GetNum(buffer, 0));

		Format(buffer, sizeof(buffer), "%ssound_weapon_override_string", prefix);
		kv.GetString(buffer, this.WeaponSoundOverrideString, sizeof(buffer));

		Format(buffer, sizeof(buffer), "%smodel_weapon_override", prefix);
		kv.GetString(buffer, this.WeaponModelOverride, sizeof(buffer));
		
		Format(buffer, sizeof(buffer), "%sweapon_vmt_setting", prefix);
		this.WeaponVMTExtraSetting	= view_as<bool>(kv.GetNum(buffer, -1));

		Format(buffer, sizeof(buffer), "%sweapon_bodygroup", prefix);
		this.Weapon_Bodygroup	= view_as<int>(kv.GetNum(buffer, -1));

		Format(buffer, sizeof(buffer), "%sweapon_custom_size", prefix);
		this.WeaponSizeOverride			= kv.GetFloat(buffer, 1.0);

		Format(buffer, sizeof(buffer), "%smodif_attackspeed_anim", prefix);
		this.ThirdpersonAnimModif			= kv.GetFloat(buffer, 1.0);

		Format(buffer, sizeof(buffer), "%sweapon_custom_size_viewmodel", prefix);
		this.WeaponSizeOverrideViewmodel			= kv.GetFloat(buffer, 1.0);

		Format(buffer, sizeof(buffer), "%sweapon_volume_stiller", prefix);
		this.WeaponVolumeStiller			= kv.GetFloat(buffer, 1.0);

		Format(buffer, sizeof(buffer), "%sweapon_volume_range", prefix);
		this.WeaponVolumeRange		= kv.GetFloat(buffer, 1.0);

		Format(buffer, sizeof(buffer), "%sbackstab_multi_dmg_penalty_bosses", prefix);
		this.BackstabDmgPentalty			= kv.GetFloat(buffer, 1.0);

		if(this.WeaponModelOverride[0])
		{
			this.WeaponModelIndexOverride = PrecacheModel(this.WeaponModelOverride, true);
		}
		else
		{
			this.WeaponModelIndexOverride = 0;
		}

		if(this.WeaponSoundOverrideString[0])
		{
			//precache the sound!
			PrecacheSound(this.WeaponSoundOverrideString, true);
		}
	
		
		Format(buffer, sizeof(buffer), "%sfunc_attack", prefix);
		kv.GetString(buffer, buffer, sizeof(buffer));
		this.FuncAttack = GetFunctionByName(null, buffer);
		
		Format(buffer, sizeof(buffer), "%sfunc_attack_immediate", prefix);
		kv.GetString(buffer, buffer, sizeof(buffer));
		this.FuncAttackInstant = GetFunctionByName(null, buffer);
		
		Format(buffer, sizeof(buffer), "%sfunc_attack2", prefix);
		kv.GetString(buffer, buffer, sizeof(buffer));
		this.FuncAttack2 = GetFunctionByName(null, buffer);
		
		Format(buffer, sizeof(buffer), "%sfunc_attack3", prefix);
		kv.GetString(buffer, buffer, sizeof(buffer));
		this.FuncAttack3 = GetFunctionByName(null, buffer);
		
		Format(buffer, sizeof(buffer), "%sfunc_reload", prefix);
		kv.GetString(buffer, buffer, sizeof(buffer));
		this.FuncReload4 = GetFunctionByName(null, buffer);
		
		Format(buffer, sizeof(buffer), "%sfunc_ondeploy", prefix);
		kv.GetString(buffer, buffer, sizeof(buffer));
		this.FuncOnDeploy = GetFunctionByName(null, buffer);
		
		Format(buffer, sizeof(buffer), "%sfunc_onholster", prefix);
		kv.GetString(buffer, buffer, sizeof(buffer));
		this.FuncOnHolster = GetFunctionByName(null, buffer);
		
		Format(buffer, sizeof(buffer), "%sint_ability_onequip", prefix);
		this.CustomWeaponOnEquip 		= kv.GetNum(buffer);

		


		Format(buffer, sizeof(buffer), "%soverride_weapon_slot", prefix);
		this.Weapon_Override_Slot 		= kv.GetNum(buffer, -1);

		Format(buffer, sizeof(buffer), "%smelee_attack_frame_delay", prefix);
		this.Melee_AttackDelayFrame 		= kv.GetNum(buffer, 12);

		
		Format(buffer, sizeof(buffer), "%smelee_can_headshot", prefix);
		this.Melee_Allows_Headshots 		= view_as<bool>(kv.GetNum(buffer, 0));
		
		Format(buffer, sizeof(buffer), "%sattack_3_ability_slot", prefix);
		this.Attack3AbilitySlot			= kv.GetNum(buffer);
		
		Format(buffer, sizeof(buffer), "%svisual_desc_only", prefix);
		this.VisualDescOnly			= view_as<bool>(kv.GetNum(buffer, 0));
		
		Format(buffer, sizeof(buffer), "%sspecial_attribute", prefix);
		this.SpecialAdditionViaNonAttribute			= kv.GetNum(buffer);

		Format(buffer, sizeof(buffer), "%sspecial_attribute_info", prefix);
		this.SpecialAdditionViaNonAttributeInfo			= kv.GetNum(buffer, 0);
		
		static char buffers[32][16];
		Format(buffer, sizeof(buffer), "%sattributes", prefix);
		kv.GetString(buffer, buffer, sizeof(buffer));
		this.Attribs = ExplodeString(buffer, ";", buffers, sizeof(buffers), sizeof(buffers[])) / 2;
		for(int i; i < this.Attribs; i++)
		{
			this.Attrib[i] = StringToInt(buffers[i*2]);
			if(!this.Attrib[i])
			{
				LogMessage("Found invalid attribute on '%s'", name);
				this.Attribs = i;
				break;
			}
			
			this.Value[i] = StringToFloat(buffers[i*2+1]);
		}

		
		Format(buffer, sizeof(buffer), "%sattributes_check", prefix);
		this.SpecialAttribRules			= kv.GetNum(buffer);
		
		Format(buffer, sizeof(buffer), "%sattributes_2", prefix);
		kv.GetString(buffer, buffer, sizeof(buffer));
		this.Attribs2 = ExplodeString(buffer, ";", buffers, sizeof(buffers), sizeof(buffers[])) / 2;
		for(int i; i<this.Attribs2; i++)
		{
			this.Attrib2[i] = StringToInt(buffers[i*2]);
			if(!this.Attrib2[i])
			{
				LogMessage("Found invalid attribute_2 on '%s'", name);
				this.Attribs2 = i;
				break;
			}
			
			this.Value2[i] = StringToFloat(buffers[i*2+1]);
		}

		
		Format(buffer, sizeof(buffer), "%sattributes_check_2", prefix);
		this.SpecialAttribRules_2			= kv.GetNum(buffer);

		Format(buffer, sizeof(buffer), "%sweapon_archetype", prefix);
		this.WeaponArchetype			= kv.GetNum(buffer, 0);

		Format(buffer, sizeof(buffer), "%sviewmodel_force_class", prefix);
		this.WeaponForceClass			= kv.GetNum(buffer, 0);

		Format(buffer, sizeof(buffer), "%sfunc_onbuy", prefix);
		kv.GetString(buffer, buffer, sizeof(buffer));
		this.FuncOnBuy = GetFunctionByName(null, buffer);

		/*Format(buffer, sizeof(buffer), "%stier", prefix);
		this.Tier = kv.GetNum(buffer, -1);
		
		Format(buffer, sizeof(buffer), "%srarity", prefix);
		this.Rarity = kv.GetNum(buffer);
		if(this.Rarity > HighestTier)
			HighestTier = this.Rarity;*/
		
		Format(buffer, sizeof(buffer), "%sscrap_cost", prefix);
		this.ScrapCost = kv.GetNum(buffer, -1);

		Format(buffer, sizeof(buffer), "%sunbox_rarity", prefix);
		this.UnboxRarity = kv.GetNum(buffer, -1);
		
		Format(buffer, sizeof(buffer), "%scannotbesaved", prefix);
		this.CannotBeSavedByCookies = view_as<bool>(kv.GetNum(buffer));

		Format(buffer, sizeof(buffer), "%spappaths", prefix);
		this.PackBranches = kv.GetNum(buffer, 1);
		
		Format(buffer, sizeof(buffer), "%spapskip", prefix);
		this.PackSkip = kv.GetNum(buffer);

		Format(buffer, sizeof(buffer), "%scustom_name", prefix);
		kv.GetString(buffer, this.Custom_Name, 64);

		return true;
	}
}

enum struct Item
{
	char Name[64];
	int Section;
	int Scale;
	int CostPerWave;
	int MaxCost;
	int MaxScaled;
	int Level;
	int Slot;
	int Special;
	bool Starter;
	bool ParentKit;
	bool ChildKit;
	bool MaxBarricadesBuild;
	bool Hidden;
	bool NoPrivatePlugin;
	bool WhiteOut;
	bool IgnoreSlots;
	char Tags[256];
	char Author[128];
	bool NoKit;
	
	ArrayList ItemInfos;
	
	int Owned[MAXTF2PLAYERS];
	int Scaled[MAXTF2PLAYERS];
	bool Equipped[MAXTF2PLAYERS];
	int Sell[MAXTF2PLAYERS];
	int BuyWave[MAXTF2PLAYERS];
	int BuyPrice[MAXTF2PLAYERS];
	float Cooldown1[MAXTF2PLAYERS];
	float Cooldown2[MAXTF2PLAYERS];
	float Cooldown3[MAXTF2PLAYERS];
	int CurrentClipSaved[MAXTF2PLAYERS];
	bool BoughtBefore[MAXTF2PLAYERS];
	int RogueBoughtRecently[MAXTF2PLAYERS];
	
	bool NPCSeller;
	bool NPCSeller_First;
	int NPCSeller_WaveStart;
	int NPCWeapon;
	bool NPCWeaponAlways;
	int GiftId;
	bool GregBlockSell;
	int GregOnlySell;
	
	bool GetItemInfo(int index, ItemInfo info)
	{
		if(!this.ItemInfos || index >= this.ItemInfos.Length)
			return false;
		
		this.ItemInfos.GetArray(index, info);
		return true;
	}
}

static const char AmmoNames[][] =
{
	"N/A",
	"Primary",
	"Secondary",
	"Scrap Metal",
	"Ball",
	"Food",
	"Jar",
	"Pistol Magazines",
	"Rockets",
	"Flamethrower Tank",
	"Flares",
	"Grenades",
	"Stickybombs",
	"Minigun Barrel",
	"Custom Bolt",
	"Medical Syringes",
	"Sniper Rifle Rounds",
	"Arrows",
	"SMG Magazines",
	"Revolver Rounds",
	"Shotgun Shells",
	"Healing Medicine",
	"Medigun Fluid",
	"Laser Battery",
	"Hand Grenade",
	"Potion Supply"
};

static ArrayList StoreItems;
static int NPCOnly[MAXTF2PLAYERS];
static int NPCCash[MAXTF2PLAYERS];
static int NPCTarget[MAXTF2PLAYERS];
static bool InLoadoutMenu[MAXTF2PLAYERS];
static KeyValues StoreBalanceLog;
static ArrayList StoreTags;
static ArrayList ChoosenTags[MAXTF2PLAYERS];
static bool UsingChoosenTags[MAXTF2PLAYERS];
static int LastMenuPage[MAXTF2PLAYERS];
static int CurrentMenuPage[MAXTF2PLAYERS];
static int CurrentMenuItem[MAXTF2PLAYERS];

static bool HasMultiInSlot[MAXTF2PLAYERS][6];
static Function HolsterFunc[MAXTF2PLAYERS] = {INVALID_FUNCTION, ...};

void Store_OnCached(int client)
{
	if(Items_HasNamedItem(client, "ZR Contest Nominator [???]"))
	{
		if(!Store_HasNamedItem(client, "ZR Contest Nominator [???] Cash"))
		{
			Store_SetNamedItem(client, "ZR Contest Nominator [???] Cash", 1);
			CashRecievedNonWave[client] += 50;
			CashSpent[client] -= 50;
		}
	}

	if(Items_HasNamedItem(client, "ZR Content Creator [???]"))
	{
		if(!Store_HasNamedItem(client, "ZR Content Creator [???] Cash"))
		{
			Store_SetNamedItem(client, "ZR Content Creator [???] Cash", 1);
			CashRecievedNonWave[client] += 50;
			CashSpent[client] -= 50;
		}
	}
}

void Store_WeaponSwitch(int client, int weapon)
{
	if(HolsterFunc[client] != INVALID_FUNCTION)
	{
		Call_StartFunction(null, HolsterFunc[client]);
		Call_PushCell(client);
		Call_Finish();

		HolsterFunc[client] = INVALID_FUNCTION;
	}

	if(weapon != -1)
	{
		if(StoreWeapon[weapon] > 0)
		{
			static ItemInfo info;

			static Item item;
			StoreItems.GetArray(StoreWeapon[weapon], item);

			if(item.Owned[client] > 0 && item.GetItemInfo(item.Owned[client] - 1, info))
			{
				if(info.FuncOnDeploy != INVALID_FUNCTION)
				{
					Call_StartFunction(null, info.FuncOnDeploy);
					Call_PushCell(client);
					Call_PushCell(weapon);
					Call_PushCell(-1);
					Call_Finish();
				}

				HolsterFunc[client] = info.FuncOnHolster;
			}
		}
	}
}

bool Store_FindBarneyAGun(int entity, int value, int budget, bool packs)
{
	if(StoreItems)
	{
		static Item item;
		static ItemInfo info;
		int choiceIndex, choiceInfo;
		int choicePrice = value;
		
		int length = StoreItems.Length;
		for(int i; i<length; i++)
		{
			StoreItems.GetArray(i, item);
			if(item.NPCWeapon >= 0 && item.GiftId == -1 && !item.Hidden && !item.NPCWeaponAlways && !item.Level)
			{
				int current;
				for(int a; item.GetItemInfo(a, info); a++)
				{
					ItemCost(0, item, info.Cost);
					current += info.Cost;
					
					if(current > budget)
						break;
					
					if(current > choicePrice)
					{
						choiceIndex = i;
						choiceInfo = a;
						choicePrice = current;
					}
					
					if(!packs || info.PackBranches != 1 || info.PackSkip)
						break;
				}
			}
		}
		
		if(choicePrice > value)
		{
			StoreItems.GetArray(choiceIndex, item);
			item.GetItemInfo(choiceInfo, info);
			Citizen_UpdateWeaponStats(entity, item.NPCWeapon, RoundToCeil(float(choicePrice) * SELL_AMOUNT), info, 0);
			return view_as<bool>(choiceInfo);
		}
	}
	return false;
}

stock bool Store_ActiveCanMulti(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon != -1)
	{
		char buffer[36];
		GetEntityClassname(weapon, buffer, sizeof(buffer));
		int slot = TF2_GetClassnameSlot(buffer);
		if(slot >= 0 && slot < sizeof(HasMultiInSlot[]))
			return HasMultiInSlot[client][slot];
	}

	return false;
}

float Ability_Check_Cooldown(int client, int what_slot, int thisWeapon = -1)
{
	int weapon = thisWeapon == -1 ? GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") : thisWeapon;
	if(weapon != -1)
	{
		if(StoreWeapon[weapon] > 0)
		{
			static Item item;
			StoreItems.GetArray(StoreWeapon[weapon], item);
			
			switch(what_slot)
			{
				case 1:
					return item.Cooldown1[client] - GetGameTime();
				
				case 2:
					return item.Cooldown2[client] - GetGameTime();
				
				case 3:
					return item.Cooldown3[client] - GetGameTime();
			}

			ThrowError("Invalid slot %d", what_slot);
		}
	}
	return 0.0;
}

void Ability_Apply_Cooldown(int client, int what_slot, float cooldown, int thisWeapon = -1)
{
	int weapon = thisWeapon == -1 ? GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") : thisWeapon;
	if(weapon != -1)
	{
		if(StoreWeapon[weapon] > 0)
		{
			static Item item;
			StoreItems.GetArray(StoreWeapon[weapon], item);
			
			switch(what_slot)
			{
				case 1:
					item.Cooldown1[client] = cooldown + GetGameTime();
				
				case 2:
					item.Cooldown2[client] = cooldown + GetGameTime();
				
				case 3:
					item.Cooldown3[client] = cooldown + GetGameTime();
				
				default:
					ThrowError("Invalid slot %d", what_slot);
			}
			
			StoreItems.SetArray(StoreWeapon[weapon], item);
		}
	}
}

void Store_OpenItemPage(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon != -1 && StoreWeapon[weapon] > 0)
	{
		static Item item;
		StoreItems.GetArray(StoreWeapon[weapon], item);
		if(item.Owned[client] && (!item.Hidden || item.ChildKit))
		{
			NPCOnly[client] = 0;
			LastMenuPage[client] = 0;
			MenuPage(client, StoreWeapon[weapon]);
		}
	}
}

stock void Store_OpenItemThis(int client, int index)
{
	static Item item;
	StoreItems.GetArray(index, item);
	//if(ItemBuyable(item))
	{
		NPCOnly[client] = 0;
		LastMenuPage[client] = 0;
		MenuPage(client, index);
	}
}

void Store_SwapToItem(int client, int swap)
{
	if(swap == -1)
		return;
	
	char classname[36], buffer[36];
	GetEntityClassname(swap, classname, sizeof(classname));

	int slot = TF2_GetClassnameSlot(classname);
	
	int length = GetMaxWeapons(client);
	for(int i; i < length; i++)
	{
		if(GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i) == swap)
		{
			for(int a; a < length && a != i; a++)
			{
				int weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", a);
				if(weapon > MaxClients)
				{
					GetEntityClassname(weapon, buffer, sizeof(buffer));
					if(TF2_GetClassnameSlot(buffer) == slot)
					{
						SetEntPropEnt(client, Prop_Send, "m_hMyWeapons", swap, a);
						SetEntPropEnt(client, Prop_Send, "m_hMyWeapons", weapon, i);
						break;
					}
				}
			}
		}
	}

	SetPlayerActiveWeapon(client, swap);
}

void Store_SwapItems(int client)
{
	//int suit = GetEntProp(client, Prop_Send, "m_bWearingSuit");
	//if(!suit)
	//	SetEntProp(client, Prop_Send, "m_bWearingSuit", true);

	int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(active > MaxClients)
	{
		char buffer[36];
		GetEntityClassname(active, buffer, sizeof(buffer));
		
		int slot = TF2_GetClassnameSlot(buffer);
		
		int length = GetMaxWeapons(client);
		for(int i; i < length; i++)
		{
			int weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
			if(weapon == active)	// Active weapon is highest up in our slot
			{
				int lowestI, nextI;
				int lowestE = -1;
				int nextE = -1;
				int switchE = active;
				int switchI = i;
				for(int a; a < length; a++)
				{
					if(a != i)
					{
						weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", a);
						if(weapon > MaxClients)
						{
							GetEntityClassname(weapon, buffer, sizeof(buffer));
							if(TF2_GetClassnameSlot(buffer) == slot)
							{
								if(a < switchI)
								{
									switchE = weapon;
									switchI = a;
								}

								if(lowestE == -1 || weapon < lowestE)
								{
									lowestE = weapon;
									lowestI = a;
								}

								if(weapon > active && (nextE == -1 || weapon < nextE))
								{
									nextE = weapon;
									nextI = a;
								}
							}
						}
					}
				}

				if(nextE == -1)
				{
					nextE = lowestE;
					nextI = lowestI;
				}

				/*GetEntityClassname(active, buffer, sizeof(buffer));
				
				GetEntityClassname(switchE, buffer, sizeof(buffer));
				
				if(nextE != -1)
				{
					GetEntityClassname(nextE, buffer, sizeof(buffer));
				}*/

				if(nextE != -1 && switchI != nextI)
				{
					SetEntPropEnt(client, Prop_Send, "m_hMyWeapons", nextE, switchI);
					SetEntPropEnt(client, Prop_Send, "m_hMyWeapons", switchE, nextI);
					
					//GetEntityClassname(nextE, buffer, sizeof(buffer));
					//FakeClientCommand(client, "use %s", buffer);
					SetPlayerActiveWeapon(client, nextE);
					//SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
					//SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + );
					
					//float time = GetGameTime() + 0.7;
					//if(GetEntPropFloat(client, Prop_Send, "m_flNextAttack") < time)
					//	SetEntPropFloat(client, Prop_Send, "m_flNextAttack", time);
				}
				break;
			}
			else if(weapon != -1)	// Another weapon is highest up in our slot
			{
				GetEntityClassname(weapon, buffer, sizeof(buffer));
				if(TF2_GetClassnameSlot(buffer) == slot)
				{
					SetPlayerActiveWeapon(client, weapon);
					break;
				}
			}
		}
	}

	//if(suit)
	//	SetEntProp(client, Prop_Send, "m_bWearingSuit", false);
}

int Store_GetSpecialOfSlot(int client, int slot)
{
	if(StoreItems)
	{
		Item item;
		int length = StoreItems.Length;
		for(int i; i<length; i++)
		{
			StoreItems.GetArray(i, item);
			if(item.Slot == slot && item.Owned[client])
				return item.Special;
		}
	}
	return -1;
}

void Store_ConfigSetup()
{
	delete StoreTags;
	StoreTags = new ArrayList(ByteCountToCells(32));

	if(StoreItems)
	{
		Item item;
		int length = StoreItems.Length;
		for(int i; i < length; i++)
		{
			StoreItems.GetArray(i, item);
			delete item.ItemInfos;
		}

		delete StoreItems;
	}
	
	delete StoreBalanceLog;
	StoreItems = new ArrayList(sizeof(Item));
	
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "weapons");
	KeyValues kv = new KeyValues("Weapons");
	kv.SetEscapeSequences(true);
	kv.ImportFromFile(buffer);
	RequestFrame(DeleteHandle, kv);
	
	char blacklist[6][32];
	zr_tagblacklist.GetString(buffer, sizeof(buffer));
	int blackcount;
	if(buffer[0])
		blackcount = ExplodeString(buffer, ";", blacklist, sizeof(blacklist), sizeof(blacklist[]));
	
	char whitelist[6][32];
	zr_tagwhitelist.GetString(buffer, sizeof(buffer));
	int whitecount;
	if(buffer[0])
		whitecount = ExplodeString(buffer, ";", whitelist, sizeof(whitelist), sizeof(whitelist[]));
	
	kv.GotoFirstSubKey();
	do
	{
		ConfigSetup(-1, kv, 0, false, whitelist, whitecount, blacklist, blackcount);
	} while(kv.GotoNextKey());

	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "weapons_usagelog");
	StoreBalanceLog = new KeyValues("UsageLog");
	StoreBalanceLog.ImportFromFile(buffer);
}

static void ConfigSetup(int section, KeyValues kv, int hiddenType, bool noKits, const char[][] whitelist, int whitecount, const char[][] blacklist, int blackcount)
{
	int cost = hiddenType == 2 ? 0 : kv.GetNum("cost", -1);
	bool isItem = cost >= 0;
	
	char buffer[128], buffers[6][32];

	Item item;
	item.Section = section;
	item.Level = kv.GetNum("level");
	item.Hidden = view_as<bool>(kv.GetNum("hidden", hiddenType ? 1 : 0));
	if(whitecount || blackcount)
	{
		kv.GetString("filter", buffer, sizeof(buffer));
		if(buffer[0] || isItem)
		{
			int filters = ExplodeString(buffer, ";", buffers, sizeof(buffers), sizeof(buffers[]));
			
			if(whitecount)
			{
				item.Hidden = true;
				
				for(int a; a < filters; a++)
				{
					for(int b; b < whitecount; b++)
					{
						if(StrEqual(buffers[a], whitelist[b], false))
						{
							item.Hidden = false;
							break;
						}
					}
					
					if(!item.Hidden)
						break;
				}
			}
			
			if(blackcount)
			{
				for(int a; a < filters; a++)
				{
					for(int b; b < whitecount; b++)
					{
						if(StrEqual(buffers[a], whitelist[b], false))
						{
							item.Hidden = true;
							break;
						}
					}
					
					if(item.Hidden)
						break;
				}
			}
		}
	}
	
	item.Starter = view_as<bool>(kv.GetNum("starter"));
	item.WhiteOut = view_as<bool>(kv.GetNum("whiteout"));
	item.IgnoreSlots = view_as<bool>(kv.GetNum("ignore_equip_region"));
	item.NoKit = view_as<bool>(kv.GetNum("nokit", noKits ? 1 : 0));
	kv.GetString("textstore", item.Name, sizeof(item.Name));
	item.GiftId = item.Name[0] ? Items_NameToId(item.Name) : -1;
	kv.GetSectionName(item.Name, sizeof(item.Name));
	CharToUpper(item.Name[0]);
	
	if(isItem)
	{
		item.Scale = kv.GetNum("scale");
		item.CostPerWave = kv.GetNum("extracost_per_wave");
		item.MaxBarricadesBuild = view_as<bool>(kv.GetNum("max_barricade_buy_logic"));
		item.MaxCost = kv.GetNum("maxcost");
		item.MaxScaled = kv.GetNum("max_times_scale");
		item.Special = kv.GetNum("special", -1);
		item.Slot = kv.GetNum("slot", -1);
		item.GregBlockSell = view_as<bool>(kv.GetNum("greg_block_sell"));
		item.GregOnlySell = kv.GetNum("greg_only_sell");
		item.NPCWeapon = kv.GetNum("npc_type", -1);
		item.NPCWeaponAlways = item.NPCWeapon > 9;
		item.ChildKit = hiddenType == 2;

		if(!item.ChildKit)
		{
			item.ParentKit = view_as<bool>(kv.GetNum("weaponkit"));
			
			kv.GetString("author", item.Author, sizeof(item.Author));
			kv.GetString("tags", item.Tags, sizeof(item.Tags));
			
			int tags = ExplodeString(item.Tags, ";", buffers, sizeof(buffers), sizeof(buffers[]));
			for(int i; i < tags; i++)
			{
				if(StoreTags.FindString(buffers[i]) == -1)
					StoreTags.PushString(buffers[i]);
			}
		}
		
		item.ItemInfos = new ArrayList(sizeof(ItemInfo));
		
		ItemInfo info;
		info.SetupKV(kv, item.Name);
		item.ItemInfos.PushArray(info);
			
		if(item.ParentKit)
		{
			if(kv.GotoFirstSubKey())
			{
				int sec = StoreItems.PushArray(item);
				
				do
				{
					ConfigSetup(sec, kv, 2, item.NoKit, whitelist, 0, blacklist, 0);
				}
				while(kv.GotoNextKey());
				kv.GoBack();
			}
		}
		else
		{
			for(int i=1; ; i++)
			{
				Format(info.Custom_Name, sizeof(info.Custom_Name), "pap_%d_", i);
				if(!info.SetupKV(kv, item.Name, info.Custom_Name))
					break;
				
				item.ItemInfos.PushArray(info);
			}

			StoreItems.PushArray(item);
		}
	}
	else if(kv.GotoFirstSubKey())
	{
		item.Slot = -1;
		int sec = StoreItems.PushArray(item);
		
		do
		{
			ConfigSetup(sec, kv, item.Hidden ? 1 : 0, item.NoKit, whitelist, whitecount, blacklist, blackcount);
		}
		while(kv.GotoNextKey());
		kv.GoBack();
	}
}

bool Store_CanPapItem(int client, int index)
{
	if(index > 0)
	{
		static Item item;
		StoreItems.GetArray(index, item);
		if(item.Owned[client])
		{
			ItemInfo info;
			if(!item.GetItemInfo(item.Owned[client] - 1, info))
				return false;
			
			if(!item.GetItemInfo(item.Owned[client] + info.PackSkip, info))
				return false;
			
			return view_as<bool>(info.Cost);
		}
	}
	return false;
}

void Store_PackMenu(int client, int index, int entity, int owner)
{
	if(!IsValidClient(owner))
		return;
		
	if(index > 0)
	{
		static Item item;
		StoreItems.GetArray(index, item);
		if(item.Owned[client])
		{
			ItemInfo info;
			if(item.GetItemInfo(item.Owned[client] - 1, info))
			{
				int count = info.PackBranches;
				if(count > 0)
				{
					Menu menu = new Menu(Store_PackMenuH);
					CancelClientMenu(client);
					SetStoreMenuLogic(client, false);

					SetGlobalTransTarget(client);
					int cash = CurrentCash-CashSpent[client];
					menu.SetTitle("%t\n \n%t\n \n%s\n ", "TF2: Zombie Riot", "Credits", cash, TranslateItemName(client, item.Name, info.Custom_Name));
					
					int skip = info.PackSkip;
					count += skip;

					char data[64], buffer[64];
					if(count > 1)
					{
						zr_tagwhitelist.GetString(buffer, sizeof(buffer));
						if(StrContains(buffer, "realtime") != -1)
							count = 1;
					}
					
					int userid = (client == owner || owner == -1) ? -1 : GetClientUserId(owner);
					
					for(int i = skip; i < count; i++)
					{
						if(item.GetItemInfo(item.Owned[client] + i, info) && info.Cost)
						{
							ItemCostPap(client, item, info, info.Cost);

							FormatEx(data, sizeof(data), "%d;%d;%d;%d", index, item.Owned[client] + i, entity, userid);
							FormatEx(buffer, sizeof(buffer), "%s [$%d]", TranslateItemName(client, item.Name, info.Custom_Name), info.Cost);
							menu.AddItem(data, buffer, cash < info.Cost ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

							if(info.Desc[0])
							{
								info.Desc = TranslateItemDescription(client, info.Desc, info.Rogue_Desc);
								StrCat(info.Desc, sizeof(info.Desc), "\n ");
								menu.AddItem("", info.Desc, ITEMDRAW_DISABLED);
							}
						}
					}
					
					if(!data[0])
					{
						FormatEx(buffer, sizeof(buffer), "%t", "Cannot Pap this");
						menu.AddItem("", buffer, ITEMDRAW_DISABLED);
					}
					
					menu.Pagination = 6;
					menu.ExitButton = true;
					menu.Display(client, MENU_TIME_FOREVER);
				}
			}
		}
	}
}

public int Store_PackMenuH(Menu menu, MenuAction action, int client, int choice)
{
	SetGlobalTransTarget(client);
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			ResetStoreMenuLogic(client);
		}
		case MenuAction_Select:
		{
			ResetStoreMenuLogic(client);
			char buffer[64];
			menu.GetItem(choice, buffer, sizeof(buffer));
			
			int values[4];
			ExplodeStringInt(buffer, ";", values, sizeof(values));
			
			static Item item;
			StoreItems.GetArray(values[0], item);
			if(item.Owned[client])
			{
				int owner = -1;
				
				ItemInfo info;
				if(item.GetItemInfo(values[1], info) && info.Cost)
				{
					ItemCostPap(client, item, info, info.Cost);
					if((CurrentCash-CashSpent[client]) >= info.Cost)
					{
						CashSpent[client] += info.Cost;
						CashSpentTotal[client] += info.Cost;
						item.Owned[client] = values[1] + 1;
						item.CurrentClipSaved[client] = -5;

						if(item.ChildKit)
						{
							// Increase sellback value of parent kit
							static Item other;
							StoreItems.GetArray(item.Section, other);

							if(other.Sell[client] < 0) //weapons with no cost start at -21312831293729139127389 so lets fix that
							{
								other.Sell[client] = 0;
							}

							other.Sell[client] += RoundToCeil(float(info.Cost) * SELL_AMOUNT);
							other.BuyWave[client] = -1;
							other.Owned[client] = values[1] + 1;

							StoreItems.SetArray(item.Section, other);

							// Packs all weapons part of the same kit
							ItemInfo info2;
							int length = StoreItems.Length;
							for(int i; i < length; i++)
							{
								StoreItems.GetArray(i, other);
								if(other.Section == item.Section && i != values[0])
								{
									if(other.GetItemInfo(values[1], info2) && info2.Cost) // If vaild, set new pack level
									{
										other.Owned[client] = values[1] + 1;
										StoreItems.SetArray(i, other);
									}
								}
							}
						}
						else
						{
							if(item.Sell[client] < 0) //weapons with no cost start at -21312831293729139127389 so lets fix that
							{
								item.Sell[client] = 0;
							}
							item.Sell[client] += RoundToCeil(float(info.Cost) * SELL_AMOUNT);
							item.BuyWave[client] = -1;
						}

						StoreItems.SetArray(values[0], item);
						
						TF2_StunPlayer(client, 0.0, 0.0, TF_STUNFLAG_SOUND, 0);
						
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client, SyncHud_Notifaction, "Your weapon was boosted");
						Store_ApplyAttribs(client);
						Store_GiveAll(client, GetClientHealth(client));
						owner = GetClientOfUserId(values[3]);
						if(IsValidClient(owner))
							Building_GiveRewardsUse(client, owner, 250, false, 5.0, true);
					}
				}
				
				Store_PackMenu(client, values[0], values[2], owner);
			}
		}
	}
	return 0;
}

/*int Store_PackCurrentItem(int client, int index)
{
	if(index > 0)
	{
		static Item item;
		StoreItems.GetArray(index, item);
		if(item.Owned[client])
		{
			ItemInfo info;
			if(!item.GetItemInfo(item.Owned[client], info))
				return 1;
			
			int money_for_pap = info.Cost;
			if(money_for_pap > 0)
			{		
				if(money_for_pap <= (CurrentCash-CashSpent[client]))
				{
					CashSpent[client] += money_for_pap;
					item.Owned[client]++;
					StoreItems.SetArray(index, item);
					return 3; //You just paped it.
				}
				else
				{
					return 2; //You dont got enough money to pap it.
				}
			}
			else
			{
				return 1; //You own it but this weapon cannot be pack a punched.
			}
		}
	}
	return 0; //you dont own the item.
}*/

void Store_RogueEndFightReset()
{
	static Item item;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		for(int c; c<MAXTF2PLAYERS; c++)
		{
			item.RogueBoughtRecently[c] = 0;
		}
		StoreItems.SetArray(i, item);
	}
	Ammo_Count_Ready += 5;
}

void Store_Reset()
{
	for(int c; c<MAXTF2PLAYERS; c++)
	{
		CashSpent[c] = 0;
		CashSpentTotal[c] = 0;
	}
	static Item item;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		for(int c; c<MAXTF2PLAYERS; c++)
		{
			item.Owned[c] = 0;
			item.Scaled[c] = 0;
			item.Equipped[c] = false;
			item.Cooldown1[c] = 0.0;
			item.Cooldown2[c] = 0.0;
			item.Cooldown3[c] = 0.0;
			item.BoughtBefore[c] = false;
			item.RogueBoughtRecently[c] = 0;
			item.CurrentClipSaved[c] = 0;
		}
		StoreItems.SetArray(i, item);
	}
	for(int c; c<MAXTF2PLAYERS; c++)
	{
		CashSpentGivePostSetup[c] = 0;
		CashSpentGivePostSetupWarning[c] = false;
	}
	if(StoreBalanceLog)
	{
		char buffer[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "weapons_usagelog");
		StoreBalanceLog.ExportToFile(buffer);
	}
}

/*bool Store_HasAnyItem(int client)
{
	static Item item;
	static ItemInfo info;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		if(item.Owned[client])
		{
			item.GetItemInfo(item.Owned[client] - 1, info);
			if(info.Cost)
				return true;
		}
	}
	
	return false;
}*/

int Store_HasNamedItem(int client, const char[] name)
{
	static Item item;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		if(StrEqual(name, item.Name, false))
			return item.Owned[client];
	}
	
	ThrowError("Unknown item name %s", name);
	return 0;
}

void Store_SetNamedItem(int client, const char[] name, int amount)
{
	static Item item;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		if(StrEqual(name, item.Name, false))
		{
			item.Owned[client] = amount;
			item.Sell[client] = 0;
			item.BuyWave[client] = -1;
			StoreItems.SetArray(i, item);
			return;
		}
	}
	
	ThrowError("Unknown item name %s", name);
}

void Store_SetClientItem(int client, int index, int owned, int scaled, int equipped, int sell)
{
	static Item item;
	StoreItems.GetArray(index, item);
	
	item.Owned[client] = owned;
	item.Scaled[client] = scaled;
	item.Equipped[client] = view_as<bool>(equipped);
	item.Sell[client] = sell;
	item.BuyWave[client] = -1;
	
	if(item.ParentKit)
	{
		static Item subItem;
		int length = StoreItems.Length;
		for(int i; i < length; i++)
		{
			StoreItems.GetArray(i, subItem);
			if(subItem.Section == index)
			{
				subItem.Owned[client] = item.Equipped[client] ? owned : 0;
				subItem.Equipped[client] = item.Equipped[client];
				StoreItems.SetArray(i, subItem);
			}
		}
	}
	
	StoreItems.SetArray(index, item);
}

static bool ItemBuyable(const Item item)
{
	if(item.Hidden)
		return false;
	
	if(item.Section > 0)
	{
		static Item item2;
		StoreItems.GetArray(item.Section, item2);
		if(item2.Hidden)
			return false;
		
		while(item2.Section > 0)
		{
			StoreItems.GetArray(item2.Section, item2);
			if(item2.Hidden)
				return false;
		}
	}
	

	return true;
}

void Store_BuyNamedItem(int client, const char name[64], bool free)
{
	static Item item;
	int items = StoreItems.Length;
	for(int a; a<items; a++)
	{
		StoreItems.GetArray(a, item);
		if(StrEqual(name, item.Name))
		{
			if(ItemBuyable(item))
			{
				static ItemInfo info;
				item.GetItemInfo(0, info);
				
				int base = info.Cost;
				ItemCost(client, item, info.Cost);

				if(info.Cost > 0 && free)
					return;
				
				if(info.Cost > 1000 && Rogue_UnlockStore() && !item.NPCSeller)
				{
					break;
				}
				else if(info.Cost > 1000 && !Rogue_UnlockStore() && info.Cost_Unlock > CurrentCash)
				{
					break;
				}
				if((base < 1001 || CurrentCash >= base) && (CurrentCash - CashSpent[client]) >= info.Cost)
				{
					bool MoneyTake = true;
					Store_BuyClientItem(client, a, item, info);
					
					if(MoneyTake)
					{
						CashSpent[client] += info.Cost;
						CashSpentTotal[client] += info.Cost;
						item.BuyPrice[client] = info.Cost;

						item.Sell[client] = ItemSell(base, info.Cost);
						if(item.GregOnlySell == 2)
						{
							item.BuyPrice[client] = 0;
							item.Sell[client] = 0;
						}
					}
					else
					{
						item.BuyPrice[client] = 0;
						item.Sell[client] = 0;
					}
					item.RogueBoughtRecently[client] += 1;
					item.BuyWave[client] = Rogue_GetRoundScale();
					if(info.NoRefundWanted)
					{
						item.BuyWave[client] = -1;
						item.Sell[client] = item.Sell[client] / 2;
					}
					if(!item.BoughtBefore[client])
					{
						item.BoughtBefore[client] = true;
						StoreBalanceLog.Rewind();
						StoreBalanceLog.SetNum(item.Name, StoreBalanceLog.GetNum(item.Name) + 1);
					}
					StoreItems.SetArray(a, item);
					return;
				}
			}
			break;
		}
	}
	
	SetGlobalTransTarget(client);
	PrintToChat(client, "%t", "Could Not Buy Item", TranslateItemName(client, name, ""));
}

void Store_EquipSlotSuffix(int client, int slot, char[] buffer, int blength)
{
	if(slot >= 0)
	{
		int count;
		int length = StoreItems.Length;
		static Item item;
		for(int i; i<length; i++)
		{
			StoreItems.GetArray(i, item);
			if(item.Equipped[client] && item.Slot == slot)
			{
				count++;
				if(count >= (slot < sizeof(SlotLimits) ? SlotLimits[slot] : 1))
				{
					static ItemInfo info;
					item.GetItemInfo(0, info);
					Format(buffer, blength, "%s {%s}", buffer, TranslateItemName(client, item.Name, info.Custom_Name));
					break;
				}
			}
		}
	}
}

void Store_EquipSlotCheck(int client, Item mainItem)
{
	if(mainItem.IgnoreSlots)
		return;
	
	int count;

	int slot = mainItem.Slot;

	static ItemInfo info;
	mainItem.GetItemInfo(0, info);
	bool isWeapon = (!mainItem.ChildKit && info.Classname[0] && TF2_GetClassnameSlot(info.Classname) <= TFWeaponSlot_Melee);
	
	int length = StoreItems.Length;
	static Item subItem;
	for(int i; i < length; i++)
	{
		StoreItems.GetArray(i, subItem);
		if(subItem.Equipped[client] && !subItem.IgnoreSlots && !subItem.ChildKit)
		{
			subItem.GetItemInfo(0, info);
			
			if(mainItem.ParentKit)
			{
				if(subItem.NoKit || (!subItem.ChildKit && info.Classname[0] && TF2_GetClassnameSlot(info.Classname) <= TFWeaponSlot_Melee))
				{
					PrintToChat(client, "%s was unequipped", TranslateItemName(client, subItem.Name, ""));
					Store_Unequip(client, i);
					continue;
				}
			}
			else if(mainItem.NoKit || isWeapon)
			{
				if(subItem.ParentKit)
				{
					PrintToChat(client, "%s was unequipped", TranslateItemName(client, subItem.Name, ""));
					Store_Unequip(client, i);
					continue;
				}
			}

			if(slot >= 0 && subItem.Slot == slot)
			{
				count++;
				if(count >= (slot < sizeof(SlotLimits) ? SlotLimits[slot] : 1))
				{
					PrintToChat(client, "%s was unequipped", TranslateItemName(client, subItem.Name, ""));
					Store_Unequip(client, i);
					continue;
				}
			}
		}
	}
}

bool Store_HasWeaponKit(int client)
{
	static Item item;
	int length = StoreItems.Length;
	for(int i; i < length; i++)
	{
		StoreItems.GetArray(i, item);
		if(item.ParentKit && item.Equipped[client])
			return true;
	}

	return false;
}

void Store_BuyClientItem(int client, int index, Item item, const ItemInfo info)
{
	Store_EquipSlotCheck(client, item);

	item.Scaled[client]++;
	item.Owned[client] = 1;
	item.Equipped[client] = true;
	item.Sell[client] = 0;
	item.BuyWave[client] = -1;

	if(item.ParentKit)
	{
		static Item subItem;
		int length = StoreItems.Length;
		for(int i; i < length; i++)
		{
			StoreItems.GetArray(i, subItem);
			if(subItem.Section == index)
			{
				subItem.Owned[client] = 1;
				subItem.Equipped[client] = true;
				StoreItems.SetArray(i, subItem);
			}
		}
	}
	
	if(info.FuncOnBuy != INVALID_FUNCTION)
	{
		Call_StartFunction(null, info.FuncOnBuy);
		Call_PushCell(client);
		Call_Finish();
	}
}

void Store_ClientDisconnect(int client)
{
	Store_WeaponSwitch(client, -1);
	
	Database_SaveGameData(client);

	CashSpent[client] = 0;
	CashSpentGivePostSetup[client] = 0;
	CashSpentGivePostSetupWarning[client] = false;
	CashSpentTotal[client] = 0;
	
	static Item item;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		if(item.Owned[client] || item.Scaled[client] || item.Equipped[client])
		{
			item.Owned[client] = 0;
			item.Scaled[client] = 0;
			item.Equipped[client] = false;
			StoreItems.SetArray(i, item);
		}
	}

	UsingChoosenTags[client] = false;
	delete ChoosenTags[client];
}

public void ReShowSettingsHud(int client)
{
	char buffer [128];
	SetGlobalTransTarget(client);
	Menu menu2 = new Menu(Settings_MenuPage);
	menu2.SetTitle("%t", "Settings Page");

	FormatEx(buffer, sizeof(buffer), "%t", "Armor Hud Setting");
	menu2.AddItem("-2", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Hurt Hud Setting");
	menu2.AddItem("-8", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Weapon Hud Setting");
	menu2.AddItem("-14", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Notif Hud Setting");
	menu2.AddItem("-20", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Zombie Volume Setting Show");
	menu2.AddItem("-55", buffer);


	FormatEx(buffer, sizeof(buffer), "%t", "Low Health Shake");

	if(b_HudLowHealthShake[client])
	{
		FormatEx(buffer, sizeof(buffer), "%s %s", buffer, "[X]");
	}
	else
	{
		FormatEx(buffer, sizeof(buffer), "%s %s", buffer, "[ ]");
	}
	menu2.AddItem("-40", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Weapon Screen Shake");
	if(b_HudScreenShake[client])
	{
		FormatEx(buffer, sizeof(buffer), "%s %s", buffer, "[X]");
	}
	else
	{
		FormatEx(buffer, sizeof(buffer), "%s %s", buffer, "[ ]");
	}
	menu2.AddItem("-41", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Hit Marker");
	if(b_HudHitMarker[client])
	{
		FormatEx(buffer, sizeof(buffer), "%s %s", buffer, "[X]");
	}
	else
	{
		FormatEx(buffer, sizeof(buffer), "%s %s", buffer, "[ ]");
	}
	menu2.AddItem("-42", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Taunt Speed Increace");
	if(b_TauntSpeedIncreace[client])
	{
		FormatEx(buffer, sizeof(buffer), "%s %s", buffer, "[X]");
	}
	else
	{
		FormatEx(buffer, sizeof(buffer), "%s %s", buffer, "[ ]");
	}
	menu2.AddItem("-71", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Zombie In Battle Logic Setting", f_Data_InBattleHudDisableDelay[client] + 2.0);
	menu2.AddItem("-72", buffer);


	
	FormatEx(buffer, sizeof(buffer), "%t", "Back");
	menu2.AddItem("-999", buffer);
	menu2.Pagination = 1;
	
	menu2.Display(client, MENU_TIME_FOREVER);
}


public void ReShowArmorHud(int client)
{
	char buffer[24];
	SetGlobalTransTarget(client);

	Menu menu2 = new Menu(Settings_MenuPage);
	menu2.SetTitle("%t", "Armor Hud Setting Inside",f_ArmorHudOffsetX[client],f_ArmorHudOffsetY[client]);

	FormatEx(buffer, sizeof(buffer), "%t", "Move Hud Up");
	menu2.AddItem("-3", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Move Hud Down");
	menu2.AddItem("-4", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Move Hud Left");
	menu2.AddItem("-5", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Move Hud Right");
	menu2.AddItem("-6", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Reset to Default");
	menu2.AddItem("-7", buffer);
					
	FormatEx(buffer, sizeof(buffer), "%t", "Back");
	menu2.AddItem("-1", buffer);

	menu2.Display(client, MENU_TIME_FOREVER);
}

public void ReShowHurtHud(int client)
{
	char buffer[24];
	SetGlobalTransTarget(client);

	Menu menu2 = new Menu(Settings_MenuPage);
	menu2.SetTitle("%t", "Hurt Hud Setting Inside",f_HurtHudOffsetX[client],f_HurtHudOffsetY[client]);

	FormatEx(buffer, sizeof(buffer), "%t", "Move Hud Up");
	menu2.AddItem("-9", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Move Hud Down");
	menu2.AddItem("-10", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Move Hud Left");
	menu2.AddItem("-11", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Move Hud Right");
	menu2.AddItem("-12", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Reset to Default");
	menu2.AddItem("-13", buffer);
					
	FormatEx(buffer, sizeof(buffer), "%t", "Back");
	menu2.AddItem("-1", buffer);

	menu2.Display(client, MENU_TIME_FOREVER);
	
	Calculate_And_Display_hp(client, client, 0.0, true); //Apply hud update so they know where it is now
}

public void ReShowWeaponHud(int client)
{
	char buffer[24];
	SetGlobalTransTarget(client);

	Menu menu2 = new Menu(Settings_MenuPage);
	menu2.SetTitle("%t", "Weapon Hud Setting Inside",f_WeaponHudOffsetX[client],f_WeaponHudOffsetY[client]);

	FormatEx(buffer, sizeof(buffer), "%t", "Move Hud Up");
	menu2.AddItem("-15", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Move Hud Down");
	menu2.AddItem("-16", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Move Hud Left");
	menu2.AddItem("-17", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Move Hud Right");
	menu2.AddItem("-18", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Reset to Default");
	menu2.AddItem("-19", buffer);
					
	FormatEx(buffer, sizeof(buffer), "%t", "Back");
	menu2.AddItem("-1", buffer);

	menu2.Display(client, MENU_TIME_FOREVER);
}

public void ReShowNotifHud(int client)
{
	char buffer[24];
	SetGlobalTransTarget(client);

	Menu menu2 = new Menu(Settings_MenuPage);
	menu2.SetTitle("%t", "Notif Hud Setting Inside",f_NotifHudOffsetX[client],f_NotifHudOffsetY[client]);

	FormatEx(buffer, sizeof(buffer), "%t", "Move Hud Up");
	menu2.AddItem("-21", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Move Hud Down");
	menu2.AddItem("-22", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Move Hud Left");
	menu2.AddItem("-23", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Move Hud Right");
	menu2.AddItem("-24", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Reset to Default");
	menu2.AddItem("-25", buffer);
					
	FormatEx(buffer, sizeof(buffer), "%t", "Back");
	menu2.AddItem("-1", buffer);

	SetDefaultHudPosition(client);
	SetGlobalTransTarget(client);
	ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "nothing");

	menu2.Display(client, MENU_TIME_FOREVER);
}


public void ReShowVolumeHud(int client)
{
	char buffer[24];
	SetGlobalTransTarget(client);

	Menu menu2 = new Menu(Settings_MenuPage);
	int volumeSettingShow = RoundToNearest(((f_ZombieVolumeSetting[client] + 1.0) * 100.0));
	
	menu2.SetTitle("%t", "Zombie Volume Setting",volumeSettingShow);

	FormatEx(buffer, sizeof(buffer), "%t", "Turn up volume");
	menu2.AddItem("-63", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Turn down volume");
	menu2.AddItem("-64", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Back");
	menu2.AddItem("-1", buffer);

	menu2.Display(client, MENU_TIME_FOREVER);
}

public int Settings_MenuPage(Menu menu, MenuAction action, int client, int choice)
{
	SetGlobalTransTarget(client);

	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
			{
				static Item item;
				menu.GetItem(0, item.Name, sizeof(item.Name));
				int index = StringToInt(item.Name);
				if(index < 0)
				{
					item.Section = -1;
				}
				else
				{
					StoreItems.GetArray(index, item);
					if(item.Section != -1)
						StoreItems.GetArray(item.Section, item);
				}

				LastMenuPage[client] = 0;
				MenuPage(client, item.Section);
			}
			/*
			else if(choice != MenuCancel_Disconnected)
			{
				StopSound(client, SNDCHAN_STATIC, "#items/tf_music_upgrade_machine.wav");
			}
			*/
		}
		case MenuAction_Select:
		{
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			switch(id)
			{
				case -2:
				{
					ReShowArmorHud(client);
				}
				case -3: //Move Armor Hud Up
				{
					f_ArmorHudOffsetX[client] -= 0.005;
					ReShowArmorHud(client);
				}
				case -4: //Move Armor Hud Down
				{
					f_ArmorHudOffsetX[client] += 0.005;
					ReShowArmorHud(client);
				}
				case -5: //Move Armor Hud Left
				{
					f_ArmorHudOffsetY[client] -= 0.005;
					ReShowArmorHud(client);
				}
				case -6: //Move Armor Hud right
				{
					f_ArmorHudOffsetY[client] += 0.005;
					ReShowArmorHud(client);
				}
				case -7: //ResetARmorHud To default
				{
					f_ArmorHudOffsetX[client] = -0.085;
					f_ArmorHudOffsetY[client] = 0.0;
					
					ReShowArmorHud(client);
				}
				
				//HURT HUD STUFF!
				case -8:
				{
					ReShowHurtHud(client);
				}
				case -9: //Move Armor Hud Up
				{
					f_HurtHudOffsetX[client] -= 0.005;
					ReShowHurtHud(client);
				}
				case -10: //Move Armor Hud Down
				{
					f_HurtHudOffsetX[client] += 0.005;
					ReShowHurtHud(client);
				}
				case -11: //Move Armor Hud Left
				{
					f_HurtHudOffsetY[client] -= 0.005;
					ReShowHurtHud(client);
				}
				case -12: //Move Armor Hud right
				{
					f_HurtHudOffsetY[client] += 0.005;
					ReShowHurtHud(client);
				}
				case -13: //ResetARmorHud To default
				{
					f_HurtHudOffsetX[client] = 0.0;
					f_HurtHudOffsetY[client] = 0.0;
					
					ReShowHurtHud(client);
				}

				//Weapon HUD STUFF!
				case -14:
				{
					ReShowWeaponHud(client);
				}
				case -15: //Move Armor Hud Up
				{
					f_WeaponHudOffsetX[client] -= 0.005;
					ReShowWeaponHud(client);
				}
				case -16: //Move Armor Hud Down
				{
					f_WeaponHudOffsetX[client] += 0.005;
					ReShowWeaponHud(client);
				}
				case -17: //Move Armor Hud Left
				{
					f_WeaponHudOffsetY[client] -= 0.005;
					ReShowWeaponHud(client);
				}
				case -18: //Move Armor Hud right
				{
					f_WeaponHudOffsetY[client] += 0.005;
					ReShowWeaponHud(client);
				}
				case -19: //ResetARmorHud To default
				{
					f_WeaponHudOffsetX[client] = 0.0;
					f_WeaponHudOffsetY[client] = 0.0;
					
					ReShowWeaponHud(client);
				}

				case -20:
				{
					ReShowNotifHud(client);
				}
				case -21: //Move Armor Hud Up
				{
					f_NotifHudOffsetX[client] -= 0.005;
					ReShowNotifHud(client);
				}
				case -22: //Move Armor Hud Down
				{
					f_NotifHudOffsetX[client] += 0.005;
					ReShowNotifHud(client);
				}
				case -23: //Move Armor Hud Left
				{
					f_NotifHudOffsetY[client] -= 0.005;
					ReShowNotifHud(client);
				}
				case -24: //Move Armor Hud right
				{
					f_NotifHudOffsetY[client] += 0.005;
					ReShowNotifHud(client);
				}
				case -25: 
				{
					f_NotifHudOffsetX[client] = 0.0;
					f_NotifHudOffsetY[client] = 0.0;
					
					ReShowNotifHud(client);
				}
				case -40: 
				{
					if(b_HudLowHealthShake[client])
					{
						b_HudLowHealthShake[client] = false;
					}
					else
					{
						b_HudLowHealthShake[client] = true;
					}
					
					ReShowSettingsHud(client);
				}
				case -41: 
				{
					if(b_HudScreenShake[client])
					{
						b_HudScreenShake[client] = false;
					}
					else
					{
						b_HudScreenShake[client] = true;
					}
					ReShowSettingsHud(client);
				}
				case -42: 
				{
					if(b_HudHitMarker[client])
					{
						b_HudHitMarker[client] = false;
					}
					else
					{
						b_HudHitMarker[client] = true;
					}
					ReShowSettingsHud(client);
				}
				case -64: //Lower Volume
				{
					f_ZombieVolumeSetting[client] -= 0.05;
					if(f_ZombieVolumeSetting[client] < -1.0)
					{
						f_ZombieVolumeSetting[client] = -1.0;
					}
					ReShowVolumeHud(client);
				}
				case -63: //Up volume
				{
					f_ZombieVolumeSetting[client] += 0.05;
					if(f_ZombieVolumeSetting[client] > 0.0)
					{
						f_ZombieVolumeSetting[client] = 0.0;
					}
					ReShowVolumeHud(client);
				}
				case -71: 
				{
					if(b_TauntSpeedIncreace[client])
					{
						b_TauntSpeedIncreace[client] = false;
					}
					else
					{
						b_TauntSpeedIncreace[client] = true;
					}
					ReShowSettingsHud(client);
				}
				case -72: 
				{
					
					f_Data_InBattleHudDisableDelay[client] += 1.0;

					if(f_Data_InBattleHudDisableDelay[client] > 3.0)
					{
						f_Data_InBattleHudDisableDelay[client] = -2.0;
					}
					ReShowSettingsHud(client);
				}
				case -55: //Show Volume Hud
				{
					ReShowVolumeHud(client);
				}

				case -1: //Move Armor Hud right
				{
					ReShowSettingsHud(client);
				}
				default:
				{
					LastMenuPage[client] = 0;
					MenuPage(client, -1);
				}
			}
		}

	}
	return 0;
}

bool Store_GetNextItem(int client, int &i, int &owned, int &scale, int &equipped, int &sell, char[] buffer="", int size=0, int &hidden = 0)
{
	static Item item;
	int length = StoreItems.Length;
	for(; i < length; i++)
	{
		StoreItems.GetArray(i, item);
		if(!item.ChildKit && (item.Owned[client] || item.Scaled[client] || item.Equipped[client]))
		{
			owned = item.Owned[client];
			scale = item.Scaled[client];
			equipped = item.Equipped[client];
			sell = item.Sell[client];
			hidden = item.Hidden;
			
			if(size)
			{
				strcopy(buffer, size, item.Name);
			}
			
			return true;
		}
	}
	return false;
}

void Store_RandomizeNPCStore(int ResetStore, int addItem = 0, bool subtract_wave = false)
{
	int amount;
	int length = StoreItems.Length;
	int[] indexes = new int[length];
	bool unlock = Rogue_UnlockStore();
	
	static Item item;
	static ItemInfo info;
	for(int i; i < length; i++)
	{
		StoreItems.GetArray(i, item);
		if(item.GregOnlySell || (item.ItemInfos && item.GiftId == -1 && !item.NPCWeaponAlways && !item.GregBlockSell))
		{
			if(item.GregOnlySell == 2)	// We always sell this if unbought
			{
				item.NPCSeller_First = true;
				item.NPCSeller = true;

				for(int c = 1; c <= MaxClients; c++)
				{
					if(item.Owned[c] || item.BoughtBefore[c])
					{
						item.NPCSeller_First = false;
						item.NPCSeller = false;
						break;
					}
				}
				
				StoreItems.SetArray(i, item);
			}
			else if(unlock && !ResetStore)	// Don't reset items, add random ones (rogue)
			{
				if(addItem == 0 && !subtract_wave && item.NPCSeller_First)
				{
					item.NPCSeller = false;
					item.NPCSeller_First = false;
				}
				else if(item.NPCSeller_WaveStart > 0 && subtract_wave)
				{
					item.NPCSeller_WaveStart--;
					StoreItems.SetArray(i, item);
				}

				if(!item.NPCSeller)
				{
					item.GetItemInfo(0, info);
					if(info.Cost > 999 && info.Cost_Unlock > (CurrentCash / 4))
						indexes[amount++] = i;
				}
			}
			else if(ResetStore != 2)	// Reset items, add random ones (normal)
			{
				if(addItem == 0 && !subtract_wave)
				{
					item.NPCSeller_First = false;
					item.NPCSeller = false;
					if(ResetStore)
					{
						item.NPCSeller_WaveStart = 0;
					}
				}

				if(item.NPCSeller_WaveStart > 0 && subtract_wave)
				{
					item.NPCSeller_WaveStart -= 1;
				}
				
				item.GetItemInfo(0, info);
				if(info.Cost > 0 && info.Cost_Unlock > (CurrentCash / 3 - 1000) && info.Cost_Unlock < CurrentCash)
					indexes[amount++] = i;
				
				StoreItems.SetArray(i, item);
			}
		}
	}
	if(subtract_wave || ResetStore)
		return;
	
	if(IsValidEntity(EntRefToEntIndex(SalesmanAlive)))
	{
		if(addItem == 0)
			CPrintToChatAll("{green}Father Grigori{default}: My child, I'm offering new wares!");
		else
			CPrintToChatAll("{green}Father Grigori{default}: My child, I'm offering extra for a limited time!");

		bool OneSuperSale = true;
		SortIntegers(indexes, amount, Sort_Random);
		int SellsMax = GrigoriMaxSells;
		if(addItem != 0)
			SellsMax = addItem;
		
		for(int i; i<SellsMax && i<amount; i++) //amount of items to sell
		{
			StoreItems.GetArray(indexes[i], item);
			if(item.NPCSeller_First)
			{
				SellsMax++;
				continue;
			}

			if(item.NPCSeller)
			{
				SellsMax++;
				continue;
			}
			if(addItem != 0 && item.NPCSeller_WaveStart <= 0)
			{
				item.NPCSeller_WaveStart = 3;
				CPrintToChatAll("{green}%s [%s]",item.Name, unlock ? "$" : "$$");
			}
			else if(OneSuperSale)
			{
				CPrintToChatAll("{green}%s [%s]",item.Name, unlock ? "$" : "$$");
				item.NPCSeller_First = true;
				OneSuperSale = false;
			}
			else if(item.NPCSeller_WaveStart <= 0)
			{
				CPrintToChatAll("{palegreen}%s%s",item.Name, unlock ? "" : " [$]");
			}
			item.NPCSeller = true;
			StoreItems.SetArray(indexes[i], item);
		}
	}
	else if(unlock)
	{
		CPrintToChatAll("{green}Recovered Items:");

		SortIntegers(indexes, amount, Sort_Random);
		int SellsMax = GrigoriMaxSells;
		if(addItem != 0)
			SellsMax = addItem;
		
		for(int i; i<SellsMax && i<amount; i++) //amount of items to sell
		{
			StoreItems.GetArray(indexes[i], item);

			CPrintToChatAll("{palegreen}%s",item.Name);

			item.NPCSeller = true;
			StoreItems.SetArray(indexes[i], item);
		}
	}
}

/*void Store_RoundStart()
{
	static Item item;
	static ItemInfo info;
	ArrayList[] lists = new ArrayList[HighestTier+1];
	char buffer[PLATFORM_MAX_PATH], buffers[4][12];
	int entity = MaxClients+1;
	while((entity=FindEntityByClassname(entity, "prop_dynamic")) != -1)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
		if(!StrContains(buffer, "zr_weapon_", false))
		{
			int tier = ExplodeString(buffer, "_", buffers, sizeof(buffers), sizeof(buffers[])) - 1;
			tier = StringToInt(buffers[tier]);
			if(tier >= 0 && tier <= HighestTier)
			{
				int length;
				if(!lists[tier])
				{
					lists[tier] = GetAllWeaponsWithTier(tier);
					if(!(length = lists[tier].Length))
					{
						delete lists[tier];
						lists[tier] = null;
						RemoveEntity(entity);
						continue;
					}
				}
				else if(!(length = lists[tier].Length))
				{
					delete lists[tier];
					lists[tier] = GetAllWeaponsWithTier(tier);
				}
				
				length = GetRandomInt(0, length-1);
				int ids[2];
				lists[tier].GetArray(length, ids);
				StoreItems.GetArray(ids[0], item);
				item.GetItemInfo(ids[1], info);
				lists[tier].Erase(length);
				
				if(info.Model[0])
					SetEntityModel(entity, info.Model);
				
				SetEntProp(entity, Prop_Send, "m_nSkin", ids[0]);
				SetEntProp(entity, Prop_Send, "m_nBody", ids[1]);
				
				if(tier >= sizeof(RenderColors))
					tier = sizeof(RenderColors)-1;
				
				SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
				SetEntityRenderColor(entity, RenderColors[tier][0], RenderColors[tier][1], RenderColors[tier][2], RenderColors[tier][3]);
			}
			else
			{
				RemoveEntity(entity);
				continue;
			}
			
			SetEntityCollisionGroup(entity, 1);
		//	SetEntProp(entity, Prop_Send, "m_CollisionGroup", 2);
			AcceptEntityInput(entity, "DisableShadow");
			AcceptEntityInput(entity, "EnableCollision");
			//Relocate weapon to higher height, looks much better
			float pos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
			pos[2] += 0.8;
			TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
		}
	}
	
	for(int i; i<=HighestTier; i++)
	{
		if(lists[i])
		{
			delete lists[i];
			lists[i] = null;
		}
	}
}

public bool Do_Not_Collide(int client, int collisiongroup, int contentsmask, bool originalResult)
{
	if(collisiongroup == 9) //Only npc's
		return false;
	else
		return originalResult;
} 

static ArrayList GetAllWeaponsWithTier(int tier)
{
	ArrayList list = new ArrayList(2);
	
	static Item item;
	static ItemInfo info;
	int length = StoreItems.Length;
	int array[2];
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		for(int a; item.GetItemInfo(a, info); a++)
		{
			if(info.Tier == tier)
			{
				array[0] = i;
				array[1] = a;
				for(int b; b<info.Rarity; b++)
				{
					list.PushArray(array);
				}
			}
		}
	}
	
	return list;
}*/

public Action Access_StoreViaCommand(int client, int args)
{
	if (!IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if(!IsVoteInProgress() && !Waves_CallVote(client))
	{
		if(ClientTutorialStep(client) == 1)
		{
			SetClientTutorialStep(client, 2);
			DoTutorialStep(client, false);	
		}
		SetGlobalTransTarget(client);
		PrintToChat(client,"%t", "Opened store via command");
		NPCOnly[client] = 0;
		LastMenuPage[client] = 0;
		MenuPage(client, -1);
	}
	return Plugin_Continue;
}

void Store_Menu(int client)
{
	Store_OnCached(client);
	if(LastStoreMenu[client])
	{
		CancelClientMenu(client);
		ClientCommand(client, "slot10");
		ResetStoreMenuLogic(client);
	}
	else if(StoreItems && !IsVoteInProgress() && !Waves_CallVote(client))
	{
		NPCOnly[client] = 0;
		
		if(ClientTutorialStep(client) == 1)
		{
			SetClientTutorialStep(client, 2);
			DoTutorialStep(client, false);	
		}
		
		LastMenuPage[client] = 0;
		MenuPage(client, -1);
	}
}

void Store_OpenNPCStore(int client)
{
	if(StoreItems && !IsVoteInProgress() && !Waves_CallVote(client))
	{
		NPCOnly[client] = 1;
		LastMenuPage[client] = 0;
		MenuPage(client, -1);
	}
}

void Store_OpenGiftStore(int client, int entity, int price, bool barney)
{
	if(StoreItems && !IsVoteInProgress() && !Waves_CallVote(client))
	{
		NPCOnly[client] = barney ? 3 : 2;
		NPCTarget[client] = EntIndexToEntRef(entity);
		NPCCash[client] = price;
		LastMenuPage[client] = 0;
		MenuPage(client, -1);
	}
}

static void MenuPage(int client, int section)
{
	if(dieingstate[client] > 0) //They shall not enter the store if they are downed.
		return;
	
	SetGlobalTransTarget(client);
	
	Menu menu;
	
	bool starterPlayer = (Level[client] < STARTER_WEAPON_LEVEL && Database_IsCached(client));

	if(CvarInfiniteCash.BoolValue)
	{
		CurrentCash = 999999;
		Ammo_Count_Used[client] = -999999;
		CashSpent[client] = 0;
		starterPlayer = false;
	}
	
	if(CurrentMenuItem[client] != section)
	{
		CurrentMenuItem[client] = section;
		CurrentMenuPage[client] = LastMenuPage[client];
		LastMenuPage[client] = 0;
	}

//	BarracksCheckItems(client);
	
	if(ClientTutorialStep(client) == 2)
	{
		//This is here so the player doesnt just have no money to buy anything.
		int cash = CurrentCash-CashSpent[client];
		if(cash < 1000)
		{
			int give_Extra_JustIncase;
			
			
			give_Extra_JustIncase = cash - 1000;
			
			CashSpent[client] += give_Extra_JustIncase;
		}
		
	}
	
	static Item item;
	static ItemInfo info;
	if(section > -1)
	{
		StoreItems.GetArray(section, item);
		
		if(item.ItemInfos)
		{
			menu = new Menu(Store_MenuItem);
			int cash = CurrentCash-CashSpent[client];
			char buffer[512];
			
			int level = item.Owned[client] - 1;
			if(item.ParentKit || level < 0 || NPCOnly[client] == 2 || NPCOnly[client] == 3)
				level = 0;
			
			item.GetItemInfo(level, info);
			
			level = item.Owned[client];
			if(level < 1 || NPCOnly[client] == 2 || NPCOnly[client] == 3)
				level = 1;
			
			SetGlobalTransTarget(client);
			ItemInfo info2;
			if(item.GetItemInfo(level, info2))
			{
				if(NPCOnly[client] == 1)
				{
					FormatEx(buffer, sizeof(buffer), "%t\n%t\n%t\n \n%t\n \n%s \n<%t> [%i] ", "TF2: Zombie Riot", "Father Grigori's Store","All Items are 20%% off here!", "Credits", cash, TranslateItemName(client, item.Name, info.Custom_Name),"Can Be Pack-A-Punched", info2.Cost);
				}
				else if(CurrentRound < 2 || Rogue_NoDiscount() || !Waves_InSetup())
				{
					FormatEx(buffer, sizeof(buffer), "%t\n \n \n%t\n \n%s \n<%t> [%i] ", "TF2: Zombie Riot", "Credits", cash, TranslateItemName(client, item.Name, info.Custom_Name),"Can Be Pack-A-Punched", info2.Cost);
				}
				else
				{
					FormatEx(buffer, sizeof(buffer), "%t\n \n%t\n%t\n%s  \n<%t> [%i] ", "TF2: Zombie Riot", "Credits", cash, "Store Discount", TranslateItemName(client, item.Name, info.Custom_Name),"Can Be Pack-A-Punched", info2.Cost);
				}
			}
			else
			{
				if(NPCOnly[client] == 1)
				{
					FormatEx(buffer, sizeof(buffer), "%t\n%t\n%t\n \n%t\n \n%s ", "TF2: Zombie Riot", "Father Grigori's Store","All Items are 20%% off here!", "Credits", cash, TranslateItemName(client, item.Name, info.Custom_Name));
				}
				else if(CurrentRound < 2 || Rogue_NoDiscount() || !Waves_InSetup())
				{
					FormatEx(buffer, sizeof(buffer), "%t\n \n%t\n \n%s ", "TF2: Zombie Riot", "Credits", cash, TranslateItemName(client, item.Name, info.Custom_Name));
				}
				else
				{
					FormatEx(buffer, sizeof(buffer), "%t\n \n%t\n%t\n%s ", "TF2: Zombie Riot", "Credits", cash, "Store Discount", TranslateItemName(client, item.Name, info.Custom_Name));
				}				
			}
			

			//		, TranslateItemName(client, item.Name) , item.PackCost > 0 ? "<Packable>" : ""
			Config_CreateDescription(ItemArchetype[info.WeaponArchetype], info.Classname, info.Attrib, info.Value, info.Attribs, buffer, sizeof(buffer));
			menu.SetTitle("%s\n%s\n ", buffer, TranslateItemDescription(client, info.Desc, info.Rogue_Desc));
			
			if(NPCOnly[client] == 2 || NPCOnly[client] == 3)
			{
				char buffer2[16];
				IntToString(section, buffer2, sizeof(buffer2));
				
				ItemCost(client, item, info.Cost);
				if(!item.NPCWeaponAlways)
					info.Cost -= NPCCash[client];
				
				FormatEx(buffer, sizeof(buffer), "%t ($%d)", "Buy", info.Cost);
				menu.AddItem(buffer2, buffer, info.Cost > cash ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			}
			else
			{
				int style = ITEMDRAW_DEFAULT;
				if(info.ScrapCost > 0) //Make scrap cost preffered, dont bother with anything else.
				{
					if((info.ScrapCost > (Scrap[client])) && !CvarInfiniteCash.BoolValue)
					{
						style = ITEMDRAW_DISABLED;
					}
					FormatEx(buffer, sizeof(buffer), "%t ($%d) [%d]", "Buy Scrap", info.ScrapCost , Scrap[client]);

					char buffer2[16];
					IntToString(section, buffer2, sizeof(buffer2));
					menu.AddItem(buffer2, buffer, style);

					//SCRAP LOGIC ABOVE!
					//BELOW IS NORMAL STORE STUFF!
				}
				else
				{
					int Repeat_Filler = 0;
					if(item.Equipped[client])
					{
						if(info.AmmoBuyMenuOnly && info.AmmoBuyMenuOnly < Ammo_MAX)	// Weapon with A2735mmo, buyable only
						{	
							int cost = AmmoData[info.AmmoBuyMenuOnly][0];
							FormatEx(buffer, sizeof(buffer), "%t [%d] ($%d)", AmmoNames[info.AmmoBuyMenuOnly], AmmoData[info.AmmoBuyMenuOnly][1], cost);
							if(cost > cash)
								style = ITEMDRAW_DISABLED;
						}
						else if(info.Ammo && info.Ammo < Ammo_MAX)	// Weapon with Ammo
						{	
							int cost = AmmoData[info.Ammo][0];
							FormatEx(buffer, sizeof(buffer), "%t [%d] ($%d)", AmmoNames[info.Ammo], AmmoData[info.Ammo][1], cost);
							if(cost > cash)
								style = ITEMDRAW_DISABLED;
						}
						else	// No Ammo
						{
							FormatEx(buffer, sizeof(buffer), "%s", "-");
							style = ITEMDRAW_DISABLED;
						}
					}
					else if(item.ChildKit || item.Owned[client] || (info.Cost <= 0 && (item.Scale*item.Scaled[client]) <= 0))	// Owned already or free
					{
						FormatEx(buffer, sizeof(buffer), "%t", "Equip");
						if(info.VisualDescOnly)
						{
							style = ITEMDRAW_DISABLED;
						}
					}
					else	// Buy it
					{
						ItemCost(client, item, info.Cost);
						
/*						bool Maxed_Building = false;
						if(item.MaxBarricadesBuild)
						{
							if(BarricadeMaxSupply(client) >= MaxBarricadesAllowed(client))
							{
								Maxed_Building = true;
								style = ITEMDRAW_DISABLED;
							}
						}

						if(Maxed_Building)
						{
							FormatEx(buffer, sizeof(buffer), "%t ($%d) [%t] [%i/%i]", "Buy", info.Cost,"MAX BARRICADES OUT CURRENTLY", i_BarricadesBuild[client], MaxBarricadesAllowed(client));
						}
						else*/
						{
							FormatEx(buffer, sizeof(buffer), "%t ($%d)", "Buy", info.Cost);
						}

						if(info.Cost > cash)
							style = ITEMDRAW_DISABLED;
					}
					
					char buffer2[16];
					IntToString(section, buffer2, sizeof(buffer2));
					menu.AddItem(buffer2, buffer, style);	// 0
					Repeat_Filler ++;
					
					bool fullSell = (item.BuyWave[client] == Waves_GetRound());
					bool canSell = (!item.ChildKit && item.Owned[client] && ((info.Cost && fullSell) || item.Sell[client] > 0));
					if(item.GregOnlySell == 2)
					{
						canSell = false;
					}
					if(item.Equipped[client] && (info.AmmoBuyMenuOnly && info.AmmoBuyMenuOnly < Ammo_MAX) || (info.Ammo && info.Ammo < Ammo_MAX))	// Weapon with Ammo
					{
						if(info.AmmoBuyMenuOnly && info.AmmoBuyMenuOnly < Ammo_MAX)	// Weapon with A2735mmo, buyable only
						{
							int cost = AmmoData[info.AmmoBuyMenuOnly][0] * 10;
							FormatEx(buffer, sizeof(buffer), "%t x10 [%d] ($%d)", AmmoNames[info.AmmoBuyMenuOnly], AmmoData[info.AmmoBuyMenuOnly][1] * 10, cost);
							if(cost > cash)
								style = ITEMDRAW_DISABLED;
							Repeat_Filler ++;
							menu.AddItem(buffer2, buffer, style);	// 1
						}
						else
						{
							int cost = AmmoData[info.Ammo][0] * 10;
							FormatEx(buffer, sizeof(buffer), "%t x10 [%d] ($%d)", AmmoNames[info.Ammo], AmmoData[info.Ammo][1] * 10, cost);
							if(cost > cash)
								style = ITEMDRAW_DISABLED;
							Repeat_Filler ++;
							menu.AddItem(buffer2, buffer, style);	// 1
						}
					}
					else if(item.Equipped[client] || canSell)
					{
						Repeat_Filler ++;
						menu.AddItem(buffer2, "-", ITEMDRAW_DISABLED);	// 1
					}

					//We shall allow unequipping again.
					if(item.Equipped[client] && item.GregOnlySell != 2)
					{
						FormatEx(buffer, sizeof(buffer), "%t", "Unequip");
						menu.AddItem(buffer2, buffer, item.ChildKit ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);	// 2
						Repeat_Filler ++;
					}
					else if(canSell)
					{
						Repeat_Filler ++;
						menu.AddItem(buffer2, "-", ITEMDRAW_DISABLED);	// 2
					}

					if(canSell)
					{
						Repeat_Filler ++;
						FormatEx(buffer, sizeof(buffer), "%t ($%d) | (%t: $%d)", "Sell", fullSell ? item.BuyPrice[client] : item.Sell[client], "Credits After Selling", (fullSell ? item.BuyPrice[client] : item.Sell[client]) + (CurrentCash-CashSpent[client]));	// 3
						menu.AddItem(buffer2, buffer);
					}
					else
					{
						Repeat_Filler ++;
						menu.AddItem(buffer2, "-", ITEMDRAW_DISABLED);	// 2
					}

					bool tinker = Blacksmith_HasTinker(client, section);
					if(tinker || item.Tags[0] || info.ExtraDesc[0] || item.Author[0])
					{
						for(int Repeatuntill; Repeatuntill < 10; Repeatuntill++)
						{
							if(Repeat_Filler < 4)
							{
								Repeat_Filler ++;
								menu.AddItem(buffer2, "-", ITEMDRAW_DISABLED);	// 2
							}
							else
							{
								break;
							}
						}
						FormatEx(buffer, sizeof(buffer), "%t", tinker ? "View Modifiers" : (info.ExtraDesc[0] ? "Extra Description" : "Tags & Author"));

						
						menu.AddItem(buffer2, buffer);
					}
				}
			}
			
			menu.ExitBackButton = true;
			if(menu.Display(client, MENU_TIME_FOREVER))
			{
				SetStoreMenuLogic(client);
			}
			
			return;
		}

		item.GetItemInfo(0, info);
		menu = new Menu(Store_MenuPage);
		if(NPCOnly[client] == 1)
		{
			menu.SetTitle("%t\n%t\n%t\n \n%t\n \n%s", starterPlayer ? "Starter Mode" : "TF2: Zombie Riot", "Father Grigori's Store","All Items are 20%% off here!", "Credits", CurrentCash-CashSpent[client], TranslateItemName(client, item.Name, info.Custom_Name));
		}
		else if(UsingChoosenTags[client])
		{
			if(CurrentRound < 2 || Rogue_NoDiscount() || !Waves_InSetup())
			{
				menu.SetTitle("%t\n%t\n%t\n \n ", starterPlayer ? "Starter Mode" : "TF2: Zombie Riot", "Cherrypick Weapon", "Credits", CurrentCash-CashSpent[client]);
			}
			else
			{
				menu.SetTitle("%t\n%t\n%t\n%t\n ", starterPlayer ? "Starter Mode" : "TF2: Zombie Riot", "Cherrypick Weapon", "Credits", CurrentCash-CashSpent[client], "Store Discount");
			}
		}
		else if(CurrentRound < 2 || Rogue_NoDiscount() || !Waves_InSetup())
		{
			menu.SetTitle("%t\n \n%t\n \n%s", starterPlayer ? "Starter Mode" : "TF2: Zombie Riot", "Credits", CurrentCash-CashSpent[client], TranslateItemName(client, item.Name, info.Custom_Name));
		}
		else
		{
			menu.SetTitle("%t\n \n%t\n%t\n%s", starterPlayer ? "Starter Mode" : "TF2: Zombie Riot", "Credits", CurrentCash-CashSpent[client], "Store Discount", TranslateItemName(client, item.Name, info.Custom_Name));
		}
	}
	else
	{
		int xpLevel = LevelToXp(Level[client]);
		int xpNext = LevelToXp(Level[client]+1);
		
		int nextAt = xpNext-xpLevel;
		menu = new Menu(Store_MenuPage);
		if(NPCOnly[client] == 1)
		{
			menu.SetTitle("%t\n%t\n%t\n \n%t\n \n ", starterPlayer ? "Starter Mode" : "TF2: Zombie Riot", "Father Grigori's Store","All Items are 20%% off here!", "Credits", CurrentCash-CashSpent[client]);
		}
		else if(CurrentRound < 2 || Rogue_NoDiscount() || !Waves_InSetup())
		{
			if(UsingChoosenTags[client])
			{
				menu.SetTitle("%t\n%t\n \n%t\n ", "TF2: Zombie Riot", "Cherrypick Weapon", "Credits", CurrentCash-CashSpent[client]);
			}
			else if(Database_IsCached(client))
			{
				menu.SetTitle("%t\n \n%t\n%t\n ", starterPlayer ? "Starter Mode" : "TF2: Zombie Riot", "XP and Level", Level[client], XP[client] - xpLevel, nextAt, "Credits", CurrentCash-CashSpent[client]);
			}
			else
			{
				menu.SetTitle("%t\n \n%t\n%t\n ", "TF2: Zombie Riot", "XP Loading", "Credits", CurrentCash-CashSpent[client]);
			}
		}
		else
		{
			if(UsingChoosenTags[client])
			{
				menu.SetTitle("%t\n%t\n \n%t\n%t\n ", "TF2: Zombie Riot", "Cherrypick Weapon", "Credits", CurrentCash-CashSpent[client], "Store Discount");
			}
			else if(Database_IsCached(client))
			{
				menu.SetTitle("%t\n \n%t\n%t\n%t\n ", starterPlayer ? "Starter Mode" : "TF2: Zombie Riot", "XP and Level", Level[client], XP[client] - xpLevel, nextAt, "Credits", CurrentCash-CashSpent[client], "Store Discount");
			}
			else
			{
				menu.SetTitle("%t\n \n%t\n%t\n%t\n ", "TF2: Zombie Riot", "XP Loading", "Credits", CurrentCash-CashSpent[client], "Store Discount");
			}
		}
		
		if(!UsingChoosenTags[client] && !NPCOnly[client] && section == -1)
		{
			char buffer[32];
			FormatEx(buffer, sizeof(buffer), "%t", "Owned Items");
			menu.AddItem("-2", buffer);
		}
	}
	
	bool found;
	char buffer[64];
	int length = StoreItems.Length;
	int ClientLevel = Level[client];
	bool hasKit = Store_HasWeaponKit(client);
	
	if(CvarInfiniteCash.BoolValue)
	{
		ClientLevel = 9999; //Set client lvl to 9999 for shop if infinite cash is enabled.
	}
	
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		//item.GetItemInfo(0, info);
		if(NPCOnly[client] == 1)	// Greg Store Menu
		{
			if((!item.NPCSeller && item.NPCSeller_WaveStart == 0) || item.Level > ClientLevel)
				continue;
		}
		else if(NPCOnly[client] == 2 || NPCOnly[client] == 3)	// Rebel Store Menu
		{
			if(item.Level > ClientLevel)
				continue;
		}
		else if(UsingChoosenTags[client])	// Tag Search Menu
		{
			if(item.Hidden || item.Level > ClientLevel)
				continue;
			
			int a;
			int length2 = ChoosenTags[client].Length;
			for(; a < length2; a++)
			{
				ChoosenTags[client].GetString(a, buffer, sizeof(buffer));
				if(StrContains(item.Tags, buffer) == -1)
					break;	// Failed
			}

			if(a < length2)
				continue;
		}
		else if(section == -2)
		{
			if((!starterPlayer && item.Hidden) || (!item.Owned[client] && !item.Scaled[client]) || item.Level || item.GiftId != -1)
				continue;
		}
		else if(item.Section != section)
		{
			continue;
		}
		else if(starterPlayer)
		{
			if(!item.Starter)
				continue;
		}
		else if(item.Hidden || item.Level > ClientLevel)
		{
			continue;
		}
		
		if(NPCOnly[client] == 3)
		{
			if(!item.NPCWeaponAlways)
				continue;
		}
		else if(NPCOnly[client] == 2)
		{
			if(item.NPCWeapon < 0)
				continue;
		}
		else if(item.NPCWeapon > 9)
		{
			continue;
		}

		if(NPCOnly[client] != 1 && item.GregOnlySell)
		{
			// Block showing items if only sell
			continue;
		}
		
		if(item.GiftId != -1 && !Items_HasIdItem(client, item.GiftId))
			continue;
		
		/*if(NPCOnly[client] != 2 && NPCOnly[client] != 3 && item.Slot >= 0)
		{
			int count;
			for(int a; a<length; a++)
			{
				if(a == i)
					continue;
				
				StoreItems.GetArray(a, item2);
				if(item2.Equipped[client] && item2.Slot == item.Slot)
					count++;
			}
			
			if(count)
			{
				bool blocked;
				if(item.Slot >= sizeof(SlotLimits))
					blocked = true;
				
				if(count >= SlotLimits[item.Slot])
					blocked = true;
				
				if(blocked)
				{
					menu.AddItem("-1", TranslateItemName(client, item.Name, 1), ITEMDRAW_DISABLED);
					found = true;
					continue;
				}
			}
		}*/

		if(NPCOnly[client] == 2 || NPCOnly[client] == 3)
		{
			if(item.ItemInfos)
			{
				int npcwallet = item.NPCWeaponAlways ? 0 : NPCCash[client];
				
				item.GetItemInfo(0, info);
				if((info.Cost < 1001 || info.Cost <= CurrentCash) && RoundToCeil(float(info.Cost) * SELL_AMOUNT) > npcwallet)
				{
					ItemCost(client, item, info.Cost);
					FormatEx(buffer, sizeof(buffer), "%s [$%d]", TranslateItemName(client, item.Name, info.Custom_Name), info.Cost - npcwallet);
					
					if(Rogue_UnlockStore())
					{
						if(item.NPCSeller_First)
						{
							FormatEx(buffer, sizeof(buffer), "%s%s", buffer, "{$}");
						}	
						else if(item.NPCSeller_WaveStart > 0)
						{
							FormatEx(buffer, sizeof(buffer), "%s%s [Waves Left:%i]", buffer, "{$}", item.NPCSeller_WaveStart);
						}
					}
					else if(item.NPCSeller_First)
					{
						FormatEx(buffer, sizeof(buffer), "%s%s", buffer, "{$$}");
					}	
					else if(item.NPCSeller_WaveStart > 0)
					{
						FormatEx(buffer, sizeof(buffer), "%s%s [Waves Left:%i]", buffer, "{$$}", item.NPCSeller_WaveStart);
					}	
					else if(item.NPCSeller)
					{
						FormatEx(buffer, sizeof(buffer), "%s%s", buffer, "{$}");
					}
					
					Store_EquipSlotSuffix(client, item.Slot, buffer, sizeof(buffer));
					IntToString(i, info.Classname, sizeof(info.Classname));
					menu.AddItem(info.Classname, buffer);
					found = true;
				}
			}
		}
		else if(!item.ItemInfos)
		{
			Store_EquipSlotSuffix(client, item.Slot, buffer, sizeof(buffer));
			IntToString(i, info.Classname, sizeof(info.Classname));
			//do not have custom name here, its in the menu and thus the custom names never apear. this isnt even for weapons.
			menu.AddItem(info.Classname, TranslateItemName(client, item.Name, ""));
			found = true;
		}
		else
		{
			item.GetItemInfo(0, info);
//			if(UsingChoosenTags[client] || item.ParentKit)
			{
				int style = ITEMDRAW_DEFAULT;
				IntToString(i, info.Classname, sizeof(info.Classname));
				
				if(info.ScrapCost > 0)
				{
					FormatEx(buffer, sizeof(buffer), "%s ($%d) [$%d]", TranslateItemName(client, item.Name, info.Custom_Name), info.ScrapCost, Scrap[client]);
					if(Item_ClientHasAllRarity(client, info.UnboxRarity))
						style = ITEMDRAW_DISABLED;
				}
				else if(item.Equipped[client])
				{
					FormatEx(buffer, sizeof(buffer), "%s [%t]", TranslateItemName(client, item.Name, info.Custom_Name), "Equipped");
				}
				else if(item.Owned[client] > 1)
				{
					FormatEx(buffer, sizeof(buffer), "%s [%t]", TranslateItemName(client, item.Name, info.Custom_Name), "Packed");
				}
				else if(item.Owned[client])
				{
					FormatEx(buffer, sizeof(buffer), "%s [%t]", TranslateItemName(client, item.Name, info.Custom_Name), "Purchased");
				}
				else if(!info.Cost && item.Level)
				{
					FormatEx(buffer, sizeof(buffer), "%s [Lv %d]", TranslateItemName(client, item.Name, info.Custom_Name), item.Level);
				}
				else if(info.Cost >= 999999 && !CvarInfiniteCash.BoolValue)
				{
					continue;
				}
				else if(info.Cost > 1000 && Rogue_UnlockStore() && !item.NPCSeller)
				{
					FormatEx(buffer, sizeof(buffer), "%s [NOT FOUND]", TranslateItemName(client, item.Name, info.Custom_Name));
					style = ITEMDRAW_DISABLED;
				}
				else if(info.Cost > 1000 && !Rogue_UnlockStore() && info.Cost_Unlock > CurrentCash)
				{
					FormatEx(buffer, sizeof(buffer), "%s [%.0f%%]", TranslateItemName(client, item.Name, info.Custom_Name), float(CurrentCash) * 100.0 / float(info.Cost_Unlock));
					style = ITEMDRAW_DISABLED;
				}
				else
				{
					ItemCost(client, item, info.Cost);
					if(hasKit && item.NoKit)
					{
						FormatEx(buffer, sizeof(buffer), "%s [WEAPON KIT EQUIPPED]", TranslateItemName(client, item.Name, info.Custom_Name));
						style = ITEMDRAW_DISABLED;
					}
					else
					{
						if(item.WhiteOut)
						{
							FormatEx(buffer, sizeof(buffer), "%s", TranslateItemName(client, item.Name, info.Custom_Name));
							style = ITEMDRAW_DISABLED;
						}
						else if(!info.Cost)
						{
							FormatEx(buffer, sizeof(buffer), "%s", TranslateItemName(client, item.Name, info.Custom_Name));
						}
						else
						{
							FormatEx(buffer, sizeof(buffer), "%s [$%d]", TranslateItemName(client, item.Name, info.Custom_Name), info.Cost);
						}
					}
				}
				
				Store_EquipSlotSuffix(client, item.Slot, buffer, sizeof(buffer));

				if(Rogue_UnlockStore())
				{
					if(item.NPCSeller_First)
					{
						FormatEx(buffer, sizeof(buffer), "%s {$}", buffer);
					}	
					else if(item.NPCSeller_WaveStart > 0)
					{
						FormatEx(buffer, sizeof(buffer), "%s {$ Waves Left: %d}", buffer, item.NPCSeller_WaveStart);
					}
				}
				else if(item.NPCSeller_First)
				{
					FormatEx(buffer, sizeof(buffer), "%s {$$}", buffer);
				}	
				else if(item.NPCSeller_WaveStart > 0)
				{
					FormatEx(buffer, sizeof(buffer), "%s {$$ Waves Left: %d}", buffer, item.NPCSeller_WaveStart);
				}
				else if(item.NPCSeller)
				{
					FormatEx(buffer, sizeof(buffer), "%s {$}", buffer);
				}

				menu.AddItem(info.Classname, buffer, style);
				found = true;
			}
		}
	}

	if(UsingChoosenTags[client])
	{
		if(!found)
		{
			FormatEx(buffer, sizeof(buffer), "%t", "None");
			IntToString(CurrentMenuItem[client], info.Classname, sizeof(info.Classname));
			menu.AddItem(info.Classname, buffer, ITEMDRAW_DISABLED);
		}
		
		menu.ExitBackButton = true;
		if(DisplayMenuAtCustom(menu, client, CurrentMenuPage[client]))
		{
			SetStoreMenuLogic(client);
		}
		
		return;
	}
	else if(section == -1 && !NPCOnly[client])
	{
		if(Level[client] > STARTER_WEAPON_LEVEL)
		{
			FormatEx(buffer, sizeof(buffer), "%t", "Loadouts");
			menu.AddItem("-22", buffer);
		}

		if(Rogue_Mode())
		{
			FormatEx(buffer, sizeof(buffer), "%t", "Collected Artifacts");
			menu.AddItem("-24", buffer);
		}

		if(Level[client] > STARTER_WEAPON_LEVEL)
		{
			FormatEx(buffer, sizeof(buffer), "%t", "Cherrypick Weapon");
			menu.AddItem("-30", buffer);
		}
		
		FormatEx(buffer, sizeof(buffer), "%t", "Help?");
		menu.AddItem("-3", buffer);
		
		if(starterPlayer)
		{
			menu.AddItem("-43", buffer, ITEMDRAW_SPACER);

			FormatEx(buffer, sizeof(buffer), "%t", "Skip Starter");
			menu.AddItem("-43", buffer);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%t", "Settings"); //Settings
			menu.AddItem("-23", buffer);

			FormatEx(buffer, sizeof(buffer), "%t", "Encyclopedia");
			menu.AddItem("-13", buffer);
/*
			zr_tagblacklist.GetString(buffer, sizeof(buffer));
			if(StrContains(buffer, "private", false) == -1)
			{
				FormatEx(buffer, sizeof(buffer), "%t", "Bored or Dead");
				menu.AddItem("-14", buffer);
			}
*/
		}

		FormatEx(buffer, sizeof(buffer), "%t", "Exit");

		int count = menu.ItemCount;
		while(count < 9)
		{
			menu.AddItem("_exit", buffer, ITEMDRAW_SPACER);
			count++;
		}

		menu.AddItem("_exit", buffer);

		menu.Pagination = 0;
		menu.ExitButton = false;
		if(menu.Display(client, MENU_TIME_FOREVER))
		{
			SetStoreMenuLogic(client);
		}
	}
	else
	{
		if(!found)
		{
			FormatEx(buffer, sizeof(buffer), "%t", "None");
			menu.AddItem("0", buffer, ITEMDRAW_DISABLED);
		}

		menu.ExitBackButton = section != -1;
		if(DisplayMenuAtCustom(menu, client, CurrentMenuPage[client]))
		{
			SetStoreMenuLogic(client);
		}
	}
}
/*
static char[] AddPluses(int amount)
{
	char buffer[16];
	if(amount)
	{
		FormatEx(buffer, sizeof(buffer), " V%d", amount + 1);
	}
	else
	{
		buffer[amount] = '\0';
	}
	return buffer;
}
*/
public int Store_MenuPage(Menu menu, MenuAction action, int client, int choice)
{
	SetGlobalTransTarget(client);
	
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			ResetStoreMenuLogic(client);
		}
		case MenuAction_Select:
		{
			ResetStoreMenuLogic(client);
			
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			if(StrEqual(buffer, "_next"))
			{
				CurrentMenuPage[client] += 7;
				MenuPage(client, CurrentMenuItem[client]);
			}
			else if(StrEqual(buffer, "_previous"))
			{
				CurrentMenuPage[client] -= 7;
				MenuPage(client, CurrentMenuItem[client]);
			}
			else if(StrEqual(buffer, "_exit"))
			{
				
			}
			else if(StrEqual(buffer, "_back"))
			{
				if(UsingChoosenTags[client])
				{
					Store_CherrypickMenu(client);
					return 0;
				}
				
				static Item item;
				menu.GetItem(0, item.Name, sizeof(item.Name));
				int index = StringToInt(item.Name);
				if(index < 0)
				{
					item.Section = -1;
				}
				else
				{
					StoreItems.GetArray(index, item);
					if(item.Section != -1)
						StoreItems.GetArray(item.Section, item);
				}

				MenuPage(client, item.Section);
			}
			else
			{
				LastMenuPage[client] = CurrentMenuPage[client];
				CurrentMenuPage[client] = 0;
				CurrentMenuItem[client] = StringToInt(buffer);
				switch(CurrentMenuItem[client])
				{
					case -23:
					{
						ReShowSettingsHud(client);
					}
					case -21:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%t", "Credits Page");
						
						FormatEx(buffer, sizeof(buffer), "%t", "Back");
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -3:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%t", "Help Title?");

						FormatEx(buffer, sizeof(buffer), "%t", "Gamemode Credits"); //credits is whatever, put in back.
						menu2.AddItem("-21", buffer);

						FormatEx(buffer, sizeof(buffer), "%t", "Buff/Debuff List");
						menu2.AddItem("-12", buffer);
						
						FormatEx(buffer, sizeof(buffer), "%t", "Gamemode Help?");
						menu2.AddItem("-4", buffer);
						
						FormatEx(buffer, sizeof(buffer), "%t", "Command Help?");
						menu2.AddItem("-5", buffer);
						
						FormatEx(buffer, sizeof(buffer), "%t", "Difficulty Help?");
						menu2.AddItem("-6", buffer);
						
						FormatEx(buffer, sizeof(buffer), "%t", "Level Help?");
						menu2.AddItem("-7", buffer);
						
						FormatEx(buffer, sizeof(buffer), "%t", "Special Zombies Help?");
						menu2.AddItem("-8", buffer);
						
						FormatEx(buffer, sizeof(buffer), "%t", "Revival Help?");
						menu2.AddItem("-9", buffer);
						
						FormatEx(buffer, sizeof(buffer), "%t", "Building Help?");
						menu2.AddItem("-10", buffer);
						
						FormatEx(buffer, sizeof(buffer), "%t", "Extra Buttons Help?");
						menu2.AddItem("-11", buffer);
						
						menu2.ExitBackButton = true;
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -4:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%t", "Gamemode Help Explained");
						
						FormatEx(buffer, sizeof(buffer), "%t", "Back");
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -12:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%t", "Debuff/Buff Explain 1");

						
						FormatEx(buffer, sizeof(buffer), "%t", "Show Debuffs");
						menu2.AddItem("-53", buffer);
						
						FormatEx(buffer, sizeof(buffer), "%t", "Back");
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -53:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%t", "Debuff/Buff Explain 2");

						
						FormatEx(buffer, sizeof(buffer), "%t", "Show Buffs");
						menu2.AddItem("-12", buffer);
						
						FormatEx(buffer, sizeof(buffer), "%t", "Back");
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -5:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%t", "Command Help Explained");
						
						FormatEx(buffer, sizeof(buffer), "%t", "Back");
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -6:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%t", "Difficulty Help Explained");
						
						FormatEx(buffer, sizeof(buffer), "%t", "Back");
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -7:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%t", "Level Help Explained");
						
						FormatEx(buffer, sizeof(buffer), "%t", "Back");
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -8:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%t", "Special Zombies Explained");
						
						FormatEx(buffer, sizeof(buffer), "%t", "Back");
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -9:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%t", "Revival Zombies Explained");
						
						FormatEx(buffer, sizeof(buffer), "%t", "Back");
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -10:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%t", "Building Explained");
						
						FormatEx(buffer, sizeof(buffer), "%t", "Back");
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -11:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%t", "Extra Buttons Explained");
						
						FormatEx(buffer, sizeof(buffer), "%t", "Back");
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -13:
					{
						Items_EncyclopediaMenu(client);
					}
					case -14:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%t", "Bored or Dead Minigame");
						
						FormatEx(buffer, sizeof(buffer), "%t", "Idlemine");
						menu2.AddItem("-15", buffer);
						
						FormatEx(buffer, sizeof(buffer), "%t", "Tetris");
						menu2.AddItem("-16", buffer);
						
						FormatEx(buffer, sizeof(buffer), "%t", "Snake");
						menu2.AddItem("-17", buffer);
						
						FormatEx(buffer, sizeof(buffer), "%t", "Solitaire");
						menu2.AddItem("-18", buffer);
						
						FormatEx(buffer, sizeof(buffer), "%t", "Pong");
						menu2.AddItem("-19", buffer);
						
						FormatEx(buffer, sizeof(buffer), "%t", "Connect 4");
						menu2.AddItem("-20", buffer);
						
						FormatEx(buffer, sizeof(buffer), "%t", "Back");
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -15:
					{
						FakeClientCommand(client, "sm_idlemine");
					}
					case -16:
					{
						FakeClientCommand(client, "sm_tetris");
					}
					case -17:
					{
						FakeClientCommand(client, "sm_snake");
					}
					case -18:
					{
						FakeClientCommand(client, "sm_solitaire");
					}
					case -19:
					{
						FakeClientCommand(client, "sm_pong");
					}
					case -20:
					{
						FakeClientCommand(client, "sm_connect4");
					}
					case -22:
					{
						LoadoutPage(client);
					}
					case -43:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%t", "Skip Starter Confirm");
						
						FormatEx(buffer, sizeof(buffer), "%t", "Skip Starter Yes");
						menu2.AddItem("-44", buffer);

						FormatEx(buffer, sizeof(buffer), "%t", "Back");
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -44:
					{
						XP[client] = LevelToXp(5);
						GiveXP(client, 0);
					}
					case -24:
					{
						Rogue_ArtifactMenu(client, 0);
					}
					case -30:
					{
						Store_CherrypickMenu(client);
					}
					default:
					{
						MenuPage(client, CurrentMenuItem[client]);
					}
				}
			}
		}
	}
	return 0;
}

public int Store_MenuItem(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			ResetStoreMenuLogic(client);

			if(choice == MenuCancel_ExitBack)
			{
				Item item;
				menu.GetItem(0, item.Name, sizeof(item.Name));
				StoreItems.GetArray(StringToInt(item.Name), item);
				MenuPage(client, item.Section);
			}
			/*
			else if(choice != MenuCancel_Disconnected)
			{
				StopSound(client, SNDCHAN_STATIC, "#items/tf_music_upgrade_machine.wav");
			}
			*/
		}
		case MenuAction_Select:
		{
			ResetStoreMenuLogic(client);
			
			if(dieingstate[client] > 0) //They shall not enter the store if they are downed.
			{
				return 0;
			}
			
			static Item item;
			menu.GetItem(0, item.Name, sizeof(item.Name));
			int index = StringToInt(item.Name);
			StoreItems.GetArray(index, item);
			
			ItemInfo info;
			switch(choice)
			{
				case 0:
				{
					int cash = CurrentCash - CashSpent[client];
					
					if(ClientTutorialStep(client) == 2)
					{
						SetClientTutorialStep(client, 3);
						DoTutorialStep(client, false);	
					}
			
					if(NPCOnly[client] == 2 || NPCOnly[client] == 3)	// Buy Rebel Weapon
					{
						item.GetItemInfo(0, info);
						
						int sell = RoundToCeil(float(info.Cost) * SELL_AMOUNT);
						ItemCost(client, item, info.Cost);
						if(!item.NPCWeaponAlways)
							info.Cost -= NPCCash[client];
						
						if(info.Cost <= cash)
						{
							int entity = EntRefToEntIndex(NPCTarget[client]);
							if(entity != INVALID_ENT_REFERENCE)
							{
								if(Citizen_UpdateWeaponStats(entity, item.NPCWeapon, sell, info, GetClientUserId(client)))
								{
									CashSpent[client] += info.Cost;
									CashSpentTotal[client] += info.Cost;
									ClientCommand(client, "playgamesound \"mvm/mvm_bought_upgrade.wav\"");
									
									if(!item.NPCWeaponAlways)
									{
										for(int i = 1; i <= MaxClients; i++)
										{
											if(GetClientMenu(i) && NPCOnly[i] == NPCOnly[client] && NPCTarget[client] == NPCTarget[i])
											{
												CancelClientMenu(i);
												NPCTarget[i] = -1;
											}
										}
										return 0;
									}
									else
									{
										int client_previously = GetClientOfUserId(i_ThisEntityHasAMachineThatBelongsToClient[entity]);
										if(IsValidClient(client_previously) && client_previously != client)
										{
											//Give them some their money back! Some other person just override theirs, i dont think they should be punished for that.......
											//BUT ONLY IF ITS ACTUALLY A DIFFERENT CLIENT. :(
											int money_back = RoundToCeil(float(i_ThisEntityHasAMachineThatBelongsToClientMoney[entity]) * SELL_AMOUNT);
											SetGlobalTransTarget(client_previously);
											PrintToChat(client_previously, "%t","You got your money back npc", money_back);
											CashSpent[client_previously] -= money_back;
											CashSpentTotal[client_previously] -= money_back;
											i_ThisEntityHasAMachineThatBelongsToClientMoney[entity] = 0;
											
										}
										i_ThisEntityHasAMachineThatBelongsToClient[entity] = GetClientUserId(client);
										i_ThisEntityHasAMachineThatBelongsToClientMoney[entity] = info.Cost;
									}
								}
							}
						}
					}
					else
					{
						int level = item.Owned[client]-1;
						if(item.ParentKit || level < 0)
							level = 0;

						item.GetItemInfo(level, info);
						if(info.ScrapCost > 0) //Make scrap cost preffered, dont bother with anything else.
						{
							if((info.ScrapCost > (Scrap[client])) && !CvarInfiniteCash.BoolValue)
							{
								return 0; //HOW THEY DO THIS? FUCK U
							}
							//just spawn it inside them LOL
							float VecOrigin[3];
							GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", VecOrigin);
							VecOrigin[2] += 45.0;

							Stock_SpawnGift(VecOrigin, GIFT_MODEL, 45.0, client, info.UnboxRarity -1); //since they are one lower
							
							if(!CvarInfiniteCash.BoolValue)
							{
								Scrap[client] -= info.ScrapCost;
							}
							
							MenuPage(client, index);

							return 0;
						}
						
						if(item.Equipped[client])	// Buy Ammo
						{
							if(info.AmmoBuyMenuOnly && info.AmmoBuyMenuOnly < Ammo_MAX)	// Weapon with A2735mmo, buyable only
							{
								CashSpent[client] += AmmoData[info.AmmoBuyMenuOnly][0];
								CashSpentTotal[client] += AmmoData[info.AmmoBuyMenuOnly][0];
								ClientCommand(client, "playgamesound \"mvm/mvm_bought_upgrade.wav\"");
								
								int ammo = GetAmmo(client, info.AmmoBuyMenuOnly) + AmmoData[info.AmmoBuyMenuOnly][1];
								SetAmmo(client, info.AmmoBuyMenuOnly, ammo);
								CurrentAmmo[client][info.AmmoBuyMenuOnly] = ammo;
							}
							else if(info.Ammo && info.Ammo < Ammo_MAX && AmmoData[info.Ammo][0] <= cash)
							{
								CashSpent[client] += AmmoData[info.Ammo][0];
								CashSpentTotal[client] += AmmoData[info.Ammo][0];
								ClientCommand(client, "playgamesound \"mvm/mvm_bought_upgrade.wav\"");
								
								int ammo = GetAmmo(client, info.Ammo) + AmmoData[info.Ammo][1];
								SetAmmo(client, info.Ammo, ammo);
								CurrentAmmo[client][info.Ammo] = ammo;
							}
						}
						else if(item.ParentKit)	// Weapon Kit
						{
							if(!item.Owned[client])	// Buy All Items
							{
								int base = info.Cost;
								ItemCost(client, item, info.Cost);
								if(info.Cost <= cash)
								{
									CashSpent[client] += info.Cost;
									CashSpentTotal[client] += info.Cost;
									Store_BuyClientItem(client, index, item, info);
									item.BuyPrice[client] = info.Cost;
									item.RogueBoughtRecently[client] += 1;
									item.Sell[client] = ItemSell(base, info.Cost);
									if(item.GregOnlySell == 2)
									{
										item.BuyPrice[client] = 0;
										item.Sell[client] = 0;
									}
									item.BuyWave[client] = Rogue_GetRoundScale();
									item.Equipped[client] = false;

									if(item.GregOnlySell == 2)
									{
										item.Sell[client] = 0;
									}
									if(!item.BoughtBefore[client])
									{
										item.BoughtBefore[client] = true;
										StoreBalanceLog.Rewind();
										StoreBalanceLog.SetNum(item.Name, StoreBalanceLog.GetNum(item.Name) + 1);
									}
									
									ClientCommand(client, "playgamesound \"mvm/mvm_bought_upgrade.wav\"");
								}
							}
							
							if(item.Owned[client] && !item.Equipped[client])	// Equip All Items
							{
								Store_EquipSlotCheck(client, item);

								item.Equipped[client] = true;
								StoreItems.SetArray(index, item);
								
								static Item subItem;
								int length = StoreItems.Length;
								for(int i; i < length; i++)
								{
									StoreItems.GetArray(i, subItem);
									if(subItem.Section == index)
									{
										Store_EquipSlotCheck(client, subItem);
										subItem.Owned[client] = item.Owned[client];
										subItem.Equipped[client] = true;
										StoreItems.SetArray(i, subItem);
									}
								}
								
								if(!TeutonType[client] && !i_ClientHasCustomGearEquipped[client])
								{
									Store_ApplyAttribs(client);
									Store_GiveAll(client, GetClientHealth(client));
								}
							}
						}
						else if(info.Classname[0])	// Weapon
						{
							if(!item.Owned[client])	// Buy Weapon
							{
								int base = info.Cost;
								ItemCost(client, item, info.Cost);
								if(info.Cost <= cash)
								{
									CashSpent[client] += info.Cost;
									CashSpentTotal[client] += info.Cost;
									Store_BuyClientItem(client, index, item, info);
									item.BuyPrice[client] = info.Cost;
									item.RogueBoughtRecently[client] += 1;
									item.Sell[client] = ItemSell(base, info.Cost);
									item.BuyWave[client] = Rogue_GetRoundScale();
									if(item.GregOnlySell == 2)
									{
										item.Sell[client] = 0;
									}
									if(info.NoRefundWanted)
									{
										item.BuyWave[client] = -1;
										item.Sell[client] = item.Sell[client] / 2;
									}
									item.Equipped[client] = false;

									if(!item.BoughtBefore[client])
									{
										item.BoughtBefore[client] = true;
										StoreBalanceLog.Rewind();
										StoreBalanceLog.SetNum(item.Name, StoreBalanceLog.GetNum(item.Name) + 1);
									}
									
									ClientCommand(client, "playgamesound \"mvm/mvm_bought_upgrade.wav\"");
								}
							}
							
							if(item.Owned[client] && !item.Equipped[client])	// Equip Weapon
							{
								Store_EquipSlotCheck(client, item);

								item.Equipped[client] = true;
								StoreItems.SetArray(index, item);
								
								if(!TeutonType[client] && !i_ClientHasCustomGearEquipped[client])
								{
									Store_GiveItem(client, index, item.Equipped[client]);
									if(TF2_GetClassnameSlot(info.Classname) == TFWeaponSlot_Melee)
										Store_RemoveNullWeapons(client);
									
									CheckInvalidSlots(client);
									CheckMultiSlots(client);
									Manual_Impulse_101(client, GetClientHealth(client));
								}
							}
						}
						else if(!item.Owned[client])	// Buy Perk
						{
							int base = info.Cost;
							ItemCost(client, item, info.Cost);
							if(info.Cost <= cash)
							{
								CashSpent[client] += info.Cost;
								CashSpentTotal[client] += info.Cost;
								Store_BuyClientItem(client, index, item, info);
								item.BuyPrice[client] = info.Cost;
								item.RogueBoughtRecently[client] += 1;
								item.Sell[client] = ItemSell(base, info.Cost);
								item.BuyWave[client] = Rogue_GetRoundScale();
								if(item.GregOnlySell == 2)
								{
									item.Sell[client] = 0;
								}
								else if(info.NoRefundWanted)
								{
									item.BuyWave[client] = -1;
									item.Sell[client] = item.Sell[client] / 2;
								}
								if(!item.BoughtBefore[client])
								{
									item.BoughtBefore[client] = true;
									StoreBalanceLog.Rewind();
									StoreBalanceLog.SetNum(item.Name, StoreBalanceLog.GetNum(item.Name) + 1);
								}
								
								StoreItems.SetArray(index, item);
								
								ClientCommand(client, "playgamesound \"mvm/mvm_bought_upgrade.wav\"");

								Store_ApplyAttribs(client);
								Store_GiveAll(client, GetClientHealth(client));
							}
						}
						else
						{
							Store_EquipSlotCheck(client, item);

							item.Equipped[client] = true;
							StoreItems.SetArray(index, item);
							
							if(!TeutonType[client] && !i_ClientHasCustomGearEquipped[client])
							{
							//	Store_GiveItem(client, index, item.Equipped[client]);
							//	if(TF2_GetClassnameSlot(info.Classname) == TFWeaponSlot_Melee)
							//		Store_RemoveNullWeapons(client);
								
								CheckMultiSlots(client);
								Manual_Impulse_101(client, GetClientHealth(client));
								Store_ApplyAttribs(client);
								Store_GiveAll(client, GetClientHealth(client));
							}
						}
					}
				}
				case 1:	 // Ammo x10
				{
					if(item.Owned[client])
					{
						int cash = CurrentCash - CashSpent[client];
						int level = item.Owned[client] - 1;
						if(item.ParentKit || level < 0)
							level = 0;
						
						item.GetItemInfo(level, info);
						if(info.AmmoBuyMenuOnly && info.AmmoBuyMenuOnly < Ammo_MAX)	// Weapon with A2735mmo, buyable only
						{
							int cost = AmmoData[info.AmmoBuyMenuOnly][0] * 10;
							if(cost <= cash)
							{
								CashSpent[client] += cost;
								CashSpentTotal[client] += cost;
								ClientCommand(client, "playgamesound \"mvm/mvm_bought_upgrade.wav\"");
								int ammo = GetAmmo(client, info.AmmoBuyMenuOnly) + AmmoData[info.AmmoBuyMenuOnly][1]*10;
								SetAmmo(client, info.AmmoBuyMenuOnly, ammo);
								CurrentAmmo[client][info.AmmoBuyMenuOnly] = ammo;
							}
						}
						else if(info.Ammo && info.Ammo < Ammo_MAX)
						{
							int cost = AmmoData[info.Ammo][0] * 10;
							if(cost <= cash)
							{
								CashSpent[client] += cost;
								CashSpentTotal[client] += cost;
								ClientCommand(client, "playgamesound \"mvm/mvm_bought_upgrade.wav\"");
								int ammo = GetAmmo(client, info.Ammo) + AmmoData[info.Ammo][1]*10;
								SetAmmo(client, info.Ammo, ammo);
								CurrentAmmo[client][info.Ammo] = ammo;
							}
						}
					}
				}
				case 2:	// Unequip
				{
					if(item.Owned[client] && item.Equipped[client] && item.GregOnlySell != 2)
					{
						int active_weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

						if(active_weapon > MaxClients)
						{
							char buffer[64];
							GetEntityClassname(active_weapon, buffer, sizeof(buffer));
							if(GetEntPropFloat(active_weapon, Prop_Send, "m_flNextPrimaryAttack") < GetGameTime() && TF2_GetClassnameSlot(buffer) != TFWeaponSlot_PDA)
							{
								Store_Unequip(client, index);
								
								Store_ApplyAttribs(client);
								Store_GiveAll(client, GetClientHealth(client));	
							}
							else
							{
								ClientCommand(client, "playgamesound items/medshotno1.wav");	
							}
						}
					}
				}
				case 3:	// Sell
				{
					if(item.Owned[client])
					{
						int active_weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

						if(active_weapon > MaxClients)
						{
							char buffer[64];
							GetEntityClassname(active_weapon, buffer, sizeof(buffer));
							if(GetEntPropFloat(active_weapon, Prop_Send, "m_flNextPrimaryAttack") < GetGameTime() && TF2_GetClassnameSlot(buffer) != TFWeaponSlot_PDA)
							{
								int level = item.Owned[client] - 1;
								if(item.ParentKit)
									level = 0;
								
								item.GetItemInfo(level, info);

								int sell = item.Sell[client];
								if(item.BuyWave[client] == Rogue_GetRoundScale())
									sell = item.BuyPrice[client];
								
								if(sell) //make sure it even can be sold.
								{
									CashSpent[client] -= sell;
									CashSpentTotal[client] -= sell;
									ClientCommand(client, "playgamesound \"mvm/mvm_money_pickup.wav\"");
								}
								item.RogueBoughtRecently[client] -= 1;
								
								item.Owned[client] = 0;
								if(item.Scaled[client] > 0)
									item.Scaled[client]--;
								
								item.Equipped[client] = false;
								StoreItems.SetArray(index, item);
								
								if(item.ParentKit)
								{
									static Item subItem;
									int length = StoreItems.Length;
									for(int i; i < length; i++)
									{
										StoreItems.GetArray(i, subItem);
										if(subItem.Section == index)
										{
											subItem.Owned[client] = 0;
											subItem.Equipped[client] = false;
											StoreItems.SetArray(i, subItem);
										}
									}
								}
									
								Store_ApplyAttribs(client);
								Store_GiveAll(client, GetClientHealth(client));
							}
							else
							{
								ClientCommand(client, "playgamesound items/medshotno1.wav");
							}
						}
					}
				}
				case 4:
				{
					item.GetItemInfo(0, info);

					char buffer[256];

					if(item.Tags[0])
					{
						char buffers[6][256];
						int tags = ExplodeString(item.Tags, ";", buffers, sizeof(buffers), sizeof(buffers[]));
						if(tags)
						{
							FormatEx(buffer, sizeof(buffer), "%s", TranslateItemDescription(client, buffers[0], ""));

							for(int i = 1; i < tags; i++)
							{
								Format(buffer, sizeof(buffer), "%s, %s", buffer, TranslateItemDescription(client, buffers[i], ""));
							}

							PrintToChat(client, "%t", "Tags List", buffer);
						}
					}

					if(info.ExtraDesc[0])
					{
						FormatEx(buffer, sizeof(buffer), "%s", TranslateItemDescription(client, info.ExtraDesc, info.Rogue_Desc));
						PrintToChat(client, buffer);
						char buffer2[256];
						FormatEx(buffer2, sizeof(buffer2), "%s", TranslateItemDescription(client, info.ExtraDesc_1, info.Rogue_Desc));
						PrintToChat(client, buffer2);
					}

					if(item.Author[0])
					{
						CPrintToChat(client, "%t", "Created By", item.Author);
					}

					Blacksmith_ExtraDesc(client, index);
				}
			}
			MenuPage(client, index);
		}
	}
	return 0;
}

static void LoadoutPage(int client, bool last = false)
{
	SetGlobalTransTarget(client);
	
	Menu menu = new Menu(Store_LoadoutPage);
	
	char buffer[64];
	
	int length;
	if(Loadouts[client])
	{
		length = Loadouts[client].Length;
		for(int i; i < length; i++)
		{
			Loadouts[client].GetString(i, buffer, sizeof(buffer));
			menu.AddItem(buffer, buffer);
		}
	}
	
	if(!length)
	{
		FormatEx(buffer, sizeof(buffer), "%t", "None");
		menu.AddItem("", buffer, ITEMDRAW_DISABLED);
	}
	
	int slots = (Level[client] + 1 - STARTER_WEAPON_LEVEL) / 2;
	if(slots > length)
	{
		menu.SetTitle("%t\n%t\n \n%t", "TF2: Zombie Riot", "Loadouts", "Save New");
	}
	else
	{
		menu.SetTitle("%t\n%t\n \n ", "TF2: Zombie Riot", "Loadouts");
	}
	
	menu.ExitBackButton = true;
	if(menu.DisplayAt(client, last ? (length / 7 * 7) : 0, MENU_TIME_FOREVER) && (Level[client] / 2) > length)
		InLoadoutMenu[client] = true;
}

public int Store_LoadoutPage(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			InLoadoutMenu[client] = false;
			
			if(choice == MenuCancel_ExitBack)
				MenuPage(client, -1);
		}
		case MenuAction_Select:
		{
			InLoadoutMenu[client] = false;
			
			char buffer[32];
			menu.GetItem(choice, buffer, sizeof(buffer));
			LoadoutItem(client, buffer);
		}
	}
	return 0;
}

static void LoadoutItem(int client, const char[] name)
{
	SetGlobalTransTarget(client);
	
	Menu menu = new Menu(Store_LoadoutItem);
	menu.SetTitle("%t\n%t\n \n%s", "TF2: Zombie Riot", "Loadouts", name);
	
	char buffer[64];
	
	FormatEx(buffer, sizeof(buffer), "%t", "All Items");
	menu.AddItem(name, buffer);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Free Only");
	menu.AddItem(name, buffer);
	
	menu.AddItem(name, buffer, ITEMDRAW_SPACER);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Delete Loadout");
	menu.AddItem(name, buffer);
	
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Store_LoadoutItem(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
				LoadoutPage(client);
		}
		case MenuAction_Select:
		{
			char buffer[32];
			menu.GetItem(choice, buffer, sizeof(buffer));
			switch(choice)
			{
				case 0, 1:
				{
					SetGlobalTransTarget(client);
					
					Menu menu2 = new Menu(Store_MenuPage);
					menu2.SetTitle("%t", "Getting Your Items");
					
					menu2.AddItem(NULL_STRING, NULL_STRING, ITEMDRAW_SPACER);
					
					menu2.Display(client, 10);
					
					Database_LoadLoadout(client, buffer, choice == 1);
				}
				case 3:
				{
					int index = Loadouts[client].FindString(buffer);
					if(index != -1)
					{
						Loadouts[client].Erase(index);
						Database_DeleteLoadout(client, buffer);
					}
					
					LoadoutPage(client);
				}
			}
		}
	}
	return 0;
}

public bool Store_SayCommand(int client)
{
	if(!InLoadoutMenu[client])
		return false;
	
	char buffer[64];
	GetCmdArgString(buffer, sizeof(buffer));
	ReplaceString(buffer, sizeof(buffer), "\"", "");
	
	int length = 33;
	if(Database_Escape(buffer, sizeof(buffer), length) && length < 31)
	{

		Database_SaveLoadout(client, buffer);
		
		if(!Loadouts[client])
			Loadouts[client] = new ArrayList(ByteCountToCells(32));
		
		Loadouts[client].PushString(buffer);
		LoadoutPage(client, true);
	}
	else
	{
		PrintToChat(client, "%T", "Invalid Name", client);
	}
	return true;
}

static void Store_CherrypickMenu(int client, int item = 0)
{
	UsingChoosenTags[client] = false;

	if(!ChoosenTags[client])
		ChoosenTags[client] = new ArrayList(ByteCountToCells(32));
	
	SetGlobalTransTarget(client);
	
	Menu menu = new Menu(Store_CherrypickMenuH);
	menu.SetTitle("%t\n%t\n \n", "TF2: Zombie Riot", "Cherrypick Weapon");
	
	char trans[32], buffer[256];

	FormatEx(trans, sizeof(trans), "%t", "Search With Tags");
	menu.AddItem(buffer, trans, ChoosenTags[client].Length ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	FormatEx(trans, sizeof(trans), "%t", "Clear Whitelist");
	menu.AddItem(buffer, trans, ChoosenTags[client].Length ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	int length = StoreTags.Length;
	for(int i; i < length; i++)
	{
		StoreTags.GetString(i, buffer, sizeof(buffer));
		FormatEx(trans, sizeof(trans), "[%s] %s", ChoosenTags[client].FindString(buffer) == -1 ? " " : "X", TranslateItemDescription(client, buffer, ""));
		menu.AddItem(buffer, trans);
	}
	
	menu.ExitBackButton = true;
	menu.DisplayAt(client, item / 7 * 7, MENU_TIME_FOREVER);
}

public int Store_CherrypickMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
				MenuPage(client, -1);
		}
		case MenuAction_Select:
		{
			switch(choice)
			{
				case 0:
				{
					UsingChoosenTags[client] = true;
					MenuPage(client, -1);
				}
				case 1:
				{
					delete ChoosenTags[client];
					Store_CherrypickMenu(client, choice);
				}
				default:
				{
					char buffer[32];
					menu.GetItem(choice, buffer, sizeof(buffer));
					int pos = ChoosenTags[client].FindString(buffer);
					if(pos == -1)
					{
						ChoosenTags[client].PushString(buffer);
					}
					else
					{
						ChoosenTags[client].Erase(pos);
					}

					Store_CherrypickMenu(client, choice);
				}
			}
		}
	}
	return 0;
}

void Store_ApplyAttribs(int client)
{
	if(TeutonType[client] || !StoreItems)
		return;

	Attributes_RemoveAll(client);
	
	TFClassType ClassForStats = WeaponClass[client];
	
	StringMap map = new StringMap();

	int Extra_Juggernog_Hp = 0;
	if(i_CurrentEquippedPerk[client] == 2)
	{
		Extra_Juggernog_Hp = 100;
	}

	if(i_HealthBeforeSuit[client] == 0)
	{
		map.SetValue("26", RemoveExtraHealth(ClassForStats, 200.0) + Extra_Juggernog_Hp);		// Health
	}
	else
	{
		map.SetValue("26", RemoveExtraHealth(ClassForStats, 1.0));		// Health
	}

	float MovementSpeed = 330.0;
	
	if(VIPBuilding_Active())
	{
		MovementSpeed = 419.0;
		map.SetValue("443", 1.25);
	}
	
	map.SetValue("201", f_DelayAttackspeedPreivous[client]);
	map.SetValue("107", RemoveExtraSpeed(ClassForStats, MovementSpeed));		// Move Speed
	map.SetValue("343", 1.0); //sentry attackspeed fix
	if(LastMann)
		map.SetValue("442", 0.7674418604651163);		// Move Speed

	map.SetValue("740", 0.0);	// No Healing from mediguns, allow healing from pickups
	map.SetValue("314", -2.0);	//Medigun uber duration, it has to be a body attribute
	map.SetValue("8", 1.5);	//give 50% more healing at the start.

	float KnockbackResistance;
	KnockbackResistance = float(CurrentCash) * 150000.0; //at wave 60, this will equal to 60* dmg

	if(KnockbackResistance > 1.0)
	{
		KnockbackResistance = 0.4;
	}
	else
	{
		KnockbackResistance -= 1.0;
		KnockbackResistance *= -1.0;
	}

	if(KnockbackResistance <= 0.40)
	{
		KnockbackResistance = 0.40;
	}
	if(KnockbackResistance > 1.0)
	{
		KnockbackResistance = 1.0;
	}

	map.SetValue("252", KnockbackResistance);
	if(Items_HasNamedItem(client, "Alaxios's Godly assistance"))
	{
		b_AlaxiosBuffItem[client] = true;
	}
	else
	{
		b_AlaxiosBuffItem[client] = false;
	}

	if(i_CurrentEquippedPerk[client] == 4)
	{
		map.SetValue("178", 0.65); //Faster Weapon Switch
	}
	
	//DOUBLE TAP!
	if(i_CurrentEquippedPerk[client] == 3) //Increace sentry damage! Not attack rate, could end ugly.
	{		
		map.SetValue("287", 0.65);
	}
	else
	{
		map.SetValue("287", 0.5);
	}

	float value;
	char buffer1[12];
	if(!i_ClientHasCustomGearEquipped[client])
	{
		static ItemInfo info;
		char buffer2[32];

		static Item item;
		int length = StoreItems.Length;
		for(int i; i < length; i++)
		{
			StoreItems.GetArray(i, item);
			if(item.Owned[client] && item.Equipped[client] && !item.ParentKit)
			{
				item.GetItemInfo(item.Owned[client]-1, info);
				if(!info.Classname[0])
				{	
					if((info.Index<0 || info.Index>2) && info.Index<6)
					{
						for(int a; a<info.Attribs; a++)
						{
							IntToString(info.Attrib[a], buffer1, sizeof(buffer1));
							if(!map.GetValue(buffer1, value))
							{
								map.SetValue(buffer1, info.Value[a]);
							}
							else if(info.Attrib[a] < 0 || info.Attrib[a]==26 || (TF2Econ_GetAttributeDefinitionString(info.Attrib[a], "description_format", buffer2, sizeof(buffer2)) && StrContains(buffer2, "additive")!=-1))
							{
								map.SetValue(buffer1, value + info.Value[a]);
							}
							else
							{
								map.SetValue(buffer1, value * info.Value[a]);
							}
						}
					}

					if((info.Index2<0 || info.Index2>2) && info.Index2<6)
					{
						for(int a; a<info.Attribs2; a++)
						{
							IntToString(info.Attrib2[a], buffer1, sizeof(buffer1));
							if(!map.GetValue(buffer1, value))
							{
								map.SetValue(buffer1, info.Value2[a]);
							}
							else if(info.Attrib2[a] < 0 || info.Attrib2[a]==26 || (TF2Econ_GetAttributeDefinitionString(info.Attrib2[a], "description_format", buffer2, sizeof(buffer2)) && StrContains(buffer2, "additive")!=-1))
							{
								map.SetValue(buffer1, value + info.Value2[a]);
							}
							else
							{
								map.SetValue(buffer1, value * info.Value2[a]);
							}
						}
					}

					if(info.FuncOnDeploy != INVALID_FUNCTION)
					{
						Call_StartFunction(null, info.FuncOnDeploy);
						Call_PushCell(client);
						Call_PushCell(-1);
						Call_PushCell(-1);
						Call_Finish();
					}
				}
			}
		}
	}
	
	Armor_Level[client] = 0;
	Jesus_Blessing[client] = 0;
	i_HeadshotAffinity[client] = 0;
	i_BarbariansMind[client] = 0;
	i_SoftShoes[client] = 0;
	i_BadHealthRegen[client] = 0;

	Rogue_ApplyAttribs(client, map);

	StringMapSnapshot snapshot = map.Snapshot();
	int entity = client;
	int length = snapshot.Length;
	int attribs = 0;
	for(int i; i < length; i++)
	{
		if(attribs && !(attribs % 16))
		{
			if(!TF2_GetWearable(client, entity))
				break;

			if(EntRefToEntIndex(i_Viewmodel_PlayerModel[client]) == entity)
			{
				i--;
				continue;
			}

			Attributes_RemoveAll(entity);
			attribs++;
		}

		snapshot.GetKey(i, buffer1, sizeof(buffer1));
		if(map.GetValue(buffer1, value))
		{
			int index = StringToInt(buffer1);
			switch(index)
			{
				case 701:
				{
					Armor_Level[client] = RoundToNearest(value);
					continue;
				}
				case 777:
				{
					Jesus_Blessing[client] = RoundToNearest(value);
					continue;
				}
				case 785:
				{
					i_HeadshotAffinity[client] = RoundToNearest(value);
					continue;
				}
				case 830:
				{
					i_BarbariansMind[client] = RoundToNearest(value);
					continue;
				}
				case 527:
				{
					i_SoftShoes[client] = RoundToNearest(value);
					continue;
				}
				case 805:
				{
					i_BadHealthRegen[client] = RoundToNearest(value);
					continue;
				}
			}

			if(Attributes_Set(entity, index, value))
				attribs++;

		}
	}

	while(TF2_GetWearable(client, entity))
	{
		if(EntRefToEntIndex(i_Viewmodel_PlayerModel[client]) == entity)
			continue;
		
		Attributes_RemoveAll(entity);
	}

	if(dieingstate[client] > 0)
	{
		ForcePlayerCrouch(client, true);
		if(b_XenoVial[client])
			Attributes_Set(client, 489, 0.85);
		else
			Attributes_Set(client, 489, 0.65);
	}
	
	Mana_Regen_Level[client] = Attributes_GetOnPlayer(client, 405);
	
	delete snapshot;
	delete map;

	TF2_AddCondition(client, TFCond_Dazed, 0.001);

	EnableSilvesterCosmetic(client);
	EnableMagiaCosmetic(client);
	Building_Check_ValidSupportcount(client);
}

void Store_GiveAll(int client, int health, bool removeWeapons = false)
{
	if(!StoreItems)
	{
		return; //STOP. BAD!
	}
	Clip_SaveAllWeaponsClipSizes(client);
	TF2_SetPlayerClass_ZR(client, CurrentClass[client], false, false);

	int entity = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(entity != -1 && GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex") == 28)
	{
		// Holding a building, prevent breakage
		return;
	}

	if(removeWeapons)
	{
		TF2_RegeneratePlayer(client);
		Manual_Impulse_101(client, health);
		return;
	}

	if(TeutonType[client] != TEUTON_NONE)
	{
		TF2_RegeneratePlayer(client);
		return;
	}
	else if(StoreItems)
	{
		Store_RemoveSpecificItem(client, "Irene's Handcannon");
		Store_RemoveSpecificItem(client, "Teutonic Longsword");
	}
	b_HasBeenHereSinceStartOfWave[client] = true; //If they arent a teuton!
	OverridePlayerModel(client, 0, false);

	//stickies can stay, we delete any non spike stickies.
	for( int i = 1; i <= MAXENTITIES; i++ ) 
	{
		if(IsValidEntity(i))
		{
			static char classname[36];
			GetEntityClassname(i, classname, sizeof(classname));
			if(!StrContains(classname, "tf_projectile_pipe_remote"))
			{
				if(!IsEntitySpike(i))
				{
					if(GetEntPropEnt(i, Prop_Send, "m_hThrower") == client)
					{
						DoGrenadeExplodeLogic(i);
						RemoveEntity(i);
					}
				}
			}
		}
	}

	//There is no easy way to preserve uber through with multiple mediguns
	//solution: save via index
	ClientSaveRageMeterStatus(client);
	ClientSaveUber(client);

	/*
	int weapon = GetPlayerWeaponSlot(client, 1); //Secondary
	if(IsValidEntity(weapon))
	{
		if(HasEntProp(weapon, Prop_Send, "m_flChargeLevel"))
		{
			f_MedigunChargeSave[client] = GetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel");
		}
	}
	*/
	if(!i_ClientHasCustomGearEquipped[client])
	{
		TF2_RemoveAllWeapons(client);
	}
	/*
	i_StickyAccessoryLogicItem[client] = EntIndexToEntRef(SpawnWeapon_Special(client, "tf_weapon_pda_engineer_destroy", 26, 100, 5, "671 ; 1"));
	*/
	int ViewmodelPlayerModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(IsValidEntity(ViewmodelPlayerModel))
	{
		Attributes_Set(ViewmodelPlayerModel, 221, -99.0);
		Attributes_Set(ViewmodelPlayerModel, 160, 1.0);
		Attributes_Set(ViewmodelPlayerModel, 35, 0.0);
		Attributes_Set(ViewmodelPlayerModel, 816, 1.0);
		Attributes_Set(ViewmodelPlayerModel, 671, 1.0);
		Attributes_Set(ViewmodelPlayerModel, 34, 999.0);
		TF2Attrib_SetByDefIndex(ViewmodelPlayerModel, 319, BANNER_DURATION_FIX_FLOAT);
		//do not save this.
		i_StickyAccessoryLogicItem[client] = EntIndexToEntRef(ViewmodelPlayerModel);
	}
	
	//RESET ALL CUSTOM VALUES! I DONT WANT TO KEEP USING ATTRIBS.
	SetAbilitySlotCount(client, 0);
	/*
	bool Was_phasing = false;
	
	if(b_PhaseThroughBuildingsPerma[client] == 2)
	{
		Was_phasing = true;
	}
	*/
	b_FaceStabber[client] = false;
	b_IsCannibal[client] = false;
	b_HasGlassBuilder[client] = false;
	b_LeftForDead[client] = false;
	b_StickyExtraGrenades[client] = false;
	b_HasMechanic[client] = false;
	b_AggreviatedSilence[client] = false;
	b_ProximityAmmo[client] = false;
	b_ExpertTrapper[client] = false;
	b_RaptureZombie[client] = false;
	b_ArmorVisualiser[client] = false;
	i_MaxSupportBuildingsLimit[client] = 0;
	b_PlayerWasAirbornKnockbackReduction[client] = false;
	BannerOnEntityCreated(client);

	if(!i_ClientHasCustomGearEquipped[client])
	{
		int count;
		bool hasPDA = false;
		bool found = false;
		bool use = true;

		int length = StoreItems.Length;
		for(int i; i < length; i++)
		{
			static ItemInfo info;
			static Item item;
			StoreItems.GetArray(i, item);
			if(item.Owned[client] && item.Equipped[client] && !item.ParentKit)
			{
				item.GetItemInfo(item.Owned[client]-1, info);

				if(info.Classname[0])
				{
					if(!StrContains(info.Classname, "tf_weapon_pda_engineer_build"))
					{
						if(hasPDA)
							continue;
						
						hasPDA = true;
					}

					Store_GiveItem(client, i, use, found);
					if(++count > 6)
					{
						SetGlobalTransTarget(client);
						PrintToChat(client, "%t", "At Weapon Limit");
						break;
					}
				}
			}
		}
	
		if(!found)
			Store_GiveItem(client, -1, use);
	}
	
	CheckMultiSlots(client);
	
//	Spawn_Buildable(client);
//	TF2_SetPlayerClass_ZR(client, TFClass_Engineer, true, false);
	/*
	if(entity > MaxClients)
	{
		TF2_SetPlayerClass_ZR(client, TFClass_Engineer);
	}
	*/

	if(Items_HasNamedItem(client, "Calmaticus' Heart Piece"))
	{
		b_NemesisHeart[client] = true;
	}
	else
	{
		b_NemesisHeart[client] = false;
	}
	if(Items_HasNamedItem(client, "Xeno Virus Vial"))
	{
		b_XenoVial[client] = true;
	}
	else
	{
		b_XenoVial[client] = false;
	}
	if(Items_HasNamedItem(client, "Overlords Final Wish"))
	{
		b_OverlordsFinalWish[client] = true;
	}
	else
	{
		b_OverlordsFinalWish[client] = false;
	}
	if(Items_HasNamedItem(client, "Bob's true fear"))
	{
		b_BobsTrueFear[client] = true;
	}
	else
	{
		b_BobsTrueFear[client] = false;
	}
	CheckSummonerUpgrades(client);
	Barracks_UpdateAllEntityUpgrades(client);
	Manual_Impulse_101(client, health);
}

void CheckInvalidSlots(int client)
{
	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		if(StoreWeapon[entity] > 0)
		{
			static Item item;
			StoreItems.GetArray(StoreWeapon[entity], item);
			if(!item.Equipped[client])
			{
				TF2_RemoveItem(client, entity);
			}
		}
	}
}

static void CheckMultiSlots(int client)
{
	ResetToZero(HasMultiInSlot[client], sizeof(HasMultiInSlot[]));

	bool exists[sizeof(HasMultiInSlot[])];
	char buffer[36];

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		GetEntityClassname(entity, buffer, sizeof(buffer));
		int slot = TF2_GetClassnameSlot(buffer);
		if(slot >= 0 && slot < sizeof(exists))
		{
			if(exists[slot])
			{
				HasMultiInSlot[client][slot] = true;
			}
			else
			{
				exists[slot] = true;
			}
		}
	}
}

void Delete_Clip(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		RequestFrame(Delete_Clip_again, ref);
		int Owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		Clip_GiveWeaponClipBack(Owner, entity);
	}
}

void Delete_Clip_again(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		int Owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		Clip_GiveWeaponClipBack(Owner, entity);
	}
}

stock void Store_RemoveNullWeapons(int client)
{
	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		if(StoreWeapon[entity] < 1)
		{
			TF2_RemoveItem(client, entity);
		}
	}
}

int Store_GiveItem(int client, int index, bool &use=false, bool &found=false)
{
	if(!StoreItems)
	{
		return -1;
	}

	int slot = -1;
	int entity = -1;
	static ItemInfo info;

	static Item item;
	int length = StoreItems.Length;

	if(index > 0 && index < length)
	{
		StoreItems.GetArray(index, item);
		if(item.Owned[client] > 0 && !item.ParentKit)	
		{
			item.GetItemInfo(item.Owned[client]-1, info);
			if(info.Classname[0])
			{
				slot = TF2_GetClassnameSlot(info.Classname);
				if(info.Weapon_Override_Slot != -1)
				{
					slot = info.Weapon_Override_Slot;
				}
				if(slot == TFWeaponSlot_Melee)
					found = true;
				
				/*if(info.SniperBugged && CurrentClass[client] == TFClass_Sniper)
				{
					CurrentClass[client] = TFClass_Soldier;
					TF2_RegeneratePlayer(client);
					return -1;
				}*/
				
				if(slot == TFWeaponSlot_Grenade)
				{
					entity = GetPlayerWeaponSlot(client, TFWeaponSlot_Grenade);
					if(entity != -1)
						TF2_RemoveItem(client, entity);
				}

				int GiveWeaponIndex = info.Index;
				if(GiveWeaponIndex > 0)
				{
					entity = SpawnWeapon(client, info.Classname, GiveWeaponIndex, 5, 6, info.Attrib, info.Value, info.Attribs, info.WeaponForceClass);	
					/*
					LogMessage("Weapon Spawned!");
					LogMessage("Name of client %N and index %i",client,client);
					LogMessage("info.Classname: %s",info.Classname);
					LogMessage("GiveWeaponIndex: %i",GiveWeaponIndex);
					char AttributePrint[255];
					for(int i=0; i<info.Attribs; i++)
					{
						Format(AttributePrint,sizeof(AttributePrint),"%s %i ;",AttributePrint, info.Attrib[i]);	
						Format(AttributePrint,sizeof(AttributePrint),"%s %.1f ;",AttributePrint, info.Value[i]);	
					}
					LogMessage("attributes: ''%s''",AttributePrint);
					LogMessage("info.Attribs: %i",info.Attribs);
					*/
				}
				else
				{
					PrintToChatAll("Somehow have an invalid GiveWeaponIndex!!!!! [%i] report to admin now!",GiveWeaponIndex);
					LogMessage("Weapon Spawned thats bad!");
					LogMessage("Name of client %N and index %i",client,client);
					LogMessage("info.Classname: %s",info.Classname);
					LogMessage("info.Attrib: %s",info.Attrib);
					LogMessage("info.Value: %s",info.Value);
					LogMessage("info.Attribs: %s",info.Attribs);
					ThrowError("Somehow have an invalid GiveWeaponIndex!!!!! [%i] info.Classname %s ",GiveWeaponIndex,info.Classname);
				}

				StoreWeapon[entity] = index;
				i_CustomWeaponEquipLogic[entity] = 0;
				i_SemiAutoWeapon[entity] = false;
				i_WeaponCannotHeadshot[entity] = false;
				i_WeaponDamageFalloff[entity] = 1.0;
				i_IsAloneWeapon[entity] = false;
				i_IsWandWeapon[entity] = false;
				i_IsWrench[entity] = false;
				i_InternalMeleeTrace[entity] = true;
				i_WeaponAmmoAdjustable[entity] = 0;
				
				if(entity > MaxClients)
				{
					if(info.CustomWeaponOnEquip != 0)
					{
						i_CustomWeaponEquipLogic[entity] = info.CustomWeaponOnEquip;
					}
					i_OverrideWeaponSlot[entity] = info.Weapon_Override_Slot;
					i_MeleeAttackFrameDelay[entity] = info.Melee_AttackDelayFrame;
					b_MeleeCanHeadshot[entity] = info.Melee_Allows_Headshots;
					
					if(info.AmmoBuyMenuOnly)
					{
						i_WeaponAmmoAdjustable[entity] = info.AmmoBuyMenuOnly;
					}
					if(info.Ammo > 0 && !CvarRPGInfiniteLevelAndAmmo.BoolValue)
					{
						if(!StrEqual(info.Classname[0], "tf_weapon_medigun"))
						{
							if(!StrEqual(info.Classname[0], "tf_weapon_particle_cannon"))
							{
								if(info.Ammo == 30)
								{
									SetEntProp(entity, Prop_Send, "m_iPrimaryAmmoType", -1);
								}
								else
								{
									b_WeaponHasNoClip[entity] = false;
									if(!info.HasNoClip)
									{
										RequestFrame(Delete_Clip, EntIndexToEntRef(entity));
										Delete_Clip(EntIndexToEntRef(entity));
									}
									else
									{
										b_WeaponHasNoClip[entity] = true;
									}
									if(info.NoHeadshot)
									{
										i_WeaponCannotHeadshot[entity] = true;
									}
									if(info.SemiAuto)
									{
										i_SemiAutoWeapon[entity] = true;
										int slot_weapon_ammo = TF2_GetClassnameSlot(info.Classname);
										
										i_SemiAutoWeapon_AmmoCount[client][slot_weapon_ammo] = 0; //Set the ammo to 0 so they cant abuse it.
										
										f_SemiAutoStats_FireRate[entity] = info.SemiAutoStats_FireRate;
										i_SemiAutoStats_MaxAmmo[entity] = info.SemiAutoStats_MaxAmmo;
										f_SemiAutoStats_ReloadTime[entity] = info.SemiAutoStats_ReloadTime;
	
									}
									if(info.Ammo) //my man broke my shit.
									{
										SetEntProp(entity, Prop_Send, "m_iPrimaryAmmoType", info.Ammo);
									}
								}
							}
						}
						//CANT USE AMMO 1 or 2 or something,
						//Allows you to switch to the weapon even though it has no ammo, there is PROOOOOOOOOOOOOOOOOOOBAABLY no weapon in the game that actually uses this
						//IF IT DOES!!! then make an exception, but as far as i know, no need.	
						/*
						if(info.Ammo) //Excluding Grenades and other chargeable stuff so you cant switch to them if they arent even ready. cus it makes no sense to have it in your hand
						{
							//It varies between 29 and 30, its better to just test it after each update
							//my guess is that the compiler optimiser from valve changes it, since its client and serverside varies
							//This allows perma switching to all weapons, even if you have 0 ammo.
							SetAmmo(client, 30, 99999);
							SetEntProp(entity, Prop_Send, "m_iSecondaryAmmoType", 30);
						}
						*/
					}
					
					if(info.IsWand > 0)
					{
						i_IsWandWeapon[entity] = info.IsWand;
					}
					if(info.IsAlone)
					{
						i_IsAloneWeapon[entity] = info.IsAlone;
					}
					if(info.IsWrench)
					{
						i_IsWrench[entity] = true;
					}
					if(!info.InternalMeleeTrace)
					{
						i_InternalMeleeTrace[entity] = false;
					}

					i_Hex_WeaponUsesTheseAbilities[entity] = 0;
		
					if(info.FuncAttack != INVALID_FUNCTION)
					{
						i_Hex_WeaponUsesTheseAbilities[entity] |= ABILITY_M1; //m1 status to weapon
					}
					if(info.FuncAttackInstant != INVALID_FUNCTION)
					{
						i_Hex_WeaponUsesTheseAbilities[entity] |= ABILITY_M1; //m1 status to weapon
					}
					if(info.FuncAttack2 != INVALID_FUNCTION)
					{
						i_Hex_WeaponUsesTheseAbilities[entity] |= ABILITY_M2; //m2 status to weapon
					}
					if(info.FuncAttack3 != INVALID_FUNCTION)
					{
						i_Hex_WeaponUsesTheseAbilities[entity] |= ABILITY_R;  //R status to weapon
					}
					
					i_WeaponArchetype[entity] 				= info.WeaponArchetype;
					i_WeaponForceClass[entity] 				= info.WeaponForceClass;
					i_WeaponSoundIndexOverride[entity] 		= info.WeaponSoundIndexOverride;
					i_WeaponModelIndexOverride[entity] 		= info.WeaponModelIndexOverride;
					Format(c_WeaponSoundOverrideString[entity],sizeof(c_WeaponSoundOverrideString[]),"%s",info.WeaponSoundOverrideString);	
					f_WeaponSizeOverride[entity]			= info.WeaponSizeOverride;
					f_WeaponSizeOverrideViewmodel[entity]	= info.WeaponSizeOverrideViewmodel;
					f_WeaponVolumeStiller[entity]				= info.WeaponVolumeStiller;
					f_WeaponVolumeSetRange[entity]				= info.WeaponVolumeRange;
					f_BackstabBossDmgPenalty[entity]		= info.BackstabDmgPentalty;
					f_ModifThirdPersonAttackspeed[entity]	= info.ThirdpersonAnimModif;
					
					i_WeaponVMTExtraSetting[entity] 			= info.WeaponVMTExtraSetting;
					i_WeaponBodygroup[entity] 				= info.Weapon_Bodygroup;

					HidePlayerWeaponModel(client, entity);

					EntityFuncAttack[entity] = info.FuncAttack;
					EntityFuncAttackInstant[entity] = info.FuncAttackInstant;
					EntityFuncAttack2[entity] = info.FuncAttack2;
					EntityFuncAttack3[entity] = info.FuncAttack3;
					EntityFuncReload4[entity]  = info.FuncReload4;
					
					b_Do_Not_Compensate[entity] 				= info.NoLagComp;
					b_Only_Compensate_CollisionBox[entity] 		= info.OnlyLagCompCollision;
					b_Only_Compensate_AwayPlayers[entity]		= info.OnlyLagCompAwayEnemy;
					b_ExtendBoundingBox[entity]		 			= info.ExtendBoundingBox;
					b_Dont_Move_Building[entity] 				= info.DontMoveBuildingComp;
					
					b_Dont_Move_Allied_Npc[entity]				= info.DontMoveAlliedNpcs;
					
					b_BlockLagCompInternal[entity] 				= info.BlockLagCompInternal;
					
				//	EntityFuncReloadSingular5[entity]  = info.FuncReloadSingular5;
					if(info.DamageFallOffForWeapon != 0.0)
					{
						i_WeaponDamageFalloff[entity] 			= info.DamageFallOffForWeapon;
					}
					f_BackstabCooldown[entity] 					= info.BackstabCD;
					f_BackstabDmgMulti[entity] 					= info.BackstabDMGMulti;
					f_BackstabHealOverThisDuration[entity] 				= info.BackstabHealOverThisTime;
					f_BackstabHealTotal[entity] 				= info.BackstabHealTotal;
					b_BackstabLaugh[entity] 					= info.BackstabLaugh;



					if (info.Reload_ModeForce == 1)
					{
					//	SetWeaponViewPunch(entity, 100.0); unused.
						SetEntProp(entity, Prop_Data, "m_bReloadsSingly", 0);
					}
					else if (info.Reload_ModeForce == 2)
					{
						SetEntProp(entity, Prop_Data, "m_bReloadsSingly", 1);
					}

					if(use)
					{
						Store_SwapToItem(client, entity);
						use = false;
					}
				}
			}
		}
	}
	else
	{
		static char Classnames[][32] = {"tf_weapon_shovel", "tf_weapon_bat", "tf_weapon_club", "tf_weapon_shovel",
		"tf_weapon_bottle", "tf_weapon_bonesaw", "tf_weapon_fists", "tf_weapon_fireaxe", "tf_weapon_knife", "tf_weapon_fireaxe" };
		
		entity = CreateEntityByName(Classnames[CurrentClass[client]]);

		if(entity > MaxClients)
		{
			static const int Indexes[] = { 6, 0, 3, 6, 1, 8, 5, 2, 4, 6 };
			SetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex", Indexes[CurrentClass[client]]);

			SetEntProp(entity, Prop_Send, "m_bInitialized", 1);
			
			SetEntProp(entity, Prop_Send, "m_iEntityQuality", 0);
			SetEntProp(entity, Prop_Send, "m_iEntityLevel", 1);
			
			GetEntityNetClass(entity, Classnames[0], sizeof(Classnames[]));
			int offset = FindSendPropInfo(Classnames[0], "m_iItemIDHigh");

			HidePlayerWeaponModel(client, entity);
			//hide original model
			
			SetEntData(entity, offset - 8, 0);	// m_iItemID
			SetEntData(entity, offset - 4, 0);	// m_iItemID
			SetEntData(entity, offset, 0);		// m_iItemIDHigh
			SetEntData(entity, offset + 4, 0);	// m_iItemIDLow
			
			DispatchSpawn(entity);
			SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", true);
			SetEntProp(entity, Prop_Send, "m_iAccountID", GetSteamAccountID(client, false));
			i_InternalMeleeTrace[entity] = true;

			Attributes_Set(entity, 1, 0.623);
		//	Attributes_Set(entity, 124, 1.0); //Mini sentry
			
			if(CurrentClass[client] != TFClass_Spy)
				Attributes_Set(entity, 15, 0.0);
			
			if(CurrentClass[client] == TFClass_Engineer)
			{
				Attributes_Set(entity, 93, 0.0);
				Attributes_Set(entity, 95, 0.0);
			}

			Attributes_Set(entity, 263, 0.0);
			Attributes_Set(entity, 264, 0.0);
			EquipPlayerWeapon(client, entity);

			if(use)
			{
				Store_SwapToItem(client, entity);
				use = false;
			}
		}
	}
	
	bool EntityIsAWeapon = false;
	if(entity > MaxClients)
	{
		EntityIsAWeapon = true;
	}
	if(EntityIsAWeapon)
	{
		Panic_Attack[entity] = 0.0;
		i_GlitchedGun[entity] = 0;
		i_SurvivalKnifeCount[client] = 0;
		i_AresenalTrap[entity] = 0;
		i_ArsenalBombImplanter[entity] = 0;
		i_NoBonusRange[entity] = 0;
		i_BuffBannerPassively[entity] = 0;
	}

	if(!TeutonType[client] && !i_ClientHasCustomGearEquipped[client])
	{
		i_MaxSupportBuildingsLimit[client] = 0;
		for(int i; i<length; i++)
		{
			StoreItems.GetArray(i, item);
			if(item.Owned[client] && item.Equipped[client] && !item.ParentKit)
			{
				item.GetItemInfo(item.Owned[client]-1, info);
				if(!info.Classname[0])
				{
					if(info.Attack3AbilitySlot != 0)
					{
						SetAbilitySlotCount(client, info.Attack3AbilitySlot);
					}
					if(info.SpecialAdditionViaNonAttribute == 2) //stabbb
					{
						b_FaceStabber[client] = true;
					}
					if(info.SpecialAdditionViaNonAttribute == 3) //eated it all
					{
						b_IsCannibal[client] = true;
					}
					if(info.SpecialAdditionViaNonAttribute == 4) //Glass Builder
					{
						b_HasGlassBuilder[client] = true;
					}
					if(info.SpecialAdditionViaNonAttribute == 5) //Left For Dead
					{
						b_LeftForDead[client] = true;
					}
					if(info.SpecialAdditionViaNonAttribute == 6) //Sticky Support Grenades
					{
						b_StickyExtraGrenades[client] = true;
					}
					if(info.SpecialAdditionViaNonAttribute == 7) //Mechanic
					{
						b_HasMechanic[client] = true;
					}
					if(info.SpecialAdditionViaNonAttribute == 8)
					{
						i_MaxSupportBuildingsLimit[client] += info.SpecialAdditionViaNonAttributeInfo;
					}
					if(info.SpecialAdditionViaNonAttribute == 9)
					{
						b_AggreviatedSilence[client] = true;
					}
					if(info.SpecialAdditionViaNonAttribute == 10)
					{
						b_ProximityAmmo[client] = true;
					}
					if(info.SpecialAdditionViaNonAttribute == 11)
					{
						b_ExpertTrapper[client] = true;
					}
					if(info.SpecialAdditionViaNonAttribute == 12)
					{
						b_RaptureZombie[client] = true;
					}
					if(info.SpecialAdditionViaNonAttribute == 13)
					{
						b_ArmorVisualiser[client] = true;
					}

					if(EntityIsAWeapon)
					{
						bool apply = CheckEntitySlotIndex(info.Index, slot, entity);
						
						if(apply)
						{
							for(int a; a<info.Attribs; a++)
							{
								bool ignore_rest = false;
								if(!Attributes_Has(entity, info.Attrib[a]))
								{
									if(info.SpecialAttribRules == 1)
									{
										ignore_rest = true;
									}
									else
									{
										Attributes_Set(entity, info.Attrib[a], info.Value[a]);
									}
								}
								else if(!ignore_rest && TF2Econ_GetAttributeDefinitionString(info.Attrib[a], "description_format", info.Classname, sizeof(info.Classname)) && StrContains(info.Classname, "additive")!=-1)
								{
									Attributes_SetAdd(entity, info.Attrib[a], info.Value[a]);
								}
								else if(!ignore_rest)
								{
									Attributes_SetMulti(entity, info.Attrib[a], info.Value[a]);
								}
							}
						}

						apply = CheckEntitySlotIndex(info.Index2, slot, entity);
						
						if(apply)
						{
							for(int a; a<info.Attribs2; a++)
							{
								bool ignore_rest = false;
								if(!Attributes_Has(entity, info.Attrib2[a]))
								{
									if(info.SpecialAttribRules_2 == 1)
									{
										ignore_rest = true;
									}
									else
									{
										Attributes_Set(entity, info.Attrib2[a], info.Value2[a]);
									}
								}
								else if(!ignore_rest && TF2Econ_GetAttributeDefinitionString(info.Attrib2[a], "description_format", info.Classname, sizeof(info.Classname)) && StrContains(info.Classname, "additive")!=-1)
								{
									Attributes_SetAdd(entity, info.Attrib2[a], info.Value2[a]);
								}
								else if(!ignore_rest)
								{
									Attributes_SetMulti(entity, info.Attrib2[a], info.Value2[a]);
								}
							}
						}
					}
				}
			}
		}
	}

	if(EntityIsAWeapon)
	{
		//SPEED COLA!
		if(i_CurrentEquippedPerk[client] == 4)
		{
			//dont give it if it doesnt have it.
			if(Attributes_Has(entity, 97))
				Attributes_SetMulti(entity, 97, 0.7);
		}

		//DOUBLE TAP!
		if(i_CurrentEquippedPerk[client] == 3)
		{
			if(Attributes_Has(entity, 6))
				Attributes_SetMulti(entity, 6, 0.85);
		}

		//DEADSHOT!
		if(i_CurrentEquippedPerk[client] == 5)
		{	
			//dont give it if it doesnt have it.
			if(Attributes_Has(entity, 103))
				Attributes_SetMulti(entity, 103, 1.2);
				
			if(Attributes_Has(entity, 106))
				Attributes_SetMulti(entity, 106, 0.8);
		}

		//QUICK REVIVE!
		if(i_CurrentEquippedPerk[client] == 1)
		{
			//do not set it, if the weapon does not have this attribute, otherwise it doesnt do anything.
			if(Attributes_Has(entity, 8))
			{
				Attributes_SetMulti(entity, 8, 1.15);
			}
			
			if(Attributes_Has(client, 8)) //set it for client too if existant.
			{
				Attributes_SetMulti(client, 8, 1.15);
			}

			// Note: This can stack with multi weapons :|
			//double note: doesnt matter, it wont multiply, i coded specifically for that reason with mediguns!
		}

		int itemdefindex = GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
		if(itemdefindex == 772 || itemdefindex == 349 || itemdefindex == 30667 || itemdefindex == 200 || itemdefindex == 45 || itemdefindex == 449 || itemdefindex == 773 || itemdefindex == 973 || itemdefindex == 1103 || itemdefindex == 669 || i_IsWandWeapon[entity])
		{
			Attributes_Set(entity, 49, 1.0);
		}

		Rogue_GiveItem(client, entity);

		/*
			Attributes to Arrays Here
		*/
		Panic_Attack[entity] = Attributes_Get(entity, 651, 0.0);
		i_SurvivalKnifeCount[entity] = RoundToNearest(Attributes_Get(entity, 33, 0.0));
		i_GlitchedGun[entity] = RoundToNearest(Attributes_Get(entity, 731, 0.0));
		i_AresenalTrap[entity] = RoundToNearest(Attributes_Get(entity, 719, 0.0));
		i_ArsenalBombImplanter[entity] = RoundToNearest(Attributes_Get(entity, 544, 0.0));
		i_NoBonusRange[entity] = RoundToNearest(Attributes_Get(entity, 410, 0.0));
		i_BuffBannerPassively[entity] = RoundToNearest(Attributes_Get(entity, 786, 0.0));
		
		i_LowTeslarStaff[entity] = RoundToNearest(Attributes_Get(entity, 3002, 0.0));
		i_HighTeslarStaff[entity] = RoundToNearest(Attributes_Get(entity, 3000, 0.0));
		
		Enable_Management_Knife(client, entity);
		Enable_Arsenal(client, entity);
		On_Glitched_Give(client, entity);
		Enable_Management_Banner(client, entity);		//Buffbanner
		Enable_Management_Banner_1(client, entity);		//Buffbanner PAP
		Enable_Management_Banner_2(client, entity); 	//Battilons
		Enable_Management_Banner_3(client, entity); 	//Ancient Banner
		
		Enable_StarShooter(client, entity);
		Enable_Passanger(client, entity);
		Enable_MG42(client, entity);
		Reset_stats_Irene_Singular_Weapon(entity);
		Reset_stats_MG42_Singular_Weapon(entity);
		Activate_Beam_Wand_Pap(client, entity);
		Activate_Yamato(client, entity);
		Activate_Fantasy_Blade(client, entity);
		Activate_Quincy_Bow(client, entity);
		Enable_Irene(client, entity);
		Enable_LappLand(client, entity);
		Enable_PHLOG(client, entity);
		Enable_OceanSong(client, entity);
		Enable_SpecterAlter(client, entity);
		Enable_WeaponArk(client, entity);
		Saga_Enable(client, entity);
//		Enable_WeaponBoard(client, entity);
		Enable_Casino(client, entity);
		Enable_Ludo(client, entity);
		Enable_Rapier(client, entity);
		Enable_Mlynar(client, entity);
		Enable_Obuch(client, entity);
		Enable_Judge(client, entity);
		Enable_SpikeLayer(client, entity);
		Enable_SensalWeapon(client, entity);
		Enable_FusionWeapon(client, entity);
//		Enable_Blemishine(client, entity);
		Gladiia_Enable(client, entity);
		Vampire_KnifesDmgMulti(client, entity);
		Activate_Neuvellete(client, entity);
		SeaMelee_Enable(client, entity);
		Enable_Leper(client, entity);
		Flagellant_Enable(client, entity);
		Enable_Impact_Lance(client, entity);
		Enable_Trash_Cannon(client, entity);
		Enable_Rusty_Rifle(client, entity);
		Enable_Blitzkrieg_Kit(client, entity);
		Enable_Quibai(client, entity);
		AngelicShotgun_Enable(client, entity);
		Enable_RedBladeWeapon(client, entity);
		Enable_Gravaton_Wand(client, entity);
		Enable_Dimension_Wand(client, entity);
		Enable_Management_Hell_Hoe(client, entity);
		Enable_Management_GrenadeHud(client, entity);
		Enable_Kahml_Fist_Ability(client, entity);
		Enable_HHH_Axe_Ability(client, entity);
		Enable_Messenger_Launcher_Ability(client, entity);
		WeaponNailgun_Enable(client, entity);
		Blacksmith_Enable(client, entity);
		Enable_West_Weapon(client, entity);
		Enable_Victorian_Launcher(client, entity);
		//Activate_Cosmic_Weapons(client, entity);
		Merchant_Enable(client, entity);
	}
	return entity;
}

int Store_GiveSpecificItem(int client, const char[] name)
{
	static Item item;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		if(StrEqual(name, item.Name, false))
		{
			Store_EquipSlotCheck(client, item);

			static ItemInfo info;
			item.GetItemInfo(0, info);
			
			item.Owned[client] = 1;
			item.Equipped[client] = true;
			item.Sell[client] = 0;
			item.BuyWave[client] = -1;
			StoreItems.SetArray(i, item);
			
			int entity = Store_GiveItem(client, i, item.Equipped[client]);
			CheckMultiSlots(client);
			return entity;
		}
	}
	
	ThrowError("Unknown item name %s", name);
	return -1;
}

void Store_RemoveSpecificItem(int client, const char[] name)
{
	if(!StoreItems)
		return;
	
	static Item item;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		if(StrEqual(name, item.Name, false))
		{
			static ItemInfo info;
			item.GetItemInfo(0, info);
			
			item.Owned[client] = 0;
			item.Equipped[client] = false;
			StoreItems.SetArray(i, item);
			
		//	int entity = Store_GiveItem(client, i, item.Equipped[client]);
			CheckMultiSlots(client);
			return;
		}
	}
}

stock void Store_ConsumeItem(int client, int index)
{
	static Item item;
	StoreItems.GetArray(index, item);
	item.Owned[client] = 0;
	item.Equipped[client] = false;
	StoreItems.SetArray(index, item);
	
	if(item.ParentKit)
	{
		int length = StoreItems.Length;
		for(int i; i < length; i++)
		{
			StoreItems.GetArray(i, item);
			if(item.Section == index)
			{
				item.Owned[client] = 0;
				item.Equipped[client] = false;
				StoreItems.SetArray(i, item);
			}
		}
	}
}

stock void Store_Unequip(int client, int index)
{
	static Item item;
	StoreItems.GetArray(index, item);
	
	ItemInfo info;
	if(item.GetItemInfo(0, info) && info.Cost <= 0)
		item.Owned[client] = 0;
	
	item.Equipped[client] = false;

	StoreItems.SetArray(index, item);

	if(item.ParentKit)
	{
		int length = StoreItems.Length;
		for(int i; i < length; i++)
		{
			StoreItems.GetArray(i, item);
			if(item.Section == index)
			{
				item.Owned[client] = 0;
				item.Equipped[client] = false;
				StoreItems.SetArray(i, item);
			}
		}
	}
}

bool Store_PrintLevelItems(int client, int level)
{
	bool found;
	Item item;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		if(item.Level == level)
		{
			static ItemInfo info;
			item.GetItemInfo(0, info);
			PrintToChat(client, TranslateItemName(client, item.Name, info.Custom_Name));
			found = true;
		}
	}
	return found;
}

char[] TranslateItemName(int client, const char name[64], const char Custom_Name[64]) //Just make it 0 as a default so if its not used, fuck it
{
	//static int ServerLang = -1;
	//if(ServerLang == -1)
	//	ServerLang = GetServerLanguage();
	
	char buffer[64];

	//if(GetClientLanguage(client) != ServerLang)
	{
		if(Custom_Name[0])
		{
			if(TranslationPhraseExists(Custom_Name))
			{
				FormatEx(buffer, sizeof(buffer), "%T", Custom_Name, client);
			}
			else
			{
				return Custom_Name;
			}
		}
		else
		{
			if(TranslationPhraseExists(name))
			{
				FormatEx(buffer, sizeof(buffer), "%T", name, client);
			}
			else
			{
				return name;
			}
		}
	}
	/*else
	{	
		if(Custom_Name[0])
		{
			FormatEx(buffer, sizeof(buffer), "%s", Custom_Name, client);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%s", name, client);
		}
	}*/
	return buffer;
}

char[] TranslateItemDescription(int client, const char Desc[256], const char Rogue_Desc[256])
{
	static int ServerLang = -1;
	if(ServerLang == -1)
		ServerLang = GetServerLanguage();
	
	char buffer[256]; 

	if(Rogue_Mode() && Rogue_Desc[0])
	{
		if(TranslationPhraseExists(Desc))
		{
			FormatEx(buffer, sizeof(buffer), "%T", Rogue_Desc, client);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%s", Rogue_Desc, client);
		}
	}
	else
	{
		if(TranslationPhraseExists(Desc))
		{
			FormatEx(buffer, sizeof(buffer), "%T", Desc, client);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%s", Desc, client);
		}
	}

	return buffer;
}

static void ItemCost(int client, Item item, int &cost)
{
	bool Setup = !Waves_Started() || (!Rogue_NoDiscount() && Waves_InSetup());
	bool GregSale = false;

	//these should account for selling.
	int scaled = item.Scaled[client];
	if(scaled > item.MaxScaled)
		scaled = item.MaxScaled;
	
	cost += item.Scale * scaled; 
	cost += item.CostPerWave * Rogue_GetRoundScale();
	
	//int original_cost_With_Sell = RoundToCeil(float(cost) * SELL_AMOUNT);
	
	//make sure anything thats additive is on the top, so sales actually help!!
	if(IsValidEntity(EntRefToEntIndex(SalesmanAlive)))
	{
		if(b_SpecialGrigoriStore) //during maps where he alaways sells, always sell!
		{
			if(Rogue_Mode())
			{
				if(item.NPCSeller_WaveStart > 0)
				{
					cost = RoundToCeil(float(cost) * 0.8);
				}
				else if(item.NPCSeller_First)
				{
					cost = RoundToCeil(float(cost) * 0.9);
				}
			}
			else if(item.NPCSeller_WaveStart > 0)
			{
				cost = RoundToCeil(float(cost) * 0.7);
			}
			else if(item.NPCSeller_First)
			{
				cost = RoundToCeil(float(cost) * 0.7);
			}
			else if(item.NPCSeller)
			{
				cost = RoundToCeil(float(cost) * 0.8);
			}
			
			if(item.NPCSeller)
				GregSale = true;
		}
	}
	
	if(Setup && !GregSale)
	{
		if(Rogue_Mode() && !Rogue_Started())
		{
			cost = RoundToCeil(float(cost) * 0.35);
		}
		else if(!Rogue_Mode() && CurrentRound < 2)//extra preround discount
		{
			if(StartCash < 750 && (!item.ParentKit || cost <= 1000)) //give super discount for normal waves
			{
				cost = RoundToCeil(float(cost) * 0.35);
			}
			else //keep normal discount for waves that have other starting cash.
			{
				cost = RoundToCeil(float(cost) * 0.7);
			}
		}
		else
		{
			cost = RoundToCeil(float(cost) * 0.9);
		}
	}
	
	if(!Rogue_Mode() && (CurrentRound != 0 || CurrentWave != -1) && cost)
	{
		switch(CurrentPlayers)
		{
			case 0:
				CheckAlivePlayers();
			
			case 1:
				cost = RoundToNearest(float(cost) * 0.7);
			
			case 2:
				cost = RoundToNearest(float(cost) * 0.8);
			
			case 3:
				cost = RoundToNearest(float(cost) * 0.9);
		}
	}
	
	//Keep this here, both of these make sure that the item doesnt go into infinite cost, and so it doesnt go below the sell value, no inf money bug!
	if(item.MaxCost > 0 && cost > item.MaxCost)
	{
		cost = item.MaxCost;
	}

	if(Rogue_Mode())
	{
		Rogue_Curse_StorePriceMulti(cost, (item.NPCSeller_WaveStart > 0 || item.NPCSeller_First || item.NPCSeller));
	}
}

static int ItemSell(int base, int discount)
{
	float cost = float(base);
	float ratio = (float(discount) / cost);
	if(ratio > SELL_AMOUNT)
	{
		ratio = SELL_AMOUNT;
	}
	else if(ratio < 0.0)
	{
		return 0;
	}

	return RoundToCeil(cost * ratio);
}

static stock void ItemCostPap(int client, const Item item, const ItemInfo info, int &cost)
{
	if(Rogue_Mode())
		Rogue_Curse_PackPriceMulti(cost);
}

bool Store_Girogi_Interact(int client, int entity, const char[] classname, bool Is_Reload_Button = false)
{
	if(Is_Reload_Button)
	{
		if(IsValidEntity(entity))
		{
			if(StrEqual(classname, "zr_base_npc"))
			{
				static char buffer[36];
				GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
				if(StrEqual(buffer, "zr_grigori"))
				{
					if(Waves_InSetup() || b_SpecialGrigoriStore)
					{
						Store_OpenNPCStore(client);
					}
					else
					{
						PrintHintText(client,"%t", "Father Grigori No Talk");
					}
					return true;
				}
			}
		}
	}
	return false;
	
}



void GiveCredits(int client, int credits, bool building)
{
	if(building && GameRules_GetRoundState() == RoundState_BetweenRounds && StartCash < 750)
	{
		if(!CashSpentGivePostSetupWarning[client])
		{
			SetGlobalTransTarget(client);
			PrintToChat(client,"%t","Pre Setup Cash Gain Hint");
			CashSpentGivePostSetupWarning[client] = true;
		}
		int CreditsGive = credits / 2;
		CashSpentGivePostSetup[client] += CreditsGive;
		CashSpent[client] -= CreditsGive;
		CashRecievedNonWave[client] += CreditsGive;
	}
	else
	{
		CashSpent[client] -= credits;
		CashRecievedNonWave[client] += credits;
	}
}

void GrantCreditsBack(int client)
{
	CashRecievedNonWave[client] += CashSpentGivePostSetup[client];
	CashSpent[client] -= CashSpentGivePostSetup[client];
	CashSpentGivePostSetup[client] = 0;
	CashSpentGivePostSetupWarning[client] = false;
}

void Clip_SaveAllWeaponsClipSizes(int client)
{
	int iea, weapon;
	while(TF2_GetItem(client, weapon, iea))
	{
		ClipSaveSingle(client, weapon);
	}
}
void ClipSaveSingle(int client, int weapon)
{
	static Item item;
	if(StoreWeapon[weapon] < 1)
	{
		return;
	}

	StoreItems.GetArray(StoreWeapon[weapon], item);
	if(item.CurrentClipSaved[client] == -5)
	{
		item.CurrentClipSaved[client] = 0;
	}
	else
	{
		int iAmmoTable = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
		int GetClip = GetEntData(weapon, iAmmoTable, 4);
		item.CurrentClipSaved[client] = GetClip;
	}
	StoreItems.SetArray(StoreWeapon[weapon], item);
}

void Clip_GiveAllWeaponsClipSizes(int client)
{
	
	int iea, weapon;
	while(TF2_GetItem(client, weapon, iea))
	{
		Clip_GiveWeaponClipBack(client, weapon);
	}
}

void Clip_GiveWeaponClipBack(int client, int weapon)
{
	if(StoreWeapon[weapon] < 1)
		return;

	if(client < 1)
		return;
	
	static Item item;
	StoreItems.GetArray(StoreWeapon[weapon], item);
	
	if(!item.Owned[client])
		return;

	ItemInfo info;
	if(item.GetItemInfo(item.Owned[client]-1, info))
	{
		if(info.HasNoClip)
		{
			return;
		}
	}
	int iAmmoTable = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
	
	SetEntData(weapon, iAmmoTable, item.CurrentClipSaved[client]);

	SetEntProp(weapon, Prop_Send, "m_iClip1", item.CurrentClipSaved[client]); // weapon clip amount bullets
}

void Store_TryRefreshMenu(int client)
{
	if(LastStoreMenu[client] && LastStoreMenu_Store[client] && (LastStoreMenu[client] + 0.5) < GetGameTime())
	{
		MenuPage(client, CurrentMenuItem[client]);
	}
}

bool DisplayMenuAtCustom(Menu menu, int client, int item)
{
	int count = menu.ItemCount;
	int base = (item / 7 * 7);
	char data[16], buffer[64];
	bool next = count > (base + 6);
	int info;

	// Add a newline to the item before Back/Previous
	if(menu.GetItem(base + 6, data, sizeof(data), info, buffer, sizeof(buffer)))
	{
		StrCat(buffer, sizeof(buffer), "\n ");
		if(menu.InsertItem(base + 6, data, buffer, info))
			menu.RemoveItem(base + 7);
	}

	if(base > 0)
	{
		FormatEx(buffer, sizeof(buffer), "%t", "Previous");

		int pos = base + 7;
		if(count > pos)
		{
			menu.InsertItem(pos, "_previous", buffer);
			count++;
		}
		else
		{
			while(count < pos)
			{
				menu.AddItem("_previous", buffer, ITEMDRAW_SPACER);
				count++;
			}

			menu.AddItem("_previous", buffer);
			count++;
		}
	}
	else if(menu.ExitBackButton)
	{
		FormatEx(buffer, sizeof(buffer), "%t", "Back");

		int pos = base + 7;
		if(count > pos)
		{
			menu.InsertItem(pos, "_back", buffer);
			count++;
		}
		else
		{
			while(count < pos)
			{
				menu.AddItem("_back", buffer, ITEMDRAW_SPACER);
				count++;
			}

			menu.AddItem("_back", buffer);
			count++;
		}
	}

	if(next)
	{
		FormatEx(buffer, sizeof(buffer), "%t", "Next");

		int pos = base + 8;
		if(count > pos)
		{
			menu.InsertItem(pos, "_next", buffer);
			count++;
		}
		else
		{
			while(count < pos)
			{
				menu.AddItem("_next", buffer, ITEMDRAW_SPACER);
				count++;
			}

			menu.AddItem("_next", buffer);
			count++;
		}
	}

	FormatEx(buffer, sizeof(buffer), "%t", "Exit");

	int pos = base + 9;
	if(count > pos)
	{
		menu.InsertItem(pos, "_exit", buffer);
	}
	else
	{
		while(count < pos)
		{
			menu.AddItem("_exit", buffer, ITEMDRAW_SPACER);
			count++;
		}

		menu.AddItem("_exit", buffer);
	}

	// DisplayAt is bad :(
	for(int i; i < base; i++)
	{
		menu.RemoveItem(0);
	}

	menu.Pagination = 0;
	menu.ExitButton = false;
	menu.ExitBackButton = false;
	return menu.Display(client, MENU_TIME_FOREVER);
	//return menu.DisplayAt(client, base, MENU_TIME_FOREVER);
}

bool Store_CheckEntitySlotIndex(int index, int entity)
{
	char classname[64];
	GetEntityClassname(entity, classname, sizeof(classname));
	int slot = TF2_GetClassnameSlot(classname);
	return CheckEntitySlotIndex(index, slot, entity);
}

static bool CheckEntitySlotIndex(int index, int slot, int entity)
{
	switch(index)
	{
		case 0, 1, 2:
		{
			if(i_IsAloneWeapon[entity])
				return false;
			
			if(index == slot && !i_IsWandWeapon[entity] && !i_IsWrench[entity])
				return true;
		}
		case 6:
		{
			if(i_IsAloneWeapon[entity])
				return false;
			
			if(slot == TFWeaponSlot_Secondary || (slot == TFWeaponSlot_Melee && !i_IsWandWeapon[entity] && !i_IsWrench[entity]))
				return true;
		}
		case 7:
		{
			if(i_IsAloneWeapon[entity])
				return false;
			
			if(slot == TFWeaponSlot_Primary || slot == TFWeaponSlot_Secondary)
				return true;
		}
		case 8:
		{
			if(i_IsAloneWeapon[entity])
				return false;
			
			if(i_IsWandWeapon[entity])
				return true;
		}
		case 9:
		{
			if(i_IsAloneWeapon[entity])
				return false;
			
			if(slot == TFWeaponSlot_Secondary || (slot == TFWeaponSlot_Melee && !i_IsWandWeapon[entity]))
				return true;
		}
		case 10:
		{
			return true;
		}
	}

	return false;
}


void ResetStoreMenuLogic(int client)
{
	LastStoreMenu[client] = 0.0;
}

void SetStoreMenuLogic(int client, bool store = true)
{
	RequestFrame(SetStoreMenuLogicDelay, client);
	LastStoreMenu[client] = GetGameTime();
	LastStoreMenu_Store[client] = store;
}

void SetStoreMenuLogicDelay(int client)
{
	LastStoreMenu[client] = GetGameTime();
}