#pragma semicolon 1
#pragma newdecls required

//As per usual, I'm using arrays for stats on different pap levels. First entry is pap1, then pap2, etc.

//INFERNAL FURY: While holding M2, drain your health to burn everything around you and increase your melee stats.
//Self-damage and cooldown become higher the longer it is active. When the ability ends, heal X HP for every zombie you killed while it is active,
//at a rate of Y HP per second, up to a maximum of Z.
static float Fury_ATKSpeed[3] = { 1.33, 1.415, 1.66 };			//Amount to multiply the user's melee attack rate while Infernal Fury is active.
static float Fury_ResMult[3] = { 0.5, 0.4, 0.25 };				//Amount to multiply damage taken from enemies while Infernal Fury is active. This should be fairly strong, because otherwise you can't really use the ability to be aggressive because the self-damage plus the damage you're taking from the enemies will get you killed in seconds.
static float Fury_DMGMult[3] = { 1.25, 1.33, 1.75 };			//Amount to multiply damage dealt by the user's melee attacks while Infernal Fury is active.
static float Fury_BurnDMG[3] = { 2.0, 3.0, 5.0 };				//Base damage dealt by Infernal Fury's AOE per 0.1s. This is affected by attributes.
static float Fury_BurnFalloff[3] = { 0.66, 0.7, 0.75 };			//Amount to multiply Infernal Fury's AOE damage for every enemy it hits.
static float Fury_BurnRadius[3] = { 120.0, 160.0, 200.0 };		//Infernal Fury AOE radius.
static int Fury_BurnMaxTargets[3] = { 3, 4, 6 };				//Infernal Fury max targets hit per AOE.	
static float Fury_HPDrain_Base[3] = { 0.2, 0.5, 1.0 };			//Base damage taken by the user per 0.1s while Infernal Fury is active.
static float Fury_HPDrain_Rise[3] = { 0.2, 0.75, 1.0 };			//Amount to increase Infernal Fury's self-damage per second while it is active.
static float Fury_HPDrain_Max[3] = { 10.0, 30.0, 40.0 };		//Maximum self-damage taken per 0.1s while Infernal Fury is active.
static float Fury_HPDrain_UberMult[3] = { 0.66, 0.66, 0.75 };	//Amount to multiply self-damage taken if übercharged.
static float Fury_HealPerKill[3] = { 20.0, 25.0, 60.0 };		//Healing stored per zombie killed while Infernal Fury is active.
static float Fury_MaxHeals[3] = { 1000.0, 2000.0, 3000.0 };		//Maximum healing stored per Infernal Fury usage.
static float Fury_HealRate[3] = { 2.0, 3.0, 4.0 };				//Stored healing given per 0.1s while Infernal Fury is not active.
static float Fury_HealRate_Penalty[3] = { 0.5, 0.5, 0.5 };		//Amount to multiply Fury_HealRate if the user has taken damage within the past 3 seconds.
static float Fury_MinCD[3] = { 10.0, 10.0, 10.0 };				//Minimum Infernal Fury cooldown.
static float Fury_MinCDTime[3] = { 2.0, 2.0, 2.0 };				//Maximum duration Infernal Fury can be used and still have the minimum cooldown applied.
static float Fury_CDRaise[3] = { 0.2, 0.2, 0.25 };				//Amount to increase Infernal Fury's cooldown per 0.1s of usage past the minimum CD window.
static float Fury_MaxCD[3] = { 80.0, 80.0, 80.0 };			//Maximum cooldown applied to Infernal Fury.
static float Fury_CDR[3] = { 2.0, 2.0, 1.0 };					//Amount to reduce Infernal Fury's remaining cooldown upon killing a zombie while Infernal Fury is not active.
static float Fury_MedicHealMultiplier[3] = { 0.33, 0.33, 0.165 };	//Amount to multiply healing received from outside sources during Infernal Fury.

//WRATH STRIKE: If enabled: Infernal Fury now charges up a powerful melee hit, which is given when Infernal Fury ends.
//The longer Infernal Fury is active, the stronger this attack becomes.
static bool Wrath_Enabled[3] = { false, false, true };			//Is Wrath Strike enabled on this PaP tier?
static float Wrath_MinStrength[3] = { 2.0, 2.0, 2.0 };			//The minimum possible melee damage multiplier of the Wrath Strike hit.
static float Wrath_Rise[3] = { 0.2, 0.2, 0.2 };					//Amount to increase Wrath Strike's damage multiplier per 0.1s of Infernal Fury's use-time, after the MinStrengthTime has passed.
static float Wrath_MaxStrength[3] = { 8.0, 8.0, 12.0 };			//Maximum melee damage multiplier.
static float Wrath_Width[3] = { 60.0, 60.0, 80.0 };				//Wrath Strike hitbox width.
static float Wrath_Length[3] = { 120.0, 120.0, 160.0 };			//Wrath Strike hitbox length.
static float Wrath_MultiHitFalloff[3] = { 0.75, 0.75, 0.75 };	//Amount to multiply damage dealt by Wrath Strike per enemy hit.
static float Wrath_Delay[3] = { 0.66, 0.66, 0.66 };				//Delay after ending Infernal Fury before Wrath Strike can be used, to prevent accidental usage.
static int Wrath_MaxTargets[3] = { 4, 4, 8 };					//Max targets hit at once by Wrath Strike.

//GENERAL: Miscellaneous extra stats.
static float Fury_BurningTargetsMultiplier[3] = { 1.35, 1.35, 1.35 };	//Amount to multiply melee damage dealt to burning targets (Wrath Strike does NOT benefit from this).

//Client/entity-specific global variables below, don't touch these:
static bool Wrath_Active[MAXPLAYERS + 1] = { false, ... };
static bool Fury_Active[MAXPLAYERS + 1] = { false, ... };
static bool Fury_WasHitByAOE[2049][MAXPLAYERS + 1];
static bool WrathStrike_WasHit[2049][MAXPLAYERS + 1];
static float Wrath_Multiplier[MAXPLAYERS + 1] = { 1.0, ... };
static float Fury_StoredHealth[MAXPLAYERS + 1] = { 0.0, ... };
static float Fury_CurrentHealthDrain[MAXPLAYERS + 1] = { 0.0, ... };
static float Fury_StartTime[MAXPLAYERS + 1] = { 0.0, ... };
static float Fury_DamagedAt[MAXPLAYERS + 1] = { 0.0, ... };
static float Fury_NextRing[MAXPLAYERS + 1] = { 0.0, ... };
static int Fury_Tier[MAXPLAYERS + 1] = { 0, ... };
static int Fury_Weapon[MAXPLAYERS + 1] = { -1, ... };
static float ability_cooldown[MAXPLAYERS + 1] = {0.0, ...};

static int Beam_Laser;
static int Beam_Glow;

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
#define SND_WRATH_SHOUT_NIKO			")npc/stalker/go_alert2a.wav"
#define SND_WRATH_BEGIN					")ambient_mp3/halloween/male_scream_14.mp3"
#define SND_WRATH_LOOP					")misc/doomsday_cap_spin_loop.wav"
#define SND_WRATH_END					")player/flame_out.wav"
#define SND_WRATHSTRIKE_ACTIVATE		")mvm/mvm_tele_activate.wav"
#define SND_WRATHSTRIKE_FULLYCHARGED	"mvm/mvm_tank_horn.wav"
#define SND_WRATHSTRIKE_SMASH			")mvm/mvm_tank_smash.wav"
#define SND_WRATHSTRIKE_SMASH_2			")mvm/giant_soldier/giant_soldier_explode.wav"
#define SND_WRATHSTRIKE_SWING			")misc/halloween/strongman_fast_whoosh_01.wav"

#define FURY_AURA						"burningplayer_corpse"
#define FURY_RINGS						"heavy_ring_of_fire"
#define WRATH_OBLITERATED				"hammer_impact_button_dust"

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
	PrecacheSound(SND_WRATHSTRIKE_SMASH_2);
	PrecacheSound(SND_WRATHSTRIKE_SWING);

	Beam_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	Beam_Glow = PrecacheModel("sprites/glow02.vmt", true);
}

float Player_OnTakeDamage_WrathfulBlade(int victim, float &damage)
{
	if (Fury_Active[victim]/* && attacker != 0*/)
	{
		damage *= Fury_ResMult[Fury_Tier[victim]];
	}
	if(!CheckInHud())
		Fury_DamagedAt[victim] = GetGameTime() + 3.0;

	return damage;
}

void WrathfulBlade_OnKill(int client, int victim)
{
	if (Fury_Active[client])
	{
		Fury_StoredHealth[client] += Fury_HealPerKill[Fury_Tier[client]];
	}
	else
	{
		float cd = Ability_Check_Cooldown(client, 2);
		cd -= Fury_CDR[Fury_Tier[client]];
		Ability_Apply_Cooldown(client, 2, cd);
	}

	for (int i = 1; i <= MaxClients; i++)
		Fury_WasHitByAOE[victim][i] = false;
}

public float WrathfulBlade_OnNPCDamaged(int victim, int attacker, int weapon, float damage, int inflictor)
{
	bool isMelee = weapon == GetPlayerWeaponSlot(attacker, 2) && !Fury_WasHitByAOE[victim][attacker];

	if (isMelee)
	{
		if (Fury_Active[attacker])
		{
			damage *= Fury_DMGMult[Fury_Tier[attacker]];
		}

		if (WrathStrike_WasHit[victim][attacker])
		{
			WrathStrike_WasHit[victim][attacker] = false;
		}
		else if (IgniteFor[victim] > 0)
		{
			damage *= Fury_BurningTargetsMultiplier[Fury_Tier[attacker]];
			DisplayCritAboveNpc(victim, attacker, true, _, _, Fury_BurningTargetsMultiplier[Fury_Tier[attacker]] < 3.0);
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
			
			if (Wrath_Active[client])
			{
				Format(HUDText, sizeof(HUDText), "WRATH STRIKE IS READY: %.2fx MELEE DAMAGE", Wrath_Multiplier[client]);
			}
			else if (Fury_Active[client])
			{
				Format(HUDText, sizeof(HUDText), "INFERNAL FURY: ACTIVE");
				if (Wrath_Enabled[Fury_Tier[client]])
				{
					Format(HUDText, sizeof(HUDText), "%s\nCHARGING WRATH STRIKE: %.2f", HUDText, Wrath_Multiplier[client] / Wrath_MaxStrength[Fury_Tier[client]]);
					if (Wrath_Multiplier[client] >= Wrath_MaxStrength[Fury_Tier[client]])
						Format(HUDText, sizeof(HUDText), "%s (MAX)", HUDText);
				}
			}

			if (Fury_StoredHealth[client] > 0.0 || Fury_Active[client])
			{
				Format(HUDText, sizeof(HUDText), "%s\nHEALTH STORED: %i", HUDText, RoundFloat(Fury_StoredHealth[client]));
				if (Fury_StoredHealth[client] >= Fury_MaxHeals[Fury_Tier[client]])
					Format(HUDText, sizeof(HUDText), "%s (MAX)", HUDText);
			}

			if (Fury_StoredHealth[client] > 0.0 && !Fury_Active[client])
				Format(HUDText, sizeof(HUDText), "%s\n(Stored health is lost upon activating Infernal Fury or being downed.)", HUDText);

			PrintHintText(client, HUDText);

			
		}

		f_NextWrathHUD[client] = GetGameTime() + 0.5;
	}
}

public void Fury_Attack(int client, int weapon, bool crit)
{
	if (Fury_Active[client])
	{
		RequestFrame(Fury_AdjustAttackSpeed, GetClientUserId(client));
	}
	else if (Wrath_Active[client])
	{
		DataPack pack = new DataPack();
		CreateDataTimer(0.2, Wrath_MeleeAttack, pack, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, GetClientUserId(client));
		WritePackCell(pack, EntIndexToEntRef(weapon));
		EmitSoundToAll(SND_WRATHSTRIKE_SWING, client, _, _, _, _, 80);
		EmitSoundToAll(SND_WRATHSTRIKE_SWING, client, _, _, _, _, 80);
		Wrath_Active[client] = false;
	}
}

static bool Wrath_Hit[2049] = { false, ... };

public Action Wrath_MeleeAttack(Handle timelytimer, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int weapon = EntRefToEntIndex(ReadPackCell(pack));

	if (!IsValidClient(client) || !IsValidEntity(weapon))
		return Plugin_Continue;

	if (!IsPlayerAlive(client))
		return Plugin_Continue;

	b_LagCompNPC_ExtendBoundingBox = true;
	StartLagCompensation_Base_Boss(client);

	float pos[3], ang[3], endPos[3], hullMin[3], hullMax[3], direction[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);

	float width = Wrath_Width[Fury_Tier[client]];
	float length = Wrath_Length[Fury_Tier[client]];

	width *= Attributes_Get(weapon, 263, 1.0);
	length *= Attributes_Get(weapon, 264, 1.0);

	hullMin[0] = -width;
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];

	GetAngleVectors(ang, direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(direction, length);
	AddVectors(pos, direction, endPos);

	TR_TraceHullFilter(pos, endPos, hullMin, hullMax, 1073741824, Wrath_Trace, client);

	float baseDMG = 65.0 * Wrath_Multiplier[client]; 
	baseDMG *= Attributes_Get(weapon, 2, 1.0);
	baseDMG *= Attributes_Get(weapon, 1, 1.0);
//	baseDMG *= Attributes_Get(weapon, 1000, 1.0);
			 
	ArrayList victims = new ArrayList(255);

	for (int victim = 1; victim < MAXENTITIES; victim++)
	{
		if (Wrath_Hit[victim])
		{
			Wrath_Hit[victim] = false;

			if (IsValidEnemy(client, victim))
			{
				PushArrayCell(victims, victim);
			}
		}
	}

	if (GetArraySize(victims) > 0)
	{
		int count = Wrath_MaxTargets[Fury_Tier[client]];
		if (count > GetArraySize(victims))
			count = GetArraySize(victims);

		ArrayList ordered = new ArrayList();

		while (GetArraySize(ordered) < count)
		{
			int closest = BigShot_GetClosestInList(pos, victims);
			PushArrayCell(ordered, closest);
		}

		float vecSwingForward[3];
		GetAngleVectors(ang, vecSwingForward, NULL_VECTOR, NULL_VECTOR);

		for (int i = 0; i < GetArraySize(ordered); i++)
		{
			int victim = GetArrayCell(ordered, i);
			if (IsValidEnemy(client, victim))
			{
				float damagePos[3], damageForce[3]; 
				WorldSpaceCenter(victim, damagePos);
				CalculateDamageForce(vecSwingForward, 100000.0, damageForce);

				WrathStrike_WasHit[victim][client] = true;
				SDKHooks_TakeDamage(victim, client, client, baseDMG, DMG_CLUB|DMG_ALWAYSGIB, weapon, damageForce, damagePos);
				baseDMG *= Wrath_MultiHitFalloff[Fury_Tier[client]];

				ParticleEffectAt(damagePos, WRATH_OBLITERATED, 2.0);
			}
		}

		EmitSoundToAll(SND_WRATHSTRIKE_SMASH, client, _, _, _, 0.8);
		EmitSoundToAll(SND_WRATHSTRIKE_SMASH_2, client, _, _, _, 0.8);
		EmitSoundToAll(SND_WRATHSTRIKE_SMASH, client, _, _, _, 0.8);
		EmitSoundToAll(SND_WRATHSTRIKE_SMASH_2, client, _, _, _, 0.8);
    
		Client_Shake(client);

		delete ordered;
	}

	delete victims;
	FinishLagCompensation_Base_boss();

	return Plugin_Continue;
}

public bool Wrath_Trace(int entity, int contentsMask, int user)
{
	if (IsEntityAlive(entity) && entity != user)
		Wrath_Hit[entity] = true;
	
	return false;
}

public void Fury_AdjustAttackSpeed(int id)
{
	int client = GetClientOfUserId(id);

	if (!IsValidClient(client))
		return;

	if (!IsPlayerAlive(client))
		return;

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); 

	if (i_CustomWeaponEquipLogic[weapon] != WEAPON_WRATHFUL_BLADE)
		return;

	float nextAttack = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack");
	float gt = GetGameTime();
	float delay = (nextAttack - gt) / Fury_ATKSpeed[Fury_Tier[client]];
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", gt + delay);
}

public void Fury_Activated_PaP1(int client, int weapon, bool crit)
{
	Fury_AttemptUse(client, weapon, crit, 0);
}

public void Fury_Activated_PaP2(int client, int weapon, bool crit)
{
	Fury_AttemptUse(client, weapon, crit, 1);
}

public void Fury_Activated_PaP3(int client, int weapon, bool crit)
{
	Fury_AttemptUse(client, weapon, crit, 2);
}

public void Fury_AttemptUse(int client, int weapon, bool crit, int tier)
{
	if (Ability_Check_Cooldown(client, 2) > 0.0)
	{
		float Ability_CD = Ability_Check_Cooldown(client, 2);
				
		if(Ability_CD <= 0.0)
		Ability_CD = 0.0;
				
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Wrathful Ability Cooldown", Ability_CD);
	}
	else if (Fury_Active[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Wrathful Ability Blocked");
	}
	else
	{
		Fury_Active[client] = true;
		Fury_StoredHealth[client] = 0.0;
		Wrath_HUD(client, weapon, true);
		Fury_Tier[client] = tier;
		Fury_StartTime[client] = GetGameTime();
		Fury_Weapon[client] = EntIndexToEntRef(weapon);
		Fury_CurrentHealthDrain[client] = Fury_HPDrain_Base[tier];
		Wrath_Active[client] = false;
		Wrath_Multiplier[client] = 1.0;

		CreateTimer(0.1, Fury_Logic, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

		Fury_Shout(client);
		EmitSoundToAll(SND_WRATH_BEGIN, client);
		EmitSoundToAll(SND_WRATH_LOOP, client, _, 80, _, 0.7, 70);

		float pos[3];
		GetClientAbsOrigin(client, pos);
		ParticleEffectAt(pos, FURY_RINGS, 1.0);
		Fury_NextRing[client] = GetGameTime() + 1.0;
		Client_Shake(client, _, 25.0, 100.0, 3.0);

		TE_SetupParticleEffect(FURY_AURA, PATTACH_ABSORIGIN_FOLLOW, client);
		TE_WriteNum("m_bControlPoint1", client);	
		TE_SendToAll();
	}
}

public Action Fury_Logic(Handle timelytimer, int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidClient(client))
		return Plugin_Stop;

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); 
	if (!IsValidEntity(weapon))
	{
		Fury_TerminateEffects(client);
		return Plugin_Stop;
	}

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

		if (Fury_StoredHealth[client] > 0.0)
		{
			CreateTimer(0.1, Fury_HealingTimer, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}

		if (hasWrath)
		{
			CreateTimer(Wrath_Delay[tier], Wrath_Activate, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);

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
	//	DMG *= Attributes_Get(weapon, 1000, 1.0);

		float pos[3];
		WorldSpaceCenter(client, pos);

		Explode_Logic_Custom(DMG, client, client, weapon, pos, Fury_BurnRadius[tier], Fury_BurnFalloff[tier], _, _, Fury_BurnMaxTargets[tier], true, 1.0, _, view_as<Function>(Fury_AOEHit));

		for (int i = 0; i <= MaxClients; i++)
		{
			Fury_WasHitByAOE[i][client] = false;
		}

		GetClientAbsOrigin(client, pos);
		TE_SetupBeamRingPoint(pos, Fury_BurnRadius[tier] * 2.0, Fury_BurnRadius[tier] * 2.0 + 0.5, Beam_Laser, Beam_Glow, 0, 10, 0.11, 25.0, 2.0, {255, 120, 0, 250}, 10, 0);
		TE_SendToAll(0.0);
		if (GetGameTime() >= Fury_NextRing[client])
		{
			ParticleEffectAt(pos, FURY_RINGS, 1.0);
			Fury_NextRing[client] = GetGameTime() + 1.0;
		}

		if (hasWrath && Wrath_Multiplier[client] < Wrath_MaxStrength[tier])
		{
			Wrath_Multiplier[client] += Wrath_Rise[tier];
			if (Wrath_Multiplier[client] >= Wrath_MaxStrength[tier])
			{
				EmitSoundToClient(client, SND_WRATHSTRIKE_FULLYCHARGED);
				EmitSoundToClient(client, SND_WRATHSTRIKE_FULLYCHARGED);
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Wrath Strike Fully Charged");
				Wrath_Multiplier[client] = Wrath_MaxStrength[tier];
			}
		}

		float dmgToTake = Fury_CurrentHealthDrain[client];
		if (IsInvuln(client))
			dmgToTake *= Fury_HPDrain_UberMult[Fury_Tier[client]];

		int currentHP = GetEntProp(client, Prop_Data, "m_iHealth");
		if (RoundFloat(dmgToTake) >= currentHP)
		{
			if (IsInvuln(client))
				SetEntProp(client, Prop_Data, "m_iHealth", 1);
			else
			{
				Fury_TerminateEffects(client);
				DealTruedamageToEnemy(0, client, dmgToTake);
			}
		}
		else
		{
			SetEntProp(client, Prop_Data, "m_iHealth", currentHP - RoundFloat(dmgToTake));
			if (Fury_CurrentHealthDrain[client] < Fury_HPDrain_Max[tier])
			{
				Fury_CurrentHealthDrain[client] += Fury_HPDrain_Rise[tier] * 0.1;
				if (Fury_CurrentHealthDrain[client] > Fury_HPDrain_Max[tier])
					Fury_CurrentHealthDrain[client] = Fury_HPDrain_Max[tier];
			}
		}
    
		ApplyTempAttrib(weapon, 734, Fury_MedicHealMultiplier[tier], 0.1);
	}

	return Plugin_Continue;
}

public Action Wrath_Activate(Handle timer, int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidClient(client))
		return Plugin_Continue;
	if (!IsPlayerAlive(client))
		return Plugin_Continue;

	Wrath_Active[client] = true;
	EmitSoundToAll(SND_WRATHSTRIKE_ACTIVATE, client, _, _, _, _, 80);

	return Plugin_Continue;
}

public void Fury_AOEHit(int attacker, int victim, float damage, int weapon)
{
	Fury_WasHitByAOE[victim][attacker] = true;
}

public Action Fury_HealingTimer(Handle timelytimer, int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidClient(client))
		return Plugin_Stop;

	if (dieingstate[client] > 0 /*|| i_CustomWeaponEquipLogic[weapon] != WEAPON_WRATHFUL_BLADE*/ || !IsPlayerAlive(client) || Fury_Active[client])
	{
		Fury_StoredHealth[client] = 0.0;
		return Plugin_Stop;
	}

	int amtHealed = HealEntityGlobal(client, client, GetGameTime() <= Fury_DamagedAt[client] ? Fury_HealRate_Penalty[Fury_Tier[client]] : Fury_HealRate[Fury_Tier[client]]);
	if (amtHealed > 0)
	{
		Fury_StoredHealth[client] -= float(amtHealed);
		if (Fury_StoredHealth[client] <= 0.0)
		{
			Fury_StoredHealth[client] = 0.0;
			return Plugin_Stop;
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

	Ability_Apply_Cooldown(client, 2, cd, EntRefToEntIndex(Fury_Weapon[client]));
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