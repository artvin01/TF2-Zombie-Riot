#pragma semicolon 1
#pragma newdecls required

static int FlawlessAmount;
static bool ReduceChaos1;
static bool ReduceChaos2;
static int MachinaWaldch;
static bool Smoking;

void Rogue_ParadoxDLC_Flawless()
{
	if(Smoking)
	{
		Rogue_AddChaos(8);
	}
	else if(FlawlessAmount)
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
	
	if(Smoking)
		chaos += 8.0;
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
	int remove = Rogue_GetIngots() / 2;
	if(remove > chaos)
		remove = chaos;

	Rogue_AddIngots(-(remove / 2), true);
	Rogue_RemoveChaos(remove);
}

public void Rogue_LifeVest_IngotChanged(int &ingots)
{
	int chaos = Rogue_GetChaos();
	int remove = ingots / 2;
	if(remove > chaos)
		remove = chaos;

	ingots -= remove / 2;
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
		int entity = NPC_CreateByName("npc_stalker_goggles", 0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, TFTeam_Red);
		if(entity != -1)
		{
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
			int other = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
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
	Store_RandomizeNPCStore(0, 1, _, 0.0);
}

public void Rogue_StartSP1_WaveStart()
{
	StartSP(6.0);
}

public void Rogue_StartSP2_WaveStart()
{
	StartSP(12.0);
}

public void Rogue_StartSP3_WaveStart()
{
	StartSP(18.0);
}

static void StartSP(float amount)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			int i, other;
			while(TF2_GetItem(ally, other, i))
			{
				Saga_ChargeReduction(client, other, amount);
			}
		}
	}
}