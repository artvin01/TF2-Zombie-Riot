#pragma semicolon 1
#pragma newdecls required

#define VILLAGE_MODEL "models/props_rooftop/roof_dish001.mdl"
#define VILLAGE_MODEL_LIGHTHOUSE "models/props_sunshine/lighthouse_top_skybox.mdl"
#define VILLAGE_MODEL_MIDDLE "models/props_urban/urban_skybuilding005a.mdl"
#define VILLAGE_MODEL_REBEL "models/egypt/tent/tent.mdl"

enum struct VillageBuff
{
	int EntityRef;
	int VillageRef;
	int Effects;
	bool IsWeapon;
}

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

static float Village_ReloadBuffFor[MAXTF2PLAYERS];
static int Village_Flags[MAXTF2PLAYERS];
static bool Village_ForceUpdate[MAXTF2PLAYERS];
static ArrayList Village_Effects;
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

	delete Village_Effects;
	Village_Effects = new ArrayList(sizeof(VillageBuff));
	
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
int Building_GetClientVillageFlags(int client)
{
	if(!Village_Effects)
		return 0;
	
	int applied;
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	VillageBuff buff;
	int length = Village_Effects.Length;
	for(int i; i < length; i++)
	{
		Village_Effects.GetArray(i, buff);
		int entity = EntRefToEntIndex(buff.EntityRef);
		if(entity == client || entity == weapon)
			applied |= buff.Effects;
	}

	return applied;
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

	i_ExtraPlayerPoints[owner] += 2; //Static low point increace.
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
	if(points < 0)
	{
		range = 0.0;
	}
	BuildingApplyDebuffyToEnemiesInRange(owner, range, mounted);

	range = range * range;
	ArrayList weapons = new ArrayList();
	ArrayList allies = new ArrayList();
	
	float pos2[3];
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < range && f_ClientArmorRegen[client] - 0.3 < GetGameTime())
			{
				allies.Push(client);

				if(effects & VILLAGE_002)
				{
					int maxarmor = MaxArmorCalculation(Armor_Level[client], client, 0.5);
					if(Armor_Charge[client] < maxarmor)
					{
						f_ClientArmorRegen[client] = GetGameTime() + 0.7;
						if(f_TimeUntillNormalHeal[client] > GetGameTime())
							GiveArmorViaPercentage(client, 0.0025, 1.0);
						else
							GiveArmorViaPercentage(client, 0.01, 1.0);
					}
				}
				else if(effects & VILLAGE_001)
				{
					if(Armor_Charge[client] < 0)
					{
						f_ClientArmorRegen[client] = GetGameTime() + 0.7;
						if(f_TimeUntillNormalHeal[client] > GetGameTime())
							GiveArmorViaPercentage(client, 0.0025, 1.0);
						else
							GiveArmorViaPercentage(client, 0.01, 1.0);
					}
				}

				int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon > MaxClients)
					weapons.Push(weapon);
			}
		}
	}
	
	int i = MaxClients + 1;
	while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
	{
		if(GetTeam(i) == TFTeam_Red)
		{
			GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < range)
				allies.Push(i);
		}
	}
	
	VillageBuff buff;
	int length = Village_Effects.Length;
	for(i = 0; i < length; i++)
	{
		Village_Effects.GetArray(i, buff);
		if(buff.VillageRef == ref)
		{
			int target = EntRefToEntIndex(buff.EntityRef);
			if(target == -1)
			{
				Village_Effects.Erase(i--);
				length--;
			}
			else
			{
				int weapPos = -1;
				int allyPos = allies.FindValue(target);
				if(allyPos == -1)
					weapPos = weapons.FindValue(target);
				
				if(allyPos == -1 && weapPos == -1)
				{
					int oldBuffs = GetBuffEffects(buff.EntityRef);
					
					Village_Effects.Erase(i--);
					length--;
					
					UpdateBuffEffects(target, buff.IsWeapon, oldBuffs, GetBuffEffects(buff.EntityRef));
				}
				else
				{
					if(allyPos != -1)
					{
						allies.Erase(allyPos);
					}
					else
					{
						weapons.Erase(weapPos);
					}
					
					if(Village_ForceUpdate[owner])
					{
						int oldBuffs = GetBuffEffects(buff.EntityRef);
						
						buff.Effects = effects;
						Village_Effects.SetArray(i, buff);
						
						UpdateBuffEffects(target, buff.IsWeapon, oldBuffs, GetBuffEffects(buff.EntityRef));
					}
				}
			}
		}
	}
	
	length = allies.Length;
	for(i = 0; i < length; i++)
	{
		int target = allies.Get(i);
		
		buff.EntityRef = EntIndexToEntRef(target);
		
		int oldBuffs = GetBuffEffects(buff.EntityRef);
		
		buff.VillageRef = ref;
		buff.IsWeapon = false;
		buff.Effects = effects;
		Village_Effects.PushArray(buff);
		
		UpdateBuffEffects(target, buff.IsWeapon, oldBuffs, GetBuffEffects(buff.EntityRef));
	}
	
	length = weapons.Length;
	for(i = 0; i < length; i++)
	{
		int target = weapons.Get(i);
		
		buff.EntityRef = EntIndexToEntRef(target);
		
		int oldBuffs = GetBuffEffects(buff.EntityRef);
		
		buff.VillageRef = ref;
		buff.IsWeapon = true;
		buff.Effects = effects;
		Village_Effects.PushArray(buff);
		
		UpdateBuffEffects(target, buff.IsWeapon, oldBuffs, GetBuffEffects(buff.EntityRef));
	}
	
	delete weapons;
	delete allies;
	
	Village_ForceUpdate[owner] = false;
	return entity == INVALID_ENT_REFERENCE ? Plugin_Stop : Plugin_Continue;
}

stock void Building_ClearRefBuffs(int ref)
{
	for(int i = -1; (i = Village_Effects.FindValue(ref, VillageBuff::EntityRef)) != -1; )
	{
		Village_Effects.Erase(i);
	}
}

bool Building_NeatherseaReduced(int entity)
{
	return view_as<bool>(GetBuffEffects(EntIndexToEntRef(entity)) & VILLAGE_003);
}

void BuildingApplyDebuffyToEnemiesInRange(int client, float range, bool mounted)
{
	if(Village_Flags[client] & VILLAGE_004)
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
		BuildingAntiRaidInternal);
	}
}

void BuildingAntiRaidInternal(int entity, int victim, float damage, int weapon)
{
	if(entity == victim)
		return;

	if(b_thisNpcIsARaid[victim])
	{
		ApplyStatusEffect(entity, victim, "Iberia's Anti Raid", 3.0);
	}
}

void Building_CamoOrRegrowBlocker(int entity, bool &camo = false, bool &regrow = false)
{
	if(camo || regrow)
	{
		if(GetTeam(entity) != 2)
		{
			static float pos1[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);

			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					int obj = Object_GetSentryBuilding(client);
					if(obj != -1)
					{
						static float pos2[3];
						bool mounted = (Building_Mounted[client] == EntIndexToEntRef(obj));
						if(mounted)
						{
							GetClientEyePosition(client, pos2);
						}
						else
						{
							GetEntPropVector(obj, Prop_Data, "m_vecAbsOrigin", pos2);
						}

						float range = 600.0;
						
						if(Village_Flags[client] & VILLAGE_100)
							range += 120.0;
						
						if(Village_Flags[client] & VILLAGE_500)
						{
							range += 125.0;
						}
						else if(Village_Flags[client] & VILLAGE_005)
						{
							range += 150.0;
						}
						
						if(mounted)
							range *= 0.55;
						
						range = range * range;

						if(GetVectorDistance(pos1, pos2, true) < range)
						{
							if(camo && (Village_Flags[client] & VILLAGE_020))
								camo = false;
							
							if(regrow && (Village_Flags[client] & VILLAGE_010))
								regrow = false;
						}
					}
				}
			}
		}
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
				i_ExtraPlayerPoints[Owner] += 100; //Static point increace.
				Village_ReloadBuffFor[Owner] = gameTime + 20.0;
				EmitSoundToAll("items/powerup_pickup_uber.wav");
				EmitSoundToAll("items/powerup_pickup_uber.wav");
			}
			else
			{
				i_ExtraPlayerPoints[Owner] += 50; //Static point increace.
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
		menu.SetTitle("%s\n \nBananas: %d (%s)\n ", TranslateItemName(viewer, "Buildable Village", ""), points, TranslateItemName(viewer, "Building Upgrades", ""));
	}
	else
	{
		menu.SetTitle("%s\n \nYou're in Banana dept! Buffs dont work!: %d (%s)\n ", TranslateItemName(viewer, "Buildable Village", ""), points, TranslateItemName(viewer, "Building Upgrades", ""));	
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
		menu.AddItem("", TranslateItemName(viewer, "Rebel Expertise", ""), ITEMDRAW_DISABLED);
		menu.AddItem("", "Village becomes an attacking sentry, plus all Rebels in", ITEMDRAW_DISABLED);
		menu.AddItem("", "radius attack faster, deal more damage, and start with $1750.\n ", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_400)
	{
		/*
		if(Village_TierExists[0] == 5)
		{
			menu.AddItem("", TranslateItemName(viewer, "Rebel Mentoring", ""), ITEMDRAW_DISABLED);
			menu.AddItem("", "All Rebels in radius start with $500,", ITEMDRAW_DISABLED);
			menu.AddItem("", "increased range and attack speed.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%s [4 Bananas]", TranslateItemName(viewer, "Rebel Expertise", ""));
			menu.AddItem(VilN(VILLAGE_500), buffer, (!owner || points < 4) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "Village becomes an attacking sentry, plus all Rebels in", ITEMDRAW_DISABLED);
			menu.AddItem("", "radius attack faster, deal more damage, and start with $1750.\n ", ITEMDRAW_DISABLED);
		}
		*/
	}
	else if(Village_Flags[client] & VILLAGE_300)
	{	/*
		FormatEx(buffer, sizeof(buffer), "%s [3 Bananas]%s", TranslateItemName(viewer, "Rebel Mentoring", ""), Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_400), buffer, (!owner || points < 3) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "All Rebels in radius start with $500,", ITEMDRAW_DISABLED);
		menu.AddItem("", "increased range and attack speed.\n ", ITEMDRAW_DISABLED);
		*/
	}
	else if(Village_Flags[client] & VILLAGE_200)
	{
		if(tier)
		{
			menu.AddItem("", TranslateItemName(viewer, "Jungle Drums", ""), ITEMDRAW_DISABLED);
			menu.AddItem("", "Increases attack speed and reloadspeed of all", ITEMDRAW_DISABLED);
			menu.AddItem("", "players and allies in the radius.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			menu.AddItem("", "PATH LOCKED.", ITEMDRAW_DISABLED);
		//	menu.AddItem("", "Increases attack speed and reloadspeed of all", ITEMDRAW_DISABLED);
		//	menu.AddItem("", "players and allies in the radius.\n ", ITEMDRAW_DISABLED);
			/*
			FormatEx(buffer, sizeof(buffer), "%s [2 Bananas]%s", TranslateItemName(viewer, "Rebel Training", ""), Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : Village_TierExists[0] == 3 ? " [Tier 3 Exists]" : "");
			menu.AddItem(VilN(VILLAGE_300), buffer, (!owner || points < 2) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "All Rebels in radius get", ITEMDRAW_DISABLED);
			menu.AddItem("", "more range and more damage.\n", ITEMDRAW_DISABLED);
			menu.AddItem("", "Village will spawn rebels every 3 waves upto 3\n ", ITEMDRAW_DISABLED);
			*/
		}
	}
	else if(Village_Flags[client] & VILLAGE_100)
	{
		FormatEx(buffer, sizeof(buffer), "%s [3 Bananas]%s", TranslateItemName(viewer, "Jungle Drums", ""), Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : Village_TierExists[0] == 3 ? " [Tier 3 Exists]" : Village_TierExists[0] == 2 ? " [Tier 2 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_200), buffer, (!owner || points < 3) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Increases attack speed of all", ITEMDRAW_DISABLED);
		menu.AddItem("", "players and allies in the radius by 5% and healrate by 8%.\n ", ITEMDRAW_DISABLED);
	}
	else if(paths < 2)
	{
		if(owner)
			menu.AddItem("", "TIP: Only one path can have a tier 3 upgrade.\n ", ITEMDRAW_DISABLED);
		
		FormatEx(buffer, sizeof(buffer), "%s [1 Banana]%s", TranslateItemName(viewer, "Bigger Radius", ""), Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : Village_TierExists[0] == 3 ? " [Tier 3 Exists]" : Village_TierExists[0] == 2 ? " [Tier 2 Exists]" : Village_TierExists[0] == 1 ? " [Tier 1 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_100), buffer, (!owner || points < 1) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Increases influence radius of the village.\n ", ITEMDRAW_DISABLED);
	}
	
	if(Village_Flags[client] & VILLAGE_050)
	{
		menu.AddItem("", TranslateItemName(viewer, "Homeland Defense", ""), ITEMDRAW_DISABLED);
		menu.AddItem("", "Ability now increases attack speed and reloadspeed and heal rate by 25%", ITEMDRAW_DISABLED);
		menu.AddItem("", "for all players and allies for 20 seconds.\n ", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_040)
	{
		if(Village_TierExists[1] == 5)
		{
			menu.AddItem("", TranslateItemName(viewer, "Call To Arms", ""), ITEMDRAW_DISABLED);
			menu.AddItem("", "Press E to activate an ability that gives nearby", ITEMDRAW_DISABLED);
			menu.AddItem("", "players and allies +12% attack speed and reloadspeed and heal rate for a short time.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%s [7 Bananas]", TranslateItemName(viewer, "Homeland Defense", ""));
			menu.AddItem(VilN(VILLAGE_050), buffer, (!owner || points < 7) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "Ability now increases attack speed and reloadspeed and heal rate by 25%", ITEMDRAW_DISABLED);
			menu.AddItem("", "for all players and allies for 20 seconds.\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_030)
	{
		FormatEx(buffer, sizeof(buffer), "%s [6 Bananas]%s", TranslateItemName(viewer, "Call To Arms", ""), Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_040), buffer, (!owner || points < 6) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Press E to activate an ability that gives nearby", ITEMDRAW_DISABLED);
		menu.AddItem("", "players and allies +12% attack speed and reloadspeed and heal rate for a short time.\n ", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_020)
	{
		if(tier)
		{
			menu.AddItem("", TranslateItemName(viewer, "Radar Scanner", ""), ITEMDRAW_DISABLED);
			menu.AddItem("", "Removes camo properites off", ITEMDRAW_DISABLED);
			menu.AddItem("", "enemies while in influence radius.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%s [5 Bananas]%s", TranslateItemName(viewer, "Monkey Intelligence Bureau", ""), Village_TierExists[1] == 5 ? " [Tier 5 Exists]" : Village_TierExists[1] == 4 ? " [Tier 4 Exists]" : Village_TierExists[1] == 3 ? " [Tier 3 Exists]" : "");
			menu.AddItem(VilN(VILLAGE_030), buffer, (!owner || points < 5) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "The Bureau grants special Bloon popping knowledge, allowing", ITEMDRAW_DISABLED);
			menu.AddItem("", "nearby players and allies to deal 5% more damage.\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_010)
	{
		FormatEx(buffer, sizeof(buffer), "%s [2 Bananas]%s", TranslateItemName(viewer, "Radar Scanner", ""), Village_TierExists[1] == 5 ? " [Tier 5 Exists]" : Village_TierExists[1] == 4 ? " [Tier 4 Exists]" : Village_TierExists[1] == 3 ? " [Tier 3 Exists]" : Village_TierExists[1] == 2 ? " [Tier 2 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_020), buffer, (!owner || points < 2) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Removes camo properites off", ITEMDRAW_DISABLED);
		menu.AddItem("", "enemies while in influence radius.\n ", ITEMDRAW_DISABLED);
	}
	else if(paths < 2)
	{
		FormatEx(buffer, sizeof(buffer), "%s [1 Banana]%s", TranslateItemName(viewer, "Grow Blocker", ""), Village_TierExists[1] == 5 ? " [Tier 5 Exists]" : Village_TierExists[1] == 4 ? " [Tier 4 Exists]" : Village_TierExists[1] == 3 ? " [Tier 3 Exists]" : Village_TierExists[1] == 2 ? " [Tier 2 Exists]" : Village_TierExists[1] == 1 ? " [Tier 1 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_010), buffer, (!owner || points < 1) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Lowers non-boss enemies from", ITEMDRAW_DISABLED);
		menu.AddItem("", "gaining health in the influence radius as much (50% usually).\n ", ITEMDRAW_DISABLED);
	}
	
	if(Village_Flags[client] & VILLAGE_005)
	{
		menu.AddItem("", "Iberia Lighthouse", ITEMDRAW_DISABLED);
		menu.AddItem("", "Increases influnce radius and all nearby allies", ITEMDRAW_DISABLED);
		menu.AddItem("", "gains a +10% attack speed and healing rate.\n ", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_004)
	{
		if(Village_TierExists[1] == 5)
		{
			menu.AddItem("", "Iberia Anti-Raid", ITEMDRAW_DISABLED);
			menu.AddItem("", "Causes Raid Bosses to take 10% more damage in its range and for 3 seconds after existing the range.", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "Iberia Lighthouse [18 Bananas]");
			menu.AddItem(VilN(VILLAGE_005), buffer, (!owner || points < 18) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "Increases influnce radius and all nearby allies", ITEMDRAW_DISABLED);
			menu.AddItem("", "gains a +10% attack speed and healing rate.\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_003)
	{
		FormatEx(buffer, sizeof(buffer), "Iberia Anti-Raid [12 Bananas]");
		menu.AddItem(VilN(VILLAGE_004), buffer, (!owner || points < 12) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Causes Raid Bosses to take 10% more damage in its range and for 3 seconds after existing the range.", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_002)
	{
		if(tier)
		{
			menu.AddItem("", "Armor Aid", ITEMDRAW_DISABLED);
			menu.AddItem("", "Gain a point of armor every half second.\n ", ITEMDRAW_DISABLED);
			menu.AddItem("", "to all players with armor in range.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "Little Handy [6 Bananas]%s", Village_TierExists[2] == 5 ? " [Tier 5 Exists]" : Village_TierExists[2] == 4 ? " [Tier 4 Exists]" : Village_TierExists[2] == 3 ? " [Tier 3 Exists]" : "");
			menu.AddItem(VilN(VILLAGE_003), buffer, (!owner || points < 6) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "Reduces the damage caused by nethersea brands", ITEMDRAW_DISABLED);
			menu.AddItem("", "by 80% to all allies with in range.\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_001)
	{
		FormatEx(buffer, sizeof(buffer), "Armor Aid [2 Bananas]%s", Village_TierExists[2] == 5 ? " [Tier 5 Exists]" : Village_TierExists[2] == 4 ? " [Tier 4 Exists]" : Village_TierExists[2] == 3 ? " [Tier 3 Exists]" : Village_TierExists[2] == 2 ? " [Tier 2 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_002), buffer, (!owner || points < 2) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Gain 1% of armor every half.\n ", ITEMDRAW_DISABLED);
		menu.AddItem("", "second to all players in range.\n ", ITEMDRAW_DISABLED);
	}
	else if(paths < 2)
	{
		FormatEx(buffer, sizeof(buffer), "Wandering Aid [2 Bananas]%s", Village_TierExists[2] == 5 ? " [Tier 5 Exists]" : Village_TierExists[2] == 4 ? " [Tier 4 Exists]" : Village_TierExists[2] == 3 ? " [Tier 3 Exists]" : Village_TierExists[2] == 2 ? " [Tier 2 Exists]" : Village_TierExists[2] == 1 ? " [Tier 1 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_001), buffer, (!owner || points < 2) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Heals 1% of armor erosion every.\n ", ITEMDRAW_DISABLED);
		menu.AddItem("", "half second to all players in range.\n ", ITEMDRAW_DISABLED);
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

static int GetBuffEffects(int ref)
{
	int flags;
	
	VillageBuff buff;
	int length = Village_Effects.Length;
	for(int i; i < length; i++)
	{
		Village_Effects.GetArray(i, buff);
		if(buff.EntityRef == ref)
			flags |= buff.Effects;
	}
	
	return flags;
}

static void UpdateBuffEffects(int entity, bool weapon, int oldBuffs, int newBuffs)
{
	if(weapon)
	{
		for(int i; i < 16; i++)
		{
			int flag = (1 << i);
			bool hadBefore = view_as<bool>(oldBuffs & flag);
			
			if(newBuffs & flag)
			{
				if(!hadBefore)
				{
					switch(flag)
					{
						case VILLAGE_000:
						{
							if(Attributes_Has(entity, 101))
								Attributes_SetMulti(entity, 101, 1.1);	// Projectile Range
							
							if(Attributes_Has(entity, 103))
								Attributes_SetMulti(entity, 103, 1.1);	// Projectile Speed
						}
						case VILLAGE_200:
						{
							if(Attributes_Has(entity, 6))
								Attributes_SetMulti(entity, 6, 0.975);	// Fire Rate
							
							if(Attributes_Has(entity, 97))
								Attributes_SetMulti(entity, 97, 0.975);	// Reload Time
							
							if(Attributes_Has(entity, 8))
								Attributes_SetMulti(entity, 8, 1.025);	// Heal Rate
						}
						case VILLAGE_030:
						{
							if(Attributes_Has(entity, 2))
								Attributes_SetMulti(entity, 2, 1.05);	// Damage
							
							if(Attributes_Has(entity, 410))
								Attributes_SetMulti(entity, 410, 1.05);	// Mage Damage
						}
						case VILLAGE_040, VILLAGE_050:
						{
							if(Waves_InFreeplay())
							{
								if(Attributes_Has(entity, 6))
									Attributes_SetMulti(entity, 6, 0.94);	// Fire Rate
								
								if(Attributes_Has(entity, 97))
									Attributes_SetMulti(entity, 97, 0.94);	// Reload Time
							}
							else
							{
								if(Attributes_Has(entity, 6))
									Attributes_SetMulti(entity, 6, 0.88);	// Fire Rate
								
								if(Attributes_Has(entity, 97))
									Attributes_SetMulti(entity, 97, 0.88);	// Reload Time
							}
							
							if(Attributes_Has(entity, 8))
								Attributes_SetMulti(entity, 8, 1.12);	// Heal Rate
						}
						case VILLAGE_005:
						{
							if(Attributes_Has(entity, 6))
								Attributes_SetMulti(entity, 6, 0.90);	// Fire Rate
							
							if(Attributes_Has(entity, 97))
								Attributes_SetMulti(entity, 97, 0.90);	// Reload Time
							
							if(Attributes_Has(entity, 8))
								Attributes_SetMulti(entity, 8, 1.1);	// Heal Rate
						}
					}
				}
			}
			else if(hadBefore)
			{
				switch(flag)
				{
					case VILLAGE_000:
					{
						if(Attributes_Has(entity, 101))
							Attributes_SetMulti(entity, 101, 1.0 / 1.1);	// Projectile Range
						
						if(Attributes_Has(entity, 103))
							Attributes_SetMulti(entity, 103, 1.0 / 1.1);	// Projectile Speed
					}
					case VILLAGE_200:
					{
						if(Attributes_Has(entity, 6))
							Attributes_SetMulti(entity, 6, 1.0 / 0.975);	// Fire Rate
						
						if(Attributes_Has(entity, 97))
							Attributes_SetMulti(entity, 97, 1.0 / 0.975);	// Reload Time
						
						if(Attributes_Has(entity, 8))
							Attributes_SetMulti(entity, 8, 1.0 / 1.025);	// Heal Rate
					}
					case VILLAGE_030:
					{
						if(Attributes_Has(entity, 2))
								Attributes_SetMulti(entity, 2, 1.0 / 1.05);	// Damage
					
						if(Attributes_Has(entity, 410))
							Attributes_SetMulti(entity, 410, 1.0 / 1.05);	// Mage Damage
					}
					case VILLAGE_040, VILLAGE_050:
					{
						if(Waves_InFreeplay())
						{
							if(Attributes_Has(entity, 6))
								Attributes_SetMulti(entity, 6, 1.0 / 0.94);	// Fire Rate
						
							if(Attributes_Has(entity, 97))
								Attributes_SetMulti(entity, 97, 1.0 / 0.94);	// Reload Time
						}
						else
						{
							if(Attributes_Has(entity, 6))
								Attributes_SetMulti(entity, 6, 1.0 / 0.88);	// Fire Rate
						
							if(Attributes_Has(entity, 97))
								Attributes_SetMulti(entity, 97, 1.0 / 0.88);	// Reload Time
						}
						
						if(Attributes_Has(entity, 8))
							Attributes_SetMulti(entity, 8, 1.0 / 1.12);	// Heal Rate
					}
					case VILLAGE_005:
					{
						if(Attributes_Has(entity, 6))
							Attributes_SetMulti(entity, 6, 1.0 / 0.90);	// Fire Rate
						
						if(Attributes_Has(entity, 97))
							Attributes_SetMulti(entity, 97, 1.0 / 0.90);	// Reload Time
						
						if(Attributes_Has(entity, 8))
							Attributes_SetMulti(entity, 8, 1.0 / 1.1);	// Heal Rate
					}
				}
			}
		}
	}
	else if(Citizen_IsIt(entity))
	{
		Citizen npc = view_as<Citizen>(entity);
		
		for(int i; i < 16; i++)
		{
			int flag = (1 << i);
			bool hadBefore = view_as<bool>(oldBuffs & flag);
			
			if(newBuffs & flag)
			{
				if(!hadBefore)
				{
					switch(flag)
					{
						case VILLAGE_000:
						{
							npc.m_fGunRangeBonus *= 1.1;
						}
						case VILLAGE_200:
						{
							npc.m_fGunFirerate *= 0.975;
							npc.m_fGunReload *= 0.975;
						}
						case VILLAGE_300:
						{
					//		if(npc.m_iGunClip > 0)
					//			npc.m_iGunClip++;
							
							npc.m_fGunRangeBonus *= 1.05;
						}
						case VILLAGE_400:
						{
							if(npc.m_iGunValue < 500)
								npc.m_iGunValue = 500;
							
							npc.m_fGunFirerate *= 0.95;
							npc.m_fGunReload *= 0.95;
						}
						case VILLAGE_500:
						{
					//		if(npc.m_iGunClip > 0)
					//			npc.m_iGunClip += 2;
							
							if(npc.m_iGunValue < 1750)
								npc.m_iGunValue = 1750;
							
							npc.m_fGunRangeBonus *= 1.1;
							npc.m_fGunFirerate *= 0.9;
							npc.m_fGunReload *= 0.9;
						}
						case VILLAGE_030:
						{
							npc.m_fGunRangeBonus *= 1.05;
						}
						case VILLAGE_040:
						{
							npc.m_fGunFirerate *= 0.88;
							npc.m_fGunReload *= 0.88;
						}
						case VILLAGE_050:
						{
							if(Waves_InFreeplay())
							{
								npc.m_fGunFirerate *= 0.94;
								npc.m_fGunReload *= 0.94;
							}
							else
							{
								npc.m_fGunFirerate *= 0.85;
								npc.m_fGunReload *= 0.85;
							}
						}
						case VILLAGE_005:
						{
							npc.m_fGunFirerate *= 0.90;
							npc.m_fGunReload *= 0.90;
						}
					}
				}
			}
			else if(hadBefore)
			{
				switch(flag)
				{
					case VILLAGE_000:
					{
						npc.m_fGunRangeBonus /= 1.1;
					}
					case VILLAGE_200:
					{
						npc.m_fGunFirerate /= 0.975;
						npc.m_fGunReload /= 0.975;
					}
					case VILLAGE_300:
					{
					//	if(npc.m_iGunClip > 1)
					//		npc.m_iGunClip--;
						
						npc.m_fGunRangeBonus /= 1.05;
					}
					case VILLAGE_400:
					{
						npc.m_fGunFirerate /= 0.95;
						npc.m_fGunReload /= 0.95;
					}
					case VILLAGE_500:
					{
					//	if(npc.m_iGunClip > 2)
					//		npc.m_iGunClip -= 2;
						
						npc.m_fGunRangeBonus /= 1.1;
						npc.m_fGunFirerate /= 0.9;
						npc.m_fGunReload /= 0.9;
					}
					case VILLAGE_030:
					{
						npc.m_fGunRangeBonus /= 1.05;
					}
					case VILLAGE_040:
					{
						npc.m_fGunFirerate /= 0.88;
						npc.m_fGunReload /= 0.88;
					}
					case VILLAGE_050:
					{
						if(Waves_InFreeplay())
						{
							npc.m_fGunFirerate /= 0.94;
							npc.m_fGunReload /= 0.94;
						}
						else
						{
							npc.m_fGunFirerate /= 0.85;
							npc.m_fGunReload /= 0.85;
						}
					}
					case VILLAGE_005:
					{
						npc.m_fGunFirerate /= 0.90;
						npc.m_fGunReload /= 0.90;
					}
				}
			}
		}
	}/*
	else if(entity > MaxClients)
	{
		BarrackBody npc = view_as<BarrackBody>(entity);
		
		if(npc.OwnerUserId)
		{
			for(int i; i < 16; i++)
			{
				int flag = (1 << i);
				bool hadBefore = view_as<bool>(oldBuffs & flag);
				
				if(newBuffs & flag)
				{
					if(!hadBefore)
					{
						switch(flag)
						{
							case VILLAGE_200:
							{
								npc.BonusFireRate *= 0.975;
							}
							case VILLAGE_030:
							{
								npc.BonusDamageBonus *= 1.05;
							}
							case VILLAGE_040:
							{
								npc.BonusFireRate *= 0.88;
							}
							case VILLAGE_050:
							{
								npc.BonusFireRate *= 0.85;
							}
							case VILLAGE_005:
							{
								npc.BonusFireRate *= 0.90;
							}
						}
					}
				}
				else if(hadBefore)
				{
					switch(flag)
					{
						case VILLAGE_200:
						{
							npc.BonusFireRate /= 0.95;
						}
						case VILLAGE_030:
						{
							npc.BonusDamageBonus /= 1.05;
						}
						case VILLAGE_040:
						{
							npc.BonusFireRate /= 0.88;
						}
						case VILLAGE_050:
						{
							npc.BonusFireRate /= 0.85;
						}
						case VILLAGE_005:
						{
							npc.BonusFireRate /= 0.90;
						}
					}
				}
			}
		}
	}*/
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
