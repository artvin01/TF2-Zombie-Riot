#pragma semicolon 1
#pragma newdecls required

#undef CONSTRUCT_NAME
#undef CONSTRUCT_RESOURCE1
#undef CONSTRUCT_RESOURCE2
#undef CONSTRUCT_COST1
#undef CONSTRUCT_COST2
#undef CONSTRUCT_MAXLVL
#undef CONSTRUCT_DAMAGE
#undef CONSTRUCT_FIRERATE
#undef CONSTRUCT_RANGE
#undef CONSTRUCT_MAXCOUNT

#define CONSTRUCT_NAME		"Mortar"
#define CONSTRUCT_RESOURCE1	"copper"
#define CONSTRUCT_COST1		(20 + (CurrentLevel * 10))
#define CONSTRUCT_MAXLVL	ObjectDungeonCenter_Level()
#define CONSTRUCT_DAMAGE	(400.0 * Pow(level + 2.0, 2.0))
#define CONSTRUCT_FIRERATE	5.0
#define CONSTRUCT_RANGE		2000.0
#define CONSTRUCT_MAXCOUNT	(1 + level)

static int NPCId;
static int LastGameTime;
static int CurrentLevel;

void ObjectDMortar_MapStart()
{
	LastGameTime = -1;
	CurrentLevel = 0;

	PrecacheModel("models/zombie_riot/buildings/mortar_2.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), CONSTRUCT_NAME);
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_dungeon_mortar");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 3;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_dungeon_mortar");
	build.Cost = 600;
	build.Health = 200;
	build.Cooldown = 30.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectDMortar(client, vecPos, vecAng);
}

methodmap ObjectDMortar < ObjectGeneric
{
	public ObjectDMortar(int client, const float vecPos[3], const float vecAng[3])
	{
		if(LastGameTime != CurrentGame)
		{
			CurrentLevel = 0;
			LastGameTime = CurrentGame;
		}

		ObjectDMortar npc = view_as<ObjectDMortar>(ObjectGeneric(client, vecPos, vecAng, "models/zombie_riot/buildings/mortar_2.mdl", "1.4", "50", {30.0, 30.0, 200.0},_,false));

		npc.SetActivity("MORTAR_IDLE");
		npc.m_iChanged_WalkCycle = 0;
		
		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCThink[npc.index] = ClotThink;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCInteract[npc.index] = ClotInteract;
		func_NPCDeath[npc.index] = Dungeon_BuildingDeath;
		SetRotateByDefaultReturn(npc.index, 180.0);

		return npc;
	}
}

static void ClotThink(ObjectDMortar npc)
{
	float gameTime = GetGameTime(npc.index);

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime - CONSTRUCT_FIRERATE)
		{
			if(npc.m_iChanged_WalkCycle != 1)
			{
				npc.m_iChanged_WalkCycle = 1;
				float pos_obj[3];
				GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos_obj);
				pos_obj[2] += 100.0;
				npc.SetActivity("MORTAR_RELOAD");		
				EmitSoundToAll(MORTAR_RELOAD, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, pos_obj);
			}
		}
		else if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			npc.SetActivity("MORTAR_IDLE");
			npc.m_iChanged_WalkCycle = 0;
		}
		return;
	}

	int owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(owner == -1)
		owner = npc.index;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, _, CONSTRUCT_RANGE, .CanSee = false, .UseVectorDistance = true, .MinimumDistance = 300.0);
		npc.m_flGetClosestTargetTime = FAR_FUTURE;
	}
	
	if(!IsValidEnemy(npc.index, npc.m_iTarget))
	{
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		if(GetTeam(npc.index) != TFTeam_Red)
			npc.m_flNextDelayTime = gameTime + ENEMY_BUILDING_DELAY_THINK;
		return;
	}

	float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);

	float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
	if(flDistanceToTarget >= (CONSTRUCT_RANGE * CONSTRUCT_RANGE) || flDistanceToTarget < (300.0 * 300.0))
	{
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		if(GetTeam(npc.index) != TFTeam_Red)
			npc.m_flNextDelayTime = gameTime + ENEMY_BUILDING_DELAY_THINK;
		return;
	}

	DBuildingMortarAction(npc.m_iTarget, owner, npc.index);
}

//todo: When pressing E, Actives All Building stuff
static void DBuildingMortarAction(int enemy, int owner, int mortar)
{
	float spawnLoc[3];
	GetEntPropVector(enemy, Prop_Send, "m_vecOrigin", spawnLoc);
	
	float pos[3];
	
	DataPack pack;
	CreateDataTimer(1.0, DMortarFire_Anims, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(mortar));
	pack.WriteCell(EntIndexToEntRef(owner));
	pack.WriteFloat(spawnLoc[0]);
	pack.WriteFloat(spawnLoc[1]);
	pack.WriteFloat(spawnLoc[2]);
	float position[3];
	position[0] = spawnLoc[0];
	position[1] = spawnLoc[1];
	position[2] = spawnLoc[2];
				
	position[2] += 3000.0;
	float AOE_range = 350.0;
	spawnLoc[2] += 5.0;
	if(GetTeam(mortar) != TFTeam_Red)
	{
		TE_SetupBeamRingPoint(spawnLoc, AOE_range*2.0, 0.0, g_Ruina_BEAM_lightning, g_Ruina_HALO_Laser, 0, 66, 2.0, 30.0, 0.1, {255,255,125,255}, 1, 0);
		TE_SendToAll();
		TE_SetupBeamRingPoint(spawnLoc, AOE_range*2.0, AOE_range*2.0 + 0.1, g_Ruina_BEAM_lightning, g_Ruina_HALO_Laser, 0, 66, 2.0, 30.0, 0.1, {255,255,125,255}, 1, 0);
		TE_SendToAll();
	}
	spawnLoc[2] += 120.0;

	int particle = ParticleEffectAt(position, "kartimpacttrail", 2.0);
	SetEdictFlags(particle, (GetEdictFlags(particle) | FL_EDICT_ALWAYS));
	float pos_obj[3];
	ParticleEffectAt(pos, "utaunt_portalswirl_purple_warp2", 2.0);
	CreateTimer(1.7, MortarFire_Falling_Shot, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);	
	GetEntPropVector(mortar, Prop_Send, "m_vecOrigin", pos_obj);
	pos_obj[2] += 100.0;
	CClotBody npcstats = view_as<CClotBody>(mortar);
	npcstats.m_flAttackHappens = GetGameTime() + CONSTRUCT_FIRERATE;
	ParticleEffectAt(pos_obj, "skull_island_embers", 2.0);
	/*
	int particle1 = ParticleEffectAt(pos_obj, "kartimpacttrail", 2.0);
	SetEdictFlags(particle1, (GetEdictFlags(particle1) | FL_EDICT_ALWAYS));
	CreateTimer(0.25, MortarFire_Falling_Shot_MoveUp, EntIndexToEntRef(particle1), TIMER_FLAG_NO_MAPCHANGE);	
	*/
	EmitSoundToAll(MORTAR_SHOT, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, pos_obj);
}
static Action DMortarFire_Anims(Handle timer, DataPack pack)
{
	pack.Reset();
	int Building = EntRefToEntIndex(pack.ReadCell());
	int owner = EntRefToEntIndex(pack.ReadCell());
	float ParticlePos[3];
	ParticlePos[0] = pack.ReadFloat();
	ParticlePos[1] = pack.ReadFloat();
	ParticlePos[2] = pack.ReadFloat();

	if(IsValidEntity(owner))
	{
		if(IsValidEntity(Building))
		{
			EmitSoundToAll(MORTAR_SHOT_INCOMMING, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.7, SNDPITCH_NORMAL, -1, ParticlePos);
		//	SetColorRGBA(glowColor, r, g, b, alpha);
		//	ParticleEffectAt(ParticlePos, "taunt_flip_land_ring", 1.0);
			DataPack pack2;
			CreateDataTimer(1.0, DMortarFire, pack2, TIMER_FLAG_NO_MAPCHANGE);
			pack2.WriteCell(EntIndexToEntRef(Building));
			pack2.WriteCell(EntIndexToEntRef(owner));
			pack2.WriteFloat(ParticlePos[0]);
			pack2.WriteFloat(ParticlePos[1]);
			pack2.WriteFloat(ParticlePos[2]);
		}	
	}	
	return Plugin_Handled;
}
static Action DMortarFire(Handle timer, DataPack pack)
{
	pack.Reset();
	int Building = EntRefToEntIndex(pack.ReadCell());
	int owner = EntRefToEntIndex(pack.ReadCell());
	float ParticlePos[3];
	ParticlePos[0] = pack.ReadFloat();
	ParticlePos[1] = pack.ReadFloat();
	ParticlePos[2] = pack.ReadFloat();
	if(IsValidEntity(owner))
	{
		if(IsValidEntity(Building))
		{
			int level = CurrentLevel;
			float AOE_range = 350.0;

			Explode_Logic_Custom(CONSTRUCT_DAMAGE, owner, owner, -1, ParticlePos, AOE_range, 0.75, _, false);
			
			CreateEarthquake(ParticlePos, 0.5, 350.0, 16.0, 255.0);
			EmitSoundToAll(MORTAR_BOOM, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.5, SNDPITCH_NORMAL, -1, ParticlePos);
			ParticleEffectAt(ParticlePos, "rd_robot_explosion", 1.0);
		}
	}
	return Plugin_Handled;
}

static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue)
		{
			if(!Dungeon_Mode() || ObjectDungeonCenter_Level() < 1)
			{
				maxcount = 0;
				return false;
			}
		}

		int level = CurrentLevel;
		maxcount = CONSTRUCT_MAXCOUNT;
		if(count >= maxcount)
		{
			maxcount = 0;
			return false;
		}
	}
	
	return true;
}

static int CountBuildings()
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
	{
		if(GetTeam(entity) != TFTeam_Red)
			continue;
		if(NPCId == i_NpcInternalId[entity])
			count++;
	}

	return count;
}


static void ClotShowInteractHud(ObjectGeneric npc, int client)
{
	char viality[64];
	BuildingVialityDisplay(client, npc.index, viality, sizeof(viality));

	if(CurrentLevel >= CONSTRUCT_MAXLVL)
	{
		PrintCenterText(client, "%s\n%t", viality, ObjectDungeonCenter_Level() < ObjectDungeonCenter_MaxLevel() ? "Upgrade Max Limited" : "Upgrade Max");
	}
	else
	{
		SetGlobalTransTarget(client);

		char button[64];
		PlayerHasInteract(client, button, sizeof(button));
		PrintCenterText(client, "%s\n%t", viality, "Upgrade Using Materials", CurrentLevel + 1, CONSTRUCT_MAXLVL + 1, button);
	}
}

static bool ClotInteract(int client, int weapon, ObjectGeneric npc)
{
	ThisBuildingMenu(client);
	return true;
}

static void ThisBuildingMenu(int client)
{
	int amount1 = Construction_GetMaterial(CONSTRUCT_RESOURCE1);

	SetGlobalTransTarget(client);

	Menu menu = new Menu(ThisBuildingMenuH);

	int level = CurrentLevel;
	float damagePre = CONSTRUCT_DAMAGE / CONSTRUCT_FIRERATE * DMGMULTI_CONST2_RED;
	int countPre = CONSTRUCT_MAXCOUNT;

	level = CurrentLevel + 1;
	float damagePost = CONSTRUCT_DAMAGE / CONSTRUCT_FIRERATE * DMGMULTI_CONST2_RED;
	int countPost = CONSTRUCT_MAXCOUNT;
	
	char buffer[64];

	if(CurrentLevel >= CONSTRUCT_MAXLVL)
	{
		menu.SetTitle("%t\n%.0f DPS\n300 ~ %.0f Range\n%d Supply", CONSTRUCT_NAME, damagePre, CONSTRUCT_RANGE, countPre);

		FormatEx(buffer, sizeof(buffer), "Level %d", CurrentLevel + 1);
		menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	}
	else
	{
		menu.SetTitle("%t\n%.0f (+%.0f) DPS\n300 ~ %.0f Range\n%d (+%d) Supply\n ", CONSTRUCT_NAME, damagePre, damagePost - damagePre, CONSTRUCT_RANGE, countPre, countPost - countPre);

		FormatEx(buffer, sizeof(buffer), "%t\n%d / %d %t", "Upgrade Building To", CurrentLevel + 2, amount1, CONSTRUCT_COST1, "Material " ... CONSTRUCT_RESOURCE1);
		menu.AddItem(buffer, buffer, (amount1 < CONSTRUCT_COST1) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}

static int ThisBuildingMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			if(GetClientButtons(client) & IN_DUCK)
			{
				PrintToChat(client, "%T", CONSTRUCT_NAME ... " Desc", client);
				ThisBuildingMenu(client);
			}
			else if(CurrentLevel < CONSTRUCT_MAXLVL && Construction_GetMaterial(CONSTRUCT_RESOURCE1) >= CONSTRUCT_COST1)
			{
				CPrintToChatAll("%t", "Player Used 1 to", client, CONSTRUCT_COST1, "Material " ... CONSTRUCT_RESOURCE1);
				CPrintToChatAll("%t", "Upgraded Building To", CONSTRUCT_NAME, CurrentLevel + 2);

				Construction_AddMaterial(CONSTRUCT_RESOURCE1, -CONSTRUCT_COST1, true);

				EmitSoundToAll("ui/chime_rd_2base_pos.wav");

				CurrentLevel++;
			}
		}
	}
	return 0;
}
