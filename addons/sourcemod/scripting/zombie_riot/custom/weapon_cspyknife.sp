#pragma semicolon 1
#pragma newdecls required

static int weapon_id[MAXPLAYERS+1]={0, ...};
static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};
static float fl_IncreaseAttackSpeed[MAXPLAYERS+1]={0.0, ...};
static float fl_IncreaseDamage[MAXPLAYERS+1]={1.0, ...};
//static float fl_IncreaseDamageTaken[MAXPLAYERS+1]={1.0, ...};

#define TheTimerForCoolDown 1.0
#define SlowStunTimer 0.88
#define MinicritTimer 0.55
#define SpeedBuffTimer 0.33

#define LessDamageMultiplier 0.70
#define DamageMultiplier 1.55
#define TakeMoreDamageMultiplier 1.25
#define IncreaseAttackSpeed 0.33
#define DecreaseAttackSpeed 1.25
#define SlownessAmount 0.65

//Third Pap Stuff
#define CooldownTimer_Pap 1.55
#define MinicritTimer_Pap 2.0
#define SpeedBuffTimer_Pap 1.0
#define SlowStunTimer_Pap 0.88

#define LessDamageMultiplier_Pap 0.70
#define DamageMultiplier_Pap 2.2
#define TakeMoreDamageMultiplier_Pap 1.15
#define IncreaseAttackSpeed_Pap 0.28
#define DecreaseAttackSpeed_Pap 1.55
#define SlownessAmount_Pap 0.55

#define ResetAttackSpeedTimer 1.22
#define ResetLessAttackSpeedTimer 1.22
#define ResetDealLessDmgTimer 1.22
#define ResetDealMoreDmgTimer 1.11
#define ResetTakeMoreDmgTimer 1.22

public void Weapon_Cspyknife_ClearAll()
{
	Zero(ability_cooldown);
}

public void Weapon_CspyKnife(int client, int weapon, bool crit, int slot)
{
	if(weapon >= MaxClients)
	{
		if(Ability_Check_Cooldown(client, slot) < 0.0)
		{
		//	Ability_Apply_Cooldown(client, slot, TheTimerForCoolDown);
			weapon_id[client] = EntIndexToEntRef(weapon);
			
			switch(GetRandomInt(1,8))
			{
				case 1:
				{
					fl_IncreaseAttackSpeed[client] = 1.0;
					/*Address address = TF2Attrib_GetByDefIndex(weapon, 6);
					if(address != Address_Null)
					fl_IncreaseAttackSpeed[client] = TF2Attrib_GetValue(address);
					Attributes_Set(weapon, 6, fl_IncreaseAttackSpeed[client] * IncreaseAttackSpeed);*/
					ApplyTempAttrib(weapon, 6, IncreaseAttackSpeed, 0.1);
					//CreateTimer(0.88, Reset_ToNormalAttackSpeed, client, TIMER_FLAG_NO_MAPCHANGE);
					//PrintToChat(client, "AttackSpeed bonus")
				}
				case 2:
				{
					TF2_AddCondition(client, TFCond_CritCola, 0.44, 0);
					//PrintToChat(client, "Minicrits")
				}
				case 3:
				{
					TF2_AddCondition(client, TFCond_SpeedBuffAlly, SpeedBuffTimer, 0);
					//PrintToChat(client, "Speedbuff")
				}
				case 4:
				{
					fl_IncreaseDamage[client] = 1.0;
					/*Address address = TF2Attrib_GetByDefIndex(weapon, 2);
					if(address != Address_Null)
					fl_IncreaseDamage[client] = TF2Attrib_GetValue(address);
					Attributes_Set(weapon, 2, fl_IncreaseDamage[client] * DamageMultiplier);*/
					ApplyTempAttrib(weapon, 2, DamageMultiplier);
					//CreateTimer(0.88, Reset_fl_IncreaseDamage, client, TIMER_FLAG_NO_MAPCHANGE);
					//PrintToChat(client, "More Dmg")
				}
				case 5:
				{
					fl_IncreaseDamage[client] = 1.0;
					/*Address address = TF2Attrib_GetByDefIndex(weapon, 2);
					if(address != Address_Null)
					fl_IncreaseDamage[client] = TF2Attrib_GetValue(address);
					Attributes_Set(weapon, 2, fl_IncreaseDamage[client] * LessDamageMultiplier);*/
					ApplyTempAttrib(weapon, 2, LessDamageMultiplier);
					//CreateTimer(0.88, Reset_fl_DecreaseDamage, client, TIMER_FLAG_NO_MAPCHANGE);
					//PrintToChat(client, "Less Dmg")
				}
				case 6:
				{
					/*fl_IncreaseDamageTaken[client] = 1.0;
					Address address = TF2Attrib_GetByDefIndex(weapon, 412);
					if(address != Address_Null)
					fl_IncreaseDamageTaken[client] = TF2Attrib_GetValue(address);
					Attributes_Set(weapon, 412, fl_IncreaseDamageTaken[client] * TakeMoreDamageMultiplier);
					CreateTimer(0.88, Reset_TakeMoreDmg, client, TIMER_FLAG_NO_MAPCHANGE);*/
					TF2_AddCondition(client, TFCond_MarkedForDeathSilent, MinicritTimer, 0);
					//PrintToChat(client, "Take More Dmg")
				}
				case 7:
				{
					TF2_StunPlayer(client, SlowStunTimer, SlownessAmount, TF_STUNFLAG_SLOWDOWN, _);
					//PrintToChat(client, "You got slowed ha!")
				}
			}
		}
	}
}

public void Weapon_CspyKnife_Pap(int client, int weapon, bool crit, int slot)
{
	if(weapon >= MaxClients)
	{
		if(Ability_Check_Cooldown(client, slot) < 0.0)
		{
		//	Ability_Apply_Cooldown(client, slot, CooldownTimer_Pap);
			weapon_id[client] = EntIndexToEntRef(weapon);
			
			switch(GetRandomInt(1, 13))
			{
				case 1:
				{
					CreateTimer(0.01, MoreAttackSpeed, client, TIMER_FLAG_NO_MAPCHANGE);
					//PrintToChat(client, "AttackSpeed bonus")
				}
				case 2:
				{
					TF2_AddCondition(client, TFCond_CritCola, MinicritTimer_Pap, 0);
					//PrintToChat(client, "Minicrits")
				}
				case 3:
				{
					TF2_AddCondition(client, TFCond_SpeedBuffAlly, SpeedBuffTimer_Pap, 0);
					//PrintToChat(client, "Speedbuff")
				}
				case 4:
				{
					CreateTimer(0.01, LessAttackSpeed, client, TIMER_FLAG_NO_MAPCHANGE);
					//PrintToChat(client, "Less Dmg, Less Attack Speed)
				}
				case 5:
				{
					CreateTimer(0.01, DealLessDmg, client, TIMER_FLAG_NO_MAPCHANGE);
					//PrintToChat(client, "Less Dmg")
				}
				case 6:
				{
					CreateTimer(0.01, DealMoreDmg, client, TIMER_FLAG_NO_MAPCHANGE);
					//PrintToChat(client, "Less Dmg")
				}
				case 7:
				{
					CreateTimer(0.01, TakeMoreDmg, client, TIMER_FLAG_NO_MAPCHANGE);
					//PrintToChat(client, "Take Slightly More Dmg")
				}
				case 8:
				{
					TF2_StunPlayer(client, SlowStunTimer_Pap, SlownessAmount_Pap, TF_STUNFLAG_SLOWDOWN, _);
					//PrintToChat(client, "You got slowed ha!")
				}
				case 9:
				{
					CreateTimer(0.01, LessAttackSpeed, client, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(0.01, TakeMoreDmg, client, TIMER_FLAG_NO_MAPCHANGE);
					//PrintToChat(client, "Less AttackSpeed, Take More Dmg")
				}
				case 10:
				{
					CreateTimer(0.01, MoreAttackSpeed, client, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(0.01, DealMoreDmg, client, TIMER_FLAG_NO_MAPCHANGE);
					//PrintToChat(client, "AttackSpeed bonus, Dmg Bonus")
				}
				case 11:
				{
					CreateTimer(0.01, LessAttackSpeed, client, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(0.01, DealLessDmg, client, TIMER_FLAG_NO_MAPCHANGE);
					//PrintToChat(client, "Less Dmg, Less Attack Speed)
				}
				case 12:
				{
					CreateTimer(0.01, LessAttackSpeed, client, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(0.01, DealMoreDmg, client, TIMER_FLAG_NO_MAPCHANGE);
					//PrintToChat(client, "More Dmg, Less Attack Speed)
				}
				case 13:
				{
					CreateTimer(0.01, MoreAttackSpeed, client, TIMER_FLAG_NO_MAPCHANGE);
					TF2_StunPlayer(client, SlowStunTimer_Pap, SlownessAmount_Pap, TF_STUNFLAG_SLOWDOWN, _);
				}
			}
		}
	}
}
//Third Pap Stuff so i can do this better without going crazy
public Action LessAttackSpeed(Handle cut_timer, int client)
{
	if(IsValidClient(client))
	{
		int weapon = EntRefToEntIndex(weapon_id[client]);
		fl_IncreaseAttackSpeed[client] = 1.0;
		/*Address address = TF2Attrib_GetByDefIndex(weapon, 6);
		if(address != Address_Null)
		fl_IncreaseAttackSpeed[client] = TF2Attrib_GetValue(address);
		Attributes_Set(weapon, 6, fl_IncreaseAttackSpeed[client] * DecreaseAttackSpeed_Pap);*/
		ApplyTempAttrib(weapon, 6, DecreaseAttackSpeed_Pap);
		//CreateTimer(ResetAttackSpeedTimer, Reset_ToNormalAttackSpeed2_Pap, client, TIMER_FLAG_NO_MAPCHANGE);
		//PrintToChat(client, "Less Attack Speed works!")
	}
	return Plugin_Handled;
}

public Action MoreAttackSpeed(Handle cut_timer, int client)
{
	if(IsValidClient(client))
	{
		int weapon = EntRefToEntIndex(weapon_id[client]);
		fl_IncreaseAttackSpeed[client] = 1.0;
		/*Address address = TF2Attrib_GetByDefIndex(weapon, 6);
		if(address != Address_Null)
		fl_IncreaseAttackSpeed[client] = TF2Attrib_GetValue(address);
		Attributes_Set(weapon, 6, fl_IncreaseAttackSpeed[client] * IncreaseAttackSpeed_Pap);*/
		ApplyTempAttrib(weapon, 6, IncreaseAttackSpeed_Pap, 0.1);
		//CreateTimer(ResetLessAttackSpeedTimer, Reset_ToNormalAttackSpeed_Pap, client, TIMER_FLAG_NO_MAPCHANGE);
		//PrintToChat(client, "More Attack Speed works!")
	}
	return Plugin_Handled;
}

public Action DealMoreDmg(Handle cut_timer, int client)
{
	if(IsValidClient(client))
	{
		int weapon = EntRefToEntIndex(weapon_id[client]);
		fl_IncreaseDamage[client] = 1.0;
		/*Address address = TF2Attrib_GetByDefIndex(weapon, 2);
		if(address != Address_Null)
		fl_IncreaseDamage[client] = TF2Attrib_GetValue(address);
		Attributes_Set(weapon, 2, fl_IncreaseDamage[client] * DamageMultiplier_Pap);*/
		ApplyTempAttrib(weapon, 2, DamageMultiplier_Pap);
		//CreateTimer(ResetDealMoreDmgTimer, Reset_fl_IncreaseDamage_Pap, client, TIMER_FLAG_NO_MAPCHANGE);
		//PrintToChat(client, "More Attack Damage works!")
	}
	return Plugin_Handled;
}

public Action DealLessDmg(Handle cut_timer, int client)
{
	if(IsValidClient(client))
	{
		int weapon = EntRefToEntIndex(weapon_id[client]);
		fl_IncreaseDamage[client] = 1.0;
		/*Address address = TF2Attrib_GetByDefIndex(weapon, 2);
		if(address != Address_Null)
		fl_IncreaseDamage[client] = TF2Attrib_GetValue(address);
		Attributes_Set(weapon, 2, fl_IncreaseDamage[client] * LessDamageMultiplier_Pap);*/
		ApplyTempAttrib(weapon, 2, LessDamageMultiplier_Pap);
		//CreateTimer(ResetDealLessDmgTimer, Reset_fl_DecreaseDamage_Pap, client, TIMER_FLAG_NO_MAPCHANGE);
		//PrintToChat(client, "More Attack Damage works!")
	}
	return Plugin_Handled;
}

public Action TakeMoreDmg(Handle cut_timer, int client)
{
	if(IsValidClient(client))
	{
		//int weapon = EntRefToEntIndex(weapon_id[client]);
		//ApplyTempAttrib(weapon, 412, TakeMoreDamageMultiplier_Pap, ResetTakeMoreDmgTimer);
		//PrintToChat(client, "More Attack Damage works!")
		TF2_AddCondition(client, TFCond_MarkedForDeathSilent, 0.44, 0);
	}
	return Plugin_Handled;
}

//Reset
/*
public Action Reset_ToNormalAttackSpeed(Handle cut_timer, int client)
{
	if(IsValidClient(client))
	{
		int weapon = EntRefToEntIndex(weapon_id[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			//Attributes_Set(weapon, 6, fl_IncreaseAttackSpeed[client]);
			ApplyTempAttrib(weapon, 6, fl_IncreaseAttackSpeed[client] / IncreaseAttackSpeed, false);
		}
		//PrintToChat(client, "Reset AttackSpeed")
	}
	return Plugin_Handled;
}

public Action Reset_ToNormalAttackSpeed2_Pap(Handle cut_timer, int client)
{
	if(IsValidClient(client))
	{
		int weapon = EntRefToEntIndex(weapon_id[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			//Attributes_Set(weapon, 6, fl_IncreaseAttackSpeed[client]);
			ApplyTempAttrib(weapon, 6, fl_IncreaseAttackSpeed[client] / DecreaseAttackSpeed_Pap, false);
		}
		//PrintToChat(client, "Reset AttackSpeed")
	}
	return Plugin_Handled;
}

public Action Reset_ToNormalAttackSpeed_Pap(Handle cut_timer, int client)
{
	if(IsValidClient(client))
	{
		int weapon = EntRefToEntIndex(weapon_id[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			//Attributes_Set(weapon, 6, fl_IncreaseAttackSpeed[client]);
			ApplyTempAttrib(weapon, 6, fl_IncreaseAttackSpeed[client] / IncreaseAttackSpeed_Pap, false);
		}
		//PrintToChat(client, "Reset AttackSpeed")
	}
	return Plugin_Handled;
}

public Action Reset_fl_IncreaseDamage(Handle cut_timer, int client)
{
	if(IsValidClient(client))
	{
		int weapon = EntRefToEntIndex(weapon_id[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			//Attributes_Set(weapon, 2, fl_IncreaseDamage[client]);
			ApplyTempAttrib(weapon, 2, fl_IncreaseDamage[client] / DamageMultiplier, false);
		}
		//PrintToChat(client, "Reset Damage")
	}
	return Plugin_Handled;
}

public Action Reset_fl_DecreaseDamage(Handle cut_timer, int client)
{
	if(IsValidClient(client))
	{
		int weapon = EntRefToEntIndex(weapon_id[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			//Attributes_Set(weapon, 2, fl_IncreaseDamage[client]);
			ApplyTempAttrib(weapon, 2, fl_IncreaseDamage[client] / LessDamageMultiplier, false);
		}
		//PrintToChat(client, "Reset Damage")
	}
	return Plugin_Handled;
}

public Action Reset_fl_IncreaseDamage_Pap(Handle cut_timer, int client)
{
	if(IsValidClient(client))
	{
		int weapon = EntRefToEntIndex(weapon_id[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			//Attributes_Set(weapon, 2, fl_IncreaseDamage[client]);
			ApplyTempAttrib(weapon, 2, fl_IncreaseDamage[client] / DamageMultiplier_Pap, false);
		}
		//PrintToChat(client, "Reset Damage")
	}
	return Plugin_Handled;
}

public Action Reset_fl_DecreaseDamage_Pap(Handle cut_timer, int client)
{
	if(IsValidClient(client))
	{
		int weapon = EntRefToEntIndex(weapon_id[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			ApplyTempAttrib(weapon, 2, fl_IncreaseDamage[client] / LessDamageMultiplier_Pap, false);
		}
		//PrintToChat(client, "Reset Damage")
	}
	return Plugin_Handled;
}

public Action Reset_TakeMoreDmg(Handle cut_timer, int client)
{
	if(IsValidClient(client))
	{
		int weapon = EntRefToEntIndex(weapon_id[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			Attributes_Set(weapon, 412, fl_IncreaseDamageTaken[client]);
		}
		//PrintToChat(client, "Reset Take More Dmg")
	}
	return Plugin_Handled;
}*/
