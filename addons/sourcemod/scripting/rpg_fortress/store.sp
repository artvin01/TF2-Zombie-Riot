#pragma semicolon 1
#pragma newdecls required

#define SELL_AMOUNT	0.7

enum struct ItemInfo
{
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
	int Attrib[32];
	float Value[32];
	int Attribs;

	int Index2;
	int Attrib2[32];
	float Value2[32];
	int Attribs2;

	int Ammo;
	
	int Reload_ModeForce;

	float DamageFallOffForWeapon; //Can this accept reversed?

	float BackstabCD;
	float BackstabDMGMulti;
	float BackstabHealOverThisTime;
	float BackstabHealTotal;
	bool BackstabLaugh;
	float BackstabDmgPentalty;
	
	Function FuncAttack;
	Function FuncAttackInstant;
	Function FuncAttack2;
	Function FuncAttack3;
	Function FuncReload4;
	Function FuncOnDeploy;
	Function FuncOnHolster;
	Function FuncOnBuy;
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
	
	int SpecialAttribRules;
	int SpecialAttribRules_2;

	int WeaponArchetype;
	int WeaponForceClass;
	
	int CustomWeaponOnEquip;
	int Weapon_Override_Slot;
	int Melee_AttackDelayFrame;
	bool Melee_Allows_Headshots;

	int EntRef;
	int Slot;
	int Store;
	int Owner;
	float Cooldown[3];
	int CurrentClipSaved;
	
	void Self(ItemInfo info)
	{
		info = this;
	}
	
	bool SetupKV(KeyValues kv, const char[] name)
	{
		kv.GetString("classname", this.Classname, sizeof(this.Classname));
		this.Index = kv.GetNum("index");
		this.Index2 = kv.GetNum("index_2");
		this.Ammo = kv.GetNum("ammo");
		this.Reload_ModeForce = kv.GetNum("reload_mode");
		this.DamageFallOffForWeapon		= kv.GetFloat("damage_falloff", 0.9);
		this.BackstabCD				= kv.GetFloat("backstab_cd", 1.5);
		this.BackstabDMGMulti		= kv.GetFloat("backstab_dmg_multi", 0.0);
		this.BackstabHealOverThisTime		= kv.GetFloat("heal_over_this_time", 0.0);
		this.BackstabHealTotal		= kv.GetFloat("backstab_total_heal", 0.0);
		this.BackstabLaugh		= view_as<bool>(kv.GetNum("backstab_laugh", 0));

		/*
		
			//LagCompArgs, instead of harcoding indexes i will use bools and shit.
				
			"lag_comp" 						"0"
			"lag_comp_comp_collision" 		"0"
			"lag_comp_ignore_player" 		"0"
			"lag_comp_dont_move_building" 	"1"
				
			//These are the defaults for anything that shouldnt trigger lag comp at all.
				
		*/
		
		this.NoLagComp				= view_as<bool>(kv.GetNum("lag_comp"));
		this.OnlyLagCompCollision	= view_as<bool>(kv.GetNum("lag_comp_collision"));
		this.OnlyLagCompAwayEnemy	= view_as<bool>(kv.GetNum("lag_comp_away_everything_enemy"));
		this.ExtendBoundingBox		= view_as<bool>(kv.GetNum("lag_comp_extend_boundingbox"));
		this.DontMoveBuildingComp	= view_as<bool>(kv.GetNum("lag_comp_dont_move_building"));
		this.DontMoveAlliedNpcs	= view_as<bool>(kv.GetNum("lag_comp_dont_allied_npc"));
		this.BlockLagCompInternal	= view_as<bool>(kv.GetNum("lag_comp_block_internal"));
		
		
		this.HasNoClip				= view_as<bool>(kv.GetNum("no_clip"));
		this.SemiAuto				= view_as<bool>(kv.GetNum("semi_auto"));
		this.NoHeadshot				= view_as<bool>(kv.GetNum("no_headshot"));
		this.IsWand	= view_as<int>(kv.GetNum("is_a_wand"));
		this.IsWrench	= view_as<bool>(kv.GetNum("is_a_wrench"));
		this.IsAlone	= view_as<bool>(kv.GetNum("ignore_upgrades"));
		this.InternalMeleeTrace	= view_as<bool>(kv.GetNum("internal_melee_trace", 1));
		this.SemiAutoStats_FireRate				= kv.GetFloat("semi_auto_stats_fire_rate");
		this.SemiAutoStats_MaxAmmo				= kv.GetNum("semi_auto_stats_maxAmmo");
		this.SemiAutoStats_ReloadTime			= kv.GetFloat("semi_auto_stats_reloadtime");
		this.WeaponSoundIndexOverride	= view_as<bool>(kv.GetNum("weapon_sound_index_override", 0));

	//	kv.GetString("sound_weapon_override_string", this.WeaponSoundOverrideString, sizeof(this.WeaponSoundOverrideString));
		kv.GetString("model_weapon_override", this.WeaponModelOverride, sizeof(this.WeaponModelOverride));
		kv.GetString("weapon_hud_extra", this.WeaponHudExtra, sizeof(this.WeaponHudExtra));
		
		this.WeaponVMTExtraSetting	= view_as<bool>(kv.GetNum("weapon_vmt_setting", -1));
		this.Weapon_Bodygroup	= view_as<int>(kv.GetNum("weapon_bodygroup", -1));
		this.Weapon_FakeIndex	= view_as<int>(kv.GetNum("weapon_fakeindex", -1));
		this.WeaponSizeOverride			= kv.GetFloat("weapon_custom_size", 1.0);
		this.ThirdpersonAnimModif			= kv.GetFloat("modif_attackspeed_anim", 1.0);
		this.WeaponSizeOverrideViewmodel			= kv.GetFloat("weapon_custom_size_viewmodel", 1.0);
		this.WeaponVolumeStiller			= kv.GetFloat("weapon_volume_stiller", 1.0);
		this.WeaponVolumeRange		= kv.GetFloat("weapon_volume_range", 1.0);
		this.BackstabDmgPentalty			= kv.GetFloat("backstab_multi_dmg_penalty_bosses", 1.0);

		if(this.WeaponModelOverride[0])
		{
			this.WeaponModelIndexOverride = PrecacheModel(this.WeaponModelOverride, true);
		}
		else
		{
			this.WeaponModelIndexOverride = 0;
		}

		//if(this.WeaponSoundOverrideString[0])
		//{
		//	//precache the sound!
		//	PrecacheSound(this.WeaponSoundOverrideString, true);
		//}

		char buffer[256];
		kv.GetString("func_attack", buffer, sizeof(buffer));
		this.FuncAttack = GetFunctionByName(null, buffer);
		
		kv.GetString("func_attack_immediate", buffer, sizeof(buffer));
		this.FuncAttackInstant = GetFunctionByName(null, buffer);
		
		kv.GetString("func_attack2", buffer, sizeof(buffer));
		this.FuncAttack2 = GetFunctionByName(null, buffer);
		
		kv.GetString("func_attack3", buffer, sizeof(buffer));
		this.FuncAttack3 = GetFunctionByName(null, buffer);
		
		kv.GetString("func_reload", buffer, sizeof(buffer));
		this.FuncReload4 = GetFunctionByName(null, buffer);
		
		kv.GetString("func_ondeploy", buffer, sizeof(buffer));
		this.FuncOnDeploy = GetFunctionByName(null, buffer);
		
		kv.GetString("func_onholster", buffer, sizeof(buffer));
		this.FuncOnHolster = GetFunctionByName(null, buffer);
		
		this.CustomWeaponOnEquip 		= kv.GetNum("int_ability_onequip");
		this.Weapon_Override_Slot 		= kv.GetNum("override_weapon_slot", -1);
		this.Melee_AttackDelayFrame 		= kv.GetNum("melee_attack_frame_delay", 12);
		this.Melee_Allows_Headshots 		= view_as<bool>(kv.GetNum("melee_can_headshot", 0));
		this.Attack3AbilitySlot			= kv.GetNum("attack_3_ability_slot");
		
		static char buffers[64][16];
		kv.GetString("attributes", buffer, sizeof(buffer));
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

		this.SpecialAttribRules			= kv.GetNum("attributes_check");
		
		kv.GetString("attributes_2", buffer, sizeof(buffer));
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

		this.SpecialAttribRules_2			= kv.GetNum("attributes_check_2");

		this.WeaponArchetype			= kv.GetNum("weapon_archetype", 0);
		this.WeaponForceClass			= kv.GetNum("viewmodel_force_class", 0);

		kv.GetString("func_onbuy", buffer, sizeof(buffer));
		this.FuncOnBuy = GetFunctionByName(null, buffer);

		this.Slot = kv.GetNum("slot", -2);
		if(this.Slot == -2)
		{
			if(this.Classname[0])
			{
				this.Slot = TF2_GetClassnameSlot(this.Classname);
			}
			else
			{
				this.Slot = -1;
			}
		}

		strcopy(this.Custom_Name, sizeof(this.Custom_Name), name);
		
		this.EntRef = INVALID_ENT_REFERENCE;
		this.Store = 0;

		return true;
	}
}

static ArrayList EquippedItems;
static Function HolsterFunc[MAXPLAYERS] = {INVALID_FUNCTION, ...};

void RpgPluginStart_Store()
{
	RegConsoleCmd("rpg_settings", SettingsStore_Command);
	ClearAllTempAttributes();
}

public Action SettingsStore_Command(int client, int args)
{
	if(client)
	{
		if(Actor_InChatMenu(client))
			return Plugin_Handled;
		
		ReShowSettingsHud(client);
	}
	return Plugin_Handled;
}

int Store_GetStoreOfEntity(int entity)
{
	int pos = EquippedItems.FindValue(EntIndexToEntRef(entity), ItemInfo::EntRef);
	if(pos == -1)
		return 0;
	
	static ItemInfo info;
	EquippedItems.GetArray(pos, info);
	return info.Store;
}

bool Store_EquipItem(int client, KeyValues kv, int index, const char[] name)
{
	bool found;
	static ItemInfo info;
	int length = EquippedItems.Length;
	for(int i; i < length; i++)
	{
		EquippedItems.GetArray(i, info);
		if(info.Owner == client && info.Store == index)
		{
			if(TextStore_GetInv(client, info.Store))
				return true;
			
			found = true;
			break;
		}
	}

	if(!found)
		info.SetupKV(kv, name);

	Store_EquipSlotCheck(client, info.Slot);
	TextStore_EquipSlotCheck(client, info.Slot);
	
	if(found)
		return true;
	
	info.Owner = client;
	info.Store = index;

	Tinker_EquipItem(client, index);

	EquippedItems.PushArray(info);
	return true;
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
		int pos = EquippedItems.FindValue(EntIndexToEntRef(weapon), ItemInfo::EntRef);
		if(pos != -1)
		{
			static ItemInfo info;
			EquippedItems.GetArray(pos, info);

			if(info.FuncOnDeploy != INVALID_FUNCTION)
			{
				Call_StartFunction(null, info.FuncOnDeploy);
				Call_PushCell(client);
				Call_PushCell(weapon);
				Call_PushCell(info.Store);
				Call_Finish();
			}

			HolsterFunc[client] = info.FuncOnHolster;
		}
	}
}

float Ability_Check_Cooldown(int client, int what_slot, int thisWeapon = -1)
{
	int weapon = thisWeapon == -1 ? GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") : thisWeapon;
	if(weapon != -1)
	{
		int pos = EquippedItems.FindValue(EntIndexToEntRef(weapon), ItemInfo::EntRef);
		if(pos != -1)
		{
			static ItemInfo info;
			EquippedItems.GetArray(pos, info);
			
			return info.Cooldown[what_slot - 1] - GetGameTime();
		}
	}
	return 0.0;
}

void Ability_Apply_Cooldown(int client, int what_slot, float cooldown, int thisWeapon = -1)
{
	int weapon = thisWeapon == -1 ? GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") : thisWeapon;
	if(weapon != -1)
	{
		int pos = EquippedItems.FindValue(EntIndexToEntRef(weapon), ItemInfo::EntRef);
		if(pos != -1)
		{
			static ItemInfo info;
			EquippedItems.GetArray(pos, info);
#if defined ZR
			if(MazeatItemHas())
			{
				cooldown *= 0.5;
			}
#endif
			info.Cooldown[what_slot - 1] = cooldown + GetGameTime();

			EquippedItems.SetArray(pos, info);
		}
	}
}

void Store_Reset()
{
	delete EquippedItems;
	EquippedItems = new ArrayList(sizeof(ItemInfo));
}

void Store_EquipSlotCheck(int client, int slot)
{
	if(slot >= 0)
	{
		int length = EquippedItems.Length;
		static ItemInfo info;
		for(int i; i < length; i++)
		{
			EquippedItems.GetArray(i, info);
			if(info.Owner == client && info.Slot == slot)
			{
				if(TextStore_GetInv(client, info.Store))
				{
					SPrintToChat(client, "%s was unequipped", info.Custom_Name);
					TextStore_SetInv(client, info.Store, _, false);
				}
			}
		}
	}
}

void Store_ClientDisconnect(int client)
{
	Store_WeaponSwitch(client, -1);
	
	static ItemInfo info;
	int length = EquippedItems.Length;
	for(int i; i < length; i++)
	{
		EquippedItems.GetArray(i, info);
		if(info.Owner == client)
		{
			EquippedItems.Erase(i--);
			length--;
		}
	}
}

static void ReShowSettingsHud(int client)
{
	char buffer [128];
	SetGlobalTransTarget(client);
	Menu menu2 = new Menu(Settings_MenuPage);
	menu2.SetTitle("%t", "Settings Page");
#if defined ZR
	FormatEx(buffer, sizeof(buffer), "%t", "Armor Hud Setting");
	menu2.AddItem("-2", buffer);
#else
	FormatEx(buffer, sizeof(buffer), "%s", "Stamina Hud Setting");
	menu2.AddItem("-2", buffer);
#endif

	FormatEx(buffer, sizeof(buffer), "%t", "Hurt Hud Setting");
	menu2.AddItem("-8", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Weapon Hud Setting");
	menu2.AddItem("-14", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Notif Hud Setting");
	menu2.AddItem("-20", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Zombie Volume Setting Show");
	menu2.AddItem("-55", buffer);


	FormatEx(buffer, sizeof(buffer), "%t", "Low Health Shake");

	if(b_HudLowHealthShake_UNSUED[client])
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

	FormatEx(buffer, sizeof(buffer), "%t", "Taunt Speed increase");
	if(b_TauntSpeedIncrease[client])
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
	
	menu2.Display(client, MENU_TIME_FOREVER);
}


public void ReShowArmorHud(int client)
{
	char buffer[24];
	SetGlobalTransTarget(client);

	Menu menu2 = new Menu(Settings_MenuPage);
#if defined ZR
	menu2.SetTitle("%t", "Armor Hud Setting Inside",f_ArmorHudOffsetX[client],f_ArmorHudOffsetY[client]);
#else
	menu2.SetTitle("%s\nX:%.3f\nY:%.3f", "Stamina Hud Offset",f_ArmorHudOffsetX[client],f_ArmorHudOffsetY[client]);
#endif
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
					if(f_ArmorHudOffsetX[client] < -1.0)
					{
						f_ArmorHudOffsetX[client] = -1.0;
					}
					ReShowArmorHud(client);
				}
				case -4: //Move Armor Hud Down
				{
					f_ArmorHudOffsetX[client] += 0.005;
					if(f_ArmorHudOffsetX[client] > -0.085)
					{
						f_ArmorHudOffsetX[client] = -0.085;
					}
					ReShowArmorHud(client);
				}
				case -5: //Move Armor Hud Left
				{
					f_ArmorHudOffsetY[client] -= 0.005;
					if(f_ArmorHudOffsetY[client] < -1.0)
					{
						f_ArmorHudOffsetY[client] = -1.0;
					}
					ReShowArmorHud(client);
				}
				case -6: //Move Armor Hud right
				{
					f_ArmorHudOffsetY[client] += 0.005;
					if(f_ArmorHudOffsetY[client] > 1.0)
					{
						f_ArmorHudOffsetY[client] = 1.0;
					}
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
					if(f_HurtHudOffsetX[client] < -1.0)
					{
						f_HurtHudOffsetX[client] = -1.0;
					}
					ReShowHurtHud(client);
				}
				case -10: //Move Armor Hud Down
				{
					f_HurtHudOffsetX[client] += 0.005;
					if(f_HurtHudOffsetX[client] > -0.085)
					{
						f_HurtHudOffsetX[client] = -0.085;
					}
					ReShowHurtHud(client);
				}
				case -11: //Move Armor Hud Left
				{
					f_HurtHudOffsetY[client] -= 0.005;
					if(f_HurtHudOffsetY[client] < 0.1)
					{
						f_HurtHudOffsetY[client] = 0.1;
					}
					ReShowHurtHud(client);
				}
				case -12: //Move Armor Hud right
				{
					if(f_HurtHudOffsetY[client] < 0.1)
					{
						f_HurtHudOffsetY[client] = 0.1;
					}
					f_HurtHudOffsetY[client] += 0.005;
					if(f_HurtHudOffsetY[client] > 0.995)
					{
						f_HurtHudOffsetY[client] = 0.995;
					}
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
					if(f_WeaponHudOffsetX[client] < -1.0)
					{
						f_WeaponHudOffsetX[client] = -1.0;
					}
					ReShowWeaponHud(client);
				}
				case -16: //Move Armor Hud Down
				{
					f_WeaponHudOffsetX[client] += 0.005;
					if(f_WeaponHudOffsetX[client] > 1.0)
					{
						f_WeaponHudOffsetX[client] = 1.0;
					}
					ReShowWeaponHud(client);
				}
				case -17: //Move Armor Hud Left
				{
					f_WeaponHudOffsetY[client] -= 0.005;
					if(f_WeaponHudOffsetY[client] < 0.10)
					{
						f_WeaponHudOffsetY[client] = 0.10;
					}
					ReShowWeaponHud(client);
				}
				case -18: //Move Armor Hud right
				{
					if(f_WeaponHudOffsetY[client] < 0.10)
					{
						f_WeaponHudOffsetY[client] = 0.10;
					}
					f_WeaponHudOffsetY[client] += 0.005;
					if(f_WeaponHudOffsetY[client] > 1.0)
					{
						f_WeaponHudOffsetY[client] = 1.0;
					}
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
					if(f_NotifHudOffsetX[client] < -1.0)
					{
						f_NotifHudOffsetX[client] = -1.0;
					}
					ReShowNotifHud(client);
				}
				case -22: //Move Armor Hud Down
				{
					f_NotifHudOffsetX[client] += 0.005;
					if(f_NotifHudOffsetX[client] > 1.0)
					{
						f_NotifHudOffsetX[client] = 1.0;
					}
					ReShowNotifHud(client);
				}
				case -23: //Move Armor Hud Left
				{
					f_NotifHudOffsetY[client] -= 0.005;
					if(f_NotifHudOffsetY[client] < 0.10)
					{
						f_NotifHudOffsetY[client] = 0.10;
					}
					ReShowNotifHud(client);
				}
				case -24: //Move Armor Hud right
				{
					if(f_NotifHudOffsetY[client] < 0.10)
					{
						f_NotifHudOffsetY[client] = 0.10;
					}
					f_NotifHudOffsetY[client] += 0.005;
					if(f_NotifHudOffsetY[client] > 1.0)
					{
						f_NotifHudOffsetY[client] = 1.0;
					}
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
				case -55: //Show Volume Hud
				{
					ReShowVolumeHud(client);
				}
				case -1: //Move Armor Hud right
				{
					ReShowSettingsHud(client);
				}
			}
		}

	}
	return 0;
}

void Store_ApplyAttribs(int client)
{
	if(!EquippedItems)
		return;
		
	Attributes_RemoveAll(client);
	Stats_ApplyAttribsPre(client);
	
	TFClassType ClassForStats = WeaponClass[client];
	
	StringMap map = new StringMap();
	
	Race race;
	Races_GetRaceByIndex(RaceIndex[client], race);
	Format(c_TagName[client],sizeof(c_TagName[]),race.Name);
	i_TagColor[client] =	{255,255,255,255};

	map.SetValue("201", f_DelayAttackspeedPreivous[client]);
	GetClientName(client, c_NpcName[client], sizeof(c_NpcName[]));

	map.SetValue("353", 1.0);	// No manual building pickup.
	map.SetValue("465", 999.0);	// instant build
	map.SetValue("464", 999.0);	// instant build
	map.SetValue("740", 0.0);	// No Healing from mediguns, allow healing from pickups
	map.SetValue("169", 0.0);	// Complete sentrygun Immunity
	map.SetValue("314", -2.0);	//Medigun uber duration, it has to be a body attribute

	float value;
	char buffer1[12];
	if(!i_ClientHasCustomGearEquipped[client])
	{
		static ItemInfo info;
		char buffer2[32];

		int length = EquippedItems.Length;
		for(int i; i < length; i++)
		{
			EquippedItems.GetArray(i, info);
			if(info.Owner == client && !info.Classname[0])
			{
				if(TextStore_GetInv(client, info.Store))
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
							else if(info.Attrib2[a] < 0 || info.Attrib2[a]==26 || (Attribute_IntAttribute(info.Attrib2[a]) || (TF2Econ_GetAttributeDefinitionString(info.Attrib2[a], "description_format", buffer2, sizeof(buffer2)) && StrContains(buffer2, "additive")!=-1)))
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
						Call_PushCell(info.Store);
						Call_Finish();
					}
				}
				else
				{
					EquippedItems.Erase(i--);
					length--;
				}
			}
		}
	}

	StringMapSnapshot snapshot = map.Snapshot();
	int entity = client;
	int length = snapshot.Length;
	int attribs = 0;
	for(int i; i < length; i++)
	{

		snapshot.GetKey(i, buffer1, sizeof(buffer1));
		if(map.GetValue(buffer1, value))
		{
			int index = StringToInt(buffer1);
			if(index < 0)
			{
				Stats_SetCustomStats(client, index, value);
			}
			else if(Attributes_Set(entity, index, value))
			{
				attribs++;
			}
		}
	}

	Stats_ApplyAttribsPost(client, ClassForStats);
	
	
	Mana_Regen_Level[client] = Attributes_GetOnPlayer(client, 405);
	
	delete snapshot;
	delete map;

	TF2_AddCondition(client, TFCond_Dazed, 0.001);
}

void Store_GiveAll(int client, int health, bool removeWeapons = false)
{
	if(!EquippedItems)
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
		TF2_RegeneratePlayer(client);
		Manual_Impulse_101(client, health);
		return;
	}

	OverridePlayerModel(client);
	TrueStrengthShieldUnequip(client);
	TrueStrengthUnequip(client);
	ChronoShiftUnequipOrDisconnect(client);
	GoldenAgilityUnequip(client);
	FishingEmblemDoubleJumpUnequip(client);

	//stickies can stay, we delete any non spike stickies.
	for( int i = 1; i <= MAXENTITIES; i++ ) 
	{
		if(IsValidEntity(i))
		{
			static char classname[36];
			GetEntityClassname(i, classname, sizeof(classname));
			if(!StrContains(classname, "tf_projectile_pipe_remote"))
			{
				if(GetEntPropEnt(i, Prop_Send, "m_hThrower") == client)
				{
					DoGrenadeExplodeLogic(i);
					RemoveEntity(i);
				}
			}
		}
	}

	if(!i_ClientHasCustomGearEquipped[client])
	{
		TF2_RemoveAllWeapons(client);
	}
	
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
	
	if(!i_ClientHasCustomGearEquipped[client])
	{
		bool found = false;
		bool use = true;

		int length = EquippedItems.Length;
		for(int i; i < length; i++)
		{
			static ItemInfo info;
			EquippedItems.GetArray(i, info);
			if(info.Owner == client)
			{
				if(info.Classname[0] && info.Slot < 3)
				{
					Store_GiveItem(client, i, use, found);
					length = EquippedItems.Length;
				}
			}
		}

		length = EquippedItems.Length;
		for(int i; i < length; i++)
		{
			static ItemInfo info;
			EquippedItems.GetArray(i, info);
			if(info.Owner == client)
			{
				if(info.Classname[0] && info.Slot > 2)
				{
					Store_GiveItem(client, i, use, found);
					length = EquippedItems.Length;
				}
			}
		}
	
		if(!found)
			Store_GiveItem(client, -1, use);
	}

	TextStore_GiveAll(client);
	
	Manual_Impulse_101(client, health);
	ReApplyTransformation(client);
	RPGCore_StaminaAddition(client, 999999999);
	RPGCore_ResourceAddition(client, 999999999);
	if(f_TransformationDelay[client] == FAR_FUTURE)
	{
		f_TransformationDelay[client] = 0.0;
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
		if(EquippedItems.FindValue(EntIndexToEntRef(entity), ItemInfo::EntRef) == -1)
		{
			TF2_RemoveItem(client, entity);
		}
	}
}

int Store_GiveItem(int client, int index, bool &use=false, bool &found=false)
{
	if(!EquippedItems)
	{
		return -1;
	}
	if(!IsPlayerAlive(client))
		return -1;

	int slot = -1;
	int entity = -1;
	static ItemInfo info;

	int length = EquippedItems.Length;

	if(index >= 0 && index < length)
	{
		EquippedItems.GetArray(index, info);
		if(info.Owner == client && TextStore_GetInv(client, info.Store))
		{
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

					i_SavedActualWeaponSlot[entity] = saveslot;
					/*
				//	LogMessage("Weapon Spawned!");
				//	LogMessage("Name of client %N and index %i",client,client);
				//	LogMessage("info.Classname: %s",info.Classname);
				//	LogMessage("GiveWeaponIndex: %i",GiveWeaponIndex);
					char AttributePrint[255];
					for(int i=0; i<info.Attribs; i++)
					{
						Format(AttributePrint,sizeof(AttributePrint),"%s %i ;",AttributePrint, info.Attrib[i]);	
						Format(AttributePrint,sizeof(AttributePrint),"%s %.1f ;",AttributePrint, info.Value[i]);	
					}
					PrintToChatAll("attributes: ''%s''",AttributePrint);
				//	LogMessage("info.Attribs: %i",info.Attribs);
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

				i_CustomWeaponEquipLogic[entity] = 0;
				i_SemiAutoWeapon[entity] = false;
				i_WeaponCannotHeadshot[entity] = false;
				i_WeaponDamageFalloff[entity] = 1.0;
				i_IsAloneWeapon[entity] = false;
				i_IsWandWeapon[entity] = false;
				i_IsWrench[entity] = false;
				i_InternalMeleeTrace[entity] = true;
				
				if(entity > MaxClients)
				{
					if(info.CustomWeaponOnEquip != 0)
					{
						i_CustomWeaponEquipLogic[entity] = info.CustomWeaponOnEquip;
					}
					i_OverrideWeaponSlot[entity] = info.Weapon_Override_Slot;
					i_MeleeAttackFrameDelay[entity] = info.Melee_AttackDelayFrame;
					b_MeleeCanHeadshot[entity] = info.Melee_Allows_Headshots;
					
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
						/*

						//This broke as of 20/12/2024, the 64bit update brok it to be specific.

						//CANT USE AMMO 1 or 2 or something,
						//Allows you to switch to the weapon even though it has no ammo, there is PROOOOOOOOOOOOOOOOOOOBAABLY no weapon in the game that actually uses this
						//IF IT DOES!!! then make an exception, but as far as i know, no need.	
						
						if(info.Ammo != Ammo_Hand_Grenade && info.Ammo != Ammo_Potion_Supply //Excluding Grenades and other chargeable stuff so you cant switch to them if they arent even ready. cus it makes no sense to have it in your hand
						{
							//It varies between 29 and 30, its better to just test it after each update
							//my guess is that the compiler optimiser from valve changes it, since its client and serverside varies
							SetAmmo(client, 29, 99999);
							SetEntProp(entity, Prop_Send, "m_iSecondaryAmmoType", 29);
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
					Format(c_WeaponUseAbilitiesHud[entity],sizeof(c_WeaponUseAbilitiesHud[]),"%s",info.WeaponHudExtra);	
					
					i_WeaponArchetype[entity] 				= info.WeaponArchetype;
					i_WeaponForceClass[entity] 				= info.WeaponForceClass;
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

					info.EntRef = EntIndexToEntRef(entity);
					strcopy(StoreWeapon[entity], sizeof(StoreWeapon[]), info.Custom_Name);
					Tinker_SpawnItem(client, info.Store, entity);
					EquippedItems.SetArray(index, info);

					if(use)
					{
						SetPlayerActiveWeapon(client, entity);
						use = false;
					}
				}
			}
		}
		else if(info.Owner == client)
		{
			EquippedItems.Erase(index);
			length--;
			return entity;
		}
	}
	else
	{
		entity = CreateEntityByName("tf_weapon_fists");

		if(entity > MaxClients)
		{
			SetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex", 5);

			SetEntProp(entity, Prop_Send, "m_bInitialized", 1);
			
			SetEntProp(entity, Prop_Send, "m_iEntityQuality", 0);
			SetEntProp(entity, Prop_Send, "m_iEntityLevel", 1);

			static int offset;
			if(!offset)
			{
				char netclass[64];
				GetEntityNetClass(entity, netclass, sizeof(netclass));
				offset = FindSendPropInfo(netclass, "m_iItemIDHigh");
			}
			
			SetEntData(entity, offset - 8, 0);	// m_iItemID
			SetEntData(entity, offset - 4, 0);	// m_iItemID
			SetEntData(entity, offset, 0);		// m_iItemIDHigh
			SetEntData(entity, offset + 4, 0);	// m_iItemIDLow
			
			DispatchSpawn(entity);
			SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", true);
			SetEntProp(entity, Prop_Send, "m_iAccountID", GetSteamAccountID(client, false));
			i_InternalMeleeTrace[entity] = true;

			Attributes_Set(entity, 1, 0.02);
			Attributes_Set(entity, 5, 1.34);
			Attributes_Set(entity, 263, 0.0);
			Attributes_Set(entity, 264, 0.0);
			EquipPlayerWeapon(client, entity);

			strcopy(StoreWeapon[entity], sizeof(StoreWeapon[]), "Fists");

			if(use)
			{
				SetPlayerActiveWeapon(client, entity);
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

	for(int i; i<length; i++)
	{
		EquippedItems.GetArray(i, info);
		if(info.Owner == client)
		{
			if(!info.Classname[0])
			{
				if(EntityIsAWeapon)
				{
					bool apply = CheckEntitySlotIndex(info.Index, slot, entity);
					
					if(apply)
					{
						for(int a; a<info.Attribs; a++)
						{
							if(info.Attrib[a] < 0)
							{
								Stats_SetCustomStats(entity, info.Attrib[a], info.Value[a]);
								continue;
							}

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

					apply = CheckEntitySlotIndex(info.Index2, slot, entity);
					
					if(apply)
					{
						for(int a; a<info.Attribs2; a++)
						{
							if(info.Attrib2[a] < 0)
							{
								Stats_SetCustomStats(entity, info.Attrib2[a], info.Value2[a]);
								continue;
							}

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

	if(EntityIsAWeapon)
	{
		RPGStore_SetWeaponDamageToDefault(entity, client, info.Classname, true);
		
		if(b_DungeonContracts_SlowerAttackspeed[client])
		{
			Attributes_SetMulti(entity, 6, 1.3);
		}

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
	}
	return entity;
}

void Clip_SaveAllWeaponsClipSizes(int client)
{
	int iea, weapon;
	while(TF2_GetItem(client, weapon, iea))
	{
		ClipSaveSingle(client, weapon);
	}
}
stock void ClipSaveSingle(int client, int weapon)
{
	int index = EquippedItems.FindValue(EntIndexToEntRef(weapon), ItemInfo::EntRef);
	if(index != -1)
	{
		ItemInfo info;
		EquippedItems.GetArray(index, info);
		if(info.CurrentClipSaved == -5)
		{
			info.CurrentClipSaved = 0;
		}
		else
		{
			int iAmmoTable = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
			int GetClip = GetEntData(weapon, iAmmoTable, 4);
			info.CurrentClipSaved = GetClip;
		}
		EquippedItems.SetArray(index, info);
	}
}

stock void Clip_GiveAllWeaponsClipSizes(int client)
{	
	int iea, weapon;
	while(TF2_GetItem(client, weapon, iea))
	{
		Clip_GiveWeaponClipBack(client, weapon);
	}
}

stock void Clip_GiveWeaponClipBack(int client, int weapon)
{
	if(client < 1)
		return;
	
	int index = EquippedItems.FindValue(EntIndexToEntRef(weapon), ItemInfo::EntRef);
	if(index != -1)
	{
		ItemInfo info;
		EquippedItems.GetArray(index, info);

		if(info.HasNoClip)
		{
			return;
		}

		int iAmmoTable = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
		
		SetEntData(weapon, iAmmoTable, info.CurrentClipSaved);

		SetEntProp(weapon, Prop_Send, "m_iClip1", info.CurrentClipSaved); // weapon clip amount bullets
	}
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

void RPGStore_SetWeaponDamageToDefault(int weapon, int client, const char[] classname, bool first = false)
{
	/*
		Todo:
		f_FlatDamagePiercing[attacker] = 1.0;
		Use this for PVP, perhaps its a stat? makes spam fire weapons not shit in pvp.
	*/
	int damageType;

	float damageBase = 65.0;//RpgConfig_GetWeaponDamage(weapon);
	if(i_IsWandWeapon[weapon])
	{
		damageType = 3;
		damageBase = 65.0;
	}
	else
	{
		if(TF2_GetClassnameSlot(classname) == TFWeaponSlot_Melee)	
		{
			damageType = 1;
		}	
		else
		{
			damageType = 2;
		}
	}
	
	static float PreviousValue[MAXENTITIES][5];
	//5 stats at once
	float value = RPGStats_FlatDamageSetStats(client, damageType) / damageBase;

	// Set a new value if we changed

	/* 
		// 4004 is stamina cost
		// 4003 is capacity cost
		// 97 Reload speed
		// 6 Attack speed


		// 2 normal damage
		// 410, mage damage
	*/

	// Damage Bonus
	if(first || value != PreviousValue[weapon][0])
	{
		if(first)
		{
			if(i_IsWandWeapon[weapon])
				Attributes_SetMulti(weapon, 410, value);
			else
				Attributes_SetMulti(weapon, 2, value);
		}
		else
		{
			// Second time we modified, remove what we previously had
			if(i_IsWandWeapon[weapon])
				Attributes_SetMulti(weapon, 410, value / PreviousValue[weapon][0]);
			else
				Attributes_SetMulti(weapon, 2, value / PreviousValue[weapon][0]);
		}

		PreviousValue[weapon][0] = value;
	}

	float AgilityScaling;
	//200 is the max, any higher and you break limits.
	AgilityScaling = AgilityMulti(Stats_Agility(client));
	value = AgilityScaling;
	if(first || value != PreviousValue[weapon][1])
	{
		if(Attributes_Has(weapon, 6))
		{
			if(first)
			{
				Attributes_SetMulti(weapon, 6, value);
			}
			else
			{
				// Second time we modified, remove what we previously had
				Attributes_SetMulti(weapon, 6, value / PreviousValue[weapon][1]);
			}
		}

		PreviousValue[weapon][1] = value;
	}

	value = AgilityScaling;
	if(first || value != PreviousValue[weapon][2])
	{
		if(Attributes_Has(weapon, 97))
		{
			if(first)
			{
				Attributes_SetMulti(weapon, 97, value);
			}
			else
			{
				// Second time we modified, remove what we previously had
				Attributes_SetMulti(weapon, 97, value / PreviousValue[weapon][2]);
			}
		}

		PreviousValue[weapon][2] = value;
	}

	value = AgilityScaling;
	if(first || value != PreviousValue[weapon][3])
	{
		if(Attributes_Has(weapon, 4004))
		{
			if(first)
			{
				Attributes_SetMulti(weapon, 4004, value);
			}
			else
			{
				// Second time we modified, remove what we previously had
				Attributes_SetMulti(weapon, 4004, value / PreviousValue[weapon][3]);
			}
		}

		PreviousValue[weapon][3] = value;
	}

	value = AgilityScaling;
	if(first || value != PreviousValue[weapon][4])
	{
		if(Attributes_Has(weapon, 4003))
		{
			if(first)
			{
				Attributes_SetMulti(weapon, 4003, value);
			}
			else
			{
				// Second time we modified, remove what we previously had
				Attributes_SetMulti(weapon, 4003, value / PreviousValue[weapon][4]);
			}
		}

		PreviousValue[weapon][4] = value;
	}
}

bool Store_SwitchToWeaponSlot(int client, int slot)
{
	int length = EquippedItems.Length;
	for(int i; i < length; i++)
	{
		static ItemInfo info;
		EquippedItems.GetArray(i, info);
		if(info.Owner == client)
		{
			if(info.Classname[0] && info.Slot == slot)
			{
				int entity = EntRefToEntIndex(info.EntRef);
				if(entity != -1)
				{
					SetPlayerActiveWeapon(client, entity);
					return true;
				}
			}
		}
	}

	return false;
}


public float Ammo_HealingSpell(int client, int index, char name[48])
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		HealEntityGlobal(client, client, kv.GetFloat("totalheal"), kv.GetFloat("overheal"), kv.GetFloat("healoverduration"), HEAL_SELFHEAL);

		if(kv.GetNum("staminaregenlevel") > 0)
			RPGCore_StaminaAddition(client, RPGStats_RetrieveMaxStamina(kv.GetNum("staminaregenlevel")));

		if(kv.GetNum("energyregenlevel") > 0)
			RPGCore_ResourceAddition(client, RoundToNearest(RPGStats_RetrieveMaxEnergy(kv.GetNum("energyregenlevel"))));

		int consume_Arg = kv.GetNum("consume", 1);
		if(consume_Arg == 1)
		{
			int amount;
			TextStore_GetInv(client, index, amount);
			TextStore_SetInv(client, index, amount - 1, amount < 2 ? 0 : -1);
			if(amount < 2)
				name[0] = 0;

			kv.GetString("return", name, sizeof(name));
			if(name[0])
				TextStore_AddItemCount(client, name, 1);
		}
		else if(consume_Arg == 0)
		{
			kv.GetString("return", name, sizeof(name));
		}

		static char buffer[PLATFORM_MAX_PATH];
		kv.GetString("sound", buffer, sizeof(buffer));
		if(buffer[0])
			ClientCommand(client, "playgamesound %s", buffer);
		
		TextStore_SetAllItemCooldown(client, 20.0);

		if(consume_Arg > 1)
		{
			return GetGameTime() + float(consume_Arg);
		}
	}
	return FAR_FUTURE;
}


public void Ammo_TagDeploy(int client, int weapon, int index)
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		kv.GetString("tagsforplayer", c_TagName[client],sizeof(c_TagName[]), "Newbie");
		kv.GetColor4("tagsforplayercolor", i_TagColor[client]);
		if(i_TagColor[client][3] == 0)
		{
			i_TagColor[client] =	{255,255,255,255};
		}
	}
}


int GetAmmoType_WeaponPrimary(int weapon)
{
	return OriginalWeapon_AmmoType[weapon];
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

stock void WeaponSpawn_Reapply(int client, int weapon, int storeindex)
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
			if(TF2_GetClassnameSlot(buffer) == slot)
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