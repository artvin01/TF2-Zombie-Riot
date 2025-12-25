#pragma semicolon 1
#pragma newdecls required

#undef CONSTRUCT_NAME
#undef CONSTRUCT_RESOURCE1
#undef CONSTRUCT_RESOURCE2
#undef CONSTRUCT_COST1
#undef CONSTRUCT_COST2
#undef CONSTRUCT_MAXLVL

#define CONSTRUCT_NAME		"Cannon"
#define CONSTRUCT_RESOURCE1	"copper"
#define CONSTRUCT_COST1		((5 + (CurrentLevel * 5)) * (CurrentLevel > 3 ? 2 : 1))
#define CONSTRUCT_MAXLVL	8
// 310 total cost

static const char NPCModel[] = "models/workshop/player/items/demo/taunt_drunk_manns_cannon/taunt_drunk_manns_cannon.mdl";

static char g_ShootingSound[][] = {
	"weapons/loose_cannon_shoot.wav",
};

static int NPCId;
static int LastGameTime;
static int CurrentLevel;

void ObjectC2Cannon_MapStart()
{
	LastGameTime = -1;
	CurrentLevel = 0;

	PrecacheSoundArray(g_ShootingSound);
	PrecacheModel(NPCModel);
	PrecacheModel("models/weapons/w_models/w_cannonball.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), CONSTRUCT_NAME);
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const2_cannon");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 3;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const2_cannon");
	build.Cost = 600;
	build.Health = 50;
	build.Cooldown = 30.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectC2Cannon(client, vecPos, vecAng);
}

methodmap ObjectC2Cannon < ObjectGeneric
{
	public void PlayShootSound() 
	{
		EmitSoundToAll(g_ShootingSound[GetRandomInt(0, sizeof(g_ShootingSound) - 1)], this.index, SNDCHAN_AUTO, 70, _, 0.7, 90);
	}
	public ObjectC2Cannon(int client, const float vecPos[3], const float vecAng[3])
	{
		if(LastGameTime != CurrentGame)
		{
			CurrentLevel = 0;
			LastGameTime = CurrentGame;
		}

		ObjectC2Cannon npc = view_as<ObjectC2Cannon>(ObjectGeneric(client, vecPos, vecAng, NPCModel, "1.75", "50", {30.0, 30.0, 70.0},_,false));

		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCThink[npc.index] = ObjectC2Cannon_ClotThink;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCInteract[npc.index] = ClotInteract;
		SetRotateByDefaultReturn(npc.index, -180.0);

		return npc;
	}
}

void ObjectC2Cannon_ClotThink(ObjectC2Cannon npc)
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
		float DistanceLimit = 900.0;

		npc.m_iTarget = GetClosestTarget(npc.index,_,DistanceLimit,.CanSee = true, .UseVectorDistance = true);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if(!IsValidEnemy(npc.index, npc.m_iTarget))
	{
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		return;
	}
	if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
	{
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		return;
	}
	if(npc.m_flNextMeleeAttack > gameTime)
	{
		return;
	}
	float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(flDistanceToTarget >= (900.0 * 900.0))
	{
		//too far away
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		return;
	}

	Sentrygun_FaceEnemy(npc.index, npc.m_iTarget);

	static float rocketAngle[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", rocketAngle);
	npc.PlayShootSound();
	float damageDealt = 117.1875 * Pow(float(CurrentLevel), 2.0);
	if(ShouldNpcDealBonusDamage(npc.m_iTarget))
		damageDealt *= 3.0;

	npc.m_flNextMeleeAttack = gameTime + 1.0;
		
	
	float VecStart[3]; WorldSpaceCenter(npc.index, VecStart );

	int rocket;
	rocket = npc.FireParticleRocket(vecTarget, damageDealt,700.0, 1, "doublejump_trail", .hide_projectile = false);

	ApplyCustomModelToWandProjectile(rocket, "models/weapons/w_models/w_cannonball.mdl", 1.0, "", _ , true);
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

static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!Dungeon_Mode())
		{
			maxcount = 0;
			return false;
		}

		maxcount = CurrentLevel > 4 ? 2 : 1;
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
		PrintCenterText(client, "%t", "Upgrade Using Materials", CurrentLevel + 1, CONSTRUCT_MAXLVL, button);
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

	menu.SetTitle("%t\n%d / %d %t\n ", CONSTRUCT_NAME, amount1, CONSTRUCT_COST1, "Material " ... CONSTRUCT_RESOURCE1);

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