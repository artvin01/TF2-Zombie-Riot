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

#define CONSTRUCT_NAME		"Minigun Turret"
#define CONSTRUCT_RESOURCE1	"copper"
#define CONSTRUCT_COST1		(10 + (CurrentLevel * 10))
#define CONSTRUCT_MAXLVL	(1 + ObjectDungeonCenter_Level())
#define CONSTRUCT_DAMAGE	(15.0 * Pow(level + 1.0, 2.0))
#define CONSTRUCT_FIRERATE	0.05
#define CONSTRUCT_RANGE		900.0
#define CONSTRUCT_MAXCOUNT	(1 + level)

static char g_ShootingSound[][] = {
	"weapons/csgo_awp_shoot.wav",
};

static int NPCId;
static int LastGameTime;
static int CurrentLevel;

void ObjectDMinigunTurret_MapStart()
{
	LastGameTime = -1;
	CurrentLevel = 0;

	PrecacheSoundArray(g_ShootingSound);
	PrecacheModel("models/buildables/sentry2.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), CONSTRUCT_NAME);
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_dungeon_minigun_turret");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 3;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_dungeon_minigun_turret");
	build.Cost = 600;
	build.Health = 200;
	build.Cooldown = 30.0;
	build.Func = ClotCanBuild;
	Building_Add(build);

	PrecacheSound("weapons/minigun_spin.wav");
	PrecacheSound("weapons/minigun_wind_down.wav");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectDMinigunTurret(client, vecPos, vecAng);
}

methodmap ObjectDMinigunTurret < ObjectGeneric
{
	public void PlayShootSound() 
	{
		EmitSoundToAll(g_ShootingSound[GetRandomInt(0, sizeof(g_ShootingSound) - 1)], this.index, SNDCHAN_AUTO, 80, _, 0.7, 90);
	}
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	public void PlayMinigunSound(bool Shooting) 
	{
		if(Shooting)
		{
			if(this.i_GunMode != 0)
			{
				StopSound(this.index, SNDCHAN_STATIC, "weapons/minigun_spin.wav");
				EmitSoundToAll("weapons/minigun_shoot.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.70);
			}
			this.i_GunMode = 0;
		}
		else
		{
			if(this.i_GunMode != 1)
			{
				StopSound(this.index, SNDCHAN_STATIC, "weapons/minigun_shoot.wav");
				EmitSoundToAll("weapons/minigun_wind_down.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.70);
			}
			this.i_GunMode = 1;
		}
	}
	public ObjectDMinigunTurret(int client, const float vecPos[3], const float vecAng[3])
	{
		if(LastGameTime != CurrentGame)
		{
			CurrentLevel = 0;
			LastGameTime = CurrentGame;
		}

		ObjectDMinigunTurret npc = view_as<ObjectDMinigunTurret>(ObjectGeneric(client, vecPos, vecAng, "models/buildables/sentry2.mdl", "2.0", "50", {40.0, 40.0, 90.0},_,false));

		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCThink[npc.index] = ObjectDMinigunTurret_ClotThink;
		func_NPCDeath[npc.index] = ObjectDMinigunTurret_Death;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCInteract[npc.index] = ClotInteract;
		SetRotateByDefaultReturn(npc.index, -180.0);
		SDKUnhook(npc.index, SDKHook_ThinkPost, ObjBaseThinkPost);
		SDKHook(npc.index, SDKHook_ThinkPost, ObjBaseThinkPostSentry);
		npc.PlayMinigunSound(false);

		return npc;
	}
}

void ObjectDMinigunTurret_Death(int entity)
{
	ObjectDMinigunTurret npc = view_as<ObjectDMinigunTurret>(entity);
	npc.PlayMinigunSound(false);
	Dungeon_BuildingDeath(entity);
}
void ObjectDMinigunTurret_ClotThink(ObjectDMinigunTurret npc)
{
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(Owner))
	{
		Owner = npc.index;
	}

	float gameTime = GetGameTime(npc.index);
	npc.m_flNextDelayTime = gameTime + CONSTRUCT_FIRERATE;
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		float DistanceLimit = CONSTRUCT_RANGE;

		npc.m_iTarget = GetClosestTarget(npc.index,_,DistanceLimit,.CanSee = false, .UseVectorDistance = true);
		npc.m_flGetClosestTargetTime = FAR_FUTURE;
	}
	
	if(!IsValidEnemy(npc.index, npc.m_iTarget))
	{
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.AddActivityViaSequence("idle_off");
		npc.PlayMinigunSound(false);
		if(GetTeam(npc.index) != TFTeam_Red)
			npc.m_flNextDelayTime = gameTime + ENEMY_BUILDING_DELAY_THINK;
		return;
	}
	/*
	if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
	{
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.AddActivityViaSequence("idle_off");
		npc.PlayMinigunSound(false);
		if(GetTeam(npc.index) != TFTeam_Red)
			npc.m_flNextDelayTime = gameTime + ENEMY_BUILDING_DELAY_THINK;
		return;
	}
	*/
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
		npc.AddActivityViaSequence("idle_off");
		npc.PlayMinigunSound(false);
		return;
	}

	Handle swingTrace;
	int target;
	Sentrygun_FaceEnemy(npc.index, npc.m_iTarget);

	static float rocketAngle[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", rocketAngle);

	if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, { 9999.0, 9999.0, 9999.0 }))
	{
		target = TR_GetEntityIndex(swingTrace);	
			
	//	npc.AddActivityViaSequence("fire");
		npc.AddActivityViaSequence("idle_off");
		float vecHit[3];
		TR_GetEndPosition(vecHit, swingTrace);
		float origin[3];
		float angles[3];
		if(npc.Anger)
		{
			view_as<CClotBody>(npc.index).GetAttachment("muzzle_l", origin, angles);
			npc.Anger = false;
		}
		else
		{
			view_as<CClotBody>(npc.index).GetAttachment("muzzle_r", origin, angles);
			npc.Anger = true;
		}
		ShootLaser(npc.index, "bullet_tracer02_red", origin, vecHit, false );
	//	npc.m_flNextMeleeAttack = gameTime + CONSTRUCT_FIRERATE;
		npc.PlayMinigunSound(true);
		if(IsValidEnemy(npc.index, target))
		{
			int level = GetTeam(npc.index) == TFTeam_Red ? CurrentLevel : 0;

			float damageDealt = CONSTRUCT_DAMAGE;
			if(GetTeam(npc.index) == TFTeam_Red)
				damageDealt *= DMGMULTI_CONST2_RED;
			if(ShouldNpcDealBonusDamage(target))
				damageDealt *= 3.0;
			
			SDKHooks_TakeDamage(target, npc.index, Owner, damageDealt, DMG_BULLET, -1, _, vecHit);
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
		menu.SetTitle("%t\n%.0f DPS\n%.0f Range\n%d Supply", CONSTRUCT_NAME, damagePre, CONSTRUCT_RANGE, countPre);

		FormatEx(buffer, sizeof(buffer), "Level %d", CurrentLevel + 1);
		menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	}
	else
	{
		menu.SetTitle("%t\n%.0f (+%.0f) DPS\n%.0f Range\n%d (+%d) Supply\n ", CONSTRUCT_NAME, damagePre, damagePost - damagePre, CONSTRUCT_RANGE, countPre, countPost - countPre);

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
