#pragma semicolon 1
#pragma newdecls required


//added a space beacuse of name overrides
char g_RandomPlayerName[][] = 
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
	" Screwdriver",
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
	" spinel",
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
};


public float Rogue_Encounter_GamemodeMadnessBattle()
{
	Rogue_GiveNamedArtifact("Gamemode Madness", true);
	Rogue_SetBattleIngots(10);
	return 0.0;
}

public float Rogue_Encounter_GamemodeMadnessBattle_SZF()
{
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

public void Rogue_RiftWarp_GamemodeMadness()
{
	if(Rogue_HasNamedArtifact("Gamemode Madness"))
		Rogue_RemoveNamedArtifact("Gamemode Madness");
	
	if(Rogue_HasNamedArtifact("Gamemode Madness SZF"))
		Rogue_RemoveNamedArtifact("Gamemode Madness SZF");
	
	if(Rogue_HasNamedArtifact("Gamemode Madness Slender"))
		Rogue_RemoveNamedArtifact("Gamemode Madness Slender");
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

public void Rogue_GamemodeMadness_EnemyRenameSZF(int entity)
{
	Rogue_GamemodeMadness_EnemyRename(entity);
	ApplyStatusEffect(entity, entity, "Damage Scaling", 9999.9);

}
public void Rogue_GamemodeMadness_EnemyRename(int entity)
{
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
		fl_Extra_Speed[entity] 				*= 1.55;
		fl_Extra_Damage[entity] 			*= 2.5;
		f_AttackSpeedNpcIncrease[entity] 	*= 0.4;
		MultiHealth(entity, 				   3.0);
	}
	else
	{
		fl_Extra_Speed[entity] 				*= GetRandomFloat(0.95, 1.35);
		fl_Extra_Damage[entity] 			*= GetRandomFloat(0.95, 1.35);
		f_AttackSpeedNpcIncrease[entity] 	*= GetRandomFloat(0.75, 1.05);
		MultiHealth(entity, 				   GetRandomFloat(0.95, 1.35));
		float AfkTimer = GetRandomFloat(0.5, 2.0);
		FreezeNpcInTime(entity, AfkTimer);
		ApplyStatusEffect(entity, entity, "UBERCHARGED",	AfkTimer);
	}
	TeleportDiversioToRandLocation(entity,_,3000.0, 1500.0, .NeedLOSPlayer = true);
}

static void MultiHealth(int entity, float amount)
{
	SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * amount));
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(ReturnEntityMaxHealth(entity) * amount));
}