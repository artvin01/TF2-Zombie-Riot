#pragma semicolon 1
#pragma newdecls required

static int WarpSeed;
static int DifficultyLevel;
static ArrayList ShopListing;
static int ConsumeLimit;
static bool CurseSwarm;
static bool CurseEmpty;
static bool CurseCorrupt;
//static bool Keycard;

stock void Rogue_Rift_MultiScale(float &multi)
{
	if(CurseSwarm)
		multi *= 1.2;
}

stock bool Rogue_Rift_NoStones()
{
	return CurseEmpty;
}

stock int Rogue_Rift_CurseLevel()
{
	return DifficultyLevel;
}

/*
void Rogue_Rift_StorePriceMulti(int &cost, bool greg)
{
	if(!greg)
		cost = cost * 11 / 10;
}
void Rogue_Rift_PackPriceMulti(int &cost)
{
	if(Keycard)
		cost = cost * 11 / 10;
}
*/
public void Rogue_Curse_RiftSwarm(bool enable)
{
	CurseSwarm = enable;
}

public void Rogue_Curse_RiftEmpty(bool enable)
{
	CurseEmpty = enable;
}

public void Rogue_Curse_RiftDarkness(bool enable)
{
	if(enable)
	{
		Rogue_GiveNamedArtifact("Rift of Darkness", true);
	}
	else
	{
		Rogue_RemoveNamedArtifact("Rift of Darkness");
	}
}

public void Rogue_RiftEmpty_Enemy(int entity)
{
	if(view_as<CClotBody>(entity).m_iBleedType == BLEEDTYPE_VOID || view_as<CClotBody>(entity).m_iBleedType == BLEEDTYPE_UMBRAL || GetEntPropFloat(entity, Prop_Data, "m_flElementRes", Element_Void) > 0.4)
	{
		fl_Extra_Damage[entity] *= 1.25;
		SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * 1.3));
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(ReturnEntityMaxHealth(entity) * 1.3));
	}
	else
	{
		fl_Extra_Damage[entity] *= 0.9;
		SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * 0.85));
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(ReturnEntityMaxHealth(entity) * 0.85));
	}
}

public void Rogue_Curse_RiftExpansion(bool enable)
{
	if(enable)
	{
		Rogue_GiveNamedArtifact("Rift of Expansion", true);
	}
	else
	{
		Rogue_RemoveNamedArtifact("Rift of Expansion");
	}
}

public void Rogue_RiftExpansion_StageStart()
{
	float pos[3], ang[3];

	Spawns_GetNextPos(pos, ang);
	NPC_CreateByName("npc_void_portal", 0, pos, ang, TFTeam_Blue);

	Spawns_GetNextPos(pos, ang);
	NPC_CreateByName("npc_void_portal", 0, pos, ang, TFTeam_Blue);

	Spawns_GetNextPos(pos, ang);
	NPC_CreateByName("npc_void_portal", 0, pos, ang, TFTeam_Blue);
}
public void Rogue_BlessingStars_Start()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2)
		{
			ApplyStatusEffect(client, client, "Blessing of Stars", 999.0);
		}
	}
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && !b_NpcIsInvulnerable[entity] && IsEntityAlive(entity) && GetTeam(entity) == TFTeam_Red)
		{
			ApplyStatusEffect(entity, entity, "Blessing of Stars", 999.0);
		}
	}
}

public void Rogue_Curse_RiftCorrupt(bool enable)
{
	CurseCorrupt = enable;
}

public void Rogue_Curse_RiftMalice(bool enable)
{
	if(enable)
	{
		Rogue_GiveNamedArtifact("Rift of Malice", true);
	}
	else
	{
		Rogue_RemoveNamedArtifact("Rift of Malice");
	}
}

public void Rogue_RiftMalice_StageStart()
{
	Rogue_AddUmbral(-3);
}

public float Rogue_Encounter_RiftShop()
{
	delete ShopListing;
	ShopListing = new ArrayList(sizeof(Artifact));

	Artifact artifact;

	bool rare = Rogue_GetFloor() > 0;
	bool easyMode = DifficultyLevel < 1;
	bool found;
	if(rare)
	{
		if(GetURandomInt() % 4)
		{
			rare = false;
		}
	}
	if(!easyMode)
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client) == 2 && Items_HasNamedItem(client, "ROGUE3_ENDING2"))
			{
				found = true;
				break;
			}
		}
	}

	if(Rogue_GetRandomArtifact(artifact, true, 6) != -1)
		ShopListing.PushArray(artifact);

	if(Rogue_GetRandomArtifact(artifact, true, 12) != -1)
		ShopListing.PushArray(artifact);
	
	if(Rogue_GetRandomArtifact(artifact, true, 12) != -1)
		ShopListing.PushArray(artifact);

	if(Rogue_GetRandomArtifact(artifact, true, 18) != -1)
		ShopListing.PushArray(artifact);

	if(Rogue_GetRandomArtifact(artifact, true, 24) != -1)
		ShopListing.PushArray(artifact);

	if(rare)
	{
		if(Rogue_GetRandomArtifact(artifact, true, 30) != -1)
			ShopListing.PushArray(artifact);
	}
	else if(found && Rogue_GetNamedArtifact("Fractured", artifact))
	{
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
	ArrayList list = Rogue_CreateGenericVote(FinishShopVote, "Shop Encounter Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Better save up now");
	vote.Append[0] = 0;
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	strcopy(vote.Config, sizeof(vote.Config), "-1");
	list.PushArray(vote);

	int length = ShopListing.Length;

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
		strcopy(vote.Name, sizeof(vote.Name), "Steal Grigori");
		vote.Append[0] = 0;
		strcopy(vote.Desc, sizeof(vote.Desc), "Steal Grigori Desc");
		strcopy(vote.Config, sizeof(vote.Config), "-2");
		vote.Locked = false;
		list.PushArray(vote);
	}

	Rogue_StartGenericVote(length ? (first ? 30.0 : 15.0) : 3.0);
}

static void FinishShopVote(const Vote vote)
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
			Rogue_GiveNamedArtifact("Despair");

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

void Rogue_RiftShop_Victory()
{
	if(ShopListing)
	{
		Artifact artifact;

		int length = ShopListing.Length;
		for(int i; i < length; i++)
		{
			ShopListing.GetArray(i, artifact);
			Rogue_GiveNamedArtifact(artifact.Name);
		}

		delete ShopListing;
	}
}

void Rogue_RiftShop_Fail()
{
	delete ShopListing;
}

stock float Rogue_Rift_OptionalVoteItem(const char[] name)
{
	ArrayList list = Rogue_CreateGenericVote(FinishOptionalVoteItem, "We found a Voidstone");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), name);
	strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Config Info");
	strcopy(vote.Config, sizeof(vote.Config), name);
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Leave it");
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave it");
	vote.Config[0] = 0;
	list.PushArray(vote);

	Rogue_StartGenericVote(15.0);
	return 20.0;
}

static void FinishOptionalVoteItem(const Vote vote, int index)
{
	if(index == 0)
		Rogue_GiveNamedArtifact(vote.Config);
}

public float Rogue_Encounter_RiftConsume()
{
	ConsumeLimit = 2;
	StartRiftVote(true);
	return 35.0;
}
public void Rogue_IsSellProfin(int entity)
{
	f_HeadshotDamageMultiNpc[entity] *= 1.25;
}

static bool StartRiftVote(bool first)
{
	ArrayList list = Rogue_CreateGenericVote(FinishRiftVote, "Rift Consume Encounter Title");
	Vote vote;

	int needToUseNow;
	if(Rogue_GetFloor() == 4 && Rogue_HasNamedArtifact("Wordless Deed") && !Rogue_HasNamedArtifact("The Shadow"))
		needToUseNow = ConsumeLimit == 1 ? 2 : 1;
	
	if(!needToUseNow)
	{
		strcopy(vote.Name, sizeof(vote.Name), "Better save up now");
		strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
		strcopy(vote.Config, sizeof(vote.Config), "-1");
		list.PushArray(vote);
	}

	int found;
	if(needToUseNow == 2)	// Need to consume the item now!
	{
		strcopy(vote.Name, sizeof(vote.Name), "Wordless Deed");
		strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Info");
		strcopy(vote.Config, sizeof(vote.Config), "Wordless Deed");
		list.PushArray(vote);
		found++;
	}

	ArrayList collection = Rogue_GetCurrentCollection();

	if(collection)
	{
		vote.Locked = needToUseNow == 2;

		Artifact artifact;
		int length = collection.Length;

		// Void Stones
		for(int i; i < length; i++)
		{
			Rogue_GetCurrentArtifacts().GetArray(collection.Get(i), artifact);

			if(!artifact.Hidden && artifact.FuncRemove != INVALID_FUNCTION && (artifact.Multi || artifact.ShopCost == 6))
			{
				strcopy(vote.Name, sizeof(vote.Name), artifact.Name);
				strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Info");
				strcopy(vote.Config, sizeof(vote.Config), artifact.Name);
				list.PushArray(vote);
				
				if(++found > 6)
					break;
			}
		}
		
		if(found < 7)
		{
			// Misc items
			for(int i = length - 1; i >= 0; i--)
			{
				Rogue_GetCurrentArtifacts().GetArray(collection.Get(i), artifact);

				if(!artifact.Hidden && artifact.FuncRemove != INVALID_FUNCTION && !(artifact.Multi || artifact.ShopCost == 6))
				{
					strcopy(vote.Name, sizeof(vote.Name), artifact.Name);
					strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Info");
					strcopy(vote.Config, sizeof(vote.Config), artifact.Name);
					list.PushArray(vote);
					
					if(++found > 6)
						break;
				}
			}
		}
	}

	Rogue_StartGenericVote(found ? (first ? 30.0 : 15.0) : 3.0);
	return view_as<bool>(found);
}

static void FinishRiftVote(const Vote vote)
{
	int index = StringToInt(vote.Config);
	switch(index)
	{
		case -1:
		{
			EndRiftVote();
		}
		default:
		{
			bool angry = Rogue_GetUmbralLevel() == 4;
			int affinity = Rogue_GetUmbral();

			Artifact artifact;
			Rogue_GetNamedArtifact(vote.Config, artifact);
			Rogue_RemoveNamedArtifact(vote.Config);

			if(angry)	// They threw away something that made it worse
				angry = affinity > Rogue_GetUmbral();

			if(!StrEqual(vote.Config, "Wordless Deed") && CurseCorrupt && (GetURandomInt() % 2))
			{
				Rogue_GiveNamedArtifact("Fractured");
			}
			else
			{
				switch(artifact.ShopCost)
				{
					case 30:
					{
						GiveCash(10000);
					}
					case 24:
					{
						GiveCash(6000);
					}
					case 18:
					{
						GiveCash(4000);
					}
					case 12:
					{
						GiveCash(2000);
					}
					default:
					{
						if(!artifact.Multi)
							GiveCash(2000);
					}
				}
			}
			
			Rogue_Rift_GatewaySent();

			if(angry)
			{
				CPrintToChatAll("%t", "Umbrals take notice of your actions");

				Rogue_StartThisBattle(5.0);
				Rogue_SetBattleIngots(1);
				Rogue_SetRequiredBattle(true);
			}
			else
			{
				ConsumeLimit--;

				if(ConsumeLimit < 1)
				{
					EndRiftVote();
				}
				else
				{
					CPrintToChatAll("%t", "Consumes Left", ConsumeLimit);
					bool found = StartRiftVote(false);
					Rogue_SetProgressTime(found ? 20.0 : 5.0, false);
				}
			}
		}
	}
}

static void EndRiftVote()
{
	if(Rogue_HasNamedArtifact("Twirl Guidance"))
	{
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(other != -1 && i_NpcInternalId[other] == TwirlFollower_ID() && IsEntityAlive(other))
			{
				SmiteNpcToDeath(other);
				break;
			}
		}

		Rogue_SetProgressTime(10.0, false);

		Rogue_RemoveNamedArtifact("Twirl Guidance");
		CPrintToChatAll("{purple}Twirl{snow} : I'm sorry, i have to stay behind, i don't want my higherups to end like lelouch, i'm sure youll be fine without me.");	// Add Twirl leave dialogue
		CPrintToChatAll("{purple}Twirl{snow} : Hey and if you die, i'll take care of everything, not joking.");
		CPrintToChatAll("{black}Izan{default} : Bye.");
		CPrintToChatAll("{white}Bob{default} : We'll be fine, we have the entirety of Irln invading, you can make sure our home is fine.");
	}
	else
	{
		Rogue_SetProgressTime(5.0, false);
	}
}

static void GiveCash(int cash)
{
	CurrentCash += cash;
	GlobalExtraCash += cash;
	CPrintToChatAll("{green}%t", "Cash Gained!", cash);
}

public void Rogue_RiftEasy_Collect()
{
	DifficultyLevel = 0;
	
	if(!Rogue_HasNamedArtifact("Bob's Assistance"))
		Rogue_GiveNamedArtifact("Bob's Assistance", true, true);
	
	if(!Rogue_HasNamedArtifact("Twirl Guidance"))
		Rogue_GiveNamedArtifact("Twirl Guidance", true, true);
}

public void Rogue_RiftEasy_Enemy(int entity)
{
	fl_Extra_Speed[entity] *= 0.8;
	fl_Extra_MeleeArmor[entity] *= 1.35;
	fl_Extra_RangedArmor[entity] *= 1.35;
	fl_Extra_Damage[entity] *= 0.65;
}

public void Rogue_RiftNormal_Collect()
{
	DifficultyLevel = 1;
	
	if(!Rogue_HasNamedArtifact("Bob's Assistance"))
		Rogue_GiveNamedArtifact("Bob's Assistance", true, true);
	
	if(!Rogue_HasNamedArtifact("Twirl Guidance"))
		Rogue_GiveNamedArtifact("Twirl Guidance", true, true);
}

public void Rogue_RiftNormal_Enemy(int entity)
{
	float stats = Pow(1.05, float(Rogue_GetFloor() + 1));

	fl_Extra_Damage[entity] *= stats;
	SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * stats));
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(ReturnEntityMaxHealth(entity) * stats));
}

public void Rogue_RiftHard_Collect()
{
	DifficultyLevel = 2;
	Rogue_GiveNamedArtifact("Fractured");
	
	if(!Rogue_HasNamedArtifact("Bob's Assistance"))
		Rogue_GiveNamedArtifact("Bob's Assistance", true, true);
	
	if(!Rogue_HasNamedArtifact("Twirl Guidance"))
		Rogue_GiveNamedArtifact("Twirl Guidance", true, true);
}

public void Rogue_RiftHard_Enemy(int entity)
{
	float stats = Pow(1.1, float(Rogue_GetFloor() + 1));

	fl_Extra_Damage[entity] *= stats;
	SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * stats));
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(ReturnEntityMaxHealth(entity) * stats));
}

public float Rogue_Encounter_Rift1()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_Rift1, "Rift Ending 1 Lore");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Rift Ending 1 Option 1");
	strcopy(vote.Desc, sizeof(vote.Desc), "Rift Ending 1 Desc 1");
	list.PushArray(vote);

	bool easyMode = DifficultyLevel < 1;
	bool found;

	if(!easyMode)
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client) == 2 && Items_HasNamedItem(client, "Reila's Scorn Keycard"))
			{
				found = true;
				break;
			}
		}
	}

	strcopy(vote.Name, sizeof(vote.Name), "Rift Ending 1 Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Rift Ending 1 Desc 2");
	if(easyMode)
	{
		vote.Locked = true;
		strcopy(vote.Append, sizeof(vote.Append), " (Rift Level 2)");
	}
	else if(!found)
	{
		vote.Locked = true;
		strcopy(vote.Append, sizeof(vote.Append), " (Win Ending 1)");
	}
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}
public void Rogue_Vote_Rift1(const Vote vote, int index)
{
	switch(index)
	{
		case 0:
		{
			Artifact artifact;
			if(Rogue_GetRandomArtifact(artifact, true, 18) != -1)
				Rogue_GiveNamedArtifact(artifact.Name);

			if(!Rogue_HasNamedArtifact("Bob's Assistance"))
				Rogue_GiveNamedArtifact("Bob's Assistance", true, true);
		}
		case 1:
		{
			Rogue_GiveNamedArtifact("Reila Assistance", true);
			Rogue_GiveNamedArtifact("Wordless Deed");
		}
	}
}

public void Rogue_Reila_Collect()
{
	for(int client_summon=1; client_summon<=MaxClients; client_summon++)
	{
		if(IsClientInGame(client_summon) && GetClientTeam(client_summon)==2 && IsPlayerAlive(client_summon) && TeutonType[client_summon] == TEUTON_NONE)
		{
			float flPos[3];
			GetClientAbsOrigin(client_summon, flPos);
			NPC_CreateByName("npc_reila_follower", client_summon, flPos, {0.0, 0.0, 0.0}, TFTeam_Red);
			break;
		}
	}
}

public void Rogue_Reila_Remove()
{
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(other != -1 && i_NpcInternalId[other] == ReilaFollower_ID() && IsEntityAlive(other))
		{
			SmiteNpcToDeath(other);
			break;
		}
	}
}

public void Rogue_Rift1_Collect()
{
	Rogue_AddUmbral(-20, true);
}

public void Rogue_Rift1_Remove()
{
	if(Rogue_Started())
	{
		Rogue_GiveNamedArtifact("Keycard");
		Rogue_AddUmbral(20);
	}
}

public void Rogue_Rift1Good_Collect()
{
	//Keycard = true;
	CPrintToChatAll("{pink}Reila{default}: I know where to use this.");
}

public void Rogue_Rift1Good_Remove()
{
	//Keycard = false;

	if(Rogue_Started())
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				Music_Stop_All(client);
				SetMusicTimer(client, GetTime() + 199);
			}
		}

		CPrintToChatAll("{pink}Reila{default}: ...");
		Rogue_RemoveNamedArtifact("Reila Assistance");
		Rogue_GiveNamedArtifact("Torn Keycard");
		Rogue_AddUmbral(-100, true);
		Rogue_AddIngots(-Rogue_GetIngots(), true);
	}
}

public void Rogue_Rift1Bad_Enemy(int entity)
{
	Elemental_AddWarpedDamage(entity, entity, RoundFloat(ReturnEntityMaxHealth(entity) * 1.8), false, _, true);
	
	if(Elemental_DamageRatio(entity, Element_Warped) <= 0.0)
	{
		view_as<CClotBody>(entity).m_bNoKillFeed = true;
		SmiteNpcToDeath(entity);
	}
}

public float Rogue_Encounter_WarpedBattle()
{
	WarpSeed = GetURandomInt();
	Rogue_GiveNamedArtifact("Rift of Warp", true);
	Rogue_SetBattleIngots(4 + (Rogue_GetFloor() / 2));
	return 0.0;
}

public void Rogue_RiftWarp_Enemy(int entity)
{
	if((GetURandomInt() % 4) == 0)
	{
		int seed1 = 2 + (WarpSeed % 3);
		int seed2 = WarpSeed / 3;

		if((seed2 % seed1) == (i_NpcInternalId[entity] % seed1))
		{
			Elemental_AddWarpedDamage(entity, entity, (Rogue_GetFloor() + 1) * 1000, false, _, true);

			if(Elemental_DamageRatio(entity, Element_Warped) > 0.0)
			{
				fl_Extra_MeleeArmor[entity] /= 3.0;
				fl_Extra_RangedArmor[entity] /= 3.0;
				fl_Extra_Speed[entity] *= 1.2;
			}
		}
	}
}

public void Rogue_RiftWarp_StageEnd()
{
	Rogue_RemoveNamedArtifact("Rift of Warp");
}

public void Rogue_StoneFractured_Collect()
{
	Rogue_AddUmbral(-5, true);
}

public void Rogue_StoneFractured_FloorChange()
{
	Rogue_AddUmbral(-5);
}

public void Rogue_StoneFractured_Remove()
{
	if(!Rogue_HasNamedArtifact("Rift of Fractured") && !Rogue_HasNamedArtifact("The Shadow"))
	{
		Rogue_GiveNamedArtifact("Rift of Fractured");

		if(!Rogue_HasNamedArtifact("Bob's Assistance"))
			Rogue_GiveNamedArtifact("Bob's Assistance", true);
	}
}

public float Rogue_Encounter_Rift2()
{
	Rogue_SetBattleIngots(12);
	Rogue_RemoveNamedArtifact("Rift of Fractured");

	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_Rift2, "We Are Fractured Lore");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "We Are Fractured Option 1");
	strcopy(vote.Desc, sizeof(vote.Desc), "We Are Fractured Desc 1");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "We Are Fractured Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}
public void Rogue_Vote_Rift2(const Vote vote, int index)
{
	switch(index)
	{
		case 0:
		{
			Rogue_StartThisBattle(5.0);
			Rogue_GiveNamedArtifact("The Shadow");
			PrintToChatAll("%t", "We Are Fractured Lore 1");
		}
		case 1:
		{
			PrintToChatAll("%t", "We Are Fractured Lore 2");
		}
	}
}

public void Rogue_Rift2_Collect(int entity)
{
	Rogue_AddUmbral(-100, true);

	if(!Rogue_HasNamedArtifact("Reila Assistance"))
		Rogue_GiveNamedArtifact("Reila Assistance", true);
}

public void Rogue_Rift2_Enemy(int entity)
{
	if(i_NpcInternalId[entity] == FallenWarrior_ID())
	{
		Elemental_AddWarpedDamage(entity, entity, 10, false, _, true);

		if(Elemental_DamageRatio(entity, Element_Warped) > 0.0)
		{
			fl_Extra_MeleeArmor[entity] /= 100.0;
			fl_Extra_RangedArmor[entity] /= 100.0;
		}
	}
}


public void Rogue_IncorruptableLeaf_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
	if(GetTeam(victim) != TFTeam_Red)
		return;

	bool GiveRes = false;
	if(victim <= MaxClients)
	{
		if(Armor_Charge[victim] < 1)
		{
			GiveRes = true;
		}
	}
	else
	{
		if(Elemental_HasDamage(victim))
		{
			GiveRes = true;
		}
	}
	if(GiveRes)
		if(!(damagetype & DMG_TRUEDAMAGE))
			damage *= 0.85;
}

stock float Rogue_Rift_OptionalBonusBattle()
{
	ArrayList list = Rogue_CreateGenericVote(FinishOptionalBonusBattle, "A strange gateway opens up");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Stay and fight it");
	strcopy(vote.Desc, sizeof(vote.Desc), "Enter a special battle");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Better leave now");
	strcopy(vote.Desc, sizeof(vote.Desc), "Better leave now");
	vote.Config[0] = 0;
	list.PushArray(vote);

	Rogue_StartGenericVote(15.0);
	return 20.0;
}

static void FinishOptionalBonusBattle(const Vote vote2, int index)
{
	if(index == 0)
	{
		Vote vote;
		strcopy(vote.Config, sizeof(vote.Config), "Strange Gateway");	// Name of stage to look up
		vote.Level = 2;
		Rogue_Vote_NextStage(vote);
	}
}