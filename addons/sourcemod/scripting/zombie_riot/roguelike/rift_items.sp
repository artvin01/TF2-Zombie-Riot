#pragma semicolon 1
#pragma newdecls required

static int PreviousFloor;
static int PreviousStage;
static bool HolyBlessing;
static bool VialityThing;
static bool FlashVestThing;

stock bool Rogue_Rift_HolyBlessing()
{
	return HolyBlessing;
}
stock bool Rogue_Rift_VialityThing()
{
	return VialityThing;
}
#define DOWNED_STUN_RANGE 200.0
stock void Rogue_Rift_FlashVest_StunEnemies(int victim)
{
	if(!Rogue_Rift_FlashVestThing())
		return;
	Explode_Logic_Custom(0.0, victim, victim, -1, _, DOWNED_STUN_RANGE, 1.0, _, _, 99,_,_,_,Viality_Stunenemy);
}

float Viality_Stunenemy(int entity, int victim, float damage, int weapon)
{
	FreezeNpcInTime(victim, 1.5);	
	return 0.0;
}
stock bool Rogue_Rift_FlashVestThing()
{
	return FlashVestThing;
}
public void Rogue_GamemodeHistory_Collect()
{
	PreviousFloor = -1;
	int floor = Rogue_GetFloor();
	int stage = Rogue_GetStage();

	Rogue_SendToFloor(6, -1);

	PreviousFloor = floor;
	PreviousStage = stage;
}

public void Rogue_GamemodeHistory_FloorChange(int &floor, int &stage)
{
	if(PreviousFloor == -1)
		return;
	
	// Send them back to where they were
	floor = PreviousFloor;
	stage = PreviousStage;
	Rogue_RemoveNamedArtifact("Gamemode History");
}

public void Rogue_GamemodeHistory_StageEnd(bool &victory)
{
	if(!victory)
	{
		// They lost, send them back
		victory = true;
		Rogue_RemoveNamedArtifact("Gamemode History");
		Rogue_SendToFloor(PreviousFloor, PreviousStage, false);
	}
}

public void Rogue_PoisonWater_Ally(int entity, StringMap map)
{
	RogueHelp_BodyHealth(entity, map, 0.8);
}

public void Rogue_PoisonWater_FloorChange(int &floor, int &stage)
{
	if(floor > 1)
		Rogue_RemoveNamedArtifact("Poisoned Water");
}

public void Rogue_HolyBlessing_Collect()
{
	HolyBlessing = true;
}

public void Rogue_HolyBlessing_Remove()
{
	HolyBlessing = false;
}
public void Rogue_Vitality_Injection_Collect()
{
	VialityThing = true;
}

public void Rogue_Vitality_Injection_Remove()
{
	VialityThing = false;
}
public void Rogue_FlashVest_Collect()
{
	FlashVestThing = true;
}

public void Rogue_FlashVest_Remove()
{
	FlashVestThing = false;
}

public void Rogue_Mazeat1_Enemy(int entity)
{
	if(view_as<CClotBody>(entity).m_iBleedType != BLEEDTYPE_VOID && view_as<CClotBody>(entity).m_iBleedType != BLEEDTYPE_UMBRAL)
	{
		RogueHelp_BodyHealth(entity, null, 0.85);
		fl_Extra_Damage[entity] *= 0.85;
	}
}

public void Rogue_Mazeat2_Enemy(int entity)
{
	if(view_as<CClotBody>(entity).m_iBleedType != BLEEDTYPE_VOID && view_as<CClotBody>(entity).m_iBleedType != BLEEDTYPE_UMBRAL)
	{
		fl_Extra_Speed[entity] *= 0.9;
	}
}

public void Rogue_Mazeat3_Enemy(int entity)
{
	if(view_as<CClotBody>(entity).m_iBleedType != BLEEDTYPE_VOID && view_as<CClotBody>(entity).m_iBleedType != BLEEDTYPE_UMBRAL)
	{
		RogueHelp_BodyHealth(entity, null, 0.7);
		fl_Extra_Damage[entity] *= 0.7;

		for(int i; i < Element_MAX; i++)
		{
			float res = GetEntPropFloat(entity, Prop_Data, "m_flElementRes");
			if(res >= 1.0)
				continue;
			
			SetEntPropFloat(entity, Prop_Data, "m_flElementRes", res - 1.0);
		}
	}
}

public void Rogue_Umbral15_Collect()
{
	Rogue_AddUmbral(15, true);
}

public void Rogue_Stone3_Collect()
{
	for(int i; i < 3; i++)
	{
		Artifact artifact;
		if(Rogue_GetRandomArtifact(artifact, true, 6) != -1)
			Rogue_GiveNamedArtifact(artifact.Name);
	}
}

public void Rogue_Umbral6_Collect()
{
	Rogue_AddIngots(4, true);
	Rogue_AddUmbral(6, true);
}

public void Rogue_OldFan_Ally(int entity, StringMap map)
{
	RogueHelp_BodyDamage(entity, map, 1.7);
}

public void Rogue_OldFan_Weapon(int entity)
{
	RogueHelp_WeaponDamage(entity, 1.7);
}

public void Rogue_ScoutScope_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
	if(IsValidEntity(attacker) && GetTeam(attacker) == TFTeam_Red)
	{
		if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
		{
			float pos1[3], pos2[3];
			GetEntPropVector(victim, Prop_Data, "m_vecOrigin", pos1);
			GetEntPropVector(attacker, Prop_Data, "m_vecOrigin", pos2);

			static const float MaxDist = 1000000.0;

			float distance = GetVectorDistance(pos1, pos2, true);
			if(distance > MaxDist)
			{
				distance = MaxDist;
				if(attacker && attacker <= MaxClients)
					DisplayCritAboveNpc(victim, attacker, true, _, _, true);
			}
			
			damage += damage * (distance / MaxDist);
		}
	}
}

public void Rogue_LakebedAegis_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
	if(GetTeam(victim) == TFTeam_Red && !(damagetype & DMG_TRUEDAMAGE))
	{
		if(GetEntProp(victim, Prop_Data, "m_iHealth") > ReturnEntityMaxHealth(victim))
			damage *= 0.65;
	}
}

public void Rogue_Woodplate_Revive(int &entity)
{
	HealEntityGlobal(entity, entity, ReturnEntityMaxHealth(entity) / 2.0, 1.0, 2.0, HEAL_ABSOLUTE);
}

public void Rogue_MedicineSticks_WaveStart()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
			VausMagicaGiveShield(client, 2);
	}

	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
		{
			if(GetTeam(entity) == TFTeam_Red)
				VausMagicaGiveShield(entity, 2);
		}
	}
}

public void Rogue_FireRate40_Revive(int &entity)
{
	if(entity > 0 && entity <= MaxClients)
	{
		int weapon, i;
		while(TF2_GetItem(entity, weapon, i))
		{
			if(Attributes_Has(weapon, 6))
				ApplyTempAttrib(weapon, 6, 0.714286, 10.0);
			
			if(Attributes_Has(weapon, 8))
				ApplyTempAttrib(weapon, 6, 1.4, 10.0);
			
			if(Attributes_Has(weapon, 97))
				ApplyTempAttrib(weapon, 97, 0.714286, 10.0);
		}
	}
}

public void Rogue_FireRate70_Revive(int &entity)
{
	if(entity > 0 && entity <= MaxClients)
	{
		int weapon, i;
		while(TF2_GetItem(entity, weapon, i))
		{
			if(Attributes_Has(weapon, 6))
				ApplyTempAttrib(weapon, 6, 0.588235, 10.0);
			
			if(Attributes_Has(weapon, 8))
				ApplyTempAttrib(weapon, 6, 1.7, 10.0);
			
			if(Attributes_Has(weapon, 97))
				ApplyTempAttrib(weapon, 97, 0.588235, 10.0);
		}
	}
}

public void Rogue_Sculpture_Enemy(int entity)
{
	f_AttackSpeedNpcIncrease[entity] *= 1.1;
}

public void Rogue_PainfulHappy_Enemy(int entity)
{
	RogueHelp_BodyHealth(entity, null, 0.85);
	fl_Extra_Speed[entity] /= 1.15;
}

public void Rogue_GravityDefying_Enemy(int entity)
{
	i_NpcWeight[entity] -= 2;
	if(i_NpcWeight[entity] < 0)
		i_NpcWeight[entity] = 0;
}

public void Rogue_Devilbane_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
	if(attacker > 0 && attacker <= MaxClients && IsValidEntity(weapon))
	{
		if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
		{
			Saga_ChargeReduction(attacker, weapon, 2.0);
		}
	}
}

public void Rogue_BansheeVeil_Enemy(int entity)
{
	for(int i; i < Element_MAX; i++)
	{
		float res = GetEntPropFloat(entity, Prop_Data, "m_flElementRes");
		if(res >= 1.0)
			continue;
		
		SetEntPropFloat(entity, Prop_Data, "m_flElementRes", res - 0.5);
	}
}

public void Rogue_LittleCube_Ally(int entity, StringMap map)
{
	RogueHelp_BodyHealth(entity, map, Rogue_GetFloor() == 6 ? 1.8 : 1.1);
}

public void Rogue_FearlessBlade_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		int highestPlayer, highestCash;
		for(int target = 1; target <= MaxClients; target++)
		{
			if(CashSpentTotal[target] > highestCash && IsClientInGame(target))
			{
				highestCash = CashSpentTotal[target];
				highestPlayer = target;
			}
		}

		if(highestPlayer == entity)
		{
			RogueHelp_BodyHealth(entity, map, 1.5);

			static int lastTarget;
			if(lastTarget != highestPlayer)
			{
				lastTarget = highestPlayer;
				CPrintToChatAll("{red}%N {crimson}recieved +50％ max health and +50％ damage bonus and +50％ heal rate.", highestPlayer);
			}
		}
	}
}

public void Rogue_FearlessBlade_Weapon(int entity, int client)
{
	int highestPlayer, highestCash;
	for(int target = 1; target <= MaxClients; target++)
	{
		if(CashSpentTotal[target] > highestCash && IsClientInGame(target))
		{
			highestCash = CashSpentTotal[target];
			highestPlayer = target;
		}
	}

	if(highestPlayer == client)
	{
		RogueHelp_WeaponDamage(entity, 1.5);
	}
}

public void Rogue_ChaosStar_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
	if(GetTeam(victim) != TFTeam_Red && (damagetype & DMG_TRUEDAMAGE))
		damage *= 2.5;
}

public void Rogue_Yearning_Ally(int entity, StringMap map)
{
	RogueHelp_BodyHealth(entity, map, 1.0 + (Rogue_GetUmbral() * 0.01));
}

static bool EyeOfFortune;
public void Rogue_EyeOfFortune_Collect()
{
	EyeOfFortune = true;
	Rogue_AddIngots(5, true);
}

void Rogue_Rift_DispatchReturn()
{
	if(EyeOfFortune)
		Rogue_AddIngots(20);
}

public void Rogue_EyeOfFortune_Remove()
{
	EyeOfFortune = false;
}

static bool ThoughtsCatcher;
public void Rogue_ThoughtsCatcher_Collect()
{
	ThoughtsCatcher = true;
	Rogue_AddIngots(5, true);
}

void Rogue_Rift_GatewaySent()
{
	if(ThoughtsCatcher)
		Rogue_AddIngots(20);
}

public void Rogue_ThoughtsCatcher_Remove()
{
	ThoughtsCatcher = false;
}

public void Rogue_AvariceScales_StageStart()
{
	if(Rogue_GetUmbralLevel() < 2)
		Rogue_AddIngots(2);
}

static bool Paintbrush;
public void Rogue_Paintbrush_Collect()
{
	Paintbrush = true;
	Rogue_AddIngots(5, true);
}

void Rogue_Rift_UmbralChange(int &amount)
{
	if(Paintbrush && amount < 0)
		amount++;
}

public void Rogue_Paintbrush_Remove()
{
	Paintbrush = false;
}

public void Rogue_SurvivorContract_Collect()
{
	Citizen_SpawnAtPoint("a");
	Citizen_SpawnAtPoint("b");
}

public void Rogue_SurvivorParty_Collect()
{
	for(int i; i < 3; i++)
	{
		Citizen_SpawnAtPoint();
	}
}

public void Rogue_SoulBindingBone_Ally(int entity, StringMap map)
{
	RogueHelp_BodyDamage(entity, map, 1.0 + (Rogue_GetUmbral() * 0.01));
}

public void Rogue_SoulBindingBone_Weapon(int entity)
{
	RogueHelp_WeaponDamage(entity, 1.0 + (Rogue_GetUmbral() * 0.01));
}

public void Rogue_Minion_Energizer_Ally(int entity, StringMap map)
{
	if(map)	// Players
	{
		
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		RogueHelp_BodyDamage(entity, null, 1.25);
		RogueHelp_BodyHealth(entity, null, 1.25);
	}
}