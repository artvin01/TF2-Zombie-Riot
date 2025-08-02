#pragma semicolon 1
#pragma newdecls required

#define VILLAGE_MODEL "models/props_rooftop/roof_dish001.mdl"
#define VILLAGE_MODEL_LIGHTHOUSE "models/props_sunshine/lighthouse_top_skybox.mdl"
#define VILLAGE_MODEL_MIDDLE "models/props_urban/urban_skybuilding005a.mdl"
#define VILLAGE_MODEL_REBEL "models/egypt/tent/tent.mdl"

#define VILLAGE_000	(1 << 0)
#define VILLAGE_100	(1 << 1)
#define VILLAGE_200	(1 << 2)
#define VILLAGE_300	(1 << 3)
#define VILLAGE_400	(1 << 4)
#define VILLAGE_500	(1 << 5)
#define VILLAGE_010	(1 << 6)
#define VILLAGE_020	(1 << 7)
#define VILLAGE_030	(1 << 8)
#define VILLAGE_040	(1 << 9)
#define VILLAGE_050	(1 << 10)
#define VILLAGE_001	(1 << 11)
#define VILLAGE_002	(1 << 12)
#define VILLAGE_003	(1 << 13)
#define VILLAGE_004	(1 << 14)
#define VILLAGE_005	(1 << 15)

static float Village_ReloadBuffFor[MAXPLAYERS];
static int Village_Flags[MAXPLAYERS];
static bool Village_ForceUpdate[MAXPLAYERS];
static int Village_TierExists[3];
static int i_VillageModelAppliance[MAXENTITIES];
static int i_VillageModelApplianceCollisionBox[MAXENTITIES];

void ObjectVillage_MapStart()
{
	PrecacheModel(VILLAGE_MODEL);
	PrecacheModel(VILLAGE_MODEL_LIGHTHOUSE);
	PrecacheModel(VILLAGE_MODEL_MIDDLE);
	PrecacheModel(VILLAGE_MODEL_REBEL);
	PrecacheSound("items/powerup_pickup_uber.wav");
	PrecacheSound("player/mannpower_invulnerable.wav");
	Zero(Village_ReloadBuffFor);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Village");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_village");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);

	BuildingInfo build;
	build.Section = 1;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_village");
	build.Cost = 1200;
	build.Health = 30;
	build.Cooldown = 30.0;
	build.Func = ObjectGeneric_CanBuildSentry;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectVillage(client, vecPos, vecAng);
}

methodmap ObjectVillage < ObjectGeneric
{
	public ObjectVillage(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectVillage npc = view_as<ObjectVillage>(ObjectGeneric(client, vecPos, vecAng, VILLAGE_MODEL, "0.75", "50", {18.0, 18.0, 70.0}, _, false));

		npc.SentryBuilding = true;
		npc.FuncCanBuild = ObjectGeneric_CanBuildSentry;
		func_NPCThink[npc.index] = ClotThink;
		func_NPCInteract[npc.index] = ClotInteract;

		SetRotateByDefaultReturn(npc.index, 180.0);
		i_PlayerToCustomBuilding[client] = EntIndexToEntRef(npc.index);

		// Timer is done instead cause we run code when a village no longer exists in here
		CreateTimer(0.5, Timer_VillageThink, EntIndexToEntRef(npc.index), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		i_VillageModelAppliance[npc.index] = 0;
		i_VillageModelApplianceCollisionBox[npc.index] = 0;
		VillageCheckItems(client);

		return npc;
	}
}

static void ClotThink(ObjectVillage npc)
{
	if(i_VillageModelAppliance[npc.index] == 5)
		ObjectSentrygun_ClotThink(view_as<ObjectSentrygun>(npc));
}

public Action Timer_VillageThink(Handle timer, int ref)
{
	float pos1[3] = {999999999.9, 999999999.9, 999999999.9};
	bool mounted;
	int owner;
	int entity = EntRefToEntIndex(ref);
	if(!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}
	if(entity != INVALID_ENT_REFERENCE)
	{
		owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(owner < 1 || owner > MaxClients)
		{
			SDKHooks_TakeDamage(entity, entity, entity, 999999.9);
			entity = INVALID_ENT_REFERENCE;
			owner = 0;
		}
		else if(Building_Mounted[owner] == ref)
		{
			GetClientEyePosition(owner, pos1);
			mounted = true;
		}
		else
		{
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		}
	}

	i_ExtraPlayerPoints[owner] += 2; //Static low point increase.
	if(entity != INVALID_ENT_REFERENCE)
		BuildingVillageChangeModel(owner, entity);
	
	int effects = Village_Flags[owner];
	
	float range = 600.0;
	
	if(effects & VILLAGE_040)
		Village_ForceUpdate[owner] = true;
	
	if(Village_ReloadBuffFor[owner] > GetGameTime())
	{
		if(effects & VILLAGE_050)
			range = 10000.0;
	}
	else
	{
		effects &= ~VILLAGE_050;
		effects &= ~VILLAGE_040;
	}
	
	if(!(effects & VILLAGE_050))
	{
		if(effects & VILLAGE_100)
			range += 120.0;
		
		if(effects & VILLAGE_500)
		{
			range += 125.0;
		}
		else if(effects & VILLAGE_005)
		{
			range += 150.0;
		}
	}
	
	if(mounted)
		range *= 0.55;

	int points = VillagePointsLeft(owner);
	if(points >= 0)
	{
		BuildingApplyDebuffyToEnemiesInRange(owner, range, mounted);
	}

	return entity == INVALID_ENT_REFERENCE ? Plugin_Stop : Plugin_Continue;
}

void BuildingApplyDebuffyToEnemiesInRange(int client, float range, bool mounted)
{
	static float pos2[3];
	if(mounted)
	{
		GetClientEyePosition(client, pos2);
	}
	else
	{
		GetEntPropVector(Object_GetSentryBuilding(client), Prop_Data, "m_vecAbsOrigin", pos2);
	}

	b_NpcIsTeamkiller[client] = true;
	b_AllowSelfTarget[client] = true;
	Explode_Logic_Custom(0.0,
	client,
	client,
	-1,
	pos2,
	range,
	_,
	_,
	false,
	99,
	false,
	_,
	VillageDetectEnemyInSight);
	b_NpcIsTeamkiller[client] = false;
	b_AllowSelfTarget[client] = false;
}

void VillageDetectEnemyInSight(int entity, int victim, float damage, int weapon)
{
	int effectsDoNow = Village_Flags[entity];
	if(GetTeam(entity) != GetTeam(victim))
	{
		//anything that affects enemies
		if(Village_Flags[entity] & VILLAGE_004)
		{
			if(b_thisNpcIsARaid[victim])
			{
				ApplyStatusEffect(entity, victim, "Iberia's Anti Raid", 3.0);
			}
		}
		if(effectsDoNow & VILLAGE_020)
			ApplyStatusEffect(entity, victim, "Revealed", 1.5);
		
		if(effectsDoNow & VILLAGE_010)
			ApplyStatusEffect(entity, victim, "Growth Blocker", 1.5);
	}
	else
	{
		if(Village_ReloadBuffFor[entity] < GetGameTime())
		{
			effectsDoNow &= ~VILLAGE_050;
			effectsDoNow &= ~VILLAGE_040;
		}

		ApplyStatusEffect(entity, victim, "Village Radar", 1.5);
		if(effectsDoNow & VILLAGE_200)
			ApplyStatusEffect(entity, victim, "Jungle Drums", 1.5);

		if(effectsDoNow & VILLAGE_030)
			ApplyStatusEffect(entity, victim, "Intelligence", 1.5);

		if(effectsDoNow & VILLAGE_040)
			ApplyStatusEffect(entity, victim, "Call To Arms", 1.5);

		if(effectsDoNow & VILLAGE_050)
			ApplyStatusEffect(entity, victim, "Homeland Defense", 1.5);

		if(effectsDoNow & VILLAGE_003)
			ApplyStatusEffect(entity, victim, "Nethersea Antidote", 1.5);

		if(effectsDoNow & VILLAGE_005)
			ApplyStatusEffect(entity, victim, "Iberia Light", 1.5);
			
		if(victim <= MaxClients)
		{
			if(f_ClientArmorRegen[victim] - 0.3 < GetGameTime())
			{
				if(effectsDoNow & VILLAGE_002)
				{
					ApplyStatusEffect(entity, victim, "Armor Curing", 1.5);
					int maxarmor = MaxArmorCalculation(Armor_Level[victim], victim, 0.5);
					if(Armor_Charge[victim] < maxarmor)
					{
						f_ClientArmorRegen[victim] = GetGameTime() + 0.7;
						if(f_TimeUntillNormalHeal[victim] > GetGameTime())
							GiveArmorViaPercentage(victim, 0.0025, 1.0);
						else
							GiveArmorViaPercentage(victim, 0.01, 1.0);
					}
				}
				else if(effectsDoNow & VILLAGE_001)
				{
					ApplyStatusEffect(entity, victim, "Elemental Curing", 1.5);
					if(Armor_Charge[victim] < 0)
					{
						f_ClientArmorRegen[victim] = GetGameTime() + 0.7;
						if(f_TimeUntillNormalHeal[victim] > GetGameTime())
							GiveArmorViaPercentage(victim, 0.0025, 1.0);
						else
							GiveArmorViaPercentage(victim, 0.01, 1.0);
					}
				}
			}
		}
		//allies
	}
}
static void VillageCheckItems(int client)
{
	int lastFlags = Village_Flags[client];
	
//	if(Store_HasNamedItem(client, "Buildable Village"))
	{
		Village_Flags[client] = VILLAGE_000;
		
		switch(Store_HasNamedItem(client, "Village NPC Expert"))
		{
			case 1:
				Village_Flags[client] += VILLAGE_100;
			
			case 2:
				Village_Flags[client] += VILLAGE_100 + VILLAGE_200;
			
			case 3:
				Village_Flags[client] += VILLAGE_100 + VILLAGE_200 + VILLAGE_300;
			
			case 4:
				Village_Flags[client] += VILLAGE_100 + VILLAGE_200 + VILLAGE_300 + VILLAGE_400;
			
			case 5:
				Village_Flags[client] += VILLAGE_100 + VILLAGE_200 + VILLAGE_300 + VILLAGE_400 + VILLAGE_500;
		}
		
		switch(Store_HasNamedItem(client, "Village Buffing Expert"))
		{
			case 1:
				Village_Flags[client] += VILLAGE_010;
			
			case 2:
				Village_Flags[client] += VILLAGE_010 + VILLAGE_020;
			
			case 3:
				Village_Flags[client] += VILLAGE_010 + VILLAGE_020 + VILLAGE_030;
			
			case 4:
				Village_Flags[client] += VILLAGE_010 + VILLAGE_020 + VILLAGE_030 + VILLAGE_040;
			
			case 5:
				Village_Flags[client] += VILLAGE_010 + VILLAGE_020 + VILLAGE_030 + VILLAGE_040 + VILLAGE_050;
		}
		
		switch(Store_HasNamedItem(client, "Village Support Expert"))
		{
			case 1:
				Village_Flags[client] += VILLAGE_001;
			
			case 2:
				Village_Flags[client] += VILLAGE_001 + VILLAGE_002;
			
			case 3:
				Village_Flags[client] += VILLAGE_001 + VILLAGE_002 + VILLAGE_003;
			
			case 4:
				Village_Flags[client] += VILLAGE_001 + VILLAGE_002 + VILLAGE_003 + VILLAGE_004;
			
			case 5:
				Village_Flags[client] += VILLAGE_001 + VILLAGE_002 + VILLAGE_003 + VILLAGE_004 + VILLAGE_005;
		}
		
		if(lastFlags != Village_Flags[client])
			Village_ForceUpdate[client] = true;
	}
//	else
	{
//		Village_Flags[client] = 0;
	}
}

static const int VillageCosts[] =
{
	// B0 1
	// B1 2
	// B2 4
	// B3 7
	// B4 11
	// B5 16
	// B6 35

	// R0 0
	// R1 1
	// R2 2
	// R3 4
	// R4 6
	// R5 9

	0,

	1,	// 1	- B0 R0
	3,	// 4	- B1 R2
	2,	// 6	- B2 R2
	3,	// 9	- B3 R2
	4,	// 13	- B4 R2

	1,	// 1	- B0 R0
	2,	// 3	- B1 R1
	5,	// 8	- B3 R1
	6,	// 14	- B4 R3
	7,	// 21	- B5 R4

	2,	// 2	- B1 R0
	2,	// 4	- B1 R2
	6,	// 10	- B3 R3
	12,	// 24	- B5 R5
	18,	// 44	- B6 R5
};

static int VillagePointsLeft(int client)
{
	int level = Object_MaxSupportBuildings(client, true);	// 1 - 16

	if(Store_HasNamedItem(client, "Construction Novice"))
		level++;
	
	if(Store_HasNamedItem(client, "Construction Apprentice"))
		level++;
	
	if(Store_HasNamedItem(client, "Engineering Repair Handling book"))
		level += 2;
	
	if(Store_HasNamedItem(client, "Alien Repair Handling book"))
		level += 2;
	
	if(Store_HasNamedItem(client, "Cosmic Repair Handling book"))
		level += 3;
	
	if(Store_HasNamedItem(client, "Construction Killer"))	// 25 -> 44
		level += 19;

	if(Store_HasNamedItem(client, "Wildingen's Elite Building Components"))	// lol
		level += 50;
	
	for(int i = 1; i < sizeof(VillageCosts); i++)
	{
		if(Village_Flags[client] & (1 << i))
			level -= VillageCosts[i];
	}

	return level;	// 1 - 25/44
}

static bool ClotInteract(int client, int weapon, ObjectHealingStation npc)
{
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	
	float gameTime = GetGameTime();
	if(f_BuildingIsNotReady[Owner] > gameTime)
		return false;
	
	if(Owner == client && f_MedicCallIngore[Owner] > gameTime)
	{
		if(!(Village_Flags[Owner] & VILLAGE_040))
		{

		}
		else if(f_BuildingIsNotReady[Owner] < gameTime)
		{
			f_BuildingIsNotReady[Owner] = gameTime + 90.0;
			
			if(Village_Flags[Owner] & VILLAGE_050)
			{
				i_ExtraPlayerPoints[Owner] += 100; //Static point increase.
				Village_ReloadBuffFor[Owner] = gameTime + 20.0;
				EmitSoundToAll("items/powerup_pickup_uber.wav");
				EmitSoundToAll("items/powerup_pickup_uber.wav");
			}
			else
			{
				i_ExtraPlayerPoints[Owner] += 50; //Static point increase.
				Village_ReloadBuffFor[Owner] = gameTime + 15.0;
				EmitSoundToAll("player/mannpower_invulnerable.wav", npc.index);
				EmitSoundToAll("player/mannpower_invulnerable.wav", npc.index);
			}
		}
		else
		{
			float Ability_CD = f_BuildingIsNotReady[Owner] - gameTime;
			
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
			
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}
	}
	else
	{
		VillageUpgradeMenu(Owner, client);
	}

	return true;
}

static void VillageUpgradeMenu(int client, int viewer)
{
	bool owner = client == viewer;
	
	Menu menu = new Menu(VillageUpgradeMenuH);
	
	SetGlobalTransTarget(viewer);
	int points = VillagePointsLeft(client);
	if(points >= 0)
	{
		menu.SetTitle("%t\n \n개선 토큰: %d (%t)\n ", "Buildable Village", points, "Building Upgrades");
	}
	else
	{
		menu.SetTitle("%t\n \nYou're in Banana dept! Buffs dont work!: %d (%t)\n ", "Buildable Village", points, "Building Upgrades");	
	}
	
	int paths;
	if(Village_Flags[client] & VILLAGE_100)
		paths++;
	
	if(Village_Flags[client] & VILLAGE_010)
		paths++;
	
	if(Village_Flags[client] & VILLAGE_001)
		paths++;
	
	bool tier = (Village_Flags[client] & VILLAGE_300) || (Village_Flags[client] & VILLAGE_030) || (Village_Flags[client] & VILLAGE_003);
	
	char buffer[256];
	if(Village_Flags[client] & VILLAGE_500)
	{
		menu.AddItem("", "일차 전문분야", ITEMDRAW_DISABLED);
		menu.AddItem("", "마을이 공격형 센트리 건처럼 행동.", ITEMDRAW_DISABLED);
		menu.AddItem("", "범위 내의 모든 반시민이 자금을 $1750 얻으며 공격 속도, 피해량 증가.\n ", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_400)
	{
		/*
		if(Village_TierExists[0] == 5)
		{
			menu.AddItem("", "일차 멘토링", ITEMDRAW_DISABLED);
			menu.AddItem("", "범위 내의 모든 반시민이 자금을 $500,", ITEMDRAW_DISABLED);
			menu.AddItem("", "얻고 시작하며 공격 속도, 사거리 증가.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%s [4 바나나]", "일차 전문분야");
			menu.AddItem(VilN(VILLAGE_500), buffer, (!owner || points < 4) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "마을이 공격형 센트리 건처럼 행동.", ITEMDRAW_DISABLED);
			menu.AddItem("", "범위 내의 모든 반시민이 자금을 $1750 얻으며 공격 속도, 피해량 증가.\n ", ITEMDRAW_DISABLED);
		}
		*/
	}
	else if(Village_Flags[client] & VILLAGE_300)
	{	/*
		FormatEx(buffer, sizeof(buffer), "%s [3 바나나]%s", "일차 멘토링", Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_400), buffer, (!owner || points < 3) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "범위 내의 모든 반시민이 자금을 $500,", ITEMDRAW_DISABLED);
		menu.AddItem("", "얻고 시작하며 공격 속도, 사거리 증가.\n ", ITEMDRAW_DISABLED);
		*/
	}
	else if(Village_Flags[client] & VILLAGE_200)
	{
		if(tier)
		{
			menu.AddItem("", "정글 드럼", ITEMDRAW_DISABLED);
			menu.AddItem("", "범위 내의 모든 아군의", ITEMDRAW_DISABLED);
			menu.AddItem("", "공격 속도, 치유 속도 증가.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			menu.AddItem("", "경로 잠김.", ITEMDRAW_DISABLED);
		//	menu.AddItem("", "범위 내의 모든 아군의", ITEMDRAW_DISABLED);
		//	menu.AddItem("", "공격 속도, 치유 속도 증가.\n ", ITEMDRAW_DISABLED);
			/*
			FormatEx(buffer, sizeof(buffer), "%s [2 바나나]%s", "일차 훈련", Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : Village_TierExists[0] == 3 ? " [Tier 3 Exists]" : "");
			menu.AddItem(VilN(VILLAGE_300), buffer, (!owner || points < 2) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "범위 내의 모든", ITEMDRAW_DISABLED);
			menu.AddItem("", "반시민의 공격력, 사거리 증가.\n", ITEMDRAW_DISABLED);
			menu.AddItem("", "매 3웨이브마다 마을이 반시민을 생성(최대 3)\n ", ITEMDRAW_DISABLED);
			*/
		}
	}
	else if(Village_Flags[client] & VILLAGE_100)
	{
		FormatEx(buffer, sizeof(buffer), "%s [3 개선 토큰]%s", "정글 드럼", Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : Village_TierExists[0] == 3 ? " [Tier 3 Exists]" : Village_TierExists[0] == 2 ? " [Tier 2 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_200), buffer, (!owner || points < 3) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "범위 내의 모든 아군의", ITEMDRAW_DISABLED);
		menu.AddItem("", "공격 속도+ 5% 및 치유 속도 +8%.\n ", ITEMDRAW_DISABLED);
	}
	else if(paths < 2)
	{
		if(owner)
			menu.AddItem("", "TIP: 단 하나의 경로만이 3티어 개선이 가능.\n ", ITEMDRAW_DISABLED);
		
		FormatEx(buffer, sizeof(buffer), "%s [1 개선 토큰]%s", "반경 증가", Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : Village_TierExists[0] == 3 ? " [Tier 3 Exists]" : Village_TierExists[0] == 2 ? " [Tier 2 Exists]" : Village_TierExists[0] == 1 ? " [Tier 1 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_100), buffer, (!owner || points < 1) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "범위 내의 모든 적의 위장 효과 제거.\n ", ITEMDRAW_DISABLED);
	}
	
	if(Village_Flags[client] & VILLAGE_050)
	{
		menu.AddItem("", "국토 방어", ITEMDRAW_DISABLED);
		menu.AddItem("", "능력 사용시 모든 플레이어와 아군의 공격 속도, 재장전 속도, 치유 속도를 25%", ITEMDRAW_DISABLED);
		menu.AddItem("", "만큼 증가. 20 초 지속.\n ", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_040)
	{
		if(Village_TierExists[1] == 5)
		{
			menu.AddItem("", "군대 소집", ITEMDRAW_DISABLED);
			menu.AddItem("", "E로 능력 사용시 주변의 모든 아군의", ITEMDRAW_DISABLED);
			menu.AddItem("", "공격 속도, 재장전 속도, 치유 속도를 짧은 시간동안 +12% 증가시킴.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%s [7 개선 토큰]", "국토 방어");
			menu.AddItem(VilN(VILLAGE_050), buffer, (!owner || points < 7) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "능력 사용시 모든 플레이어와 아군의 공격 속도, 재장전 속도, 치유 속도를 25%", ITEMDRAW_DISABLED);
			menu.AddItem("", "만큼 증가. 20 초 지속.\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_030)
	{
		FormatEx(buffer, sizeof(buffer), "%s [6 개선 토큰]%s", "군대 소집", Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_040), buffer, (!owner || points < 6) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "E로 능력 사용시 주변의 모든 아군의", ITEMDRAW_DISABLED);
		menu.AddItem("", "공격 속도, 재장전 속도, 치유 속도를 짧은 시간동안 +12% 증가시킴.\n ", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_020)
	{
		if(tier)
		{
			menu.AddItem("", "레이더 스캐너", ITEMDRAW_DISABLED);
			menu.AddItem("", "범위 내의 모든", ITEMDRAW_DISABLED);
			menu.AddItem("", "적들의 위장 효과를 제거.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%s [5 개선 토큰]%s", "원숭이 정보국", Village_TierExists[1] == 5 ? " [Tier 5 Exists]" : Village_TierExists[1] == 4 ? " [Tier 4 Exists]" : Village_TierExists[1] == 3 ? " [Tier 3 Exists]" : "");
			menu.AddItem(VilN(VILLAGE_030), buffer, (!owner || points < 5) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "주변의 모든 아군들의", ITEMDRAW_DISABLED);
			menu.AddItem("", "공격 피해량이 5% 증가.\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_010)
	{
		FormatEx(buffer, sizeof(buffer), "%s [2 개선 토큰]%s", "레이더 스캐너", Village_TierExists[1] == 5 ? " [Tier 5 Exists]" : Village_TierExists[1] == 4 ? " [Tier 4 Exists]" : Village_TierExists[1] == 3 ? " [Tier 3 Exists]" : Village_TierExists[1] == 2 ? " [Tier 2 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_020), buffer, (!owner || points < 2) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "범위 내의 모든", ITEMDRAW_DISABLED);
		menu.AddItem("", "적들의 위장 효과를 제거.\n ", ITEMDRAW_DISABLED);
	}
	else if(paths < 2)
	{
		FormatEx(buffer, sizeof(buffer), "%s [1 바나나]%s", "재생 차단기", Village_TierExists[1] == 5 ? " [Tier 5 Exists]" : Village_TierExists[1] == 4 ? " [Tier 4 Exists]" : Village_TierExists[1] == 3 ? " [Tier 3 Exists]" : Village_TierExists[1] == 2 ? " [Tier 2 Exists]" : Village_TierExists[1] == 1 ? " [Tier 1 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_010), buffer, (!owner || points < 1) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "보스를 제외한 적들의", ITEMDRAW_DISABLED);
		menu.AddItem("", "체력 회복량이 감소. (대부분 15%%)\n ", ITEMDRAW_DISABLED);
	}
	
	if(Village_Flags[client] & VILLAGE_005)
	{
		menu.AddItem("", "이베리아 등대", ITEMDRAW_DISABLED);
		menu.AddItem("", "영향 범위 내의 모든 아군의 ", ITEMDRAW_DISABLED);
		menu.AddItem("", "공격 속도, 치유 속도 +10%.\n ", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_004)
	{
		if(Village_TierExists[1] == 5)
		{
			menu.AddItem("", "이베리아 안티 레이드", ITEMDRAW_DISABLED);
			menu.AddItem("", "영향 범위 내에 있는 레이드 보스에게 받는 피해 10% 증가 부여. 범위 밖으로 나가면 3초간 지속.", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "이베리아 등대 [18 개선 토큰]");
			menu.AddItem(VilN(VILLAGE_005), buffer, (!owner || points < 18) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "영향 범위 내의 모든 아군의", ITEMDRAW_DISABLED);
			menu.AddItem("", "공격 속도, 치유 속도 +10%.\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_003)
	{
		FormatEx(buffer, sizeof(buffer), "이베리아 안티 레이드 [12 개선 토큰]");
		menu.AddItem(VilN(VILLAGE_004), buffer, (!owner || points < 12) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "영향 범위 내에 있는 레이드 보스에게 받는 피해 10% 증가 부여. 범위 밖으로 나가면 3초간 지속.", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_002)
	{
		if(tier)
		{
			menu.AddItem("", "아머 재생 오라", ITEMDRAW_DISABLED);
			menu.AddItem("", "매 0.5초마다 범위 내의 모든 아군의 아머를\n ", ITEMDRAW_DISABLED);
			menu.AddItem("", "회복시킴.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "조력자 [6 개선 토큰]%s", Village_TierExists[2] == 5 ? " [Tier 5 Exists]" : Village_TierExists[2] == 4 ? " [Tier 4 Exists]" : Village_TierExists[2] == 3 ? " [Tier 3 Exists]" : "");
			menu.AddItem(VilN(VILLAGE_003), buffer, (!owner || points < 6) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "범위 내의 모든 아군은 명흔으로 받는", ITEMDRAW_DISABLED);
			menu.AddItem("", "피해가 80% 감소함.\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_001)
	{
		FormatEx(buffer, sizeof(buffer), "아머 재생 오라 [2 개선 토큰]%s", Village_TierExists[2] == 5 ? " [Tier 5 Exists]" : Village_TierExists[2] == 4 ? " [Tier 4 Exists]" : Village_TierExists[2] == 3 ? " [Tier 3 Exists]" : Village_TierExists[2] == 2 ? " [Tier 2 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_002), buffer, (!owner || points < 2) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "매 0.5초마다 범위 내의 모든 아군의 아머를 1%\n ", ITEMDRAW_DISABLED);
		menu.AddItem("", "회복시킴.\n ", ITEMDRAW_DISABLED);
	}
	else if(paths < 2)
	{
		FormatEx(buffer, sizeof(buffer), "아머 부식 항독제 [2 개선 토큰]%s", Village_TierExists[2] == 5 ? " [Tier 5 Exists]" : Village_TierExists[2] == 4 ? " [Tier 4 Exists]" : Village_TierExists[2] == 3 ? " [Tier 3 Exists]" : Village_TierExists[2] == 2 ? " [Tier 2 Exists]" : Village_TierExists[2] == 1 ? " [Tier 1 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_001), buffer, (!owner || points < 2) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "매 0.5초마다 범위 내의 모든 아군의 아머 부식 수치를 1%.\n ", ITEMDRAW_DISABLED);
		menu.AddItem("", "감소시킴.\n ", ITEMDRAW_DISABLED);
	}

	int entity = Object_GetSentryBuilding(client);
	if(!IsValidEntity(entity))
		return;
		
	float pos[3];
	bool mounted = (Building_Mounted[client] == EntIndexToEntRef(entity));
	if(mounted)
	{
		GetClientEyePosition(client, pos);
	}
	else
	{
		if(IsValidEntity(entity))
		{
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
			pos[2] += 15.0;
		}
	}
	
	menu.Pagination = 0;
	menu.ExitButton = true;
	menu.Display(viewer, MENU_TIME_FOREVER);
}

public int VillageUpgradeMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char num[16];
			menu.GetItem(choice, num, sizeof(num));
			
			switch(StringToInt(num))
			{
				case VILLAGE_500:
				{
					Store_SetNamedItem(client, "Village NPC Expert", 5);
					Village_TierExists[0] = 5;
					
					int entity = EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
					if(entity > MaxClients && IsValidEntity(entity))
					{
						RemoveEntity(entity);
						f_BuildingIsNotReady[client] = 0.0; 
					}
					/*
					int count;
					int i = MaxClients + 1;
					while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
					{
						if(!b_NpcHasDied[i])
						{
							if(Citizen_IsIt(i))
								count++;
						}
					}
					
					if(count < MAX_REBELS_ALLOWED)
						Citizen_SpawnAtPoint(_, client);
						*/
				}
				case VILLAGE_400:
				{
					Store_SetNamedItem(client, "Village NPC Expert", 4);
					Village_TierExists[0] = 4;
				/*
					int count;
					int i = MaxClients + 1;
					while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
					{
						if(!b_NpcHasDied[i])
						{
							if(Citizen_IsIt(i))
								count++;
						}
					}
					
					if(count < MAX_REBELS_ALLOWED)
						Citizen_SpawnAtPoint(_, client);
					*/
				}
				case VILLAGE_300:
				{
					Store_SetNamedItem(client, "Village NPC Expert", 3);
					Village_TierExists[0] = 3;
				/*
					int count;
					int i = MaxClients + 1;
					while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
					{
						if(!b_NpcHasDied[i])
						{
							if(Citizen_IsIt(i))
								count++;
						}
					}
					
					if(count < MAX_REBELS_ALLOWED)
						Citizen_SpawnAtPoint(_, client);
					*/
				}
				case VILLAGE_200:
				{
					Store_SetNamedItem(client, "Village NPC Expert", 2);
					Village_TierExists[0] = 2;
				}
				case VILLAGE_100:
				{
					Store_SetNamedItem(client, "Village NPC Expert", 1);
					Village_TierExists[0] = 1;
				}
				case VILLAGE_050:
				{
					Store_SetNamedItem(client, "Village Buffing Expert", 5);
					f_BuildingIsNotReady[client] = GetGameTime() + 15.0;
					Village_TierExists[1] = 5;
				}
				case VILLAGE_040:
				{
					Store_SetNamedItem(client, "Village Buffing Expert", 4);
					f_BuildingIsNotReady[client] = GetGameTime() + 15.0;
					Village_TierExists[1] = 4;
				}
				case VILLAGE_030:
				{
					Store_SetNamedItem(client, "Village Buffing Expert", 3);
					Village_TierExists[1] = 3;
				}
				case VILLAGE_020:
				{
					Store_SetNamedItem(client, "Village Buffing Expert", 2);
					Village_TierExists[1] = 2;
				}
				case VILLAGE_010:
				{
					Store_SetNamedItem(client, "Village Buffing Expert", 1);
					Village_TierExists[1] = 1;
				}
				case VILLAGE_005:
				{
					Store_SetNamedItem(client, "Village Support Expert", 5);
					Village_TierExists[2] = 5;
				}
				case VILLAGE_004:
				{
					Store_SetNamedItem(client, "Village Support Expert", 4);
					Village_TierExists[2] = 4;
				}
				case VILLAGE_003:
				{
					Store_SetNamedItem(client, "Village Support Expert", 3);
					Village_TierExists[2] = 3;
				}
				case VILLAGE_002:
				{
					Store_SetNamedItem(client, "Village Support Expert", 2);
					Village_TierExists[2] = 2;
				}
				case VILLAGE_001:
				{
					Store_SetNamedItem(client, "Village Support Expert", 1);
					Village_TierExists[2] = 1;
				}
			}
			
			ClientCommand(client, "playgamesound \"mvm/mvm_money_pickup.wav\"");
			VillageCheckItems(client);
			VillageUpgradeMenu(client, client);
		}
	}
	return 0;
}

static char[] VilN(int flag)
{
	char num[16];
	IntToString(flag, num, sizeof(num));
	return num;
}


static void BuildingVillageChangeModel(int owner, int entity)
{
	/*
		Explained:
		Buildings, or sentries in this regard have some special rule where their model scale makes their bounding box scale with it
		thats why we have all this extra shit.
	*/
	int ModelTypeApplied = i_VillageModelAppliance[entity];
	int collisionboxapplied = i_VillageModelApplianceCollisionBox[entity];
	if(ModelTypeApplied == 1 && collisionboxapplied != 1)
	{
		i_VillageModelApplianceCollisionBox[entity] = 1;
		float minbounds[3] = {-20.0, -20.0, 0.0};
		float maxbounds[3] = {20.0, 20.0, 30.0};
		SetEntPropVector(entity, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxbounds);
//		SetEntPropVector(entity, Prop_Send, "m_vecMinsPreScaled", minbounds);
//		SetEntPropVector(entity, Prop_Send, "m_vecMaxsPreScaled", maxbounds);

//		view_as<CClotBody>(entity).UpdateCollisionBox();
	}
	else if(ModelTypeApplied == 2 && collisionboxapplied != 2)
	{
		i_VillageModelApplianceCollisionBox[entity] = 2;
		float minbounds[3] = {-20.0, -20.0, 0.0};
		float maxbounds[3] = {20.0, 20.0, 30.0};
		SetEntPropVector(entity, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxbounds);
//		SetEntPropVector(entity, Prop_Send, "m_vecMinsPreScaled", minbounds);
//		SetEntPropVector(entity, Prop_Send, "m_vecMaxsPreScaled", maxbounds);

//		view_as<CClotBody>(entity).UpdateCollisionBox();
	}
	else if(ModelTypeApplied == 3 && collisionboxapplied != 3)
	{
		i_VillageModelApplianceCollisionBox[entity] = 3;
		float minbounds[3] = {-20.0, -20.0, 0.0};
		float maxbounds[3] = {20.0, 20.0, 30.0};
		SetEntPropVector(entity, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxbounds);
//		SetEntPropVector(entity, Prop_Send, "m_vecMinsPreScaled", minbounds);
//		SetEntPropVector(entity, Prop_Send, "m_vecMaxsPreScaled", maxbounds);

//		view_as<CClotBody>(entity).UpdateCollisionBox();
	}
	else if(ModelTypeApplied == 4 && collisionboxapplied != 4)
	{
		i_VillageModelApplianceCollisionBox[entity] = 4;
		float minbounds[3] = {-20.0, -20.0, 0.0};
		float maxbounds[3] = {20.0, 20.0, 30.0};
		SetEntPropVector(entity, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxbounds);
//		SetEntPropVector(entity, Prop_Send, "m_vecMinsPreScaled", minbounds);
//		SetEntPropVector(entity, Prop_Send, "m_vecMaxsPreScaled", maxbounds);

//		view_as<CClotBody>(entity).UpdateCollisionBox();
	}
	else if(ModelTypeApplied == 5 && collisionboxapplied != 5)
	{
		i_VillageModelApplianceCollisionBox[entity] = 5;
		float minbounds[3] = {-20.0, -20.0, 0.0};
		float maxbounds[3] = {20.0, 20.0, 30.0};
		SetEntPropVector(entity, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxbounds);
//		SetEntPropVector(entity, Prop_Send, "m_vecMinsPreScaled", minbounds);
//		SetEntPropVector(entity, Prop_Send, "m_vecMaxsPreScaled", maxbounds);

//		view_as<CClotBody>(entity).UpdateCollisionBox();
	}
	if(Village_Flags[owner] & VILLAGE_500 && ModelTypeApplied != 5)
	{
		i_VillageModelAppliance[entity] = 5;
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.75);
		SetEntityModel(entity, VILLAGE_MODEL_REBEL);
	}
	else if(Village_Flags[owner] & VILLAGE_300 && !(Village_Flags[owner] & VILLAGE_500) && ModelTypeApplied != 1)
	{
		i_VillageModelAppliance[entity] = 1;
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.4);
		SetEntityModel(entity, VILLAGE_MODEL_REBEL);
	}
	else if(Village_Flags[owner] & VILLAGE_030 && ModelTypeApplied != 2)
	{
		i_VillageModelAppliance[entity] = 2;
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.4);
		SetEntityModel(entity, VILLAGE_MODEL_MIDDLE);
	}
	else if(Village_Flags[owner] & VILLAGE_003 && ModelTypeApplied != 3)
	{
		i_VillageModelAppliance[entity] = 3;
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 1.5);
		SetEntityModel(entity, VILLAGE_MODEL_LIGHTHOUSE);
	}
	else if(ModelTypeApplied == 0)
	{
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.75);
		i_VillageModelAppliance[entity] = 4;
		SetEntityModel(entity, VILLAGE_MODEL);
	}
}
