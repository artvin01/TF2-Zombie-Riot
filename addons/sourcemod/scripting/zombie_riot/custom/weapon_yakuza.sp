/*
	Stand + M1 = Light
	Duck + M1 = Grab (Pap 1)
	(Jump + M1) M1 -> M2 = Heavy
	//Better idea: Since melee hits take long, you'd press m1 and then quickly press m2 to ininitate a heavy hit.

	Duck + M2 = Block (Pap 3)
	Stand + M2 = Style Special (Pap 2)
	For dragonmode: Enemy must be attacking, if they are
	its a tigerdrop
	how it works:
	Activate ability, for 0.2 seconds it checks if you take damage, if you do, 
	negate 90% of all damage for animation duration, and do attack in the direction you aimed at

	(Jump + M2) M2 -> R = Heat Special (Pap 4)
	better idea:when pressing m2 and instantly pressing r, itll do this instead
	avoid jumping at all costs, its annoying to work with

	Ducking is fine.
	R = Switch Style
*/

enum
{
	Attack_Light,
	Attack_Heavy,
	Attack_Grab
}

enum
{
	Style_Brawler,	// Balanced
	Style_Beast,	// Slow, AOE
	Style_Rush,		// Fast, Evasion
	Style_Dragon	// Best of all, but limited time use
}

static const char StyleName[][] =
{
	"Brawler",
	"Beast",
	"Rush",
	"Dragon"
};

// https://www.youtube.com/watch?v=VxQXaqDSNUw&t=15s
#define INDEX_BUILDINGHOLDING	474

static Handle WeaponTimer[MAXPLAYERS];
static int WeaponRef[MAXPLAYERS] = {-1, ...};
static int WeaponLevel[MAXPLAYERS];
static int WeaponCharge[MAXPLAYERS];
static int WeaponStyle[MAXPLAYERS];
static bool SuperDragon[MAXPLAYERS];
static int LastAttack[MAXPLAYERS];
static int LastVictim[MAXPLAYERS] = {-1, ...};
static float BlockNextFor[MAXPLAYERS];
static int BlockStale[MAXPLAYERS];
static int CurrentWeaponComboAt[MAXPLAYERS];
static float LastDamage[MAXPLAYERS];
static float LastSpeed[MAXPLAYERS];
static float CurrentlyInAttack[MAXPLAYERS];
static bool Precached;
static float HeatActionCooldown[MAXPLAYERS];
static float HeatActionCooldownEnemy[MAXENTITIES];

void Yakuza_MapStart()
{
	Zero(WeaponCharge);
	Zero(WeaponStyle);
	Zero(BlockNextFor);
	Zero(BlockStale);
	Zero(HeatActionCooldown);
	Zero(HeatActionCooldownEnemy);
	Precached = false;
	SpecialLastMan = 0;
	PrecacheSound("items/pegleg_01.wav");
	PrecacheSound("items/pegleg_02.wav");
	PrecacheSound("items/powerup_pickup_base.wav");
}

float Yakuza_DurationDoEnemy(int enemy)
{
	if(LastMann)
	{
		return 1.0;
	}
	if(b_thisNpcIsARaid[enemy])
	{
		return 0.5;
	}
	return 1.0;
}
bool Yakuza_IsBeastMode(int client)
{
	if(WeaponTimer[client] == null)
		return false;

	if(WeaponStyle[client] != Style_Beast)
		return false;

	return true;
}

// Is this player a Yakuza
bool Yakuza_IsNotInJoint(int client)
{
	return WeaponTimer[client] != null;	
}

int Yakuza_Lastman(any toggle = -1)
{
//	if(!FileNetwork_Enabled())
//		return 0;
		
	if(toggle != -1)
		SpecialLastMan = view_as<bool>(toggle);
	
	return SpecialLastMan;
}

void Yakuza_EnemiesHit(int client, int weapon, int &enemies_hit_aoe)
{
	if(LastAttack[client] != Attack_Grab && WeaponStyle[client] == Style_Beast && weapon != -1)
		enemies_hit_aoe += GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") == INDEX_BUILDINGHOLDING ? 4 : 2;
}

void Yakuza_AddCharge(int client, int amount)
{
	if(amount)
	{
		if(!SuperDragon[client] && WeaponStyle[client] == Style_Dragon)
		{
			//Dragon style CANNOT gain heat at all
			if(amount >= 0)
				amount = 0;
		}
		WeaponCharge[client] += amount;

		if(WeaponCharge[client] < 0)
		{
			WeaponCharge[client] = 0;
		}
		else
		{
			int maxcharge = MaxCharge(client);
			if(WeaponCharge[client] > maxcharge)
				WeaponCharge[client] = maxcharge;
		}

		SetEntProp(client, Prop_Send, "m_nStreaks", WeaponCharge[client] / 20);
	}

	TriggerTimer(WeaponTimer[client], true);
}

#define BEAST_DMG_CHANGE 1.5
#define RUSH_DMG_CHANGE 0.50
#define DRAGON_DMG_CHANGE 1.25
static void UpdateStyle(int client)
{
	int weapon = EntRefToEntIndex(WeaponRef[client]);
	if(weapon != -1)
	{
		int SlowPlayer = 0;
		float color = 4.0;
		float damage = 1.05;
		float speed = 1.0;
		i_MeleeAttackFrameDelay[weapon] = 12;
		switch(WeaponStyle[client])
		{
			case Style_Beast:
			{
				color = 2.0;
				damage = BEAST_DMG_CHANGE;
				speed = 1.5;
				SlowPlayer = 1;
			}
			case Style_Rush:
			{
				i_MeleeAttackFrameDelay[weapon] = 6;
				color = 6.0;
				damage = RUSH_DMG_CHANGE;
				speed = 0.67;
			}
			case Style_Dragon:
			{
				i_MeleeAttackFrameDelay[weapon] = 9;
				color = 1.0;
				damage = DRAGON_DMG_CHANGE;
				speed = 0.75;
			}
		}

		// See Yakuz_SpawnWeaponPre
		if(GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") == INDEX_BUILDINGHOLDING)
		{
			damage *= 1.5;
			speed *= 1.15;
			i_WeaponFakeIndex[weapon] = 5;
			SlowPlayer = 2;
		}

		if(SlowPlayer == 1)
			Attributes_Set(weapon, 54, 0.9);
		else if(SlowPlayer == 2)
			Attributes_Set(weapon, 54, 0.8);
		else
			Attributes_Set(weapon, 54, 1.0);

		SetEntProp(client, Prop_Send, "m_nStreaks", 0);

		Attributes_SetMulti(weapon, 2, damage / LastDamage[client]);
		LastDamage[client] = damage;

		Attributes_SetMulti(weapon, 6, speed / LastSpeed[client]);
		LastSpeed[client] = speed;

		Attributes_Set(weapon, 2025, 3.0);
		Attributes_Set(weapon, 2014, color);
		Attributes_Set(weapon, 2013, 2007.0);
		ViewChange_Update(client, false);
	}
}

static int MaxCharge(int client)
{
	return 75 + WeaponLevel[client] * 25;
}

static int PlayerState(int client)
{
	if(GetClientButtons(client) & IN_DUCK)
		return 1;
	
	return 0;
}

void Yakuz_SpawnWeaponPre(int client, int &index, TFClassType &class)
{
	if(WeaponStyle[client] == Style_Beast && IsValidEntity(i2_MountedInfoAndBuilding[1][client]) && GetEntProp(i2_MountedInfoAndBuilding[1][client], Prop_Data, "m_iHealth") > 0)
	{
		// Holding building? Conscientious Objector.
		// Note: Do Store_GiveAll when removing/adding a mounted building
		index = INDEX_BUILDINGHOLDING;
		class = TFClass_DemoMan;
	}
}

void Yakuza_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_YAKUZA)
	{
		// Weapon Setup
		WeaponLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));
		WeaponRef[client] = EntIndexToEntRef(weapon);
		SuperDragon[client] = Attributes_Get(weapon, 6123, 0.0) != 0.0;

		delete WeaponTimer[client];
		WeaponTimer[client] = CreateTimer(0.6, WeaponTimerFunc, client, TIMER_REPEAT);

		LastDamage[client] = 1.0;
		LastSpeed[client] = 1.0;

		YakuzaMusicDownload();

		UpdateStyle(client);
	}
}
void YakuzaMusicDownload()
{
	if(!Precached)
	{
		// MASS REPLACE THIS IN ALL FILES
		PrecacheSoundCustom("#zombiesurvival/yakuza_lastman.mp3",_,1);
		Precached = true;
	}
}
static Action WeaponTimerFunc(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		int weapon = EntRefToEntIndex(WeaponRef[client]);
		if(weapon != -1)
		{
			if(weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
			{
				b_IsCannibal[client] = true;
				if(LastMann)
					TF2_AddCondition(client, TFCond_InHealRadius, 1.1);
				
				if(!SuperDragon[client] && WeaponStyle[client] == Style_Dragon)
				{
					Yakuza_AddCharge(client, -1);
					if(WeaponCharge[client] < 1)
					{
						WeaponStyle[client] = 0;
						UpdateStyle(client);
					}
				}

				PrintHintText(client, "%s - HEAT %d％", StyleName[WeaponStyle[client]], WeaponCharge[client]);
				
			}
			else
			{
				// Decay HEAT while not equipped
				WeaponCharge[client] -= 5;
				if(WeaponCharge[client] < 0)
					WeaponCharge[client] = 0;
			}

			return Plugin_Continue;
		}
	}

	WeaponCharge[client] = 0;
	WeaponTimer[client] = null;
	return Plugin_Stop;
}

public void Weapon_Yakuza_R(int client, int weapon, bool crit, int slot)
{
	// Switch styles on R
	//Handle this differently

	WeaponStyle[client]++;
	if(WeaponStyle[client] >= Style_Dragon)
	{
		WeaponStyle[client] = 0;
	}

	if(PlayerState(client) == 1)
	{
		if(WeaponLevel[client] > 2)
		{
			if(SuperDragon[client] || WeaponCharge[client] >= 80)
			{
				WeaponStyle[client] = Style_Dragon;
			}
			else
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "Requires 80％ HEAT for Dragon Style!");
			}
		}
	}
	
	switch(WeaponStyle[client])
	{
		case Style_Brawler:
			EmitSoundToClient(client, "items/powerup_pickup_base.wav", client, _, 75, _, 0.60);

		case Style_Beast:
			EmitSoundToClient(client, "items/powerup_pickup_knockout.wav", client, _, 75, _, 0.60);

		case Style_Rush:
			EmitSoundToClient(client, "items/powerup_pickup_agility.wav", client, _, 75, _, 0.60);

		case Style_Dragon:
			EmitSoundToClient(client, "items/powerup_pickup_strength.wav", client, _, 75, _, 0.60);
		
	}
	
	// Update weapon for held building
	if(WeaponStyle[client] == Style_Beast)
	{
		if(IsValidEntity(i2_MountedInfoAndBuilding[1][client]))
			Store_GiveAll(client, GetClientHealth(client));
	}
	else if(GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") == INDEX_BUILDINGHOLDING)
	{
		Store_GiveAll(client, GetClientHealth(client));
	}
	
	TriggerTimer(WeaponTimer[client], true);
	UpdateStyle(client);
}

public void Weapon_Yakuza_M1(int client, int weapon, bool crit, int slot)
{
	switch(PlayerState(client))
	{
		//if not ducking
		case 0:
			Yakuza_BasicAttack(client, weapon);
		
		//If ducking
		case 1:
			Yakuza_GrabAttack(client, weapon, slot);
	}
}

public void Weapon_Yakuza_M2(int client, int weapon, bool crit, int slot)
{
	if(CurrentlyInAttack[client] > GetGameTime())
	{
		CurrentWeaponComboAt[client] = 0;
		LastAttack[client] = Attack_Heavy;
		TF2_AddCondition(client, TFCond_CritCanteen, 0.25);
		Yakuza_WeaponCooldown(weapon);
		//Set the current ongoing attack to heavy, critboost for visual effect
		return;
	}
	
	if(dieingstate[client] != 0 || WeaponLevel[client] < 1)
		return;
	
	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	switch(PlayerState(client))
	{
		case 0:
			Yakuza_M2Special(client, weapon, slot);
		//Need to duck for blocking with m2
		case 1:
			Yakuza_Block(client, weapon, slot);
	}
}

void YakuzaWeaponSwingDid(int client)
{
	CurrentlyInAttack[client] = 0.0;
}
static void Yakuza_BasicAttack(int client, int weapon)
{
	LastAttack[client] = Attack_Light;
	CurrentlyInAttack[client] = GetGameTime() + (float(i_MeleeAttackFrameDelay[weapon]) * GetTickInterval());
	
	int MaxAttacksPossible = 4;

	switch(WeaponStyle[client])
	{
		case Style_Beast:
			MaxAttacksPossible = 2;
		
		case Style_Rush:
			MaxAttacksPossible = 9;

		case Style_Dragon:
			MaxAttacksPossible = 5;
	}

	DataPack pack = new DataPack();
	RequestFrame(Yakuza_ApplyWeaponCD2, pack);
	pack.WriteCell(EntIndexToEntRef(weapon));
	CurrentWeaponComboAt[client]++;
	if(CurrentWeaponComboAt[client] >= MaxAttacksPossible)
	{
		CurrentWeaponComboAt[client] = 0;
		
		Yakuza_WeaponCooldown(weapon);
	}
}

void Yakuza_WeaponCooldown(int weapon)
{
	
	DataPack pack = new DataPack();
	RequestFrame(Yakuza_ApplyWeaponCD2, pack);
	pack.WriteCell(EntIndexToEntRef(weapon));

	float cooldown = 4.0;
	cooldown *= Attributes_Get(weapon, 6, 1.0);
	cooldown *= Attributes_Get(weapon, 396, 1.0);
	DataPack pack2 = new DataPack();
	RequestFrame(Yakuza_ApplyWeaponCD, pack2);
	pack2.WriteCell(EntIndexToEntRef(weapon));
	pack2.WriteFloat(cooldown);
}


public void Yakuza_ApplyWeaponCD(DataPack pack)
{
	pack.Reset();
	int Weapon = EntRefToEntIndex(pack.ReadCell());
	float TimeSet = pack.ReadFloat();
	
	if(IsValidEntity(Weapon))
	{
		int Owner = GetEntPropEnt(Weapon, Prop_Send, "m_hOwnerEntity");
		if(Owner > 0)
		{
			if(LastAttack[Owner] == Attack_Heavy)
			{
				TimeSet *= 1.5;
			}
			else if(LastAttack[Owner] == Attack_Grab)
			{
				TimeSet *= 6.0;
				Ability_Apply_Cooldown(Owner, 1, TimeSet);
			}
			if(LastAttack[Owner] != Attack_Grab)
				SetEntPropFloat(Weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + TimeSet);
		}
	}

	delete pack;
}

public void Yakuza_ApplyWeaponCD2(DataPack pack)
{
	pack.Reset();
	int Weapon = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(Weapon))
	{
		SetEntPropFloat(Weapon, Prop_Send, "m_flNextSecondaryAttack", FAR_FUTURE);
	}

	delete pack;
}
static void Yakuza_GrabAttack(int client, int weapon, int slot)
{
	if(dieingstate[client] != 0 || WeaponLevel[client] < 1)
	{
		Yakuza_BasicAttack(client, weapon);
		return;
	}

	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		
		Yakuza_BasicAttack(client, weapon);
		return;
	}

	LastAttack[client] = Attack_Grab;
	TF2_AddCondition(client, TFCond_CritCanteen, 0.25);
	Yakuza_WeaponCooldown(weapon);
	//Set the current ongoing attack to heavy, critboost for visual effect
}

bool TraceStunOnly;
bool YakuzaTestStunOnlyTrace()
{
	return TraceStunOnly;
}

#define HEATACTION_DMG_MULTI 6.0
public void Yakuza_M2Special(int client, int weapon, int slot)
{
	if(HeatActionCooldown[client] > GetGameTime())
		return;

	if(WeaponStyle[client] != Style_Dragon)
		TraceStunOnly = true;


	Handle swingTrace;
	float vecSwingForward[3];
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 80.0, false, 45.0, true); //infinite range, and ignore walls!
				
	int target = TR_GetEntityIndex(swingTrace);	
	delete swingTrace;
	TraceStunOnly = false;
	
	if(target <= 0)
	{
		if(WeaponStyle[client] == Style_Beast)
		{
			//Allow tracing and picking up on decorative objects
			//Code this last
			if(MountBuildingToBackInternal(client, true))
			{
				//Hurray, no buiding was found, lets try stealing!
				Store_GiveAll(client, GetClientHealth(client));
				FinishLagCompensation_Base_boss();
				return;
			}
			
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "STYLE: Target must be a decorative building or your own!");
			FinishLagCompensation_Base_boss();
			return;
		}
		else if(WeaponStyle[client] == Style_Rush)
		{
			Rogue_OnAbilityUse(client, weapon);
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 1.5);
			ApplyTempAttrib(weapon, 6, 0.85, 1.5);
			Ability_Apply_Cooldown(client, 2, 8.0);
			FinishLagCompensation_Base_boss();
			return;
		}

		if(WeaponStyle[client] != Style_Brawler)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "HEAT: No target!");
			FinishLagCompensation_Base_boss();
			return;
		}
	}
	
	//We found a target!
	if(target > 0 && (f_TimeFrozenStill[target] > GetGameTime(target) || WeaponStyle[client] == Style_Dragon))
	{
		//the target is stunned! Do we allow a heat action?
		if(WeaponLevel[client] > 1)
		{
			if(CvarInfiniteCash.BoolValue && WeaponCharge[client] < 100)
				WeaponCharge[client] = 100;

			int RequiredHeat = 80;
			//dont need extreme full heat.
			if(WeaponStyle[client] == Style_Dragon)
			{
				if(GetClientButtons(client) & IN_ATTACK) //if its dragon, make it so they cant hold m1
				{
					FinishLagCompensation_Base_boss();
					return;
				}
				RequiredHeat = 45;
			}
			else
			{
				if(HeatActionCooldownEnemy[target] > GetGameTime())
				{
					//cant spam heat actions.
					ClientCommand(client, "playgamesound items/medshotno1.wav");
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "HEAT: Enemy was recently in HEAT ability! Wait!");
					FinishLagCompensation_Base_boss();
					return;
				}
			}
			float flMaxhealth = float(ReturnEntityMaxHealth(client));

			if(WeaponCharge[client] >= RequiredHeat)
			{
				Rogue_OnAbilityUse(client, weapon);
				Yakuza_AddCharge(client, -RequiredHeat);
				f_AntiStuckPhaseThrough[client] = GetGameTime() + (3.5 * Yakuza_DurationDoEnemy(target));
				f_AntiStuckPhaseThroughFirstCheck[client] = GetGameTime() + (3.5 * Yakuza_DurationDoEnemy(target));
				ApplyStatusEffect(client, client, "Intangible", 3.5 * Yakuza_DurationDoEnemy(target));
				//Everything is greenlit! Yaay!
				HeatActionCooldown[client] = GetGameTime() + 0.5;
				if(WeaponStyle[client] != Style_Dragon)
					HeatActionCooldownEnemy[target] = GetGameTime() + 5.0;
				//cant spam heat action.
				switch(WeaponStyle[client])
				{
					case Style_Brawler:
					{
						float DamageBase = 250.0;
						DamageBase *= HEATACTION_DMG_MULTI;
						DamageBase *= Attributes_Get(weapon, 2, 1.0);
						DoSpecialActionYakuza(client, DamageBase, "brawler_heat_1", 2.5 * Yakuza_DurationDoEnemy(target), target);
						flMaxhealth *= 1.25;
						//more healing and damage for brawler
					}

					case Style_Beast:
					{
						if(IsValidEntity(i2_MountedInfoAndBuilding[1][client]))
						{
							float DamageBase = 160.0;
							DamageBase *= HEATACTION_DMG_MULTI;
							DamageBase *= Attributes_Get(weapon, 2, 1.0);
							DoSpecialActionYakuza(client, DamageBase, "beast_heat_building_1", 1.35 * Yakuza_DurationDoEnemy(target), target);
						}
						else
						{
							float DamageBase = 120.0;
							DamageBase *= HEATACTION_DMG_MULTI;
							DamageBase *= Attributes_Get(weapon, 2, 1.0);
							DoSpecialActionYakuza(client, DamageBase, "brawler_heat_2", 2.1 * Yakuza_DurationDoEnemy(target), target);
						}
					}
					
					case Style_Rush:
					{
						float DamageBase = 300.0;
						DamageBase *= HEATACTION_DMG_MULTI;
						DamageBase *= Attributes_Get(weapon, 2, 1.0);
						DoSpecialActionYakuza(client, DamageBase, "brawler_heat_3", 2.5 * Yakuza_DurationDoEnemy(target), target);
					}

					case Style_Dragon:
					{
						float DamageBase = 230.0;
						DamageBase *= HEATACTION_DMG_MULTI;
						DamageBase *= Attributes_Get(weapon, 2, 1.0);
						//tiger drop negates all damage.
						f_AntiStuckPhaseThrough[client] = 0.0;
						f_AntiStuckPhaseThroughFirstCheck[client] = 0.0;
						IncreaseEntityDamageTakenBy(client, 0.1, 0.75);
						DoSpecialActionYakuza(client, DamageBase, "brawler_heat_4", 0.75, target);
						flMaxhealth *= 0.45;
					}
				}
				
				flMaxhealth *= 0.12;
				if(LastMann)
					flMaxhealth *= 2.0;
					
				HealEntityGlobal(client, client, flMaxhealth, 1.0, 0.0, HEAL_SELFHEAL);
				FinishLagCompensation_Base_boss();
				return;
			}

			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "HEAT: Requires %d％ HEAT for this!", RequiredHeat);
			FinishLagCompensation_Base_boss();
			return;
		}

		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "HEAT: Ability not unlocked!");
		FinishLagCompensation_Base_boss();
		return;
	}

	if(GetClientButtons(client) & IN_ATTACK)
	{
		FinishLagCompensation_Base_boss();
		return;
	}

	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 100.0, false, 45.0, true); //infinite range, and ignore walls!
	FinishLagCompensation_Base_boss();
	target = TR_GetEntityIndex(swingTrace);	
	delete swingTrace;

	if(target > 0 && WeaponStyle[client] == Style_Brawler)
	{
		Rogue_OnAbilityUse(client, weapon);
		float vecForward[3];
		static float angles[3];
		GetClientEyePosition(client, angles);
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		float damage_force[3]; CalculateDamageForce(vecForward, 40000.0, damage_force);
		float damage = 120.0;
		damage *= Attributes_Get(weapon, 2, 1.0);
		float EnemyVecPos[3]; WorldSpaceCenter(target, EnemyVecPos);
		SDKHooks_TakeDamage(target, client, client, damage, DMG_CLUB, -1, damage_force, EnemyVecPos);
		EmitSoundToAll(IRENE_KICKUP_1, client, _, 75, _, 0.60);
		float DistanceCheck[3];
		GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", DistanceCheck);
		spawnRing_Vectors(DistanceCheck, 50.0 * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 200, 1, 0.25, 12.0, 6.1, 1);	
		if(i_NpcWeight[target] < 4)
		{
			Rogue_OnAbilityUse(client, weapon);
			
			bool halved = (b_thisNpcIsARaid[target] || b_thisNpcIsABoss[target] || i_NpcWeight[target] > 2);
			
			float VicLoc[3];
			VicLoc[2] += halved ? 250.0 : 450.0; //Jump up.
			if(!VIPBuilding_Active() && !HasSpecificBuff(target, "Solid Stance"))
			{
				SDKUnhook(target, SDKHook_Think, NpcJumpThink);
				f3_KnockbackToTake[target] = VicLoc;
				SDKHook(target, SDKHook_Think, NpcJumpThink);
			}
			FreezeNpcInTime(target, halved ? 0.75 : 1.5);
		}
		Ability_Apply_Cooldown(client, 2, 6.0);
		return;
	}
	
	ClientCommand(client, "playgamesound items/medshotno1.wav");
	SetDefaultHudPosition(client);
	SetGlobalTransTarget(client);
	ShowSyncHudText(client,  SyncHud_Notifaction, "HEAT: Target must be stunned!");
}

static void Yakuza_Block(int client, int weapon, int slot)
{
	if(WeaponLevel[client] < 3)
	{
		Yakuza_M2Special(client, weapon, slot);
		return;
	}
	
	Rogue_OnAbilityUse(client, weapon);

	float gameTime = GetGameTime();
//	float cooldown = 2.0;
	float duration = 0.5;
	if(BlockStale[client] > 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Cannot Block! Attack to regain block count!");
		return;		
	}
	switch(WeaponStyle[client])
	{
		case Style_Beast:
		{
		//	cooldown = 2.5;
			duration = 0.8;
		}
		case Style_Rush:
		{
	//		cooldown = 1.5;
			duration = 0.4;
		}
		case Style_Dragon:
		{
	//		cooldown = 1.5;
			duration = 0.65;
		}
	}
	
//	Ability_Apply_Cooldown(client, 2, cooldown * 3.0 * (1.0 + (BlockStale[client] * 0.05)));

	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", gameTime + duration);

	BlockStale[client] += 10;	// Every block stales by x1.5

	int NumberRand = GetRandomInt(0,1);
	EmitSoundToAll(NumberRand ? "items/pegleg_01.wav" : "items/pegleg_02.wav", client, SNDCHAN_STATIC, 80, _, 1.0, 90);
	EmitSoundToAll(NumberRand ? "items/pegleg_01.wav" : "items/pegleg_02.wav", client, SNDCHAN_STATIC, 80, _, 1.0, 90);

	if(RaidbossIgnoreBuildingsLogic(1))
	{
		ApplyTempAttrib(weapon, 206, 0.25, duration);
	}
	else
	{
		BlockNextFor[client] = gameTime + duration;
	}
}

void Yakuza_NPCTakeDamage(int victim, int attacker, float &damage, int weapon)
{
	BlockStale[attacker]--;
	if(BlockStale[attacker] <= 0)
		BlockStale[attacker] = 0;
		
	LastVictim[attacker] = EntIndexToEntRef(victim);
	int HeatGive = 4;

	switch(WeaponStyle[attacker])
	{
		case Style_Brawler:
			HeatGive = 4;

		case Style_Beast:
			HeatGive = 3;

		case Style_Rush:
			HeatGive = 2;

		case Style_Dragon:
		{
			if(!SuperDragon[attacker])
				HeatGive = 0;
		}
	}
	if(b_thisNpcIsARaid[victim])
	{
		HeatGive = RoundToNearest(float(HeatGive) * 1.5);
	}
	//reward heavy hit or normal hit with rush style
	if(CurrentWeaponComboAt[attacker] == 0)
	{
		if(WeaponStyle[attacker] == Style_Rush)
		{
			TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 0.5);
		}
	}

	if(GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") == INDEX_BUILDINGHOLDING && LastAttack[attacker] != Attack_Grab)
	{
		bool failed = true;

		int building = EntRefToEntIndex(i2_MountedInfoAndBuilding[1][attacker]);
		if(building != -1)
		{
			int health = GetEntProp(building, Prop_Data, "m_iHealth") - (GetEntProp(building, Prop_Data, "m_iMaxHealth") / 10);
			
			if(health > 0)
			{
				SetEntProp(building, Prop_Data, "m_iHealth", health);
				failed = false;
			}
			else
			{
				int entity = EntRefToEntIndex(i2_MountedInfoAndBuilding[1][attacker]);
				if(IsValidEntity(i2_MountedInfoAndBuilding[1][attacker]))
				{
					float posStacked[3]; 
					GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", posStacked);
					AcceptEntityInput(i2_MountedInfoAndBuilding[1][attacker], "ClearParent");
					SDKCall_SetLocalOrigin(entity, posStacked);	
					i2_MountedInfoAndBuilding[1][attacker] = INVALID_ENT_REFERENCE;
				}
				if(IsValidEntity(i2_MountedInfoAndBuilding[0][attacker]))
				{
					RemoveEntity(i2_MountedInfoAndBuilding[0][attacker]);
					i2_MountedInfoAndBuilding[0][attacker] = INVALID_ENT_REFERENCE;
				}
				DestroyBuildingDo(building);
			}
		}

		if(failed)
		{
			Store_GiveAll(attacker, GetClientHealth(attacker));
		}
	}

	switch(LastAttack[attacker])
	{
		case Attack_Heavy:
		{
			bool PlaySound = false;
			if(f_MinicritSoundDelay[attacker] < GetGameTime())
			{
				PlaySound = true;
				f_MinicritSoundDelay[attacker] = GetGameTime() + 0.01;
			}
			HeatGive *= 2;
			DisplayCritAboveNpc(victim, attacker, PlaySound); //Display crit above head
			switch(WeaponStyle[attacker])
			{
				case Style_Brawler:
					damage *= 3.5;
				
				case Style_Beast:
					damage *= 2.5;
				
				case Style_Rush:
					damage *= 4.25;

				case Style_Dragon:
					damage *= 4.0;
			}
			if(LastMann || !b_thisNpcIsARaid[victim])
				SensalCauseKnockback(attacker, victim, 0.5, false);
		}
		case Attack_Grab:
		{
			damage = 1.0;
			HeatGive *= 2;
			float duration = 1.35;
			if(!LastMann && b_thisNpcIsARaid[victim])
			{
				//Give bigger cooldown.
				float cooldown = 4.0;
				cooldown *= Attributes_Get(weapon, 6, 1.0);
				cooldown *= 6.0;
				cooldown *= 3.0;
				Ability_Apply_Cooldown(attacker, 1, cooldown);
				duration *= 0.85;
			}
			FreezeNpcInTime(victim, duration * Yakuza_DurationDoEnemy(victim));
		}
	}
	Yakuza_AddCharge(attacker, HeatGive);

	// +25% damage at 100% HEAT
	damage *= 1.0 + (WeaponCharge[attacker] * 0.0025);
}

void Yakuza_SelfTakeDamage(int victim, int &attacker, float &damage, int damagetype, int weapon)
{
	if(!(damagetype & DMG_TRUEDAMAGE))
	{
		if(LastMann)
		{
			damage *= 0.75;
		}
		if(WeaponStyle[victim] == Style_Brawler)
			damage *= 0.90;

		if(WeaponStyle[victim] == Style_Dragon)
			damage *= 0.8;

		if(WeaponStyle[victim] == Style_Beast)
		{
			if(GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") == INDEX_BUILDINGHOLDING)
				damage *= 0.7;
			else
				damage *= 0.8;
		}

		if((damagetype & DMG_TRUEDAMAGE) || attacker <= MaxClients)
			return;
		
		//You actually gain alot of heat with brawler mode when blocking!
		//todo: add logic during brawlermode and Dragon mode
		//dragon mode has limited heatgain on block in kiwami, but with hnow ZR works and how dragonmode works here, it sohuldnt be limited.
		
		//With beastmode, you cant actually block youre just immune to knockback, but that in ZR sucks, so it should be the best to block with.
		if((damagetype & DMG_CLUB) && BlockNextFor[victim] > GetGameTime())
		{
			if(!CheckInHud())
			{
				int rand = (GetURandomInt() % 4) + 1;
				ClientCommand(victim, "playgamesound player/resistance_heavy%d.wav", rand);
				ClientCommand(victim, "playgamesound player/resistance_heavy%d.wav", rand);
			}
			damage = 0.0;
			return;
		}
	}
//	if(!CheckInHud()) This was supposed to be removed, as in late waves you kinda instalooe heat.
//		Yakuza_AddCharge(victim, RoundToCeil(damage * -0.01));
}

static int DoSpecialActionYakuza(int client, float DamageBase, const char[] animation, float duration, int target)
{
	//Reduce the damgae they take in half during the animtion, just incase, evne though they are untargetable anyways.
	//incase of AOE attacks and all.
	IncreaseEntityDamageTakenBy(client, 0.5, duration);
	if(!StrContains(animation, "brawler_heat_4"))
	{

	}
	else
	{
		//tigerdrop doesnt do ignoring
		b_ThisEntityIgnored[client] = true;
	}
	float vAngles[3];
	float vOrigin[3];
	
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	float vecSwingForward[3];
	float vecSwingEnd[3];
	GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);
	vecSwingEnd[0] = vOrigin[0] + vecSwingForward[0] * LEPER_MAXRANGE_VIEW_EFFECT * 0.25;
	vecSwingEnd[1] = vOrigin[1] + vecSwingForward[1] * LEPER_MAXRANGE_VIEW_EFFECT * 0.25;
	vecSwingEnd[2] = vOrigin[2] + vecSwingForward[2] * LEPER_MAXRANGE_VIEW_EFFECT * 0.25;
	vecSwingEnd[2] -= 30.0;
	
	//always from upwards somewhere.
	vAngles[0] = GetRandomFloat(-10.0 , -5.0);
	switch(GetRandomInt(0,1))
	{
		case 0:
		{
			vAngles[1] += GetRandomFloat(80.0 , 90.0);
		}
		case 1:
		{
			vAngles[1] -= GetRandomFloat(80.0 , 90.0);
		}
	}

	float LeperViewAnglesMins[3];
	float LeperViewAnglesMaxs[3];
	LeperViewAnglesMins = view_as<float>({-LEPER_BOUNDS_VIEW_EFFECT, -LEPER_BOUNDS_VIEW_EFFECT, -LEPER_BOUNDS_VIEW_EFFECT});
	LeperViewAnglesMaxs = view_as<float>({LEPER_BOUNDS_VIEW_EFFECT, LEPER_BOUNDS_VIEW_EFFECT, LEPER_BOUNDS_VIEW_EFFECT});

	GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);

	vecSwingEnd[0] = vOrigin[0] + vecSwingForward[0] * LEPER_MAXRANGE_VIEW_EFFECT;
	vecSwingEnd[1] = vOrigin[1] + vecSwingForward[1] * LEPER_MAXRANGE_VIEW_EFFECT;
	vecSwingEnd[2] = vOrigin[2] + vecSwingForward[2] * LEPER_MAXRANGE_VIEW_EFFECT;
	Handle trace = TR_TraceHullFilterEx( vOrigin, vecSwingEnd, LeperViewAnglesMins, LeperViewAnglesMaxs, ( MASK_SOLID ), TraceRayHitWorldOnly, client );
	if ( TR_GetFraction(trace) < 1.0)
	{
		//we hit nothing something, uh oh!
		TR_GetEndPosition(vecSwingEnd, trace);
	}
	GetClientEyeAngles(client, vAngles);
	vAngles[0] = 0.0;
	GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);

	delete trace;

	float vecSwingEndMiddle[3];
	vecSwingEndMiddle[0] = vOrigin[0] + vecSwingForward[0] * LEPER_MAXRANGE_VIEW_EFFECT;
	vecSwingEndMiddle[1] = vOrigin[1] + vecSwingForward[1] * LEPER_MAXRANGE_VIEW_EFFECT;
	vecSwingEndMiddle[2] = vOrigin[2] + vecSwingForward[2] * LEPER_MAXRANGE_VIEW_EFFECT;
	trace = TR_TraceHullFilterEx( vOrigin, vecSwingEndMiddle, LeperViewAnglesMins, LeperViewAnglesMaxs, ( MASK_SOLID ), TraceRayHitWorldOnly, client );
	if ( TR_GetFraction(trace) < 1.0)
	{
		//we hit nothing something, uh oh!
		TR_GetEndPosition(vecSwingEndMiddle, trace);
	}
	delete trace;
	float vAngleCamera[3];
	float MiddleAngle[3];
	MiddleAngle[0] = (vecSwingEndMiddle[0] + vOrigin[0]) / 2.0;
	MiddleAngle[1] = (vecSwingEndMiddle[1] + vOrigin[1]) / 2.0;
	MiddleAngle[2] = (vecSwingEndMiddle[2] + vOrigin[2]) / 2.0;
	
//	int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
//	TE_SetupBeamPoints(MiddleAngle, vecSwingEnd, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 5.0, 5.0, 5.0, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
//	TE_SendToAll();
	int viewcontrol = CreateEntityByName("prop_dynamic");
	if (IsValidEntity(viewcontrol))
	{
		GetVectorAnglesTwoPoints(vecSwingEnd, MiddleAngle, vAngleCamera);
		SetEntityModel(viewcontrol, "models/empty.mdl");
		DispatchKeyValueVector(viewcontrol, "origin", vecSwingEnd);
		DispatchKeyValueVector(viewcontrol, "angles", vAngleCamera);
		DispatchSpawn(viewcontrol);	
		SetClientViewEntity(client, viewcontrol);
	}
	float vabsAngles[3];
	float vabsOrigin[3];
	GetClientAbsOrigin(client, vabsOrigin);
	GetClientEyeAngles(client, vabsAngles);
	vabsAngles[0] = 0.0;
	SetVariantInt(0);
	AcceptEntityInput(client, "SetForcedTauntCam");	
	
	int spawn_index = NPC_CreateByName("npc_allied_kiryu_visualiser", client, vabsOrigin, vabsAngles, target, animation);

	fl_AbilityOrAttack[spawn_index][3] = DamageBase;
	CClotBody npc = view_as<CClotBody>(spawn_index);
	npc.m_iWearable9 = viewcontrol;
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);

	if(i_OverlordComboAttack[npc.index] == 5)
	{
		Building_Mounted[client] = -1;
		int entity = EntRefToEntIndex(i2_MountedInfoAndBuilding[1][client]);
		if(IsValidEntity(i2_MountedInfoAndBuilding[1][client]))
		{
			float posStacked[3]; 
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", posStacked);
			AcceptEntityInput(i2_MountedInfoAndBuilding[1][client], "ClearParent");
			SDKCall_SetLocalOrigin(entity, posStacked);	
			i2_MountedInfoAndBuilding[1][client] = INVALID_ENT_REFERENCE;
		}
		if(IsValidEntity(i2_MountedInfoAndBuilding[0][client]))
		{
			RemoveEntity(i2_MountedInfoAndBuilding[0][client]);
			i2_MountedInfoAndBuilding[0][client] = INVALID_ENT_REFERENCE;
		}
		
		npc.m_iWearable8 = entity;
		float ModelScale = GetEntPropFloat(entity, Prop_Send, "m_flModelScale");
		ModelScale *= 3.0;

		ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", ModelScale);
		
		if(IsValidEntity(objstats.m_iWearable1))
		{
			SetEntPropFloat(objstats.m_iWearable1, Prop_Send, "m_flModelScale", ModelScale);
		}
		if(IsValidEntity(objstats.m_iWearable2))
		{
			SetEntPropFloat(objstats.m_iWearable2, Prop_Send, "m_flModelScale", ModelScale);
		}
	}
	/*
	if(LastMann && Yakuza_Lastman())
	{
		// Camera for all players yippie
		for(int other = 1; other <= MaxClients; other++)
		{
			if(other != client && IsClientInGame(other) && IsPlayerAlive(other))
			{
				SetVariantInt(0);
				AcceptEntityInput(other, "SetForcedTauntCam");
				SetClientViewEntity(other, viewcontrol);

				CreateTimer(duration, Yakuza_ResetCameraOnly, GetClientUserId(other), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	*/
	
	TF2_AddCondition(client, TFCond_FreezeInput, -1.0);

	SetEntityMoveType(client, MOVETYPE_NONE);
	SetEntProp(client, Prop_Send, "m_bIsPlayerSimulated", 0);
	SetEntProp(client, Prop_Send, "m_bSimulatedEveryTick", 0);
//	SetEntProp(client, Prop_Send, "m_bAnimatedEveryTick", 0);
	SetEntProp(client, Prop_Send, "m_bClientSideAnimation", 0);
	SetEntProp(client, Prop_Send, "m_bClientSideFrameReset", 1);
	SetEntProp(client, Prop_Send, "m_bForceLocalPlayerDraw", 1);
	int entity, i;
	while(TF2U_GetWearable(client, entity, i))
	{
		SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") | EF_NODRAW);
	}

	return spawn_index;
}