#pragma semicolon 1
#pragma newdecls required

//Handle h_TimerBlemishineManagement[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
//static float f_BlemishineHudDelay[MAXTF2PLAYERS];
static float f_BlemishineThinkDelay[MAXTF2PLAYERS];
static float f_Blemishine_AbilityActive[MAXTF2PLAYERS];
static int i_BlemishineWhichAbility[MAXTF2PLAYERS];
static float f_AbilityHealAmmount[MAXTF2PLAYERS];

#define BLEMISHINE_RANGE_ABILITY	150.0
#define BLEMISHINE_COOLDOWN			40.0
#define BLEMISHINE_ABILITY_ACTIVE	5.0
#define BLEMISHINE_DISTANCE_WINGS	50.0

void Blemishine_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	PrecacheSound("weapons/vaccinator_charge_tier_04.wav");
	PrecacheSound("player/taunt_medic_heroic.wav");
//	Zero(f_BlemishineHudDelay);
	Zero(f_BlemishineThinkDelay);
}

void Reset_stats_Blemishine_Singular(int client) //This is on disconnect/connect
{
//	if (h_TimerBlemishineManagement[client] != INVALID_HANDLE)
//	{
//		KillTimer(h_TimerBlemishineManagement[client]);
//	}	
	f_Blemishine_AbilityActive[client] = 0.0;
//	h_TimerBlemishineManagement[client] = INVALID_HANDLE;
}

public void Weapon_BlemishineAttackM2Base(int client, int weapon, bool &result, int slot)
{
	//This melee is too unique, we have to code it in a different way.
	if (Ability_Check_Cooldown(client, slot) < 0.0 || CvarInfiniteCash.BoolValue)
	{
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, BLEMISHINE_COOLDOWN);
		f_Blemishine_AbilityActive[client] = GetGameTime() + BLEMISHINE_ABILITY_ACTIVE;
		float flPos[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);		
		ParticleEffectAt(flPos, "bombinomicon_flash", 1.0);
		int particle_Sing = ParticleEffectAt(flPos, "utaunt_arcane_yellow_parent", BLEMISHINE_ABILITY_ACTIVE);
		SetParent(client, particle_Sing);
		EmitSoundToAll("player/taunt_medic_heroic.wav", client, SNDCHAN_AUTO, 75,_,1.0,100);
		EmitSoundToAll("weapons/vaccinator_charge_tier_04.wav", client, SNDCHAN_AUTO, 75,_,1.0,100);
		MakePlayerGiveResponseVoice(client, 1); //haha!
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		Explode_Logic_Custom(0.0, client, client, weapon, _, BLEMISHINE_RANGE_ABILITY,_,_,_,_,_,_,BlemishineAbilityHit);
		FinishLagCompensation_Base_boss();
		i_BlemishineWhichAbility[client] = 1;
		float value = Attributes_FindOnWeapon(client, weapon, 180);
		f_AbilityHealAmmount[client] = value * 1.9;
		SDKUnhook(client, SDKHook_PreThink, Blemishine_Think);
		SDKHook(client, SDKHook_PreThink, Blemishine_Think);
		/*
			utaunt_arcane_yellow_parent

		*/
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

public void Weapon_BlemishineAttackM2Stronger(int client, int weapon, bool &result, int slot)
{
	//This melee is too unique, we have to code it in a different way.
	if (Ability_Check_Cooldown(client, slot) < 0.0 || CvarInfiniteCash.BoolValue)
	{
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, BLEMISHINE_COOLDOWN);
		f_Blemishine_AbilityActive[client] = GetGameTime() + BLEMISHINE_ABILITY_ACTIVE;
		float flPos[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);		
		ParticleEffectAt(flPos, "bombinomicon_flash", 1.0);
		int particle_Sing = ParticleEffectAt(flPos, "utaunt_arcane_yellow_parent", BLEMISHINE_ABILITY_ACTIVE);
		SetParent(client, particle_Sing);
		BlemishineAuraEffects(client, BLEMISHINE_ABILITY_ACTIVE);
		EmitSoundToAll("player/taunt_medic_heroic.wav", client, SNDCHAN_AUTO, 75,_,1.0,100);
		EmitSoundToAll("weapons/vaccinator_charge_tier_04.wav", client, SNDCHAN_AUTO, 75,_,1.0,100);
		MakePlayerGiveResponseVoice(client, 1); //haha!
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		Explode_Logic_Custom(0.0, client, client, weapon, _, BLEMISHINE_RANGE_ABILITY,_,_,_,_,_,_,BlemishineAbilityHit2);
		FinishLagCompensation_Base_boss();
		i_BlemishineWhichAbility[client] = 2;
		float value = Attributes_FindOnWeapon(client, weapon, 180);
		f_AbilityHealAmmount[client] = value * 1.9;
		SDKUnhook(client, SDKHook_PreThink, Blemishine_Think);
		SDKHook(client, SDKHook_PreThink, Blemishine_Think);
		/*
			utaunt_arcane_yellow_parent
		*/
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

public void Weapon_BlemishineAttackM2Strongest(int client, int weapon, bool &result, int slot)
{
	//This melee is too unique, we have to code it in a different way.
	if (Ability_Check_Cooldown(client, slot) < 0.0 || CvarInfiniteCash.BoolValue)
	{
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, BLEMISHINE_COOLDOWN);
		f_Blemishine_AbilityActive[client] = GetGameTime() + BLEMISHINE_ABILITY_ACTIVE;
		float flPos[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);		
		ParticleEffectAt(flPos, "bombinomicon_flash", 1.0);
		int particle_Sing = ParticleEffectAt(flPos, "utaunt_arcane_yellow_parent", BLEMISHINE_ABILITY_ACTIVE);
		SetParent(client, particle_Sing);
		BlemishineAuraEffects(client, BLEMISHINE_ABILITY_ACTIVE);
		EmitSoundToAll("player/taunt_medic_heroic.wav", client, SNDCHAN_AUTO, 75,_,1.0,100);
		EmitSoundToAll("weapons/vaccinator_charge_tier_04.wav", client, SNDCHAN_AUTO, 75,_,1.0,100);
		MakePlayerGiveResponseVoice(client, 1); //haha!
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		Explode_Logic_Custom(0.0, client, client, weapon, _, BLEMISHINE_RANGE_ABILITY,_,_,_,_,_,_,BlemishineAbilityHit3);
		FinishLagCompensation_Base_boss();
		i_BlemishineWhichAbility[client] = 2;
		float value = Attributes_FindOnWeapon(client, weapon, 180);
		f_AbilityHealAmmount[client] = value * 1.9;
		SDKUnhook(client, SDKHook_PreThink, Blemishine_Think);
		SDKHook(client, SDKHook_PreThink, Blemishine_Think);
		/*
			utaunt_arcane_yellow_parent
		*/
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

void BlemishineAbilityHit(int entity, int victim, float damage, int weapon)
{
	float StunDuration = 2.0;
	if(b_thisNpcIsABoss[victim])
	{
		StunDuration = 1.0;
	}	
	if(b_thisNpcIsARaid[victim])
	{
		StunDuration = 0.85;
	}	

	FreezeNpcInTime(victim, StunDuration);
}

void BlemishineAbilityHit2(int entity, int victim, float damage, int weapon)
{
	float StunDuration = 3.5;
	if(b_thisNpcIsABoss[victim])
	{
		StunDuration = 1.5;
	}	
	if(b_thisNpcIsARaid[victim])
	{
		StunDuration = 1.25;
	}	

	FreezeNpcInTime(victim, StunDuration);
}
void BlemishineAbilityHit3(int entity, int victim, float damage, int weapon)
{
	float StunDuration = 4.5;
	if(b_thisNpcIsABoss[victim])
	{
		StunDuration = 2.5;
	}	
	if(b_thisNpcIsARaid[victim])
	{
		StunDuration = 2.0;
	}	

	FreezeNpcInTime(victim, StunDuration);
}
/*
public void Enable_Blemishine(int client, int weapon) 
{
	if (h_TimerBlemishineManagement[client] != INVALID_HANDLE)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BLEMISHINE) 
		{
			//Is the weapon it again?
			//Yes?
			KillTimer(h_TimerBlemishineManagement[client]);
			h_TimerBlemishineManagement[client] = INVALID_HANDLE;
			DataPack pack;
			h_TimerBlemishineManagement[client] = CreateDataTimer(0.1, Timer_Management_Blemishine, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BLEMISHINE) //9 Is for Passanger
	{
		DataPack pack;
		h_TimerBlemishineManagement[client] = CreateDataTimer(0.1, Timer_Management_Blemishine, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}



public Action Timer_Management_Blemishine(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(IsValidClient(client))
	{
		if (IsClientInGame(client))
		{
			if (IsPlayerAlive(client))
			{
				Blemishine_Cooldown_Logic(client, EntRefToEntIndex(pack.ReadCell()));
			}
			else
				Kill_Timer_Blemishine(client);
		}
		else
			Kill_Timer_Blemishine(client);
	}
	else
		Kill_Timer_Blemishine(client);
		
	return Plugin_Continue;
}

public void Blemishine_Cooldown_Logic(int client, int weapon)
{
	if (!IsValidMulti(client))
		return;
		
	if(IsValidEntity(weapon))
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BLEMISHINE)
		{
			int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
			{
				if(f_BlemishineHudDelay[client] < GetGameTime())
				{
					float cooldown = Ability_Check_Cooldown(client, 2);
					if(cooldown > 0.0)
					{
						PrintHintText(client,"%.1f％",cooldown);	
					}
					else
					{
						PrintHintText(client,"%.1f％",cooldown);	
					}
					StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
					f_BlemishineHudDelay[client] = GetGameTime() + 0.5;
				}
			}
		}
		else
		{
			Kill_Timer_Blemishine(client);
		}
	}
	else
	{
		Kill_Timer_Blemishine(client);
	}
}

public void Kill_Timer_Blemishine(int client)
{
	if (h_TimerBlemishineManagement[client] != INVALID_HANDLE)
	{
		KillTimer(h_TimerBlemishineManagement[client]);
		h_TimerBlemishineManagement[client] = INVALID_HANDLE;
	}
}
*/
public float Player_OnTakeDamage_Blemishine(int victim, int attacker, float &damage)
{
	if(GetGameTime() < f_Blemishine_AbilityActive[victim])
	{
		switch(i_BlemishineWhichAbility[victim])
		{
			case 1:
			{
				damage *= 0.8;
			}
			case 2:
			{
				damage *= 0.75;
			}
		}
	}

	return damage;
}

public float NPC_OnTakeDamage_Blemishine(int attacker, int victim, float &damage, int weapon)
{
	if(f_TimeFrozenStill[victim] > GetGameTime(victim))
	{
		damage *= 1.35; //deal more damage against frozen targets.
		DisplayCritAboveNpc(victim, attacker, true);
	}
	if(GetGameTime() < f_Blemishine_AbilityActive[attacker])
	{
		switch(i_BlemishineWhichAbility[attacker])
		{
			case 1:
			{
				damage *= 1.45;
			}
			case 2:
			{
				float value = Attributes_FindOnWeapon(attacker, weapon, 180);
				value *= 8.0;
				DoHealingOcean(attacker, attacker, (150.0 * 150.0), value, true);
				damage *= 2.0;
			}
		}
	}
	return damage;
}

public void Blemishine_Think(int client)
{
	if(f_BlemishineThinkDelay[client] > GetGameTime())
	{
		return;
	}
	f_BlemishineThinkDelay[client] = GetGameTime() + 0.1;
	if(GetGameTime() < f_Blemishine_AbilityActive[client])
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding > 0)
		{		
			if(i_CustomWeaponEquipLogic[weapon_holding] != WEAPON_BLEMISHINE) 
			{
				f_Blemishine_AbilityActive[client] = 0.0; //reset.
				SDKUnhook(client, SDKHook_PreThink, Blemishine_Think);
				return;
			}
			if(f_AbilityHealAmmount[client] > 0)
			{
				DoHealingOcean(client, client, (150.0 * 150.0), f_AbilityHealAmmount[client], true);
				return;
			}
			
		}
		SDKUnhook(client, SDKHook_PreThink, Blemishine_Think);
		return;
	}
	SDKUnhook(client, SDKHook_PreThink, Blemishine_Think);
	return;
}


void BlemishineAuraEffects(int client, float duration)
{
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);

	if(!IsValidEntity(viewmodelModel))
		return;

	float flPos[3];
	float flAng[3];
	GetAttachment(viewmodelModel, "flag", flPos, flAng);

	int particle_1 = ParticleEffectAt({0.0,0.0,0.0}, "", duration);
	int particle_2 = ParticleEffectAt({50.0,-10.0,10.0}, "rockettrail_fire_airstrike", duration);
	int particle_2_1 = ParticleEffectAt({80.0,-5.0,-20.0}, "rockettrail_fire_airstrike", duration);
	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_2, particle_2_1, "",_, true);

	int particle_3 = ParticleEffectAt({-50.0,-10.0,10.0}, "rockettrail_fire_airstrike", duration);
	int particle_3_1 = ParticleEffectAt({-80.0,-5.0,-20.0}, "rockettrail_fire_airstrike", duration);
	SetParent(particle_1, particle_3, "",_, true);
	SetParent(particle_3, particle_3_1, "",_, true);

	Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
	SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(viewmodelModel, particle_1, "flag",_);


	int Laser_1 = ConnectWithBeamClient(particle_2, particle_1, 200, 166, 35, 2.0, 6.0, 1.0, LASERBEAM);
	int Laser_2 = ConnectWithBeamClient(particle_3, particle_1, 200, 166, 35, 2.0, 6.0, 1.0, LASERBEAM);
	int Laser_3 = ConnectWithBeamClient(particle_3_1, particle_3, 200, 166, 35, 1.0, 2.0, 1.0, LASERBEAM);
	int Laser_4 = ConnectWithBeamClient(particle_2_1, particle_2, 200, 166, 35, 1.0, 2.0, 1.0, LASERBEAM);

	CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(Laser_1), TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(Laser_2), TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(Laser_3), TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(Laser_4), TIMER_FLAG_NO_MAPCHANGE);
}