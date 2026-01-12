#pragma semicolon 1
#pragma newdecls required

#undef CONSTRUCT_NAME
#undef CONSTRUCT_RESOURCE1
#undef CONSTRUCT_RESOURCE2
#undef CONSTRUCT_COST1
#undef CONSTRUCT_COST2
#undef CONSTRUCT_MAXLVL

#define CONSTRUCT_NAME		"Tranquilizer Turret"
#define CONSTRUCT_RESOURCE1	"copper"
#define CONSTRUCT_COST1		(30 + (CurrentLevel * 10))
#define CONSTRUCT_MAXLVL	(ObjectDungeonCenter_Level() - 1)

static const char g_ShootingSound[] =
	"weapons/sniper_rifle_classic_shoot.wav";

static int NPCId;
static int LastGameTime;
static int CurrentLevel;

void ObjectDStunGun_MapStart()
{
	LastGameTime = -1;
	CurrentLevel = 0;

	PrecacheSound(g_ShootingSound);
	PrecacheModel("models/combine_turrets/floor_turret.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), CONSTRUCT_NAME);
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_dungeon_stungun");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 3;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_dungeon_stungun");
	build.Cost = 600;
	build.Health = 100;
	build.Cooldown = 30.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectDStunGun(client, vecPos, vecAng);
}

methodmap ObjectDStunGun < ObjectGeneric
{
	public void PlayShootSound() 
	{
		EmitSoundToAll(g_ShootingSound, this.index, SNDCHAN_AUTO, 80, _, 0.7, 90);
	}
	public ObjectDStunGun(int client, const float vecPos[3], const float vecAng[3])
	{
		if(LastGameTime != CurrentGame)
		{
			CurrentLevel = 0;
			LastGameTime = CurrentGame;
		}

		ObjectDStunGun npc = view_as<ObjectDStunGun>(ObjectGeneric(client, vecPos, vecAng, "models/combine_turrets/floor_turret.mdl", "1.0", "50", {23.0, 23.0, 61.0}, _, false));

		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCThink[npc.index] = ClotThink;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCInteract[npc.index] = ClotInteract;
		SetRotateByDefaultReturn(npc.index, -180.0);

		return npc;
	}
}

static void ClotThink(ObjectDStunGun npc)
{
	float gameTime = GetGameTime(npc.index);
	npc.m_flNextDelayTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{

		npc.m_iTarget = GetClosestTarget(npc.index,_,1000.0,.CanSee = true, .UseVectorDistance = true);
		npc.m_flGetClosestTargetTime = FAR_FUTURE;
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
	if(flDistanceToTarget >= (1000.0 * 1000.0))
	{
		//too far away
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		return;
	}

	Sentrygun_FaceEnemy(npc.index, npc.m_iTarget);

	if(npc.m_flNextMeleeAttack > gameTime)
		return;

	Handle swingTrace;
	if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, { 9999.0, 9999.0, 9999.0 }))
	{
		int target = TR_GetEntityIndex(swingTrace);	
		float level = GetTeam(npc.index) == TFTeam_Red ? float(CurrentLevel) : MultiGlobalEnemy;
			
		float vecHit[3];
		TR_GetEndPosition(vecHit, swingTrace);
		float origin[3];
		float angles[3];
		view_as<CClotBody>(npc.index).GetAttachment("light", origin, angles);
		ShootLaser(npc.index, "bullet_tracer02_red_crit", origin, vecHit, false );
		npc.m_flNextMeleeAttack = gameTime + 9.0 - (level * 2.0);
		npc.PlayShootSound();
		if(IsValidEnemy(npc.index, target))
		{
			if(i_IsVehicle[target])	// EMP!!
			{
				AcceptEntityInput(target, "TurnOff");

				SetVariantString("OnUser4 !self:TurnOn::3:-1");
				AcceptEntityInput(target, "AddOutput");
				AcceptEntityInput(target, "FireUser4");
				AcceptEntityInput(target, "FireUser4");

				for(int other = 1; other <= MaxClients; other++)
				{
					if(IsClientInGame(other) && Vehicle_Driver(other) == target)
						SetEntPropFloat(other, Prop_Send, "m_flNextAttack", GetGameTime() + 3.0);
				}
			}
			else if(target < 1 || target >= MaxClients)
			{
				TF2_StunPlayer(target, 2.0, 1.0, TF_STUNFLAG_SLOWDOWN);
			}
			else
			{
				FreezeNpcInTime(target, b_thisNpcIsARaid[target] ? 0.4 : 2.0);
			}
		}
	}

	delete swingTrace;
}

static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue)
		{
			if(!Dungeon_Mode() || ObjectDungeonCenter_Level() < 2 || LastGameTime != CurrentGame)
			{
				maxcount = 0;
				return false;
			}
		}

		maxcount = CurrentLevel + 1;
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
	if(CurrentLevel >= CONSTRUCT_MAXLVL)
	{
		PrintCenterText(client, "%t", ObjectDungeonCenter_Level() < 3 ? "Upgrade Max Limited" : "Upgrade Max");
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
