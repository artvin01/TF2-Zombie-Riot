#pragma semicolon 1
#pragma newdecls required

#define Zealot_NORMAL_HIT	"weapons/halloween_boss/knight_axe_hit.wav"
#define Zealot_AOE_SWING_HIT	"ambient/rottenburg/barrier_smash.wav"
#define Zealot_SOLEMNY	"misc/halloween/spell_overheal.wav"

#define SAMURAI_SWORD_PARRY 	"weapons/samurai/tf_katana_impact_object_02.wav"
public const char PotionNames[][] =
{
	"Potion of Vigor",
	"Potion of Swiftness",
	"Potion of Resilience",
	"Potion of Focus",
};

Handle Timer_Zealot_Management[MAXPLAYERS+1] = {null, ...};
float Zealot_HudDelay[MAXPLAYERS+1];
static int ParticleRef[MAXPLAYERS+1];
static int WeaponCheckExist[MAXPLAYERS+1];
static int WeaponCheckExistBlock[MAXPLAYERS+1];
static int WeaponCheckExistRapidFire[MAXPLAYERS+1];
static float f_ResetMoveSpeedPenalty[MAXPLAYERS+1];
static float f_DashCooldownZealot[MAXPLAYERS+1];
static float f_StaminaLeftZealot[MAXPLAYERS+1];
static float f_BlockCheckDelay[MAXPLAYERS+1];
static int MaxDodgeCount[MAXPLAYERS+1] = {10, ...};
static float f_BlockRegenDelay[MAXPLAYERS+1];
static int i_PaPLevel[MAXPLAYERS+1] = {0, ...};
static int i_RandomCurrentPotion[MAXPLAYERS+1] = {0, ...};
static float f_PotionCooldownDo[MAXPLAYERS+1];
static float f_ChargeDuration[MAXPLAYERS+1];
static float f_ZealotDamageSave[MAXPLAYERS+1];
static int f_PistolGet[MAXPLAYERS+1];
static int i_WeaponGotLastmanBuff[MAXENTITIES];
static bool Precached;
static int i_WhatPotionDrink[MAXPLAYERS+1];
static float Zealot_OneshotProtection[MAXPLAYERS+1];
static float Zealot_BonusMeleeDamage[MAXPLAYERS+1];
static float Zealot_BonusMeleeDamageDuration[MAXPLAYERS+1];
static float Zealot_BonusMeleeDamageWearoff[MAXPLAYERS+1];
static float AmmoGiveWeapon[MAXPLAYERS+1];

void Zealot_RoundStart()
{
	Zero(Zealot_OneshotProtection);
	Zero(f_StaminaLeftZealot);
}
void OnMapStartZealot()
{
	PrecacheSound("passtime/projectile_swoosh3.wav");
	Zero(Zealot_HudDelay);
	Zero(f_DashCooldownZealot);
	Zero(i_RandomCurrentPotion);
	Zero(f_BlockRegenDelay);
	Zero(f_StaminaLeftZealot);
	Zero(f_PotionCooldownDo);
	Precached = false;
	Zero(Zealot_OneshotProtection);
	PrecacheSound("plats/tram_hit4.wav");
	Zero(Zealot_BonusMeleeDamageDuration);
	Zero(Zealot_BonusMeleeDamageWearoff);
	PrecacheSound(SAMURAI_SWORD_PARRY);
}

bool Zealot_Sugmar(int client)
{
	return Timer_Zealot_Management[client] != null;	
}
public void Weapon_ZealotRCheckCD(int client, int weapon, bool &result, int slot)
{
	return;
}

void Zealot_ApplyGlobalRCooldown(int client, float Duration)
{
	Duration *= CooldownReductionAmount(client);

	f_DashCooldownZealot[client] = GetGameTime() + Duration;
	int weapon1;
	int ie;
	while(TF2_GetItem(client, weapon1, ie))
	{
		//make sure to not brick melees...
		if(IsValidEntity(weapon1))
		{
			Ability_Apply_Cooldown(client, 3, Duration, weapon1, true);
		}
	}
}
void Zealot_ReduceGlobalRCooldown(int client, float Duration, bool potion = false)
{
	f_DashCooldownZealot[client] -= Duration;
	int weapon1;
	int ie;
	while(TF2_GetItem(client, weapon1, ie))
	{
		//make sure to not brick melees...
		if(IsValidEntity(weapon1))
		{
			if(potion)
			{
				if(i_CustomWeaponEquipLogic[weapon1] == WEAPON_ZEALOT_POTION)
				{
					float CurrentCD = Ability_Check_Cooldown(client, 2, weapon1);
					Ability_Apply_Cooldown(client, 2, CurrentCD - Duration, weapon1, true);
					f_PotionCooldownDo[client] -= Duration;
					GrenadeApplyCooldownHud(client, f_PotionCooldownDo[client] - GetGameTime());
				}
			}
			else
			{
				float CurrentCD = Ability_Check_Cooldown(client, 3, weapon1);
				Ability_Apply_Cooldown(client, 3, CurrentCD - Duration, weapon1, true);
			}
		}
	}
}

#define CHARGE_DURATION 1.0
#define CHARGE_DEFAULT_DAMGAE 200.0

public void Weapon_ZealotBlockRapier(int client, int weapon, bool &result, int slot)
{
	//this is a holding one, dont.
	f_CooldownForAbilities[client][0] = FAR_FUTURE;
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_ZEALOT_MELEE && (GetClientButtons(client) & IN_DUCK))
	{
		if(i_PaPLevel[client] >= 2)
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0)
			{
				//ignore rest.
				Rogue_OnAbilityUse(client, weapon);
				Ability_Apply_Cooldown(client, slot, 60.0);

				f_ChargeDuration[client] = GetGameTime() + CHARGE_DURATION;
				static float anglesB[3];
				GetClientEyeAngles(client, anglesB);
				anglesB[0] = 0.0;
				static float velocity[3];
				GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
				float knockback = 700.0;
				ScaleVector(velocity, knockback);
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
				TF2_AddCondition(client, TFCond_LostFooting, CHARGE_DURATION);
				TF2_AddCondition(client, TFCond_AirCurrent, CHARGE_DURATION);
				TF2_AddCondition(client, TFCond_FreezeInput, CHARGE_DURATION);
				IncreaseEntityDamageTakenBy(client, 0.25, CHARGE_DURATION);
				f_AntiStuckPhaseThrough[client] = GetGameTime() + CHARGE_DURATION + 0.5;
				f_AntiStuckPhaseThroughFirstCheck[client] = GetGameTime() + CHARGE_DURATION + 0.5;
				ApplyStatusEffect(client, client, "Intangible", 3.0);
				if(i_PaPLevel[client] >= 4)
				{
					f_AntiStuckPhaseThrough[client] = GetGameTime() + 5.0;
					f_AntiStuckPhaseThroughFirstCheck[client] = GetGameTime() + 5.0;
					ApplyStatusEffect(client, client, "Intangible", 5.0);
				}
				//only take 25% damage overall.
				// knockback is the overall force with which you be pushed, don't touch other stuff
				if(i_PaPLevel[client] >= 5)
				{
					Zealot_BonusMeleeDamageWearoff[client] = GetGameTime() + 15.0;
					Zealot_BonusMeleeDamageDuration[client] = GetGameTime() + 5.0;
					Zealot_BonusMeleeDamage[client] = 1.0;
				}
				//giver faster attackspeed
				ApplyTempAttrib(weapon, 6, 0.75, 5.0);
				ApplyStatusEffect(client, client, "Zealot's Rush", 5.0);
				
				int viewmodelModel;
				viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
				if(IsValidEntity(viewmodelModel))
				{
					float flPos[3];
					GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
					flPos[2] += 40.0;
					int particle = ParticleEffectAt(flPos, "scout_dodge_red", CHARGE_DURATION);
					SetParent(viewmodelModel, particle);
				}
				EmitSoundToAll("items/powerup_pickup_strength.wav", client, SNDCHAN_STATIC,75,_,0.65, GetRandomInt(105,109));
				SDKUnhook(client, SDKHook_PreThink, Client_ZealotChargeDo);
				SDKHook(client, SDKHook_PreThink, Client_ZealotChargeDo);
				f_ZealotDamageSave[client] = CHARGE_DEFAULT_DAMGAE;
				f_ZealotDamageSave[client] *= WeaponDamageAttributeMultipliers(weapon);
			}
			else
			{
				float Ability_CD = Ability_Check_Cooldown(client, slot);
				
				if(Ability_CD <= 0.0)
					Ability_CD = 0.0;
					
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
			}
			return;
		}
	}
	f_BlockCheckDelay[client] = GetGameTime();
	WeaponCheckExistBlock[client] = EntIndexToEntRef(weapon);
	SDKUnhook(client, SDKHook_PreThink, Client_ZealotBlock);
	SDKHook(client, SDKHook_PreThink, Client_ZealotBlock);
	Attributes_Set(weapon, 821, 1.0);
}

public void Weapon_ZealotRapidfirePistol(int client, int weapon, bool &result, int slot)
{
	//this is a holding one, dont.
	f_CooldownForAbilities[client][1] = FAR_FUTURE;
	f_BlockCheckDelay[client] = GetGameTime();
	WeaponCheckExistRapidFire[client] = EntIndexToEntRef(weapon);
	SDKUnhook(client, SDKHook_PreThink, Client_ZealotRevolverRapid);
	SDKHook(client, SDKHook_PreThink, Client_ZealotRevolverRapid);
	Attributes_SetMulti(weapon, 106, 4.0);
	Attributes_SetMulti(weapon, 6, 0.35);
}

public void Client_ZealotRevolverRapid(int client)
{
	if(!IsValidEntity(WeaponCheckExistRapidFire[client]))
	{
		WeaponCheckExistRapidFire[client] = -1;
		SDKUnhook(client, SDKHook_PreThink, Client_ZealotRevolverRapid);
		return;
	}
	bool Remove_CantAttack = false;
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon != EntRefToEntIndex(WeaponCheckExistRapidFire[client]))
	{
		Remove_CantAttack = true;
	}
	int buttons = GetClientButtons(client);
	if(!(buttons & IN_RELOAD))
	{
		Remove_CantAttack = true;
	}
	if(Remove_CantAttack)
	{
		Attributes_SetMulti(EntRefToEntIndex(WeaponCheckExistRapidFire[client]), 106, 1 / 4.0);
		Attributes_SetMulti(EntRefToEntIndex(WeaponCheckExistRapidFire[client]), 6, 1 / 0.35);
		WeaponCheckExistRapidFire[client] = -1;
		SDKUnhook(client, SDKHook_PreThink, Client_ZealotRevolverRapid);
		return;
	}
}

public void ZealotPotionDrink(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		float BuffDuration = 5.0;
		switch(i_PaPLevel[client])
		{
			case 2,3:
				BuffDuration = 8.0;
			case 4,5:
				BuffDuration = 13.0;
		}
		char DescDo[255];
		Format(DescDo, sizeof(DescDo), "%s Desc", PotionNames[i_RandomCurrentPotion[client]]);
		SetDefaultHudPosition(client,_,_,_, 2.0);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", DescDo);	
		float MaxHealth = float(ReturnEntityMaxHealth(client));
		if(i_RandomCurrentPotion[client] == 0)
		{
			HealEntityGlobal(client, client, MaxHealth, 1.0, BuffDuration, HEAL_SELFHEAL);
		}
		//regen stamina to full.

		HealEntityGlobal(client, client, MaxHealth / 4.0, 1.0, 2.0, HEAL_SELFHEAL);
		EmitSoundToAll("player/pl_scout_dodge_can_drink.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
		Ability_Apply_Cooldown(client, slot, 60.0); //Semi long cooldown, this is a strong buff.
		ApplyStatusEffect(client, client, "Zealot's Random Drinks", BuffDuration);
		f_PotionCooldownDo[client] = GetGameTime() + (CooldownReductionAmount(client) * 60.0);
		GrenadeApplyCooldownHud(client, f_PotionCooldownDo[client] - GetGameTime());
		
		i_WhatPotionDrink[client] = i_RandomCurrentPotion[client];
		
		if(i_WhatPotionDrink[client] == 2)
			Zealot_RegenerateStamina(client, 2, 99.0);

		if(i_WhatPotionDrink[client] == 1)
		{
			ApplyTempAttrib(client, 442, 1.1, BuffDuration);
			CreateTimer(BuffDuration + 0.1, Timer_UpdateMovementSpeed, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		}

		i_RandomCurrentPotion[client] = GetRandomInt(0,3);
		UpdateWeaponVisibleGrenade(weapon, client, true);
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}
public void Client_ZealotBlock(int client)
{
	if(!IsValidEntity(WeaponCheckExistBlock[client]))
	{
		WeaponCheckExistBlock[client] = -1;
		SDKUnhook(client, SDKHook_PreThink, Client_ZealotBlock);
		return;
	}
	bool Remove_CantAttack = false;
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon != EntRefToEntIndex(WeaponCheckExistBlock[client]))
	{
		Remove_CantAttack = true;
	}
	int buttons = GetClientButtons(client);
	if(!(buttons & IN_ATTACK2))
	{
		Remove_CantAttack = true;
	}
	if(Remove_CantAttack)
	{
		if(IsValidClient(client))
			TF2_RemoveCondition(client, TFCond_RuneResist);
		Attributes_Set(EntRefToEntIndex(WeaponCheckExistBlock[client]), 821, 0.0);
		WeaponCheckExistBlock[client] = -1;
		SDKUnhook(client, SDKHook_PreThink, Client_ZealotBlock);
		return;
	}
	if(f_BlockCheckDelay[client] > GetGameTime())
	{
		return;
	}
	f_BlockCheckDelay[client] = GetGameTime() + 0.1;
	f_BlockRegenDelay[client] = GetGameTime() + 3.0;
	if(f_StaminaLeftZealot[client] <= 0.0)
	{
		TF2_RemoveCondition(client, TFCond_RuneResist);
	}
	else
	{
		TF2_AddCondition(client, TFCond_RuneResist, 999999.9);
	}
}

void WeaponZealot_OnTakeDamage_Gun(int attacker, int victim, float &damage)
{
	float ReduceCD = 0.4;
	if(i_HasBeenHeadShotted[victim])
		ReduceCD += 0.25;

	Zealot_RegenerateStamina(attacker, 1, 1.5 * (ReduceCD + 1.0));
	Zealot_ReduceGlobalRCooldown(attacker, ReduceCD);
	Zealot_ReduceGlobalRCooldown(attacker, ReduceCD, true);

	if(Zealot_BonusMeleeDamageWearoff[attacker] > GetGameTime())
	{
		damage *= Zealot_BonusMeleeDamage[attacker];
	}
	else
	{
		Zealot_BonusMeleeDamage[attacker] = 1.0;
	}

	if(HasSpecificBuff(attacker, "Zealot's Random Drinks"))
	{
		if(i_WhatPotionDrink[attacker] == 3 && i_HasBeenHeadShotted[victim])
		{
			damage *= 1.3;
		}
	}	
}
void WeaponZealot_OnTakeDamage(int attacker, int victim, float &damage)
{
	//Anti delay
	if(Zealot_BonusMeleeDamageDuration[attacker] > GetGameTime())
	{
		Zealot_BonusMeleeDamage[attacker] += 0.05;
		if(Zealot_BonusMeleeDamage[attacker] >= 1.5)
		{	
			Zealot_BonusMeleeDamage[attacker] = 1.5;
		}
	}
	if(Zealot_BonusMeleeDamageWearoff[attacker] > GetGameTime())
	{
		damage *= Zealot_BonusMeleeDamage[attacker];
	}
	else
	{
		Zealot_BonusMeleeDamage[attacker] = 1.0;
	}
	AmmoGiveWeapon[attacker] += 0.5;
	if(i_HasBeenHeadShotted[victim])
		AmmoGiveWeapon[attacker] += 0.5;

	int ammo = GetAmmo(attacker, Ammo_ClassSpecific);
	if(AmmoGiveWeapon[attacker] >= 1.0)
	{
		ammo++;
		AmmoGiveWeapon[attacker]--;
	}
	//Block to 10 ammo		
	int maxammodo = 10;
	int WeaponPistol = EntRefToEntIndex(f_PistolGet[attacker]);
	if(IsValidEntity(WeaponPistol))
	{
		maxammodo = RoundFloat(float(maxammodo) * Attributes_Get(WeaponPistol, 4, 0.0));
	}
	if(ammo > maxammodo)
		ammo = maxammodo;

	float ReduceCD = 0.4;
	if(i_HasBeenHeadShotted[victim])
		ReduceCD += 0.25;

	Zealot_RegenerateStamina(attacker, 1, 1.5 * (ReduceCD + 1.0));
	Zealot_ReduceGlobalRCooldown(attacker, ReduceCD);
	Zealot_ReduceGlobalRCooldown(attacker, ReduceCD, true);

	SetAmmo(attacker, Ammo_ClassSpecific, ammo);
	CurrentAmmo[attacker][Ammo_ClassSpecific] = ammo;
	MaxDodgeCount[attacker] = 10;
	if(HasSpecificBuff(attacker, "Zealot's Random Drinks"))
	{
		if(i_WhatPotionDrink[attacker] == 3 && i_HasBeenHeadShotted[victim])
		{
			damage *= 1.3;
		}
	}	
}
public float Player_OnTakeDamage_Zealot(int victim, float &damage, int attacker, int weapon, float damagePosition[3], int damagetype)
{
	if(CheckInHud())
		return damage;
	
	if(!(damagetype & DMG_TRUEDAMAGE))
	{
		if(LastMann)
		{
			damage *= 0.75;
		}
	}
	if(!IsValidEntity(WeaponCheckExistBlock[victim]))
	{
		if(i_PaPLevel[victim] >= 3)
		{
			int flHealth = GetEntProp(victim, Prop_Send, "m_iHealth");
			if(Zealot_OneshotProtection[victim] < GetGameTime() && damage >= flHealth)
			{
				damage = 0.0;
				GiveCompleteInvul(victim, 2.0);
				EmitSoundToAll("misc/halloween/spell_overheal.wav", victim, SNDCHAN_STATIC, 80, _, 0.5, 70);
				Zealot_OneshotProtection[victim] = GetGameTime() + (CooldownReductionAmount(victim) * 300.0); // 60 second cooldown
			}
		}
		return damage;
	}

	if(f_StaminaLeftZealot[victim] > 0.0)
	{
		int dmg_through_armour = RoundToCeil(damage * ZR_ARMOR_DAMAGE_REDUCTION_INVRERTED);
		EmitSoundToClient(victim, SAMURAI_SWORD_PARRY, victim, SNDCHAN_STATIC, 60, _, 0.25, GetRandomInt(95,105));				
		if(damage * ZR_ARMOR_DAMAGE_REDUCTION >= f_StaminaLeftZealot[victim])
		{
			float damage_received_after_calc;
			damage_received_after_calc = damage - f_StaminaLeftZealot[victim];
			f_StaminaLeftZealot[victim] = 0.0;
			damage = damage_received_after_calc;
		}
		else
		{
			f_StaminaLeftZealot[victim] -= damage * ZR_ARMOR_DAMAGE_REDUCTION;
			damage = 0.0;
			damage += float(dmg_through_armour);
		}
	}
	else
	{
		TF2_RemoveCondition(victim, TFCond_RuneResist);
	}
	if(i_PaPLevel[victim] >= 3)
	{
		int flHealth = GetEntProp(victim, Prop_Send, "m_iHealth");
		if(Zealot_OneshotProtection[victim] < GetGameTime() && damage >= flHealth)
		{
			damage = 0.0;
			GiveCompleteInvul(victim, 2.0);
			EmitSoundToAll("misc/halloween/spell_overheal.wav", victim, SNDCHAN_STATIC, 80, _, 0.5, 70);
			Zealot_OneshotProtection[victim] = GetGameTime() + (CooldownReductionAmount(victim) * 300.0); // 60 second cooldown
		}
	}
	return damage;
}
public void Enable_Zealot(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_ZEALOT_MELEE) //
	{
		if (Timer_Zealot_Management[client] != null)
		{
			delete Timer_Zealot_Management[client];
			Timer_Zealot_Management[client] = null;
		}
		i_WeaponGotLastmanBuff[weapon] = false;
		b_IsCannibal[client] = true;
		i_PaPLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));
		SDKUnhook(client, SDKHook_PreThink, Client_ZealotThink);
		SDKHook(client, SDKHook_PreThink, Client_ZealotThink);
		DataPack pack;
		Timer_Zealot_Management[client] = CreateDataTimer(0.1, Timer_Management_Zealot, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		WeaponCheckExist[client] = EntIndexToEntRef(weapon);
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
		float pos[3]; GetClientAbsOrigin(client, pos);
		pos[2] += 5.0;
		int entity = ParticleEffectAt(pos, "utaunt_arcane_yellow_base", -1.0);
		if(entity > MaxClients)
		{
			SetParent(client, entity);
			ParticleRef[client] = EntIndexToEntRef(entity);
		}
		ZealotMusicDownload();
	}
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_ZEALOT_GUN) //
	{
		f_PistolGet[client] = EntIndexToEntRef(weapon);
	}
}

void ZealotMusicDownload()
{
	if(!Precached)
	{
		// MASS REPLACE THIS IN ALL FILES
		PrecacheSoundCustom("#zombiesurvival/zealot_lastman_1.mp3",_,1);
		Precached = true;
	}
}

public void Client_ZealotThink(int client)
{
	if(!IsValidEntity(WeaponCheckExist[client]))
	{
		SDKUnhook(client, SDKHook_PreThink, Client_ZealotThink);
		return;
	}
	
	if(f_ResetMoveSpeedPenalty[client] && f_ResetMoveSpeedPenalty[client] < GetGameTime())
	{
		f_Client_BackwardsWalkPenalty[client] = f_Weapon_BackwardsWalkPenalty[EntRefToEntIndex(WeaponCheckExist[client])];
		f_ResetMoveSpeedPenalty[client] = 0.0;
		f_Client_LostFriction[client] = 0.1;
	}

	if(f_DashCooldownZealot[client] > GetGameTime())
		return;

	if(dieingstate[client] != 0)
		return;
	//if the client presses the same movement key twice in a row really fast, itll make them dash
	/*
	Find a better solution before continuning
	*/
	static int holding[MAXPLAYERS];
	int buttons = GetClientButtons(client);
	if(holding[client] & IN_RELOAD)
	{
		if(!(buttons & IN_RELOAD))
			holding[client] &= ~IN_RELOAD;

		return;
	}
	else
	{
		if(!(buttons & IN_RELOAD))
			return;

		holding[client] |= IN_RELOAD;
	}

	//only continune if they tapped reload.
	float AngleDeviate = 0.0;
	if((buttons & IN_MOVELEFT))
	{
		AngleDeviate += 90.0;
		if((buttons & IN_BACK))
			AngleDeviate += 45.0;
		else if((buttons & IN_FORWARD))
			AngleDeviate -= 45.0;
		//Dodge to left
	}
	if((buttons & IN_MOVERIGHT))
	{
		AngleDeviate -= 90.0;
		if((buttons & IN_BACK))
			AngleDeviate -= 45.0;
		else if((buttons & IN_FORWARD))
			AngleDeviate += 45.0;
		//Dodge to right
	}
	if(AngleDeviate == 0.0 && (buttons & IN_BACK))
	{
		AngleDeviate += 180.0;
		//Dodge to back
	}
	if(AngleDeviate == 0.0 && (buttons & IN_FORWARD))
	{
		AngleDeviate += 0.01;
		//Dodge to .... front?
	}

	//Not holding Reload. block.
	//wasnt dodging.
	if(AngleDeviate == 0.0)
		return;

	if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
	{
		
	}
	else
	{
		//NOT IN AIR!!!
		return;
	}
	if(MaxDodgeCount[client] <= 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Zealot Dash Denie Spam");
		return;
	}
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(IsValidEntity(weapon))
		Rogue_OnAbilityUse(client, weapon);

	MaxDodgeCount[client]--;

	//Punishment for dodging forwards.
	if((buttons & IN_FORWARD))
		MaxDodgeCount[client]--;
	static float anglesB[3];
	GetClientEyeAngles(client, anglesB);
	anglesB[1] += AngleDeviate;
	anglesB[0] = 0.0;
	static float velocity[3];
	GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
	float knockback = 800.0;
	TF2_AddCondition(client, TFCond_LostFooting, 0.25);
	TF2_AddCondition(client, TFCond_AirCurrent, 0.25);
	// knockback is the overall force with which you be pushed, don't touch other stuff
	ScaleVector(velocity, knockback);
	f_Client_BackwardsWalkPenalty[client] = 1.0;
	f_Client_LostFriction[client] = 0.0;
	f_ResetMoveSpeedPenalty[client] = GetGameTime() + 0.25;
	float CooldownDo = 5.0;
	switch(i_PaPLevel[client])
	{
		case 1:
			CooldownDo = 4.0;
		case 2,3:
			CooldownDo = 3.5;
		case 4,5:
			CooldownDo = 3.0;
	}
	if(LastMann)
		CooldownDo * 0.65;

	if(HasSpecificBuff(client, "Zealot's Random Drinks"))
	{
		if(i_WhatPotionDrink[client] == 1)
		{
			CooldownDo *= 0.65;
		}
	}
	Zealot_ApplyGlobalRCooldown(client, CooldownDo);
	EmitSoundToAll("passtime/projectile_swoosh3.wav", client, SNDCHAN_STATIC,80,_,1.0, GetRandomInt(100, 105));
	float WorldSpaceVec[3]; WorldSpaceCenter(client, WorldSpaceVec);
	
	TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_lines", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	//Not holding Reload. block.
}

public Action Timer_Management_Zealot(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
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
		if(IsValidClient(client))
			TF2_RemoveCondition(client, TFCond_RuneResist);
		Timer_Zealot_Management[client] = null;
		f_Client_LostFriction[client] = 0.1;
		return Plugin_Stop;
	}	
	if(LastMann)
	{
		if(!i_WeaponGotLastmanBuff[weapon])
		{
			i_WeaponGotLastmanBuff[weapon] = true;
			Attributes_SetMulti(weapon, 6, 0.75);
		}
	}
	else
	{
		if(i_WeaponGotLastmanBuff[weapon])
		{
			i_WeaponGotLastmanBuff[weapon] = false;
			Attributes_SetMulti(weapon, 6, 1 / 0.75);
		}
	}
	ApplyStatusEffect(client, client, "Fluid Movement", 0.5);
	Zealot_Hud_Logic(client, weapon, false);
		
	return Plugin_Continue;
}


public void Zealot_Hud_Logic(int client, int weapon, bool ignoreCD)
{
	//Do your code here :)
	if(Zealot_HudDelay[client] > GetGameTime() && !ignoreCD)
		return;

	Zealot_RegenerateStamina(client, 0, 1.0);
	if(f_PotionCooldownDo[client] > GetGameTime())
	{
		GrenadeApplyCooldownHud(client, f_PotionCooldownDo[client] - GetGameTime());
	}
	char ZealotHud[255];
	int ammo = GetAmmo(client, Ammo_ClassSpecific);
	int maxammodo = 10;
	int WeaponPistol = EntRefToEntIndex(f_PistolGet[client]);
	if(IsValidEntity(WeaponPistol))
	{
		maxammodo = RoundFloat(float(maxammodo) * Attributes_Get(WeaponPistol, 4, 0.0));
	}
	Format(ZealotHud, sizeof(ZealotHud), "스태미너 %.0f％ | 탄환 [%i/%i]", ((f_StaminaLeftZealot[client] / Zealot_RegenerateStaminaMAx(client)) * 100.0), ammo, maxammodo);
	
	
	if(i_PaPLevel[client] >= 1)
	{
		if(f_PotionCooldownDo[client] > GetGameTime())
		{
			Format(ZealotHud, sizeof(ZealotHud), "%s\n포션이 준비되지 않음...", ZealotHud);
		}
		else
		{
			Format(ZealotHud, sizeof(ZealotHud), "%s\n현재 포션\n%s", ZealotHud, PotionNames[i_RandomCurrentPotion[client]]);
		}
	}
	if(i_PaPLevel[client] >= 3)
	{
		if(Zealot_OneshotProtection[client] > GetGameTime())
		{
			Format(ZealotHud, sizeof(ZealotHud), "%s\n즉사 방지 (%.1f)", ZealotHud, Zealot_OneshotProtection[client] - GetGameTime());
		}
		else
		{
			Format(ZealotHud, sizeof(ZealotHud), "%s\n즉사 방지 (준비됨)", ZealotHud, PotionNames[i_RandomCurrentPotion[client]]);
		}
	}
	if(i_PaPLevel[client] >= 4)
	{
		if(Zealot_BonusMeleeDamageWearoff[client] > GetGameTime())
		{
			Format(ZealotHud, sizeof(ZealotHud), "%s\n거친 일격 (x%.1f)", ZealotHud, Zealot_BonusMeleeDamage[client]);
		}
	}
	
	Zealot_HudDelay[client] = GetGameTime() + 0.5;
	PrintHintText(client,"%s",ZealotHud);
	
}

float Zealot_RegenerateStaminaMAx(int client)
{
	float MaxStamina = float(ReturnEntityMaxHealth(client));
	MaxStamina *= 0.225;
	switch(i_PaPLevel[client])
	{
		case 1:
			MaxStamina *= 1.1;
		case 2,3:
			MaxStamina *= 1.15;
		case 4,5:
			MaxStamina *= 1.2;
	}
	return MaxStamina;
}
void Zealot_RegenerateStamina(int client, int force, float multi)
{
	float MaxStamina = Zealot_RegenerateStaminaMAx(client);
	float ExtraMax = 1.0;
	if(HasSpecificBuff(client, "Zealot's Random Drinks"))
	{
		if(i_WhatPotionDrink[client] == 2)
		{
			ExtraMax *= 2.0;
		}
	}
	if(f_StaminaLeftZealot[client] < MaxStamina * ExtraMax || force == 2)
	{
		if(!IsValidEntity(WeaponCheckExistBlock[client]) && (f_BlockRegenDelay[client] < GetGameTime() || force))
		{
			f_StaminaLeftZealot[client] += (MaxStamina * ExtraMax * 0.035 * multi);
			if(f_StaminaLeftZealot[client] > MaxStamina * ExtraMax)
			{
				f_StaminaLeftZealot[client] = MaxStamina * ExtraMax;
			}
		}
	}
}



public void Client_ZealotChargeDo(int client)
{
	if(f_ChargeDuration[client] < GetGameTime())
	{
		f_ResetMoveSpeedPenalty[client] = 0.0;
		f_Client_LostFriction[client] = 0.1;

		SDKUnhook(client, SDKHook_PreThink, Client_ZealotChargeDo);
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(IsValidEntity(weapon))
		{
			f_Client_BackwardsWalkPenalty[client] = f_Weapon_BackwardsWalkPenalty[weapon];
		}
		return;
	}
	if(f_BlockCheckDelay[client] > GetGameTime())
	{
		return;
	}
	f_BlockCheckDelay[client] = GetGameTime() + 0.1;

	float DamageDeal = f_ZealotDamageSave[client];

	static float anglesB[3];
	GetClientEyeAngles(client, anglesB);
	anglesB[0] = 0.0;
	static float velocity[3];
	GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
	float knockback = 700.0;
	ScaleVector(velocity, knockback);
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	
	float vecMe[3];
	WorldSpaceCenter(client, vecMe);
	Explode_Logic_Custom(DamageDeal, client, client, -1, vecMe, EXPLOSION_RADIUS * 0.75,_,_,false, .FunctionToCallBeforeHit = ZealotOnlyHitOnce);
}


float ZealotOnlyHitOnce(int attacker, int victim, float &damage, int weapon)
{
	
	//Zealot will have an offset of 10000, always increment by Maxentities.
	//Client instead of target, so it gets removed if the target dies
	if(IsIn_HitDetectionCooldown(attacker + (MAXENTITIES * 2),victim))
	{
		damage = 0.0;
		return 0.0;
	}
	Set_HitDetectionCooldown(attacker + (MAXENTITIES * 2),victim, GetGameTime() + 1.0);
	float targPos[3];
	WorldSpaceCenter(victim, targPos);
	EmitSoundToAll("plats/tram_hit4.wav", victim, SNDCHAN_STATIC, 80, _, 0.8);
	TE_Particle("skull_island_embers", targPos, NULL_VECTOR, NULL_VECTOR, victim, _, _, _, _, _, _, _, _, _, 0.0);
	return 0.0;
}


public Action Timer_UpdateMovementSpeed(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client))
	{
		SDKCall_SetSpeed(client);
	}
	return Plugin_Handled;
}