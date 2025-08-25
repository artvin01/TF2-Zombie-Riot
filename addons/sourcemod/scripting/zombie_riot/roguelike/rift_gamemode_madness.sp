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
	" Baka"
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
	Rogue_RemoveNamedArtifact("Gamemode Madness");
	Rogue_RemoveNamedArtifact("Gamemode Madness SZF");
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

public void Rogue_GamemodeMadness_EnemyRenameSZF(int entity)
{
	Rogue_GamemodeMadness_EnemyRename(entity);
	ApplyStatusEffect(entity, entity, "Damage Scaling", 9999.9);

}
public void Rogue_GamemodeMadness_EnemyRename(int entity)
{
	strcopy(c_NpcName[entity], sizeof(c_NpcName[]), g_RandomPlayerName[GetRandomInt(0, sizeof(g_RandomPlayerName) - 1)]);
	b_NameNoTranslation[entity] = true;

	fl_Extra_Speed[entity] 				*= GetRandomFloat(0.75, (1.0 / 0.75));
	fl_Extra_Damage[entity] 			*= GetRandomFloat(0.75, (1.0 / 0.75));
	f_AttackSpeedNpcIncrease[entity] 	*= GetRandomFloat(0.75, (1.0 / 0.75));
	MultiHealth(entity, 				   GetRandomFloat(0.75, (1.0 / 0.75)));

	//inside joke that they are mega tryhards
	if(StrEqual(c_NpcName[entity], "Artorias", false) || StrEqual(c_NpcName[entity], "Hun oli", false) || StrEqual(c_NpcName[entity], "Haxton", false))
	{
		fl_Extra_Speed[entity] 				*= 1.2;
		fl_Extra_Damage[entity] 			*= 1.45;
		f_AttackSpeedNpcIncrease[entity] 	*= 0.55;
		MultiHealth(entity, 				   2.0);
	}
	else
	{
		float AfkTimer = GetRandomFloat(1.5, 2.0);
		FreezeNpcInTime(entity, AfkTimer);
		ApplyStatusEffect(entity, entity, "UBERCHARGED",	AfkTimer);
	}
	TeleportDiversioToRandLocation(entity,_,3000.0, 1000.0);
}

static void MultiHealth(int entity, float amount)
{
	SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * amount));
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(ReturnEntityMaxHealth(entity) * amount));
}