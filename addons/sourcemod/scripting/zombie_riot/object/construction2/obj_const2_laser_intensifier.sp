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

#define CONSTRUCT_NAME		"Laser Intensifier"
#define CONSTRUCT_RESOURCE1	"copper"
#define CONSTRUCT_COST1		(20 + (CurrentLevel * 10))
#define CONSTRUCT_MAXLVL	ObjectDungeonCenter_Level()
#define CONSTRUCT_DAMAGE	(90.0 * Pow(level + 1.0, 2.0))
#define CONSTRUCT_RANGE		500.0
#define CONSTRUCT_MAXCOUNT	(1 + level)

static const char NPCModel[] = "models/props_moonbase/moon_cube_crystal02.mdl";

static char g_ShootingSound[][] = {
	"weapons/capper_shoot.wav",
};

static int NPCId;
static int LastGameTime;
static int CurrentLevel;

void ObjectC2LaserIntensifier_MapStart()
{
	LastGameTime = -1;
	CurrentLevel = 0;

	PrecacheSoundArray(g_ShootingSound);
	PrecacheModel(NPCModel);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), CONSTRUCT_NAME);
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const2_laser_intensifier");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 3;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const2_laser_intensifier");
	build.Cost = 300;
	build.Health = 600;
	build.Cooldown = 10.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectC2LaserIntensifier(client, vecPos, vecAng);
}

methodmap ObjectC2LaserIntensifier < ObjectGeneric
{
	property float m_flAttackspeedRamp
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	public void PlayShootSound() 
	{
		EmitSoundToAll(g_ShootingSound[GetRandomInt(0, sizeof(g_ShootingSound) - 1)], this.index, SNDCHAN_AUTO, 80, _, 0.6, iClamp(RoundToNearest(30.0 / this.m_flAttackspeedRamp), 70, 110));
	}
	public ObjectC2LaserIntensifier(int client, const float vecPos[3], const float vecAng[3])
	{
		if(LastGameTime != CurrentGame)
		{
			CurrentLevel = 0;
			LastGameTime = CurrentGame;
		}

		ObjectC2LaserIntensifier npc = view_as<ObjectC2LaserIntensifier>(ObjectGeneric(client, vecPos, vecAng, NPCModel, "0.9", "50", {20.0, 20.0, 60.0},_,false));

		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCThink[npc.index] = ObjectC2LaserIntensifier_ClotThink;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCInteract[npc.index] = ClotInteract;
		func_NPCDeath[npc.index] = Dungeon_BuildingDeath;
		SetRotateByDefaultReturn(npc.index, -180.0);
		npc.m_flAttackspeedRamp = 2.0;

		npc.m_iWearable1 = npc.EquipItemSeperate("models/workshop/weapons/c_models/c_invasion_pistol/c_invasion_pistol.mdl",_,_, 4.0, 40.0);

		return npc;
	}
}

void ObjectC2LaserIntensifier_ClotThink(ObjectC2LaserIntensifier npc)
{
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(Owner))
	{
		Owner = npc.index;
	}

	float gameTime = GetGameTime(npc.index);
	npc.m_flNextDelayTime = gameTime + 0.1;
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index,_,CONSTRUCT_RANGE,.CanSee = true, .UseVectorDistance = true);
		npc.m_flGetClosestTargetTime = FAR_FUTURE;
	}
	
	if(!IsValidEnemy(npc.index, npc.m_iTarget))
	{
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flAttackspeedRamp = 2.0;
		return;
	}
	if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
	{
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flAttackspeedRamp = 2.0;
		return;
	}
	if(npc.m_flNextMeleeAttack > gameTime)
	{
		return;
	}
	float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );

	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(flDistanceToTarget >= (CONSTRUCT_RANGE * CONSTRUCT_RANGE))
	{
		//too far away
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flAttackspeedRamp = 2.0;
		return;
	}
	if(npc.m_iTarget != npc.m_iTargetAlly)
	{
		npc.m_flAttackspeedRamp = 2.0;
	}
	else
	{
		if(npc.m_flAttackspeedRamp <= 1.0)
			npc.m_flAttackspeedRamp *= 0.85;
		else
			npc.m_flAttackspeedRamp *= 0.45;

		if(npc.m_flAttackspeedRamp <= 0.15)
		{
			npc.m_flAttackspeedRamp = 0.15;
		}
	}
	npc.m_iTargetAlly = npc.m_iTarget;
	Sentrygun_FaceEnemy(npc.index, npc.m_iTarget);

	float VecStart[3]; WorldSpaceCenter(npc.index, VecStart );

	int level = GetTeam(npc.index) == TFTeam_Red ? CurrentLevel : 0;

	float damageDealt = CONSTRUCT_DAMAGE;
	if(GetTeam(npc.index) == TFTeam_Red)
		damageDealt *= DMGMULTI_CONST2_RED;
	if(ShouldNpcDealBonusDamage(npc.m_iTarget))
		damageDealt *= 3.0;

	int rocket;
	rocket = npc.FireParticleRocket(vecTarget, damageDealt,700.0, 1.0, "raygun_projectile_red", .hide_projectile = true);

	npc.PlayShootSound();
	if(GetTeam(npc.index) == TFTeam_Red)
	{
		float fAng[3];
		GetEntPropVector(rocket, Prop_Send, "m_angRotation", fAng);
		Initiate_HomingProjectile(rocket,
		npc.index,
			180.0,			// float lockonAngleMax,
			90.0,				//float homingaSec,
			true,				// bool LockOnlyOnce,
			true,				// bool changeAngles,
			fAng,
			npc.m_iTarget);			// float AnglesInitiate[3]);
		TriggerTimerHoming(rocket);	
	}
	npc.m_flNextMeleeAttack = gameTime + npc.m_flAttackspeedRamp;

}

static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue)
		{
			if(!Dungeon_Mode() || ObjectDungeonCenter_Level() < 2)
			{
				maxcount = 0;
				return false;
			}
		}

		int level = CurrentLevel;
		maxcount = CONSTRUCT_MAXCOUNT;
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
	float damagePre = CONSTRUCT_DAMAGE * DMGMULTI_CONST2_RED;
	int countPre = CONSTRUCT_MAXCOUNT;

	level = CurrentLevel + 1;
	float damagePost = CONSTRUCT_DAMAGE * DMGMULTI_CONST2_RED;
	int countPost = CONSTRUCT_MAXCOUNT;
	
	char buffer[64];

	if(CurrentLevel >= CONSTRUCT_MAXLVL)
	{
		menu.SetTitle("%t\n%.0f ~ %.0f DPS\n%.0f Range\n%d Supply", CONSTRUCT_NAME, damagePre / 2.0, damagePre / 0.15, CONSTRUCT_RANGE, countPre);

		FormatEx(buffer, sizeof(buffer), "Level %d", CurrentLevel + 1);
		menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	}
	else
	{
		menu.SetTitle("%t\n%.0f (+%.0f) ~ %.0f (+%.0f) DPS\n%.0f Range\n%d (+%d) Supply\n ", CONSTRUCT_NAME, damagePre / 2.0, (damagePost / 2.0) - (damagePre / 2.0), damagePre / 0.15, (damagePost / 0.15) - (damagePre / 0.15), CONSTRUCT_RANGE, countPre, countPost - countPre);

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
