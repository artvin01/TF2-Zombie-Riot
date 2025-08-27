#pragma semicolon 1
#pragma newdecls required

static int FlawlessAmount;
static bool ReduceChaos1;
static bool ReduceChaos2;
static int MachinaWaldch;
static bool Smoking;
static bool LongDebuff;
static bool ShortStun;
static bool LongStun;
static Handle TulipTimer;
static float CurrentTulipDamage[MAXPLAYERS];
static Handle CastleTimer;
static float CurrentCastleHealth[MAXPLAYERS];

void Rogue_ParadoxDLC_Flawless(int chaos)
{
	if(Smoking)
	{
		//always add 5.
		Rogue_AddChaos(5);
	}

	if(FlawlessAmount && chaos <= 5)
	{
		Rogue_RemoveChaos(FlawlessAmount);
	}
}

void Rogue_ParadoxDLC_BattleChaos(float &chaos)
{
	if(ReduceChaos1)
		chaos *= 0.6;
	
	if(ReduceChaos2)
		chaos *= 0.4;
}

void Rogue_ParadoxDLC_DebuffTime(int entity, float &time)
{
	if(LongDebuff && GetTeam(entity) != TFTeam_Red)
		time *= 2.0;
}

void Rogue_ParadoxDLC_StunTime(int entity, float &time)
{
	if(ShortStun && GetTeam(entity) != TFTeam_Red)
		time *= 1.25;
	
	if(LongStun && GetTeam(entity) != TFTeam_Red)
		time *= 1.35;
}

void Rogue_ParadoxDLC_AbilityUsed(int client)
{
	if(TulipTimer != null)
		RequestFrame(BlackTulipDecay, GetClientUserId(client));
}

public void Rogue_RuinaGem_Collect()
{
	Rogue_RemoveChaos(10);
}

public void Rogue_Flawless1_Collect()
{
	FlawlessAmount += 6;
}

public void Rogue_Flawless1_Remove()
{
	FlawlessAmount -= 6;
}

public void Rogue_Flawless2_Collect()
{
	FlawlessAmount += 9;
}

public void Rogue_Flawless2_Remove()
{
	FlawlessAmount -= 9;
}

public void Rogue_ReduceChaos1_Collect()
{
	ReduceChaos1 = true;
}

public void Rogue_ReduceChaos1_Remove()
{
	ReduceChaos1 = false;
}

public void Rogue_ReduceChaos2_Collect()
{
	ReduceChaos2 = true;
}

public void Rogue_ReduceChaos2_Remove()
{
	ReduceChaos2 = false;
}

public void Rogue_MercenaryInsurance_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value = 1.0;
		float multi = Rogue_GetChaosLevel() > 2 ? 0.65 : 0.9;
		// 10%/35% damage resist

		map.GetValue("412", value);
		map.SetValue("412", value * multi);
	}
}

public void Rogue_LifeVest_Collect()
{
	int chaos = Rogue_GetChaos();
	int remove = Rogue_GetIngots();
	if(remove > chaos)
		remove = chaos;

	Rogue_AddIngots(-(remove), true);
	Rogue_RemoveChaos(remove);
}

public void Rogue_LifeVest_IngotChanged(int &ingots)
{
	if(ingots <= 0)
		return;
		
	int chaos = Rogue_GetChaos();
	int remove = ingots;
	if(remove > chaos)
		remove = chaos;

	ingots -= remove;
	Rogue_RemoveChaos(remove);
}

public void Rogue_Scrapper_RecoverWeapon(int &weapons)
{
	Rogue_AddIngots(weapons * 2);
	weapons = 0;
}

public void Rogue_MachinaWaldch_Collect()
{
	MachinaWaldch = 6666666;
}

public void Rogue_MachinaWaldch_StageStart()
{
	if(MachinaWaldch > 0)
	{
		float pos[3], ang[3];
		Spawns_GetNextPos(pos, ang);

		int entity = NPC_CreateByName("npc_stalker_goggles", 0, pos, ang, TFTeam_Red, _, true);
		if(entity != -1)
		{
			Rogue_AllySpawned(entity);
			Waves_AllySpawned(entity);

			SetEntProp(entity, Prop_Data, "m_iHealth", MachinaWaldch);
			fl_Extra_Damage[entity] *= 2.0;
		}
	}
}

public void Rogue_MachinaWaldch_StageEnd(bool victory)
{
	if(victory)
	{
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(other != -1 && i_NpcInternalId[other] == StalkerGoggles_ID() && IsEntityAlive(other))
			{
				MachinaWaldch = GetEntProp(other, Prop_Data, "m_iHealth");
				SmiteNpcToDeath(other);
				return;
			}
		}
	}

	MachinaWaldch = 0;
}

public void Rogue_Smoking_Collect()
{
	Smoking = true;
}

public void Rogue_Smoking_Ally(int entity, StringMap map)
{
	if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			npc.m_fGunBonusReload *= 0.8;
			npc.m_fGunBonusFireRate *= 0.8;
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
				npc.BonusFireRate /= 0.8;
		}
	}
}

public void Rogue_Smoking_Weapon(int entity)
{
	if(Attributes_Has(entity, 6))
		Attributes_SetMulti(entity, 6, 0.8);
	
	if(Attributes_Has(entity, 97))
		Attributes_SetMulti(entity, 97, 0.8);
	
	if(Attributes_Has(entity, 733))
		Attributes_SetMulti(entity, 733, 0.8);
	
	if(Attributes_Has(entity, 8))
		Attributes_SetMulti(entity, 8, (1.0 / 0.8));
}

public void Rogue_Smoking_Remove()
{
	Smoking = false;
	Rogue_Refresh_Remove();
}

public void Rogue_FreeWeapon_Collect()
{
	Store_RandomizeNPCStore(ZR_STORE_DEFAULT_SALE, 1, 0.01);
}

public void Rogue_StartSP1_WaveStart()
{
	StartSP(15.0);
}

public void Rogue_StartSP2_WaveStart()
{
	StartSP(25.0);
}

public void Rogue_StartSP3_WaveStart()
{
	StartSP(50.0);
}

static void StartSP(float amount)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			int i, other;
			while(TF2_GetItem(client, other, i))
			{
				Saga_ChargeReduction(client, other, amount);
			}
		}
	}
}

public void Rogue_StunPuppet1_Enemy(int entity)
{
	CreateTimer(0.1, StunPuppet1_Timer, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

static Action StunPuppet1_Timer(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity == -1 || b_NpcHasDied[entity])
		return Plugin_Stop;
	
	float DamageDeal = 16.0;
	float ExtraDamageDealt;
	int AttackerWho = LastHitRef[entity];
	if(!IsValidEntity(AttackerWho))
		AttackerWho = 0;

	ExtraDamageDealt = ExtraDamageWaveScaling(); //at wave 60, this will equal to 60* dmg
	if(ExtraDamageDealt <= 0.35)
	{
		ExtraDamageDealt = 0.35;
	}
	DamageDeal *= ExtraDamageDealt;
	if(HasSpecificBuff(entity, "Stunned") && !IsInvuln(entity))
		SDKHooks_TakeDamage(entity, AttackerWho, AttackerWho, DamageDeal, DMG_PLASMA|DMG_SHOCK, LastHitWeaponRef[entity], .Zr_damage_custom = ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED|ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS);
	
	return Plugin_Continue;
}

public void Rogue_StunPuppet2_Enemy(int entity)
{
	CreateTimer(0.1, StunPuppet2_Timer, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

static Action StunPuppet2_Timer(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity == -1 || b_NpcHasDied[entity])
		return Plugin_Stop;
	
	int AttackerWho = LastHitRef[entity];
	if(!IsValidEntity(AttackerWho))
		AttackerWho = 0;

	float DamageDeal = 24.0;
	float ExtraDamageDealt;

	ExtraDamageDealt = ExtraDamageWaveScaling(); //at wave 60, this will equal to 60* dmg
	if(ExtraDamageDealt <= 0.35)
	{
		ExtraDamageDealt = 0.35;
	}
	DamageDeal *= ExtraDamageDealt;
	if(HasSpecificBuff(entity, "Stunned") && !IsInvuln(entity))
		SDKHooks_TakeDamage(entity, AttackerWho, AttackerWho, DamageDeal, DMG_PLASMA|DMG_SHOCK, LastHitWeaponRef[entity], .Zr_damage_custom = ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED|ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS);
	
	return Plugin_Continue;
}

public void Rogue_LongDebuff_Collect()
{
	LongDebuff = true;
}

public void Rogue_LongDebuff_Remove()
{
	LongDebuff = false;
}

public void Rogue_LongStun1_Collect()
{
	ShortStun = true;
}

public void Rogue_LongStun1_Remove()
{
	ShortStun = false;
}

public void Rogue_LongStun2_Collect()
{
	LongStun = true;
}

public void Rogue_LongStun2_Remove()
{
	LongStun = false;
}

public void Rogue_BlackTulip_Collect()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		CurrentTulipDamage[client] = 1.0;
	}

	TulipTimer = CreateTimer(1.0, Tulip_Timer, _, TIMER_REPEAT);
}

static Action Tulip_Timer(Handle timer)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && CurrentTulipDamage[client] < 1.6)
		{
			CurrentTulipDamage[client] *= 1.004;

			int i, entity;
			while(TF2_GetItem(client, entity, i))
			{
				if(Attributes_Has(entity, 2))
					Attributes_SetMulti(entity, 2, 1.004);
				
				if(Attributes_Has(entity, 8))
					Attributes_SetMulti(entity, 8, 1.004);
				
				if(Attributes_Has(entity, 410))
					Attributes_SetMulti(entity, 410, 1.004);
			}
		}
	}

	return Plugin_Continue;
}

static void BlackTulipDecay(int userid)
{
	int client = GetClientOfUserId(userid);
	if(client && CurrentTulipDamage[client] > 1.0)
	{
		CPrintToChat(client, "{black}The Black Tulip lost its power and is recharging...");
		int i, entity;
		while(TF2_GetItem(client, entity, i))
		{
			if(Attributes_Has(entity, 2))
				Attributes_SetMulti(entity, 2, 1.0 / CurrentTulipDamage[client]);
			
			if(Attributes_Has(entity, 8))
				Attributes_SetMulti(entity, 8, 1.0 / CurrentTulipDamage[client]);
			
			if(Attributes_Has(entity, 410))
				Attributes_SetMulti(entity, 410, 1.0 / CurrentTulipDamage[client]);
		}

		CurrentTulipDamage[client] = 1.0;
	}
}

public void Rogue_BlackTulip_Weapon(int entity, int client)
{
	if(Attributes_Has(entity, 2))
		Attributes_SetMulti(entity, 2, CurrentTulipDamage[client]);
	
	if(Attributes_Has(entity, 8))
		Attributes_SetMulti(entity, 8, CurrentTulipDamage[client]);
	
	if(Attributes_Has(entity, 410))
		Attributes_SetMulti(entity, 410, CurrentTulipDamage[client]);
}

public void Rogue_BlackTulip_Ally(int entity, StringMap map)
{
	if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);
			npc.m_fGunBonusDamage *= 1.6;
		}
	}
}

public void Rogue_BlackTulip_Remove()
{
	delete TulipTimer;
	Rogue_Refresh_Remove();
}

public void Rogue_CastleSpring_Collect()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		CurrentCastleHealth[client] = 1.0;
	}

	CastleTimer = CreateTimer(1.0, Castle_Timer, _, TIMER_REPEAT);
}

static Action Castle_Timer(Handle timer)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			if(IsPlayerAlive(client) && dieingstate[client] == 0)
			{
				if(CurrentCastleHealth[client] < 1.6)
					CurrentCastleHealth[client] *= 1.0016;
			}
			else
			{
				CurrentCastleHealth[client] = 1.0;
			}
		}
	}

	return Plugin_Continue;
}

public void Rogue_CastleSpring_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;

		// +X% max health
		map.GetValue("26", value);
		map.SetValue("26", value * CurrentCastleHealth[entity]);
	}
}

public void Rogue_CastleSpring_Remove()
{
	delete CastleTimer;
	Rogue_Refresh_Remove();
}