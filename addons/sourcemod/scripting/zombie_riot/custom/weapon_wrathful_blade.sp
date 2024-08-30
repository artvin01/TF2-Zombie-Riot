#pragma semicolon 1
#pragma newdecls required

//As per usual, I'm using arrays for stats on different pap levels. First entry is pap1, then pap2, etc.

//INFERNAL FURY: While holding M2, drain your health to burn everything around you and increase your melee stats.
//Self-damage and cooldown become higher the longer it is active. When the ability ends, heal X HP for every zombie you killed while it is active,
//at a rate of Y HP per second, up to a maximum of Z.
static float Fury_ATKSpeed[3] = { 1.33, 1.66, 2.0 };		//Amount to multiply the user's melee attack rate while Infernal Fury is active.
static float Fury_ResMult[3] = { 0.75, 0.66, 0.5 };			//Amount to multiply damage taken from enemies while Infernal Fury is active.
static float Fury_DMGMult[3] = { 1.5, 1.75, 2.0 };			//Amount to multiply damage dealt by the user's melee attacks while Infernal Fury is active.
static float Fury_BurnDMG[3] = { 2.0, 3.0, 4.0 };			//Base damage dealt by Infernal Fury's AOE per 0.1s. This is affected by attributes.
static float Fury_BurnFalloff[3] = { 0.66, 0.7, 0.75 };		//Amount to multiply Infernal Fury's AOE damage for every enemy it hits.
static float Fury_BurnRadius[3] = { 120.0, 180.0, 240.0 };	//Infernal Fury AOE radius.
static int Fury_BurnMaxTargets[3] = { 3, 4, 5 };			//Infernal Fury max targets hit per AOE.	
static float Fury_HPDrain_Base[3] = { 1.0, 1.0, 1.0 };		//Base damage taken by the user per 0.1s while Infernal Fury is active.
static float Fury_HPDrain_Rise[3] = { 1.0, 1.0, 1.0 };		//Amount to increase Infernal Fury's self-damage per second while it is active.
static float Fury_HPDrain_Max[3] = { 30.0, 40.0, 50.0 };	//Maximum self-damage taken per 0.1s while Infernal Fury is active.
static float Fury_HealPerKill[3] = { 10.0, 15.0, 20.0 };	//Healing stored per zombie killed while Infernal Fury is active.
static float Fury_MaxHeals[3] = { 1000.0, 2000.0, 3000.0 };	//Maximum healing stored per Infernal Fury usage.
static float Fury_HealRate[3] = { 2.0, 3.0, 4.0 };			//Stored healing given per 0.1s while Infernal Fury is not active.
static float Fury_HealRate_Penalty[3] = { 0.5, 0.5, 0.5 };	//Amount to multiply Fury_HealRate if the user has taken damage within the past 3 seconds.
static float Fury_MinCD[3] = { 10.0, 10.0, 10.0 };			//Minimum Infernal Fury cooldown.
static float Fury_MinCDTime[3] = { 2.0, 2.0, 2.0 };			//Maximum duration Infernal Fury can be used and still have the minimum cooldown applied.
static float Fury_CDRaise[3] = { 0.4, 0.4, 0.4 };			//Amount to increase Infernal Fury's cooldown per 0.1s of usage past the minimum CD window.
static float Fury_MaxCD[3] = { 120.0, 120.0, 120.0 };		//Maximum cooldown applied to Infernal Fury.
static float Fury_CDR[3] = { 0.5, 0.5, 0.5 };				//Amount to reduce Infernal Fury's remaining cooldown upon killing a zombie while Infernal Fury is not active.

//WRATH STRIKE: If enabled: Infernal Fury now charges up a powerful melee hit, which is given when Infernal Fury ends.
//The longer Infernal Fury is active, the stronger this attack becomes.
static bool Wrath_Enabled[3] = { false, false, true };		//Is Wrath Strike enabled on this PaP tier?
static float Wrath_MinStrength[3] = { 2.0, 2.0, 2.0 };		//The minimum possible melee damage multiplier of the Wrath Strike hit.
static float Wrath_MinStrengthTime[3] = { 2.0, 2.0, 2.0 };	//Duration for which Infernal Fury must be used for the minimum melee damage bonus to be applied.
static float Wrath_Rise[3] = { 0.1, 0.1, 0.1 };				//Amount to increase Wrath Strike's damage multiplier per 0.1s of Infernal Fury's use-time, after the MinStrengthTime has passed.
static float Wrath_MaxStrength[3] = { 8.0, 8.0, 8.0 };		//Maximum melee damage multiplier.

//Client/entity-specific global variables below, don't touch these:
static bool Wrath_Active[MAXPLAYERS + 1] = { false, ... };
static bool Fury_Active[MAXPLAYERS + 1] = { false, ... };
static float Wrath_Multiplier[MAXPLAYERS + 1] = { 1.0, ... };
static float Fury_StoredHealth[MAXPLAYERS + 1] = { 0.0, ... };
static float Fury_CurrentHealthDrain[MAXPLAYERS + 1] = { 0.0, ... };
static float Fury_StartTime[MAXPLAYERS + 1] = { 0.0, ... };
static int Fury_Tier[MAXPLAYERS + 1] = { 0, ... };
static float ability_cooldown[MAXPLAYERS + 1] = {0.0, ...};

public void Wrathful_Blade_ResetAll()
{
	for (int i = 0; i <= MaxClients; i++)
	{
		Fury_Active[i] = false;
		Wrath_Active[i] = false;
	}

	Zero(ability_cooldown);
}

#define SND_WRATH_SHOUT_SCOUT			")vo/scout_paincrticialdeath02.mp3"
#define SND_WRATH_SHOUT_SNIPER			")vo/sniper_paincrticialdeath01.mp3"
#define SND_WRATH_SHOUT_SOLDIER			")vo/soldier_paincrticialdeath01.mp3"
#define SND_WRATH_SHOUT_DEMOMAN			")vo/demoman_paincrticialdeath02.mp3"
#define SND_WRATH_SHOUT_MEDIC			")vo/medic_paincrticialdeath02.mp3"
#define SND_WRATH_SHOUT_HEAVY			")vo/heavy_paincrticialdeath02.mp3"
#define SND_WRATH_SHOUT_PYRO			")vo/pyro_paincrticialdeath01.mp3"
#define SND_WRATH_SHOUT_SPY				")vo/spy_paincrticialdeath02.mp3"
#define SND_WRATH_SHOUT_ENGINEER		")vo/engineer_paincrticialdeath01.mp3"
#define SND_WRATH_SHOUT_BARNEY			")vo/k_lab2/ba_getgoing.wav"
#define SND_WRATH_SHOUT_KLEINER			")vo/trainyard/kl_whatisit02.wav"
#define SND_WRATH_SHOUT_SKELETON		")items/halloween/witch03.wav"
#define SND_WRATH_SHOUT_NIKO			")misc/blank.wav"
#define SND_WRATH_BEGIN					")weapons/quake_explosion_remastered.wav"
#define SND_WRATH_LOOP					")weapons/phlog_loop_crit.wav"
#define SND_WRATH_END					")player/flame_out.wav"
#define SND_WRATHSTRIKE_ACTIVATE		")mvm/mvm_tele_activate.wav"
#define SND_WRATHSTRIKE_FULLYCHARGED	"mvm/mvm_tank_horn.wav"
#define SND_WRATHSTRIKE_SMASH			")mvm/mvm_tank_smash.wav"

#define FURY_AURA						"burningplayer_red"

void Wrathful_Blade_Precache()
{
	PrecacheSound(SND_WRATH_SHOUT_SCOUT);
	PrecacheSound(SND_WRATH_SHOUT_SNIPER);
	PrecacheSound(SND_WRATH_SHOUT_SOLDIER);
	PrecacheSound(SND_WRATH_SHOUT_DEMOMAN);
	PrecacheSound(SND_WRATH_SHOUT_MEDIC);
	PrecacheSound(SND_WRATH_SHOUT_HEAVY);
	PrecacheSound(SND_WRATH_SHOUT_PYRO);
	PrecacheSound(SND_WRATH_SHOUT_SPY);
	PrecacheSound(SND_WRATH_SHOUT_ENGINEER);
	PrecacheSound(SND_WRATH_SHOUT_BARNEY);
	PrecacheSound(SND_WRATH_SHOUT_KLEINER);
	PrecacheSound(SND_WRATH_SHOUT_SKELETON);
	PrecacheSound(SND_WRATH_SHOUT_NIKO);
	PrecacheSound(SND_WRATH_BEGIN);
	PrecacheSound(SND_WRATH_LOOP);
	PrecacheSound(SND_WRATH_END);
	PrecacheSound(SND_WRATHSTRIKE_ACTIVATE);
	PrecacheSound(SND_WRATHSTRIKE_FULLYCHARGED);
	PrecacheSound(SND_WRATHSTRIKE_SMASH);
}

public float WrathfulBlade_OnNPCDamaged(int victim, int attacker, int weapon, float damage, int inflictor)
{
	bool isMelee = weapon == GetPlayerWeaponSlot(attacker, 2);

	if (Fury_Active[attacker] && isMelee)
	{
		damage *= Fury_DMGMult[Fury_Tier[attacker]];
	}

	if (Wrath_Active[attacker] && isMelee)
	{
		damage *= Wrath_Multiplier[attacker];
		Wrath_Active[attacker] = false;
		Wrath_Multiplier[attacker] = 1.0;
		EmitSoundToAll(SND_WRATHSTRIKE_SMASH, victim);
	}

	if (damage >= GetEntProp(victim, Prop_Data, "m_iHealth"))
	{
		if (Fury_Active[attacker])
		{
			Fury_StoredHealth[attacker] += Fury_HealPerKill[Fury_Tier[attacker]];
		}
		else
		{
			float cd = Ability_Check_Cooldown(attacker, 2);
			cd -= Fury_CDR[Fury_Tier[attacker]];
			Ability_Apply_Cooldown(attacker, 2, cd);
		}
	}

	return damage;
}

Handle Timer_Wrath[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };
static float f_NextWrathHUD[MAXPLAYERS + 1] = { 0.0, ... };

public void Enable_WrathfulBlade(int client, int weapon)
{
	if (Timer_Wrath[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_WRATHFUL_BLADE)
		{
			delete Timer_Wrath[client];
			Timer_Wrath[client] = null;
			DataPack pack;
			Timer_Wrath[client] = CreateDataTimer(0.1, Timer_WrathControl, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_WRATHFUL_BLADE)
	{
		DataPack pack;
		Timer_Wrath[client] = CreateDataTimer(0.1, Timer_WrathControl, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		f_NextWrathHUD[client] = 0.0;
	}
}

public Action Timer_WrathControl(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Timer_Wrath[client] = null;
		return Plugin_Stop;
	}	

	Wrath_HUD(client, weapon, false);

	return Plugin_Continue;
}

public void Wrath_HUD(int client, int weapon, bool forced)
{
	if(f_NextWrathHUD[client] < GetGameTime() || forced)
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		if(weapon_holding == weapon)
		{
			char HUDText[255];

			if (!Fury_Active[client] && !Wrath_Active[client])
			{
				float remCD = Ability_Check_Cooldown(client, 2);
				if (remCD > 0.0)
				{
					Format(HUDText, sizeof(HUDText), "Infernal Fury [%.1fs]", remCD);
				}
				else
				{
					Format(HUDText, sizeof(HUDText), "Infernal Fury [HOLD M2]");
				}
			}
			else if (Wrath_Active[client])
			{
				Format(HUDText, sizeof(HUDText), "WRATH STRIKE IS READY: %i[PERCENT] MELEE DAMAGE", RoundFloat(Wrath_Multiplier[client] * 100.0));
			}
			else if (Fury_Active[client])
			{
				Format(HUDText, sizeof(HUDText), "INFERNAL FURY: ACTIVE\nHEALTH STORED: %i/%i", RoundFloat(Fury_StoredHealth[client]), RoundFloat(Fury_MaxHeals[Fury_Tier[client]]));
				if (Wrath_Enabled[Fury_Tier[client]])
					Format(HUDText, sizeof(HUDText), "\nCHARGING WRATH STRIKE: %i[PERCENT]", RoundFloat(Wrath_Multiplier[client] * 100.0));
			}

			ReplaceString(HUDText, sizeof(HUDText), "[PERCENT]", "%%");
			PrintHintText(client, HUDText);

			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
		}

		f_NextWrathHUD[client] = GetGameTime() + 0.5;
	}
}

public void Fury_Activated_PaP1(int client, int weapon, bool crit)
{
	Fury_AttemptUse(client, weapon, crit, 0);
}

public void Fury_Activated_PaP2(int client, int weapon, bool crit)
{
	Fury_AttemptUse(client, weapon, crit, 0);
}

public void Fury_Activated_PaP3(int client, int weapon, bool crit)
{
	Fury_AttemptUse(client, weapon, crit, 0);
}

public void Fury_AttemptUse(int client, int weapon, bool crit, int tier)
{
	if (Ability_Check_Cooldown(client, 2) < 0.0)
	{
		Wrath_HUD(client, weapon, true);
		Fury_Tier[client] = tier;
		Fury_StartTime[client] = GetGameTime();
		Fury_CurrentHealthDrain[client] = Fury_HPDrain_Base[tier];

		CreateTimer(0.1, Fury_Logic, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

		Fury_Shout(client);
		EmitSoundToAll(SND_WRATH_BEGIN, client);
		EmitSoundToAll(SND_WRATH_LOOP, client);

		TE_SetupParticleEffect(FURY_AURA, PATTACH_ABSORIGIN_FOLLOW, client);
		TE_WriteNum("m_bControlPoint1", client);	
		TE_SendToAll();
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, 2);
				
		if(Ability_CD <= 0.0)
		Ability_CD = 0.0;
				
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Wrathful Ability Cooldown", Ability_CD);
	}
}

public Action Fury_Logic(Handle timelytimer, int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidClient(client))
		return Plugin_Stop;

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); 

	if (dieingstate[client] > 0 || i_CustomWeaponEquipLogic[weapon] != WEAPON_WRATHFUL_BLADE || !IsPlayerAlive(client))
	{
		Fury_TerminateEffects(client);
		return Plugin_Stop;
	}

	int tier = Fury_Tier[client];
	bool hasWrath = Wrath_Enabled[tier];
	Wrath_HUD(client, weapon, true);

	if (GetClientButtons(client) & IN_ATTACK2 == 0)
	{
		Fury_TerminateEffects(client);

		if (hasWrath)
		{
			Wrath_Active[client] = true;

			EmitSoundToAll(SND_WRATHSTRIKE_ACTIVATE);

			TF2_AddCondition(client, TFCond_CritHype);

			if (Wrath_Multiplier[client] < Wrath_MinStrength[tier])
				Wrath_Multiplier[client] = Wrath_MinStrength[tier];
		}

		return Plugin_Stop;
	}
	else
	{
		float DMG = Fury_BurnDMG[tier];
		DMG *= Attributes_Get(weapon, 1, 1.0);
		DMG *= Attributes_Get(weapon, 2, 1.0);
		DMG *= Attributes_Get(weapon, 1000, 1.0);
		//We calculate the damage ourself so that we don't have to pass the weapon index.
		//If we do pass the weapon index, it gets counted as melee damage which allows it to be multiplied by Infernal Fury's melee multiplier. Too cheesy!

		float pos[3];
		WorldSpaceCenter(client, pos);

		Explode_Logic_Custom(DMG, client, client, 0, pos, Fury_BurnRadius[tier], Fury_BurnFalloff[tier], _, _, Fury_BurnMaxTargets[tier], true, 1.0);

		if (hasWrath && (GetGameTime() - Fury_StartTime[client]) > Wrath_MinStrengthTime[tier] && Wrath_Multiplier[client] < Wrath_MaxStrength[client])
		{
			Wrath_Multiplier[client] += Wrath_Rise[tier];
			if (Wrath_Multiplier[client] >= Wrath_MaxStrength[tier])
			{
				EmitSoundToClient(client, SND_WRATHSTRIKE_FULLYCHARGED);
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Wrath Strike Fully Charged");
				Wrath_Multiplier[client] = Wrath_MaxStrength[tier];
			}
		}

		SDKHooks_TakeDamage(client, client, client, Fury_CurrentHealthDrain[client]);
		if (Fury_CurrentHealthDrain[client] < Fury_HPDrain_Max[tier])
		{
			Fury_CurrentHealthDrain[client] += Fury_HPDrain_Rise[tier] * 0.1;
			if (Fury_CurrentHealthDrain[client] > Fury_HPDrain_Max[tier])
				Fury_CurrentHealthDrain[client] = Fury_HPDrain_Max[tier];
		}
	}

	return Plugin_Continue;
}

public void Fury_TerminateEffects(int client)
{
	TE_Start("EffectDispatch");
	TE_WriteNum("entindex", client);
	TE_WriteNum("m_nHitBox", GetParticleEffectIndex(FURY_AURA));
	TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffectStop"));
	TE_SendToAll();
	
	Fury_Active[client] = false;
	StopSound(client, SNDCHAN_AUTO, SND_WRATH_LOOP);
	EmitSoundToAll(SND_WRATH_END, client);

	Fury_ApplyCooldown(client);
}

public void Fury_ApplyCooldown(int client)
{
	float cd = Fury_MinCD[Fury_Tier[client]];

	float useTime = (GetGameTime() - Fury_StartTime[client]) - Fury_MinCDTime[Fury_Tier[client]];
	
	if (useTime > 0.0)
	{
		cd += useTime * (10.0 * Fury_CDRaise[Fury_Tier[client]]);
		if (cd > Fury_MaxCD[Fury_Tier[client]])
			cd = Fury_MaxCD[Fury_Tier[client]];
	}

	Ability_Apply_Cooldown(client, 2, cd);
}

public void Fury_Shout(int client)
{
	char sound[255];

	if (i_CustomModelOverrideIndex[client] < BARNEY)
	{
		switch (view_as<int>(CurrentClass[client]))
		{
			case 1:
			{
				sound = SND_WRATH_SHOUT_SCOUT;
			}
			case 2:
			{
				sound = SND_WRATH_SHOUT_SNIPER;
			}
			case 3:
			{
				sound = SND_WRATH_SHOUT_SOLDIER;
			}
			case 4:
			{
				sound = SND_WRATH_SHOUT_DEMOMAN;
			}
			case 5:
			{
				sound = SND_WRATH_SHOUT_MEDIC;
			}
			case 6:
			{
				sound = SND_WRATH_SHOUT_HEAVY;
			}
			case 7:
			{
				sound = SND_WRATH_SHOUT_PYRO;
			}
			case 8:
			{
				sound = SND_WRATH_SHOUT_SPY;
			}
			case 9:
			{
				sound = SND_WRATH_SHOUT_ENGINEER;
			}
		}
	}
	else
	{
		switch(i_CustomModelOverrideIndex[client])
		{
			case 1:
			{
				sound = SND_WRATH_SHOUT_BARNEY;
			}
			case 2:
			{
				sound = SND_WRATH_SHOUT_NIKO;
			}
			case 3:
			{
				sound = SND_WRATH_SHOUT_SKELETON;
			}
			case 4:
			{
				sound = SND_WRATH_SHOUT_KLEINER;
			}
		}
	}

	EmitSoundToAll(sound, client, _, _, _, _, 90);
	EmitSoundToAll(sound, client, _, _, _, 0.85, 70);
	EmitSoundToAll(sound, client, _, _, _, 0.75, 50);
}