#pragma semicolon 1
#pragma newdecls required
static Handle h_TimerRedBladeWeaponManagement[MAXPLAYERS+1] = {null, ...};

void ResetMapStartRedBladeWeapon()
{
	RedBlade_Map_Precache();
}

void RedBlade_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	PrecacheSound("ambient/cp_harbor/furnace_1_shot_02.wav");
	PrecacheSound("items/powerup_pickup_supernova_activate.wav");

}

public void Red_charge_ability(int client, int weapon, bool crit, int slot) // the main ability used to recover the unique mana needed to for the weapon to fire projectiles
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Handle swingTrace;
		b_LagCompNPC_No_Layers = true;
		float vecSwingForward[3];
		StartLagCompensation_Base_Boss(client);
		DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 1500.0, false, 45.0, true); //infinite range, and ignore walls!
		FinishLagCompensation_Base_boss();

		int target = TR_GetEntityIndex(swingTrace);	
		delete swingTrace;
		if(!IsValidEnemy(client, target, true))
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			return;
		}
		i_RedBladeNpcToCharge[client] = EntIndexToEntRef(target);

		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, 10.0);
		EmitSoundToAll("items/powerup_pickup_supernova_activate.wav", client, _, 80, _, 0.8, 100);

		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		float knockback = 300.0;
		// knockback is the overall force with which you be pushed, don't touch other stuff
		ScaleVector(velocity, knockback);
		if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			velocity[2] = fmax(velocity[2], 300.0);
		else
			velocity[2] += 100.0;    // a little boost to alleviate arcing issues

		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
		
	//	ApplyTempAttrib(weapon, 852, 0.5, 5.0);

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
public void Enable_RedBladeWeapon(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerRedBladeWeaponManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SKADI)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerRedBladeWeaponManagement[client];
			h_TimerRedBladeWeaponManagement[client] = null;
			DataPack pack;
			h_TimerRedBladeWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_RedBlade, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SKADI)
	{
		DataPack pack;
		h_TimerRedBladeWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_RedBlade, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_RedBlade(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		DestroyRedBladeEffect(client);
		h_TimerRedBladeWeaponManagement[client] = null;
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		RedBladeHudShow(client, weapon);
	}
	else
	{
		DestroyRedBladeEffect(client);
	}
		
	return Plugin_Continue;
}

void WeaponRedBlade_OnTakeDamageNpc(int attacker,int victim, int damagetype,int weapon, float &damage)
{
	if(HALFORNO[attacker] && b_thisNpcIsARaid[victim])
	{
		damage *= 0.75;
	}

	
	if(damagetype & DMG_CLUB)
		NPC_Ignite(victim, attacker, 3.0, weapon);
}

void CreateRedBladeEffect(int client)
{
	
	DestroyRedBladeEffect(client);
	
	float flPos[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);

	
	int particle = ParticleEffectAt(flPos, "utaunt_tarotcard_red_glow", 0.0);
	AddEntityToThirdPersonTransitMode(client, particle);
	SetParent(client, particle);
}

void DestroyRedBladeEffect(int client)
{

}
