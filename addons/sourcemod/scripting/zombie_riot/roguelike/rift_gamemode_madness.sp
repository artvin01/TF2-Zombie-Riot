#pragma semicolon 1
#pragma newdecls required


//added a space beacuse of name overrides
static const char g_RandomPlayerName[][] = 
{
	" kevinmery2009",
	" jDavid",
	" Unknown(fish)",
	" Samuu",
	" Mened",
	" Shabadu",
	" Monoflak",
	" Dorian",
	" Lucella",
	" Bouncer",
	" Fire",
	" bucket",
	" Biohunter",
	" Emberflame FoxHeart",
	" MadeInQuick",
	" SimplySmiley",
	" salty_bert",
	" light",
	" asyashi",
	" BeepG",
	" MetaB",
	" Artvin",
	" Batfoxkid",
	" Crust",
	" Artorias",
	" CocoTM",
	" Robotnik",
	" Forged Identity",
	" Undenied_Player",
	" PubScrubLord",
	" rivesid",
	" Mikusch",
	" EthanTheRedHead",
	" Juice",
	" Hun oli",
	" Mr. Phil",
	" Windflow",
	" Gravina",
	" Pinkie",
	" catorgator",
	" 42",
	" <#F00>Serafeline",
	" CzechMate",
	" Dencube",
	" Drandor",
	" IHaveAToaster",
	" infinite phantasm",
	" JuneOrJuly",
	" Kamuixmod",
	" literail",
	" Mr-Fluf",
	" Alex Turtle",
	" Octa",
	" Dunwall",
	" okra",
	" Black_Knight",
	" GeeNoVoid",
	" Serrt",
	" Jonkster",
	" GiovaJag",
	" Heisenbones",
	" matej",
	" miru",
	" Polybius",
	" rake",
	" notalex",
	" Haxton",
	" wo",
	" knightriderx25",
	" Star in a pond",
	" Flareinferno",
	" Vegatwo",
	" pokemonPasta",
	" GaleDynasty",
	" Owlbine",
	" ♫ SENSAL ♫",
	" Tori",
	" Baka",
	" Tumby",
	" Trobby",
	" xtrem_spook",
	" spindel",
	" Nakiさん",
	" Cosmo",
	" GAIDA BG",
	" spootis",
	" MrCow",
	" Robin :3 (she/her)",
	" Zati",
	" Canardé",
	" Zettabyte",
	" A Suicidal Soldier",
	" A Fairy With a Pan",
	" Pandrodor",
	" Minealberto112",
	" ★PedritoGMG★",
	" Sphynx♡",
	" The man of fent",
	" Clearwater",
	" Igor",
	" Zati",
	" CookieCat",
	" BagelBites",
	" ihop",
	" Spookmaster",
	" Xamad",
	" ★Dr.Heals ㅇㅅㅇ",
	" ★GANGST The Trackpad Gamer★",
	" synthakii",
	" Syko",
	" Pasta Stalin",
	" Flaming",
	" Rodz",
	" Solace",
	" Pandora✔",
	" bob",
	" Box",
	" Greed",
	" LewandaSillyFeathers",
	" eno",
	" tocks",
	" West.",
	" FurretX",
	" Vesp",
	" UberMedicFully",
	" Clone",
	" Kitteh",
	" LeAlex14"
};

static ArrayList TemporaryRebelList;

public float Rogue_Encounter_GamemodeMadnessBattle()
{
	Rogue_GamemodeMadness_TryToEnableURF();
	Rogue_GiveNamedArtifact("Gamemode Madness", true);
	Rogue_SetBattleIngots(10);
	return 0.0;
}

public float Rogue_Encounter_GamemodeMadnessBattle_SZF()
{
	Rogue_GamemodeMadness_TryToEnableURF();
	CPrintToChatAll("%t", "SZF Damage Scaling Mode");
	Rogue_GiveNamedArtifact("Gamemode Madness SZF", true);
	Rogue_SetBattleIngots(10);
	return 0.0;
}

public float Rogue_Encounter_GamemodeMadnessBattle_Slender()
{
	Rogue_GiveNamedArtifact("Gamemode Madness Slender", true);
	return 0.0;
}

public float Rogue_Encounter_GamemodeMadnessBattle_ZombieRiot()
{
	Rogue_GamemodeMadness_TryToEnableURF();
	Rogue_GiveNamedArtifact("Gamemode Madness Zombie Riot", true);
	Rogue_SetBattleIngots(10);
	RequestFrame(StartZombieRiotFrame);
	return 0.0;
}

public void Rogue_RiftWarp_GamemodeMadness()
{
	if(Rogue_HasNamedArtifact("Gamemode Madness"))
		Rogue_RemoveNamedArtifact("Gamemode Madness");
	
	if(Rogue_HasNamedArtifact("Gamemode Madness SZF"))
		Rogue_RemoveNamedArtifact("Gamemode Madness SZF");
	
	if(Rogue_HasNamedArtifact("Gamemode Madness Slender"))
		Rogue_RemoveNamedArtifact("Gamemode Madness Slender");
	
	if(Rogue_HasNamedArtifact("Gamemode Madness Zombie Riot"))
		Rogue_RemoveNamedArtifact("Gamemode Madness Zombie Riot");
	
	if(Rogue_HasNamedArtifact("Gamemode Madness URF"))
		Rogue_RemoveNamedArtifact("Gamemode Madness URF");
}

public void Rogue_GamemodeMadnessSlender_StartStage()
{
	RequestFrame(StartSlenderFrame);
}

public void StartSlenderFrame()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			i_AmountDowned[client] = 99;

			if(IsPlayerAlive(client))
				SDKHooks_UpdateMarkForDeath(client);
		}
	}

	Rogue_Dome_WaveEnd();
}

public void Rogue_GamemodeMadnessSlender_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;

		// -25% movement speed
		value = 1.0;
		map.GetValue("107", value);
		map.SetValue("107", value * 0.75);
	}
}
public void Rogue_GamemodeMadnessSlender_Enemy(int entity)
{
	SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", 600.0);
	SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", 1000.0);
	b_ThisEntityIgnoredByOtherNpcsAggro[entity] = true;
}

public void StartZombieRiotFrame()
{
	if (!TemporaryRebelList)
		TemporaryRebelList = new ArrayList();
	else
		TemporaryRebelList.Clear();
	
	int client;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			client = i;
			break;
		}
	}
	
	int MedicRangedWeapons[] = {
		Cit_Pistol,
		Cit_SMG,
		Cit_AR
	};
	
	int DPSRangedWeapons[] = {
		Cit_Shotgun,
		Cit_SMG,
		Cit_AR,
		Cit_RPG
	};
	
	// Spawn in 20 renamed rebels
	for (int i = 0; i < 20; i++)
	{
		int spawnNpc = Citizen_SpawnAtPoint("", client);
		Citizen npc = view_as<Citizen>(spawnNpc);
		Rogue_GamemodeMadness_EnemyRename(spawnNpc);
		fl_Extra_Damage[spawnNpc] *= 2.5;
		//5x dmg
		
		// We select rebel types/roles ourselves because we want no builders and less medics than Citizen_SetRandomRole offers
		int role, type;
		
		switch (i % 5)
		{
			case 0:
			{
				// 1 in 5 rebels will be medics
				role = Cit_Medic;
				type = MedicRangedWeapons[GetURandomInt() % sizeof(MedicRangedWeapons)];
			}
			
			case 1:
			{
				// 1 in 5 rebels will be tanks
				role = Cit_Fighter;
				type = Cit_Melee;
			}
			
			default:
			{
				// The rest will be DPS
				role = Cit_Fighter;
				type = DPSRangedWeapons[GetURandomInt() % sizeof(DPSRangedWeapons)];
			}
		}
		
		Citizen_UpdateStats(spawnNpc, type, role);
		
		RogueHelp_BodyHealth(spawnNpc, null, 3.0);
		fl_Extra_Damage[spawnNpc] *= 2.0;
		npc.m_bInteractable = false;
		npc.m_bDissapearOnDeath = true;
		
		TemporaryRebelList.Push(EntIndexToEntRef(spawnNpc));
	}
	//update scalig now
	DoGlobalMultiScaling();
	Rogue_Dome_WaveEnd();
}

public void Rogue_GamemodeMadnessZombieRiot_EndStage()
{
	Rogue_RiftWarp_GamemodeMadness();
	Rogue_GiveNamedArtifact("Zombie Riot Badge", false);
	
	if (!TemporaryRebelList)
		return;
	
	int length = TemporaryRebelList.Length;
	for (int i = 0; i < length; i++)
	{
		int ref = TemporaryRebelList.Get(i);
		int entity = EntRefToEntIndex(ref);
		if (IsValidEntity(entity))
			SmiteNpcToDeath(entity);
	}
	
	delete TemporaryRebelList;
}

public void Rogue_GamemodeMadness_Item_ZombieRiotBadge()
{
	CurrentCash += 200;
	GlobalExtraCash += 200;	
}

public void Rogue_GamemodeMadness_EnemyRenameSZF(int entity)
{
	Rogue_GamemodeMadness_EnemyRename(entity);
	ApplyStatusEffect(entity, entity, "Damage Scaling", 9999.9);

}
public void Rogue_GamemodeMadness_EnemyRename(int entity)
{
	//dont touch buildings.
	if(i_NpcIsABuilding[entity])
		return;
		
	strcopy(c_NpcName[entity], sizeof(c_NpcName[]), g_RandomPlayerName[GetRandomInt(0, sizeof(g_RandomPlayerName) - 1)]);
	b_NameNoTranslation[entity] = true;


	//inside joke that they are mega tryhards
	if(StrEqual(c_NpcName[entity], " Artorias", false) ||
	 StrEqual(c_NpcName[entity], " Hun oli", false) ||
	 StrEqual(c_NpcName[entity], " Pinkie", false) ||
	 StrEqual(c_NpcName[entity], " CocoTM", false) ||
	 StrEqual(c_NpcName[entity], " Juice", false) ||
	 StrEqual(c_NpcName[entity], " asyashi", false) ||
	 StrEqual(c_NpcName[entity], " ♫ SENSAL ♫", false) ||
	  StrEqual(c_NpcName[entity], " Haxton", false))
	{
		fl_Extra_Speed[entity] 				*= 1.35;
		fl_Extra_Damage[entity] 			*= 2.0;
		f_AttackSpeedNpcIncrease[entity] 	*= 0.6;
		RogueHelp_BodyHealth(entity, null, 				   2.0);
	}
	else
	{
		fl_Extra_Speed[entity] 				*= GetRandomFloat(0.95, 1.35);
		fl_Extra_Damage[entity] 			*= GetRandomFloat(0.95, 1.35);
		f_AttackSpeedNpcIncrease[entity] 	*= GetRandomFloat(0.75, 1.05);
		RogueHelp_BodyHealth(entity, null, 				   GetRandomFloat(0.95, 1.35));
		float AfkTimer = GetRandomFloat(0.5, 2.0);
		FreezeNpcInTime(entity, AfkTimer);
		ApplyStatusEffect(entity, entity, "UBERCHARGED",	AfkTimer);
	}
	TeleportDiversioToRandLocation(entity,_,3000.0, 1500.0, .NeedLOSPlayer = true);
}

public void Rogue_GamemodeMadness_TryToEnableURF()
{
	if (GetURandomFloat() >= 0.1) // 10% to enable
		return;
	
	Rogue_GiveNamedArtifact("Gamemode Madness URF", true);
	CPrintToChatAll("%t", "Gamemode Madness URF Mode");
	EmitGameSoundToAll("Powerup.PickUpSupernova");
}

public void Rogue_GamemodeMadnessURF_Enemy(int entity)
{
	ApplyStatusEffect(entity, entity, "Dimensional Turbulence", 99999.0);
}

public void Rogue_GamemodeMadnessURF_Ally(int entity, StringMap map)
{
	if (map) // Player
	{
		// Players don't get affected by movement speed buffs, so we apply a second one here
		RogueHelp_BodySpeed(entity, map, 1.25);
	}
	
	ApplyStatusEffect(entity, entity, "Ultra Rapid Fire", 99999.0);
}

public void Rogue_GamemodeMadnessURF_Remove()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
			RemoveSpecificBuff(i, "Ultra Rapid Fire");
	}
	
	for (int i = 0; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if (entity != INVALID_ENT_REFERENCE)
			RemoveSpecificBuff(i, "Ultra Rapid Fire");
	}
	
	Rogue_Refresh_Remove();
}