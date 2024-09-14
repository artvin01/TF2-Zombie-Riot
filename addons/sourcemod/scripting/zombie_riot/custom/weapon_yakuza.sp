/*
	Stand + M1 = Light
	Duck + M1 = Grab (Pap 1)
	(Jump + M1) M1 -> M2 = Heavy
	//Better idea: Since melee hits take long, you'd press m1 and then quickly press m2 to ininitate a heavy hit.

	Duck + M2 = Block (Pap 3)
	Stand + M2 = Style Special (Pap 2)
	For dragonmode: Enemy must be attacking, if they are
	its a tigerdrop
	how it works:
	Activate ability, for 0.2 seconds it checks if you take damage, if you do, 
	negate all damage for animation duration, and do attack in the direction you aimed at

	(Jump + M2) M2 -> R = Heat Special (Pap 4)
	better idea:when pressing m2 and instantly pressing r, itll do this instead
	avoid jumping at all costs, its annoying to work with

	Ducking is fine.
	R = Switch Style
*/

enum
{
	Attack_Light,
	Attack_Heavy,
	Attack_Grab
}

enum
{
	Style_Brawler,	// Balanced
	Style_Beast,	// Slow, AOE
	Style_Rush,		// Fast, Evasion
	Style_Dragon,	// Best of all, but limited time use

	Style_MAX
}

static const char StyleName[][] =
{
	"Brawler",
	"Beast",
	"Rush",
	"Dragon"
};

static Handle WeaponTimer[MAXTF2PLAYERS];
static int WeaponRef[MAXTF2PLAYERS] = {-1, ...};
static int WeaponLevel[MAXTF2PLAYERS];
static int WeaponCharge[MAXTF2PLAYERS];
static int WeaponStyle[MAXTF2PLAYERS];
static int LastAttack[MAXTF2PLAYERS];
static int LastVictim[MAXTF2PLAYERS] = {-1, ...};
static float BlockNextFor[MAXTF2PLAYERS];
static int BlockStale[MAXTF2PLAYERS];
static float TigerDrop_Negate[MAXTF2PLAYERS];

void Yakuza_MapStart()
{
	Zero(WeaponCharge);
	Zero(WeaponStyle);
	Zero(BlockNextFor);
	Zero(BlockStale);
	Zero(TigerDrop_Negate);
}

bool Yakuza_HasCharge(int client)
{
	return WeaponTimer[client] != null && WeaponCharge[client] < MaxCharge(client);
}

void Yakuza_ChargeReduced(int client, float time)
{
	if(WeaponTimer[client] != null)
		WeaponCharge[client] += RoundFloat(time * 5.0);
}

void Yakuza_EnemiesHit(int client, int &enemies_hit_aoe)
{
	if(LastAttack[client] != Attack_Grab && WeaponStyle[client] == Style_Beast)
		enemies_hit_aoe += 2;
}

static int AddCharge(int client, int amount)
{
	if(amount)
	{
		WeaponCharge[client] += amount;

		if(WeaponCharge[client] < 0)
		{
			WeaponCharge[client] = 0;
		}
		else
		{
			int maxcharge = MaxCharge(client);
			if(WeaponCharge[client] > maxcharge)
				WeaponCharge[client] = 0;
		}
	}

	TriggerTimer(WeaponTimer[client], true);
}

static void UpdateStyle(int client)
{
	int weapon = EntRefToEntIndex(WeaponRef[client]);
	if(weapon != -1)
	{
		float value;

		switch(WeaponStyle[client])
		{
			case Style_Brawler:
				value = 1;
			
			case Style_Beast:
				value = 2;
			
			case Style_Rush:
				value = 6;

			case Style_Dragon:
				value = 6; //idk which, needs to be red
		}

		Attributes_Set(weapon, 2025, 3.0);
		Attributes_Set(weapon, 2014, value);
		Attributes_Set(weapon, 2013, 2007.0);
		ViewChange_Update(client, false);
	}
}

static int MaxCharge(int client)
{
	return 100 + WeaponLevel[client] * 20;
}

static int PlayerState(int client)
{
	if(!(GetEntityFlags(client) & FL_ONGROUND))
		return 1;
	
	if(GetClientButtons(client) & IN_DUCK)
		return 2;
	
	return 0;
}

void Yakuza_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_YAKUZA)
	{
		// Weapon Setup
		WeaponLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));
		WeaponRef[client] = EntIndexToEntRef(weapon);

		delete WeaponTimer[client];
		WeaponTimer[client] = CreateTimer(1.0, WeaponTimerFunc, client, TIMER_REPEAT);

		UpdateStyle(client);
	}
}

static Action WeaponTimerFunc(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		int weapon = EntRefToEntIndex(WeaponRef[client]);
		if(weapon != -1)
		{
			if(weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
			{
				PrintHintText(client, "%s - HEAT %d%%", StyleName[WeaponStyle[client]], WeaponCharge[client]);
				StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			}
			else
			{
				// Decay HEAT while not equipped
				WeaponCharge[client] -= 5;
				if(WeaponCharge[client] < 0)
					WeaponCharge[client] = 0;
			}

			return Plugin_Continue;
		}
	}

	WeaponTimer[client] = null;
	return Plugin_Stop;
}

public void Weapon_Yakuza_R(int client, int weapon, bool crit, int slot)
{
	// Switch styles on R

	WeaponStyle[client]++;
	if(WeaponStyle[client] >= Style_MAX)
		WeaponStyle[client] = 0;
	
	TriggerTimer(WeaponTimer[client], true);
	UpdateStyle(client);
}

public void Weapon_Yakuza_M1(int client, int weapon, bool crit, int slot)
{
	switch(PlayerState(client))
	{
		case 0:
			Yakuza_LightAttack(client, weapon);
		
		case 1:
			Yakuza_HeavyAttack(client, weapon);
		
		case 2:
			Yakuza_GrabAttack(client, weapon, slot);
	}
}

public void Weapon_Yakuza_M2(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0)
		return;
	
	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	switch(PlayerState(client))
	{
		case 0:
			Yakuza_StyleSpecial(client, weapon, slot);
		
		case 1:
			Yakuza_HeatSpecial(client, weapon, slot);
		
		case 2:
			Yakuza_Block(client, weapon, slot);
	}
}

static void Yakuza_LightAttack(int client, int weapon)
{
	LastAttack[client] = Attack_Light;

	float gameTime = GetGameTime();
	float cooldown = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack") - gameTime;

	switch(WeaponStyle[client])
	{
		case Style_Beast:
			cooldown *= 2.0;
		
		case Style_Rush:
			cooldown *= 0.67;
	}

	Ability_Apply_Cooldown(client, 1, cooldown);
	Ability_Apply_Cooldown(client, 2, cooldown);

	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", gameTime + cooldown);
}

static void Yakuza_HeavyAttack(int client, int weapon)
{
	LastAttack[client] = Attack_Heavy;

	float gameTime = GetGameTime();
	float cooldown = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack") - gameTime;

	switch(WeaponStyle[client])
	{
		case Style_Brawler:
			cooldown *= 2.5;
		
		case Style_Beast:
			cooldown *= 5.0;
		
		case Style_Rush:
			cooldown *= 2.0;
	}

	Ability_Apply_Cooldown(client, 1, cooldown);
	Ability_Apply_Cooldown(client, 2, cooldown);

	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", gameTime + cooldown);
}

static void Yakuza_GrabAttack(int client, int weapon, int slot)
{
	if(dieingstate[client] != 0 || WeaponLevel[client] < 1)
	{
		Yakuza_HeavyAttack(client, weapon);
		return;
	}

	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		
		Yakuza_HeavyAttack(client, weapon);
		return;
	}

	LastAttack[client] = Attack_Grab;

	float cooldown = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack") - GetGameTime();

	Ability_Apply_Cooldown(client, 1, cooldown * 5.0);
	Ability_Apply_Cooldown(client, 2, cooldown);
}

static void Yakuza_StyleSpecial(int client, int weapon, int slot)
{
	if(CvarInfiniteCash.BoolValue && WeaponCharge[client] < 25)
		WeaponCharge[client] = 25;
	
	if(WeaponCharge[client] < 25)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "Require 25%% HEAT for this action");
	}
	else
	{
		Rogue_OnAbilityUse(weapon);
		
	}
}

static void Yakuza_HeatSpecial(int client, int weapon, int slot)
{
	if(WeaponLevel[client] < 4)
	{
		Yakuza_StyleSpecial(client, weapon);
		return;
	}

	if(CvarInfiniteCash.BoolValue && WeaponCharge[client] < 100)
		WeaponCharge[client] = 100;
	
	if(WeaponCharge[client] < 100)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "Require 100%% HEAT for this action");
	}
	else
	{
		Rogue_OnAbilityUse(weapon);
		AddCharge(client, -999);
	}
}

static void Yakuza_Block(int client, int weapon, int slot)
{
	if(WeaponLevel[client] < 3)
	{
		Yakuza_StyleSpecial(client, weapon);
		return;
	}

	float gameTime = GetGameTime();
	float cooldown = 2.0;
	float duration = 0.5;

	switch(WeaponStyle[client])
	{
		case Style_Beast:
		{
			cooldown = 2.5;
			duration = 0.8;
		}
		case Style_Rush:
		{
			cooldown = 1.5;
			duration = 0.4;
		}
		case Style_Dragon:
		{
			cooldown = 1.5;
			duration = 0.65;
		}
	}

	Ability_Apply_Cooldown(client, 1, duration);
	Ability_Apply_Cooldown(client, 2, cooldown * 3.0 * (1.0 + (BlockStale[client] * 0.05)));

	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", gameTime + duration);

	BlockStale[client] += 10;	// Every block stales by x1.5

	if(RaidbossIgnoreBuildingsLogic(1))
	{
		ApplyTempAttrib(weapon, 206, 0.25, duration);
	}
	else
	{
		BlockNextFor[client] = gameTime + duration;
	}
}

void Yakuza_NPCTakeDamage(int victim, int attacker, float &damage, int weapon, int damagetype)
{
	BlockStale[attacker]--;
	LastVictim[attacker] = EntIndexToEntRef(victim);

	switch(LastAttack[victim])
	{
		case Attack_Light:
		{
			switch(WeaponStyle[attacker])
			{
				case Style_Beast:
					damage *= 1.25;
				
				case Style_Rush:
					damage *= 0.8;
				
				case Style_Dragon:
					damage *= 1.3;
			}
		}
		case Attack_Heavy:
		{
			switch(WeaponStyle[attacker])
			{
				case Style_Brawler:
					damage *= 3.5;
				
				case Style_Beast:
					damage *= 5.0;
				
				case Style_Rush:
					damage *= 2.75;

				case Style_Dragon:
					damage *= 6.0;
			}
		}
		case Attack_Grab:
		{
			damage = 1.0;

			float duration = 1.0;
			switch(WeaponStyle[attacker])
			{
				case Style_Beast:
					duration = 1.6;
				
				case Style_Rush:
					duration = 0.8;

				case Style_Dragon:
					damage *= 1.5;
			}

			FreezeNpcInTime(victim, duration);
		}
	}

	// TODO: Adjust based on waves
	AddCharge(client, RoundToCeil(damage * 0.001));

	// +25% damage at 100% HEAT
	damage *= 1.0 + (WeaponCharge[attacker] * 0.0025);
}

void Yakuza_SelfTakeDamage(int victim, int &attacker, float &damage, int damagetype)
{
	//however, it cannot negate true damage, that would be dumb
	if(TigerDrop_Negate[victim] > GetGameTime())
	{
		damage = 0.0;
		return;
	}
	if((damagetype & DMG_SLASH) || attacker <= MaxClients)
		return;
	
	//You actually gain alot of heat with brawler mode when blocking!
	//todo: add logic during brawlermode and Dragon mode
	//dragon mode has limited heatgain on block in kiwami, but with hnow ZR works and how dragonmode works here, it sohuldnt be limited.
	
	//With beastmode, you cant actually block youre just immune to knockback, but that in ZR sucks, so it should be the best to block with.
	if((damagetype & DMG_CLUB) && BlockNextFor[victim] > GetGameTime())
	{
		damage = 0.0;
		return;
	}

	AddCharge(client, RoundToCeil(damage * -0.01));
}

static int SetCameraEffect(int client, const char[] animation, float duration)
{
	float vAngles[3];
	float vOrigin[3];
	
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	float vecSwingForward[3];
	float vecSwingEnd[3];
	GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);
	vecSwingEnd[0] = vOrigin[0] + vecSwingForward[0] * LEPER_MAXRANGE_VIEW_EFFECT * 0.25;
	vecSwingEnd[1] = vOrigin[1] + vecSwingForward[1] * LEPER_MAXRANGE_VIEW_EFFECT * 0.25;
	vecSwingEnd[2] = vOrigin[2] + vecSwingForward[2] * LEPER_MAXRANGE_VIEW_EFFECT * 0.25;
	vecSwingEnd[2] -= 30.0;
	
	//always from upwards somewhere.
	vAngles[0] = GetRandomFloat(-10.0 , -5.0);
	switch(GetRandomInt(0,1))
	{
		case 0:
		{
			vAngles[1] += GetRandomFloat(80.0 , 90.0);
		}
		case 1:
		{
			vAngles[1] -= GetRandomFloat(80.0 , 90.0);
		}
	}

	float LeperViewAnglesMins[3];
	float LeperViewAnglesMaxs[3];
	LeperViewAnglesMins = view_as<float>({-LEPER_BOUNDS_VIEW_EFFECT, -LEPER_BOUNDS_VIEW_EFFECT, -LEPER_BOUNDS_VIEW_EFFECT});
	LeperViewAnglesMaxs = view_as<float>({LEPER_BOUNDS_VIEW_EFFECT, LEPER_BOUNDS_VIEW_EFFECT, LEPER_BOUNDS_VIEW_EFFECT});

	GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);

	vecSwingEnd[0] = vOrigin[0] + vecSwingForward[0] * LEPER_MAXRANGE_VIEW_EFFECT;
	vecSwingEnd[1] = vOrigin[1] + vecSwingForward[1] * LEPER_MAXRANGE_VIEW_EFFECT;
	vecSwingEnd[2] = vOrigin[2] + vecSwingForward[2] * LEPER_MAXRANGE_VIEW_EFFECT;
	Handle trace = TR_TraceHullFilterEx( vOrigin, vecSwingEnd, LeperViewAnglesMins, LeperViewAnglesMaxs, ( MASK_SOLID ), TraceRayHitWorldOnly, client );
	if ( TR_GetFraction(trace) < 1.0)
	{
		//we hit nothing something, uh oh!
		TR_GetEndPosition(vecSwingEnd, trace);
	}
	GetClientEyeAngles(client, vAngles);
	vAngles[0] = 0.0;
	GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);

	delete trace;

	float vecSwingEndMiddle[3];
	vecSwingEndMiddle[0] = vOrigin[0] + vecSwingForward[0] * LEPER_MAXRANGE_VIEW_EFFECT;
	vecSwingEndMiddle[1] = vOrigin[1] + vecSwingForward[1] * LEPER_MAXRANGE_VIEW_EFFECT;
	vecSwingEndMiddle[2] = vOrigin[2] + vecSwingForward[2] * LEPER_MAXRANGE_VIEW_EFFECT;
	trace = TR_TraceHullFilterEx( vOrigin, vecSwingEndMiddle, LeperViewAnglesMins, LeperViewAnglesMaxs, ( MASK_SOLID ), TraceRayHitWorldOnly, client );
	if ( TR_GetFraction(trace) < 1.0)
	{
		//we hit nothing something, uh oh!
		TR_GetEndPosition(vecSwingEndMiddle, trace);
	}
	delete trace;
	float vAngleCamera[3];
	float MiddleAngle[3];
	MiddleAngle[0] = (vecSwingEndMiddle[0] + vOrigin[0]) / 2.0;
	MiddleAngle[1] = (vecSwingEndMiddle[1] + vOrigin[1]) / 2.0;
	MiddleAngle[2] = (vecSwingEndMiddle[2] + vOrigin[2]) / 2.0;
	
//	int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
//	TE_SetupBeamPoints(MiddleAngle, vecSwingEnd, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 5.0, 5.0, 5.0, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
//	TE_SendToAll();
	int viewcontrol = CreateEntityByName("prop_dynamic");
	if (IsValidEntity(viewcontrol))
	{
		GetVectorAnglesTwoPoints(vecSwingEnd, MiddleAngle, vAngleCamera);
		SetEntityModel(viewcontrol, "models/empty.mdl");
		DispatchKeyValueVector(viewcontrol, "origin", vecSwingEnd);
		DispatchKeyValueVector(viewcontrol, "angles", vAngleCamera);
		DispatchSpawn(viewcontrol);	
		SetClientViewEntity(client, viewcontrol);
	}
	float vabsAngles[3];
	float vabsOrigin[3];
	GetClientAbsOrigin(client, vabsOrigin);
	GetClientEyeAngles(client, vabsAngles);
	vabsAngles[0] = 0.0;
	SetVariantInt(0);
	AcceptEntityInput(client, "SetForcedTauntCam");	
	
	int spawn_index = NPC_CreateByName("npc_allied_leper_visualiser", client, vabsOrigin, vabsAngles, GetTeam(client), animation);
	
	DataPack pack;
	CreateDataTimer(duration, Leper_SuperHitInitital_After, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(client);
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(EntIndexToEntRef(viewcontrol));
	pack.WriteCell(EntIndexToEntRef(spawn_index));
	
	TF2_AddCondition(client, TFCond_FreezeInput, -1.0);

	SetEntityMoveType(client, MOVETYPE_NONE);
	SetEntProp(client, Prop_Send, "m_bIsPlayerSimulated", 0);
	SetEntProp(client, Prop_Send, "m_bSimulatedEveryTick", 0);
//	SetEntProp(client, Prop_Send, "m_bAnimatedEveryTick", 0);
	SetEntProp(client, Prop_Send, "m_bClientSideAnimation", 0);
	SetEntProp(client, Prop_Send, "m_bClientSideFrameReset", 1);
	SetEntProp(client, Prop_Send, "m_bForceLocalPlayerDraw", 1);
	int entity, i;
	while(TF2U_GetWearable(client, entity, i))
	{
		SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") | EF_NODRAW);
	}

	return spawn_index;
}