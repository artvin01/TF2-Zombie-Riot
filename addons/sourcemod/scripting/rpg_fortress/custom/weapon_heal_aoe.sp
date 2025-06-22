#pragma semicolon 1
#pragma newdecls required

#define WAND_INIT_SOUND "player/mannpower_invulnerable.wav"

static float f_HealAmount[MAXPLAYERS];
static char gLaser1;
static bool b_WasMagicFocus[MAXPLAYERS];


void Wand_HolyLight_Map_Precache()
{
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	PrecacheSound(WAND_INIT_SOUND);
	PrecacheSound("npc/strider/charging.wav");
}

public float AbilityHolyLight(int client, int index, char name[48])
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(!kv)
	{
		return 0.0;
	}

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!IsValidEntity(weapon))
	{
		return 0.0;
	}

	static char classname[36];
	GetEntityClassname(weapon, classname, sizeof(classname));
	if (!i_IsWandWeapon[weapon])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Magic Wand.");
		return 0.0;
	}
	if(Stats_Intelligence(client) < 150)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "You do not have enough Intelligence [150]");
		return 0.0;
	}

	int StatsForCalcMultiAdd;
	Stats_Artifice(client, StatsForCalcMultiAdd);
	StatsForCalcMultiAdd /= 4;
	//get base endurance for cost
	if(i_CurrentStamina[client] < StatsForCalcMultiAdd)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%s", "Not Enough Stamina");
		return 0.0;
	}

	int StatsForCalcMultiAdd_Capacity;

	StatsForCalcMultiAdd_Capacity = StatsForCalcMultiAdd * 2;

	if(Current_Mana[client] < StatsForCalcMultiAdd_Capacity)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%s", "Not Enough Mana");
		return 0.0;
	}
	
	int StatsForCalcMultiAdd_dmg;
	StatsForCalcMultiAdd_dmg = Stats_Artifice(client);

	float damageDelt = RPGStats_FlatDamageSetStats(client, 0, StatsForCalcMultiAdd_dmg);

	damageDelt *= 0.5;
	b_WasMagicFocus[client] = false;

	Weapon_HolyLightInit(client, weapon,/* 1,*/ damageDelt);
	float time = 30.0;
	RPGCore_ResourceReduction(client, StatsForCalcMultiAdd_Capacity);
	if(ChronoShiftReady(client) == 2)
	{
		ChronoShiftDoCooldown(client);
		time = 0.0;
	}
	else
	{
		RPGCore_StaminaReduction(weapon, client, StatsForCalcMultiAdd / 2);
	}
	return (GetGameTime() + time);
}

stock void Weapon_HolyLightInit(int client, int weapon/*, int level*/, float damage)
{
	static float startPos[3];
	GetClientEyePosition(client, startPos);
	static float endPos[3], eyeAngles[3];
	GetClientEyeAngles(client, eyeAngles);
	TR_TraceRayFilter(startPos, eyeAngles, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitPlayersOrEntityCombat, client);
	TR_GetEndPosition(endPos);
	f_HealAmount[client] = damage;
	
	float RadiusHeal = 400.0;
	float DurationUntill = 1.6;
	
	endPos[2] += 2.0;
	if(MagicFocusReady(client))
	{
		MagicFocusUse(client);
		b_WasMagicFocus[client] = true;
	}
	if(!b_WasMagicFocus[client])
	{
		spawnRing_Vectors(endPos, /*RANGE*/ RadiusHeal * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 200, 1, /*DURATION*/ DurationUntill, 12.0, 0.1, 1);
		spawnRing_Vectors(endPos, /*RANGE*/ RadiusHeal * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 200, 1, /*DURATION*/ DurationUntill, 12.0, 0.1, 1, 1.0);
	}
	else
	{
		spawnRing_Vectors(endPos, /*RANGE*/ RadiusHeal * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 50, 200, 1, /*DURATION*/ DurationUntill, 12.0, 0.1, 1);
		spawnRing_Vectors(endPos, /*RANGE*/ RadiusHeal * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 50, 200, 1, /*DURATION*/ DurationUntill, 12.0, 0.1, 1, 1.0);	
	}
	Handle pack;
	CreateDataTimer(DurationUntill, Timer_AoeHealHolyLight, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, EntIndexToEntRef(client));
	WritePackFloat(pack, endPos[0]);
	WritePackFloat(pack, endPos[1]);
	WritePackFloat(pack, endPos[2]);
	WritePackFloat(pack, RadiusHeal);
	EmitSoundToAll(WAND_INIT_SOUND, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, endPos);
	EmitSoundToAll(WAND_INIT_SOUND, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, endPos);
}

static Action Timer_AoeHealHolyLight(Handle dashHud, DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	float VectorPos[3];
	VectorPos[0] = pack.ReadFloat();
	VectorPos[1] = pack.ReadFloat();
	VectorPos[2] = pack.ReadFloat();
	float RangeHeal = pack.ReadFloat();
	if(!IsValidClient(client))
		return Plugin_Stop;

	float VecAbove[3];
	VecAbove = VectorPos;
	VecAbove[2] += 1000.0;
	if(b_WasMagicFocus[client])
	{
		TE_SetupBeamPoints(VecAbove, VectorPos, gLaser1, 0, 0, 0, 0.25, 100.0, 100.0, 0, NORMAL_ZOMBIE_VOLUME, {255, 255, 50, 255}, 3);
		TE_SendToAll();
		spawnRing_Vectors(VectorPos, /*RANGE*/ 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 50, 200, 1, /*DURATION*/ 0.25, 12.0, 0.1, 1, RangeHeal * 2.0);
	}
	else
	{
		TE_SetupBeamPoints(VecAbove, VectorPos, gLaser1, 0, 0, 0, 0.25, 100.0, 100.0, 0, NORMAL_ZOMBIE_VOLUME, {50, 255, 50, 255}, 3);
		TE_SendToAll();
		spawnRing_Vectors(VectorPos, /*RANGE*/ 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 200, 1, /*DURATION*/ 0.25, 12.0, 0.1, 1, RangeHeal * 2.0);
	}

	HolyLightHealLogic(client, RangeHeal, VectorPos);
	return Plugin_Handled;
}


void HolyLightHealLogic(int client, float radius, float VectorPos[3])
{
	b_NpcIsTeamkiller[client] = true;
	b_AllowSelfTarget[client] = true;
	Explode_Logic_Custom(f_HealAmount[client] * 2.0,
	client,
	client,
	-1,
	VectorPos,
	radius,
	1.0,
	1.0,
	false,
	99,
	false,
	_,
	HolyLightAoeHealInternal);
	b_NpcIsTeamkiller[client] = false;
	b_AllowSelfTarget[client] = false;
}


void HolyLightAoeHealInternal(int entity, int victim, float damage, int weapon)
{
	if (GetTeam(victim) == GetTeam(entity) && !RPGCore_PlayerCanPVP(entity, victim))
	{
		HealEntityGlobal(entity, victim, f_HealAmount[entity] * 0.25, 1.0, 2.0, HEAL_NO_RULES);
		if(b_WasMagicFocus[entity])
		{
			HealEntityGlobal(entity, victim, f_HealAmount[entity] * 0.1, 1.0, 5.0, HEAL_NO_RULES);
			ApplyStatusEffect(entity, victim, "Ally Empowerment", 10.0);
		}
	}
}