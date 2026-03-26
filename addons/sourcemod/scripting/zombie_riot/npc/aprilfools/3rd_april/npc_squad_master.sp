#pragma semicolon 1
#pragma newdecls required


void SquadX_Master_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mazeat Fabulous Squad X Elite, Solvence of Cringe");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_squad_master");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static const char g_ExplosionSoundDo[][] = {
	"items/cart_explode.wav",
};
static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_ExplosionSoundDo));	   i++) { PrecacheSound(g_ExplosionSoundDo[i]);	   }
	PrecacheSoundCustom("#zombiesurvival/aprilfools/mazeat_fabulous_squad_x.mp3");
	NPC_GetByPlugin("npc_squad_bob");
	NPC_GetByPlugin("npc_squad_omega");
	NPC_GetByPlugin("npc_squad_shadowing_darkness");
	NPC_GetByPlugin("npc_squad_whiteflower");
	AddToDownloadsTable("materials/zombie_riot/overlays/leper_overlay.vtf");
	AddToDownloadsTable("materials/zombie_riot/overlays/leper_overlay.vmt");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return SquadX_Master(vecPos, vecAng, team, data);
}

methodmap SquadX_Master < CClotBody
{
	property int m_iAppearState
	{
		public get()							{ return i_State[this.index]; }
		public set(int TempValueForProperty) 	{ i_State[this.index] = TempValueForProperty; }
	}
	property float m_flTimeUntillNextAppear
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flTimeUntillNextAppearFreeze
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flWaitOnTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property int m_iGetTimeDo
	{
		public get()							{ return i_AttacksTillReload[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillReload[this.index] = TempValueForProperty; }
	}
	public void PlayExplodeSound() 
	{
		int sound = GetRandomInt(0, sizeof(g_ExplosionSoundDo) - 1);
		EmitSoundToAll(g_ExplosionSoundDo[sound], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_ExplosionSoundDo[sound], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_ExplosionSoundDo[sound], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public SquadX_Master(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		SquadX_Master npc = view_as<SquadX_Master>(CClotBody(vecPos, {0.0,0.0,0.0}, "models/empty.mdl", "1.0", "40000", ally, _, _, true, false));
		i_NpcWeight[npc.index] = 999;
		npc.m_flNextMeleeAttack = 0.0;
		strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "?????????????");
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);

		
		b_thisNpcIsARaid[npc.index] = true;
		npc.m_bThisNpcIsABoss = true;
		b_NoHealthbar[npc.index] = 1;

		
		b_NpcUnableToDie[npc.index] = true;

		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			float value = StringToFloat(buffers[0]);
			RaidModeScaling = value;

			if(RaidModeScaling < 35)
			{
				RaidModeScaling *= 0.25; //abit low, inreacing
			}
			else
			{
				RaidModeScaling *= 0.5;
			}

			if(value > 40.0)
			{
				RaidModeScaling *= 0.85;
			}
			
		}
		else
		{	
			RaidModeScaling = float(Waves_GetRoundScale()+1);
			if(RaidModeScaling < 35)
			{
				RaidModeScaling *= 0.25; //abit low, inreacing
			}
			else
			{
				RaidModeScaling *= 0.5;
			}
				
			if(Waves_GetRoundScale()+1 > 25)
			{
				RaidModeScaling *= 0.85;
			}
		}
		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		npc.m_flWaitOnTime = 1.0;
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff

		npc.m_iGetTimeDo = GetTime();
		RemoveAllDamageAddition();
		return npc;
	}
}

static void Internal_ClotThink(int iNPC)
{
	SquadX_Master npc = view_as<SquadX_Master>(iNPC);
	if(npc.m_flWaitOnTime)
	{
		if(npc.m_iGetTimeDo != GetTime())
		{
			//sync up!!!
			npc.m_flTimeUntillNextAppear = GetGameTime(npc.index) + 3.0;
			npc.m_flTimeUntillNextAppearFreeze = 8.4;
			RaidModeTime = GetGameTime(npc.index) + 200.0;
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidAllowsBuildings = false;
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/aprilfools/mazeat_fabulous_squad_x.mp3");
			music.Time = 164;
			music.Volume = 1.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Pokeminaj XY - Team Flanaconda boss Battle (Mashup)");
			strcopy(music.Artist, sizeof(music.Artist), "Delak");
			Music_SetRaidMusic(music);
			npc.m_flWaitOnTime = 0.0;
		}
		else
		{
			return;
		}

		
	}
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;

	//delete all koulms
	int inpcloop1, a1;
	int CurrentHealth;
	int CurrentMaxHealth;
	while((inpcloop1 = FindEntityByNPC(a1)) != -1)
	{
		if(IsValidEntity(inpcloop1) && (
			i_NpcInternalId[inpcloop1] == SquadX_WhiteflowerIDReturn() ||
			i_NpcInternalId[inpcloop1] == SquadX_Shadowing_DarknessIDReturn() ||
			i_NpcInternalId[inpcloop1] == SquadX_OmegaIDReturn() ||
			i_NpcInternalId[inpcloop1] == SquadX_BobIDReturn()
			))
		{
			CurrentHealth += GetEntProp(inpcloop1, Prop_Data, "m_iHealth");
			CurrentMaxHealth += ReturnEntityMaxHealth(inpcloop1);
		}
	}

	SetEntProp(npc.index, Prop_Data, "m_iHealth", CurrentHealth);
	SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", CurrentMaxHealth);

	if(npc.m_flTimeUntillNextAppear > GetGameTime(npc.index))
	{
		return;
	}
	if(npc.m_iAppearState >= 6)
		return;
	float SpawnPos[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", SpawnPos);
	switch(npc.m_iAppearState)
	{
		case 0:
		{
			
			int viewcontrol = CreateEntityByName("prop_dynamic");
			if (IsValidEntity(viewcontrol))
			{
				float OriginCamrea[3];
				OriginCamrea = SpawnPos;
				OriginCamrea[0] += 150.0;
				OriginCamrea[2] += 50.0;
				SetEntityModel(viewcontrol, "models/empty.mdl");
				DispatchKeyValueVector(viewcontrol, "origin", OriginCamrea);
				DispatchKeyValueVector(viewcontrol, "angles", {0.0, -180.0,0.0});
				DispatchSpawn(viewcontrol);	
				npc.m_iWearable1 = viewcontrol;
			}
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && GetClientTeam(client) == 2)
				{
					DoOverlay(client, "zombie_riot/overlays/leper_overlay", 0);
					SetEntProp(client, Prop_Send, "m_iHideHUD", HIDEHUD_ALL); 
					ForceClientViewOntoEntity(client, npc.m_iWearable1);
					SetEntityFlags(client, GetEntityFlags(client)|FL_FROZEN|FL_ATCONTROLS);
				}
			}
			float OriginText[3];
			OriginText = SpawnPos;
			OriginText[0] += 55.0;
			OriginText[2] += 75.0;
			OriginText[1] += 15.0;
			int WorldText = SpawnFormattedWorldText("Mazeat", OriginText, 11, {255,125,125,255}, -1, false, false);
			CreateTimer(npc.m_flTimeUntillNextAppearFreeze, Timer_RemoveEntity, EntIndexToEntRef(WorldText), TIMER_FLAG_NO_MAPCHANGE);
			SpawnPos[1] -= 15.0;
			CreateEarthquake(SpawnPos, 0.5, 9999.9, 35.0, 255.0);
			npc.m_flTimeUntillNextAppear = GetGameTime(npc.index) + 1.5;
			int spawn_index = NPC_CreateByName("npc_squad_bob", -1, SpawnPos, {0.0,0.0,0.0}, GetTeam(npc.index));
			if(spawn_index > 0)
			{
				CClotBody npc1 = view_as<CClotBody>(spawn_index);
				FreezeNpcInTime(spawn_index, npc.m_flTimeUntillNextAppearFreeze);
				npc.m_flTimeUntillNextAppearFreeze -= 1.5;
			}
		}
		case 1:
		{
			float OriginText[3];
			OriginText = SpawnPos;
			OriginText[0] += 55.0;
			OriginText[2] += 55.0;
			OriginText[1] -= 15.0;
			int WorldText = SpawnFormattedWorldText("Fabulous Squad", OriginText, 11, {125,255,125,255}, -1, false, false);
			CreateTimer(npc.m_flTimeUntillNextAppearFreeze, Timer_RemoveEntity, EntIndexToEntRef(WorldText), TIMER_FLAG_NO_MAPCHANGE);
			SpawnPos[1] -= 30.0;
			CreateEarthquake(SpawnPos, 0.5, 9999.9, 35.0, 255.0);
			npc.m_flTimeUntillNextAppear = GetGameTime(npc.index) + 1.5;
			int spawn_index = NPC_CreateByName("npc_squad_omega", -1, SpawnPos, {0.0,0.0,0.0}, GetTeam(npc.index));
			if(spawn_index > 0)
			{
				CClotBody npc1 = view_as<CClotBody>(spawn_index);
				FreezeNpcInTime(spawn_index, npc.m_flTimeUntillNextAppearFreeze);
				npc.m_flTimeUntillNextAppearFreeze -= 1.5;
			}
		}
		case 2:
		{
			
			float OriginText[3];
			OriginText = SpawnPos;
			OriginText[0] += 55.0;
			OriginText[2] += 25.0;
			OriginText[1] += 25.0;
			int WorldText = SpawnFormattedWorldText("Squad", OriginText, 11, {125,125,255,255}, -1, false, false);
			CreateTimer(npc.m_flTimeUntillNextAppearFreeze, Timer_RemoveEntity, EntIndexToEntRef(WorldText), TIMER_FLAG_NO_MAPCHANGE);
			SpawnPos[1] += 30.0;
			CreateEarthquake(SpawnPos, 0.5, 9999.9, 35.0, 255.0);
			npc.m_flTimeUntillNextAppear = GetGameTime(npc.index) + 1.5;
			int spawn_index = NPC_CreateByName("npc_squad_shadowing_darkness", -1, SpawnPos, {0.0,0.0,0.0}, GetTeam(npc.index));
			if(spawn_index > 0)
			{
				CClotBody npc1 = view_as<CClotBody>(spawn_index);
				FreezeNpcInTime(spawn_index, npc.m_flTimeUntillNextAppearFreeze);
				npc.m_flTimeUntillNextAppearFreeze -= 1.5;
			}
		}
		case 3:
		{
			float OriginText[3];
			OriginText = SpawnPos;
			OriginText[0] += 55.0;
			OriginText[2] += 15.0;
			OriginText[1] -= 25.0;
			int WorldText = SpawnFormattedWorldText("X Elite", OriginText, 13, {125,255,255,255}, -1, true, false);
			CreateTimer(npc.m_flTimeUntillNextAppearFreeze, Timer_RemoveEntity, EntIndexToEntRef(WorldText), TIMER_FLAG_NO_MAPCHANGE);
			
			SpawnPos[0] += 15.0;
			SpawnPos[1] += 15.0;
			SpawnPos[2] += 85.0;
			CreateEarthquake(SpawnPos, 0.5, 9999.9, 35.0, 255.0);
			npc.m_flTimeUntillNextAppear = GetGameTime(npc.index) + 1.5;
			int spawn_index = NPC_CreateByName("npc_squad_whiteflower", -1, SpawnPos, {0.0,0.0,0.0}, GetTeam(npc.index));
			if(spawn_index > 0)
			{
				CClotBody npc1 = view_as<CClotBody>(spawn_index);
				FreezeNpcInTime(spawn_index, npc.m_flTimeUntillNextAppearFreeze);
				npc.m_flTimeUntillNextAppearFreeze -= 1.5;
			}
		}
		case 4:
		{
			float OriginText[3];
			OriginText = SpawnPos;
			OriginText[0] += 55.0;
			OriginText[2] += 10.0;
		//	OriginText[1] -= 25.0;
			int WorldText = SpawnFormattedWorldText("(Solvence of Cringe)", OriginText, 4, {255,255,255,255}, -1, true, false);
			CreateTimer(npc.m_flTimeUntillNextAppearFreeze, Timer_RemoveEntity, EntIndexToEntRef(WorldText), TIMER_FLAG_NO_MAPCHANGE);

			strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "Mazeat Fabulous Squad X Elite, Solvence of Cringe");
			npc.m_flTimeUntillNextAppear = GetGameTime(npc.index) + 3.0;
			npc.PlayExplodeSound();
			CreateEarthquake(SpawnPos, 3.0, 9999.9, 35.0, 255.0);
			TE_Particle("hightower_explosion", SpawnPos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			TE_Particle("grenade_smoke_cycle", SpawnPos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
		}
		case 5:
		{
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					SetEntityFlags(client, GetEntityFlags(client) & ~(FL_FROZEN | FL_ATCONTROLS));
					SetClientViewEntity(client, client);
					Thirdperson_PlayerSpawn(client);
					DoOverlay(client, "", 0);
					SetEntProp(client, Prop_Send, "m_iHideHUD", HIDEHUD_BUILDING_STATUS | HIDEHUD_CLOAK_AND_FEIGN | HIDEHUD_BONUS_PROGRESS); 
				}
			}
			ClearAllCameras();
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			//revert cameras do
		}
	}
	npc.m_iAppearState++;

}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	SquadX_Master npc = view_as<SquadX_Master>(victim);
	
	//cant be hurt, but shouldnt appear in hud
	damage = 0.0;
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	SquadX_Master npc = view_as<SquadX_Master>(entity);
}