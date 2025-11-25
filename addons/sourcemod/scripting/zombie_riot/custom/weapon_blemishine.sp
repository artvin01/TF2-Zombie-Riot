#pragma semicolon 1
#pragma newdecls required

static float f_BlemishineThinkDelay[MAXPLAYERS];
static float f_Blemishine_AbilityActive[MAXPLAYERS];
static int i_BlemishineWhichAbility[MAXPLAYERS];
static float f_AbilityHealAmmount[MAXPLAYERS];

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
	f_Blemishine_AbilityActive[client] = 0.0;
}
public void Weapon_BlemishineAttackM2BasePre(int client, int weapon, bool &result, int slot)
{
	//This melee is too unique, we have to code it in a different way.
	if (Ability_Check_Cooldown(client, slot) < 0.0 || CvarInfiniteCash.BoolValue)
	{
		Rogue_OnAbilityUse(client, weapon);
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
		
		i_BlemishineWhichAbility[client] = 1;
		float value = Attributes_Get(weapon, 180, 0.0);
		f_AbilityHealAmmount[client] = value * 2.0;
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
public void Weapon_BlemishineAttackM2Base(int client, int weapon, bool &result, int slot)
{
	//This melee is too unique, we have to code it in a different way.
	if (Ability_Check_Cooldown(client, slot) < 0.0 || CvarInfiniteCash.BoolValue)
	{
		Rogue_OnAbilityUse(client, weapon);
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
		float value = Attributes_Get(weapon, 180, 0.0);
		f_AbilityHealAmmount[client] = value * 2.0;
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
		Rogue_OnAbilityUse(client, weapon);
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
		float value = Attributes_Get(weapon, 180, 0.0);
		f_AbilityHealAmmount[client] = value * 2.0;
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
		Rogue_OnAbilityUse(client, weapon);
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
		float value = Attributes_Get(weapon, 180, 0.0);
		f_AbilityHealAmmount[client] = value * 2.0;
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
public float Player_OnTakeDamage_Blemishine(int victim, int attacker, float &damage, int damagetype)
{
	if(damagetype & DMG_TRUEDAMAGE)
		return damage;

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

public float Player_OnTakeDamage_Blemishine_Hud(int victim)
{
	if(GetGameTime() < f_Blemishine_AbilityActive[victim])
	{
		switch(i_BlemishineWhichAbility[victim])
		{
			case 1:
			{
				return 0.8;
			}
			case 2:
			{
				return 0.75;
			}
		}
	}

	return 1.0;
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
				float value = Attributes_Get(weapon, 180, 0.0);
				value *= 8.0;
				DoHealingOcean(attacker, attacker, (150.0 * 150.0), value * 1.35, true);
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
			if(f_AbilityHealAmmount[client] > 0.0)
			{
				DoHealingOcean(client, client, (200.0 * 200.0), f_AbilityHealAmmount[client] * 1.0, true);
				float flPos[3];
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);		
				spawnRing_Vectors(flPos, /*RANGE*/ 200.0 * 2.0, 0.0, 0.0, 15.0, EMPOWER_MATERIAL, 231, 231, 4, 125, 1, /*DURATION*/ 0.12, 3.0, 2.5, 5);
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

	if(AtEdictLimit(EDICT_PLAYER))
		return;
		
	float flPos[3];
	float flAng[3];
	GetAttachment(viewmodelModel, "flag", flPos, flAng);

	int particle_1 = InfoTargetParentAt({0.0,0.0,0.0}, "", duration);
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


	int Laser_1 = ConnectWithBeamClient(particle_2, particle_1, 200, 166, 35, 2.0, 6.0, 1.0, LASERBEAM, client);
	int Laser_2 = ConnectWithBeamClient(particle_3, particle_1, 200, 166, 35, 2.0, 6.0, 1.0, LASERBEAM, client);
	int Laser_3 = ConnectWithBeamClient(particle_3_1, particle_3, 200, 166, 35, 1.0, 2.0, 1.0, LASERBEAM, client);
	int Laser_4 = ConnectWithBeamClient(particle_2_1, particle_2, 200, 166, 35, 1.0, 2.0, 1.0, LASERBEAM, client);

	CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(Laser_1), TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(Laser_2), TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(Laser_3), TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(Laser_4), TIMER_FLAG_NO_MAPCHANGE);
}