#pragma semicolon 1
#pragma newdecls required

#define SOUND_WAND_SHOT_DIM	"misc/doomsday_lift_stop.wav"
#define SOUND_DIM_IMPACT "weapons/cow_mangler_explosion_normal_01.wav"
#define SOUND_ABILITY "misc/rd_points_return01.wav"
#define MAX_DIMENSION_CHARGE 30
static Handle h_TimerDimensionWeaponManagement[MAXPLAYERS+1]={null, ...};
static int how_many_times_swinged[MAXTF2PLAYERS];
static float f_DIMAbilityActive[MAXPLAYERS+1]={0.0, ...};
static float f_DIMhuddelay[MAXPLAYERS+1]={0.0, ...};


void ResetMapStartDimWeapon()
{
	Zero(f_DIMhuddelay);
	Wand_Dimension_Map_Precache();
}
void Wand_Dimension_Map_Precache()
{
	PrecacheSound(SOUND_WAND_SHOT_DIM);
	PrecacheSound(SOUND_DIM_IMPACT);
	PrecacheSound(SOUND_ABILITY);
}

public void Enable_Dimension_Wand(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerDimensionWeaponManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_DIMENSION_RIPPER)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerDimensionWeaponManagement[client];
			h_TimerDimensionWeaponManagement[client] = null;
			DataPack pack;
			h_TimerDimensionWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_Dimension, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_DIMENSION_RIPPER)
	{
		DataPack pack;
		h_TimerDimensionWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_Dimension, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_Dimension(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerDimensionWeaponManagement[client] = null;
		return Plugin_Stop;
	}
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{	
		Dimension_Cooldown_Logic(client, weapon);
	}	
	return Plugin_Continue;
}

public void Dimension_Cooldown_Logic(int client, int weapon)
{
	if(f_DIMhuddelay[client] < GetGameTime())
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
		{
			if(f_DIMAbilityActive[client] < GetGameTime())
			{
				if(how_many_times_swinged[client] < MAX_DIMENSION_CHARGE)
				{
					PrintHintText(client,"Dimension power [%i%/%i]", how_many_times_swinged[client], MAX_DIMENSION_CHARGE);
				}
				else
				{
					PrintHintText(client,"Summon Ready");
				}
			}
			else
			{
				PrintHintText(client,"Hi ;D");
			}
			
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			f_DIMhuddelay[client] = GetGameTime() + 0.5;
		}
	}
}

public void Weapon_Dimension_Wand(int client, int weapon, bool crit)
{
	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(mana_cost <= Current_Mana[client])
	{
		float damage = 65.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
		
		Mana_Regen_Delay[client] = GetGameTime() + 1.0;
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
			
		float speed = 1200.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		
		speed *= Attributes_Get(weapon, 104, 1.0);
		
		speed *= Attributes_Get(weapon, 475, 1.0);
		
		float time = 500.0 / speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		
		time *= Attributes_Get(weapon, 102, 1.0);
		

		EmitSoundToAll(SOUND_WAND_SHOT_DIM, client, SNDCHAN_WEAPON, 65, _, 0.4, 100);
		//This spawns the projectile, this is a return int, if you want, you can do extra stuff with it, otherwise, it can be used as a void.
		switch(GetRandomInt(1, 4))
		{
			case 1:
			{
				Wand_Projectile_Spawn(client, speed, time, damage, 3/*Default wand*/, weapon, "raygun_projectile_blue_trail");
			}
			case 2:
			{
				Wand_Projectile_Spawn(client, speed, time, damage, 3/*Default wand*/, weapon, "raygun_projectile_blue_crit_trail");
			}
			case 3:
			{
				Wand_Projectile_Spawn(client, speed, time, damage, 3/*Default wand*/, weapon, "raygun_projectile_red_trail");
			}
			case 4:
			{
				Wand_Projectile_Spawn(client, speed, time, damage, 3/*Default wand*/, weapon, "raygun_projectile_red_crit_trail");
			}
			default: //This should not happen
			{
				ShowSyncHudText(client,  SyncHud_Notifaction, "An error occured. Scream at devs");//none
			}
		}

	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

public void Wand_DimensionTouch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position, false);	// 2048 is DMG_NOGIB?
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		EmitSoundToAll(SOUND_DIM_IMPACT, entity, SNDCHAN_STATIC, 80, _, 1.0);
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		EmitSoundToAll(SOUND_DIM_IMPACT, entity, SNDCHAN_STATIC, 80, _, 1.0);
		RemoveEntity(entity);
	}
}

public Action Dimension_KillNPC(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity) && !b_NpcHasDied[entity])
	{
		SmiteNpcToDeath(entity);
	}
	
	return Plugin_Stop;
}



void Npc_OnTakeDamage_DimensionalRipper(int attacker)
{
	/*
		++ add charge code xd
	*/
	if(how_many_times_swinged[attacker] <= MAX_DIMENSION_CHARGE)
	{
		how_many_times_swinged[attacker] += 1;
	}
	//if(b_thisNpcIsARaid[victim])
	//{
	//	how_many_times_swinged[attacker] += 1;
	//}
	if(how_many_times_swinged[attacker] >= MAX_DIMENSION_CHARGE)
	{
		how_many_times_swinged[attacker] = MAX_DIMENSION_CHARGE;
	}
}

 
public void Weapon_Dimension_Summon_Normal(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 7))
	{
		case 1:
			Dimension_Summon_Npc(client, "npc_headcrabzombie_fortified",weapon, 1.4, 1.4, "ghost_appearation");
		case 2:
			Dimension_Summon_Npc(client, "npc_xeno_zombie_scout_grave" ,weapon, 1.3, 0.8, "ghost_appearation");
		case 3:
			Dimension_Summon_Npc(client, "npc_medival_man_at_arms" ,weapon, 1.4, 1.3, "ghost_appearation");
		case 4:
			Dimension_Summon_Npc(client, "npc_seaslider" ,weapon, 1.4, 1.3, "ghost_appearation");
		case 5:
			Dimension_Summon_Npc(client, "npc_ahim" ,weapon, 1.3, 1.2, "ghost_appearation");
		case 6:
			Dimension_Summon_Npc(client, "npc_pental" ,weapon, 1.3, 1.3, "ghost_appearation");
		case 7:
			Dimension_Summon_Npc(client, "npc_alt_combine_soldier_mage" ,weapon, 1.2, 1.3, "ghost_appearation");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

public void Weapon_Dimension_Summon_Normal_PAP(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 9))
	{
		case 1:
			Dimension_Summon_Npc(client, "npc_kamikaze_demo" ,weapon, 1.0, 2.5, "ghost_appearation");
		case 2:
			Dimension_Summon_Npc(client, "npc_xeno_kamikaze_demo" ,weapon, 1.0, 2.5, "ghost_appearation");
		case 3:
			Dimension_Summon_Npc(client, "npc_seaborn_demo" ,weapon, 1.0, 2.5, "ghost_appearation");	
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

public void Weapon_Dimension_Summon_Normal_PAP_PAP(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 14))
	{
		case 1:
			Dimension_Summon_Npc(client, "npc_panzer" ,weapon, 1.5, 1.0, "ghost_appearation");
		case 3:
			Dimension_Summon_Npc(client, "npc_doctor" ,weapon, 0.6, 1.3, "ghost_appearation");	
		case 4:
			Dimension_Summon_Npc(client, "npc_phantom_knight" ,weapon, 1.1, 1.2, "ghost_appearation");
		case 5:
			Dimension_Summon_Npc(client, "npc_true_fusion_warrior" ,weapon, 0.8, 0.8, "ghost_appearation");	
		case 6:
			Dimension_Summon_Npc(client, "npc_citizen_runner" ,weapon, 3.0, 1.1, "ghost_appearation");
		case 7:
			Dimension_Summon_Npc(client, "npc_medival_villager" ,weapon, 1.2, 1.2, "ghost_appearation");	
		case 8:
			Dimension_Summon_Npc(client, "npc_sensal" ,weapon, 0.6, 0.6, "ghost_appearation");
		case 9:
			Dimension_Summon_Npc(client, "npc_overlord_rogue" ,weapon, 1.0, 1.0, "ghost_appearation");
		case 10:
			Dimension_Summon_Npc(client, "npc_majorsteam" ,weapon, 1.0, 1.2, "ghost_appearation");
		case 11:
			Dimension_Summon_Npc(client, "npc_the_purge" ,weapon, 0.9, 1.0, "ghost_appearation");	
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

public void Weapon_Dimension_Summon_Blitz(int client, int weapon, bool &result, int slot, int pap_logic)
{
	
	switch(GetRandomInt(1, 8))
	{
		case 1:
			Dimension_Summon_Npc(client, "npc_alt_combine_soldier_mage" ,weapon, 1.1, 1.15, "eyeboss_tp_player");
		case 2:
			Dimension_Summon_Npc(client, "npc_alt_medic_charger" ,weapon, 1.3, 1.2, "eyeboss_tp_player");
		case 3:
			Dimension_Summon_Npc(client, "npc_alt_mecha_soldier_barrager" ,weapon, 1.1, 1.3, "eyeboss_tp_player");
		case 4:
			Dimension_Summon_Npc(client, "npc_alt_sniper_railgunner" ,weapon, 1.1, 1.5, "eyeboss_tp_player");
		case 5:
			Dimension_Summon_Npc(client, "npc_alt_mecha_engineer" ,weapon, 1.1, 1.2, "eyeboss_tp_player");
		case 6:
			Dimension_Summon_Npc(client, "npc_alt_mecha_heavy" ,weapon, 1.4, 1.2, "eyeboss_tp_player");
		case 7:
			Dimension_Summon_Npc(client, "npc_alt_mecha_scout" ,weapon, 1.0, 1.1, "eyeboss_tp_player");
		case 8:
			Dimension_Summon_Npc(client, "npc_alt_medic_supperior_mage" ,weapon, 1.4, 1.2, "eyeboss_tp_player");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

public void Weapon_Dimension_Summon_Blitz_PAP(int client, int weapon, bool &result, int slot, int pap_logic)
{
	
	switch(GetRandomInt(1, 9))
	{
		case 1:
			Dimension_Summon_Npc(client, "npc_alt_medic_berserker" ,weapon, 1.4, 1.2, "eyeboss_tp_player");
		case 2:
			Dimension_Summon_Npc(client, "npc_alt_kahml" ,weapon, 1.0, 0.8, "eyeboss_tp_player");
		case 3:
			Dimension_Summon_Npc(client, "npc_alt_combine_soldier_deutsch_ritter" ,weapon, 1.4, 1.3, "eyeboss_tp_player");
		case 4:
			Dimension_Summon_Npc(client, "npc_alt_mecha_pyro_giant_main" ,weapon, 1.4, 1.2, "eyeboss_tp_player");
		case 5:
			Dimension_Summon_Npc(client, "npc_alt_the_shit_slapper" ,weapon, 1.3, 1.1, "eyeboss_tp_player");
		case 6:
			Dimension_Summon_Npc(client, "npc_alt_ikunagae" ,weapon, 1.8, 1.7, "eyeboss_tp_player");
		case 7:
			Dimension_Summon_Npc(client, "npc_alt_soldier_barrager" ,weapon, 1.0, 1.3, "eyeboss_tp_player");
		case 8:
			Dimension_Summon_Npc(client, "npc_alt_schwertkrieg" ,weapon, 1.5, 1.3, "eyeboss_tp_player");
		case 9:
			Dimension_Summon_Npc(client, "npc_alt_mecha_heavy_giant" ,weapon, 1.5, 1.2, "eyeboss_tp_player");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

public void Weapon_Dimension_Summon_Xeno(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 6))
	{
		case 1:
			Dimension_Summon_Npc(client, "npc_medic_main" ,weapon, 1.1, 1.0, "utaunt_smoke_floor1_green");
		case 2:
			Dimension_Summon_Npc(client, "npc_alt_medic_constructor" ,weapon, 1.0, 1.1, "utaunt_smoke_floor1_green");
		case 3:
			Dimension_Summon_Npc(client, "npc_defanda" ,weapon, 1.5, 1.2, "utaunt_smoke_floor1_green");
		case 4:
			Dimension_Summon_Npc(client, "npc_protecta" ,weapon, 1.3, 1.2, "utaunt_smoke_floor1_green");
		case 5:
			Dimension_Summon_Npc(client, "npc_yadeam" ,weapon, 1.75, 1.4, "utaunt_smoke_floor1_green");
		case 6:
			Dimension_Summon_Npc(client, "npc_rajul" ,weapon, 1.1, 1.2, "utaunt_smoke_floor1_green");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

public void Weapon_Dimension_Summon_Xeno_PAP(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 9))
	{
		case 1:
			Dimension_Summon_Npc(client, "npc_seaborn_medic" ,weapon, 1.2, 1.3, "utaunt_smoke_floor1_green");
		case 2:
			Dimension_Summon_Npc(client, "npc_isharmla" ,weapon, 1.0, 1.2, "utaunt_smoke_floor1_green");
		case 3:
			Dimension_Summon_Npc(client, "npc_guardus" ,weapon, 1.5, 1.25, "utaunt_smoke_floor1_green");
		case 4:
			Dimension_Summon_Npc(client, "npc_helena" ,weapon, 0.5, 2.0, "utaunt_smoke_floor1_green");
		case 5:
			Dimension_Summon_Npc(client, "npc_xeno_medic_healer" ,weapon, 0.5, 1.2, "utaunt_smoke_floor1_green");
		case 6:
			Dimension_Summon_Npc(client, "npc_xeno_medic_healer" ,weapon, 0.5, 1.2, "utaunt_smoke_floor1_green");
		case 7:
			Dimension_Summon_Npc(client, "npc_arctic_mage" ,weapon, 1.5, 1.1, "utaunt_smoke_floor1_green");
		case 8:
			Dimension_Summon_Npc(client, "npc_skin_hunter" ,weapon, 1.2, 1.6, "utaunt_smoke_floor1_green");
		case 9:
			Dimension_Summon_Npc(client, "npc_mad_doctor" ,weapon, 1.3, 1.2, "utaunt_smoke_floor1_green");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}
public void Weapon_Dimension_Summon_Medeival(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 12))
	{
		case 1:
			Dimension_Summon_Npc(client, "npc_speedus_adivus" ,weapon, 1.0, 1.0, "npc_boss_bomb_alert");
		case 2:
			Dimension_Summon_Npc(client, "npc_hitman" ,weapon, 0.8, 0.6, "npc_boss_bomb_alert");
		case 3:
			Dimension_Summon_Npc(client, "npc_inabdil" ,weapon, 1.2, 1.2, "npc_boss_bomb_alert");
		case 4:
			Dimension_Summon_Npc(client, "npc_medival_hussar" ,weapon, 1.4, 1.2, "npc_boss_bomb_alert");
		case 5:
			Dimension_Summon_Npc(client, "npc_medival_knight" ,weapon, 1.3, 1.1, "npc_boss_bomb_alert");
		case 6:
			Dimension_Summon_Npc(client, "npc_medival_brawler" ,weapon, 1.2, 1.2, "npc_boss_bomb_alert");
		case 7:
			Dimension_Summon_Npc(client, "npc_medival_paladin" ,weapon, 1.4, 1.2, "npc_boss_bomb_alert");
		case 8:
			Dimension_Summon_Npc(client, "npc_medival_eagle_warrior" ,weapon, 1.2, 1.1, "npc_boss_bomb_alert");
		case 9:
			Dimension_Summon_Npc(client, "npc_medival_cavalary" ,weapon, 1.3, 1.2, "npc_boss_bomb_alert");
		case 10:
			Dimension_Summon_Npc(client, "npc_medival_eagle_giant" ,weapon, 1.5, 1.3, "npc_boss_bomb_alert");
		case 11:
			Dimension_Summon_Npc(client, "npc_runover" ,weapon, 1.2, 1.2, "npc_boss_bomb_alert");
		case 12:
			Dimension_Summon_Npc(client, "npc_medival_achilles" ,weapon, 1.75, 1.2, "npc_boss_bomb_alert");
		
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

public void Weapon_Dimension_Summon_Medeival_PAP(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 2))
	{
		case 1:
			Dimension_Summon_Npc(client, "npc_medival_ram" ,weapon, 1.0, 0.2, "npc_boss_bomb_alert");
			Dimension_Summon_Npc(client, "npc_seaborn_vanguard" ,weapon, 0.5, 1.1, "utaunt_constellations_blue_base");
			Dimension_Summon_Npc(client, "npc_seaborn_vanguard" ,weapon, 0.5, 1.1, "utaunt_constellations_blue_base");
		case 2:
			Dimension_Summon_Npc(client, "npc_medival_ram" ,weapon, 0.2, 0.75, "npc_boss_bomb_alert");
			Dimension_Summon_Npc(client, "npc_seaborn_vanguard" ,weapon, 0.5, 1.1, "utaunt_constellations_blue_base");
			Dimension_Summon_Npc(client, "npc_seaborn_vanguard" ,weapon, 0.5, 1.1, "utaunt_constellations_blue_base");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}
public void Weapon_Dimension_Summon_Seaborn(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 5))
	{
		case 1:
			Dimension_Summon_Npc(client, "npc_seaslider" ,weapon, 1.2, 1.0, "utaunt_constellations_blue_base");
		case 2:
			Dimension_Summon_Npc(client, "npc_netherseapredator" ,weapon, 1.0, 1.2, "utaunt_constellations_blue_base");
		case 3:
			Dimension_Summon_Npc(client, "npc_netherseaspewer" ,weapon, 1.2, 1.3, "utaunt_constellations_blue_base");
		case 4:
			Dimension_Summon_Npc(client, "npc_netherseareefbreaker" ,weapon, 1.4, 1.2, "utaunt_constellations_blue_base");
		case 5:
			Dimension_Summon_Npc(client, "npc_firsttotalk" ,weapon, 1.75, 1.2, "utaunt_constellations_blue_base");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}
public void Weapon_Dimension_Summon_Seaborn_PAP(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 2))
	{
		case 1:
			Dimension_Summon_Npc(client, "npc_seaborn_vanguard" ,weapon, 1.0, 0.9, "utaunt_constellations_blue_base");
			Dimension_Summon_Npc(client, "npc_seaborn_kazimersch_beserker" ,weapon, 1.6, 1.2, "utaunt_constellations_blue_base");
			Dimension_Summon_Npc(client, "npc_seaborn_guard" ,weapon, 1.0, 1.0, "utaunt_constellations_blue_base");
			Dimension_Summon_Npc(client, "npc_seaborn_caster" ,weapon, 0.7, 1.1, "utaunt_constellations_blue_base");
		case 2:
			Dimension_Summon_Npc(client, "npc_lastknight" ,weapon, 1.5, 1.0, "utaunt_constellations_blue_base");
			Dimension_Summon_Npc(client, "npc_saintcarmen" ,weapon, 1.0, 1.0, "utaunt_constellations_blue_base");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}
public void Weapon_Dimension_Summon_Expidonsa(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 5))
	{
		case 1:
			Dimension_Summon_Npc(client, "npc_pental" ,weapon, 1.3, 1.3, "eyeboss_death_vortex");
		case 2:
			Dimension_Summon_Npc(client, "npc_dualrea" ,weapon, 1.2, 1.3, "eyeboss_death_vortex");
		case 3:
			Dimension_Summon_Npc(client, "npc_erasus" ,weapon, 1.2, 1.2, "eyeboss_death_vortex");
		case 4:
			Dimension_Summon_Npc(client, "npc_siccerino" ,weapon, 1.3, 1.3, "eyeboss_death_vortex");
		case 5:
			Dimension_Summon_Npc(client, "npc_seargent_ideal" ,weapon, 2.0, 1.3, "eyeboss_death_vortex");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

public void Weapon_Dimension_Summon_Expidonsa_PAP(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 6))
	{
		case 1:
			Dimension_Summon_Npc(client, "npc_gianttankus" ,weapon, 1.4, 1.2, "eyeboss_death_vortex");
		case 2:
			Dimension_Summon_Npc(client, "npc_guardus" ,weapon, 1.6, 1.2, "eyeboss_death_vortex");
		case 3:
			Dimension_Summon_Npc(client, "npc_ignitus" ,weapon, 1.6, 1.2, "eyeboss_death_vortex");
		case 4:
			Dimension_Summon_Npc(client, "npc_soldine" ,weapon, 2.0, 1.5, "eyeboss_death_vortex");
		case 5:
			Dimension_Summon_Npc(client, "npc_captino_agentus" ,weapon, 1.4, 1.4, "eyeboss_death_vortex");
		case 6:
			Dimension_Summon_Npc(client, "npc_benera" ,weapon, 4.0, 4.0, "eyeboss_death_vortex");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

public void Weapon_Dimension_Summon_Interitus(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 7))
	{
		case 1:
			Dimension_Summon_Npc(client, "npc_medival_archer" ,weapon, 1.1, 1.25, "teleporter_blue_exit");
		case 2:
			Dimension_Summon_Npc(client, "npc_medival_crossbow" ,weapon, 1.0, 1.4, "teleporter_blue_exit");
		case 3:
			Dimension_Summon_Npc(client, "npc_medival_longbowmen" ,weapon, 1.2, 1.5, "teleporter_blue_exit");
		case 4:
			Dimension_Summon_Npc(client, "npc_medival_arbalest" ,weapon, 1.2, 1.3, "teleporter_blue_exit");
		case 5:
			Dimension_Summon_Npc(client, "npc_alt_sniper_railgunner" ,weapon, 1.2, 1.3, "teleporter_blue_exit");
		case 6:
			Dimension_Summon_Npc(client, "npc_qanaas" ,weapon, 1.2, 1.3, "teleporter_blue_exit");
		case 7:
			Dimension_Summon_Npc(client, "npc_winter_sniper" ,weapon, 1.3, 1.2, "teleporter_blue_exit");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

public void Weapon_Dimension_Summon_Interitus_PAP(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1,7))
	{
		case 1:
			Dimension_Summon_Npc(client, "npc_medival_elite_longbowmen" ,weapon, 0.75, 1.4, "teleporter_blue_exit");
		case 2:
			Dimension_Summon_Npc(client, "npc_medival_crossbow_giant" ,weapon, 0.8, 1.4, "teleporter_blue_exit");
		case 3:
			Dimension_Summon_Npc(client, "npc_enforcer" , weapon, 0.8, 1.5, "teleporter_blue_exit");
		case 4:
			Dimension_Summon_Npc(client, "npc_archosauria" ,weapon, 0.8, 1.6, "teleporter_blue_exit");
		case 5:
			Dimension_Summon_Npc(client, "npc_infected_goggles" ,weapon, 0.5, 1.1, "teleporter_blue_exit");
		case 6:
			Dimension_Summon_Npc(client, "npc_medival_handcannoneer" ,weapon, 0.5, 2.0, "teleporter_blue_exit");
		case 7:
			Dimension_Summon_Npc(client, "npc_ripper_goggles" ,weapon, 1.0, 1.0, "teleporter_blue_exit");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

void Dimension_Summon_Npc(int client, char[] NpcName, int weapon, float HealthMulti, float DamageMulti, char[] ParticleEffect)
{
	
	if(weapon >= MaxClients)
	{
		if (how_many_times_swinged[client] >= MAX_DIMENSION_CHARGE)
		{
			int mana_cost = 150;
			if(mana_cost <= Current_Mana[client])
			{
				how_many_times_swinged[client] = 0;
				Rogue_OnAbilityUse(weapon);
				Current_Mana[client] -= mana_cost;
				float pos1[3], ang[3];
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos1);
				GetEntPropVector(client, Prop_Data, "m_angRotation", ang);
				float Dimension_Loc[3];
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", Dimension_Loc);
				if(ParticleEffect[0])
					ParticleEffectAt(Dimension_Loc, ParticleEffect, 1.5);
				EmitSoundToAll(SOUND_ABILITY, client, SNDCHAN_STATIC, 70, _, 1.2);
				
				int entity = NPC_CreateByName(NpcName, client, pos1, ang, TFTeam_Red);
				if(entity > MaxClients)
				{
					//30 as a starting value.
					//fl_MeleeArmor[entity] = 1.0;
					//fl_RangedArmor[entity] = 1.0;
					//Reset resistances.
					
					float f_MaxHealth = 30.0;
					f_MaxHealth *= Attributes_Get(weapon, 410, 1.0);
					f_MaxHealth *= HealthMulti;
					SetEntProp(entity, Prop_Data, "m_iHealth", RoundToNearest(f_MaxHealth));
					SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToNearest(f_MaxHealth));
					
					float ExtraDamage = Attributes_Get(weapon, 410, 1.0);
					ExtraDamage *= DamageMulti;
					ExtraDamage *= 1.25;
					fl_Extra_Damage[entity] *= ExtraDamage;
					fl_MeleeArmor[entity] = 1.0;
					fl_RangedArmor[entity] = 1.0;
					b_IsCamoNPC[entity] = false;

					CreateTimer(60.0, Dimension_KillNPC, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(3.0, Dimension_GiveStrength, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
					i_NpcOverrideAttacker[entity] = EntIndexToEntRef(client);
					b_thisNpcIsABoss[entity] = false;
					b_thisNpcIsARaid[entity] = false;
					b_ShowNpcHealthbar[entity] = true;
					if(EntRefToEntIndex(RaidBossActive) == entity)
						RaidBossActive = INVALID_ENT_REFERENCE;
				}
			}
			else
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Not enough Charges");
		}
	}
}

public Action Dimension_GiveStrength(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity) && !b_NpcHasDied[entity])
	{	
		fl_Extra_Damage[entity] *= 1.25;
		if(RaidbossIgnoreBuildingsLogic(1))
		{
			fl_Extra_Damage[entity] *= 1.2;
			fl_MeleeArmor[entity] = 0.9;
			fl_RangedArmor[entity] = 0.85;
		}	
	}

	
	return Plugin_Stop;
}