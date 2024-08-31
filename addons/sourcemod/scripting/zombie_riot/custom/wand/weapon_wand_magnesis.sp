#pragma semicolon 1
#pragma newdecls required

//As per usual, I'm using arrays for stats on different pap levels. First entry is pap1, then pap2, etc.

//STANDARD M1 PROJECTILE: The Magnesis Staff's primary fire is nothing special, just a generic projectile.
static float Magnesis_M1_Cost[3] = { 10.0, 10.0, 10.0 };            //M1 cost.
static float Magnesis_M1_DMG[3] = { 40.0, 60.0, 80.0 };             //M1 projectile damage.
static float Magnesis_M1_Lifespan[3] = { 0.2, 0.25, 0.3 };          //M1 projectile lifespan.
static float Magnesis_M1_Velocity[3] = { 1200.0, 1400.0, 1600.0 };  //M1 projectile velocity.

//M2 - GRAB: Clicking M2 on a living zombie allows the user to grab that zombie and hold it in front of them, provided 
//the target is within range. Holding a zombie drains mana, which becomes more expensive the longer the zombie is held.
//Held zombies are stunned. At any time, the user may press M2 again to throw the zombie (if they do not have the mana
//to afford the throw, the zombie is simply dropped). The velocity of this throw is based on the amount of damage
//that zombie took while grabbed, relative to their max health.
static float Magnesis_Grab_Requirement[3] = { 50.0, 100.0, 150.0 };		//Initial mana cost in order to grab an enemy.
static float Magnesis_Grab_Cost_Normal[3] = { 5.0, 5.0, 5.0 };			//Mana drained per 0.1s while holding a normal enemy.
static float Magnesis_Grab_Cost_Special[3] = { 35.0, 35.0, 35.0 };		//Mana drained per 0.1s while holding a boss/mini-boss.
static float Magnesis_Grab_Cost_Raid[3] = { 75.0, 75.0, 75.0 };			//Mana drained per 0.1s while holding a raid.
static float Magnesis_Grab_Range[3] = { 150.0, 200.0, 250.0 };			//Maximum distance from which enemies can be grabbed.
static float Magnesis_Grab_MaxVel[3] = { 400.0, 600.0, 800.0 };			//Maximum throw velocity.
static float Magnesis_Grab_ThrowThreshold[3] = { 0.75, 0.66, 0.5 };		//Percentage of max health taken as damage while grabbed in order for the throw to reach max velocity.
static float Magnesis_Grab_ThrowDMG[3] = { 1000.0, 1500.0, 2000.0 };	//Damage dealt to grabbed enemies when they are thrown.
static bool Magnesis_Grab_Specials[3] = { false, true, true };			//Can the Magnesis Staff grab bosses/mini-bosses on this tier?
static bool Magnesis_Grab_Raids[3] = { false, false, true };			//Can the Magnesis Staff grab raids on this tier?

//NEWTONIAN KNUCKLES: Alternate PaP path which replaces the M1 with a far stronger explosive projectile with a slower rate of fire.
//Replaces M2 with a shockwave that deals knockback. M1 projectile deals bonus damage if it airshots an enemy who is airborne because of the M2 attack.
static float Newtonian_M1_Cost[3] = { 50.0, 75.0, 100.0 };						//M1 cost.
static float Newtonian_M1_DMG[3] = { 400.0, 800.0, 1200.0 };					//M1 damage.
static float Newtonian_M1_Radius[3] = { 150.0, 165.0, 180.0 };					//M1 explosion radius.
static float Newtonian_M1_Velocity[3] = { 1400.0, 1800.0, 2200.0 };				//M1 projectile velocity.
static float Newtonian_M1_Lifespan[3] = { 1.0, 1.15, 1.3 };						//M1 projectile lifespan.
static float Newtonian_M1_Falloff_MultiHit[3] = { 0.66, 0.75, 0.85 };			//Amount to multiply damage dealt by M1 per target hit.
static float Newtonian_M1_Falloff_Distance[3] = { 0.66, 0.75, 0.85 };			//Maximum M1 damage falloff, based on distance.
static float Newtonian_M1_ComboMult[3] = { 2.0, 2.0, 2.0 };						//Amount to multiply damage dealt by the M1 to enemies who have been knocked airborne by the M2.
static int Newtonian_M1_MaxTargets[3] = { 4, 5, 6 };							//Max targets hit by the M1 projectile's explosion.
static float Newtonian_M2_Cost[3] = { 200.0, 300.0, 400.0 };					//M2 cost.
static float Newtonian_M2_DMG[3] = { 800.0, 1600.0, 2400.0 };					//M2 damage.
static float Newtonian_M2_Radius[3] = { 160.0, 180.0, 200.0 };					//M2 radius.
static float Newtonian_M2_Falloff_MultiHit[3] = { 0.5, 0.66, 0.75 };			//Amount to multiply damage dealt by the M2 shockwave per target hit.
static float Newtonian_M2_Falloff_Distance[3] = { 0.5, 0.66, 0.75 };			//Maximum M2 damage falloff, based on distance.
static float Newtonian_M2_Knockback_Horizontal[3] = { 200.0, 250.0, 300.0 };	//Horizontal knockback applied to enemies hit by the M2 shockwave.
static float Newtonian_M2_Knockback_Vertical[3] = { 400.0, 500.0, 600.0 };		//Vertical knockback applied to enemies hit by the M2 shockwave.

//Client/entity-specific global variables below, don't touch these:
static float ability_cooldown[MAXPLAYERS + 1] = {0.0, ...};

public void Magnesis_ResetAll()
{
	Zero(ability_cooldown);
}

#define SND_MAGNESIS_M1         ")"
#define SND_NEWTONIAN_M1		")"

#define PARTICLE_MAGNESIS_M1     			"raygun_projectile_blue"
#define PARTICLE_MAGNESIS_M1_FINALPAP		"raygun_projectile_blue_crit"
#define PARTICLE_NEWTONIAN_M1    			"raygun_projectile_red"
#define PARTICLE_NEWTONIAN_M1_FINALPAP    	"raygun_projectile_red_crit"

void Magnesis_Precache()
{
    PrecacheSound(SND_MAGNESIS_M1);
	PrecacheSound(SND_NEWTONIAN_M1);
}

void Magnesis_OnKill(int client, int victim)
{
}

public void Magnesis_OnNPCDamaged(int victim, int attacker, int weapon, float damage, int inflictor)
{

}

Handle Timer_Magnesis[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };
static float f_NextMagnesisHUD[MAXPLAYERS + 1] = { 0.0, ... };

public void Enable_Magnesis(int client, int weapon)
{
	if (Timer_Magnesis[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MAGNESIS)
		{
			delete Timer_Magnesis[client];
			Timer_Magnesis[client] = null;
			DataPack pack;
			Timer_Magnesis[client] = CreateDataTimer(0.1, Timer_MagnesisControl, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MAGNESIS)
	{
		DataPack pack;
		Timer_Magnesis[client] = CreateDataTimer(0.1, Timer_MagnesisControl, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		f_NextMagnesisHUD[client] = 0.0;
	}
}

public Action Timer_MagnesisControl(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Timer_Magnesis[client] = null;
		return Plugin_Stop;
	}

	Magnesis_HUD(client, weapon, false);

	return Plugin_Continue;
}

public void Magnesis_HUD(int client, int weapon, bool forced)
{
	if(f_NextMagnesisHUD[client] < GetGameTime() || forced)
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		if(weapon_holding == weapon)
		{
			char HUDText[255];

			PrintHintText(client, HUDText);

			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
		}

		f_NextMagnesisHUD[client] = GetGameTime() + 0.5;
	}
}

public void Magnesis_Attack_0(int client, int weapon, bool &result, int slot)
{
    Magnesis_FireProjectile(client, weapon, 0);
}

public void Magnesis_Attack_1(int client, int weapon, bool &result, int slot)
{
    Magnesis_FireProjectile(client, weapon, 1);
}

public void Magnesis_Attack_2(int client, int weapon, bool &result, int slot)
{
    Magnesis_FireProjectile(client, weapon, 2);
}

public void Magnesis_FireProjectile(int client, int weapon, int tier)
{
    float mana_cost = Magnesis_M1_Cost[tier];

    if(mana_cost <= Current_Mana[client])
	{	
		Rogue_OnAbilityUse(weapon);
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
		
		//TODO: Fire it.

        EmitSoundToAll(SND_MAGNESIS_M1, client, _, _, _, 0.66);
		EmitSoundToClient(client, SND_MAGNESIS_M1, _, _, _, _, 0.66);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		
		if (mana_cost > Current_Mana[client])
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}

public void Magnesis_Grab_0(int client, int weapon, bool &result, int slot)
{
    Magnesis_AttemptGrab(client, weapon, 0);
}

public void Magnesis_Grab_1(int client, int weapon, bool &result, int slot)
{
    Magnesis_AttemptGrab(client, weapon, 1);
}

public void Magnesis_Grab_2(int client, int weapon, bool &result, int slot)
{
    Magnesis_AttemptGrab(client, weapon, 2);
}

public void Magnesis_AttemptGrab(int client, int weapon, int tier)
{
    float mana_cost = Magnesis_Grab_Requirement[tier];

    if(mana_cost <= Current_Mana[client])
	{
		//TODO: Check to see if we can grab the thing we're looking at.

		Rogue_OnAbilityUse(weapon);
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		
		if (mana_cost > Current_Mana[client])
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}

public void Newtonian_Attack_0(int client, int weapon, bool &result, int slot)
{
    Newtonian_FireProjectile(client, weapon, 0);
}

public void Newtonian_Attack_1(int client, int weapon, bool &result, int slot)
{
    Newtonian_FireProjectile(client, weapon, 1);
}

public void Newtonian_Attack_2(int client, int weapon, bool &result, int slot)
{
    Newtonian_FireProjectile(client, weapon, 2);
}

public void Newtonian_FireProjectile(int client, int weapon, int tier)
{
    float mana_cost = Newtonian_M1_Cost[tier];

    if(mana_cost <= Current_Mana[client])
	{	
		Rogue_OnAbilityUse(weapon);
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
		
		//TODO: Fire it

        EmitSoundToAll(SND_NEWTONIAN_M1, client, _, _, _, 0.8);
		EmitSoundToClient(client, SND_NEWTONIAN_M1, _, _, _, _, 0.66);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		
		if (mana_cost > Current_Mana[client])
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}

public void Newtonian_Shockwave_0(int client, int weapon, bool &result, int slot)
{
    Newtonian_TryShockwave(client, weapon, 0);
}

public void Newtonian_Shockwave_1(int client, int weapon, bool &result, int slot)
{
    Newtonian_TryShockwave(client, weapon, 1);
}

public void Newtonian_Shockwave_2(int client, int weapon, bool &result, int slot)
{
    Newtonian_TryShockwave(client, weapon, 2);
}

public void Newtonian_TryShockwave(int client, int weapon, int tier)
{
    float mana_cost = Newtonian_M2_Cost[tier];

    if(mana_cost <= Current_Mana[client])
	{
		Rogue_OnAbilityUse(weapon);
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		//TODO: Shockwave

		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;

        EmitSoundToAll(SND_NEWTONIAN_M2, client);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		
		if (mana_cost > Current_Mana[client])
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}