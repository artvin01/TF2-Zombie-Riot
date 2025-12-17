#pragma semicolon 1
#pragma newdecls required

//As per usual, I'm using arrays for stats on different pap levels. First entry is pap1, then pap2, etc.
//There is no pap0 entry for this weapon because it doesn't do anything which requires a plugin on pap0.

static int BigShot_MaxTargets[2] = { 4, 7 };						//The maximum number of zombies penetrated by the big shot.
static int BigShot_BrainBlastMaxTargets[2] = { 0, 15 };				//The maximum number of zombies hit by Brain Blast explosions (Brain Blast: if the M2 headshots at least one zombie, trigger an explosion on the last zombie in the penetration chain, which gets stronger for every headshot in the chain.).

static float BigShot_BaseDMG[2] = { 12.0,  15.0 };					//Base Big Shot damage. Note that this gets multiplied by the weapon's damage attribute. The Rusty Rifle's M1 base damage before attributes is 6.0, so this should be set relative to that.
static float BigShot_PerHeadshotMult[2] = { 1.1, 1.12 };			//Amount to multiply the damage dealt to zombies in the penetration chain for each zombie before them in the chain which was headshot.
static float BigShot_PerBodyshotMult[2] = { 0.66, 0.8 };			//Amount to multiply the damage dealt to zombies in the penetration chain for each zombie before them in the chain which was bodyshot. This is ignored for zombies which are headshot.
static float BigShot_BrainBlastDMG[2] = { 0.0, 1000.0 };			//The base damage of Brain Blast.
static float BigShot_BrainBlastBonus[2] = { 0.0, 500.0 };			//Amount to increase Brain Blast explosion damage for every zombie in the chain past 1.
static float BigShot_BrainBlastRadius[2] = { 0.0, 400.0 };			//The blast radius of blain blast.
static float BigShot_BrainBlastFalloff_Radius[2] = { 0.0, 0.5 };	//Maximum damage faloff of Brain Blast, based on radius.
static float BigShot_BrainBlastFalloff_MultiHit[2] = { 0.0, 0.8 };	//Amount to multiply damage dealt by Brain Blast for each zombie it hits.
static float BigShot_Cooldown[2] = { 15.0, 15.0 };					//Big Shot's cooldown.

static bool BigShot_BrainBlast[2] = { false, true };				//Is Brain Blast active on this pap tier?

static float Rusty_RaidMult = 1.4;

//Client/entity-specific global variables below, don't touch these:
static bool BigShot_Active[MAXPLAYERS + 1] = { false, ... };
static bool BigShot_Hit[2049] = { false, ... };
static int BigShot_Tier[MAXPLAYERS + 1] = { false, ... };
static float ability_cooldown[MAXPLAYERS + 1] = {0.0, ...};

public void Rusty_Rifle_ResetAll()
{
	for (int i = 0; i <= MaxClients; i++)
		BigShot_Active[i] = false;

	Zero(ability_cooldown);
}

#define SND_RUSTY_BIGSHOT_PREPARE	")player/taunt_rocket_hover_start.wav"
#define SND_RUSTY_BIGSHOT		")mvm/giant_soldier/giant_soldier_rocket_shoot_crit.wav"
#define SND_RUSTY_BIGSHOT_2		")mvm/giant_common/giant_common_explodes_01.wav"
#define SND_RUSTY_BRAINBLAST	")mvm/giant_soldier/giant_soldier_explode.wav"

#define PARTICLE_BRAINBLAST_1		"drg_cow_explosioncore_charged"
#define PARTICLE_BRAINBLAST_2		"drg_cow_explosioncore_charged_blue"
#define PARTICLE_BIGSHOT_TRACER_1	"dxhr_sniper_rail_red"
#define PARTICLE_BIGSHOT_TRACER_2	"dxhr_sniper_rail_blue"

void Rusty_Rifle_Precache()
{
	PrecacheSound(SND_RUSTY_BIGSHOT_PREPARE);
	PrecacheSound(SND_RUSTY_BIGSHOT);
	PrecacheSound(SND_RUSTY_BIGSHOT_2);
	PrecacheSound(SND_RUSTY_BRAINBLAST);
}

Handle Timer_Rusty[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };
static float f_NextRustyHUD[MAXPLAYERS + 1] = { 0.0, ... };

public float Rusty_OnNPCDamaged(int victim, int attacker, float damage)
{
	if (b_thisNpcIsARaid[victim])
	{
		damage *= Rusty_RaidMult;
		//Hard to hit non giant raids!
		if(!b_IsGiant[victim])
			damage *= 1.1;
	}

	return damage;
}

public void Enable_Rusty_Rifle(int client, int weapon)
{
	if (Timer_Rusty[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_RUSTY_RIFLE)
		{
			delete Timer_Rusty[client];
			Timer_Rusty[client] = null;
			DataPack pack;
			Timer_Rusty[client] = CreateDataTimer(0.1, Timer_RustyControl, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_RUSTY_RIFLE)
	{
		DataPack pack;
		Timer_Rusty[client] = CreateDataTimer(0.1, Timer_RustyControl, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		f_NextRustyHUD[client] = 0.0;
	}
}

public Action Timer_RustyControl(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Timer_Rusty[client] = null;
		return Plugin_Stop;
	}	

	Rusty_HUD(client, weapon, false);

	return Plugin_Continue;
}

public void Rusty_HUD(int client, int weapon, bool forced)
{
	if(f_NextRustyHUD[client] < GetGameTime() || forced)
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		if(weapon_holding == weapon)
		{
			if (BigShot_Active[client])
				PrintHintText(client, "빅 샷 장전됨: 발사하세요!");
			else
				PrintHintText(client, "빅 샷 장전 대기중...");
			
			
		}

		f_NextRustyHUD[client] = GetGameTime() + 0.5;
	}
}

public void Weapon_Rusty_Rifle_Fire(int client, int weapon, bool crit)
{
	if (!BigShot_Active[client])
		return;

	
	b_LagCompNPC_ExtendBoundingBox = true;
	StartLagCompensation_Base_Boss(client);

	float pos[3], ang[3], endPos[3], hullMin[3], hullMax[3], direction[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);

	hullMin[0] = -1.0;		//Very small bounds to mimic actual hitscan.
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];
	Zero(BigShot_Hit);

	GetAngleVectors(ang, direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(direction, 9999.0);
	AddVectors(pos, direction, endPos);

	TR_TraceHullFilter(pos, endPos, hullMin, hullMax, 1073741824, BigShot_Trace, client);

	float baseDMG = BigShot_BaseDMG[BigShot_Tier[client]] * Attributes_Get(weapon, 2, 1.0);
	float penalizedDMG = baseDMG;
			 
	ArrayList victims = new ArrayList(255);

	for (int victim = 1; victim < MAXENTITIES; victim++)
	{
		if (BigShot_Hit[victim])
		{
			BigShot_Hit[victim] = false;

			if (IsValidEnemy(client, victim))
			{
				PushArrayCell(victims, victim);
			}
		}
	}

	if (GetArraySize(victims) > 0)
	{
		int count = BigShot_MaxTargets[BigShot_Tier[client]];
		if (count > GetArraySize(victims))
			count = GetArraySize(victims);

		ArrayList ordered = new ArrayList();

		while (GetArraySize(ordered) < count)
		{
			int closest = BigShot_GetClosestInList(pos, victims);
			PushArrayCell(ordered, closest);
		}

		int numHeadshots = 0;
		for (int i = 0; i < GetArraySize(ordered); i++)
		{
			int victim = GetArrayCell(ordered, i);
			if (IsValidEnemy(client, victim))
			{
				bool headshot = false;

				float vicLoc[3], hitPos[3];
				WorldSpaceCenter(victim, vicLoc);

				Handle trace = TR_TraceRayFilterEx(pos, endPos, MASK_SHOT, RayType_EndPoint, BulletAndMeleeTrace, client);
				if (TR_GetFraction(trace) < 1.0)
				{
					int target = TR_GetEntityIndex(trace);
					if (target > 0)
					{
						headshot = (TR_GetHitGroup(trace) == HITGROUP_HEAD && !b_CannotBeHeadshot[victim]);
						TR_GetEndPosition(hitPos, trace);
					}
				}
				delete trace;

				if (headshot)
				{
					DisplayCritAboveNpc(victim, client, true);

					float dmg = baseDMG;

					if(i_HeadshotAffinity[client] == 1)
					{
						dmg *= 2.0;
					}
					else
					{
						dmg *= 1.65;
					}
					
					if(i_CurrentEquippedPerk[client] & PERK_MARKSMAN_BEER)
					{
						dmg *= 1.25;
					}

					SDKHooks_TakeDamage(victim, client, client, dmg, DMG_BULLET, weapon, NULL_VECTOR, vicLoc);
					baseDMG *= BigShot_PerHeadshotMult[BigShot_Tier[client]];
					numHeadshots++;
				}
				else
				{
					float dmg = penalizedDMG;

					if(i_HeadshotAffinity[client] == 1)
					{
						dmg *= 0.75;
					}
            
					SDKHooks_TakeDamage(victim, client, client, dmg, DMG_BULLET, weapon, NULL_VECTOR, vicLoc);
				}

				penalizedDMG *= BigShot_PerBodyshotMult[BigShot_Tier[client]];

				if (i == GetArraySize(ordered) - 1)
				{
					float userLoc[3];
					WorldSpaceCenter(client, userLoc);
					ConstrainDistance(pos, endPos, GetVectorDistance(pos, endPos), GetVectorDistance(userLoc, vicLoc), true);
					BigShot_SpawnTracer(client, weapon, endPos);

					if (numHeadshots > 0 && BigShot_BrainBlast[BigShot_Tier[client]])
					{
						ParticleEffectAt(hitPos, BigShot_Tier[client] == 0 ? PARTICLE_BRAINBLAST_1 : PARTICLE_BRAINBLAST_2);
						EmitSoundToAll(SND_RUSTY_BRAINBLAST, victim, _, 120);
						EmitSoundToAll(SND_RUSTY_BRAINBLAST, victim, _, 120);

						EmitSoundToClient(client, SND_RUSTY_BRAINBLAST);
						float blastDMG = BigShot_BrainBlastDMG[BigShot_Tier[client]] + ((float(numHeadshots) - 1.0) * BigShot_BrainBlastBonus[BigShot_Tier[client]]);
						Explode_Logic_Custom(blastDMG, client, client, weapon, vicLoc, BigShot_BrainBlastRadius[BigShot_Tier[client]], BigShot_BrainBlastFalloff_MultiHit[BigShot_Tier[client]], BigShot_BrainBlastFalloff_Radius[BigShot_Tier[client]], false, BigShot_BrainBlastMaxTargets[BigShot_Tier[client]], false, 1.0);
					}
				}
			}
		}

		delete ordered;
	}
	else
	{
		BigShot_SpawnTracer(client, weapon, endPos);
	}

	delete victims;

	BigShot_Active[client] = false;
	SetForceButtonState(client, false, IN_ATTACK);
	EmitSoundToAll(SND_RUSTY_BIGSHOT, client);
	EmitSoundToAll(SND_RUSTY_BIGSHOT_2, client, _, _, _, _, 80);
	Client_Shake(client, SHAKE_START, 30.0, 150.0, 1.25);
	Rusty_HUD(client, weapon, true);
	//doesnt matter which tier, same cooldown
	Ability_Apply_Cooldown(client, 2, BigShot_Cooldown[1]);

	RequestFrame(BigShot_RevertAttribs, EntIndexToEntRef(weapon));
	FinishLagCompensation_Base_boss();
}

public void BigShot_SpawnTracer(int client, int weapon, float endPos[3])
{
	float pos[3];
	GetClientEyePosition(client, pos);
	pos[2] -= 15.0;

	ShootLaser(weapon, BigShot_Tier[client] == 0 ? PARTICLE_BIGSHOT_TRACER_1 : PARTICLE_BIGSHOT_TRACER_2, pos, endPos);
}

public int BigShot_GetClosestInList(float pos[3], ArrayList &victims)
{
	int closestSlot = 0;
	int closestVic = 0;
	float closestDist = 99999999.0;

	for (int i = 0; i < GetArraySize(victims); i++)
	{
		int victim = GetArrayCell(victims, i);
		float vicPos[3];
		WorldSpaceCenter(victim, vicPos);

		float dist = GetVectorDistance(pos, vicPos);
		if (dist < closestDist)
		{
			closestVic = victim;
			closestDist = dist;
			closestSlot = i;
		}
	}

	RemoveFromArray(victims, closestSlot);

	return closestVic;
}

public bool BigShot_Trace(int entity, int contentsMask, int user)
{
	if (IsEntityAlive(entity) && entity != user)
		BigShot_Hit[entity] = true;
	
	return false;
}

public void BigShot_RevertAttribs(int ref)
{
	int weapon = EntRefToEntIndex(ref);
	if (!IsValidEntity(weapon))
		return;

	Attributes_Set(weapon, 305, 0.0);
	Attributes_Set(weapon, 45, 0.1);
	Attributes_SetMulti(weapon, 4014, 0.25);
}

public void BigShot_RemoveForcedReload(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidClient(client))
		return;

	SetForceButtonState(client, false, IN_RELOAD);
}

public void Weapon_Rusty_Rifle_BigShot_Pap1(int client, int weapon, bool crit)
{
	BigShot_AttemptUse(client, weapon, crit, 0);
}

public void Weapon_Rusty_Rifle_BigShot_Pap2(int client, int weapon, bool crit)
{
	BigShot_AttemptUse(client, weapon, crit, 1);
}

public void BigShot_AttemptUse(int client, int weapon, bool crit, int tier)
{
	if (Ability_Check_Cooldown(client, 2) < 0.0)
	{
		float nextAttack = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack");
		if (GetGameTime() < nextAttack || BigShot_Active[client])
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Rusty Ability Blocked");
		}
		else
		{
			Attributes_Set(weapon, 305, 1.0);
			Attributes_Set(weapon, 45, 0.0);
			Attributes_SetMulti(weapon, 4014, 4.0);

			SetEntProp(weapon, Prop_Data, "m_iClip1", 0);
			SetForceButtonState(client, true, IN_RELOAD);
			RequestFrame(BigShot_RemoveForcedReload, GetClientUserId(client));
			EmitSoundToAll(SND_RUSTY_BIGSHOT_PREPARE, client);
			Rogue_OnAbilityUse(client, weapon);
			BigShot_Active[client] = true;
			BigShot_Tier[client] = tier;
			Rusty_HUD(client, weapon, true);
		}
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, 2);
				
		if(Ability_CD <= 0.0)
		Ability_CD = 0.0;
				
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Rusty Ability Cooldown", Ability_CD);
	}
}