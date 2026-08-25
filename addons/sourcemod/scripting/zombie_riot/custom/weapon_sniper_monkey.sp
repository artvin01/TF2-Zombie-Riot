#pragma semicolon 1
#pragma newdecls required

#define SUPPLYDROP_CRATE_SMALL_MODEL "models/props_island/mannco_case_small.mdl"
#define SUPPLYDROP_CRATE_SMALL_SOUND "ui/itemcrate_smash_rare.wav"
#define SUPPLYDROP_CRATE_SMALL_PARTICLE "crate_drop_debris"

#define SUPPLYDROP_CRATE_LARGE_MODEL "models/props_island/mannco_case_large.mdl"
#define SUPPLYDROP_CRATE_LARGE_SOUND "ui/itemcrate_smash_ultrarare_short.wav"
#define SUPPLYDROP_CRATE_LARGE_PARTICLE "mvm_loot_debris"

#define SUPPLYDROP_PARACHUTE_MODEL "models/workshop/weapons/c_models/c_paratooper_pack/c_paratrooper_parachute.mdl"

#define SUPPLYDROP_FLARE_SOUND "weapons/flare_detonator_launch.wav"
#define SUPPLYDROP_FLARE_PARTICLE_NORMAL "utaunt_celebrationtime_yellow_flare1"
#define SUPPLYDROP_FLARE_PARTICLE_RED "utaunt_celebrationtime_red_flare1"
#define SUPPLYDROP_FLARE_PARTICLE_BLU "utaunt_celebrationtime_blue_flare1"

#define SUPPLYDROP_MAX_PICKUPS 16
#define SUPPLYDROP_MAX_POWERUPS 2

static bool SmartBounce;
static int LastHitTarget;
static int PickupsDropped;
static int PowerupsDropped;

void SniperMonkey_ResetUses()
{
	PickupsDropped = 0;
	PowerupsDropped = 0;
}

void SniperMonkey_ClearAll()
{
	SmartBounce = false;
	SniperMonkey_ResetUses();
}

void SupplyDrop_MapStart()
{
	PrecacheModel(SUPPLYDROP_CRATE_SMALL_MODEL);
	PrecacheModel(SUPPLYDROP_CRATE_LARGE_MODEL);
	PrecacheModel(SUPPLYDROP_PARACHUTE_MODEL);
	
	PrecacheSound(SUPPLYDROP_CRATE_SMALL_SOUND);
	PrecacheSound(SUPPLYDROP_CRATE_LARGE_SOUND);
	PrecacheSound(SUPPLYDROP_FLARE_SOUND);
	
	PrecacheParticleSystem(SUPPLYDROP_CRATE_SMALL_PARTICLE);
	PrecacheParticleSystem(SUPPLYDROP_CRATE_LARGE_PARTICLE);
	PrecacheParticleSystem(SUPPLYDROP_FLARE_PARTICLE_NORMAL);
	PrecacheParticleSystem(SUPPLYDROP_FLARE_PARTICLE_RED);
	PrecacheParticleSystem(SUPPLYDROP_FLARE_PARTICLE_BLU);
}

float SniperMonkey_BouncingBullets(int victim, int &attacker, int &inflictor, float damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if(LastHitTarget == victim)
		return 0.0;
	
	if(LastHitTarget != victim && !(damagetype & DMG_BLAST))
	{
		if(SmartBounce)
		{

			float pos[3];
			
			int targets[3];
			int healths[3];
			int i;
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				i = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(i))
				{
					if(i != victim && !b_NpcHasDied[i] && GetTeam(i) != TFTeam_Red)
					{
						GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", pos);
						if(GetVectorDistance(pos, damagePosition, true) < 62500.0) 
						{
							int hp = GetEntProp(i, Prop_Data, "m_iHealth");
							if(healths[0] < hp)
							{
								healths[2] = healths[1];
								targets[2] = targets[1];
								
								healths[1] = healths[0];
								targets[1] = targets[0];
								
								healths[0] = hp;
								targets[0] = i;
							}
							else if(healths[1] < hp)
							{
								healths[2] = healths[1];
								targets[2] = targets[1];
								
								healths[1] = hp;
								targets[1] = i;
							}
							else if(healths[2] < hp)
							{
								healths[2] = hp;
								targets[2] = i;
							}
						}
					}
				}
			}
			
			for(i = 0; i < sizeof(targets); i++)
			{
				if(targets[i])
				{
					float DamageDealDo = damage * (0.875 - (0.2 * float(i)));
					if(DamageDealDo >= 0.0)
						SDKHooks_TakeDamage(targets[i], inflictor, attacker, DamageDealDo, damagetype|DMG_BLAST, weapon, damageForce, damagePosition);
				}
			}
			if(RaidbossIgnoreBuildingsLogic(1))
			{
				damage *= 1.5;
			}
		}
		else
		{
			int value = i_ExplosiveProjectileHexArray[attacker];
			i_ExplosiveProjectileHexArray[attacker] = 0;	// If DMG_TRUEDAMAGE doesn't block NPC_OnTakeDamage_Equipped_Weapon_Logic, adjust this
			LastHitTarget = victim;
			
			Explode_Logic_Custom(damage, attacker, attacker, weapon, damagePosition, 250.0, EXPLOSION_AOE_DAMAGE_FALLOFF, _, false, 4);
			if(RaidbossIgnoreBuildingsLogic(1))
			{
				damage *= 1.5;
			}			
			i_ExplosiveProjectileHexArray[attacker] = value;
			LastHitTarget = 0;
		}
	}
	return damage;
}

float SniperMonkey_MaimMoab(int victim, int &attacker, int &inflictor, float damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	float duration = 4.0;
	
	if(duration)
	{
		if((damagetype & DMG_BLAST))
			duration *= 1.5;
		
		if(f_ChargeTerroriserSniper[weapon] > 70.0)
		{
			ApplyStatusEffect(attacker, victim, "Maimed", duration);
		}
	}

	return SniperMonkey_BouncingBullets(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
}

float SniperMonkey_CrippleMoab(int victim, int &attacker, int &inflictor, float damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	float duration = 4.0;

	if(duration)
	{
		if((damagetype & DMG_BLAST))
			duration *= 1.5;
		
		if(f_ChargeTerroriserSniper[weapon] > 70.0)
		{
			ApplyStatusEffect(attacker, victim, "Maimed", duration);
			
			duration *= 1.3;
			ApplyStatusEffect(attacker, victim, "Cripple", duration);
		}
	}
	
	return SniperMonkey_BouncingBullets(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
}

public void Weapon_EnableSmartBouncing(int client)
{
	SmartBounce = true;
}

public void Weapon_EliteDefender(int client, int weapon, bool &result, int slot)
{
	float value = 0.3;
	if(!dieingstate[client] && !LastMann)
	{
		int maxhealth, health;
		for(int target=1; target<=MaxClients; target++)
		{
			if(IsClientInGame(target) && GetClientTeam(target)==2 && TeutonType[target] != TEUTON_WAITING)
			{
				if(IsPlayerAlive(target) && TeutonType[target] == TEUTON_NONE)
				{
					int maxhp = dieingstate[target] ? 1000 : SDKCall_GetMaxHealth(target);
					maxhealth += maxhp;
					
					int hp = GetClientHealth(target);
					if(hp > maxhp)
						hp = maxhp;
					
					health += hp;
				}
				else
				{
					maxhealth += 1000;
				}
			}
		}
		
		if(maxhealth)
		{
			value = float(health) / float(maxhealth);
			if(value < 0.2)
				value = 0.2;
		}
	}
	
	Attributes_Set(weapon, 396, value);
}

public void Weapon_SupplyDrop(int client, int weapon, bool &result, int slot)
{
	if (!Waves_Started())
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%T", "Supply Drop Wave Hasn't Started", client);
		return;
	}
	
	float cooldown = Ability_Check_Cooldown(client, slot);
	if(cooldown > 0.0)
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
		
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		return;
	}
	
	int pap = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
	int amount = 2;
	bool enhanced = false;
	
	if (pap >= 4)
	{
		amount = 3;
		enhanced = Weapon_SupplyDrop_CanSpawnPickupType(true); // if max amount of powerups was reached, use pickups instead
	}
	
	if (!enhanced && !Weapon_SupplyDrop_CanSpawnPickupType(enhanced))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%T", "Supply Drop Wave Limit Reached", client);
		return;
	}
	
	ArrayList teammates = new ArrayList();
	for (int other = 1; other <= MaxClients; other++)
	{
		if (IsValidClient(other) && !IsFakeClient(other) && IsEntityAlive(other, _, true) && GetTeam(client) == GetTeam(other) && client != other)
			teammates.Push(other);
	}
	
	// not enough teammates, also add this player
	if (teammates.Length < amount)
	{
		teammates.Push(client);
		amount = teammates.Length;
	}
	
	if (amount)
		teammates.Sort(Sort_Random, Sort_Integer);
	
	int pickupsSpawned, powerupsSpawned;
	for (int i = 0; i < amount; i++)
	{
		bool enhancedPickup;
		if (i == 0 && enhanced)
			enhancedPickup = true;
		
		if (!Weapon_SupplyDrop_CanSpawnPickupType(enhancedPickup))
			continue;
		
		int other = teammates.Get(i);
		float pos[3];
		WorldSpaceCenter(other, pos);
		
		if (enhancedPickup)
		{
			PowerupsDropped++;
			powerupsSpawned++;
		}
		else
		{
			PickupsDropped++;
			pickupsSpawned++;
		}
		
		Weapon_SupplyDrop_SpawnPickupHeadingToPos(client, pos, enhancedPickup);
	}
	
	delete teammates;
	
	char flareParticle[64];
	if (powerupsSpawned)
	{
		if (ZR_Get_Modifier() == SECONDARY_MERCS)
			flareParticle = SUPPLYDROP_FLARE_PARTICLE_BLU;
		else
			flareParticle = SUPPLYDROP_FLARE_PARTICLE_RED;
		
	}
	else
	{
		flareParticle = SUPPLYDROP_FLARE_PARTICLE_NORMAL;
	}
	
	if (flareParticle[0])
	{
		EmitSoundToAll(SUPPLYDROP_FLARE_SOUND, client, SNDCHAN_STATIC, .volume = 0.5, .pitch = 85, .soundtime = GetGameTime() - 0.12);
		
		float pos[3];
		WorldSpaceCenter(client, pos);
		ParticleEffectAt(pos, flareParticle, 2.5);
	}
	
	Ability_Apply_Cooldown(client, slot, 30.0);
}

static void Weapon_SupplyDrop_SpawnPickupHeadingToPos(int client, float initialPos[3], bool enhancedPickup)
{
	float mins[3], maxs[3], pos[3];
	mins = { -24.0, -24.0, 0.0 };
	maxs = { 24.0, 24.0, 24.0 };
	
	pos = initialPos;
	pos[2] += 1000.0;
	
	Handle trace;
	trace = TR_TraceHullFilterEx(initialPos, pos, mins, maxs, MASK_PLAYERSOLID_BRUSHONLY, TraceRayHitWorldOnly);
	TR_GetEndPosition(pos, trace);
	delete trace;
	
	pos[2] -= 16.0;
	
	float distance = GetVectorDistance(initialPos, pos);
	float speed = distance / GetRandomFloat(5.0, 7.0);
	if (speed < 30.0)
		speed = 30.0;
	
	CClotBody npc = view_as<CClotBody>(client); // steamhappy!
	int rocket = npc.FireParticleRocket(initialPos, 0.0, speed, 0.0, "", .FromBlueNpc = false, .Override_Spawn_Loc = true, .Override_VEC = pos);
	SetEntityCollisionGroup(rocket, COLLISION_GROUP_DEBRIS);
	SDKUnhook(rocket, SDKHook_StartTouch, Rocket_Particle_StartTouch);
	WandProjectile_ApplyFunctionToEntity(rocket, enhancedPickup ? Weapon_SupplyDrop_Enhanced_Rocket_StartTouch : Weapon_SupplyDrop_Rocket_StartTouch);
	
	int crate = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(crate))
	{
		b_ToggleTransparency[crate] = false;
		DispatchKeyValue(crate, "model", enhancedPickup ? SUPPLYDROP_CRATE_LARGE_MODEL : SUPPLYDROP_CRATE_SMALL_MODEL);
		DispatchKeyValue(crate, "StartDisabled", "false");
		DispatchKeyValue(crate, "Solid", "2");
		DispatchKeyValue(crate, "skin", "1");
		
		pos[2] += 20.0;
		TeleportEntity(crate, pos);
		DispatchSpawn(crate);
		SetEntProp(crate, Prop_Send, "m_usSolidFlags", 12); 
		SetEntityCollisionGroup(crate, 27);
		
		SetEntPropFloat(crate, Prop_Send, "m_flModelScale", 0.6);
		
		if (ZR_Get_Modifier() == SECONDARY_MERCS)
			SetEntityRenderColor(crate, 88, 133, 162);
		else
			SetEntityRenderColor(crate, 210, 100, 103);
		
		SetVariantString("!activator");
		AcceptEntityInput(crate, "SetParent", rocket);
	}
	
	int parachute = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(parachute))
	{
		b_ToggleTransparency[parachute] = false;
		DispatchKeyValue(parachute, "model", SUPPLYDROP_PARACHUTE_MODEL);
		DispatchKeyValue(parachute, "StartDisabled", "false");
		DispatchKeyValue(parachute, "Solid", "2");
		
		pos[0] += 16.0;
		pos[2] -= 50.0;
		TeleportEntity(parachute, pos);
		DispatchSpawn(parachute);
		SetVariantString("deploy_idle");
		AcceptEntityInput(parachute, "SetDefaultAnimation");
		SetVariantString("deploy");
		AcceptEntityInput(parachute, "SetAnimation");
		DispatchKeyValueFloat(parachute, "playbackrate", 0.5);
		SetEntProp(parachute, Prop_Send, "m_usSolidFlags", 12); 
		SetEntityCollisionGroup(parachute, 27);
		
		// 1/50 chance to spawn with a random color
		if (GetURandomInt() % 50)
			SetEntityRenderColor(parachute, 75, 75, 75);
		else
			SetEntityRenderColor(parachute, GetURandomInt() % 256, GetURandomInt() % 256, GetURandomInt() % 256);
		
		SetVariantString("!activator");
		AcceptEntityInput(parachute, "SetParent", crate);
	}
}

static bool Weapon_SupplyDrop_CanSpawnPickupType(bool enhancedPickup)
{
	if (enhancedPickup)
		return PowerupsDropped < SUPPLYDROP_MAX_POWERUPS;
	
	return PickupsDropped < SUPPLYDROP_MAX_PICKUPS;
}

static void Weapon_SupplyDrop_Rocket_StartTouch(int entity, int target)
{
	if (0 < target < MAXENTITIES)
		return;
	
	float pos[3];
	WorldSpaceCenter(entity, pos);
	RandomPickup_SpawnPickup(pos, 60.0);
	
	ParticleEffectAt(pos, SUPPLYDROP_CRATE_SMALL_PARTICLE);
	EmitSoundToAll(SUPPLYDROP_CRATE_SMALL_SOUND, entity, SNDCHAN_STATIC);
	RemoveEntity(entity);
}

static void Weapon_SupplyDrop_Enhanced_Rocket_StartTouch(int entity, int target)
{
	if (0 < target < MAXENTITIES)
		return;
	
	float pos[3];
	WorldSpaceCenter(entity, pos);
	
	bool follow = IsPointHazard(pos);
	switch (GetURandomInt() % 3)
	{
		case 0: SpawnMaxAmmo(entity, follow);
		case 1: SpawnHealth(entity, follow);
		case 2: SpawnMoney(entity, follow);
	}
	
	ParticleEffectAt(pos, SUPPLYDROP_CRATE_LARGE_PARTICLE);
	EmitSoundToAll(SUPPLYDROP_CRATE_LARGE_SOUND, entity, SNDCHAN_STATIC);
	RemoveEntity(entity);
}

/*
public void Weapon_SupplyDrop(int client, int weapon, bool &result, int slot)
{
	if(SuppliesUsed >= 2)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "Supply drop limit reached this wave");
		return;
	}
	else if(Ability_Check_Cooldown(client, slot) < 0.0)
	{
		float pos1[3], pos2[3];
		GetClientEyePosition(client, pos1);
		
		float distance;
		int target = -1;
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(entity) && !b_NpcHasDied[entity] && b_NpcForcepowerupspawn[entity] != 2 && GetTeam(entity) != TFTeam_Red)
			{
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos2);
				
				float dist = GetVectorDistance(pos1, pos2, true);
				if(distance < dist) 
				{
					target = entity;
					distance = dist;
				}
			}
		}
		
		if(target != -1)
		{
			b_NpcForcepowerupspawn[target] = 2;
			ClientCommand(client, "playgamesound ui/quest_status_tick_advanced_friend.wav");
			Ability_Apply_Cooldown(client, slot, 120.0);

			SuppliesUsed++;
		}
		else
		{
			ClientCommand(client, "playgamesound ui/medic_alert.wav");
			Ability_Apply_Cooldown(client, slot, 5.0);
		}
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
		
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

public void Weapon_SupplyDropElite(int client, int weapon, bool &result, int slot)
{
	if(SuppliesUsed >= 2)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "Supply drop limit reached this wave");
		return;
	}
	if(Ability_Check_Cooldown(client, slot) < 0.0)
	{
		int target = -1;
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(entity) && !b_NpcHasDied[entity] && b_NpcForcepowerupspawn[entity] != 2 && GetTeam(entity) != TFTeam_Red)
			{
				target = entity;
				break;
			}
		}
		
		if(target != -1)
		{
			b_NpcForcepowerupspawn[target] = 2;
			ClientCommand(client, "playgamesound ui/quest_status_tick_expert_friend.wav");
			Ability_Apply_Cooldown(client, slot, 90.0);
			SuppliesUsed++;
		}
		else
		{
			ClientCommand(client, "playgamesound ui/medic_alert.wav");
			Ability_Apply_Cooldown(client, slot, 5.0);
		}
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
		
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}
*/