#pragma semicolon 1
#pragma newdecls required
static Handle h_TimerSkadiWeaponManagement[MAXPLAYERS+1] = {null, ...};
static bool b_AbilityActivated[MAXPLAYERS];
static float i_Swings[MAXPLAYERS+1]={0.0, ...};

void ResetMapStartSkadiWeapon()
{
	Skadi_Map_Precache();
	Zero(i_Swings);
}

void Skadi_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	PrecacheSound("ambient/cp_harbor/furnace_1_shot_05.wav");
}

public void Skadi_Ability_M2(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 50.0);
			EmitSoundToAll("ambient/cp_harbor/furnace_1_shot_05.wav", client, SNDCHAN_AUTO, 70, _, 1.0);
			//PrintToChatAll("Rapid Shot Activated");
			ApplyTempAttrib(weapon, 6, 1.1, 15.0);
			b_AbilityActivated[client] = true;
			CreateTimer(15.0, Timer_Bool_Skadi, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			float flPos[3]; // original
			float flAng[3]; // original
			GetAttachment(client, "m_vecAbsOrigin", flPos, flAng);
			int particle_Base = ParticleEffectAt(flPos, "utaunt_tarotcard_blue_glow", 15.0);
			SetParent(client, particle_Base, "m_vecAbsOrigin");
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
public void Enable_SkadiWeapon(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerSkadiWeaponManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SKADI)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerSkadiWeaponManagement[client];
			h_TimerSkadiWeaponManagement[client] = null;
			DataPack pack;
			h_TimerSkadiWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_Skadi, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
	else
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SKADI)
		{
			DataPack pack;
			h_TimerSkadiWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_Skadi, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		
	}	

	if(i_WeaponArchetype[weapon] == 22)	// Abyssal Hunter
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(h_TimerSkadiWeaponManagement[i])
			{
				ApplyStatusEffect(weapon, weapon, "Abyssal Skills", 9999999.0);
				Attributes_SetMulti(weapon, 2, 1.1);
			}
		}
	}
}

public Action Timer_Management_Skadi(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		b_AbilityActivated[client] = false;
		h_TimerSkadiWeaponManagement[client] = null;
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
	//	CreateSkadiEffect(client);
	}
	else
	{
		b_AbilityActivated[client] = false;
		Zero(i_Swings);
	}

	return Plugin_Continue;
}

void WeaponSkadi_OnTakeDamageNpc(int attacker,float &damage)
{
	if(b_AbilityActivated[attacker])
	{
		i_Swings[attacker] += 1.0;
		if(i_Swings[attacker] > 10.0)
			i_Swings[attacker] = 10.0;
		damage *= (1.0 + (i_Swings[attacker] * 0.1));
	}
}

void WeaponSkadi_OnTakeDamage(int attacker, int victim, float &damage, int damagetype)
{
	if(b_AbilityActivated[victim])
	{
		if(!(damagetype & DMG_TRUEDAMAGE))
			damage *= 0.80;

		if(b_thisNpcIsARaid[attacker])
		{
			damage *= 1.1;
		}
	}
}

public Action Timer_Bool_Skadi(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	b_AbilityActivated[client] = false;
	Zero(i_Swings);
	return Plugin_Stop;
}
