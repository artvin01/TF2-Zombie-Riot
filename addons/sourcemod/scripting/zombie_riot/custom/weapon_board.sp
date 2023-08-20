#pragma semicolon 1
#pragma newdecls required
//no idea how those work but they are needed from what i see
static int weapon_id[MAXPLAYERS+1]={0, ...};
static int Board_Hits[MAXPLAYERS+1]={0, ...};
static int Board_Level[MAXPLAYERS+1]={0, ...};
static float f_AniSoundSpam[MAXPLAYERS+1]={0.0, ...};
static bool swag =  true; //please forgive me for I have sinned

Handle h_TimerWeaponBoardManagement[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
static float f_WeaponBoardhuddelay[MAXPLAYERS+1]={0.0, ...};

/*void PunishmentEffect(int entity, int victim, float damage, int weapon)
{
	float Range = 150.0;
	float Pos[3];
	GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", Pos);
	I wanted to implement an effect similar to Riot Shield here for when you parry with the Punishment shield, but couldn't get it to work properly and crashing is annoying
}*/

public void Punish(int victim, int weapon, int bool) //AOE parry damage that scales with melee upgrades, im a coding maestro SUPREME
{
	float damage = 2500.0;
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

	EmitSoundToAll("weapons/air_burster_explode1.wav");
}

public void SwagMeter(int victim, int weapon) //so that parrying 2 enemies at once doesnt grant more effects
{
	if (swag == true)
	{
		if (Board_Level[victim] == 2)
		{
			StartHealingTimer(victim, 0.1, float(SDKCall_GetMaxHealth(victim)) * 0.01, 5);
			swag = false;
		}
		else if (Board_Level[victim] == 5)
		{
			ApplyTempAttrib(victim, 26, 1.2, 5.35);
			StartHealingTimer(victim, 0.1, float(SDKCall_GetMaxHealth(victim)) * 0.01, 5);
			swag = false;
		}
		else if(Board_Level[victim] == 4)
		{
			Punish(victim, weapon, true);
			swag = false;
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
		Ability_Apply_Cooldown(client, slot, 5.0);
		ClientCommand(client, "playgamesound weapons/samurai/tf_katana_draw_02.wav");

		Board_Level[client] = 0;
		
		weapon_id[client] = weapon;

		float flPos[3]; // original
		float flAng[3]; // original	
		GetAttachment(client, "effect_hand_r", flPos, flAng);
				
		int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 0.2);
				
		SetParent(client, particler, "effect_hand_r");

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
		Ability_Apply_Cooldown(client, slot, 5.0);
		ClientCommand(client, "playgamesound weapons/samurai/tf_katana_draw_02.wav");

		Board_Level[client] = 1;
		
		weapon_id[client] = weapon;

		float flPos[3]; // original
		float flAng[3]; // original	
		GetAttachment(client, "effect_hand_r", flPos, flAng);
				
		int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 0.2);
				
		SetParent(client, particler, "effect_hand_r");

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
		Ability_Apply_Cooldown(client, slot, 5.0); // PARRY COOLDOWN!!!!!!
		ClientCommand(client, "playgamesound weapons/samurai/tf_katana_draw_02.wav");

		Board_Level[client] = 2;
		
		swag = true;

		weapon_id[client] = weapon;
		
		float flPos[3]; // original
		float flAng[3]; // original
		
		GetAttachment(client, "effect_hand_r", flPos, flAng);
				
		int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 0.2);
				
		SetParent(client, particler, "effect_hand_r");

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
		Ability_Apply_Cooldown(client, slot, 3.0);
		ClientCommand(client, "playgamesound weapons/samurai/tf_katana_draw_02.wav");

		Board_Level[client] = 3;
		
		weapon_id[client] = weapon;

		float flPos[3]; // original
		float flAng[3]; // original
		GetAttachment(client, "effect_hand_r", flPos, flAng);
			
		int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 0.2);
				
		SetParent(client, particler, "effect_hand_r");
				

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
		Ability_Apply_Cooldown(client, slot, 5.0);
		ClientCommand(client, "playgamesound weapons/samurai/tf_katana_draw_02.wav");

		Board_Level[client] = 4;
		
		swag = true;

		weapon_id[client] = weapon;

		float flPos[3]; // original
		float flAng[3]; // original	
		GetAttachment(client, "effect_hand_r", flPos, flAng);
				
		int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 0.2);
				
		SetParent(client, particler, "effect_hand_r");

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
		Ability_Apply_Cooldown(client, slot, 5.0);
		ClientCommand(client, "playgamesound weapons/samurai/tf_katana_draw_02.wav");

		Board_Level[client] = 5;
		
		swag = true;

		weapon_id[client] = weapon;

		float flPos[3]; // original
		float flAng[3]; // original	
		GetAttachment(client, "effect_hand_r", flPos, flAng);
				
		int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 0.2);
				
		SetParent(client, particler, "effect_hand_r");

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
		Ability_Apply_Cooldown(client, slot, 3.0);
		ClientCommand(client, "playgamesound weapons/samurai/tf_katana_draw_02.wav");

		Board_Level[client] = 6;
		
		weapon_id[client] = weapon;

		float flPos[3]; // original
		float flAng[3]; // original	
		GetAttachment(client, "effect_hand_r", flPos, flAng);
				
		int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 0.2);
				
		SetParent(client, particler, "effect_hand_r");

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
	if (Ability_Check_Cooldown(victim, 2) >= 4.65 && Ability_Check_Cooldown(victim, 2) < 5.0)
	{
		float damage_reflected = damage;
		//PrintToChatAll("parry worked");
		if(Board_Level[victim] == 1)
		{
			damage_reflected = 3250.0; //1.0 = 50
			Board_Hits[victim] += 1;
			//PrintToChatAll("Spike parry");
		}
		else if(Board_Level[victim] == 2)
		{
			damage_reflected = 1500.0;
			Board_Hits[victim] += 1;
			SwagMeter(victim, weapon);
			//PrintToChatAll("Leaf parry");
		}
		else if(Board_Level[victim] == 4)
		{
			damage_reflected = 2500.0;
			Board_Hits[victim] += 1;
			SwagMeter(victim, weapon);
			//PrintToChatAll("Punishment parry");
		}
		else if(Board_Level[victim] == 5)
		{
			damage_reflected = 6000.0;
			Board_Hits[victim] += 1;
			SwagMeter(victim, weapon);
			//PrintToChatAll("Rampart parry");
		}
		else if(Board_Level[victim] == 0)
		{
			damage_reflected = 650.0;
			Board_Hits[victim] += 1;
			//PrintToChatAll("Board parry");
		}
		
		if(f_AniSoundSpam[victim] < GetGameTime())
		{
			f_AniSoundSpam[victim] = GetGameTime() + 0.2;
			ClientCommand(victim, "playgamesound weapons/samurai/tf_katana_impact_object_02.wav");
		}
		
		static float angles[3];
		GetEntPropVector(victim, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		Entity_Position = WorldSpaceCenter(attacker);
		
		float flPos[3]; // original
		float flAng[3]; // original
		
		GetAttachment(victim, "effect_hand_r", flPos, flAng);
		
		int particler = ParticleEffectAt(flPos, "raygun_projectile_red_crit", 0.15);

		DataPack pack = new DataPack();
		pack.WriteCell(EntIndexToEntRef(particler));
		pack.WriteFloat(Entity_Position[0]);
		pack.WriteFloat(Entity_Position[1]);
		pack.WriteFloat(Entity_Position[2]);
		
		RequestFrame(TeleportParticleBoard, pack);
	
		
		SDKHooks_TakeDamage(attacker, victim, victim, damage_reflected, DMG_CLUB, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position);
		
		return damage * 0.05;
	}
	else if ((Ability_Check_Cooldown(victim, 2) >= 2.65 && Ability_Check_Cooldown(victim, 2) < 3.0) && (Board_Level[victim] == 3 || Board_Level[victim] == 6))
	{
		float damage_reflected = damage;
		//PrintToChatAll("parry worked");
		if(Board_Level[victim] == 3)
		{
			damage_reflected = 1050.0;
			Board_Hits[victim] += 1;
			//PrintToChatAll("Rookie parry");
		}
		else if(Board_Level[victim] == 6)
		{
			damage_reflected = 2692.6;
			Board_Hits[victim] += 1;
			//PrintToChatAll("Cudgel parry");
			float time = GetGameTime() + 3.5;
			if(f_CudgelDebuff[attacker] < time)
				f_CudgelDebuff[attacker] = time;
		}

		if(f_AniSoundSpam[victim] < GetGameTime())
		{
			f_AniSoundSpam[victim] = GetGameTime() + 0.2;
			ClientCommand(victim, "playgamesound weapons/samurai/tf_katana_impact_object_02.wav");
		}
		
		static float angles[3];
		GetEntPropVector(victim, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		Entity_Position = WorldSpaceCenter(attacker);
		
		float flPos[3]; // original
		float flAng[3]; // original
		
		GetAttachment(victim, "effect_hand_r", flPos, flAng);
		
		int particler = ParticleEffectAt(flPos, "raygun_projectile_red_crit", 0.15);
		
		DataPack pack = new DataPack();
		pack.WriteCell(EntIndexToEntRef(particler));
		pack.WriteFloat(Entity_Position[0]);
		pack.WriteFloat(Entity_Position[1]);
		pack.WriteFloat(Entity_Position[2]);
		
		RequestFrame(TeleportParticleBoard, pack);
	
		
		SDKHooks_TakeDamage(attacker, victim, victim, damage_reflected, DMG_CLUB, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position);
		
		return damage * 0.05;
	} 
	else if(Board_Level[victim] == 0) //board
	{
		//PrintToChatAll("damage resist");
		return damage * 0.85;
	}
	else if(Board_Level[victim] == 1) //spike
	{
		//PrintToChatAll("damage resist");
		return damage * 0.9;
	}
	else if(Board_Level[victim] == 2) //leaf
	{
		//PrintToChatAll("damage resist");
		return damage * 0.7;
	}
	else if(Board_Level[victim] == 3) //rookie
	{
		//PrintToChatAll("damage resist");
		return damage * 0.8;
	}
	else if(Board_Level[victim] == 4) //punish
	{
		//PrintToChatAll("damage resist");
		return damage * 0.7;
	}
	else if(Board_Level[victim] == 5) //ramp
	{
		//PrintToChatAll("damage resist");
		return damage * 0.5;
	}
	else if(Board_Level[victim] == 6) //the last one cudgel
	{
		//PrintToChatAll("damage resist");
		return damage * 0.6;
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

void TeleportParticleBoard(DataPack pack)
{
	pack.Reset();
	int particleEntity = EntRefToEntIndex(pack.ReadCell());
	float Vec_Pos[3];
	Vec_Pos[0] = pack.ReadFloat();
	Vec_Pos[1] = pack.ReadFloat();
	Vec_Pos[2] = pack.ReadFloat();
	
	if(IsValidEntity(particleEntity))
	{
		TeleportEntity(particleEntity, Vec_Pos);
	}
	delete pack;
}