#pragma semicolon 1
#pragma newdecls required
//no idea how those work but they are needed from what i see
static int weapon_id[MAXPLAYERS+1]={0, ...};
static int Board_Hits[MAXPLAYERS+1]={0, ...};
static int Board_Level[MAXPLAYERS+1]={0, ...};
static float f_ParryDuration[MAXPLAYERS+1]={0.0, ...};
static float f_AniSoundSpam[MAXPLAYERS+1]={0.0, ...};
static int Board_OutlineModel[MAXPLAYERS+1]={INVALID_ENT_REFERENCE, ...};
static bool Board_Ability_1[MAXPLAYERS+1]; //please forgive me for I have sinned
static float f_BoardReflectCooldown[MAXTF2PLAYERS][MAXENTITIES];
static int ParryCounter = 0;

Handle h_TimerWeaponBoardManagement[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
static float f_WeaponBoardhuddelay[MAXPLAYERS+1]={0.0, ...};

void WeaponBoard_Precache()
{
	PrecacheSound("weapons/air_burster_explode1.wav");
	Zero(f_ParryDuration);
	Zero2(f_BoardReflectCooldown);
}

void Board_EntityCreated(int entity) 
{
	for(int i=1; i<=MaxClients; i++)
	{
		f_BoardReflectCooldown[i][entity] = 0.0;
	}
}

public void Punish(int victim, int weapon, int bool) //AOE parry damage that scales with melee upgrades, im a coding maestro SUPREME
{
	float damage = 107.5;
	damage *= Attributes_Get(weapon, 2, 1.0);
			
	int value = i_ExplosiveProjectileHexArray[victim];
	i_ExplosiveProjectileHexArray[victim] = EP_DEALS_CLUB_DAMAGE;

	float UserLoc[3];
	GetClientAbsOrigin(victim, UserLoc);

	float Range = 250.0;
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(victim);				
	Explode_Logic_Custom(damage, victim, victim, weapon, _, Range, 1.0, 0.0, false, 6,_,_);
	FinishLagCompensation_Base_boss();

	i_ExplosiveProjectileHexArray[victim] = value;

	EmitSoundToAll("weapons/air_burster_explode1.wav", victim, SNDCHAN_AUTO, 90, _, 1.0);
}

public void SwagMeter(int victim, int weapon) //so that parrying 2 enemies at once doesnt grant more effects
{
	if (Board_Ability_1[victim] == true)
	{
		float MaxHealth = float(SDKCall_GetMaxHealth(victim));
		if (MaxHealth > 1500.0)
		{
			MaxHealth = 1500.0;
		}
		if (Board_Level[victim] == 2)
		{
			StartHealingTimer(victim, 0.1, MaxHealth * 0.004, 5);
			Board_Ability_1[victim] = false;
		}
		else if (Board_Level[victim] == 5)
		{
			ApplyTempAttrib(victim, 26, 1.14, 4.3);
			StartHealingTimer(victim, 0.1, MaxHealth * 0.004, 5);
			Board_Ability_1[victim] = false;
		}
		else if(Board_Level[victim] == 4)
		{
			Punish(victim, weapon, true);
			Board_Ability_1[victim] = false;
		}
		else
		{
			return;
		}
	}
	else
	{
		return;
	}

}

public void Board_empower_ability(int client, int weapon, bool crit, int slot) // Base parry mechanic, level 0
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
		float Cooldown = 5.0;
		Cooldown = ShieldCutOffCooldown_Board(Cooldown, weapon);
		Ability_Apply_Cooldown(client, slot, Cooldown);

		Board_Level[client] = 0;
		
		weapon_id[client] = weapon;

		OnAbilityUseEffect_Board(client, weapon);

		//PrintToChatAll("Board ability");

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

public void Board_empower_ability_Spike(int client, int weapon, bool crit, int slot) // Parry for the Spike shield, level 1
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
		float Cooldown = 5.0;
		Cooldown = ShieldCutOffCooldown_Board(Cooldown, weapon);
		Ability_Apply_Cooldown(client, slot, Cooldown);

		Board_Level[client] = 1;
		
		weapon_id[client] = weapon;

		OnAbilityUseEffect_Board(client, weapon);

		//PrintToChatAll("Spike parry");
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

public void Board_empower_ability_Leaf(int client, int weapon, bool crit, int slot) // Parry for the Leaf shield, level 2
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
		float Cooldown = 5.0;
		Cooldown = ShieldCutOffCooldown_Board(Cooldown, weapon);
		Ability_Apply_Cooldown(client, slot, Cooldown);

		Board_Level[client] = 2;
		
		Board_Ability_1[client] = true;

		weapon_id[client] = weapon;
		
		OnAbilityUseEffect_Board(client, weapon);

		//PrintToChatAll("Leaf parry");

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

public void Board_empower_ability_Rookie(int client, int weapon, bool crit, int slot) // Parry for the Rookie Shield, level 3
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
		float Cooldown = 3.0;
		Cooldown = ShieldCutOffCooldown_Board(Cooldown, weapon);
		Ability_Apply_Cooldown(client, slot, Cooldown);

		Board_Level[client] = 3;
		
		weapon_id[client] = weapon;

		OnAbilityUseEffect_Board(client, weapon);
				

		//PrintToChatAll("Rookie Parry");

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

public void Board_empower_ability_Punishment(int client, int weapon, bool crit, int slot) // Parry for the Punishment Shield, level 4
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
		float Cooldown = 5.0;
		Cooldown = ShieldCutOffCooldown_Board(Cooldown, weapon);
		Ability_Apply_Cooldown(client, slot, Cooldown);

		Board_Level[client] = 4;
		
		Board_Ability_1[client] = true;

		weapon_id[client] = weapon;

		OnAbilityUseEffect_Board(client, weapon);

		//PrintToChatAll("Board parry");

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

public void Board_empower_ability_Rampart(int client, int weapon, bool crit, int slot) // Parry for the Rampart Shield, level 5
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
		float Cooldown = 5.0;
		Cooldown = ShieldCutOffCooldown_Board(Cooldown, weapon);
		Ability_Apply_Cooldown(client, slot, Cooldown);

		Board_Level[client] = 5;
		
		Board_Ability_1[client] = true;

		weapon_id[client] = weapon;

		OnAbilityUseEffect_Board(client, weapon);

		//PrintToChatAll("Board parry");

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

public void Board_empower_ability_Cudgel(int client, int weapon, bool crit, int slot) // Parry for the Cudgel Shield, level 6
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
		float Cooldown = 3.0;
		Cooldown = ShieldCutOffCooldown_Board(Cooldown, weapon);
		Ability_Apply_Cooldown(client, slot, Cooldown);

		Board_Level[client] = 6;
		
		weapon_id[client] = weapon;

		OnAbilityUseEffect_Board(client, weapon);

		//PrintToChatAll("Board parry");

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
//stuff that gets activated upon taking any damage
public float Player_OnTakeDamage_Board(int victim, float &damage, int attacker, int weapon, float damagePosition[3])
{
	if (f_ParryDuration[victim] > GetGameTime())
	{
		if(Board_Level[victim] == 1)
		{
			Board_Hits[victim] += 1;
		}
		else if(Board_Level[victim] == 2)
		{
			Board_Hits[victim] += 1;
			SwagMeter(victim, weapon);
		}
		else if(Board_Level[victim] == 3)
		{
			Board_Hits[victim] += 1;
		}
		else if(Board_Level[victim] == 4)
		{
			Board_Hits[victim] += 1;
			SwagMeter(victim, weapon);
		}
		else if(Board_Level[victim] == 5)
		{
			Board_Hits[victim] += 1;
			SwagMeter(victim, weapon);
		}
		else if(Board_Level[victim] == 6)
		{
			Board_Hits[victim] += 1;
			float time = GetGameTime() + 3.95;
			if(f_CudgelDebuff[attacker] <= time)
				f_CudgelDebuff[attacker] = time;
		}
		else if(Board_Level[victim] == 0)
		{
			Board_Hits[victim] += 1;
		}
		
		if(f_AniSoundSpam[victim] < GetGameTime())
		{
			f_AniSoundSpam[victim] = GetGameTime() + 0.2;
			PlayParrySoundBoard(victim);
			float flPos[3]; // original
			float flAng[3]; // original
			
			GetAttachment(victim, "effect_hand_l", flPos, flAng);
			
			ParticleEffectAt(flPos, "mvm_soldier_shockwave", 0.15);
		}
	
		
		if(f_BoardReflectCooldown[victim][attacker] < GetGameTime())
		{
			ParryCounter += 1;
			float ParriedDamage = 0.0;
			switch (ParryCounter)
			{
				case 1:
				{
					ParriedDamage = 70.0;
				}
				case 2:
				{
					ParriedDamage = 65.0;
				}
				case 3:
				{
					ParriedDamage = 55.0;
				}
				case 4:
				{
					ParriedDamage = 45.0;
				}
				case 5, 6, 7:
				{
					ParriedDamage = 25.0;
				}
				default:
				{
					ParriedDamage = 0.0;
				}
			}
			ParriedDamage = CalculateDamageBonus_Board(ParriedDamage, weapon);
		
			static float angles[3];
			GetEntPropVector(victim, Prop_Send, "m_angRotation", angles);
			float vecForward[3];
			GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
			static float Entity_Position[3];
			Entity_Position = WorldSpaceCenter(attacker);

			f_BoardReflectCooldown[victim][attacker] = GetGameTime() + 0.1;
			SDKHooks_TakeDamage(attacker, victim, victim, ParriedDamage, DMG_CLUB, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position);
		}

		switch (ParryCounter)
		{
			case 1:
			{
				return damage * 0.3;
			}
			case 2:
			{
				return damage * 0.4;
			}
			default:
			{
				return damage * 0.7;
			}
		}

	}
	else if(Board_Level[victim] == 0) //board
	{
		//PrintToChatAll("damage resist");
		return damage * 0.9;
	}
	else if(Board_Level[victim] == 1) //spike
	{
		//PrintToChatAll("damage resist");
		return damage * 0.95;
	}
	else if(Board_Level[victim] == 2) //leaf
	{
		//PrintToChatAll("damage resist");
		return damage * 0.85;
	}
	else if(Board_Level[victim] == 3) //rookie
	{
		//PrintToChatAll("damage resist");
		return damage * 0.9;
	}
	else if(Board_Level[victim] == 4) //punish
	{
		//PrintToChatAll("damage resist");
		return damage * 0.85;
	}
	else if(Board_Level[victim] == 5) //ramp
	{
		//PrintToChatAll("damage resist");
		return damage * 0.75;
	}
	else if(Board_Level[victim] == 6) //the last one cudgel
	{
		//PrintToChatAll("damage resist");
		return damage * 0.8;
	}
	else
	{
		return damage;
	}
}

public void Kill_Timer_WeaponBoard(int client)
{
	if (h_TimerWeaponBoardManagement[client] != INVALID_HANDLE)
	{
		KillTimer(h_TimerWeaponBoardManagement[client]);
		h_TimerWeaponBoardManagement[client] = INVALID_HANDLE;
	}
}

public void WeaponBoard_Cooldown_Logic(int client, int weapon)
{
	if (!IsValidMulti(client))
		return;
		
	if(IsValidEntity(weapon))
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BOARD) //Double check to see if its good or bad :(
		{	
			if(f_WeaponBoardhuddelay[client] < GetGameTime())
			{
				f_WeaponBoardhuddelay[client] = GetGameTime() + 0.5;
				int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
				{
					StopSound(client, SNDCHAN_STATIC, "ui/hint.wav");
				}
			}
		}
		else
		{
			Kill_Timer_WeaponBoard(client);
		}
	}
	else
	{
		Kill_Timer_WeaponBoard(client);
	}
}
public Action Timer_Management_WeaponBoard(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(IsValidClient(client))
	{
		if (IsClientInGame(client))
		{
			if (IsPlayerAlive(client))
			{
				WeaponBoard_Cooldown_Logic(client, EntRefToEntIndex(pack.ReadCell()));
			}
			else
				Kill_Timer_WeaponBoard(client);
		}
		else
			Kill_Timer_WeaponBoard(client);
	}
	else
		Kill_Timer_WeaponBoard(client);
		
	return Plugin_Continue;
}

public void Enable_WeaponBoard(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerWeaponBoardManagement[client] != INVALID_HANDLE)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BOARD)
		{
			KillTimer(h_TimerWeaponBoardManagement[client]);
			h_TimerWeaponBoardManagement[client] = INVALID_HANDLE;
			DataPack pack;
			h_TimerWeaponBoardManagement[client] = CreateDataTimer(0.1, Timer_Management_WeaponBoard, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BOARD)
	{
		DataPack pack;
		h_TimerWeaponBoardManagement[client] = CreateDataTimer(0.1, Timer_Management_WeaponBoard, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

void OnAbilityUseEffect_Board(int client, int active, int FramesActive = 35)
{
	int WeaponModel;
	WeaponModel = EntRefToEntIndex(i_Viewmodel_WeaponModel[client]);

	if(!IsValidEntity(WeaponModel)) //somehow doesnt exist, aboard!
		return;

	f_ParryDuration[client] = GetGameTime() + 0.7;
	ClientCommand(client, "playgamesound misc/halloween/strongman_fast_whoosh_01.wav");
	
	int ModelIndex = GetEntProp(WeaponModel, Prop_Send, "m_nModelIndex");
	char model[PLATFORM_MAX_PATH];
	ModelIndexToString(ModelIndex, model, PLATFORM_MAX_PATH);

	int Glow = TF2_CreateGlow_White(WeaponModel, model, client, f_WeaponSizeOverride[active]);
	SetVariantColor(view_as<int>({255, 255, 255, 200}));
	AcceptEntityInput(Glow, "SetGlowColor");
	//save for deletion when they switch away too fast
	Board_OutlineModel[client] = EntIndexToEntRef(Glow);
	SDKHook(Glow, SDKHook_SetTransmit, BarrackBody_Transmit);
	BarrackOwner[Glow] = client;

	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(active));
	pack.WriteCell(EntIndexToEntRef(WeaponModel));
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteCell(EntIndexToEntRef(Glow));
	RequestFrames(RemoveEffectsOffShield_Board, FramesActive, pack); // 60 is 1 sec?

	if (ParryCounter != 0)
	{
		ParryCounter = 0;
	}
//	SetEntPropFloat(WeaponModel, Prop_Send, "m_flModelScale", f_WeaponSizeOverride[active] * 1.25);
}

void RemoveEffectsOffShield_Board(DataPack pack)
{
	pack.Reset();
	int WeaponEntity = EntRefToEntIndex(pack.ReadCell());
	int WeaponViewEntity = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell());
	int GlowEntity = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client)) //does the player still exist, if no, aboard
	{
		delete pack;
		return;
	}
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	//does my weapon exist
	//does the model for it exist (different form normal tf2 cus zr)
	//is my current weapon different from what i used before
	if(IsValidEntity(WeaponViewEntity) && IsValidEntity(WeaponEntity) && weapon_holding == WeaponEntity)
	{
		SetEntPropFloat(WeaponViewEntity, Prop_Send, "m_flModelScale", f_WeaponSizeOverride[WeaponEntity]);
	}
	if(IsValidEntity(GlowEntity))
	{
		RemoveEntity(GlowEntity);
	}
	
	delete pack;
}

public void Weapon_BoardHolster(int client)
{
	int entity = EntRefToEntIndex(Board_OutlineModel[client]);
	if(entity != INVALID_ENT_REFERENCE)
		RemoveEntity(entity);	
}

void PlayParrySoundBoard(int client)
{
	switch(GetRandomInt(1,3))
	{
		case 1:
		{
			ClientCommand(client, "playgamesound weapons/demo_charge_hit_flesh1.wav");
		}
		case 2:
		{
			ClientCommand(client, "playgamesound weapons/demo_charge_hit_flesh2.wav");
		}
		case 3:
		{
			ClientCommand(client, "playgamesound weapons/demo_charge_hit_flesh3.wav");
		}
	}
}

float ShieldCutOffCooldown_Board(float CooldownCurrent, int weapon)
{
	float attackspeed = Attributes_Get(weapon, 6, 1.0);

	CooldownCurrent *= attackspeed;

	if(CooldownCurrent <= 0.7)
	{
		CooldownCurrent = 0.7; //cant get lower then 0.7
	}
	return CooldownCurrent;
}
float CalculateDamageBonus_Board(float damage, int weapon)
{
	float damageModif = damage;
	damageModif *= Attributes_Get(weapon, 1, 1.0);
	damageModif *= Attributes_Get(weapon, 2, 1.0);
	damageModif *= Attributes_Get(weapon, 476, 1.0);
	return damageModif;
}