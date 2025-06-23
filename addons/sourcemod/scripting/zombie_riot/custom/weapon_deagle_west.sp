#pragma semicolon 1
#pragma newdecls required

static Handle h_TimerWestWeaponManagement[MAXPLAYERS+1] = {null, ...};
static float f_West_Aim_Duration[MAXPLAYERS+1];
static int i_West_Target[MAXPLAYERS+1];

#define SOUND_REVOLVER_FANG 	"items/powerup_pickup_agility.wav"
#define SOUND_REVOLVER_NOON 	"ambient/medieval_falcon.wav"

void ResetMapStartWest()
{
	West_Map_Precache();
	Zero(f_West_Aim_Duration);
}
void West_Map_Precache()
{
	PrecacheSound("items/powerup_pickup_haste.wav");
	PrecacheSound("items/battery_pickup.wav");
	PrecacheSound(SOUND_REVOLVER_FANG);
	PrecacheSound(SOUND_REVOLVER_NOON);
}

public void Enable_West_Weapon(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerWestWeaponManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_WEST_REVOLVER)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerWestWeaponManagement[client];
			h_TimerWestWeaponManagement[client] = null;
			DataPack pack;
			h_TimerWestWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_Revolver_West, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_WEST_REVOLVER)
	{
		DataPack pack;
		h_TimerWestWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_Revolver_West, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_Revolver_West(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerWestWeaponManagement[client] = null;
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		REVOLER_AIM(client);
	}
		
	return Plugin_Continue;
}

public void Revolver_Fang(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 30.0);
			EmitSoundToAll(SOUND_REVOLVER_FANG, client, SNDCHAN_AUTO, 100, _, 0.6);
			ApplyTempAttrib(weapon, 6, 0.3, 2.0);
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
}
public void Revolver_Fang_PAP1(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		if(f_West_Aim_Duration[client] > GetGameTime())
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			return;
		}
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 25.0);
			EmitSoundToAll(SOUND_REVOLVER_FANG, client, SNDCHAN_AUTO, 100, _, 0.6);
			ApplyTempAttrib(weapon, 6, 0.3, 2.5);

			static float anglesB[3];
			GetClientEyeAngles(client, anglesB);
			static float velocity[3];
			GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(velocity, velocity);
			float knockback = -750.0;
			// knockback is the overall force with which you be pushed, don't touch other stuff
			ScaleVector(velocity, knockback);
			if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			{
				velocity[2] = fmax(velocity[2], 300.0);
			}	
			else
			{
				velocity[2] += 90.0;	// a little boost to alleviate arcing issues
			}
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
			f_West_Aim_Duration[client] = GetGameTime() + 2.5;
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
}

public void Revolver_Highnoon(int client, int weapon, bool crit, int slot, int victim)
{
	if(IsValidEntity(client))
	{
		if(f_West_Aim_Duration[client] > GetGameTime())
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			return;
		}
		if(Ability_Check_Cooldown(client, slot) < 0.0 && !(GetClientButtons(client) & IN_DUCK) && NeedCrouchAbility(client))
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Crouch for ability");	
			return;
		}
		
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 60.0);
			EmitSoundToAll(SOUND_REVOLVER_NOON, client, SNDCHAN_AUTO, 140, _, 0.6);
			ApplyTempAttrib(weapon, 6, 0.1, 1.5);
			ApplyTempAttrib(weapon, 2, 1.3, 1.5);
			ApplyTempAttrib(weapon, 97, 0.01, 1.5);
			MakePlayerGiveResponseVoice(client, 1);

			Handle swingTrace;
			float vecSwingForward[3];
			StartLagCompensation_Base_Boss(client);
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9900.0, false, 9900.0, true); //infinite range, and does not ignore walls!
			FinishLagCompensation_Base_boss();

				
			int target = TR_GetEntityIndex(swingTrace);	
			delete swingTrace;
			if(!IsValidEnemy(client, target, true))
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				return;
			}
			i_West_Target[client] = EntIndexToEntRef(target);


			TF2_AddCondition(client, TFCond_HalloweenCritCandy, 2.0, client);
			f_West_Aim_Duration[client] = GetGameTime() + 2.0;	
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
}

void REVOLER_AIM(int client)
{
	if(f_West_Aim_Duration[client] > GetGameTime())
	{
		int ChargeEnemy = EntRefToEntIndex(i_West_Target[client]);
		if(IsValidEnemy(client, ChargeEnemy, true))
		{
			if(TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy))
			{
				LookAtTarget(client, ChargeEnemy);
			}
		}
		else if(!TF2_IsPlayerInCondition(client, TFCond_Charging))
		{
			f_West_Aim_Duration[client] = 0.0;
		}
	}
	else
	{
		TF2_RemoveCondition(client, TFCond_HalloweenCritCandy);
		f_West_Aim_Duration[client] = 0.0;
	}
}


public void TriggerFinger_UspAbility(int client, int weapon, bool crit, int slot, int victim)
{
	if(IsValidEntity(client))
	{
		if(Ability_Check_Cooldown(client, slot) > 0.0)
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
		
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, 35.0);
		ApplyTempAttrib(weapon, 6, 0.5, 3.0);
		ApplyTempAttrib(weapon, 97, 0.5, 3.0);
		MakePlayerGiveResponseVoice(client, 1);
		EmitSoundToAll("items/powerup_pickup_haste.wav", client, _, 70);
		ApplyStatusEffect(client, client, "Trigger Finger", 3.0);
		ApplyStatusEffect(client, client, "Trigger Finger Hidden", 3.0);
	}
}
public void TriggerFinger_UspAbility2(int client, int weapon, bool crit, int slot, int victim)
{
	if(IsValidEntity(client))
	{
		if(Ability_Check_Cooldown(client, slot) > 0.0)
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
		
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, 35.0);
		ApplyTempAttrib(weapon, 6, 0.5, 4.0);
		ApplyTempAttrib(weapon, 97, 0.5, 4.0);
		MakePlayerGiveResponseVoice(client, 1);
		EmitSoundToAll("items/powerup_pickup_haste.wav", client, _, 70);
		ApplyStatusEffect(client, client, "Trigger Finger", 4.0);
		ApplyStatusEffect(client, client, "Trigger Finger Hidden", 4.0);
	}
}

// SHERRIF REVOLVER
public void DepthPerception_RevolverM2(int client, int weapon, bool crit, int slot, int victim)
{
	if(!IsValidEntity(client))
		return;

	if(Ability_Check_Cooldown(client, slot) > 0.0)
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
	
	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 16.0);
	if(CvarInfiniteCash.BoolValue)
		Ability_Apply_Cooldown(client, slot, 0.0);
	EmitSoundToAll("items/powerup_pickup_haste.wav", client, _, 70);
			
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	Explode_Logic_Custom(0.0, client, client, weapon, _, 9999.9,_,_,true,4,_,_,SherrifRevolverHit);
	//add LOS check.
	FinishLagCompensation_Base_boss();
	ApplyStatusEffect(client, client, "Depth Percieve", 3.0);
}
// SHERRIF REVOLVER
public void DepthPerception_RevolverM2_PAP(int client, int weapon, bool crit, int slot, int victim)
{
	if(!IsValidEntity(client))
		return;

	if(Ability_Check_Cooldown(client, slot) > 0.0)
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
	
	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 12.0);
	if(CvarInfiniteCash.BoolValue)
		Ability_Apply_Cooldown(client, slot, 0.0);

	EmitSoundToAll("items/powerup_pickup_haste.wav", client, _, 70);
			
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	float flPos[3];
	GetClientEyePosition(client, flPos);
	Explode_Logic_Custom(0.0, client, client, weapon, flPos, 3000.9,_,_,true,4,_,_,SherrifRevolverHit);
	//add LOS check.
	FinishLagCompensation_Base_boss();
	ApplyStatusEffect(client, client, "Depth Percieve", 3.0);
}

void SherrifRevolverHit(int entity, int victim, float damage, int weapon)
{
	ApplyStatusEffect(entity, victim, "Depth Percepted", 3.0);
	StatusEffects_AddDepthPerception_Glow(victim);
}


void SherrifRevolver_NPCTakeDamage(int attacker, int victim, float &damage, int weapon, int whichtype)
{
	if(!HasSpecificBuff(attacker, "", StatusIdDepthPerceptionOwnerFunc()))
		return;

	if(!StatusEffects_AddDepthPerception_Glow_IsaOwner(victim, attacker))
		return;
	//am the owner!
	StatusEffects_AddDepthPerception_UseUpMark(victim, attacker);
	damage *= 3.0;
	bool PlaySound = false;
	if(f_MinicritSoundDelay[attacker] < GetGameTime())
	{
		PlaySound = true;
		f_MinicritSoundDelay[attacker] = GetGameTime() + 0.25;
	}
	
	DisplayCritAboveNpc(victim, attacker, PlaySound); //Display crit above head
	if(whichtype == WEAPON_SHERRIF)
	{
		float CurrentCD = Ability_Check_Cooldown(attacker, 3, weapon);
		Ability_Apply_Cooldown(attacker, 3, CurrentCD - 1.5, weapon, true);
	}
}


// SHERRIF REVOLVER
public void DepthPerception_RevolverR(int client, int weapon, bool crit, int slot, int victim)
{
	if(!IsValidEntity(client))
		return;

	if(Ability_Check_Cooldown(client, slot) > 0.0)
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
	
	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 60.0);
	EmitSoundToAll("items/battery_pickup.wav", client, _, 70);
	if(CvarInfiniteCash.BoolValue)
		Ability_Apply_Cooldown(client, slot, 0.0);

	int WeaponDo = Store_GiveSpecificItem(client, "Wanted's Lever Action");
	SetAmmo(client, 27, 0);
	CurrentAmmo[client][27] = 0;
	ResetClipOfWeaponStore(WeaponDo, client, 8);
}
// SHERRIF REVOLVER
public void Weapon_ShootOnRemoveSelf_LeverAction(int client, int weapon, bool crit, int slot, int victim)
{
	int CurrentAmmoHave = GetAmmo(client, 27);
	int iAmmoTable = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
	int CurrentClip = GetEntData(weapon, iAmmoTable, 4);
	if(CurrentAmmoHave <= 1 && CurrentClip <= 1)
	{
		Store_RemoveSpecificItem(client, "Wanted's Lever Action");
		CreateTimer(0.5, LazyCoding_RemoveWeapon, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE);
		FakeClientCommand(client, "use tf_weapon_revolver");
	}
}

public Action LazyCoding_RemoveWeapon(Handle Calcium_Remove_SpellHandle, int ref)
{
	int weapon = EntRefToEntIndex(ref);
	if (IsValidEntity(weapon))
	{
		int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
		if(IsValidClient(owner))
		{
			int weapon_holding = GetEntPropEnt(owner, Prop_Send, "m_hActiveWeapon");
			if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
			{
				FakeClientCommand(owner, "use tf_weapon_revolver");
			}
			TF2_RemoveItem(owner, weapon);
		}
	}	
	return Plugin_Handled;
}