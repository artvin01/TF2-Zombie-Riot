#pragma semicolon 1
#pragma newdecls required

#define WEAPON_SWITCH_SOUND 		"items/gunpickup2.wav"
#define CRIME_SOUND					"mvm/mvm_tank_explode.wav"

static Handle h_Barrack_Timer[MAXPLAYERS] = {null, ...};
static int BarracksBuffMode[MAXPLAYERS + 1];				// What type of buffs are you using for your shotgun
static int WeaponPap[MAXPLAYERS];							// What pap is the weapon, necessary for a bunch of checks
static int ResourceGen[MAXPLAYERS];							// Resource generation for Barracks
static int CivType[MAXPLAYERS];								// What civ is the player using, lms check and used for special buffs to barracks
static int ShotgunHeal_Targets[MAXPLAYERS];					// How many targets will the shotgun aoe heal (Npcs)
static float ShotgunHeal[MAXPLAYERS];						// How much is the shotgun healing
static float Barrack_HUDDelay[MAXPLAYERS];					// Hud delay
static float Barracks_PowerHitTime[MAXPLAYERS];				// Timer for the Crouch + M1 of the Italian Business
static float Barracks_NovaCDTime[MAXPLAYERS];				// Cd for the healing nova of the shotgun
static float ReDash[MAXPLAYERS];							// For the 5s window of the Chain Hit
bool BR_Precached = false;

/*
Passives:
Gets a bit of hp with paps (nowhere near as much as Melee kits, not as much as Therapy either).

The Marker - Primary1:
A revolver with 2 shots, 50% slower fire rate, generates barrack resources on hit and marks targets, each pap increases rate of fire, reload rate and mag size until 6.
[M2] - Makes you swap to the other primary weapon

Reconstructor Shotgun - Primary2:
A shotgun with average stats, infinite fire but slower fire rate, deals more dmg to marked and has a healing nova which also buffs starting from pap 4
[M2] - Makes you swap to the other primary weapon

Melee:
A wrench that works similarly to Tinker's one, starting from second pap it gets a powerful hit like Texas Business, stuns when hitting with the ability (not raids, don't look at me like that), from the 4th pap you can chain yet another dash after the first for more dmg and stun duration and basically keeps you safe but SIGNIFICANTLY more cooldown.
[Crouch + M1] - Unlocked after second pap, allows you to dash at a target for a powerful attack, can be used twice in a row starting from 4th pap.

*/
public void Barracks_OnMapStart()
{
	//precache + zero stuff
	PrecacheSound(WEAPON_SWITCH_SOUND);
	PrecacheSound(CRIME_SOUND);
	Zero(CivType);
	Zero(WeaponPap);
	Zero(ShotgunHeal);
	Zero(ShotgunHeal_Targets);
	Zero(BarracksBuffMode);
	Zero(Barrack_HUDDelay);
	Zero(ResourceGen);
	Zero(ReDash);
	Zero(Barracks_NovaCDTime);
	Zero(Barracks_PowerHitTime);
	
	BR_Precached = false;
}
void PrecacheBarracksMusic()
{
	if(!BR_Precached)
	{
		PrecacheSoundCustom("#zombiesurvival/medieval_raid/kazimierz_boss.mp3", _, 1);
		BR_Precached = true;
	} 
}
static int PlayerState(int client)
{
	if(GetClientButtons(client) & IN_DUCK)
		return 1;
	
	return 0;
}
public void Enable_Barracks(int client, int weapon)
{
	DataPack pack = new DataPack();
	if(h_Barrack_Timer[client] != null)
	{
		if(IsValidHandle(h_Barrack_Timer[client]))
			delete h_Barrack_Timer[client];
		h_Barrack_Timer[client] = null;
	}
	WeaponPap[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));
	ResourceGen[client] = RoundFloat(Attributes_Get(weapon, 4050, 0.0));
	h_Barrack_Timer[client] = CreateDataTimer(0.1, Timer_Barracks, pack, TIMER_REPEAT);
	pack.WriteCell(client);
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteCell(EntIndexToEntRef(client));
	PrecacheBarracksMusic();
}
static Action Timer_Barracks(Handle timer, DataPack pack)
{
	pack.Reset();
	int clientindx = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell());
	
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{	
		h_Barrack_Timer[clientindx] = null;
		return Plugin_Stop;
	}
	Barracks_HUD(client);
	return Plugin_Continue;
}
bool IsBarracks(int client)
{
	if(h_Barrack_Timer[client] != null)
		return true;

	return false;
}
public int WhatCiv(int client)
{
	// And so it begins to check every single Civ
	if (Store_HasNamedItem(client, "Almina's Last Hope"))
	{
		if (Store_HasNamedItem(client, "Almina and Expidonsan's Help"))
		{
			CivType[client] = Almina_Thorns;
		}
		else 
		{
			CivType[client] = Thorns;
		}
	}
	// Check for Expidonsa
	else if (Store_HasNamedItem(client, "Almina and Expidonsan's Help"))
	{
		CivType[client] = Almina_Thornless;
	}
	// Check Blitzkrieg
	else if (Store_HasNamedItem(client, "Blitzkrieg's Army"))
	{
		CivType[client] = Alternative;
	}
	// Check Guln
	else if (Store_HasNamedItem(client, "Guln's Companions"))
	{
		CivType[client] = Combine;
	}
	// Nothing equipped = Default
	else
	{
		CivType[client] = Default;
	}
	return CivType[client];
}
public void Weapon_Marker_M2(int client, int weapon, bool crit, int slot)
{
	EmitSoundToClient(client, WEAPON_SWITCH_SOUND, client, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	FakeClientCommandEx(client, "use tf_weapon_shotgun_primary");
}
public void Weapon_Hunter_M2(int client, int weapon, bool crit, int slot)
{
	EmitSoundToClient(client, WEAPON_SWITCH_SOUND, client, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	FakeClientCommandEx(client, "use tf_weapon_revolver");
}
public void Barracks_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int zr_custom_damage)
{
	if(CheckInHud())
	return;
	
	if(HasSpecificBuff(victim, "Marked"))
	{
		SummonerRenerateResources(attacker, 3.0 + (WeaponPap[attacker] * 2), 0.0, true);
	}
	
	ApplyStatusEffect(attacker, victim, "Marked", 4.0 + (WeaponPap[attacker] * 2));
	SummonerRenerateResources(attacker, 5.0, 0.0, true);
}
public void Barracks_OnTakeDamage_Hunter(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int zr_custom_damage)
{
	if(CheckInHud())
	return;
	
	if(HasSpecificBuff(victim, "Marked"))
	{
		damage *= (1.2 + ((WeaponPap[attacker] * 0.1)));
	}
	if(Ability_Check_Cooldown(attacker, 2) < 0.0)
	{
		float pos1[3];
		GetEntPropVector(attacker, Prop_Data, "m_vecAbsOrigin", pos1);
		ShotgunHeal[attacker] = (damage/2);
		
		HealingCap(attacker);	// Update the healing targets, basically checks the pap and updates "ShotgunHeal_Targets" based on it
		int targetsHealed = 0;	// Need to use it to keep track of how many it heals, must be max of 3 for balance reasons
		
		for(int entitycount = 0; entitycount < MAXENTITIES; entitycount++) // Check for npcs
		{
			if(targetsHealed >= ShotgunHeal_Targets[attacker])	// This is to immediately stop it after it heals the cap of units
			{
				break;
			}
			if(IsValidEntity(entitycount) && entitycount != attacker && (!b_NpcHasDied[entitycount]))	// 9000 more checks to see if they didn't die, to not heal the user, to heal ONLY barrack troops, to apply a debuff called "Healing Decay" to prevent healing....
			{
				if(GetTeam(entitycount) == GetTeam(attacker) && IsEntityAlive(entitycount))
				{
					char npc_classname[60];
					NPC_GetPluginById(i_NpcInternalId[entitycount], npc_classname, sizeof(npc_classname));
					
					if(StrContains(npc_classname, "npc_barrack", false) == -1)	// Check for healing ONLY barrack units
					{
						continue;
					}
					if(HasSpecificBuff(entitycount, "Healing Decay"))	// Skip targets that cannot be healed
					{
						continue;
					}

					static float pos2[3];
					GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
					if(GetVectorDistance(pos1, pos2, true) < (600 * 600))
					{
						HealEntityGlobal(attacker, entitycount, ShotgunHeal[attacker], _, 1.0);
						ShotgunBuffs(attacker, entitycount);	// And to buff npcs, thought i was done talking?
						if(!LastMann)
						{
							ApplyStatusEffect(attacker, entitycount, "Healing Decay", 15.0);	// This is the debuff that prevent healing from nova
						}
						else
						{
							ApplyStatusEffect(attacker, entitycount, "Healing Decay", 10.0);
						}
						targetsHealed++;
					}
				}
			}
		}
		DesertYadeamDoHealEffect(attacker, 600.0);
		HealEntityGlobal(attacker, attacker, (ShotgunHeal[attacker]/20), _, 3.0); // User heals themselves for 5% of that much
		ApplyStatusEffect(attacker, attacker, "Healing Decay", 15.0);	// You can only heal yourself once every 15s even on LMS, i don't wanna give too much self healing
		if(!LastMann)
		{
			Ability_Apply_Cooldown(attacker, 2, 15.0);
			if(i_CurrentEquippedPerk[attacker] & PERK_ENERGY_DRINK)
			{
				Barracks_NovaCDTime[attacker] = GetGameTime() + 12.75;
			}
			else
			{
				Barracks_NovaCDTime[attacker] = GetGameTime() + 15.0;
			}
		}
		else
		{
			Ability_Apply_Cooldown(attacker, 2, 10.0);
			if(i_CurrentEquippedPerk[attacker] & PERK_ENERGY_DRINK)
			{
				Barracks_NovaCDTime[attacker] = GetGameTime() + 8.5;
			}
			else
			{
				Barracks_NovaCDTime[attacker] = GetGameTime() + 10.0;
			}
		}
	}
}
public void Barracks_OnTakeDamage_Italian(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int zr_custom_damage)
{
	if(CheckInHud())
		return;
	
	if(HasSpecificBuff(victim, "Marked"))
	{
		SummonerRenerateResources(attacker, 5.0 + (WeaponPap[attacker] * 3.5), 0.0, true);
		damage *= 1.5;
	}
	SummonerRenerateResources(attacker, 10.0, 0.0, true);
	if(WeaponPap[attacker] >= 2)
	{
		if(PlayerState(attacker) == 1)
		{
			if(WeaponPap[attacker] >= 4)
			{
				if(ReDash[attacker] > GetGameTime())	// Checks to avoid redash bla bla bla, also totally didn't "borrow" Texas Business code (thanks)
				{
					damage *= 6.0;
					ReDash[attacker] = 0.0;
					
					ClientCommand(attacker, "playgamesound weapons/air_burster_explode3.wav");
					ClientCommand(attacker, "playgamesound weapons/air_burster_explode3.wav");
					static float anglesB[3];
					GetClientEyeAngles(attacker, anglesB);
					static float velocity[3];
					GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
					float knockback = -700.0;
					// knockback is the overall force with which you be pushed, don't touch other stuff
					ScaleVector(velocity, knockback);
					if ((GetEntityFlags(attacker) & FL_ONGROUND) != 0 || GetEntProp(attacker, Prop_Send, "m_nWaterLevel") >= 1)
						velocity[2] = fmax(velocity[2], 300.0);
					else
						velocity[2] += 150.0;    // a little boost to alleviate arcing issues
					TeleportEntity(attacker, NULL_VECTOR, NULL_VECTOR, velocity);
					
					if(!b_thisNpcIsARaid[victim])
						FreezeNpcInTime(victim, 1.0);
						
					SummonerRenerateResources(attacker, 60.0, 0.0, true);
					if(!LastMann)
					{
						Ability_Apply_Cooldown(attacker, 1, 70.0);
						if(i_CurrentEquippedPerk[attacker] & PERK_ENERGY_DRINK)
						{
							Barracks_PowerHitTime[attacker] = GetGameTime() + 59.5;
						}
						else
						{
							Barracks_PowerHitTime[attacker] = GetGameTime() + 70.0;
						}
					}
					else
					{
						Ability_Apply_Cooldown(attacker, 1, 45.0);
						if(i_CurrentEquippedPerk[attacker] & PERK_ENERGY_DRINK)
						{
							Barracks_PowerHitTime[attacker] = GetGameTime() + 38.25;
						}
						else
						{
							Barracks_PowerHitTime[attacker] = GetGameTime() + 45.0;
						}
					}
				}
			}
			if(Ability_Check_Cooldown(attacker, 1) <= 0.0)
			{
				int Crime = GetRandomInt(1, 2000);
				if(Crime != 2000)	// Don't say that word...
				{
					damage *= 5.0;
					
					ClientCommand(attacker, "playgamesound weapons/air_burster_explode3.wav");
					static float anglesB[3];
					GetClientEyeAngles(attacker, anglesB);
					static float velocity[3];
					GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
					float knockback = -350.0;
					// knockback is the overall force with which you be pushed, don't touch other stuff
					ScaleVector(velocity, knockback);
					if ((GetEntityFlags(attacker) & FL_ONGROUND) != 0 || GetEntProp(attacker, Prop_Send, "m_nWaterLevel") >= 1)
						velocity[2] = fmax(velocity[2], 300.0);
					else
						velocity[2] += 150.0;    // a little boost to alleviate arcing issues
					TeleportEntity(attacker, NULL_VECTOR, NULL_VECTOR, velocity);
					
					if(!b_thisNpcIsARaid[victim])
						FreezeNpcInTime(victim, 1.0);
					
					SummonerRenerateResources(attacker, 50.0, 0.0, true);
					if(!LastMann)
					{
						Ability_Apply_Cooldown(attacker, 1, 30.0);
						if(i_CurrentEquippedPerk[attacker] & PERK_ENERGY_DRINK)
						{
							Barracks_PowerHitTime[attacker] = GetGameTime() + 25.5;
						}
						else
						{
							Barracks_PowerHitTime[attacker] = GetGameTime() + 30.0;
						}
					}
					else
					{
						Ability_Apply_Cooldown(attacker, 1, 20.0);
						if(i_CurrentEquippedPerk[attacker] & PERK_ENERGY_DRINK)
						{
							Barracks_PowerHitTime[attacker] = GetGameTime() + 17.0;
						}
						else
						{
							Barracks_PowerHitTime[attacker] = GetGameTime() + 20.0;
						}
					}
					if(WeaponPap[attacker] >= 4)
						ReDash[attacker] = GetGameTime() + 5.0;
				}
				else	// Ooooh boy...
				{
					float vecMe[3]; WorldSpaceCenter(attacker, vecMe);
					vecMe[2] += 45;
					TE_Particle("asplode_hoodoo", vecMe, NULL_VECTOR, NULL_VECTOR, attacker, _, _, _, _, _, _, _, _, _, 0.0);
					
					damage *= 50.0;
					
					EmitSoundToAll(CRIME_SOUND, attacker, SNDCHAN_STATIC, 100, _, 1.0);
					CPrintToChatAll("{red}%N said something about putting PINEAPPLE ON PIZZA and the wrench violently explodes sending them to Saturn.", attacker);
					
					static float anglesB[3];
					GetClientEyeAngles(attacker, anglesB);
					static float velocity[3];
					GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
					float knockback = -3500.0;
					// knockback is the overall force with which you be pushed, don't touch other stuff
					ScaleVector(velocity, knockback);
					if ((GetEntityFlags(attacker) & FL_ONGROUND) != 0 || GetEntProp(attacker, Prop_Send, "m_nWaterLevel") >= 1)
						velocity[2] = fmax(velocity[2], 300.0);
					else
						velocity[2] += 150.0;    // a little boost to alleviate arcing issues
					TeleportEntity(attacker, NULL_VECTOR, NULL_VECTOR, velocity);
					
					FreezeNpcInTime(victim, 3.0);
					ApplyStatusEffect(attacker, attacker, "Ragdolled", 3.0);
					FreezeNpcInTime(attacker, 3.0);
					
					SummonerRenerateResources(attacker, 120.0, 0.0, true);
					if(!LastMann)
					{
						Ability_Apply_Cooldown(attacker, 1, 30.0);
						if(i_CurrentEquippedPerk[attacker] & PERK_ENERGY_DRINK)
						{
							Barracks_PowerHitTime[attacker] = GetGameTime() + 25.5;	// For anybody that reads and wonders "Wait, isn't that an annoyance to write and calculate all cooldowns -15% cause energy drink? Yes, it is.
						}
						else
						{
							Barracks_PowerHitTime[attacker] = GetGameTime() + 30.0;
						}
					}
					else
					{
						Ability_Apply_Cooldown(attacker, 1, 20.0);
						if(i_CurrentEquippedPerk[attacker] & PERK_ENERGY_DRINK)
						{
							Barracks_PowerHitTime[attacker] = GetGameTime() + 17.0;
						}
						else
						{
							Barracks_PowerHitTime[attacker] = GetGameTime() + 20.0;
						}
					}
				}
			}
		}
	}
}
public int Barracks_GetInfo(int client, int choice)
{
	if (client > 0 && client <= MaxClients)
	{
		if (!IsBarracks(client))
		return -1;
		
		switch(choice)
		{
			case 1:
				return WeaponPap[client];
			case 2:
				return ResourceGen[client];
		}
	}
	return 0;
}
public void HealingCap(int client)
{
	int Targets = 1;
	switch(WeaponPap[client])
	{
		case 1:
		{
			Targets = 1;
		}
		case 2:
		{
			Targets = 2;
		}
		case 3:
		{
			Targets = 3;
		}
		case 4:
		{
			Targets = 3;
		}
		case 5:
		{
			Targets = 3;
		}
		case 6:
		{
			Targets = 3;
		}
		case 7:
		{
			Targets = 3;
		}
	}
	ShotgunHeal_Targets[client] = Targets; 
}
public void Barracks_ChangeBuffMode(int client, int weapon, bool crit, int slot)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client))
		return;

	if (BarracksBuffMode[client] == 0)
	{
		BarracksBuffMode[client] = 1;
	}
	else
	{
		BarracksBuffMode[client] = 0;
	}
	ClientCommand(client, "playgamesound weapons/vaccinator_toggle.wav");
}
public void ShotgunBuffs(int client, int entity)
{
	if(WeaponPap[client] > 3)
	{
		if (BarracksBuffMode[client] == 0)	// If it's 0 the player is using Defensive buffs which are below
		{
			switch(WeaponPap[client])
			{
				case 4:
				{
					ApplyStatusEffect(client, entity, "Barrack Defense Overclock 1", 5.0);
					ApplyStatusEffect(client, client, "Barrack Defense Overclock 1", 5.0);
				}
				case 5:
				{
					ApplyStatusEffect(client, entity, "Barrack Defense Overclock 2", 5.0);
					ApplyStatusEffect(client, client, "Barrack Defense Overclock 2", 5.0);
				}
				case 6:
				{
					ApplyStatusEffect(client, entity, "Barrack Defense Overclock 3", 5.0);
					ApplyStatusEffect(client, client, "Barrack Defense Overclock 3", 5.0);
				}
				case 7:
				{
					ApplyStatusEffect(client, entity, "Barrack Defense Overclock 4", 5.0);
					ApplyStatusEffect(client, client, "Barrack Defense Overclock 4", 5.0);
				}
			}
		}
		else	// Otherwise it's offense mode so buffs that increase dmg/attack speed of troops
		{
			switch(WeaponPap[client])
			{
				case 4:
				{
					ApplyStatusEffect(client, entity, "Barrack Offense Overclock 1", 5.0);
					ApplyStatusEffect(client, client, "Barrack Offense Overclock 1", 5.0);
				}
				case 5:
				{
					ApplyStatusEffect(client, entity, "Barrack Offense Overclock 2", 5.0);
					ApplyStatusEffect(client, client, "Barrack Offense Overclock 2", 5.0);
				}
				case 6:
				{
					ApplyStatusEffect(client, entity, "Barrack Offense Overclock 3", 5.0);
					ApplyStatusEffect(client, client, "Barrack Offense Overclock 3", 5.0);
				}
				case 7:
				{
					ApplyStatusEffect(client, entity, "Barrack Offense Overclock 4", 5.0);
					ApplyStatusEffect(client, client, "Barrack Offense Overclock 4", 5.0);
				}
			}
		}
	}
}
static void Barracks_HUD(int client)
{
	if (Barrack_HUDDelay[client] > GetGameTime())
		return;

	// Calculate remaining time by subtracting current time from expiration time, unironically was quite annoying to do due to the sheer amount of conditionals...
	float PowerHit = Barracks_PowerHitTime[client] - GetGameTime();
	float NovaCD = Barracks_NovaCDTime[client] - GetGameTime();

	char BarracksHud[255];
	
	// Buff Mode Hud
	if (WeaponPap[client] < 4)
	{
		Format(BarracksHud, sizeof(BarracksHud), "Barracks Abilities Status\n[Healing Nova Mode: LOCKED]");
	}
	else
	{
		if (BarracksBuffMode[client] == 0)
		{
			Format(BarracksHud, sizeof(BarracksHud), "Barracks Abilities Status\n[Healing Nova Mode: Defense]");
		}
		else
		{
			Format(BarracksHud, sizeof(BarracksHud), "Barracks Abilities Status\n[Healing Nova Mode: Offense]");
		}
	}

	// Heal Nova Hud
	if (NovaCD <= 0.0)
	{
		Format(BarracksHud, sizeof(BarracksHud), "%s\nHealing Nova: Ready!", BarracksHud);
	}
	else
	{
		Format(BarracksHud, sizeof(BarracksHud), "%s\nHealing Nova: [%.1f]", BarracksHud, NovaCD);
	}

	// Power-Strike + Chain-Hit, if you're wondering why it's called ReDash btw it's cause i thought about making it a dash, decided against it
	if(WeaponPap[client] >= 2)
	{
		float redashTimeLeft = ReDash[client] - GetGameTime();
		if(WeaponPap[client] >= 4)	// This has to show ONLY if the pap is >= 4
		{
			if(redashTimeLeft > 0.0)
			{
				Format(BarracksHud, sizeof(BarracksHud), "%s\nChain Hit: ACTIVE! (Chain Window: %.1fs)", BarracksHud, redashTimeLeft);
			}
		}
		if(redashTimeLeft <= 0.0)	// Show the cooldown only when the redash ends
		{
			if(PowerHit <= 0.0)
			{
				Format(BarracksHud, sizeof(BarracksHud), "%s\nPower-Strike: Ready!", BarracksHud);
			}
			else
			{
				Format(BarracksHud, sizeof(BarracksHud), "%s\nPower-Strike: [%.1f]", BarracksHud, PowerHit);
			}
		}
	}

	Barrack_HUDDelay[client] = GetGameTime() + 0.4;
	PrintHintText(client, "%s", BarracksHud);
}

