#pragma semicolon 1
#pragma newdecls required

static Handle h_KitPurge_Timer[MAXPLAYERS] = {INVALID_HANDLE, ...};

static float fl_KitPurge_Energy[MAXPLAYERS]={0.0, ...};
static float fl_KitPurge_NextHUD[MAXPLAYERS]={0.0, ...};

static int i_KitPurge_Crusher_Ref[MAXPLAYERS]={0, ...};
static int i_KitPurge_Rampager_Ref[MAXPLAYERS]={0, ...};
static bool b_KitPurge_Toogle[MAXPLAYERS]={false, ...};
static int i_KitPurge_Annahilator_Last_Hit_Ref[MAXPLAYERS]={0, ...};
static float fl_KitPurge_Crusher_Last_Hit[MAXPLAYERS]={0.0, ...};
static float fl_KitPurge_Annahilator_Bonus_Damage_Stack[MAXPLAYERS]={0.0, ...};
//static float fl_KitPurge_Annahilator_Damage_Attribute_Origional=[MAXPLAYERS]={0.0, ...};// simply manipulating attribute is not a good idea
static float fl_KitPurge_Annahilator_Tookout_Time[MAXPLAYERS]={0.0, ...};

static Handle Annahilator_Damage_Revert_Timer[MAXPLAYERS]={INVALID_HANDLE, ...};
static Handle Annahilator_Remove_Timer[MAXPLAYERS]={INVALID_HANDLE, ...};
static Handle QuadLauncher_Remove_Timer[MAXPLAYERS]={INVALID_HANDLE, ...};

//			check out cfg file						pap	 0		n		2		3		4		5		6		n		n
static float fl_KitPurge_Annahilator_Max_Hold_Time[9]=	{10.0,	10.0,	12.0,	12.0,	12.0,	12.0,	12.0,	12.0,	15.0};
static float fl_KitPurge_Annahilator_Speed_Penality[9]=	{0.001,	0.001,	0.001,	0.001,	0.001,	0.35,	0.4,	0.4,	0.4};//inverted_percentage, attribute 183
static float fl_KitPurge_Annahilator_Resistance[9]=		{0.5,	0.5,	0.5,	0.5,	0.5,	0.5,	0.5,	0.5,	0.5};//attribute 412
static int fl_KitPurge_QuadLauncher_Rockets[9]=			{2,		2,		2,		2,		2,		3,		4,		4,		4};
static float fl_KitPurge_QuadLauncher_FireSpeed[9]=		{1.0,	1.0,	1.0,	1.0,	1.0,	0.85,	0.85,	0.85,	0.85};
static float fl_KitPurge_Ram_Max_Time[9]=				{3.0,	3.0,	3.0,	3.0,	3.0,	3.0,	6.0,	6.0,	6.0};

static Handle Revert_Weapon_Back_Timer[MAXPLAYERS]={null, ...};
static int attacks_mode[MAXPLAYERS]={12, ...};
static int weapon_id[MAXPLAYERS]={0, ...};
static float QuadSinceLastRemove[MAXPLAYERS]={0.0, ...};

#define PURGE_MAX_ENERGY 500.0
#define PURGE_ENERGY_CLOSE_RANGE 400.0
#define PURGE_ENERGY_CLOSE_RANGE_MULTI_GAIN 1.4
#define PURGE_ENERGY_SHOTGUN 3.0
#define PURGE_ENERGY_RIFLE 1.2

#define PURGE_RAM_BASE_DMG 270.0
#define PURGE_RAM_RADIUS 150.0
#define PURGE_RAM_TIME 3.0
#define PURGE_RAM_SPEED 500.0
#define PURGE_RAM_MAX_HIT 10

#define PURGE_QUADLAUNCHER_MAX_HOLD 7.0

#define PURGE_ANNAHILATOR_ENERGY_REQUIRE 250.0
#define PURGE_QUAD_LAUNCHER_ENERGY_REQUIRE 400.0

#define PURGE_QUADLAUNCHER_COOLDOWN 80.0
#define PURGE_ANNAHILATOR_COOLDOWN 90.0

#define PURGE_ANNAHILATOR_VALID_RANGE 1500.0
#define PURGE_ANNAHILATOR_BONUS_DAMAGE_MAXPERCENT 1.0	//+100% dmg
#define PURGE_ANNAHILATOR_BONUS_DAMAGE_FADE 5.0

#define PURGE_EQUIPMINIGUN "mvm/giant_heavy/giant_heavy_gunwindup.wav"
#define PURGE_REMOVEMINIGUN "mvm/giant_heavy7giant_heavy_gunwinddown.wav"
#define PURGE_QUAD_LAUNCHER_SOUND "mvm/giant_demoman/giant_demoman_grenade_shoot.wav"
#define PURGE_EXPLOSION_SOUND "mvm/mvm_tank_explode.wav"
#define PURGE_SWITCH_SOUND "items/gunpickup2.wav"
#define PURGE_ARMOR_HURT_SOUND "physics/metal/metal_box_impact_bullet1.wav"
#define PURGE_EQUIP_GRENADE "mvm/giant_pyro/giant_pyro_flamethrower_start.wav"

public void PurgeKit_MapStart()
{
	PrecacheSound(PURGE_EQUIPMINIGUN);
	PrecacheSound(PURGE_REMOVEMINIGUN);
	PrecacheSound(PURGE_QUAD_LAUNCHER_SOUND);
	PrecacheSound(PURGE_EXPLOSION_SOUND);
	PrecacheSound(PURGE_SWITCH_SOUND);
	PrecacheSound(PURGE_EQUIP_GRENADE);
}

public void Enable_PurgeKit(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_KIT_PURGE_ANNAHILATOR || i_CustomWeaponEquipLogic[weapon] == WEAPON_KIT_PURGE_MISC)
	{
		//this is a weapon attached to omega, we want to delay getting the stats of the base weapon, 
		//and then apply any and all changes we need.
		int WhatTypeDo = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
		if(WhatTypeDo >= 999)
		{
			KitPurgeGiveAttributes(client, weapon, WhatTypeDo);
			return;
		}
	}
	if(h_KitPurge_Timer[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_KIT_PURGE_CRUSHER)
		{
			i_KitPurge_Crusher_Ref[client] = EntIndexToEntRef(weapon);
			SDKUnhook(client, SDKHook_OnTakeDamage, Weapon_Purging_Owner_OnTakeDamage);
			SDKHook(client, SDKHook_OnTakeDamage, Weapon_Purging_Owner_OnTakeDamage);
			if(IsValidHandle(h_KitPurge_Timer[client]))
				delete h_KitPurge_Timer[client];
			h_KitPurge_Timer[client] = null;
			DataPack pack;
			h_KitPurge_Timer[client] = CreateDataTimer(0.1, Timer_PurgeKit, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
	
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_KIT_PURGE_CRUSHER)
	{
		i_KitPurge_Crusher_Ref[client] = EntIndexToEntRef(weapon);
		SDKHook(client, SDKHook_OnTakeDamage, Weapon_Purging_Owner_OnTakeDamage);
		DataPack pack;
		h_KitPurge_Timer[client] = CreateDataTimer(0.1, Timer_PurgeKit, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		fl_KitPurge_NextHUD[client] = 0.0;
	}
}

public Action Timer_PurgeKit(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Store_RemoveSpecificItem(client, "Purging Grinder");
		Store_RemoveSpecificItem(client, "Purging Annihilator");	
		Store_RemoveSpecificItem(client, "Purging QuadLauncher");
		SDKUnhook(client, SDKHook_OnTakeDamage, Weapon_Purging_Owner_OnTakeDamage);
		
		h_KitPurge_Timer[client] = null;
		/*
		if(Annahilator_Remove_Timer[client] != null)
		{
			if(IsValidHandle(Annahilator_Remove_Timer[client]))
				delete Annahilator_Remove_Timer[client];
			Annahilator_Remove_Timer[client] = null;
		}
		if(Annahilator_Damage_Revert_Timer[client] != null)
		{
			if(IsValidHandle(Annahilator_Damage_Revert_Timer[client]))
				delete Annahilator_Damage_Revert_Timer[client];
			Annahilator_Damage_Revert_Timer[client] = null;
		}
		if(QuadLauncher_Remove_Timer[client] != null)
		{
			if(IsValidHandle(QuadLauncher_Remove_Timer[client]))
				delete QuadLauncher_Remove_Timer[client];
			QuadLauncher_Remove_Timer[client] = null;
		}
		*/
		
		return Plugin_Stop;
	}
	PurgeKit_HUD(client, weapon, false);
	
	//PrintToConsoleAll("m_hActiveWeapon: %d", GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"));
	if(f_OneShotProtectionTimer[client] > GetGameTime() && !b_KitPurge_Toogle[client])
	{
		b_KitPurge_Toogle[client] = true;
		//PurgeKit_GainEnergy(client, 99999.0);
		float clientPos[3];WorldSpaceCenter(client, clientPos);
		float clientAng[3];GetClientEyeAngles(client, clientAng);
		TE_Particle("hightower_explosion", clientPos, NULL_VECTOR, clientAng, -1, _, _, _, _, _, _, _, _, _, 0.0);
		EmitSoundToAll(PURGE_EXPLOSION_SOUND, 0, SNDCHAN_AUTO, 100, _, 1.0);
		
		Explode_Logic_Custom(100.0 * Attributes_Get(weapon, 2, 1.0), client, client, weapon, clientPos, PURGE_ENERGY_CLOSE_RANGE, _, _, _, 999);
		for(int a; a < i_MaxcountNpcTotal; a++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[a]);
			
			if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
			{
				float vecTarget[3]; WorldSpaceCenter(entity, vecTarget);
				float VecSelfNpc[3]; WorldSpaceCenter(client, VecSelfNpc);
				float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
				float knockback = 700.0;
				if(b_thisNpcIsABoss[entity] || b_thisNpcIsARaid[entity])
				{
					knockback = (b_thisNpcIsARaid[entity]) ? 350.0 : 500.0;
				}
				if(flDistanceToTarget <= PURGE_ENERGY_CLOSE_RANGE * PURGE_ENERGY_CLOSE_RANGE)
					Custom_Knockback(client, entity, knockback, true);
			}
		}
	}
	if(f_OneShotProtectionTimer[client] < GetGameTime() && b_KitPurge_Toogle[client])
	{
		b_KitPurge_Toogle[client] = false;
	}
	return Plugin_Continue;
}

public void PurgeKit_HUD(int client, int weapon, bool forced)
{
	if(fl_KitPurge_NextHUD[client] < GetGameTime() || forced)
	{
		int crusherWeapon = weapon;//EntRefToEntIndex(i_KitPurge_Crusher_Ref[client]);
		float annahiCD = Ability_Check_Cooldown(client, 3, crusherWeapon);
		int rampagerWeapon = EntRefToEntIndex(i_KitPurge_Rampager_Ref[client]);
		float quadCD = Ability_Check_Cooldown(client, 3, rampagerWeapon);
		char annahiStat[15],quadStat[15];
		if(annahiCD > 0.0)
		{
			if(Annahilator_Remove_Timer[client] != null)
				annahiStat = "Active";
			else
				annahiStat = "Offline";
		}
		else
			annahiStat = "Online";
		if(quadCD > 0.0)
		{
			if(QuadLauncher_Remove_Timer[client] != null)
				quadStat = "Active";
			else
				quadStat = "Offline";
		}
		else
			quadStat = "Online";
		if(Attributes_Get(weapon, Attrib_PapNumber, 1.0) < 2.0)
			PrintHintText(client, "퍼지 시스템 가동중.\n에너지: [%.0f/%.0f]", fl_KitPurge_Energy[client], PURGE_MAX_ENERGY);
		else if(Attributes_Get(weapon, Attrib_PapNumber, 1.0) < 4.0)
			PrintHintText(client, "퍼지 시스템 가동중.\n에너지: [%.0f/%.0f]\n말살 명령:%s", fl_KitPurge_Energy[client], PURGE_MAX_ENERGY, annahiStat);
		else
			PrintHintText(client, "퍼지 시스템 가동중.\n에너지: [%.0f/%.0f]\n말살 명령:%s\n4연장 로켓:%s", fl_KitPurge_Energy[client], PURGE_MAX_ENERGY, annahiStat, quadStat);
		fl_KitPurge_NextHUD[client] = GetGameTime() + 0.4;
	}
}

public void Weapon_Purging_Rampager(int client, int weapon, bool crit, int slot)
{//from original rampager
	if(weapon >= MaxClients)
	{
		weapon_id[client] = EntIndexToEntRef(weapon);
		attacks_mode[client] += -1;
				
		if (attacks_mode[client] <= 4)
		{
			attacks_mode[client] = 4;
		}
		float dmgBalance = PurgingRampagerAttackSpeed(attacks_mode[client]) / PurgingRampagerAttackSpeed(attacks_mode[client] + 1);
		
		if(attacks_mode[client] < 8)
			Attributes_Set(weapon, 1, dmgBalance);
		Attributes_Set(weapon, 396, PurgingRampagerAttackSpeed(attacks_mode[client]));
		if(Revert_Weapon_Back_Timer[client] != null)
			delete Revert_Weapon_Back_Timer[client];
		Revert_Weapon_Back_Timer[client] = CreateTimer(3.0, Reset_weapon_purging_rampager, client);
	}
}

public void Weapon_Purging_QuadLauncher(int client, int weapon, bool crit, int slot)
{
	if(!IsValidEntity(client))
		return;
	int pap = 0;
	int KitWeaponMain = EntRefToEntIndex(i_KitPurge_Crusher_Ref[client]);
	if(IsValidEntity(KitWeaponMain))
		pap = RoundToFloor(Attributes_Get(KitWeaponMain, Attrib_PapNumber, 1.0));
	EmitSoundToAll(PURGE_QUAD_LAUNCHER_SOUND, client, SNDCHAN_STATIC, 80, _, 0.8);
	//Client_Shake(client, 0, 35.0, 20.0, 0.8);
		
	float speed = 1500.0;
	float damage = 100.0;
	damage *= Attributes_Get(weapon, 1, 1.0);

	damage *= Attributes_Get(weapon, 2, 1.0);
			
	speed *= Attributes_Get(weapon, 103, 1.0);
		
	speed *= Attributes_Get(weapon, 104, 1.0);
		
	speed *= Attributes_Get(weapon, 475, 1.0);
			
	float extra_accuracy = 2.0;
		
	extra_accuracy *= Attributes_Get(weapon, 106, 1.0);
			
	int team = GetClientTeam(client);
			
	for (int repeat = 1; repeat <= fl_KitPurge_QuadLauncher_Rockets[pap]; repeat++)
	{
		int entity = CreateEntityByName("tf_projectile_rocket");
		if(IsValidEntity(entity))
		{
			static float pos[3], ang[3], vel_2[3], shootPos[3];
			GetClientEyeAngles(client, ang);
			GetClientEyePosition(client, pos);
			WorldSpaceCenter(client, shootPos);
					
			switch(repeat)
			{
				case 1:
				{
					ang[0] += -extra_accuracy;
					ang[1] += extra_accuracy;
				}
				case 2:
				{
					ang[0] += extra_accuracy;
					ang[1] += extra_accuracy;
				}
				case 3:
				{
					ang[0] += extra_accuracy;
					ang[1] += -extra_accuracy;
				}
				case 4:
				{
					ang[0] += -extra_accuracy;
					ang[1] += -extra_accuracy;
				}
			}
			
			if(fl_KitPurge_QuadLauncher_Rockets[pap] != 4)
			{
				ang[0] += (GetRandomInt(0, 1) ? -1 : 1) * GetURandomFloat() * extra_accuracy;
				ang[1] += (GetRandomInt(0, 1) ? -1 : 1) * GetURandomFloat() * extra_accuracy;
			}
			ang[2] += 2.0;
			GetAngleVectors(ang, vel_2, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(vel_2, speed);
			//vel_2[2] *= -1;
					
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
			SetEntProp(entity, Prop_Send, "m_iTeamNum", team, 1);
			SetEntProp(entity, Prop_Send, "m_nSkin", (team-2));
			SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, damage, true);
			SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher",weapon);
					
			SetVariantInt(team);
			AcceptEntityInput(entity, "TeamNum", -1, -1, 0);
			SetVariantInt(team);
			AcceptEntityInput(entity, "SetTeam", -1, -1, 0); 
					
			SetEntPropEnt(entity, Prop_Send, "m_hLauncher", weapon);
	
			DispatchSpawn(entity);
			TeleportEntity(entity, shootPos, ang, vel_2);
			SetEntityCollisionGroup(entity, 24);
			Set_Projectile_Collision(entity);
		}
	}
}

public void Weapon_Purging_Rampager_M2(int client, int weapon, bool crit, int slot)
{
	EmitSoundToClient(client, PURGE_SWITCH_SOUND, client, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	FakeClientCommandEx(client, "use tf_weapon_shotgun_hwg");
}

public void Weapon_Purging_Crusher_M2(int client, int weapon, bool crit, int slot)
{
	EmitSoundToClient(client, PURGE_SWITCH_SOUND, client, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	FakeClientCommandEx(client, "use tf_weapon_smg");
}

public void Weapon_Purging_Rampager_R(int client, int weapon, bool crit, int slot)
{
	i_KitPurge_Rampager_Ref[client] = EntIndexToEntRef(weapon);
	if(!IsValidEntity(client))
		return;
	if(Ability_Check_Cooldown(client, slot) > 0.0 && !CvarInfiniteCash.BoolValue)
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);

		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
	
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		return;
	}
	if(!(GetClientButtons(client) & IN_DUCK) && NeedCrouchAbility(client))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Crouch for ability");	
		return;
	}
	
	if(fl_KitPurge_Energy[client] < PURGE_QUAD_LAUNCHER_ENERGY_REQUIRE && !CvarInfiniteCash.BoolValue)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "You need %.0f energy to take out QuadLauncher!", PURGE_QUAD_LAUNCHER_ENERGY_REQUIRE);
		return;
	}
	
	int pap = RoundToFloor(Attributes_Get(weapon, Attrib_PapNumber, 1.0));
	if( pap > 3 || CvarInfiniteCash.BoolValue)
	{
		PurgeKit_GainEnergy(client, -PURGE_QUAD_LAUNCHER_ENERGY_REQUIRE);
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, PURGE_QUADLAUNCHER_COOLDOWN);
		int weaponN = Store_GiveSpecificItem(client, "Purging QuadLauncher");
		EmitSoundToAll(PURGE_EQUIP_GRENADE, client, SNDCHAN_STATIC, 80, _, 0.8);
		ResetClipOfWeaponStore(weaponN, client, 9999);
		SetEntData(weaponN, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), 100);
		if(QuadLauncher_Remove_Timer[client] != null)
		{
			if(IsValidHandle(QuadLauncher_Remove_Timer[client]))
				delete QuadLauncher_Remove_Timer[client];
			QuadLauncher_Remove_Timer[client] = null;
		}
		QuadSinceLastRemove[client] = GetGameTime() + PURGE_QUADLAUNCHER_MAX_HOLD;
		QuadLauncher_Remove_Timer[client] = 
			CreateTimer(QuadSinceLastRemove[client] - GetGameTime(), Weapon_Purging_QuadLauncher_Remove_Later, EntIndexToEntRef(weaponN), TIMER_FLAG_NO_MAPCHANGE);

			
	}
}

public void Weapon_Purging_Crusher_R(int client, int weapon, bool crit, int slot)
{
	i_KitPurge_Crusher_Ref[client] = EntIndexToEntRef(weapon);
	if(!IsValidEntity(client))
		return;
	if(Ability_Check_Cooldown(client, slot) > 0.0 && !CvarInfiniteCash.BoolValue)
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);

		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
	
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		return;
	}
	if(!(GetClientButtons(client) & IN_DUCK) && NeedCrouchAbility(client))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Crouch for ability");	
		return;
	}
	
	if(fl_KitPurge_Energy[client] < PURGE_ANNAHILATOR_ENERGY_REQUIRE && !CvarInfiniteCash.BoolValue)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "You need %.0f energy to take out Annihilator!", PURGE_ANNAHILATOR_ENERGY_REQUIRE);
		return;
	}
	
	int pap = RoundToFloor(Attributes_Get(weapon, Attrib_PapNumber, 1.0));
	if( pap > 1 || CvarInfiniteCash.BoolValue)
	{
		PurgeKit_GainEnergy(client, -PURGE_ANNAHILATOR_ENERGY_REQUIRE);
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, PURGE_ANNAHILATOR_COOLDOWN);
		int weaponN = Store_GiveSpecificItem(client, "Purging Annihilator");
		ResetClipOfWeaponStore(weaponN, client, 9999);
		fl_KitPurge_Annahilator_Tookout_Time[client] = (GetGameTime() + fl_KitPurge_Annahilator_Max_Hold_Time[pap]);
		if(Annahilator_Remove_Timer[client] != null)
		{
			if(IsValidHandle(Annahilator_Remove_Timer[client]))
				delete Annahilator_Remove_Timer[client];
			Annahilator_Remove_Timer[client] = null;
		}
		EmitSoundToAll(PURGE_EQUIPMINIGUN, client, SNDCHAN_STATIC, 80, _, 0.8);
		DataPack pack = new DataPack();
		Annahilator_Remove_Timer[client] = 
			CreateTimer(0.1, Weapon_Purging_Annahilator_Remove_Later, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(weaponN));
	}
}

public void Weapon_Purging_Annahilator_R(int client, int weapon, bool crit, int slot)
{
	FakeClientCommandEx(client, "use tf_weapon_shotgun_hwg");
	Store_RemoveSpecificItem(client, "Purging Annihilator");
	
	Weapon_Purging_Annahilator_Remove(EntIndexToEntRef(weapon), client);
	TF2_RemoveItem(client, weapon);
}

public float Npc_OnTakeDamage_Purging_Annahilator(int attacker, int victim, float damage, int weapon, int damagetype)
{//from Npc_OnTakeDamage_Siccerino
	if(!(damagetype & DMG_BULLET))
		return damage;
		
	damage *= 1.0 + fl_KitPurge_Annahilator_Bonus_Damage_Stack[attacker];
	
	if(!CheckInHud())
	{
		if(i_KitPurge_Annahilator_Last_Hit_Ref[attacker] == EntIndexToEntRef(victim))
		{
			if(fl_KitPurge_Annahilator_Bonus_Damage_Stack[attacker] + 0.05 <= PURGE_ANNAHILATOR_BONUS_DAMAGE_MAXPERCENT)
				fl_KitPurge_Annahilator_Bonus_Damage_Stack[attacker] += 0.05;
			else
				fl_KitPurge_Annahilator_Bonus_Damage_Stack[attacker] = PURGE_ANNAHILATOR_BONUS_DAMAGE_MAXPERCENT;
			if(Annahilator_Damage_Revert_Timer[attacker] != null)
			{
				if(IsValidHandle(Annahilator_Damage_Revert_Timer[attacker]))
					delete Annahilator_Damage_Revert_Timer[attacker];
				Annahilator_Damage_Revert_Timer[attacker] = null;
			}
			
			DataPack pack;
			Annahilator_Damage_Revert_Timer[attacker] = 
				CreateDataTimer(PURGE_ANNAHILATOR_BONUS_DAMAGE_FADE, Purging_Annahilator_damageBonus_Fade, pack, TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(EntIndexToEntRef(attacker));
			//pack.WriteCell(EntIndexToEntRef(victim));
			//pack.WriteFloat(0.1);
		}
		else
		{
			//if(fl_KitPurge_Annahilator_Bonus_Damage_Stack[attacker] - 0.2 >= 0.0)
			//	fl_KitPurge_Annahilator_Bonus_Damage_Stack[attacker] -= 0.2;
			fl_KitPurge_Annahilator_Bonus_Damage_Stack[attacker] = 0.0;
			i_KitPurge_Annahilator_Last_Hit_Ref[attacker] = EntIndexToEntRef(victim);
		}
	}
	
	return damage;
}

public Action Weapon_Purging_Owner_OnTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(Armor_Charge[client] > 0)
	{
		EmitSoundToClient(client, PURGE_ARMOR_HURT_SOUND, _, _, _, _, 1.0);
	}
	return Plugin_Continue;
}

public Action Reset_weapon_purging_rampager(Handle cut_timer, int client)
{
	if(IsValidClient(client))
	{
		attacks_mode[client] = 12;
		if(IsValidEntity(EntRefToEntIndex(weapon_id[client])))
		{
			Attributes_Set((EntRefToEntIndex(weapon_id[client])), 1, 1.0);
			Attributes_Set((EntRefToEntIndex(weapon_id[client])), 396, PurgingRampagerAttackSpeed(attacks_mode[client]));
			ClientCommand(client, "playgamesound items/medshotno1.wav");
		}
	}
	Revert_Weapon_Back_Timer[client] = null;
	return Plugin_Handled;
}

public void PurgeKit_GainEnergy(int client, float energy)
{
	if(energy)
	{
		fl_KitPurge_Energy[client] += energy;

		if(fl_KitPurge_Energy[client] < 0.0)
		{
			fl_KitPurge_Energy[client] = 0.0;
		}
		else
		{
			if(fl_KitPurge_Energy[client] > PURGE_MAX_ENERGY)
				fl_KitPurge_Energy[client] = PURGE_MAX_ENERGY;
		}
	}
}

public void PurgeKit_NPCTakeDamage_Rampager(int attacker, int victim, float &damage, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_KIT_PURGE_RAMPAGER)
	{
		if(fl_KitPurge_Crusher_Last_Hit[attacker] == GetGameTime(attacker))
			return;
		fl_KitPurge_Crusher_Last_Hit[attacker] = GetGameTime(attacker);
		float attackerPos[3],victimPos[3];
		WorldSpaceCenter(attacker, attackerPos);
		WorldSpaceCenter(victim, victimPos);
		float flDistanceToTarget = GetVectorDistance(attackerPos, victimPos, true);
		if(flDistanceToTarget < PURGE_ENERGY_CLOSE_RANGE * PURGE_ENERGY_CLOSE_RANGE)
			PurgeKit_GainEnergy(attacker, PURGE_ENERGY_RIFLE * PURGE_ENERGY_CLOSE_RANGE_MULTI_GAIN);
		else
			PurgeKit_GainEnergy(attacker, PURGE_ENERGY_RIFLE);
	}
}

public void PurgeKit_NPCTakeDamage_Crusher(int attacker, int victim, float &damage, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_KIT_PURGE_CRUSHER)
	{
		if(fl_KitPurge_Crusher_Last_Hit[attacker] == GetGameTime(attacker))
			return;
		fl_KitPurge_Crusher_Last_Hit[attacker] = GetGameTime(attacker);
		float attackerPos[3],victimPos[3];
		WorldSpaceCenter(attacker, attackerPos);
		WorldSpaceCenter(victim, victimPos);
		float flDistanceToTarget = GetVectorDistance(attackerPos, victimPos, true);
		if(flDistanceToTarget < PURGE_ENERGY_CLOSE_RANGE * PURGE_ENERGY_CLOSE_RANGE)
			PurgeKit_GainEnergy(attacker, PURGE_ENERGY_SHOTGUN * PURGE_ENERGY_CLOSE_RANGE_MULTI_GAIN);
		else
			PurgeKit_GainEnergy(attacker, PURGE_ENERGY_SHOTGUN);
	}
}


public float PurgingRampagerAttackSpeed(int number)
{
	switch(number)
	{	/*
		case 1:
		{
			return 0.2;
		} 
		case 2:
		{
			return 0.3;
		} 
		case 3:
		{
			return 0.4;
		}*/
		case 4:
		{
			return 0.6;
		} 
		case 5:
		{
			return 0.7;
		} 
		case 6:
		{
			return 0.8;
		} 
		case 7:
		{
			return 0.9;
		} 
		case 8:
		{
			return 1.0;
		} 
		case 9:
		{
			return 1.15;
		} 
		case 10:
		{
			return 1.3;
		} 
		default:
		{
			return 1.5;
		} 
	}
}

public Action Purging_Annahilator_damageBonus_Fade(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	//int enemy = EntRefToEntIndex(pack.ReadCell());
	//float number = pack.ReadFloat();
	if(IsValidClient(client))
	{
		//fl_KitPurge_Annahilator_Bonus_Damage_Stack[client] -= number;
		if(fl_KitPurge_Annahilator_Bonus_Damage_Stack[client] != 0.0)
		{
			fl_KitPurge_Annahilator_Bonus_Damage_Stack[client] = 0.0;
		}
	}
	
	Annahilator_Damage_Revert_Timer[client] = null;
	return Plugin_Stop;
}

public Action Weapon_Purging_QuadLauncher_Remove_Later(Handle h,int ref)
{
	int weapon = EntRefToEntIndex(ref);
	if(!IsValidEntity(weapon))
	{
		return Plugin_Stop;
	}
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	float ownerPos[3];
	WorldSpaceCenter(owner, ownerPos);
	bool IsDowned = (dieingstate[owner] != 0);
	int weaponN = -1;
	if(!IsDowned)
		weaponN = Store_GiveSpecificItem(owner, "Purging Grinder");

	TE_Particle("hightower_explosion", ownerPos, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0, .clientspec = owner);
	TE_Particle("mvm_soldier_shockwave", ownerPos, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	EmitSoundToClient(owner, PURGE_EXPLOSION_SOUND, owner, SNDCHAN_AUTO, 80, _, 0.8);
	if (IsValidEntity(weapon))
	{
		if(IsValidClient(owner))
		{
			Store_RemoveSpecificItem(owner, "Purging QuadLauncher");
			TF2_RemoveItem(owner, weapon);
		}
	}
	if(!IsDowned && weaponN != -1)
	{
		FakeClientCommand(owner, "use tf_weapon_fists");
		Weapon_Purging_Crush(owner, EntIndexToEntRef(weaponN));
	}

	QuadLauncher_Remove_Timer[owner] = null;
	return Plugin_Stop;
}

public void Weapon_Purging_Annahilator_Remove(int ref, int owner)
{
	int weapon = EntRefToEntIndex(ref);
	
	if(Annahilator_Remove_Timer[owner] != null)
	{
		if(IsValidHandle(Annahilator_Remove_Timer[owner]))
			delete Annahilator_Remove_Timer[owner];
		Annahilator_Remove_Timer[owner] = null;
	}
	DataPack pack = new DataPack();
	Annahilator_Remove_Timer[owner] = 
		CreateTimer(0.1, Weapon_Purging_Annahilator_Remove_Later, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(weapon));
}

public Action Weapon_Purging_Annahilator_Remove_Later(Handle h, DataPack pack)
{
	pack.Reset();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(weapon))
	{
		delete pack;
		return Plugin_Stop;
	}
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if(IsValidClient(owner))
	{
		int KitWeaponMain = EntRefToEntIndex(i_KitPurge_Crusher_Ref[owner]);
		if(IsValidEntity(KitWeaponMain))
		{
			int pap = RoundToFloor(Attributes_Get(KitWeaponMain, Attrib_PapNumber, 1.0));
			if(GetGameTime() < fl_KitPurge_Annahilator_Tookout_Time[owner])
			{
				//timer still going, we fine
				int crusherWeapon = EntRefToEntIndex(i_KitPurge_Crusher_Ref[owner]);
				Ability_Apply_Cooldown(owner, 3, PURGE_ANNAHILATOR_COOLDOWN, crusherWeapon);
				if(LastMann)
				{
					Attributes_Set(weapon, 107, 1.0);
				}
				else
				{
					Attributes_Set(weapon, 107, fl_KitPurge_Annahilator_Speed_Penality[pap]);
				}
				return Plugin_Continue;
			}
		}
	}
	//timer ran out ding ding ding
	if(IsValidEntity(weapon))
	{
		Attributes_Set(weapon, 107, 1.0);
		if(IsValidClient(owner))
		{
			int crusherWeapon = EntRefToEntIndex(i_KitPurge_Crusher_Ref[owner]);
			
			//PrintToConsoleAll("crusherWeapon %d", crusherWeapon);
			float Ability_CD = Ability_Check_Cooldown(owner, 3, crusherWeapon);
			Ability_Apply_Cooldown(owner, 3, Ability_CD, crusherWeapon);
			EmitSoundToAll(PURGE_REMOVEMINIGUN, owner, SNDCHAN_STATIC, 80, _, 0.8);
			Store_RemoveSpecificItem(owner, "Purging Annihilator");
			TF2_RemoveItem(owner, weapon);
			FakeClientCommand(owner, "use tf_weapon_shotgun_hwg");
		}
	}
	Annahilator_Remove_Timer[owner] = null;
	delete pack;
	return Plugin_Stop;
}

public void Weapon_Purging_Crush(int client, int weaponRef)
{
	float clientAngle[3];
	int weapon = EntRefToEntIndex(weaponRef);
	TF2_AddCondition(client, TFCond_LostFooting, 999.0);
	TF2_AddCondition(client, TFCond_AirCurrent, 999.0);
	//int paplevel = RoundToFloor(Attributes_Get(weapon, Attrib_PapNumber, 1.0));
			

	GetClientEyeAngles(client, clientAngle);
	float velocity[3];
	GetAngleVectors(clientAngle, velocity, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(velocity, velocity);
	ScaleVector(velocity, PURGE_RAM_SPEED);
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	float Time = GetGameTime(client);
	SetEntPropFloat(client, Prop_Send, "m_flNextAttack", Time+0.75);
			
	DataPack pack = new DataPack();
	CreateTimer(0.1, Weapon_Purging_Crush_Think, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteCell(Time);

}

public Action Weapon_Purging_Crush_Think(Handle h, DataPack pack)
{
//	PUUUUUUUSSSSSSHHHHHHHH!!!!!!!!!!!!!!!!!!
	
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	float crushStartTime = pack.ReadCell();
	float Time = GetGameTime(client);
	int paplvl;
	if(IsValidEntity(weapon))
		paplvl = RoundToFloor(Attributes_Get(weapon, Attrib_PapNumber, 1.0));
	if(Time < crushStartTime + fl_KitPurge_Ram_Max_Time[paplvl] && IsValidEntity(weapon))
	{
		int team = GetTeam(client);
		SetEntPropFloat(client, Prop_Send, "m_flNextAttack", Time+0.75);
		
		FakeClientCommand(client, "use tf_weapon_fists");
		
		float clientAngle[3];
		GetClientEyeAngles(client, clientAngle);
		float velocity[3];
		GetAngleVectors(clientAngle, velocity, NULL_VECTOR, NULL_VECTOR);
		int entHit = 0;
		float damage = PURGE_RAM_BASE_DMG;
		damage *= Attributes_Get(weapon, 2, 1.0);
		damage *= 0.075;
		for(int a; a < i_MaxcountNpcTotal; a++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[a]);
			if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity) && entHit <= PURGE_RAM_MAX_HIT)
			{
				if(GetTeam(entity) == team)
					continue;
					
				float selfPos[3];
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", selfPos);
				float vecHitPos[3];WorldSpaceCenter(entity, vecHitPos);
				
				if(GetVectorDistance(selfPos, vecHitPos, true) > PURGE_RAM_RADIUS * PURGE_RAM_RADIUS)
					continue;
	
				entHit++;

				SDKHooks_TakeDamage(entity, client, client, damage, DMG_CLUB, weapon, _, vecHitPos);
				damage *= LASER_AOE_DAMAGE_FALLOFF;
				if(view_as<CClotBody>(entity).IsOnGround())
				{
					float knockback = 350.0;
					if(b_thisNpcIsARaid[entity])
					{
						if(!LastMann)
							continue;
					}
					if(b_thisNpcIsABoss[entity] || b_thisNpcIsARaid[entity])
					{
						knockback = (b_thisNpcIsARaid[entity]) ? 70.0 : 200.0;
					}
					if(LastMann)
						knockback *= 1.5;
					Custom_Knockback(client, entity, knockback, true);
				}
			}
		}
		
		GetAngleVectors(clientAngle, velocity, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(velocity, velocity);
		ScaleVector(velocity, PURGE_RAM_SPEED);
		if((GetEntityFlags(client) & FL_ONGROUND))
			velocity[2] = 0.0;
		else
			velocity[2] = -30.0;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
		return Plugin_Continue;
	}
	
	if(IsValidClient(client))
	{
		TF2_RemoveCondition(client, TFCond_LostFooting);
		TF2_RemoveCondition(client, TFCond_AirCurrent);
		//SetEntityGravity(client, 1.0);
		
		if(GetAmmo(client, 14) < 10)
			SetAmmo(client, 14, 10);
		
		Store_RemoveSpecificItem(client, "Purging Grinder");
		if(IsValidEntity(weapon))
			TF2_RemoveItem(client, weapon);
		FakeClientCommandEx(client, "use tf_weapon_shotgun_hwg");
	}
	delete pack;
	return Plugin_Stop;
}

bool PurgeKit_LastMann(int client)
{
	return h_KitPurge_Timer[client] != null;	
}



void KitPurgeGiveAttributes(int client, int weapon, int WhatTypeWeapon)
{
	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteCell(WhatTypeWeapon);
	RequestFrame(KitPurgeGiveAttributesData, pack);
	//well sucks to suck
	
}


void KitPurgeGiveAttributesData(DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	int WhatTypeWeapon = pack.ReadCell();
	delete pack;
	if(!IsValidEntity(weapon) || !IsValidClient(client))
		return;

	int KitWeaponMain = EntRefToEntIndex(i_KitPurge_Crusher_Ref[client]);
	if(!IsValidEntity(KitWeaponMain))
		return;

	//we get and use attribute 1 for damage, we dont use 2
	//we dont want tinkers and other buffs to affect it.
	float MeleeWeaponMulti = Attributes_Get(KitWeaponMain, 1, 1.0);

	//force switch to these always.
	SetPlayerActiveWeapon(client, weapon);
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
	int pap = RoundToFloor(Attributes_Get(KitWeaponMain, Attrib_PapNumber, 1.0));
	switch(WhatTypeWeapon)
	{
		//Annihilator minigun
		case 1000:
		{
			Attributes_SetMulti(weapon, 2, MeleeWeaponMulti);
			Attributes_Set(weapon, 107, fl_KitPurge_Annahilator_Speed_Penality[pap]);
			Attributes_Set(weapon, 412, fl_KitPurge_Annahilator_Resistance[pap]);
			Attributes_Set(weapon, 698, 1.0);
			Weapon_Purging_Annahilator_Remove(EntIndexToEntRef(weapon), client);
		}
		//Quad Launcher
		case 1001:
		{
			Attributes_SetMulti(weapon, 2, MeleeWeaponMulti);
			Attributes_SetMulti(weapon, 6, fl_KitPurge_QuadLauncher_FireSpeed[pap]);
			Attributes_Set(weapon, 698, 1.0);
			if(QuadLauncher_Remove_Timer[client] != null)
			{
				if(IsValidHandle(QuadLauncher_Remove_Timer[client]))
					delete QuadLauncher_Remove_Timer[client];
				QuadLauncher_Remove_Timer[client] = null;
			}
			QuadLauncher_Remove_Timer[client] = 
				CreateTimer(QuadSinceLastRemove[client] - GetGameTime(), Weapon_Purging_QuadLauncher_Remove_Later, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE);
		}
		//Grinder melee thing
		case 1002:
		{
			Attributes_SetMulti(weapon, 2, MeleeWeaponMulti);
			Attributes_Set(weapon, 107, 1.4);
			Attributes_Set(weapon, 252, 0.5);
			if(pap <= 6)
				Attributes_Set(weapon, 412, 1.5);
			else
				Attributes_Set(weapon, 412, 1.25);
			Attributes_Set(weapon, 698, 1.0);
		}
	}
}










