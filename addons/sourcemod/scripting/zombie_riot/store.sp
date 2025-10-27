#pragma semicolon 1
#pragma newdecls required

#define SELL_AMOUNT 0.9
bool PapPreviewMode[MAXPLAYERS];

enum
{
	PAP_DESC_BOUGHT,
	PAP_DESC_PREVIEW
}


enum struct ItemInfo
{
	int Cost;
	int Cost_Unlock;
	char Desc[256];
	char Rogue_Desc[256];
	char ExtraDesc[256];
	char ExtraDesc_1[256];
	
	bool HasNoClip;
	bool NoSafeClip;
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
	bool Visible_BuildingStats;
	bool IsSupport;
	bool IsAlone;
	bool InternalMeleeTrace;
	
	char Classname[36];
	char Custom_Name[64];

	int Index;
	int Attrib[32];
	float Value[32];
	int Attribs;

	int Index2;
	int Attrib2[32];
	float Value2[32];
	int Attribs2;

	int Ammo;
	int AmmoBuyMenuOnly;
	
	int Reload_ModeForce;
	float Backwards_Walk_Penalty;

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
//	char WeaponSoundOverrideString[255];
	char WeaponHudExtra[16];
	float ThirdpersonAnimModif;
	int WeaponVMTExtraSetting;
	int Weapon_Bodygroup;
	int Weapon_FakeIndex;
	float WeaponVolumeStiller;
	float WeaponVolumeRange;
	
	int Attack3AbilitySlot;
	bool VisualDescOnly;
	
	int SpecialAdditionViaNonAttribute; //better then spamming attribs.
	int SpecialAdditionViaNonAttributeInfo; //better then spamming attribs.

	int SpecialAttribRules;
	int SpecialAttribRules_2;

	int WeaponArchetype;
	int WeaponFaction1;
	int WeaponFaction2;
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

		Format(buffer, sizeof(buffer), "%sbackwards_walk_penalty", prefix);
		this.Backwards_Walk_Penalty		= kv.GetFloat(buffer, 0.7);

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
		
		Format(buffer, sizeof(buffer), "%sno_safeclip", prefix);
		this.NoSafeClip				= view_as<bool>(kv.GetNum(buffer));
		
		Format(buffer, sizeof(buffer), "%ssemi_auto", prefix);
		this.SemiAuto				= view_as<bool>(kv.GetNum(buffer));
		
		Format(buffer, sizeof(buffer), "%sno_headshot", prefix);
		this.NoHeadshot				= view_as<bool>(kv.GetNum(buffer));

		Format(buffer, sizeof(buffer), "%sis_a_wand", prefix);
		this.IsWand	= view_as<int>(kv.GetNum(buffer));

		Format(buffer, sizeof(buffer), "%sis_a_wrench", prefix);
		this.IsWrench	= view_as<bool>(kv.GetNum(buffer));

		Format(buffer, sizeof(buffer), "%svisible_building_stats", prefix);
		this.Visible_BuildingStats	= view_as<bool>(kv.GetNum(buffer));

		Format(buffer, sizeof(buffer), "%sis_a_support", prefix);
		this.IsSupport	= view_as<bool>(kv.GetNum(buffer));

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

	//	Format(buffer, sizeof(buffer), "%ssound_weapon_override_string", prefix);
	//	kv.GetString(buffer, this.WeaponSoundOverrideString, sizeof(buffer));

		Format(buffer, sizeof(buffer), "%smodel_weapon_override", prefix);
		kv.GetString(buffer, this.WeaponModelOverride, sizeof(buffer));

		Format(buffer, sizeof(buffer), "%sweapon_hud_extra", prefix);
		kv.GetString(buffer, this.WeaponHudExtra, sizeof(buffer));
		
		Format(buffer, sizeof(buffer), "%sweapon_vmt_setting", prefix);
		this.WeaponVMTExtraSetting	= view_as<bool>(kv.GetNum(buffer, -1));

		Format(buffer, sizeof(buffer), "%sweapon_bodygroup", prefix);
		this.Weapon_Bodygroup	= kv.GetNum(buffer, -1);

		Format(buffer, sizeof(buffer), "%sweapon_fakeindex", prefix);
		this.Weapon_FakeIndex	= kv.GetNum(buffer, -1);

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
		
		static char buffers[64][16];
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

		Format(buffer, sizeof(buffer), "%sweapon_faction", prefix);
		this.WeaponFaction1 = kv.GetNum(buffer);

		Format(buffer, sizeof(buffer), "%sweapon_faction2", prefix);
		this.WeaponFaction2 = kv.GetNum(buffer);

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
	bool Starter;
	bool ParentKit;
	bool ChildKit;
	bool MaxBarricadesBuild;
	bool Hidden;
	bool WhiteOut;
	bool IgnoreSlots;
	char Tags[256];
	char Author[128];
	bool NoKit;
	bool ForceAllowWithKit; //For wrenches.
	
	ArrayList ItemInfos;
	
	int Owned[MAXPLAYERS];
	int Scaled[MAXPLAYERS];
	bool Equipped[MAXPLAYERS];
	int Sell[MAXPLAYERS];
	int BuyWave[MAXPLAYERS];
	int BuyPrice[MAXPLAYERS];
	float Cooldown1[MAXPLAYERS];
	float Cooldown2[MAXPLAYERS];
	float Cooldown3[MAXPLAYERS];
	int CurrentClipSaved[MAXPLAYERS];
	bool BoughtBefore[MAXPLAYERS];
	int RogueBoughtRecently[MAXPLAYERS];
	
	bool NPCSeller;
	float NPCSeller_Discount;
	int NPCSeller_WaveStart;
	int NPCWeapon;
	bool NPCWeaponAlways;
	int GiftId;
	bool GregBlockSell;
	bool StaleCost;
	int GregOnlySell;
	bool RogueAlwaysSell;
	
	bool GetItemInfo(int index, ItemInfo info)
	{
		if(!this.ItemInfos || index >= this.ItemInfos.Length)
		{
			static ItemInfo BlankInfo;
			info = BlankInfo;
			return false;
		}
		
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
	"Potion Supply",
	"N/A",
	"N/A",
	"N/A"
};

static ArrayList StoreItems;
static int NPCOnly[MAXPLAYERS];
static int NPCCash[MAXPLAYERS];
//static int NPCTarget[MAXPLAYERS];
static bool InLoadoutMenu[MAXPLAYERS];
//static KeyValues StoreBalanceLog;
static ArrayList StoreTags;
static ArrayList ChoosenTags[MAXPLAYERS];
static bool UsingChoosenTags[MAXPLAYERS];
static int LastMenuPage[MAXPLAYERS];
static int CurrentMenuPage[MAXPLAYERS];
static int CurrentMenuItem[MAXPLAYERS];

static bool HasMultiInSlot[MAXPLAYERS][6];
static Function HolsterFunc[MAXPLAYERS] = {INVALID_FUNCTION, ...};

void Store_OnCached(int client)
{
	if(!Store_HasNamedItem(client, "ZR Contest Nominator [???] Cash"))
	{
		int amount;

		if(Items_HasNamedItem(client, "ZR Contest 2024 Top 10"))
		{
			amount = 100;
		}
		else if(Items_HasNamedItem(client, "ZR Contest 2024 Top 20"))
		{
			amount = 75;
		}
		else if(Items_HasNamedItem(client, "ZR Contest 2024 Top 30"))
		{
			amount = 50;
		}
		
		if(Items_HasNamedItem(client, "ZR Contest 2024 Artist"))
			amount += 50;
		
		amount += SkillTree_GetByName(client, "Cash Up 1") * 2;
		amount += SkillTree_GetByName(client, "Cash Up 1 Infinite") / 5;
		amount += SkillTree_GetByName(client, "Cash Up 1 High") * 20;
		amount += SkillTree_GetByName(client, "Cash Up Barney 1") * 30;

		if(amount)
		{
			Store_SetNamedItem(client, "ZR Contest Nominator [???] Cash", 1);
			//Building_GiveRewardsUse(0, client, amount);
			CashReceivedNonWave[client] += amount;
			CashSpent[client] -= amount;
			CashSpentLoadout[client] -= amount;
		}
	}

	if(Items_HasNamedItem(client, "ZR Content Creator [???]"))
	{
		if(!Store_HasNamedItem(client, "ZR Content Creator [???] Cash"))
		{
			Store_SetNamedItem(client, "ZR Content Creator [???] Cash", 1);
			//Building_GiveRewardsUse(0, client, 50);
			CashReceivedNonWave[client] += 50;
			CashSpent[client] -= 50;
			CashSpentLoadout[client] -= 50;
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

stock bool Store_ActiveCanMulti(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon != -1)
	{
		char buffer[36];
		GetEntityClassname(weapon, buffer, sizeof(buffer));
		int slot = TF2_GetClassnameSlot(buffer, weapon);
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

stock float CooldownReductionAmount(int client)
{
	float Cooldown = 1.0;
	if(MazeatItemHas())
	{
		Cooldown *= 0.66;
	}
	if(HasSpecificBuff(client, "Ziberian Flagship Weaponry"))
	{
		Cooldown *= 0.85;
	}
	if(HasSpecificBuff(client, "Dimensional Turbulence"))
	{
		Cooldown *= 0.25;
	}
	if(HasSpecificBuff(client, "Ultra Rapid Fire"))
	{
		Cooldown *= 0.6;
	}
	if(i_CurrentEquippedPerk[client] & PERK_ENERGY_DRINK)
		Cooldown *= 0.85;
		
	return Cooldown;
}

void Ability_Apply_Cooldown(int client, int what_slot, float cooldown, int thisWeapon = -1, bool ignoreCooldown = false)
{
	int weapon = thisWeapon == -1 ? GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") : thisWeapon;
	if(weapon != -1)
	{
		if(StoreWeapon[weapon] > 0)
		{
			static Item item;
			StoreItems.GetArray(StoreWeapon[weapon], item);
#if defined ZR
			if(!ignoreCooldown)
				cooldown *= CooldownReductionAmount(client);
#endif
			
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
	else
	{
		SPrintToChat(client,"%t", "Cant Display");
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

void Store_SwapToItem(int client, int swap, bool SwitchDo = true)
{
	if(swap == -1)
		return;
	
	char classname[36], buffer[36];
	GetEntityClassname(swap, classname, sizeof(classname));

	int slot = TF2_GetClassnameSlot(classname, swap);
	
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
					if(TF2_GetClassnameSlot(buffer, weapon) == slot)
					{
						SetEntPropEnt(client, Prop_Send, "m_hMyWeapons", swap, a);
						SetEntPropEnt(client, Prop_Send, "m_hMyWeapons", weapon, i);
						break;
					}
				}
			}
		}
	}
	if(SwitchDo)
		SetPlayerActiveWeapon(client, swap);
	int WeaponValidCheck = 0;

	//make sure to fake swap aswell!
	while(WeaponValidCheck != swap)
	{
		WeaponValidCheck = Store_CycleItems(client, slot);
		if(WeaponValidCheck == -1)
			break;
	}
}

void Store_SwapItems(int client, bool SwitchDo = true, int activeweaponoverride = -1)
{
	//int suit = GetEntProp(client, Prop_Send, "m_bWearingSuit");
	//if(!suit)
	//	SetEntProp(client, Prop_Send, "m_bWearingSuit", true);

	int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(activeweaponoverride != -1)
	{
		active = activeweaponoverride;
	}
	if(active > MaxClients)
	{
		char buffer[36];
		GetEntityClassname(active, buffer, sizeof(buffer));
		
		int slot = TF2_GetClassnameSlot(buffer, active);
		
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
							if(TF2_GetClassnameSlot(buffer, weapon) == slot)
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
					if(SwitchDo)
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
				if(TF2_GetClassnameSlot(buffer, weapon) == slot)
				{
					if(SwitchDo)
						SetPlayerActiveWeapon(client, weapon);
					break;
				}
			}
		}
	}

	//if(suit)
	//	SetEntProp(client, Prop_Send, "m_bWearingSuit", false);
}

// Returns the top most weapon (or -1 for no change)
int Store_CycleItems(int client, int slot, bool ChangeWeapon = true)
{
	char buffer[36];
	
	int topWeapon = -1;
	int firstWeapon = -1;
	int previousIndex = -1;
	int length = GetMaxWeapons(client);
	for(int i; i < length; i++)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
		if(weapon != -1)
		{
			GetEntityClassname(weapon, buffer, sizeof(buffer));
			if(TF2_GetClassnameSlot(buffer, weapon) == slot)
			{
				if(firstWeapon == -1)
					firstWeapon = weapon;

				if(previousIndex != -1)
				{
					// Replace this weapon with the previous slot (1 <- 2)
					if(ChangeWeapon)
						SetEntPropEnt(client, Prop_Send, "m_hMyWeapons", weapon, previousIndex);
					if(topWeapon == -1)
						topWeapon = weapon;
				}

				previousIndex = i;
			}
		}
	}

	if(firstWeapon != -1)
	{
		// First to Last (7 <- 0)
		if(ChangeWeapon)
			SetEntPropEnt(client, Prop_Send, "m_hMyWeapons", firstWeapon, previousIndex);
	}

	return topWeapon;
}

void Store_ConfigSetup()
{
	ClearAllTempAttributes();
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
	
//	delete StoreBalanceLog;
	StoreItems = new ArrayList(sizeof(Item));
	
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "weapons");
	KeyValues kv = new KeyValues("Weapons");
	kv.SetEscapeSequences(true);
	kv.ImportFromFile(buffer);
	
	char blacklist[6][32];
	zr_tagblacklist.GetString(buffer, sizeof(buffer));
	int blackcount;
	if(buffer[0])
		blackcount = ExplodeString(buffer, ",", blacklist, sizeof(blacklist), sizeof(blacklist[]));
	
	char whitelist[6][32];
	zr_tagwhitelist.GetString(buffer, sizeof(buffer));
	int whitecount;
	if(buffer[0])
		whitecount = ExplodeString(buffer, ",", whitelist, sizeof(whitelist), sizeof(whitelist[]));
	
	kv.GotoFirstSubKey();
	do
	{
		ConfigSetup(-1, kv, 0, false, false, whitelist, whitecount, blacklist, blackcount);
	} while(kv.GotoNextKey());

	delete kv;

//	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "weapons_usagelog");
//	StoreBalanceLog = new KeyValues("UsageLog");
//	StoreBalanceLog.ImportFromFile(buffer);
}

static void ConfigSetup(int section, KeyValues kv, int hiddenType, bool noKits, bool rogueSell, const char[][] whitelist, int whitecount, const char[][] blacklist, int blackcount)
{
	int cost = hiddenType == 2 ? 0 : kv.GetNum("cost", -1);
	bool isItem = cost >= 0;
	
	char buffer[128], buffers[12][32];

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
			
			if(whitecount && (item.Hidden || zr_tagwhitehard.BoolValue))
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
	item.RogueAlwaysSell = view_as<bool>(kv.GetNum("rogue_always_sell", rogueSell ? 1 : 0));
	item.NoKit = view_as<bool>(kv.GetNum("nokit", noKits ? 1 : 0));
	item.ForceAllowWithKit = view_as<bool>(kv.GetNum("forcewithkits"));
	kv.GetString("textstore", item.Name, sizeof(item.Name));
	item.GiftId = item.Name[0] ? Items_NameToId(item.Name) : -1;
	kv.GetSectionName(item.Name, sizeof(item.Name));
	item.Name[0] = CharToUpper(item.Name[0]);
	
	if(isItem)
	{
		item.Scale = kv.GetNum("scale");
		item.CostPerWave = kv.GetNum("extracost_per_wave");
		item.MaxBarricadesBuild = view_as<bool>(kv.GetNum("max_barricade_buy_logic"));
		item.MaxCost = kv.GetNum("maxcost");
		item.MaxScaled = kv.GetNum("max_times_scale");
		item.Slot = kv.GetNum("slot", -1);
		item.GregBlockSell = view_as<bool>(kv.GetNum("greg_block_sell"));
		item.StaleCost = view_as<bool>(kv.GetNum("stale_cost"));
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
					ConfigSetup(sec, kv, 2, item.NoKit, item.RogueAlwaysSell, whitelist, 0, blacklist, 0);
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
			ConfigSetup(sec, kv, item.Hidden ? 1 : 0, item.NoKit, item.RogueAlwaysSell, whitelist, whitecount, blacklist, blackcount);
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
		/*
		if(Rogue_UnlockStore())
		{
			if(item.ChildKit)
			{
				static Item parent;
				StoreItems.GetArray(item.Section, parent);

				if(!parent.NPCSeller && !parent.RogueAlwaysSell)
					return false;
			}
			else if(!item.NPCSeller && !item.RogueAlwaysSell)
			{
				return false;
			}
		}
		*/
		if(item.Owned[client])
		{
			ItemInfo info;
			if(!item.GetItemInfo(item.Owned[client] - 1, info) || info.PackBranches < 1)
				return false;

			if(!item.GetItemInfo(item.Owned[client] + info.PackSkip, info))
				return false;
			
			return view_as<bool>(info.Cost);
		}
	}
	return false;
}
void Store_PackMenu(int client, int index, int owneditemlevel = -1, int owner, bool Preview = false)
{
	if(!IsValidClient(owner))
		return;
		
	if(!IsValidClient(client))
		return;
		
	if(index > 0)
	{
		PapPreviewMode[client] = Preview;
		static Item item;
		StoreItems.GetArray(index, item);
		if(item.Owned[client] || Preview)
		{
			ItemInfo info;
			int OwnedItemIndex = item.Owned[client];
			if(Preview)
			{
				OwnedItemIndex = owneditemlevel;
			}
			if(item.GetItemInfo(OwnedItemIndex - 1, info))
			{
				int count = info.PackBranches;
				if(count > 0)
				{
					Menu menu = new Menu(Store_PackMenuH);
					CancelClientMenu(client);
					SetStoreMenuLogic(client, false);

					int cash = CurrentCash-CashSpent[client];
					if(StarterCashMode[client])
					{
						int maxCash = StartCash;
						maxCash -= CashSpentLoadout[client];
						cash = maxCash;
					}
					char buf[84];
					if(!Preview && !b_AntiLateSpawn_Allow[client])
					{
						Format(buf, sizeof(buf), "%T", "Late Join Pap Menu", client);
					}
					else if(PapPreviewMode[client])
					{
						Format(buf, sizeof(buf), "%T", "Preview Mode Pap", client);
						cash = 999999;
					}
					else if(StarterCashMode[client])
						Format(buf, sizeof(buf), "%T", "Loadout Credits",client, cash);
					else
						Format(buf, sizeof(buf), "%T", "Credits",client, cash);

					TranslateItemName(client, item.Name, info.Custom_Name, info.Custom_Name, sizeof(info.Custom_Name));
					menu.SetTitle("%T\n \n%s\n \n%s\n ", "TF2: Zombie Riot", client, buf, info.Custom_Name);
					
					int skip = info.PackSkip;
					count += skip;

					char data[64], buffer[64];
					/*
					if(count > 1)
					{
						zr_tagwhitelist.GetString(buffer, sizeof(buffer));
						if(StrContains(buffer, "realtime") != -1)
							count = 1;
					}
					What in the god damn?!
					*/
					int userid = EntIndexToEntRef(client);
					if(IsValidClient(owner))
					{
						userid = EntIndexToEntRef(owner);
					}
					char dataFirst[64];
					Format(dataFirst, sizeof(dataFirst), "%i;%i;%i", index, (OwnedItemIndex), userid);
					
					for(int i = skip; i < count; i++)
					{
						if(item.GetItemInfo(OwnedItemIndex + i, info) && info.Cost)
						{
							ItemCostPap(item, info.Cost);

//							Format(data, sizeof(data), "%d;%d;%d;%d", index, OwnedItemIndex + i, entity, userid);
							Format(data, sizeof(data), "%i;%i;%i", index, (OwnedItemIndex + i), userid);
							TranslateItemName(client, item.Name, info.Custom_Name, info.Custom_Name, sizeof(info.Custom_Name));
							Format(buffer, sizeof(buffer), "%s [$%d]", info.Custom_Name, info.Cost);
							menu.AddItem(data, buffer, cash < info.Cost ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

							if(info.Desc[0])
							{
								char DescWeapon[64];
								char DescWeaponFuse[128];
								Format(DescWeaponFuse, sizeof(DescWeaponFuse), "%s-explain-%s", dataFirst,data);
								Format(DescWeapon, sizeof(DescWeapon), "%T\n ", "Describe This Weapon", client);
								menu.AddItem(DescWeaponFuse, DescWeapon, ITEMDRAW_DEFAULT);
							}
						}
					}
					
					if(!data[0])
					{
						Format(buffer, sizeof(buffer), "%T", "Cannot Pap this", client);
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
			if(StrContains(buffer, "-explain-", false) != -1)
			{
				char valuesChar[2][64];
				ExplodeString(buffer, "-explain-", valuesChar, sizeof(valuesChar), sizeof(valuesChar[]));
				//remove explain from text.

				int values[3];
				ExplodeStringInt(valuesChar[0], ";", values, sizeof(values));

				int ValuesDisplay[3];
				ExplodeStringInt(valuesChar[1], ";", ValuesDisplay, sizeof(ValuesDisplay));
				
				static Item item;
				StoreItems.GetArray(values[0], item);
				int OwnedItemIndex = ValuesDisplay[1];

				if(OwnedItemIndex)
				{
					ItemInfo info;
					if(item.GetItemInfo(ValuesDisplay[1], info) && info.Cost)
					{ 	
						PrintPapDescription(client, item, info, PAP_DESC_PREVIEW);
					}
				}

				Store_PackMenu(client, values[0], values[1], EntRefToEntIndex(values[2]), PapPreviewMode[client]);
				return 0;
			}
			
			int values[3];
			ExplodeStringInt(buffer, ";", values, sizeof(values));
			
			static Item item;
			StoreItems.GetArray(values[0], item);
			int OwnedItemIndex = item.Owned[client];
			if(PapPreviewMode[client]) //so it atelast displays
				OwnedItemIndex = values[1];

			if(OwnedItemIndex)
			{
				int owner = -1;

				ItemInfo info;
				if(item.GetItemInfo(values[1], info) && info.Cost)
				{ 	
					ItemCostPap(item, info.Cost);
					if(PapPreviewMode[client])
					{
						//If client clicks on anything, view that pap instead.
						values[1] = values[1] + 1;
					}
					else if((CurrentCash-CashSpent[client]) >= info.Cost)
					{
						CashSpent[client] += info.Cost;
						CashSpentTotal[client] += info.Cost;
						CashSpentLoadout[client] += info.Cost;
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
						
						ShowSyncHudText(client, SyncHud_Notifaction, "Your weapon was boosted");
						PrintPapDescription(client, item, info, PAP_DESC_BOUGHT);
						
						Store_ApplyAttribs(client);
						Store_GiveAll(client, GetClientHealth(client));
						owner = EntRefToEntIndex(values[2]);
						if(IsValidClient(owner))
							Building_GiveRewardsUse(client, owner, 150, true, 4.0, true);
					}
				}
				
				Store_PackMenu(client, values[0], values[1], EntRefToEntIndex(values[2]), PapPreviewMode[client]);
			}
		}
	}
	return 0;
}

void PrintPapDescription(int client, Item item, ItemInfo info, int type = PAP_DESC_BOUGHT)
{
	//This code is ass
	TranslateItemName(client, item.Name, info.Custom_Name, info.Custom_Name, sizeof(info.Custom_Name));
	char bufferHeader[128];
	
	switch (type)
	{
		case PAP_DESC_BOUGHT:
			FormatEx(bufferHeader, sizeof(bufferHeader), "%T", "Pap Weapon Upgraded", client, info.Custom_Name);	
		
		case PAP_DESC_PREVIEW:
			FormatEx(bufferHeader, sizeof(bufferHeader), "%T", "Pap Weapon Preview", client, info.Custom_Name);
	}
	
	SPrintToChat(client, "%s", bufferHeader);
	
	char bufferSizeSplit[512];
	char DescDo[256];
	Format(DescDo, sizeof(DescDo), "%s", info.Desc);
	char DescDo2[256];
	Format(DescDo2, sizeof(DescDo2), "%s", info.Rogue_Desc);
	TranslateItemName(client, DescDo, DescDo2, bufferSizeSplit, sizeof(bufferSizeSplit));
	char Display1[240];
	char Display2[240];
	Format(Display1, sizeof(Display1), "%s", bufferSizeSplit);
	if(strlen(bufferSizeSplit) > 240) //If 240 exists, split.
	{
		Format(Display2, sizeof(Display2), "%s", bufferSizeSplit[239]);
		CPrintToChat(client, "%s%s-", STORE_COLOR ,Display1);
	}
	else
		CPrintToChat(client, "%s%s", STORE_COLOR ,Display1);

	if(Display2[0])
		CPrintToChat(client, "%s%s", STORE_COLOR ,Display2);
}

void Store_RogueEndFightReset()
{
	static Item item;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		for(int c; c<MAXPLAYERS; c++)
		{
			item.RogueBoughtRecently[c] = 0;
		}
		StoreItems.SetArray(i, item);
	}
	Ammo_Count_Ready += 5;
}

void Store_Reset()
{
	for(int c; c<MAXPLAYERS; c++)
	{
		StarterCashMode[c] = true;
		CashSpent[c] = 0;
		CashSpentTotal[c] = 0;
		CashSpentLoadout[c] = 0;
	}
	static Item item;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		item.NPCSeller = false;
		item.NPCSeller_WaveStart = 0;
		item.NPCSeller_Discount = 1.0;
		for(int c; c<MAXPLAYERS; c++)
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
	for(int c; c<MAXPLAYERS; c++)
	{
		CashSpentGivePostSetup[c] = 0;
		CashSpentGivePostSetupWarning[c] = false;
	}
//	if(StoreBalanceLog)
//	{
//		char buffer[PLATFORM_MAX_PATH];
//		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "weapons_usagelog");
//		StoreBalanceLog.ExportToFile(buffer);
//	}
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
				else if(info.Cost_Unlock > 1000 && StarterCashMode[client])
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
						CashSpentLoadout[client] += info.Cost;
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
					item.BuyWave[client] = Waves_GetRoundScale();
					if(info.NoRefundWanted)
					{
						item.BuyWave[client] = -1;
						item.Sell[client] = item.Sell[client] / 2;
					}
					if(!item.BoughtBefore[client])
					{
						item.BoughtBefore[client] = true;
					//	StoreBalanceLog.Rewind();
					//	StoreBalanceLog.SetNum(item.Name, StoreBalanceLog.GetNum(item.Name) + 1);
					}
					StoreItems.SetArray(a, item);
					return;
				}
			}
			break;
		}
	}
	
	TranslateItemName(client, name, _, item.Name, sizeof(item.Name));
	PrintToChat(client, "%t", "Could Not Buy Item", item.Name);
}

void Store_EquipSlotSuffix(int client, int slot, char[] buffer, int blength)
{
	if(slot >= 0)
	{
		int length = StoreItems.Length;
		static Item item;
		for(int i; i<length; i++)
		{
			StoreItems.GetArray(i, item);
			if(item.Equipped[client] && item.Slot == slot)
			{
				static ItemInfo info;
				item.GetItemInfo(0, info);
				Format(buffer, blength, "%s {%T%i}", buffer, "Slot ", client,item.Slot);
				break;
			}
		}
	}
}

void Store_EquipSlotCheck(int client, Item mainItem)
{
	if(mainItem.IgnoreSlots)
		return;
	
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
			
			if(!subItem.ForceAllowWithKit && !mainItem.ForceAllowWithKit)
			{
				if(mainItem.ParentKit)
				{
					if(subItem.NoKit || (!subItem.ChildKit && info.Classname[0] && TF2_GetClassnameSlot(info.Classname) <= TFWeaponSlot_Melee))
					{
						TranslateItemName(client, subItem.Name, info.Custom_Name, info.Custom_Name, sizeof(info.Custom_Name));
						PrintToChat(client, "%s was unequipped", info.Custom_Name);
						Store_Unequip(client, i);
						continue;
					}
				}
				else if(mainItem.NoKit || isWeapon)
				{
					if(subItem.ParentKit)
					{
						TranslateItemName(client, subItem.Name, info.Custom_Name, info.Custom_Name, sizeof(info.Custom_Name));
						PrintToChat(client, "%s was unequipped", info.Custom_Name);
						Store_Unequip(client, i);
						continue;
					}
				}
			}

			if(slot >= 0 && subItem.Slot == slot)
			{
				TranslateItemName(client, subItem.Name, info.Custom_Name, info.Custom_Name, sizeof(info.Custom_Name));
				PrintToChat(client, "%s was unequipped", info.Custom_Name);
				Store_Unequip(client, i);
				continue;
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
	CashSpentLoadout[client] = 0;
	StarterCashMode[client] = true;
	
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
	Menu menu2 = new Menu(Settings_MenuPage);
	menu2.SetTitle("%T", "Settings Page", client);

	Format(buffer, sizeof(buffer), "%T", "Armor Hud Setting", client);
	menu2.AddItem("-2", buffer);

	Format(buffer, sizeof(buffer), "%T", "Hurt Hud Setting", client);
	menu2.AddItem("-8", buffer);

	Format(buffer, sizeof(buffer), "%T", "Weapon Hud Setting", client);
	menu2.AddItem("-14", buffer);

	Format(buffer, sizeof(buffer), "%T", "Notif Hud Setting", client);
	menu2.AddItem("-20", buffer);

	Format(buffer, sizeof(buffer), "%T", "Zombie Volume Setting Show", client);
	menu2.AddItem("-55", buffer);


	Format(buffer, sizeof(buffer), "%T", "Low Health Shake", client);

	Format(buffer, sizeof(buffer), "%T", "Weapon Screen Shake", client);
	if(b_HudScreenShake[client])
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[X]");
	}
	else
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[ ]");
	}
	menu2.AddItem("-41", buffer);

	Format(buffer, sizeof(buffer), "%T", "Hit Marker", client);
	if(b_HudHitMarker[client])
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[X]");
	}
	else
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[ ]");
	}
	menu2.AddItem("-42", buffer);

	Format(buffer, sizeof(buffer), "%T", "Disable Map Music", client);
	if(b_IgnoreMapMusic[client])
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[X]");
	}
	else
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[ ]");
	}
	menu2.AddItem("-80", buffer);

	Format(buffer, sizeof(buffer), "%T", "Disable Ambient Music", client);
	if(b_DisableDynamicMusic[client])
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[X]");
	}
	else
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[ ]");
	}
	menu2.AddItem("-81", buffer);

	
	Format(buffer, sizeof(buffer), "%T", "Enable Ammobox Count Perma", client);
	if(b_EnableRightSideAmmoboxCount[client])
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[X]");
	}
	else
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[ ]");
	}
	menu2.AddItem("-82", buffer);

	
	Format(buffer, sizeof(buffer), "%T", "Enable Visible Downs", client);
	if(b_EnableCountedDowns[client])
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[X]");
	}
	else
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[ ]");
	}
	menu2.AddItem("-83", buffer);

	Format(buffer, sizeof(buffer), "%T", "Enable Visual Clutter", client);
	if(b_EnableClutterSetting[client])
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[X]");
	}
	else
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[ ]");
	}
	menu2.AddItem("-84", buffer);
	/*
	Format(buffer, sizeof(buffer), "%T", "Enable Numeral Armor", client);
	if(b_EnableNumeralArmor[client])
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[X]");
	}
	else
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[ ]");
	}
	menu2.AddItem("-85", buffer);
	*/

	Format(buffer, sizeof(buffer), "%T", "Taunt Speed increase", client);
	if(b_TauntSpeedIncrease[client])
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[X]");
	}
	else
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[ ]");
	}
	menu2.AddItem("-71", buffer);

	if(!zr_interactforcereload.BoolValue)
		Format(buffer, sizeof(buffer), "%T", "Interact With Reload", client);
	else
		Format(buffer, sizeof(buffer), "%T", "Interact With Spray", client);

	if(b_InteractWithReload[client])
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[X]");
	}
	else
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[ ]");
	}
	menu2.AddItem("-73", buffer);

	Format(buffer, sizeof(buffer), "%T", "Disable Setup Music", client);
	if(b_DisableSetupMusic[client])
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[X]");
	}
	else
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[ ]");
	}
	menu2.AddItem("-90", buffer);

	Format(buffer, sizeof(buffer), "%T", "Disable Status Effect Hints", client);
	if(b_DisableStatusEffectHints[client])
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[X]");
	}
	else
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[ ]");
	}
	Format(buffer, sizeof(buffer), "%T", "Disable Status Lastmann Music", client);
	if(b_LastManDisable[client])
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[X]");
	}
	else
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[ ]");
	}

	menu2.AddItem("-96", buffer);
	Format(buffer, sizeof(buffer), "%T", "DamageHud Setting", client);
	if(b_DisplayDamageHudSettingInvert[client])
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[X]");
	}
	else
	{
		Format(buffer, sizeof(buffer), "%s %s", buffer, "[ ]");
	}
	menu2.AddItem("-97", buffer);

	Format(buffer, sizeof(buffer), "%T", "Fix First Sound Play Manually", client);
	Format(buffer, sizeof(buffer), "%s", buffer);
	menu2.AddItem("-86", buffer);

	Format(buffer, sizeof(buffer), "%T", "See Tutorial Again", client);
	Format(buffer, sizeof(buffer), "%s", buffer);
	menu2.AddItem("-95", buffer);
	

	
	Format(buffer, sizeof(buffer), "%T", "Back", client);
	menu2.AddItem("-999", buffer);
	menu2.Pagination = 1;
	
	menu2.Display(client, MENU_TIME_FOREVER);
}


public void ReShowArmorHud(int client)
{
	char buffer[24];

	Menu menu2 = new Menu(Settings_MenuPage);
	menu2.SetTitle("%T", "Armor Hud Setting Inside", client,f_ArmorHudOffsetX[client],f_ArmorHudOffsetY[client]);

	Format(buffer, sizeof(buffer), "%T", "Move Hud Up", client);
	menu2.AddItem("-3", buffer);

	Format(buffer, sizeof(buffer), "%T", "Move Hud Down", client);
	menu2.AddItem("-4", buffer);

	Format(buffer, sizeof(buffer), "%T", "Move Hud Left", client);
	menu2.AddItem("-5", buffer);

	Format(buffer, sizeof(buffer), "%T", "Move Hud Right", client);
	menu2.AddItem("-6", buffer);

	Format(buffer, sizeof(buffer), "%T", "Reset to Default", client);
	menu2.AddItem("-7", buffer);
					
	Format(buffer, sizeof(buffer), "%T", "Back", client);
	menu2.AddItem("-1", buffer);

	menu2.Display(client, MENU_TIME_FOREVER);
}

public void ReShowHurtHud(int client)
{
	char buffer[24];
	

	Menu menu2 = new Menu(Settings_MenuPage);
	menu2.SetTitle("%T", "Hurt Hud Setting Inside", client,f_HurtHudOffsetX[client],f_HurtHudOffsetY[client]);

	Format(buffer, sizeof(buffer), "%T", "Move Hud Up", client);
	menu2.AddItem("-9", buffer);

	Format(buffer, sizeof(buffer), "%T", "Move Hud Down", client);
	menu2.AddItem("-10", buffer);

	Format(buffer, sizeof(buffer), "%T", "Move Hud Left", client);
	menu2.AddItem("-11", buffer);

	Format(buffer, sizeof(buffer), "%T", "Move Hud Right", client);
	menu2.AddItem("-12", buffer);

	Format(buffer, sizeof(buffer), "%T", "Reset to Default", client);
	menu2.AddItem("-13", buffer);
					
	Format(buffer, sizeof(buffer), "%T", "Back", client);
	menu2.AddItem("-1", buffer);

	menu2.Display(client, MENU_TIME_FOREVER);
	
	Calculate_And_Display_hp(client, client, 0.0, true); //Apply hud update so they know where it is now
}

public void ReShowWeaponHud(int client)
{
	char buffer[24];
	

	Menu menu2 = new Menu(Settings_MenuPage);
	menu2.SetTitle("%T", "Weapon Hud Setting Inside", client,f_WeaponHudOffsetX[client],f_WeaponHudOffsetY[client]);

	Format(buffer, sizeof(buffer), "%T", "Move Hud Up", client);
	menu2.AddItem("-15", buffer);

	Format(buffer, sizeof(buffer), "%T", "Move Hud Down", client);
	menu2.AddItem("-16", buffer);

	Format(buffer, sizeof(buffer), "%T", "Move Hud Left", client);
	menu2.AddItem("-17", buffer);

	Format(buffer, sizeof(buffer), "%T", "Move Hud Right", client);
	menu2.AddItem("-18", buffer);

	Format(buffer, sizeof(buffer), "%T", "Reset to Default", client);
	menu2.AddItem("-19", buffer);
					
	Format(buffer, sizeof(buffer), "%T", "Back", client);
	menu2.AddItem("-1", buffer);

	menu2.Display(client, MENU_TIME_FOREVER);
}

public void ReShowNotifHud(int client)
{
	char buffer[24];
	

	Menu menu2 = new Menu(Settings_MenuPage);
	menu2.SetTitle("%T", "Notif Hud Setting Inside", client,f_NotifHudOffsetX[client],f_NotifHudOffsetY[client]);

	Format(buffer, sizeof(buffer), "%T", "Move Hud Up", client);
	menu2.AddItem("-21", buffer);

	Format(buffer, sizeof(buffer), "%T", "Move Hud Down", client);
	menu2.AddItem("-22", buffer);

	Format(buffer, sizeof(buffer), "%T", "Move Hud Left", client);
	menu2.AddItem("-23", buffer);

	Format(buffer, sizeof(buffer), "%T", "Move Hud Right", client);
	menu2.AddItem("-24", buffer);

	Format(buffer, sizeof(buffer), "%T", "Reset to Default", client);
	menu2.AddItem("-25", buffer);
					
	Format(buffer, sizeof(buffer), "%T", "Back", client);
	menu2.AddItem("-1", buffer);

	ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "nothing");

	menu2.Display(client, MENU_TIME_FOREVER);
}


public void ReShowVolumeHud(int client)
{
	char buffer[24];

	Menu menu2 = new Menu(Settings_MenuPage);
	int volumeSettingShow = RoundToNearest(((f_ZombieVolumeSetting[client] + 1.0) * 100.0));
	
	menu2.SetTitle("%T", "Zombie Volume Setting", client,volumeSettingShow);

	Format(buffer, sizeof(buffer), "%T", "Turn up volume", client);
	menu2.AddItem("-63", buffer);

	Format(buffer, sizeof(buffer), "%T", "Turn down volume", client);
	menu2.AddItem("-64", buffer);

	Format(buffer, sizeof(buffer), "%T", "Back", client);
	menu2.AddItem("-1", buffer);

	menu2.Display(client, MENU_TIME_FOREVER);
}

public int Settings_MenuPage(Menu menu, MenuAction action, int client, int choice)
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
					if(b_HudLowHealthShake_UNSUED[client])
					{
						b_HudLowHealthShake_UNSUED[client] = false;
					}
					else
					{
						b_HudLowHealthShake_UNSUED[client] = true;
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
				case -80:
				{
					if(b_IgnoreMapMusic[client])
					{
						b_IgnoreMapMusic[client] = false;
					}
					else
					{
						b_IgnoreMapMusic[client] = true;
					}
					ReShowSettingsHud(client);
				}
				case -81:
				{
					b_DisableDynamicMusic[client] = !b_DisableDynamicMusic[client];
					ReShowSettingsHud(client);
				}
				case -82:
				{
					b_EnableRightSideAmmoboxCount[client] = !b_EnableRightSideAmmoboxCount[client];
					ReShowSettingsHud(client);
				}
				case -83:
				{
					b_EnableCountedDowns[client] = !b_EnableCountedDowns[client];
					ReShowSettingsHud(client);
				}
				case -84:
				{
					b_EnableClutterSetting[client] = !b_EnableClutterSetting[client];
					PrintToChat(client,"%t", "Enable Visual Clutter Desc");
				}
				case -85:
				{
					b_EnableNumeralArmor[client] = !b_EnableNumeralArmor[client];
					ReShowSettingsHud(client);
					
				}
				case -86:
				{
					Manual_SoundcacheFixTest(client);
				}
				case -95:
				{
					StartTutorial(client);
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
					if(b_TauntSpeedIncrease[client])
					{
						b_TauntSpeedIncrease[client] = false;
					}
					else
					{
						b_TauntSpeedIncrease[client] = true;
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
				case -73: 
				{
					if(b_InteractWithReload[client])
					{
						b_InteractWithReload[client] = false;
					}
					else
					{
						b_InteractWithReload[client] = true;
					}
					PrintToChat(client,"%t", "Enable Reload Interact Desc");
					ReShowSettingsHud(client);
				}
				case -90: 
				{
					if(b_DisableSetupMusic[client])
					{
						b_DisableSetupMusic[client] = false;
					}
					else
					{
						if(PrepareMusicVolume[client] > 0.0)
						{
 							StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/setup_music_extreme_z_battle_dokkan.mp3");
							PrepareMusicVolume[client] = 0.0;
							SetMusicTimer(client, GetTime() + 1);	
						}
						b_DisableSetupMusic[client] = true;
					}
					
					ReShowSettingsHud(client);
				}
				case -96: 
				{
					if(b_LastManDisable[client])
					{
						b_LastManDisable[client] = false;
					}
					else
					{
						b_LastManDisable[client] = true;
					}
					PrintToChat(client,"%t", "Disable Status Lastmann Music Explain");
					ReShowSettingsHud(client);
				}
				case -97:
				{
					if(b_DisplayDamageHudSettingInvert[client])
					{
						b_DisplayDamageHudSettingInvert[client] = false;
					}
					else
					{
						b_DisplayDamageHudSettingInvert[client] = true;
					}
					PrintToChat(client,"%t", "DamageHud Setting Explain");
					ReShowSettingsHud(client);
				}
				case -91: 
				{
					if(b_DisableStatusEffectHints[client])
					{
						b_DisableStatusEffectHints[client] = false;
					}
					else
					{
						b_DisableStatusEffectHints[client] = true;
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

// If timed is less than 0, super sale
void Store_DiscountNamedItem(const char[] name, int timed = 0, float discount = -1.0)
{
	int length = StoreItems.Length;
	for(int i; i < length; i++)
	{
		static Item item;
		StoreItems.GetArray(i, item);
		if(StrEqual(name, item.Name, false))
		{
			if(timed)
			{
				item.NPCSeller_Discount = discount < 0.0 ? 0.7 : discount;
				item.NPCSeller_WaveStart = timed;
			}
			else
			{
				item.NPCSeller_Discount = discount < 0.0 ? (timed < 0 ? 0.7 : 0.8) : discount;
				item.NPCSeller = true;
			}

			StoreItems.SetArray(i, item);
			break;
		}
	}
}

#define ZR_STORE_RESET (1 << 1) //This will reset the entire store to default
#define ZR_STORE_DEFAULT_SALE (1 << 2) //This  will reset the current normally sold items, and put up a new set of items
#define ZR_STORE_WAVEPASSED (1 << 3) //any storelogic that should be called when a wave passes

void Store_RandomizeNPCStore(int StoreFlags, int addItem = 0, float override = -1.0)
{
	int amount;
	int length = StoreItems.Length;
	int[] indexes = new int[length];
	bool rogue = Rogue_Mode();
	bool unlock = Rogue_UnlockStore();

	static Item item;
	static ItemInfo info;
	int GrigoriCashLogic = CurrentCash;
	//we dont want to go above this cash amount.
	if(GrigoriCashLogic > 70000)
		GrigoriCashLogic = 70000;

	//If we are in unlock mode, i.e. rogue2, then we want to have a minimim cash amount.
	if(unlock)
	{
		if(GrigoriCashLogic < 3700)
			GrigoriCashLogic = 3700;
	}

	
	for(int i; i < length; i++)
	{
		StoreItems.GetArray(i, item);
		//In here we get each and every single store item that exists in ZR
		//This will not happen if we want to reset the store entirely.
		if((StoreFlags & ZR_STORE_RESET))
		{
			//We want to entirely reset the store...
			item.NPCSeller_Discount = 1.0;
			item.NPCSeller = false;
			item.NPCSeller_WaveStart = 0;
			StoreItems.SetArray(i, item);
			continue;
		}
		//NEVER GO ON SALE, ALWAYS SAME COST.
		if(!unlock && item.StaleCost)
		{
			continue;
		}
		if(item.GregOnlySell == 2 && (!(StoreFlags & ZR_STORE_RESET)))
		{
			//We always sell this if unbought
			//Some items have to be always sold no matter what, in this case its grigori's ammo.
			float ApplySale = 0.7;
			if(override >= 0.0)
				ApplySale = override;

			item.NPCSeller_Discount = ApplySale;
			item.NPCSeller = true;

			for(int c = 1; c <= MaxClients; c++)
			{
				if(item.Owned[c] || item.BoughtBefore[c])
				{
					item.NPCSeller = false;
					break;
				}
			}
			
			StoreItems.SetArray(i, item);
			continue;
			//We only want to do this to the item.
			//it never really has to be reset.
		}

		//Any item thats within a sale thats time limited should tick down here.
		if((StoreFlags & ZR_STORE_WAVEPASSED))
		{
			if(item.NPCSeller_WaveStart > 0)
			{
				if((item.NPCSeller_WaveStart -1) <= 0)
				{
					item.NPCSeller_Discount = 1.0;
					item.NPCSeller = false;
					//remove said sale
				}
				item.NPCSeller_WaveStart--;
				StoreItems.SetArray(i, item);
				continue;
			}
		}
		if(!unlock)
		{
			//in normal zr, we have a few different rules.
			if((StoreFlags & ZR_STORE_DEFAULT_SALE))
			{
				if((item.GregOnlySell && item.GregOnlySell != 2) || (item.ItemInfos && item.GiftId == -1 && !item.NPCWeaponAlways && !item.GregBlockSell && (!item.Hidden)))
				{
					item.GetItemInfo(0, info);
					if(info.Cost > 0 && info.Cost_Unlock > ((GrigoriCashLogic / 3)- 1000) && info.Cost_Unlock < GrigoriCashLogic)
						indexes[amount++] = i;
				}

				if(item.NPCSeller && addItem == 0 && item.NPCSeller_WaveStart <= 0)
				{
					item.NPCSeller = false;
					item.NPCSeller_Discount = 1.0;
					StoreItems.SetArray(i, item);
				}
			}
		}
		else
		{
			//We want to add a few items to the aviable unlock list in rogue2
			if((StoreFlags & ZR_STORE_DEFAULT_SALE))
			{
				if(item.GregOnlySell || (item.ItemInfos && item.GiftId == -1 && !item.NPCWeaponAlways && !item.GregBlockSell && (!item.Hidden)))
				{
					if(!item.NPCSeller && !item.RogueAlwaysSell)
					{
						item.GetItemInfo(0, info);
						if(info.Cost > 0 && info.Cost_Unlock < (GrigoriCashLogic / 3))
							indexes[amount++] = i;
					}
					//if we assume a sale like this is happening, thenwe must reset all previously sold items!
				}
			}
		}
	}


	
	//we dont want to call the bottom part if we are to reset the store!
	//or just pass waves for indication purposes...
	if((StoreFlags & ZR_STORE_WAVEPASSED) || (StoreFlags & ZR_STORE_RESET))
		return;
	
	if(IsValidEntity(EntRefToEntIndex(SalesmanAlive)))
	{
		if(i_SpecialGrigoriReplace == 0)
		{
			if(addItem == 0)
				CPrintToChatAll("{green}Father Grigori{default}: My child, I'm offering new wares!");
			else
				CPrintToChatAll("{green}Father Grigori{default}: My child, I'm offering extra for a limited time!");
		}
		else
		{
			if(addItem == 0)
				CPrintToChatAll("{purple}The World Machine{default}: Come here! I managed to get some items!");
			else
				CPrintToChatAll("{purple}The World Machine{default}: Come here! I managed to get some items, but they vanish fast!");
		}
		bool OneSuperSale = (override < 0.0 && !rogue);
		SortIntegers(indexes, amount, Sort_Random);
		int SellsMax = GrigoriMaxSells;
		if(addItem != 0)
			SellsMax = addItem;
		
		for(int i; i<SellsMax && i<amount; i++) //amount of items to sell
		{
			StoreItems.GetArray(indexes[i], item);
			if(item.NPCSeller)
			{
				SellsMax++;
				continue;
			}
			float ApplySale = 0.8;
			if(rogue)
				ApplySale = 0.5;
				
			if(override >= 0.0)
				ApplySale = override;
				
			item.NPCSeller_Discount = ApplySale;
			if(addItem != 0 && item.NPCSeller_WaveStart <= 0)
			{
				CPrintToChatAll("{green}%s [$$]",item.Name);
				item.NPCSeller_WaveStart = 3;
				if(item.NPCSeller_Discount == 0.8)
					item.NPCSeller_Discount = 0.7;
			}
			else if(OneSuperSale)
			{
				CPrintToChatAll("{green}%s [$$]",item.Name);
				OneSuperSale = false;
				item.NPCSeller_Discount = 0.7;
			}
			else if(item.NPCSeller_WaveStart <= 0)
			{
				CPrintToChatAll("{palegreen}%s%s",item.Name, item.NPCSeller_Discount < 1.0 ? " [$]" : "");
			}
			item.NPCSeller = true;
			StoreItems.SetArray(indexes[i], item);
			
			if(item.Section != -1)
			{
				static Item ParentItem;
				//In here we will give any parent of said sold item the discount!
				for(int SemiInfLoop ; SemiInfLoop <= 50 ; SemiInfLoop++)
				{
					//This just prevents infinite loops.
					StoreItems.GetArray(item.Section, ParentItem);
					if(ParentItem.NPCSeller_Discount == 0.0 || ParentItem.NPCSeller_Discount > item.NPCSeller_Discount)
						ParentItem.NPCSeller_Discount = item.NPCSeller_Discount;

					if(ParentItem.NPCSeller_WaveStart < item.NPCSeller_WaveStart)
						ParentItem.NPCSeller_WaveStart = item.NPCSeller_WaveStart;

					ParentItem.NPCSeller = true;
						
					StoreItems.SetArray(item.Section, ParentItem);
					if(ParentItem.Section != -1)
					{
						item = ParentItem;
					}
					else
						break;
				}
			}
		}
	}
	else if(unlock)
	{
		ArrayList sections = new ArrayList();

		SortIntegers(indexes, amount, Sort_Random);
		int SellsMax = addItem;
		if(SellsMax > 0 && amount > 0)
		{
			char buffer[256];
			if(override < 0.0 || override > 0.95)
			{
				strcopy(buffer, sizeof(buffer), "{green}Recovered Items:{palegreen}");
			}
			else
			{
				Format(buffer, sizeof(buffer), "{green}Recovered at -%d％ off:{palegreen}", RoundFloat((1.0 - override) * 100.0));
			}

			for(int i; i<SellsMax && i<amount; i++) //amount of items to sell
			{
				StoreItems.GetArray(indexes[i], item);

				if(amount > SellsMax)
				{
					// Skip some items to increase the rate of other sections
					if(sections.FindValue(item.Section) != -1)
					{
						SellsMax++;
						continue;
					}
				}

				// Blah: Item
				// Blash, Item
				Format(buffer, sizeof(buffer), "%s%s %s", buffer, i ? "," : "", item.Name);

				item.NPCSeller = true;
				float ApplySale = 1.0;

				if(override >= 0.0)
					ApplySale = override;
					
				item.NPCSeller_Discount = ApplySale;
				StoreItems.SetArray(indexes[i], item);
				sections.Push(item.Section);
			}

			CPrintToChatAll(buffer);
		}

		delete sections;
	}
}
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
		PrintToChat(client,"%t", "Opened store via command");
		NPCOnly[client] = 0;
		LastMenuPage[client] = 0;
		MenuPage(client, -1);
	}
	return Plugin_Continue;
}

void Store_Menu(int client)
{
	if(CvarInfiniteCash.BoolValue)
	{
		StarterCashMode[client] = false;
	}
	Store_OnCached(client);
	if(LastStoreMenu[client] || AnyMenuOpen[client])
	{
		HideMenuInstantly(client);
		//show a blank page to instantly hide it
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
void HideMenuInstantly(int client)
{
	Menu menu = new Menu(Store_BlankHide);
	menu.AddItem("", "", ITEMDRAW_SPACER);
	menu.Pagination = 0;
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
}
static int Store_BlankHide(Menu menu, MenuAction action, int client, int choice)
{
	if(action == MenuAction_End)
	{
		delete menu;
	}
	return 0;
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
/*
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
}*/

static void MenuPage(int client, int section)
{
	if(dieingstate[client] > 0) //They shall not enter the store if they are downed.
		return;
	
	if(f_PreventMovementClient[client] > GetGameTime())
		return;
	
	Menu menu;
	
	bool starterPlayer = (Level[client] < STARTER_WEAPON_LEVEL && Database_IsCached(client));

	if(CvarInfiniteCash.BoolValue)
	{
		CurrentCash = 999999;
		Ammo_Count_Used[client] = -999999;
		CashSpent[client] = 0;
		starterPlayer = false;
	}

	if(!b_AntiLateSpawn_Allow[client])
	{
		//they joined late, make sure they buy something.

		int CashUsedMust = RoundToNearest(float(CurrentCash) * 0.6);
		if(CashUsedMust >= 40000)
		{
			//if they spend atleast 40k, allow at all times, this is beacuse there are sometimes wavesets
			//or meme modes that give like a googleplex cash
			CashUsedMust = 40000;
		}

		//enough cash was thrown away.
		if(CashSpent[client] >= CashUsedMust)
		{
			b_AntiLateSpawn_Allow[client] = true;
			//allow them to play.
		}
	}
	
	if(CurrentMenuItem[client] != section)
	{
		CurrentMenuItem[client] = section;
		CurrentMenuPage[client] = LastMenuPage[client];
		LastMenuPage[client] = 0;
	}
	
	int cash = CurrentCash-CashSpent[client];
	if(StarterCashMode[client])
	{
		int maxCash = StartCash;
		maxCash -= CashSpentLoadout[client];
		cash = maxCash;
		if(cash < 0)
		{
			StarterCashMode[client] = false;
			MenuPage(client, section);
			return;
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
			char buffer[512];
			
			int level = item.Owned[client] - 1;
			if(item.ParentKit || level < 0 || NPCOnly[client] == 2 || NPCOnly[client] == 3)
				level = 0;

			item.GetItemInfo(level, info);
			
			char buf[84];
			if(StarterCashMode[client])
				Format(buf, sizeof(buf), "%T", "Loadout Credits", client, cash);
			else
				Format(buf, sizeof(buf), "%T", "Credits", client, cash);

			TranslateItemName(client, item.Name, info.Custom_Name, info.Custom_Name, sizeof(info.Custom_Name));
			
			if(NPCOnly[client] == 1)
			{
				if(i_SpecialGrigoriReplace == 0)
				{
					if(Rogue_Mode())
					{
						Format(buffer, sizeof(buffer), "%T\n%T\n%T\n \n%s\n \n%s ", "TF2: Zombie Riot", client, "Father Grigori's Store", client,"All Items are 10％ off here!", client, buf, info.Custom_Name);
					}
					else
					{
						Format(buffer, sizeof(buffer), "%T\n%T\n%T\n \n%s\n \n%s ", "TF2: Zombie Riot", client, "Father Grigori's Store", client,"All Items are 20％ off here!", client, buf, info.Custom_Name);
					}
				}
				else
				{
					if(Rogue_Mode())
					{
						Format(buffer, sizeof(buffer), "%T\n%T\n%T\n \n%s\n \n%s ", "TF2: Zombie Riot", client, "The World Machine's Items", client,"All Items are 10％ off here!", client, buf, info.Custom_Name);
					}
					else
					{
						Format(buffer, sizeof(buffer), "%T\n%T\n%T\n \n%s\n \n%s ", "TF2: Zombie Riot", client, "The World Machine's Items", client,"All Items are 20％ off here!", client, buf, info.Custom_Name);
					}
				}
			}
			else if(CurrentRound < 2 || Rogue_NoDiscount() || Construction_Mode() || !Waves_InSetup())
			{
				Format(buffer, sizeof(buffer), "%T\n \n%s\n \n%s ", "TF2: Zombie Riot", client, buf, info.Custom_Name);
			}
			else
			{
				Format(buffer, sizeof(buffer), "%T\n \n%s\n%T\n%s ", "TF2: Zombie Riot", client, buf, "Store Discount", client, info.Custom_Name);
			}				
			
			Config_CreateDescription(ItemArchetype[info.WeaponArchetype], info.Classname, info.Attrib, info.Value, info.Attribs, buffer, sizeof(buffer));
			
			TranslateItemName(client, info.Desc, info.Rogue_Desc, info.Rogue_Desc, sizeof(info.Rogue_Desc));
			menu.SetTitle("%s\n%s\n ", buffer, info.Rogue_Desc);
			
			if(NPCOnly[client] == 2 || NPCOnly[client] == 3)
			{
				char buffer2[16];
				IntToString(section, buffer2, sizeof(buffer2));
				
				ItemCost(client, item, info.Cost);
				if(!item.NPCWeaponAlways)
					info.Cost -= NPCCash[client];
				
				Format(buffer, sizeof(buffer), "%T ($%d)", "Buy", client, info.Cost);
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
					Format(buffer, sizeof(buffer), "%T ($%d) [%d]", "Buy Scrap", client, info.ScrapCost , Scrap[client]);

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
							Format(buffer, sizeof(buffer), "%T ($%d)", AmmoNames[info.AmmoBuyMenuOnly], client, cost);
							if(cost > cash)
								style = ITEMDRAW_DISABLED;
						}
						else if(info.Ammo && info.Ammo < Ammo_MAX)	// Weapon with Ammo
						{	
							int cost = AmmoData[info.Ammo][0];
							Format(buffer, sizeof(buffer), "%T ($%d)", AmmoNames[info.Ammo], client, cost);
							if(cost > cash)
								style = ITEMDRAW_DISABLED;
						}
						else	// No Ammo
						{
							Format(buffer, sizeof(buffer), "%s", "-");
							style = ITEMDRAW_DISABLED;
						}
					}
					else if(item.ChildKit || item.Owned[client] || (info.Cost <= 0 && (item.Scale*item.Scaled[client]) <= 0))	// Owned already or free
					{
						Format(buffer, sizeof(buffer), "%T", "Equip", client);
						if(info.VisualDescOnly)
						{
							style = ITEMDRAW_DISABLED;
						}
					}
					else	// Buy it
					{
						ItemCost(client, item, info.Cost);
						
						Format(buffer, sizeof(buffer), "%T ($%d)", "Buy", client, info.Cost);
						if(info.Cost > cash)
							style = ITEMDRAW_DISABLED;
					}
					
					char buffer2[16];
					IntToString(section, buffer2, sizeof(buffer2));
					menu.AddItem(buffer2, buffer, style);	// 0
					Repeat_Filler ++;
					
					bool fullSell = (item.BuyWave[client] == Waves_GetRoundScale());
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
							Format(buffer, sizeof(buffer), "%T x10 ($%d)", AmmoNames[info.AmmoBuyMenuOnly], client, cost);
							if(cost > cash)
								style = ITEMDRAW_DISABLED;
							Repeat_Filler ++;
							menu.AddItem(buffer2, buffer, style);	// 1
						}
						else
						{
							int cost = AmmoData[info.Ammo][0] * 10;
							Format(buffer, sizeof(buffer), "%T x10 ($%d)", AmmoNames[info.Ammo], client, cost);
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
						Format(buffer, sizeof(buffer), "%T", "Unequip", client);
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
						Format(buffer, sizeof(buffer), "%T ($%d) | (%T: $%d)", "Sell", client, fullSell ? item.BuyPrice[client] : item.Sell[client], "Credits After Selling", client, (fullSell ? item.BuyPrice[client] : item.Sell[client]) + (cash));	// 3
						menu.AddItem(buffer2, buffer);
					}
					else
					{
						Repeat_Filler ++;
						menu.AddItem(buffer2, "-", ITEMDRAW_DISABLED);	// 2
					}
					
					level = item.Owned[client];
					if(level < 1 || NPCOnly[client] == 2 || NPCOnly[client] == 3)
						level = 1;

					bool CanBePapped = false;
					ItemInfo info2;

					//allow inspecting kit children
					if(item.ParentKit)
					{
						static Item subItem;
						int length = StoreItems.Length;
						for(int i; i < length; i++)
						{
							StoreItems.GetArray(i, subItem);
							if(subItem.Section == section /*this is also just item index?*/)
							{
								if(subItem.GetItemInfo(level, info2))
								{
									CanBePapped = true;
									break;
								}
							}
						}
					}
					else
					{
						if(item.GetItemInfo(level, info2))
							CanBePapped = true;
					}
					
					bool tinker = Blacksmith_HasTinker(client, section);
					
					if(CanBePapped)
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
								Repeat_Filler ++;
								break;
							}
						}
						Format(buffer, sizeof(buffer), "%T", "View PAP Upgrades", client);
						menu.AddItem(buffer2, buffer);
					}
					if(tinker || item.Tags[0] || info.ExtraDesc[0] || item.Author[0] || info.WeaponFaction1)
					{
						for(int Repeatuntill; Repeatuntill < 10; Repeatuntill++)
						{
							if(Repeat_Filler < 5)
							{
								Repeat_Filler ++;
								menu.AddItem(buffer2, "-", ITEMDRAW_DISABLED);	// 2
							}
							else
							{
								Repeat_Filler ++;
								break;
							}
						}
						Format(buffer, sizeof(buffer), "%T", tinker ? "View Modifiers" : (info.ExtraDesc[0] ? "Extra Description" : "Tags & Author"), client);

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
		
		char buf[84];
		if(StarterCashMode[client])
			Format(buf, sizeof(buf), "%T", "Loadout Credits", client, cash);
		else
			Format(buf, sizeof(buf), "%T", "Credits_Menu", client, cash, GlobalExtraCash + CashReceivedNonWave[client]);
		item.GetItemInfo(0, info);
		menu = new Menu(Store_MenuPage);
		if(NPCOnly[client] == 1)
		{
			menu.SetTitle("%T\n%T\n%T\n \n%ss\n \n%s", starterPlayer ? "Starter Mode" : "TF2: Zombie Riot", client, "Father Grigori's Store", client,"All Items are 20％ off here!", client, buf, info.Custom_Name);
		}
		else if(UsingChoosenTags[client])
		{
			if(CurrentRound < 2 || Rogue_NoDiscount() || Construction_Mode() || !Waves_InSetup())
			{
				menu.SetTitle("%T\n%T\n%s\n \n ", starterPlayer ? "Starter Mode" : "TF2: Zombie Riot", client, "Cherrypick Weapon", client, buf);
			}
			else
			{
				menu.SetTitle("%T\n%T\n%s\n%T\n ", starterPlayer ? "Starter Mode" : "TF2: Zombie Riot", client, "Cherrypick Weapon", client, buf, "Store Discount", client);
			}
		}
		else if(CurrentRound < 2 || Rogue_NoDiscount() || Construction_Mode() || !Waves_InSetup())
		{
			menu.SetTitle("%T\n \n%s\n \n%s", starterPlayer ? "Starter Mode" : "TF2: Zombie Riot", client, buf, info.Custom_Name);
		}
		else
		{
			menu.SetTitle("%T\n \n%s\n%T\n%s", starterPlayer ? "Starter Mode" : "TF2: Zombie Riot", client, buf, "Store Discount", client, info.Custom_Name);
		}
	}
	else
	{
		int xpLevel = LevelToXp(Level[client]);
		int xpNext = LevelToXp(Level[client]+1);
		
		char buf[84];
		if(StarterCashMode[client])
			Format(buf, sizeof(buf), "%T", "Loadout Credits", client, cash);
		else
			Format(buf, sizeof(buf), "%T", "Credits_Menu", client, cash, GlobalExtraCash + CashReceivedNonWave[client]);
		int nextAt = xpNext-xpLevel;
		menu = new Menu(Store_MenuPage);
		if(NPCOnly[client] == 1)
		{
			if(i_SpecialGrigoriReplace == 0)
				menu.SetTitle("%T\n%T\n%T\n \n%s\n \n ", starterPlayer ? "Starter Mode" : "TF2: Zombie Riot", client, "Father Grigori's Store", client,"All Items are 20％ off here!", client, buf);
			else
			{
				menu.SetTitle("%T\n%T\n%T\n \n%s\n \n ", starterPlayer ? "Starter Mode" : "TF2: Zombie Riot", client, "The World Machine's Items", client,"All Items are 20％ off here!", client, buf);
			}
		}
		else if(CurrentRound < 2 || Rogue_NoDiscount() || Construction_Mode() || !Waves_InSetup())
		{
			if(UsingChoosenTags[client])
			{
				menu.SetTitle("%T\n%T\n \n%s\n ", "TF2: Zombie Riot", client, "Cherrypick Weapon", client, buf);
			}
			else if(!CvarLeveling.BoolValue)
			{
				menu.SetTitle("%T\n \n%s\n ", "TF2: Zombie Riot", client, buf);
			}
			else if(Database_IsCached(client))
			{
				menu.SetTitle("%T\n \n%T\n%s\n ", starterPlayer ? "Starter Mode" : "TF2: Zombie Riot", client, "XP and Level", client, Level[client], XP[client] - xpLevel, nextAt, buf);
			}
			else
			{
				menu.SetTitle("%T\n \n%T\n%s\n ", "TF2: Zombie Riot", client, "XP Loading", client, buf);
			}
		}
		else
		{
			if(UsingChoosenTags[client])
			{
				menu.SetTitle("%T\n%T\n \n%s\n%T\n ", "TF2: Zombie Riot", client, "Cherrypick Weapon", client, buf, "Store Discount", client);
			}
			else if(!CvarLeveling.BoolValue)
			{
				menu.SetTitle("%T\n \n%s\n%T\n ", "TF2: Zombie Riot", client, buf, "Store Discount", client);
			}
			else if(Database_IsCached(client))
			{
				menu.SetTitle("%T\n \n%T\n%s\n%T\n ", starterPlayer ? "Starter Mode" : "TF2: Zombie Riot", client, "XP and Level", client, Level[client], XP[client] - xpLevel, nextAt, buf, "Store Discount", client);
			}
			else
			{
				menu.SetTitle("%T\n \n%T\n%s\n%T\n ", "TF2: Zombie Riot", client, "XP Loading", client, buf, "Store Discount", client);
			}
		}
		
		if(!UsingChoosenTags[client] && !NPCOnly[client] && section == -1)
		{
			char buffer[32];
			if(StarterCashMode[client])
			{
				Format(buffer, sizeof(buffer), "%T\n ", "Confirm Loadout", client);
				int ConfirmAllow = ITEMDRAW_DISABLED;
				if(CvarInfiniteCash.BoolValue)
				{
					ConfirmAllow = ITEMDRAW_DEFAULT;
				}
				if((CashSpentTotal[client] > 1/*|| Level[client] >= 10*/))
				{
					ConfirmAllow = ITEMDRAW_DEFAULT;
				}
				if(Waves_Started())
				{
					ConfirmAllow = ITEMDRAW_DEFAULT;
				}
				menu.AddItem("-26", buffer, ConfirmAllow);
			}
			else
			{
				if(Waves_Started())
					Format(buffer, sizeof(buffer), "%T", "Owned Items", client);
				else
					Format(buffer, sizeof(buffer), "%T", "Return to loadout Menu", client);
				menu.AddItem("-2", buffer);
			}
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
	else if(!CvarLeveling.BoolValue)
	{
		ClientLevel = 999;
	}
	if(section == -2)
	{
		if(Waves_Started())
			Format(buffer, sizeof(buffer), "%T", "Sell All Items", client);
		else
			Format(buffer, sizeof(buffer), "%T", "Return to loadout Menu", client);

		menu.AddItem("-999969", buffer);
	}
	if(section == -999969)
	{
		char buffer2[128];
		if(Waves_Started())
			Format(buffer2, sizeof(buffer2), "%T", "Sell Items Confirm", client);
		else
			Format(buffer2, sizeof(buffer2), "%T", "Sell Items Confirm Pref", client);

		menu.AddItem("-9999691", buffer2, ITEMDRAW_DISABLED);
		Format(buffer, sizeof(buffer), "%T", "No", client);
		menu.AddItem("-9999692", buffer);
		Format(buffer, sizeof(buffer), "%T", "Yes", client);
		menu.AddItem("-9999693", buffer);

	}
	else if(section == -9999693)
	{
		//Sell all items
		for(int i; i<length; i++)
		{
			StoreItems.GetArray(i, item);
			if(!item.Hidden) //dont sell hidden items!
				TryAndSellOrUnequipItem(i, item, client, false, false, true);
		}
		Store_ApplyAttribs(client);
		Store_GiveAll(client, GetClientHealth(client));
		ClientCommand(client, "playgamesound \"mvm/mvm_money_pickup.wav\"");
		MenuPage(client, 0);	
		if(!Waves_Started())
		{
			StarterCashMode[client] = true;
		}
		return;
	}
	else
	{
		for(int i; i<length; i++)
		{
			StoreItems.GetArray(i, item);
			item.GetItemInfo(0, info);
			if(NPCOnly[client] == 1)	// Greg Store Menu
			{
				if(!item.ItemInfos)
					continue;
					//dont display categories here....
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
				// Bought Items
				if((!item.Starter && item.Hidden) || (!item.Owned[client] && !item.Scaled[client]))
					continue;
			}
			else if(item.Section != section)
			{
				continue;
			}
			else if(starterPlayer && !Rogue_UnlockStore())
			{
				if(!item.Starter)
					continue;
			}
			else if(item.Level > ClientLevel)
			{
				continue;
			}
			else if(item.NPCSeller || item.NPCSeller_WaveStart > 0)
			{
				//empty
			}
			else if(item.Hidden)
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

			if(NPCOnly[client] == 2 || NPCOnly[client] == 3)
			{
				if(item.ItemInfos)
				{
					int npcwallet = item.NPCWeaponAlways ? 0 : NPCCash[client];
					
					item.GetItemInfo(0, info);
					if((info.Cost < 1001 || info.Cost <= CurrentCash) && RoundToCeil(float(info.Cost) * SELL_AMOUNT) > npcwallet)
					{
						ItemCost(client, item, info.Cost);
						TranslateItemName(client, item.Name, info.Custom_Name, info.Custom_Name, sizeof(info.Custom_Name));
						Format(buffer, sizeof(buffer), "%s [$%d]", info.Custom_Name, info.Cost - npcwallet);
						
						if(!item.BoughtBefore[client])
						{
							if(Rogue_UnlockStore())
							{
								if(item.NPCSeller_WaveStart > 0)
								{
									Format(buffer, sizeof(buffer), "%s%s [Waves Left:%i]", buffer, "{$}", item.NPCSeller_WaveStart);
								}
								else if(item.NPCSeller && item.NPCSeller_Discount < 1.0)
								{
									Format(buffer, sizeof(buffer), "%s {$}", buffer);
								}
							}
							else if(item.NPCSeller_WaveStart > 0)
							{
								Format(buffer, sizeof(buffer), "%s {$$} [Waves Left:%i]", buffer, item.NPCSeller_WaveStart);
							}
							else if(item.NPCSeller)
							{
								Format(buffer, sizeof(buffer), "%s {$%s}", buffer, item.NPCSeller_Discount < 0.71 ? "$" : "");
							}
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
				TranslateItemName(client, item.Name, info.Custom_Name, buffer, sizeof(buffer));
				if(item.NPCSeller_WaveStart > 0)
				{
					Format(buffer, sizeof(buffer), "%s {$$}", buffer);
				}
				else if(item.NPCSeller_Discount > 0.0 && item.NPCSeller_Discount < 1.0)
				{
					Format(buffer, sizeof(buffer), "%s {$%s}", buffer, item.NPCSeller_Discount < 0.71 ? "$" : "");
				}
				//category has some type of sale in it !
				menu.AddItem(info.Classname, buffer);
				found = true;
			}
			else
			{
				item.GetItemInfo(0, info);
	//			if(UsingChoosenTags[client] || item.ParentKit)
				{
					int style = ITEMDRAW_DEFAULT;
					IntToString(i, info.Classname, sizeof(info.Classname));
					TranslateItemName(client, item.Name, info.Custom_Name, info.Custom_Name, sizeof(info.Custom_Name));
					
					if(info.ScrapCost > 0)
					{
						Format(buffer, sizeof(buffer), "%s ($%d) [$%d]", info.Custom_Name, info.ScrapCost, Scrap[client]);
						if(Item_ClientHasAllRarity(client, info.UnboxRarity))
							style = ITEMDRAW_DISABLED;
					}
					else if(item.Equipped[client])
					{
						Format(buffer, sizeof(buffer), "%s [%T]", info.Custom_Name, "Equipped", client);
					}
					else if(item.Owned[client] > 1)
					{
						Format(buffer, sizeof(buffer), "%s [%T]", info.Custom_Name, "Packed", client);
					}
					else if(item.Owned[client])
					{
						Format(buffer, sizeof(buffer), "%s [%T]", info.Custom_Name, "Purchased", client);
					}
					else if(!info.Cost && item.Level)
					{
						Format(buffer, sizeof(buffer), "%s [Lv %d]", info.Custom_Name, item.Level);
					}
					else if(info.Cost >= 999999 && !CvarInfiniteCash.BoolValue)
					{
						continue;
					}
					else if(info.Cost_Unlock > 1000 && StartCash < 750 && StarterCashMode[client])
					{
						continue;
					}
					else if(!item.WhiteOut && Rogue_UnlockStore() && !item.NPCSeller && !item.RogueAlwaysSell && !CvarInfiniteCash.BoolValue)
					{
						Format(buffer, sizeof(buffer), "%s [↑]", info.Custom_Name);
					}
					else if(!item.WhiteOut && info.Cost_Unlock > 1000 && !Rogue_UnlockStore() && info.Cost_Unlock > CurrentCash)
					{
						Format(buffer, sizeof(buffer), "%s [%.0f％]", info.Custom_Name, float(CurrentCash) * 100.0 / float(info.Cost_Unlock));
						style = ITEMDRAW_DISABLED;
					}
					else
					{
						ItemCost(client, item, info.Cost);
						if(hasKit && item.NoKit)
						{
							Format(buffer, sizeof(buffer), "%s [WEAPON KIT EQUIPPED]", info.Custom_Name);
							style = ITEMDRAW_DISABLED;
						}
						else
						{
							if(item.WhiteOut)
							{
								Format(buffer, sizeof(buffer), "%s", info.Custom_Name);
								style = ITEMDRAW_DISABLED;
							}
							else if(!info.Cost)
							{
								Format(buffer, sizeof(buffer), "%s", info.Custom_Name);
							}
							else
							{
								Format(buffer, sizeof(buffer), "%s [$%d]", info.Custom_Name, info.Cost);
							}
						}
					}
					
					Store_EquipSlotSuffix(client, item.Slot, buffer, sizeof(buffer));

					//Dont show discount if bought before.
					if(!item.BoughtBefore[client])
					{
						if(Rogue_UnlockStore())
						{
							if(item.NPCSeller_WaveStart > 0)
							{
								Format(buffer, sizeof(buffer), "%s%s [Waves Left:%i]", buffer, "{$}", item.NPCSeller_WaveStart);
							}
							else if(item.NPCSeller && item.NPCSeller_Discount < 1.0)
							{
								Format(buffer, sizeof(buffer), "%s {$}", buffer);
							}
						}
						else if(item.NPCSeller_WaveStart > 0)
						{
							Format(buffer, sizeof(buffer), "%s {$$} [Waves Left:%i]", buffer, item.NPCSeller_WaveStart);
						}
						else if(item.NPCSeller)
						{
							Format(buffer, sizeof(buffer), "%s {$%s}", buffer, item.NPCSeller_Discount < 0.71 ? "$" : "");
						}
					}

					menu.AddItem(info.Classname, buffer, style);
					found = true;
				}
			}
		}
			
	}

	if(UsingChoosenTags[client])
	{
		if(!found)
		{
			Format(buffer, sizeof(buffer), "%T", "None", client);
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
			Format(buffer, sizeof(buffer), "%T", "Loadouts", client);
			menu.AddItem("-22", buffer);
		}

		if(Rogue_ArtifactEnabled())
		{
			Format(buffer, sizeof(buffer), "%T", "Collected Artifacts", client);
			menu.AddItem("-24", buffer);
		}

		if(Level[client] > STARTER_WEAPON_LEVEL)
		{
			if(CvarSkillPoints.BoolValue)
			{
				Format(buffer, sizeof(buffer), "%T", "Skill Tree", client);
				menu.AddItem("-25", buffer);
			}

			Format(buffer, sizeof(buffer), "%T", "Cherrypick Weapon", client);
			menu.AddItem("-30", buffer);
		}
		
		Format(buffer, sizeof(buffer), "%T", "Help?", client);
		menu.AddItem("-3", buffer);
		
		if(starterPlayer)
		{
			menu.AddItem("-43", buffer, ITEMDRAW_SPACER);

			Format(buffer, sizeof(buffer), "%T", "Skip Starter", client);
			menu.AddItem("-43", buffer);
		}
		else
		{
			Format(buffer, sizeof(buffer), "%T", "Settings", client); //Settings
			menu.AddItem("-23", buffer);

			Format(buffer, sizeof(buffer), "%T", "Encyclopedia", client);
			menu.AddItem("-13", buffer);

			Format(buffer, sizeof(buffer), "%T", "Status Effect List", client);
			menu.AddItem("-100", buffer);
		}

		if(DisplayMenuAtCustom(menu, client, CurrentMenuPage[client]))
		{
			SetStoreMenuLogic(client);
		}
	}
	else
	{
		if(!found)
		{
			Format(buffer, sizeof(buffer), "%T", "None", client);
			menu.AddItem("0", buffer, ITEMDRAW_DISABLED);
		}

		menu.ExitBackButton = section != -1;
		if(DisplayMenuAtCustom(menu, client, CurrentMenuPage[client]))
		{
			SetStoreMenuLogic(client);
		}
	}
}

public int Store_MenuPage(Menu menu, MenuAction action, int client, int choice)
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
					case -26:
					{
						StarterCashMode[client] = false;
						CurrentMenuItem[client] = -1;
						MenuPage(client, CurrentMenuItem[client]);
					}
					case -25:
					{
						SkillTree_OpenMenu(client);
					}
					case -23:
					{
						ReShowSettingsHud(client);
					}
					case -21:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%T", "Credits Page", client);
						
						Format(buffer, sizeof(buffer), "%T", "Back", client);
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -3:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%T", "Help Title?", client);

						Format(buffer, sizeof(buffer), "%T", "Gamemode Credits", client); //credits is whatever, put in back.
						menu2.AddItem("-21", buffer);

						if(CvarCustomModels.BoolValue)
						{
							if(IsFileInDownloads("models/sasamin/oneshot/zombie_riot_edit/niko_05.mdl"))
							{
								Format(buffer, sizeof(buffer), "%T", "Custom Models", client);
								menu2.AddItem("-45", buffer);
							}
							else
							{
								CvarCustomModels.BoolValue = false;
							}
						}

						Format(buffer, sizeof(buffer), "%T", "Buff/Debuff List", client);
						menu2.AddItem("-12", buffer);
						
						Format(buffer, sizeof(buffer), "%T", "Gamemode Help?", client);
						menu2.AddItem("-4", buffer);
						
						Format(buffer, sizeof(buffer), "%T", "Command Help?", client);
						menu2.AddItem("-5", buffer);
						
						Format(buffer, sizeof(buffer), "%T", "Difficulty Help?", client);
						menu2.AddItem("-6", buffer);
						
						Format(buffer, sizeof(buffer), "%T", "Level Help?", client);
						menu2.AddItem("-7", buffer);
						
						Format(buffer, sizeof(buffer), "%T", "Special Zombies Help?", client);
						menu2.AddItem("-8", buffer);
						
						Format(buffer, sizeof(buffer), "%T", "Revival Help?", client);
						menu2.AddItem("-9", buffer);
						
						Format(buffer, sizeof(buffer), "%T", "Building Help?", client);
						menu2.AddItem("-10", buffer);
						
						Format(buffer, sizeof(buffer), "%T", "Extra Buttons Help?", client);
						menu2.AddItem("-11", buffer);
						
						menu2.ExitBackButton = true;
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -4:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%T", "Gamemode Help Explained", client);
						
						Format(buffer, sizeof(buffer), "%T", "Back", client);
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -12:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%T", "Debuff/Buff Explain 1", client);

						
						Format(buffer, sizeof(buffer), "%T", "Show Debuffs", client);
						menu2.AddItem("-53", buffer);
						
						Format(buffer, sizeof(buffer), "%T", "Back", client);
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -53:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%T", "Debuff/Buff Explain 2", client);

						
						Format(buffer, sizeof(buffer), "%T", "Show Buffs", client);
						menu2.AddItem("-12", buffer);
						
						Format(buffer, sizeof(buffer), "%T", "Back", client);
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -5:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%T", "Command Help Explained", client);
						
						Format(buffer, sizeof(buffer), "%T", "Back", client);
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -6:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%T", "Difficulty Help Explained", client);
						
						Format(buffer, sizeof(buffer), "%T", "Back", client);
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -7:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%T", "Level Help Explained", client);
						
						Format(buffer, sizeof(buffer), "%T", "Back", client);
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -8:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%T", "Special Zombies Explained", client);
						
						Format(buffer, sizeof(buffer), "%T", "Back", client);
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -9:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%T", "Revival Zombies Explained", client);
						
						Format(buffer, sizeof(buffer), "%T", "Back", client);
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -10:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%T", "Building Explained", client);
						
						Format(buffer, sizeof(buffer), "%T", "Back", client);
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -11:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%T", "Extra Buttons Explained", client);
						
						Format(buffer, sizeof(buffer), "%T", "Back", client);
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -13:
					{
						c_WeaponUseAbilitiesHud[client][0] = 0;
						Items_EncyclopediaMenu(client);
					}
					case -100:
					{
						Items_StatusEffectListMenu(client);
					}
					case -14:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%T", "Bored or Dead Minigame", client);
						
						Format(buffer, sizeof(buffer), "%T", "Idlemine", client);
						menu2.AddItem("-15", buffer);
						
						Format(buffer, sizeof(buffer), "%T", "Tetris", client);
						menu2.AddItem("-16", buffer);
						
						Format(buffer, sizeof(buffer), "%T", "Snake", client);
						menu2.AddItem("-17", buffer);
						
						Format(buffer, sizeof(buffer), "%T", "Solitaire", client);
						menu2.AddItem("-18", buffer);
						
						Format(buffer, sizeof(buffer), "%T", "Pong", client);
						menu2.AddItem("-19", buffer);
						
						Format(buffer, sizeof(buffer), "%T", "Connect 4", client);
						menu2.AddItem("-20", buffer);
						
						Format(buffer, sizeof(buffer), "%T", "Back", client);
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
						menu2.SetTitle("%T", "Skip Starter Confirm", client);
						
						Format(buffer, sizeof(buffer), "%T", "Back", client);
						menu2.AddItem("-1", buffer);
						Format(buffer, sizeof(buffer), "%T", "Back", client);
						menu2.AddItem("-1", buffer);
						Format(buffer, sizeof(buffer), "%T", "Back", client);
						menu2.AddItem("-1", buffer);
						Format(buffer, sizeof(buffer), "%T", "Skip Starter Button", client);
						menu2.AddItem("-44", buffer);
						Format(buffer, sizeof(buffer), "%T", "Back", client);
						menu2.AddItem("-1", buffer);
						Format(buffer, sizeof(buffer), "%T", "Back", client);
						menu2.AddItem("-1", buffer);
						Format(buffer, sizeof(buffer), "%T", "Back", client);
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -44:
					{
						XP[client] = LevelToXp(5);
						Level[client] = 0; //Just incase.
						Native_ZR_OnGetXP(client, XP[client], 1);
						GiveXP(client, 0);
						TutorialEndFully(client);
					}
					case -24:
					{
						Rogue_ArtifactMenu(client, 0);
					}
					case -30:
					{
						Store_CherrypickMenu(client);
					}
					case -45:
					{
						Menu menu2 = new Menu(Store_MenuPage);
						menu2.SetTitle("%T", "Custom Models", client);
						
						Format(buffer, sizeof(buffer), "%T", "TF2 Class", client);
						menu2.AddItem("-46", buffer);
						
						Format(buffer, sizeof(buffer), "%T", "Barney", client);
						menu2.AddItem("-47", buffer);

						Format(buffer, sizeof(buffer), "%T", "Niko Oneshot", client);
						menu2.AddItem("-48", buffer);

						Format(buffer, sizeof(buffer), "%T", "Skeleboy", client);
						menu2.AddItem("-49", buffer);

						Format(buffer, sizeof(buffer), "%T", "Kleiner", client);
						menu2.AddItem("-50", buffer);

						Format(buffer, sizeof(buffer), "%T", "Fat HHH", client);
						menu2.AddItem("-151", buffer);

						Format(buffer, sizeof(buffer), "%T", "Back", client);
						menu2.AddItem("-1", buffer);
						
						menu2.Display(client, MENU_TIME_FOREVER);
					}
					case -46:
					{
						OverridePlayerModel(client);
						JoinClassInternal(client, CurrentClass[client]);
						MenuPage(client, -1);
					}
					case -47:
					{
						OverridePlayerModel(client, BARNEY, true);
						JoinClassInternal(client, CurrentClass[client]);
						MenuPage(client, -1);
					}
					case -48:
					{
						OverridePlayerModel(client, NIKO_2, true);
						JoinClassInternal(client, CurrentClass[client]);
						MenuPage(client, -1);
					}
					case -49:
					{
						OverridePlayerModel(client, SKELEBOY, false);
						JoinClassInternal(client, CurrentClass[client]);
						MenuPage(client, -1);
					}
					case -50:
					{
						OverridePlayerModel(client, KLEINER, true);
						JoinClassInternal(client, CurrentClass[client]);
						MenuPage(client, -1);
					}
					case -151:
					{
						OverridePlayerModel(client, HHH_SkeletonOverride, true);
						JoinClassInternal(client, CurrentClass[client]);
						MenuPage(client, -1);
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
	//Profiler profiler = new Profiler();
//	profiler.Start();
	int returndo = Store_MenuItemInt(menu, action, client, choice);
//	profiler.Stop();
//	PrintToChatAll("Profiler: %f", profiler.Time);
//	delete profiler;

	return returndo;
}
public int Store_MenuItemInt(Menu menu, MenuAction action, int client, int choice)
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
			if(f_PreventMovementClient[client] > GetGameTime())
			{
				//dont call anything.
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
					
					if(StarterCashMode[client])
					{
						int maxCash = StartCash;
						maxCash -= CashSpentLoadout[client];
						cash = maxCash;
					}
					if(ClientTutorialStep(client) == 2)
					{
						SetClientTutorialStep(client, 3);
						DoTutorialStep(client, false);	
					}
		
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

						Stock_SpawnGift(VecOrigin, GIFT_MODEL, 45.0, view_as<ZRGiftRarity>(info.UnboxRarity -1)); //since they are one lower
						
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
							CashSpentLoadout[client] += AmmoData[info.AmmoBuyMenuOnly][0];
							ClientCommand(client, "playgamesound \"mvm/mvm_bought_upgrade.wav\"");
							
							int ammo = GetAmmo(client, info.AmmoBuyMenuOnly) + AmmoData[info.AmmoBuyMenuOnly][1];
							SetAmmo(client, info.AmmoBuyMenuOnly, ammo);
							CurrentAmmo[client][info.AmmoBuyMenuOnly] = ammo;
						}
						else if(info.Ammo && info.Ammo < Ammo_MAX && AmmoData[info.Ammo][0] <= cash)
						{
							CashSpent[client] += AmmoData[info.Ammo][0];
							CashSpentTotal[client] += AmmoData[info.Ammo][0];
							CashSpentLoadout[client] += AmmoData[info.Ammo][0];
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
								CashSpentLoadout[client] += info.Cost;
								Store_BuyClientItem(client, index, item, info);
								item.BuyPrice[client] = info.Cost;
								item.RogueBoughtRecently[client] += 1;
								item.Sell[client] = ItemSell(base, info.Cost);
								if(item.GregOnlySell == 2)
								{
									item.BuyPrice[client] = 0;
									item.Sell[client] = 0;
								}
								item.BuyWave[client] = Waves_GetRoundScale();
								item.Equipped[client] = false;

								if(item.GregOnlySell == 2)
								{
									item.Sell[client] = 0;
								}
								if(!item.BoughtBefore[client])
								{
									item.BoughtBefore[client] = true;
								//	StoreBalanceLog.Rewind();
								//	StoreBalanceLog.SetNum(item.Name, StoreBalanceLog.GetNum(item.Name) + 1);
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
								CashSpentLoadout[client] += info.Cost;
								Store_BuyClientItem(client, index, item, info);
								item.BuyPrice[client] = info.Cost;
								item.RogueBoughtRecently[client] += 1;
								item.Sell[client] = ItemSell(base, info.Cost);
								item.BuyWave[client] = Waves_GetRoundScale();
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
								//	StoreBalanceLog.Rewind();
								//	StoreBalanceLog.SetNum(item.Name, StoreBalanceLog.GetNum(item.Name) + 1);
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
							CashSpentLoadout[client] += info.Cost;
							Store_BuyClientItem(client, index, item, info);
							item.BuyPrice[client] = info.Cost;
							item.RogueBoughtRecently[client] += 1;
							item.Sell[client] = ItemSell(base, info.Cost);
							item.BuyWave[client] = Waves_GetRoundScale();
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
							//	StoreBalanceLog.Rewind();
							//	StoreBalanceLog.SetNum(item.Name, StoreBalanceLog.GetNum(item.Name) + 1);
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
				case 1:	 // Ammo x10
				{
					if(item.Owned[client])
					{
						int cash = CurrentCash - CashSpent[client];
						if(StarterCashMode[client])
						{
							int maxCash = StartCash;
							maxCash -= CashSpentLoadout[client];
							cash = maxCash;
						}
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
								CashSpentLoadout[client] += cost;
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
								CashSpentLoadout[client] += cost;
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
					TryAndSellOrUnequipItem(index, item, client, true, true);
				}
				case 3:	// Sell
				{
					TryAndSellOrUnequipItem(index, item, client, false, true);
				}
				case 4:	
				{

					item.GetItemInfo(0, info);
					int level = item.Owned[client];
					bool OwnedBefore = view_as<bool>(item.Owned[client]);
					if(level < 1 || NPCOnly[client] == 2 || NPCOnly[client] == 3)
						level = 1;

					//can be papped ? See if yes
					ItemInfo info2;

					//allow inspecting kit children
					if(item.ParentKit)
					{
						static Item subItem;
						int length = StoreItems.Length;
						for(int i; i < length; i++)
						{
							StoreItems.GetArray(i, subItem);
							if(subItem.Section == index)
							{
								if(subItem.GetItemInfo(level, info2))
								{
									if(!b_AntiLateSpawn_Allow[client] && OwnedBefore)
										Store_PackMenu(client, i, level, client, false);
									else
										Store_PackMenu(client, i, level, client, true);

									return 0;
								}
							}
						}
					}
					else if(item.GetItemInfo(level, info2))
					{
						if(!b_AntiLateSpawn_Allow[client] && OwnedBefore)
							Store_PackMenu(client, index, level, client, false);
						else
							Store_PackMenu(client, index, level, client, true);

						return 0;
					}
				}
				case 5:
				{
					item.GetItemInfo(0, info);

					char buffer[256], buffers[6][256];

					if(item.Tags[0])
					{
						int tags = ExplodeString(item.Tags, ";", buffers, sizeof(buffers), sizeof(buffers[]));
						if(tags)
						{
							TranslateItemName(client, buffers[0], _, buffer, sizeof(buffer));

							for(int i = 1; i < tags; i++)
							{
								TranslateItemName(client, buffers[i], _, buffers[0], sizeof(buffer));
								Format(buffer, sizeof(buffer), "%s, %s", buffer, buffers[0]);
							}

							PrintToChat(client, "%t", "Tags List", buffer);
						}
					}

					if(info.WeaponFaction1)
					{
						TranslateItemName(client, ItemFaction[info.WeaponFaction1], _, buffer, sizeof(buffer));
						if(info.WeaponFaction2)
						{
							TranslateItemName(client, ItemFaction[info.WeaponFaction2], _, buffers[0], sizeof(buffer));
							Format(buffer, sizeof(buffer), "%s, %s", buffer, buffers[0]);
						}

						PrintToChat(client, "%t", "Faction List", buffer);
					}

					if(info.ExtraDesc[0])
					{
						TranslateItemName(client, info.ExtraDesc, info.Rogue_Desc, buffer, sizeof(buffer));
						PrintToChat(client, buffer);
						char buffer2[256];
						TranslateItemName(client, info.ExtraDesc_1, info.Rogue_Desc, buffer2, sizeof(buffer2));
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
//anymore then 20 slots iss overkill.
#define MAX_LOADOUT_SLOTS 20
static void LoadoutPage(int client, bool last = false)
{
	
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
		Format(buffer, sizeof(buffer), "%T", "None", client);
		menu.AddItem("", buffer, ITEMDRAW_DISABLED);
	}

	int slots = MAX_LOADOUT_SLOTS;
	if(slots > length)
	{
		menu.SetTitle("%T\n%T\n \n%T", "TF2: Zombie Riot", client, "Loadouts", client, "Save New", client);
	}
	else
	{
		menu.SetTitle("%T\n%T\n \n ", "TF2: Zombie Riot", client, "Loadouts", client);
	}
	
	menu.ExitBackButton = true;
	if(menu.DisplayAt(client, last ? (length / 7 * 7) : 0, MENU_TIME_FOREVER) && (MAX_LOADOUT_SLOTS) > length)
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
	Menu menu = new Menu(Store_LoadoutItem);
	menu.SetTitle("%T\n%T\n \n%s", "TF2: Zombie Riot", client, "Loadouts", client, name);
	
	char buffer[64];
	
	//We will check for favorites the lazy way.
	
	Format(buffer, sizeof(buffer), "%T", "All Items", client);
	menu.AddItem(name, buffer);
	
	Format(buffer, sizeof(buffer), "%T", "Free Only", client);
	menu.AddItem(name, buffer);
	
	if(!StrContains(name, "[♥]"))
	{
		Format(buffer, sizeof(buffer), "%T", "Un Favorite", client);
		menu.AddItem(name, buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "Favorite", client);
		menu.AddItem(name, buffer);
	}

	
	menu.AddItem(name, buffer, ITEMDRAW_SPACER);
	
	Format(buffer, sizeof(buffer), "%T", "Delete Loadout", client);
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
					
					
					Menu menu2 = new Menu(Store_MenuPage);
					menu2.SetTitle("%T", "Getting Your Items", client);
					
					menu2.AddItem(NULL_STRING, NULL_STRING, ITEMDRAW_SPACER);
					
					menu2.Display(client, 10);
					
					Database_LoadLoadout(client, buffer, choice == 1);
				}
				case 2:
				{
					char buffer2[256];
					if(!StrContains(buffer, "[♥]"))
					{
						//Remove favorite
						Format(buffer2, sizeof(buffer2), "%s", buffer[5]);
						int index = Loadouts[client].FindString(buffer);
						if(index != -1)
						{
							Database_EditName(client, buffer, buffer2);
							Loadouts[client].SetString(index, buffer2, sizeof(buffer2));
						}
						LoadoutPage(client);
					}
					else
					{
						//Add favorite
						Format(buffer2, sizeof(buffer2), "[♥]%s", buffer);
						int index = Loadouts[client].FindString(buffer);
						if(index != -1)
						{
							Database_EditName(client, buffer, buffer2);
							Loadouts[client].SetString(index, buffer2, sizeof(buffer2));
						}
						LoadoutPage(client);
					}
				}
				case 4:
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
	
	if(!StrContains(buffer, "[♥]"))
	{
		PrintToChat(client, "%T", "Invalid Name", client);
		return true;
	}
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
	
	
	
	Menu menu = new Menu(Store_CherrypickMenuH);
	menu.SetTitle("%T\n%T\n \n", "TF2: Zombie Riot", client, "Cherrypick Weapon", client);
	
	char trans[32], buffer[256];

	Format(trans, sizeof(trans), "%T", "Search With Tags", client);
	menu.AddItem(buffer, trans, ChoosenTags[client].Length ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	Format(trans, sizeof(trans), "%T", "Clear Whitelist", client);
	menu.AddItem(buffer, trans, ChoosenTags[client].Length ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	int length = StoreTags.Length;
	for(int i; i < length; i++)
	{
		StoreTags.GetString(i, buffer, sizeof(buffer));
		TranslateItemName(client, buffer, _, buffer, sizeof(buffer));
		Format(trans, sizeof(trans), "[%s] %s", ChoosenTags[client].FindString(buffer) == -1 ? " " : "X", buffer);
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

	//Each time we delete ALL attributes, we increase this amount by one.
	ClientAttribResetCount[client]++;
	Attributes_RemoveAll(client);
	
	TFClassType ClassForStats = WeaponClass[client];
	
	StringMap map = new StringMap();

	int Extra_Juggernog_Hp = 0;
	if(i_CurrentEquippedPerk[client] & PERK_OBSIDIAN)
	{
		Extra_Juggernog_Hp = 100;
	}

	if(i_HealthBeforeSuit[client] == 0)
	{
		float HealthDoLogic = RemoveExtraHealth(ClassForStats, 0.1);
		map.SetValue("125", HealthDoLogic);
		map.SetValue("26", (200.0 + Extra_Juggernog_Hp));		// Health
	}
	else
	{
		map.SetValue("125", RemoveExtraHealth(ClassForStats, 1.0));		// Health
	}

	map.SetValue("201", f_DelayAttackspeedPreivous[client]);
	map.SetValue("343", 1.0); //sentry attackspeed fix
	map.SetValue("526", 1.0);//
	map.SetValue("4049", 1.0);// Elemental Res

	map.SetValue("442", 1.0);	// Move Speed
	map.SetValue("49", 1);	// no doublejumps

	if(b_IsAloneOnServer)
		map.SetValue("412", 0.75);	//if alone, gain 25% resistance

	map.SetValue("740", 0.0);	// No Healing from mediguns, allow healing from pickups
	map.SetValue("314", -2.0);	//Medigun uber duration, it has to be a body attribute
	map.SetValue("8", 2.0);	//give 50% more healing at the start.
	if(f_PreventMovementClient[client] > GetGameTime())
	{
		map.SetValue("819", 1.0);
		map.SetValue("820", 1.0);
		map.SetValue("821", 1.0);
		map.SetValue("107", 0.001);
		map.SetValue("698", 1.0);
		//try prevent.
	}
	else
	{
		
		float MovementSpeed = 330.0;
		
		if(VIPBuilding_Active())
		{
			MovementSpeed = 419.0;
			map.SetValue("443", 1.25);
		}
		map.SetValue("107", RemoveExtraSpeed(ClassForStats, MovementSpeed));		// Move Speed
	}

	float KnockbackResistance;
	KnockbackResistance = float(CurrentCash) * 150000.0; //at wave 40, this will equal to 60* dmg

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
	map.SetValue("4039", 1.0);
//	Attrib_BlessingBuff
	if(Items_HasNamedItem(client, "Alaxios's Godly assistance"))
	{
		b_AlaxiosBuffItem[client] = true;
	}
	else
	{
		b_AlaxiosBuffItem[client] = false;
	}
	
	if(i_CurrentEquippedPerk[client] & PERK_HASTY_HOPS)
	{
		map.SetValue("178", 0.65); //Faster Weapon Switch
	}
	
	if(i_CurrentEquippedPerk[client] & PERK_MORNING_COFFEE) //increase sentry damage! Not attack rate, could end ugly.
	{		
		map.SetValue("287", 0.65);
	}
	else
	{
		map.SetValue("287", 0.5);
	}
	map.SetValue("95", 1.0);

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
							else if(info.Attrib[a] < 0 || info.Attrib[a]==26 || (Attribute_IntAttribute(info.Attrib[a]) || (TF2Econ_GetAttributeDefinitionString(info.Attrib[a], "description_format", buffer2, sizeof(buffer2)) && StrContains(buffer2, "additive")!=-1)))
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
							else if(info.Attrib2[a] < 0 || info.Attrib2[a]==26 || (Attribute_IntAttribute(info.Attrib2[a]) || (TF2Econ_GetAttributeDefinitionString(info.Attrib2[a], "description_format", info.Classname, sizeof(info.Classname)) && StrContains(info.Classname, "additive")!=-1)))
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
	Grigori_Blessing[client] = 0;
	i_HeadshotAffinity[client] = 0;
	i_SoftShoes[client] = 0;

	SkillTree_ApplyAttribs(client, map);
	Rogue_ApplyAttribs(client, map);
	Waves_ApplyAttribs(client, map);
	FullMoonDoubleHp(client, map);

	StringMapSnapshot snapshot = map.Snapshot();
//	entity = client;
	int length = snapshot.Length;
	int attribs = 0;
//	int ClientsideAttribs = 0;
	for(int i; i < length; i++)
	{

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
					Grigori_Blessing[client] = RoundToNearest(value);
					continue;
				}
				case 785:
				{
					i_HeadshotAffinity[client] = RoundToNearest(value);
					continue;
				}
				case 527:
				{
					i_SoftShoes[client] = RoundToNearest(value);
					continue;
				}
			}

			if(Attributes_Set(client, index, value))
				attribs++;

		}
	}
	if(dieingstate[client] > 0)
	{
		ForcePlayerCrouch(client, true);
		if(Rogue_Rift_VialityThing())
			Attributes_SetMulti(client, 442, 0.85);
		else
			Attributes_SetMulti(client, 442, 0.65);
	}
	
	Mana_Regen_Level[client] = Attributes_GetOnPlayer(client, 405);
	
	delete snapshot;
	delete map;
	StatusEffect_StoreRefresh(client);
	TF2_AddCondition(client, TFCond_Dazed, 0.001);

	EnableSilvesterCosmetic(client);
	EnableMagiaCosmetic(client);
	Building_Check_ValidSupportcount(client);
	//give all revelant things back
	//Get the previous count to get back all their stats.
	int clientid = GetSteamAccountID(client);
	WeaponSpawn_Reapply(client, client, clientid);
}

void Store_GiveAll(int client, int health, bool removeWeapons = false)
{
//	Profiler profiler = new Profiler();
//	profiler.Start();		
	Store_GiveAllInternal(client, health, removeWeapons);		
//	profiler.Stop();	
//	PrintToChatAll("Profiler testing: %f", profiler.Time);
//	delete profiler;
}

void Store_GiveAllInternal(int client, int health, bool removeWeapons = false)
{
	b_HasBeenHereSinceStartOfWave[client] = false;
	TF2_RemoveCondition(client, TFCond_Taunting);
	PreMedigunCheckAntiCrash(client);
	if(!StoreItems)
	{
		return; //STOP. BAD!
	}
	if(!IsPlayerAlive(client))
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
		b_HasBeenHereSinceStartOfWave[client] = true; //If they arent a teuton!
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
		Store_RemoveSpecificItem(client, "Teutonic Longsword", false);
	}
	b_HasBeenHereSinceStartOfWave[client] = true; //If they arent a teuton!
	//OverridePlayerModel(client);
	//stickies can stay, we delete any non spike stickies.
	for( int i = 1; i <= MAXENTITIES; i++ ) 
	{
		if(IsValidEntity(i))
		{
			static char classname[36];
			GetEntityClassname(i, classname, sizeof(classname));
			if(StrEqual(classname, "tf_projectile_pipe_remote"))
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
	b_CanSeeBuildingValues_Force[client] = false;
	b_Reinforce[client] = false;
	i_MaxSupportBuildingsLimit[client] = 0;
	b_PlayerWasAirbornKnockbackReduction[client] = false;
	BannerOnEntityCreated(client);
	FullmoonEarlyReset(client);

	if(!i_ClientHasCustomGearEquipped[client])
	{
		int count;
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
					Store_GiveItem(client, i, use, found);
					if(++count > 6)
					{
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
	CheckSummonerUpgrades(client);
	Barracks_UpdateAllEntityUpgrades(client);
	Manual_Impulse_101(client, health);
	BarracksCheckItems(client);
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
		int slot = TF2_GetClassnameSlot(buffer, entity);
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
	if(!IsPlayerAlive(client))
	{
		return -1; //STOP. BAD!
	}
	//incase.
	TF2_RemoveCondition(client, TFCond_Taunting);
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
				int saveslot = TF2_GetClassnameSlot(info.Classname);
				slot = saveslot;
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
				int class = info.WeaponForceClass;

				if(GiveWeaponIndex > 0)
				{
					if(info.CustomWeaponOnEquip == WEAPON_YAKUZA)
						Yakuz_SpawnWeaponPre(client, GiveWeaponIndex, view_as<TFClassType>(class));
					
					entity = SpawnWeapon(client, info.Classname, GiveWeaponIndex, 5, 6, info.Attrib, info.Value, info.Attribs, class);	
					
					i_SavedActualWeaponSlot[entity] = saveslot;
					
					if(!StrContains(info.Classname, "tf_weapon_crossbow"))
					{
						//Fix crossbow infinite reload issue
						//it messes up Zr balance heavily and causes other bugs.
						//Shouldnt apply to support ones.
						if(!info.IsSupport && !info.IsAlone)
						{
							CrossbowGiveDhook(entity, false);
						}
						else
							CrossbowGiveDhook(entity, true);
					}
					HidePlayerWeaponModel(client, entity, true);

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
				b_CanSeeBuildingValues[entity] = false;
				i_IsSupportWeapon[entity] = false;
				i_IsKitWeapon[entity] = false;
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
					OriginalWeapon_AmmoType[entity] = -1;
					if(info.Ammo > 0 && !CvarRPGInfiniteLevelAndAmmo.BoolValue)
					{
						if(!StrEqual(info.Classname[0], "tf_weapon_medigun"))
						{
							if(!StrEqual(info.Classname[0], "tf_weapon_particle_cannon"))
							{
								if(info.Ammo == 30)
								{
									SetEntProp(entity, Prop_Send, "m_iPrimaryAmmoType", -1);
									OriginalWeapon_AmmoType[entity] = -1;
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
										
										i_SemiAutoWeapon_AmmoCount[entity] = 0; //Set the ammo to 0 so they cant abuse it.
										
										f_SemiAutoStats_FireRate[entity] = info.SemiAutoStats_FireRate;
										i_SemiAutoStats_MaxAmmo[entity] = info.SemiAutoStats_MaxAmmo;
										f_SemiAutoStats_ReloadTime[entity] = info.SemiAutoStats_ReloadTime;
	
									}
									if(info.Ammo) //my man broke my shit.
									{
										SetEntProp(entity, Prop_Send, "m_iPrimaryAmmoType", info.Ammo);
										OriginalWeapon_AmmoType[entity] = info.Ammo;
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
					if(info.Visible_BuildingStats)
					{
						b_CanSeeBuildingValues[entity] = true;
					}
					if(info.IsSupport)
					{
						i_IsSupportWeapon[entity] = true;
					}
					if(item.ChildKit)
					{
						i_IsKitWeapon[entity] = true;
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
					Format(c_WeaponUseAbilitiesHud[entity],sizeof(c_WeaponUseAbilitiesHud[]),"%s",info.WeaponHudExtra);	
					
					i_WeaponArchetype[entity] 				= info.WeaponArchetype;
					i_WeaponForceClass[entity] 				= class;
					i_WeaponSoundIndexOverride[entity] 		= info.WeaponSoundIndexOverride;
					i_WeaponModelIndexOverride[entity] 		= info.WeaponModelIndexOverride;
				//	Format(c_WeaponSoundOverrideString[entity],sizeof(c_WeaponSoundOverrideString[]),"%s",info.WeaponSoundOverrideString);	
					f_WeaponSizeOverride[entity]			= info.WeaponSizeOverride;
					f_WeaponSizeOverrideViewmodel[entity]	= info.WeaponSizeOverrideViewmodel;
					f_WeaponVolumeStiller[entity]				= info.WeaponVolumeStiller;
					f_WeaponVolumeSetRange[entity]				= info.WeaponVolumeRange;
					f_BackstabBossDmgPenalty[entity]		= info.BackstabDmgPentalty;
					f_ModifThirdPersonAttackspeed[entity]	= info.ThirdpersonAnimModif;
					
					i_WeaponVMTExtraSetting[entity] 			= info.WeaponVMTExtraSetting;
					i_WeaponBodygroup[entity] 				= info.Weapon_Bodygroup;
					i_WeaponFakeIndex[entity] 				= info.Weapon_FakeIndex;

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
					f_Weapon_BackwardsWalkPenalty[entity] 		= info.Backwards_Walk_Penalty;
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
		"tf_weapon_bottle", "tf_weapon_bonesaw", "tf_weapon_fists", "tf_weapon_fireaxe", "tf_weapon_knife", "tf_weapon_wrench" };
		entity = CreateEntityByName(Classnames[CurrentClass[client]]);

		if(entity > MaxClients)
		{
			static const int Indexes[] = { 196, 0, 3, 196, 1, 8, 5, 2, 194, 30758 };
			SetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex", Indexes[CurrentClass[client]]);

			SetEntProp(entity, Prop_Send, "m_bInitialized", 1);
			
			SetEntProp(entity, Prop_Send, "m_iEntityQuality", 0);
			SetEntProp(entity, Prop_Send, "m_iEntityLevel", 1);
			
			GetEntityNetClass(entity, Classnames[0], sizeof(Classnames[]));
			int offset = FindSendPropInfo(Classnames[0], "m_iItemIDHigh");

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
						//only give 1 revive at all costs.
						if(i_AmountDowned[client] < 1)
						{
							i_AmountDowned[client] = 1;
						}
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
					if(info.SpecialAdditionViaNonAttribute == 14)
					{
						b_Reinforce[client] = true;
					}
					if(info.SpecialAdditionViaNonAttribute == 15)
					{
						b_CanSeeBuildingValues_Force[client] = true;
					}

					int CostDo;

					if(EntityIsAWeapon)
					{
						ItemCost(client, item, CostDo);
						bool apply = CheckEntitySlotIndex(info.Index, slot, entity, CostDo);
						
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
										//Giving kits everything makes sure it doesnt add it if you dont even own it.
										//This makes sure it doesnt break certain weapons, and doesnt break tinker.
										if(slot != 12)
											Attributes_Set(entity, info.Attrib[a], info.Value[a]);
									}
								}
								else if(!ignore_rest && (Attribute_IntAttribute(info.Attrib[a]) || (TF2Econ_GetAttributeDefinitionString(info.Attrib[a], "description_format", info.Classname, sizeof(info.Classname)) && StrContains(info.Classname, "additive")!=-1)))
								{
									Attributes_SetAdd(entity, info.Attrib[a], info.Value[a]);
								}
								else if(!ignore_rest)
								{
									Attributes_SetMulti(entity, info.Attrib[a], info.Value[a]);
								}
							}
						}

						apply = CheckEntitySlotIndex(info.Index2, slot, entity, CostDo);
						
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
										//Giving kits everything makes sure it doesnt add it if you dont even own it.
										//This makes sure it doesnt break certain weapons, and doesnt break tinker.
										if(slot != 12)
											Attributes_Set(entity, info.Attrib2[a], info.Value2[a]);
									}
								}
								else if(!ignore_rest && (Attribute_IntAttribute(info.Attrib2[a]) || (TF2Econ_GetAttributeDefinitionString(info.Attrib2[a], "description_format", info.Classname, sizeof(info.Classname)) && StrContains(info.Classname, "additive")!=-1)))
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
		if(i_CurrentEquippedPerk[client] & PERK_HASTY_HOPS)
		{
			//dont give it if it doesnt have it.
			if(Attributes_Has(entity, 97))
				Attributes_SetMulti(entity, 97, 0.7);
		}

		if(i_CurrentEquippedPerk[client] & PERK_MORNING_COFFEE)
		{
			if(Attributes_Has(entity, 6))
				Attributes_SetMulti(entity, 6, 0.85);
		}

		//DEADSHOT!
		if(i_CurrentEquippedPerk[client] & PERK_MARKSMAN_BEER)
		{	
			//dont give it if it doesnt have it.
			if(Attributes_Has(entity, 103))
				Attributes_SetMulti(entity, 103, 1.2);
				
			if(Attributes_Has(entity, 106))
				Attributes_SetMulti(entity, 106, 0.8);
		}

		//Regene Berry!
		if(i_CurrentEquippedPerk[client] & PERK_REGENE)
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

		SkillTree_GiveItem(client, entity);
		Rogue_GiveItem(client, entity);
		Waves_GiveItem(entity);

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

		if(Attributes_Get(entity, 4015, 0.0) >= 1.0)
		{
			SetEntPropFloat(entity, Prop_Send, "m_flNextPrimaryAttack", FAR_FUTURE);
		}
		if(Attributes_Get(entity, Attrib_SetSecondaryDelayInf, 0.0) >= 1.0)
		{
			SetEntPropFloat(entity, Prop_Send, "m_flNextSecondaryAttack", FAR_FUTURE);
		}
		
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
		Enable_SuperubersawAlter(client, entity);
		Enable_WeaponArk(client, entity);
		Saga_Enable(client, entity);
//		Enable_WeaponBoard(client, entity);
		Enable_Casino(client, entity);
		Enable_BuffPotion(client, entity);
		Enable_Ludo(client, entity);
		Enable_Rapier(client, entity);
		Enable_Mlynar(client, entity);
		Enable_Obuch(client, entity);
		Enable_Judge(client, entity);
		Enable_SpikeLayer(client, entity);
		Enable_SensalWeapon(client, entity);
		Enable_FusionWeapon(client, entity);
		Wkit_Soldin_Enable(client, entity);
//		Enable_Blemishine(client, entity);
		Gladiia_Enable(client, entity);
		Vampire_KnifesDmgMulti(client, entity);
		Activate_Neuvellete(client, entity);
		SeaMelee_Enable(client, entity);
		Enable_Leper(client, entity);
		Enable_Zealot(client, entity);
		Flagellant_Enable(client, entity);
		Enable_Impact_Lance(client, entity);
		Enable_Trash_Cannon(client, entity);
		Enable_TornadoBlitz(client, entity);
		Enable_Rusty_Rifle(client, entity);
		Enable_Blitzkrieg_Kit(client, entity);
		Activate_Fractal_Kit(client, entity);
		Enable_Quibai(client, entity);
		AngelicShotgun_Enable(client, entity);
		FullMoon_Enable(client, entity);
		Enable_RedBladeWeapon(client, entity);
		Enable_Gravaton_Wand(client, entity);
		Enable_Reiuji_Wand(client, entity);
		Enable_Dimension_Wand(client, entity);
		Enable_Management_Hell_Hoe(client, entity);
		Enable_Management_GrenadeHud(client, entity);
		Enable_HHH_Axe_Ability(client, entity);
		Enable_Messenger_Launcher_Ability(client, entity);
		WeaponNailgun_Enable(client, entity);
		Blacksmith_Enable(client, entity);
		Enable_West_Weapon(client, entity);
		Enable_Victorian_Launcher(client, entity);
		Enable_Chainsaw(client, entity);
		//Activate_Cosmic_Weapons(client, entity);
		Merchant_Enable(client, entity);
		Flametail_Enable(client, entity);
		Ulpianus_Enable(client, entity);
		Enable_WrathfulBlade(client, entity);
		BlacksmithBrew_Enable(client, entity);
		Yakuza_Enable(client, entity);
		Enable_SkadiWeapon(client, entity);
		Enable_Hunting_Rifle(client, entity);
		Weapon_Anti_Material_Rifle_Deploy(client, entity);
		Walter_Enable(client, entity);
		Enable_CastleBreakerWeapon(client, entity);
		Purnell_Enable(client, entity);
		Medigun_SetModeDo(client, entity);
		Cheese_Enable(client, entity);
		Ritualist_Enable(client, entity);

		//give all revelant things back
		WeaponSpawn_Reapply(client, entity, StoreWeapon[entity]);
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

void Store_RemoveSpecificItem(int client, const char[] name, bool UpdateSlots = false)
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
			if(UpdateSlots)
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
			TranslateItemName(client, item.Name, info.Custom_Name, info.Custom_Name, sizeof(info.Custom_Name));
			PrintToChat(client, info.Custom_Name);
			found = true;
		}
	}
	return found;
}

int Store_GetItemName(int index, int client = 0, char[] buffer, int leng, bool translate = true)
{
	static Item item;
	StoreItems.GetArray(index, item);

	int level = item.Owned[client] - 1;
	if(level < 0)
		level = 0;
	
	static ItemInfo info;
	item.GetItemInfo(level, info);

	if(translate)
		return TranslateItemName(client, item.Name, info.Custom_Name, buffer, leng);
	
	if(info.Custom_Name[0])
		return strcopy(buffer, leng, info.Custom_Name);
	
	return strcopy(buffer, leng, item.Name);
}

int TranslateItemName(int client, const char[] name, const char[] Custom_Name = "", char[] buffer, int length)
{
	if(Custom_Name[0])
	{
		if(TranslationPhraseExists(Custom_Name))
			return Format(buffer, length, "%T", Custom_Name, client);
		
		return strcopy(buffer, length, Custom_Name);
	}
	else if(TranslationPhraseExists(name))
	{
		return Format(buffer, length, "%T", name, client);
	}

	return strcopy(buffer, length, name);
}

/*
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
				Format(buffer, sizeof(buffer), "%T", Custom_Name, client);
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
				Format(buffer, sizeof(buffer), "%T", name, client);
			}
			else
			{
				return name;
			}
		}
	}
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
			Format(buffer, sizeof(buffer), "%T", Rogue_Desc, client);
		}
		else
		{
			Format(buffer, sizeof(buffer), "%s", Rogue_Desc, client);
		}
	}
	else
	{
		if(TranslationPhraseExists(Desc))
		{
			Format(buffer, sizeof(buffer), "%T", Desc, client);
		}
		else
		{
			Format(buffer, sizeof(buffer), "%s", Desc, client);
		}
	}

	return buffer;
}

char[] TranslateItemDescription_Long(int client, const char Desc[256], const char Rogue_Desc[256])
{
	static int ServerLang = -1;
	if(ServerLang == -1)
		ServerLang = GetServerLanguage();
	
	char buffer[512]; 

	if(Rogue_Mode() && Rogue_Desc[0])
	{
		if(TranslationPhraseExists(Desc))
		{
			Format(buffer, sizeof(buffer), "%T", Rogue_Desc, client);
		}
		else
		{
			Format(buffer, sizeof(buffer), "%s", Rogue_Desc, client);
		}
	}
	else
	{
		if(TranslationPhraseExists(Desc))
		{
			Format(buffer, sizeof(buffer), "%T", Desc, client);
		}
		else
		{
			Format(buffer, sizeof(buffer), "%s", Desc, client);
		}
	}

	return buffer;
}
*/
static void ItemCost(int client, Item item, int &cost)
{
	bool Setup = !Waves_Started() || (!Rogue_NoDiscount() && !Construction_Mode() && Waves_InSetup());
	bool GregSale = false;

	//these should account for selling.
	int scaled = item.Scaled[client];
	if(scaled > item.MaxScaled)
		scaled = item.MaxScaled;
	
	cost += item.Scale * scaled; 
	cost += item.CostPerWave * Waves_GetRoundScale();

	if(Rogue_UnlockStore() && !item.NPCSeller && !item.RogueAlwaysSell && !CvarInfiniteCash.BoolValue)
	{
		cost = RoundToNearest(float(cost) * 1.2); 
	}
	static ItemInfo info;
	item.GetItemInfo(0, info);
	//NEVER GO ON SALE, ALWAYS SAME COST.
	if(StarterCashMode[client])
	{
		if(!item.StaleCost)
		{
			if(StartCash < 750 && (cost <= 1000 || info.Cost_Unlock <= 1000)) //give super discount for normal waves
			{
				cost = RoundToCeil(float(cost) * 0.35);
			}
			else 
			{
				cost = RoundToCeil(float(cost) * 0.7);	//keep normal discount for waves that have other starting cash.
			}
		}
		else
		{
			cost = RoundToCeil(float(cost) * 0.7);
		}
		return;
	}
		
	if(!item.StaleCost)
	{
		//int original_cost_With_Sell = RoundToCeil(float(cost) * SELL_AMOUNT);
		
		//make sure anything thats additive is on the top, so sales actually help!!
		if(IsValidEntity(EntRefToEntIndex(SalesmanAlive)))
		{
			if(b_SpecialGrigoriStore && !item.BoughtBefore[client])
			{
				//during maps where he alaways sells, always sell!
				//If the client bought this weapon before, do not offer the discount anymore.
				if(item.NPCSeller_WaveStart > 0 || item.NPCSeller)
				{
					cost = RoundToCeil(float(cost) * item.NPCSeller_Discount);
				}
				
				if(item.NPCSeller)
					GregSale = true;
			}
		}
		
		//allow greg sales here.
		if(Setup && !GregSale)
		{
			cost = RoundToCeil(float(cost) * 0.9);
		}
		/*
		if(!Rogue_Mode() && (CurrentRound != 0 || CurrentWave != -1) && cost)
		{
			switch(CurrentPlayers)
			{
				case 0:
					CheckAlivePlayers();
				
				case 1:
					cost = RoundToNearest(float(cost) * 0.9);
				
				case 2:
					cost = RoundToNearest(float(cost) * 0.92);
				
				case 3:
					cost = RoundToNearest(float(cost) * 0.95);
			}
		}
		*/
			
	}
	
	//Keep this here, both of these make sure that the item doesnt go into infinite cost, and so it doesnt go below the sell value, no inf money bug!
	if(item.MaxCost > 0 && cost > item.MaxCost)
	{
		cost = item.MaxCost;
	}

	if(Rogue_Mode())
	{
		Rogue_Curse_StorePriceMulti(cost, (item.NPCSeller_WaveStart > 0 || item.NPCSeller));
	//	Rogue_Rift_StorePriceMulti(cost, (item.NPCSeller_WaveStart > 0 || item.NPCSeller));
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

static stock void ItemCostPap(const Item item, int &cost)
{
	if(Rogue_Mode())
	{
		if(Rogue_UnlockStore() && item.NPCSeller)
			cost = RoundFloat(cost * item.NPCSeller_Discount);
		
		bool NotFoundCost = false;
		if(Rogue_UnlockStore())
		{
			if(item.ChildKit)
			{
				static Item parent;
				StoreItems.GetArray(item.Section, parent);

				if(!parent.NPCSeller && !parent.RogueAlwaysSell)
					NotFoundCost = true;
			}
			else if(!item.NPCSeller && !item.RogueAlwaysSell)
			{
				NotFoundCost = true;
			}
		}
		if(NotFoundCost)
		{
			cost = RoundToNearest(float(cost) * 1.2); 
		}
		Rogue_Curse_PackPriceMulti(cost);
	//	Rogue_Rift_PackPriceMulti(cost);
	}
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
	Force_ExplainBuffToClient(client, "Explain Building Cash", true);
	if(building && GameRules_GetRoundState() == RoundState_BetweenRounds && StartCash < 750)
	{
		if(!CashSpentGivePostSetupWarning[client])
		{
			CPrintToChat(client,"{darkgrey}%T","Pre Setup Cash Gain Hint", client);
			CashSpentGivePostSetupWarning[client] = true;
		}
		int CreditsGive = credits / 2;
		CashSpentGivePostSetup[client] += CreditsGive;
		CashSpent[client] -= CreditsGive;
		CashReceivedNonWave[client] += CreditsGive;
	}
	else
	{
		CashSpent[client] -= credits;
		CashReceivedNonWave[client] += credits;
	}
}

void GrantCreditsBack(int client)
{
	CashReceivedNonWave[client] += CashSpentGivePostSetup[client];
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
		if(info.NoSafeClip)
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
	if(LastStoreMenu[client] && LastStoreMenu_Store[client] && (LastStoreMenu[client] + 3.0) < GetGameTime())
	{
		MenuPage(client, CurrentMenuItem[client]);
	}
}

bool DisplayMenuAtCustom(Menu menu, int client, int item)
{
	int count = menu.ItemCount;
	int base = (item / 7 * 7);
	char data[16], buffer[64];
	bool next = count > (base + 7);
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
		Format(buffer, sizeof(buffer), "%T", "Previous", client);

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
		Format(buffer, sizeof(buffer), "%T", "Back", client);

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
	else
	{
		int pos = base + 7;
		if(count > pos)
		{
			menu.InsertItem(pos, "_back", buffer, ITEMDRAW_SPACER);
			count++;
		}
		else
		{
			while(count < pos)
			{
				menu.AddItem("_back", buffer, ITEMDRAW_SPACER);
				count++;
			}

			menu.AddItem("_back", buffer, ITEMDRAW_SPACER);
			count++;
		}
	}

	if(next)
	{
		Format(buffer, sizeof(buffer), "%T", "Next", client);

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

	Format(buffer, sizeof(buffer), "%T", "Exit", client);

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
	return CheckEntitySlotIndex(index, slot, entity, 1);
}

static bool CheckEntitySlotIndex(int index, int slot, int entity, int costOfUpgrade)
{
	switch(index)
	{
		case 0, 1, 2:
		{
			if(i_IsAloneWeapon[entity] && costOfUpgrade != 0)
				return false;
			
			if(index == slot && !i_IsWandWeapon[entity] && !i_IsWrench[entity])
				return true;
		}
		case 6:
		{
			if(i_IsAloneWeapon[entity] && costOfUpgrade != 0)
				return false;
			
			if(slot == TFWeaponSlot_Secondary || (slot == TFWeaponSlot_Melee && !i_IsWandWeapon[entity] && !i_IsWrench[entity]))
				return true;
		}
		case 7:
		{
			if(i_IsAloneWeapon[entity] && costOfUpgrade != 0)
				return false;
			
			if(slot == TFWeaponSlot_Primary || slot == TFWeaponSlot_Secondary)
				return true;
		}
		case 8:
		{
			if(i_IsAloneWeapon[entity] && costOfUpgrade != 0)
				return false;
			
			if(i_IsWandWeapon[entity])
				return true;
		}
		case 9:
		{
			if(i_IsAloneWeapon[entity] && costOfUpgrade != 0)
				return false;
			
			if(slot == TFWeaponSlot_Secondary || (slot == TFWeaponSlot_Melee && !i_IsWandWeapon[entity]))
				return true;
		}
		case 10:
		{
			return true;
		}
		case 11:
		{
			if(i_IsAloneWeapon[entity] && costOfUpgrade != 0)
				return false;

			if(i_IsSupportWeapon[entity])
				return true;
		}
		case 12:
		{
			if(i_IsKitWeapon[entity])
				return true;
		}
	}

	return false;
}


void ResetStoreMenuLogic(int client)
{
	LastStoreMenu[client] = 0.0;
	AnyMenuOpen[client] = 0.0;
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


static ArrayList List_TempApplyWeaponPer[MAXPLAYERS];

/*
	Example:

	static TempAttribStore TempStoreAttrib;

	TempStoreAttrib.Attribute = 6;
	TempStoreAttrib.Value = 0.75;
	TempStoreAttrib.GameTimeRemoveAt = GetGameTime() + 5.0; //5 second duration
	TempStoreAttrib.Weapon_StoreIndex = StoreWeapon[weapon];
	TempStoreAttrib.Apply_TempAttrib(client, weapon);

	//gives attackspeed for 5 seconds with an increase of 25%!


*/
enum struct TempAttribStore
{
	int Attribute;
	float Value;
	float GameTimeRemoveAt;
	int Weapon_StoreIndex;
	int ClientOnly_ResetCountSave;
	/*
	Function FuncBeforeApply;
	Function FuncAfterApply;
	*/
	void Apply_TempAttrib(int client, int weapon)
	{
		ApplyTempAttrib_Internal(weapon, this.Attribute, this.Value, this.GameTimeRemoveAt - GetGameTime(), ClientAttribResetCount[client]);
		if(!List_TempApplyWeaponPer[client])
			List_TempApplyWeaponPer[client] = new ArrayList(sizeof(TempAttribStore));

		List_TempApplyWeaponPer[client].PushArray(this);
	}
}

//on map restart
void ClearAllTempAttributes()
{
	for(int c = 0; c < MAXPLAYERS; c++)
	{
		delete List_TempApplyWeaponPer[c];
	}
}

void WeaponSpawn_Reapply(int client, int weapon, int storeindex)
{
	if(!List_TempApplyWeaponPer[client])
	{
		return;
	}
	static TempAttribStore TempStoreAttrib;
	int length = List_TempApplyWeaponPer[client].Length;
	for(int i; i<length; i++)
	{
		List_TempApplyWeaponPer[client].GetArray(i, TempStoreAttrib);
		if(TempStoreAttrib.GameTimeRemoveAt < GetGameTime())
		{
			List_TempApplyWeaponPer[client].Erase(i);
			i--;
			length--;
			continue;
		}
		if(storeindex == TempStoreAttrib.Weapon_StoreIndex)
		{
			ApplyTempAttrib_Internal(weapon, TempStoreAttrib.Attribute, TempStoreAttrib.Value, TempStoreAttrib.GameTimeRemoveAt - GetGameTime(), ClientAttribResetCount[client]);
			//Give all the things needed to the weapon again.
		}
	}
	//????
}

//this is ONLY used for casino
void Store_WeaponUpgradeByOnePap(int client, int weapon)
{
	static Item item;
	StoreItems.GetArray(StoreWeapon[weapon], item);
	if(item.Owned[client])
	{
		item.Owned[client]++;
		StoreItems.SetArray(StoreWeapon[weapon], item);
		TF2_StunPlayer(client, 0.0, 0.0, TF_STUNFLAG_SOUND, 0);
		Store_ApplyAttribs(client);
		Store_GiveAll(client, GetClientHealth(client));
	}
}
int GetAmmoType_WeaponPrimary(int weapon)
{
	return OriginalWeapon_AmmoType[weapon];
}



void TryAndSellOrUnequipItem(int index, Item item, int client, bool ForceUneqip, bool PlaySound, bool IgnoreRestriction = false)
{
	if(!item.Owned[client])
		return;
		
	ItemInfo info;
	int level = item.Owned[client] - 1;
	if(item.ParentKit)
		level = 0;
	
	item.GetItemInfo(level, info);
	if((info.Cost <= 0 || ForceUneqip) && (item.Equipped[client] && item.GregOnlySell != 2))
	{
		int active_weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		if(active_weapon > MaxClients)
		{
			char buffer[64];
			GetEntityClassname(active_weapon, buffer, sizeof(buffer));
			if(IgnoreRestriction || (GetEntPropFloat(active_weapon, Prop_Send, "m_flNextPrimaryAttack") < GetGameTime() || GetEntPropFloat(active_weapon, Prop_Send, "m_flNextPrimaryAttack") >= FAR_FUTURE) && TF2_GetClassnameSlot(buffer, active_weapon) != TFWeaponSlot_PDA)
			{
				Store_Unequip(client, index);
				
				Store_ApplyAttribs(client);
				Store_GiveAll(client, GetClientHealth(client));	
			}
			else
			{
				if(PlaySound)
					ClientCommand(client, "playgamesound items/medshotno1.wav");	
			}
		}
		return;
	}
	if(!ForceUneqip)
	{
		int active_weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		if(active_weapon > MaxClients)
		{
			char buffer[64];
			GetEntityClassname(active_weapon, buffer, sizeof(buffer));
			if(IgnoreRestriction || (GetEntPropFloat(active_weapon, Prop_Send, "m_flNextPrimaryAttack") < GetGameTime() || GetEntPropFloat(active_weapon, Prop_Send, "m_flNextPrimaryAttack") >= FAR_FUTURE) && TF2_GetClassnameSlot(buffer, active_weapon) != TFWeaponSlot_PDA)
			{

				int sell = item.Sell[client];
				if(item.BuyWave[client] == Waves_GetRoundScale())
					sell = item.BuyPrice[client];
				
				if(sell) //make sure it even can be sold.
				{
					CashSpent[client] -= sell;
					CashSpentTotal[client] -= sell;
					CashSpentLoadout[client] -= sell;
					if(PlaySound)
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
					
				if(PlaySound)
				{
					Store_ApplyAttribs(client);
					Store_GiveAll(client, GetClientHealth(client));
				}
			}
			else
			{
				if(PlaySound)
					ClientCommand(client, "playgamesound items/medshotno1.wav");
			}
		}
	}
}

void ResetClipOfWeaponStore(int weapon, int client, int clipsizeSet)
{
	static Item item;
	StoreItems.GetArray(StoreWeapon[weapon], item);
	item.CurrentClipSaved[client] = clipsizeSet; //Reset clip to 8
	StoreItems.SetArray(StoreWeapon[weapon], item);

}

bool Store_IsWeaponFaction(int client, int weapon, int faction)
{
	if(client <= 0)
		return false;
	if(weapon <= 0)
		return false;
	if(StoreWeapon[weapon] <= 0)
		return false;
		
	static Item item;
	StoreItems.GetArray(StoreWeapon[weapon], item);
	if(!item.Owned[client])
		return false;

	static ItemInfo info;
	if(!item.GetItemInfo(item.Owned[client]-1, info))
		return false;
	
	if(info.WeaponFaction1 == faction)
		return true;
	
	if(info.WeaponFaction2 == faction)
		return true;
	
	return false;
}