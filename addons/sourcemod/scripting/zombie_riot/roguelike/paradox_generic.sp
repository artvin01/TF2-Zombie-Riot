#pragma semicolon 1
#pragma newdecls required

static ArrayList ShopListing;

int ShopSetting = 0;
public float Rogue_Encounter_ParadoxShop()
{
	ShopSetting = 0;
	return Rogue_Encounter_ParadoxShop_Internal();
}
public float Rogue_Encounter_ParadoxShop_Ruina()
{
	ShopSetting = 1;
	return Rogue_Encounter_ParadoxShop_Internal();
}
public float Rogue_Encounter_ParadoxShop_Internal()
{	
	if(ShopSetting == 0)
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				Music_Stop_All(client);
				SetMusicTimer(client, GetTime() + 1);
			}
		}

		RemoveAllCustomMusic();

		strcopy(MusicString1.Path, sizeof(MusicString1.Path), "#zombiesurvival/forest_rogue/knucklebones.mp3");
		MusicString1.Time = 999;
		MusicString1.Volume = 1.0;
		MusicString1.Custom = true;
		strcopy(MusicString1.Name, sizeof(MusicString1.Name), "Knucklebones");
		strcopy(MusicString1.Artist, sizeof(MusicString1.Artist), "River Boy");
		
	}

	delete ShopListing;
	ShopListing = new ArrayList(sizeof(Artifact));

	Artifact artifact;

	int ingots = Rogue_GetIngots();

	bool rare = !(GetURandomInt() % 4);

	if(!rare)
	{
		if(Rogue_GetRandomArtfiact(artifact, true, 6) != -1)
			ShopListing.PushArray(artifact);
	}

	if(ingots > 11)
	{
		if(Rogue_GetRandomArtfiact(artifact, true, 12) != -1)
			ShopListing.PushArray(artifact);
		
		if(Rogue_GetRandomArtfiact(artifact, true, 12) != -1)
			ShopListing.PushArray(artifact);
	}

	if(ingots > 17)
	{
		if(Rogue_GetRandomArtfiact(artifact, true, 18) != -1)
			ShopListing.PushArray(artifact);
	}

	if(ingots > 23)
	{
		if(Rogue_GetRandomArtfiact(artifact, true, 24) != -1)
			ShopListing.PushArray(artifact);
	}

	if(rare)
	{
		if(Rogue_GetRandomArtfiact(artifact, true, 30) != -1)
			ShopListing.PushArray(artifact);
	}

	int entity = -1;
	while((entity=FindEntityByClassname(entity, "*")) != -1)
	{
		if(entity < MAXENTITIES)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", artifact.Name, sizeof(artifact.Name));
			if(StrEqual(artifact.Name, "zr_store_prop", false))
				AcceptEntityInput(entity, "Enable");
		}
	}

	StartShopVote(true);
	return 35.0;
}

static void StartShopVote(bool first)
{
	ArrayList list;
	switch(ShopSetting)
	{
		case 0:
			list = Rogue_CreateGenericVote(Rogue_Vote_Shop2Encounter, "Shop Encounter Title");
		case 1:
		{
			if(Rogue_HasNamedArtifact("Mark of a Thief"))
				list = Rogue_CreateGenericVote(Rogue_Vote_Shop2Encounter_Ruina, "Shop Encounter Title Ruina Evil");
			else
				list = Rogue_CreateGenericVote(Rogue_Vote_Shop2Encounter_Ruina, "Shop Encounter Title Ruina");
		}
	}
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Better save up now");
	vote.Append[0] = 0;
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	strcopy(vote.Config, sizeof(vote.Config), "-1");
	list.PushArray(vote);

	int length = ShopListing.Length;
	if(ShopSetting == 0 || (ShopSetting == 1 && !Rogue_HasNamedArtifact("Mark of a Thief")))
	{
		Artifact artifact;
		int ingots = Rogue_GetIngots();
		for(int i; i < length; i++)
		{
			ShopListing.GetArray(i, artifact);

			int cost = artifact.ShopCost;

			Rogue_ParadoxGeneric_ShopCost(cost);

			strcopy(vote.Name, sizeof(vote.Name), artifact.Name);
			Format(vote.Append, sizeof(vote.Append), " △%d", cost);
			strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Info");
			IntToString(i, vote.Config, sizeof(vote.Config));
			vote.Locked = ingots < cost;
			list.PushArray(vote);
		}
		if(length)
		{
			if(ShopSetting == 0)
			{
				strcopy(vote.Name, sizeof(vote.Name), "Steal Grigori");
				vote.Append[0] = 0;
				strcopy(vote.Desc, sizeof(vote.Desc), "Steal Grigori Desc");
				strcopy(vote.Config, sizeof(vote.Config), "-2");
				vote.Locked = false;
				list.PushArray(vote);
			}
			else
			{
				strcopy(vote.Name, sizeof(vote.Name), "Steal Ruinian");
				vote.Append[0] = 0;
				strcopy(vote.Desc, sizeof(vote.Desc), "Steal Ruinian Desc");
				strcopy(vote.Config, sizeof(vote.Config), "-2");
				vote.Locked = false;
				list.PushArray(vote);
			}
		}	
	}
	if(ShopSetting == 1 && !Rogue_HasNamedArtifact("Great Within from Ruina's Great Crystal"))
	{
		int ingots = Rogue_GetIngots();
		strcopy(vote.Name, sizeof(vote.Name), "Ruinian Shop Help Out");
		vote.Append[0] = 0;
		strcopy(vote.Desc, sizeof(vote.Desc), "Ruinian Shop Help Out Desc");
		strcopy(vote.Config, sizeof(vote.Config), "-3");
		int cost = 18;
		if(Rogue_HasNamedArtifact("Mark of a Thief"))
		{
			cost = 36;
		}
		Format(vote.Append, sizeof(vote.Append), " △%d", cost);
		vote.Locked = ingots < cost;
		list.PushArray(vote);
	}

	Rogue_StartGenericVote(length ? (first ? 30.0 : 15.0) : 3.0);
}

public void Rogue_Vote_Shop2Encounter_Ruina(const Vote vote)
{
	Artifact artifact;
	int index = StringToInt(vote.Config);
	switch(index)
	{
		case -1:
		{
			Rogue_SetProgressTime(5.0, false);

			delete ShopListing;

			int entity = -1;
			while((entity=FindEntityByClassname(entity, "*")) != -1)
			{
				if(entity < MAXENTITIES)
				{
					GetEntPropString(entity, Prop_Data, "m_iName", artifact.Name, sizeof(artifact.Name));
					if(StrEqual(artifact.Name, "zr_store_prop", false))
						AcceptEntityInput(entity, "Disable");
				}
			}
		}
		case -2:
		{
			if(ShopListing)
			{
				int length = ShopListing.Length;
				for(int i; i < length; i++)
				{
					ShopListing.GetArray(i, artifact);
					if(artifact.ShopCost > 8)
						Rogue_GiveNamedArtifact(artifact.Name);
				}

				delete ShopListing;
			}
			Rogue_GiveNamedArtifact("Mark of a Thief", true);
			Rogue_GiveNamedArtifact("Evil Within from Ruina's Great Crystal");

			CPrintToChatAll("%t", "Shop Ruina Sad");
			CPrintToChatAll("%t", "Shop Ruina Sad 1");
		}
		case -3:
		{
			Rogue_GiveNamedArtifact("Great Within from Ruina's Great Crystal");

			CPrintToChatAll("%t", "Shop Ruina Happy");
			CPrintToChatAll("%t", "Shop Ruina Happy 1");
			
			StartShopVote(false);
			Rogue_SetProgressTime(20.0, false);
		}
		default:
		{
			ShopListing.GetArray(index, artifact);
			ShopListing.Erase(index);

			Rogue_GiveNamedArtifact(artifact.Name);

			int cost = artifact.ShopCost;

			Rogue_ParadoxGeneric_ShopCost(cost);
			
			Rogue_AddIngots(-cost, true);

			StartShopVote(false);
			Rogue_SetProgressTime(20.0, false);
		}
	}
}
public void Rogue_Vote_Shop2Encounter(const Vote vote)
{
	Artifact artifact;
	int index = StringToInt(vote.Config);
	switch(index)
	{
		case -1:
		{
			Rogue_SetProgressTime(5.0, false);

			delete ShopListing;

			int entity = -1;
			while((entity=FindEntityByClassname(entity, "*")) != -1)
			{
				if(entity < MAXENTITIES)
				{
					GetEntPropString(entity, Prop_Data, "m_iName", artifact.Name, sizeof(artifact.Name));
					if(StrEqual(artifact.Name, "zr_store_prop", false))
						AcceptEntityInput(entity, "Disable");
				}
			}
		}
		case -2:
		{
			Rogue_StartThisBattle(5.0);
			Rogue_SetBattleIngots(1);
			Rogue_GiveNamedArtifact("Mark of a Thief", true);

			int entity = -1;
			while((entity=FindEntityByClassname(entity, "*")) != -1)
			{
				if(entity < MAXENTITIES)
				{
					GetEntPropString(entity, Prop_Data, "m_iName", artifact.Name, sizeof(artifact.Name));
					if(StrEqual(artifact.Name, "zr_store_prop", false))
						AcceptEntityInput(entity, "Disable");
				}
			}
		}
		default:
		{
			ShopListing.GetArray(index, artifact);
			ShopListing.Erase(index);

			Rogue_GiveNamedArtifact(artifact.Name);

			int cost = artifact.ShopCost;

			Rogue_ParadoxGeneric_ShopCost(cost);
			
			Rogue_AddIngots(-cost, true);

			StartShopVote(false);
			Rogue_SetProgressTime(20.0, false);
		}
	}
}
void Rogue_ParadoxShop_Victory()
{
	if(ShopListing)
	{
		Artifact artifact;

		int length = ShopListing.Length;
		for(int i; i < length; i++)
		{
			ShopListing.GetArray(i, artifact);
			if(artifact.ShopCost > 8)
				Rogue_GiveNamedArtifact(artifact.Name);
		}

		delete ShopListing;
	}
}
void Rogue_ParadoxShop_Fail()
{
	delete ShopListing;
}

static void GiveShield(int amount)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(TeutonType[client] == TEUTON_NONE && IsClientInGame(client) && IsPlayerAlive(client))
		{
			int health = GetClientHealth(client);
			if(health > 0)
				SetEntityHealth(client, health + amount);
		}
	}

	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
		{
			if(GetTeam(entity) == TFTeam_Red)
				SetEntProp(entity, Prop_Data, "m_iHealth", GetEntProp(entity, Prop_Data, "m_iHealth") + amount);
		}
	}
}

static void GiveLife(int entity, StringMap map, int amount)
{
	if(map)	// Player
	{
		float value;

		// +X max health
		map.GetValue("26", value);
		map.SetValue("26", value + amount);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		// +X max health
		int health = ReturnEntityMaxHealth(entity) + amount;

		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	}
}

static void MultiHealth(int entity, float amount)
{
	SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * amount));
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(ReturnEntityMaxHealth(entity) * amount));
}

static void GiveMaxHealth(int entity, StringMap map, float amount)
{
	if(map)	// Player
	{
		float value;

		// +X% max health
		map.GetValue("26", value);
		map.SetValue("26", value * amount);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		// +X% max health
		int health = RoundFloat(ReturnEntityMaxHealth(entity) * amount);

		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	}
}

public void Rogue_Store1_Collect()
{
	int recover = 1;
	Rogue_TriggerFunction(Artifact::FuncRecoverWeapon, recover);
	Store_RandomizeNPCStore(ZR_STORE_DEFAULT_SALE, recover);
}

public void Rogue_Store2_Collect()
{
	int recover = 2;
	Rogue_TriggerFunction(Artifact::FuncRecoverWeapon, recover);
	Store_RandomizeNPCStore(ZR_STORE_DEFAULT_SALE, recover);
}

public void Rogue_Store3_Collect()
{
	int recover = 3;
	Rogue_TriggerFunction(Artifact::FuncRecoverWeapon, recover);
	Store_RandomizeNPCStore(ZR_STORE_DEFAULT_SALE, recover);
}

public void Rogue_Shield1_Collect()
{
	GiveShield(500);
}

public void Rogue_Shield2_Collect()
{
	GiveShield(1000);
}

public void Rogue_Shield3_Collect()
{
	GiveShield(1500);
}

public void Rogue_Shield4_Collect()
{
	GiveShield(2000);
}

public void Rogue_Shield5_Collect()
{
	GiveShield(2500);
}

public void Rogue_Shield6_Collect()
{
	GiveShield(3000);
}

public void Rogue_Hope1_Collect()
{
	CurrentCash += 1000;
	GlobalExtraCash += 1000;
}

public void Rogue_Hope8_Collect()
{
	CurrentCash += 8000;
	GlobalExtraCash += 8000;
}

public void Rogue_Ingot25_Collect()
{
	Rogue_AddIngots(25, true);
}

public void Rogue_Life1_Ally(int entity, StringMap map)
{
	GiveLife(entity, map, 125);
}

public void Rogue_Life2_Ally(int entity, StringMap map)
{
	GiveLife(entity, map, 250);
}

public void Rogue_Life3_Ally(int entity, StringMap map)
{
	GiveLife(entity, map, 375);
}

public void Rogue_Life4_Ally(int entity, StringMap map)
{
	GiveLife(entity, map, 500);
}

public void Rogue_Life5_Ally(int entity, StringMap map)
{
	GiveLife(entity, map, 625);
}

public void Rogue_Life6_Ally(int entity, StringMap map)
{
	GiveLife(entity, map, 750);
}

public void Rogue_AttackDown1_Enemy(int entity)
{
	fl_Extra_Damage[entity] /= 1.07;
}

public void Rogue_AttackDown2_Enemy(int entity)
{
	fl_Extra_Damage[entity] /= 1.12;
}

public void Rogue_AttackDown3_Enemy(int entity)
{
	fl_Extra_Damage[entity] /= 1.17;
}

public void Rogue_HealthDown1_Enemy(int entity)
{
	MultiHealth(entity, 0.9);
}

public void Rogue_HealthDown2_Enemy(int entity)
{
	MultiHealth(entity, 0.85);
}

public void Rogue_HealthDown3_Enemy(int entity)
{
	MultiHealth(entity, 0.8);
}

public void Rogue_MeleeDamage1_Weapon(int entity)
{
	if(Store_CheckEntitySlotIndex(2, entity))
		Attributes_SetMulti(entity, 2, 1.15);
}

public void Rogue_MeleeDamage2_Weapon(int entity)
{
	if(Store_CheckEntitySlotIndex(2, entity))
		Attributes_SetMulti(entity, 2, 1.25);
}

public void Rogue_RangedDamage1_Weapon(int entity)
{
	if(Store_CheckEntitySlotIndex(7, entity))
		Attributes_SetMulti(entity, 2, 1.15);
}

public void Rogue_RangedDamage2_Weapon(int entity)
{
	if(Store_CheckEntitySlotIndex(7, entity))
		Attributes_SetMulti(entity, 2, 1.25);
}

public void Rogue_MageDamage1_Weapon(int entity)
{
	if(Store_CheckEntitySlotIndex(8, entity))
		Attributes_SetMulti(entity, 410, 1.15);
}

public void Rogue_MageDamage2_Weapon(int entity)
{
	if(Store_CheckEntitySlotIndex(8, entity))
		Attributes_SetMulti(entity, 410, 1.25);
}

public void Rogue_Health1_Ally(int entity, StringMap map)
{
	GiveMaxHealth(entity, map, 1.2);
}

public void Rogue_Health2_Ally(int entity, StringMap map)
{
	GiveMaxHealth(entity, map, 1.35);
}

public void Rogue_Health3_Ally(int entity, StringMap map)
{
	GiveMaxHealth(entity, map, 1.5);
}

public void Rogue_MeleeVuln1_Enemy(int entity)
{
	fl_Extra_MeleeArmor[entity] *= 1.15;
}

public void Rogue_MeleeVuln2_Enemy(int entity)
{
	fl_Extra_MeleeArmor[entity] *= 1.25;
}

public void Rogue_MeleeVuln3_Enemy(int entity)
{
	fl_Extra_MeleeArmor[entity] *= 1.35;
}

public void Rogue_RangedVuln1_Enemy(int entity)
{
	fl_Extra_RangedArmor[entity] *= 1.15;
}

public void Rogue_RangedVuln2_Enemy(int entity)
{
	fl_Extra_RangedArmor[entity] *= 1.25;
}

public void Rogue_RangedVuln3_Enemy(int entity)
{
	fl_Extra_RangedArmor[entity] *= 1.35;
}

public void Rogue_Healing1_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value = 1.0;

		// +20% healing bonus
		map.GetValue("526", value);
		map.SetValue("526", value * 1.2);
	}
}

public void Rogue_Healing2_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value = 1.0;

		// +30% healing bonus
		map.GetValue("526", value);
		map.SetValue("526", value * 1.3);
	}
}

static Handle EternalNightTimer;

public void Rogue_EternalNight_Collect()
{
	delete EternalNightTimer;
	EternalNightTimer = CreateTimer(0.2, Timer_EternalNightTimer, _, TIMER_REPEAT);
}

public void Rogue_EternalNight_Weapon(int entity)
{
	if(Attributes_Has(entity, 2))
		Attributes_SetMulti(entity, 2, 1.25);
	
	if(Attributes_Has(entity, 6))
		Attributes_SetMulti(entity, 6, 0.75);

	if(Attributes_Has(entity, 410))
		Attributes_SetMulti(entity, 410, 1.25);
}

public void Rogue_EternalNight_Remove()
{
	delete EternalNightTimer;
	Rogue_Refresh_Remove();
}

static Action Timer_EternalNightTimer(Handle timer)
{
	if(Rogue_CanRegen())
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(TeutonType[client] == TEUTON_NONE && IsClientInGame(client) && IsPlayerAlive(client) && dieingstate[client] == 0)
			{
				int health = GetClientHealth(client);
				if(health > 2)
				{
					SetEntityHealth(client, health - 2);
				}
				else
				{
					SDKHooks_TakeDamage(client, 0, 0, 999.9, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
				}
			}
		}
	}

	return Plugin_Continue;
}

static Handle DeadTreeTimer;

public void Rogue_DeadTree_Collect()
{
	delete DeadTreeTimer;
	DeadTreeTimer = CreateTimer(0.2, Timer_DeadTreeTimer, _, TIMER_REPEAT);
}

public void Rogue_DeadTree_Ally(int entity, StringMap map)
{
	if(map)	// Player
		GiveMaxHealth(entity, map, 0.75);
}

public void Rogue_DeadTree_Remove()
{
	delete DeadTreeTimer;
	Rogue_Refresh_Remove();
}

static Action Timer_DeadTreeTimer(Handle timer)
{
	if(Rogue_CanRegen())
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(TeutonType[client] == TEUTON_NONE && IsClientInGame(client) && IsPlayerAlive(client) && dieingstate[client] == 0)
			{
				int health = GetClientHealth(client);
				if(health > 0 && health < SDKCall_GetMaxHealth(client))
					SetEntityHealth(client, health + 4);
			}
		}
	}

	return Plugin_Continue;
}

public void Rogue_Fowlbeast_Ally(int entity, StringMap map)
{
	if(map)	// Players
	{
		
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{

			}
			else	// Other
			{
				int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
				if(owner > 0 && owner <= MaxClients)
				{
					fl_Extra_Damage[entity] *= 1.3;
					MultiHealth(entity, 1.3);

					int weapon = GetEntPropEnt(owner, Prop_Send, "m_hActiveWeapon");
					if(weapon != -1)
					{
						if(Attributes_Has(weapon, 2))
							ApplyTempAttrib(weapon, 2, 1.6, 10.0);
						
						if(Attributes_Has(weapon, 410))
							ApplyTempAttrib(weapon, 410, 1.6, 10.0);
					}
				}
			}
		}
	}
}

public void Rogue_QueenFellowship_Collect()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(TeutonType[client] == TEUTON_NONE && IsClientInGame(client) && IsPlayerAlive(client))
		{
			int health = GetClientHealth(client);
			if(health > 0)
			{
				int maxhealth = SDKCall_GetMaxHealth(client);
				if(health > maxhealth)
				{
					health -= maxhealth;
				}
				else
				{
					health = 0;
				}

				SetEntityHealth(client, health + (maxhealth * 5) + 500);
			}
		}
	}

	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
		{
			if(GetTeam(entity) == TFTeam_Red)
			{
				int health = GetEntProp(entity, Prop_Data, "m_iHealth");
				if(health > 0)
				{
					int maxhealth = ReturnEntityMaxHealth(entity);
					if(health > maxhealth)
					{
						health -= maxhealth;
					}
					else
					{
						health = 0;
					}

					SetEntProp(entity, Prop_Data, "m_iHealth", health + (maxhealth * 5) + 500);
				}
			}
		}
	}
}

public void Rogue_AncientTreeFruit_Collect()
{
	Artifact artifact;
	for(int i; i < 3; i++)
	{
		if(Rogue_GetRandomArtfiact(artifact, true, 12) != -1)
			Rogue_GiveNamedArtifact(artifact.Name);
	}
}

static bool ShopSale;

void Rogue_ParadoxGeneric_ShopCost(int &cost)
{
	if(ShopSale)
		cost /= 2;
}

public void Rogue_ShopSale_Collect()
{
	ShopSale = true;
}

public void Rogue_ShopSale_Remove()
{
	ShopSale = false;
}

public void Rogue_BobDuck_Collect()
{
	for(int client_summon=1; client_summon<=MaxClients; client_summon++)
	{
		if(IsClientInGame(client_summon) && GetClientTeam(client_summon)==2 && IsPlayerAlive(client_summon) && TeutonType[client_summon] == TEUTON_NONE)
		{
			float flPos[3];
			GetClientAbsOrigin(client_summon, flPos);
			NPC_CreateByName("npc_duck_follower", client_summon, flPos, {0.0, 0.0, 0.0}, TFTeam_Red);
			break;
		}
	}
}

public void Rogue_BobDuck_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;

		// +25% max health
		map.GetValue("26", value);
		map.SetValue("26", value * 1.25);

		// +25% building damage
		value = 1.0;
		map.GetValue("287", value);
		map.SetValue("287", value * 1.25);

		// -10% damage vuln
		value = 1.0;
		map.GetValue("412", value);
		map.SetValue("412", value * 0.9);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// +25% damage bonus
			npc.m_fGunBonusDamage *= 1.25;

			// +15% fire rate
			npc.m_fGunBonusFireRate *= 0.85;

			// +15% reload speed
			npc.m_fGunReload *= 0.85;

			// +25% max health
			int health = ReturnEntityMaxHealth(npc.index) * 5 / 4;
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				// +25% damage bonus
				npc.BonusDamageBonus *= 1.25;

				// +15% fire rate
				npc.BonusFireRate /= 0.85;

				// +25% max health
				int health = ReturnEntityMaxHealth(npc.index) * 5 / 4;
				SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
			}
		}
	}
}

public void Rogue_BobDuck_Weapon(int entity)
{
	Attributes_SetMulti(entity, 2, 1.25);

	if(Attributes_Has(entity, 6))
		Attributes_SetMulti(entity, 6, 0.85);
	
	if(Attributes_Has(entity, 97))
		Attributes_SetMulti(entity, 97, 0.85);
	
	if(Attributes_Has(entity, 733))
		Attributes_SetMulti(entity, 733, 0.85);
	
	Attributes_SetMulti(entity, 410, 1.25);

	char buffer[36];
	GetEntityClassname(entity, buffer, sizeof(buffer));
	if(StrEqual(buffer, "tf_weapon_medigun"))
	{
		Attributes_SetMulti(entity, 1, 1.25);
	}
}

public void Rogue_BobDuck_Remove()
{
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(other != -1 && i_NpcInternalId[other] == DuckFollower_ID() && IsEntityAlive(other))
		{
			SmiteNpcToDeath(other);
			break;
		}
	}
}
