#pragma semicolon 1
#pragma newdecls required

#undef CONSTRUCT_NAME
#undef CONSTRUCT_RESOURCE1
#undef CONSTRUCT_RESOURCE2
#undef CONSTRUCT_COST1
#undef CONSTRUCT_COST2
#undef CONSTRUCT_MAXLVL

#define CONSTRUCT_NAME		"Incinerator"
#define CONSTRUCT_RESOURCE1	"copper"
#define CONSTRUCT_COST1		(20 + (CurrentLevel * 10))
#define CONSTRUCT_MAXLVL	5

static const char NPCModel[] = "models/props_wasteland/lighthouse_fresnel_light_base.mdl";

static char g_ShootingSound[][] = {
	"weapons/loose_cannon_shoot.wav",
};

static int NPCId;
static int LastGameTime;
static int CurrentLevel;
static bool Unlocked;

void ObjectC2Incinerator_MapStart()
{
	LastGameTime = -1;
	CurrentLevel = 0;
	Unlocked = false;

	PrecacheSoundArray(g_ShootingSound);
	PrecacheModel(NPCModel);
	PrecacheModel("models/weapons/w_models/w_cannonball.mdl");
	PrecacheSound("misc/flame_engulf.wav");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), CONSTRUCT_NAME);
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const2_incinerator");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 3;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const2_incinerator");
	build.Cost = 600;
	build.Health = 50;
	build.Cooldown = 30.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectC2Incinerator(client, vecPos, vecAng);
}

methodmap ObjectC2Incinerator < ObjectGeneric
{
	public void PlayShootSound() 
	{
		EmitSoundToAll(g_ShootingSound[GetRandomInt(0, sizeof(g_ShootingSound) - 1)], this.index, SNDCHAN_AUTO, 70, _, 0.7, 90);
		
	}
	public ObjectC2Incinerator(int client, const float vecPos[3], const float vecAng[3])
	{
		if(LastGameTime != CurrentGame)
		{
			CurrentLevel = 0;
			LastGameTime = CurrentGame;
			Unlocked = false;
		}

		ObjectC2Incinerator npc = view_as<ObjectC2Incinerator>(ObjectGeneric(client, vecPos, vecAng, NPCModel, "0.6", "50", {20.0, 20.0, 150.0},_,false));

		float flPos[3]; // original
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
		npc.m_iWearable3 = ParticleEffectAt_Parent(flPos, "spell_fireball_small_trail_red", npc.index, "root", {0.0,0.0,140.0});
		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCThink[npc.index] = ObjectC2Incinerator_ClotThink;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCInteract[npc.index] = ClotInteract;
		func_NPCDeath[npc.index] = ClotDeath;
		SetRotateByDefaultReturn(npc.index, -180.0);

		return npc;
	}
}

void ObjectC2Incinerator_ClotThink(ObjectC2Incinerator npc)
{
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(Owner))
	{
		Owner = npc.index;
	}

	float gameTime = GetGameTime(npc.index);
	npc.m_flNextDelayTime = gameTime + 0.1;

	if(npc.m_flNextMeleeAttack > gameTime)
	{
		return;
	}
	npc.m_flNextMeleeAttack = gameTime + 0.5;
		
	float ProjectileLoc[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
	spawnRing_Vectors(ProjectileLoc, 300.0 * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 255, 125, 65, 200, 1, 0.6, 5.0, 0.1, 3);
	Explode_Logic_Custom(25.0, npc.index, npc.index, -1, ProjectileLoc, 300.0 , _ , _ , true, _, _, 10.0, ObjConst2_Incinerator_Ingite);
}
static void ObjConst2_Incinerator_Ingite(int entity, int victim, float damage, int weapon)
{
	int level = GetTeam(entity) == TFTeam_Red ? CurrentLevel : 0;

	float damageDealt = 25.0 * Pow(float(level), 3.0);
	bool HadBuffBefore = true;
	if(!HasSpecificBuff(victim, "Burn"))
		HadBuffBefore = false;
	
	NPC_Ignite(victim, entity, 4.0, -1, damageDealt);
	if(!HadBuffBefore && HasSpecificBuff(victim, "Burn"))
	{
		EmitSoundToAll("misc/flame_engulf.wav", victim, SNDCHAN_AUTO, 80, _, 0.7, 100);
	}
}
static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue)
		{
			if(!Dungeon_Mode() || !Unlocked || LastGameTime != CurrentGame)
			{
				maxcount = 0;
				return false;
			}
		}

		maxcount = (CurrentLevel / 2) + 1;
		if(count >= maxcount)
			return false;
	}
	
	return true;
}

static int CountBuildings()
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
	{
		if(NPCId == i_NpcInternalId[entity])
			count++;
	}

	return count;
}


static void ClotShowInteractHud(ObjectGeneric npc, int client)
{
	if(CurrentLevel >= CONSTRUCT_MAXLVL)
	{
		PrintCenterText(client, "%t", "Upgrade Max");
	}
	else
	{
		SetGlobalTransTarget(client);

		char button[64];
		PlayerHasInteract(client, button, sizeof(button));
		PrintCenterText(client, "%t", "Upgrade Using Materials", CurrentLevel + 1, CONSTRUCT_MAXLVL + 1, button);
	}
}

static bool ClotInteract(int client, int weapon, ObjectGeneric npc)
{
	if(CurrentLevel >= CONSTRUCT_MAXLVL)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}

	ThisBuildingMenu(client);
	return true;
}

static void ThisBuildingMenu(int client)
{
	int amount1 = Construction_GetMaterial(CONSTRUCT_RESOURCE1);

	SetGlobalTransTarget(client);

	Menu menu = new Menu(ThisBuildingMenuH);

	menu.SetTitle("%t\n \n%d / %d %t", CONSTRUCT_NAME, amount1, CONSTRUCT_COST1, "Material " ... CONSTRUCT_RESOURCE1);

	char buffer[64];
	FormatEx(buffer, sizeof(buffer), "%t", "Upgrade Building To", CurrentLevel + 2);
	menu.AddItem(buffer, buffer, (amount1 < CONSTRUCT_COST1) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

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

static void ClotDeath(int entity)
{
	if(!Unlocked && LastGameTime == CurrentGame && GetTeam(entity) != TFTeam_Red && !(i_HexCustomDamageTypes[entity] & ZR_SLAY_DAMAGE))
	{
		Unlocked = true;
		CPrintToChatAll("{green}%t", "Unlocked Building", CONSTRUCT_NAME);
	}
}
