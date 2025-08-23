#pragma semicolon 1
#pragma newdecls required

#define PARTICLE_JARATE		"peejar_impact_small"
#define PARTICLE_MADMILK	"peejar_impact_milk"
#define PARTICLE_SHRINK		"utaunt_arcane_green_parent"//"utaunt_merasmus"
#define SOUND_JAREXPLODE	"weapons/jar_explode.wav"
#define SOUND_TRANSFORM1	"ambient/halloween/thunder_04.wav"
#define SOUND_TRANSFORM2	"ambient/halloween/thunder_01.wav"
#define SOUND_SHRINK		"items/powerup_pickup_plague_infected.wav"

static float TonicBuff[MAXPLAYERS];
static float TonicBuff_CD[MAXPLAYERS];


static Handle h_PotionBuff[MAXPLAYERS+1] = {null, ...};

public void Enable_BuffPotion(int client, int weapon) 
{
	if (h_PotionBuff[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BUFFPOTION) 
		{
			//Is the weapon it again?
			//Yes?
			delete h_PotionBuff[client];
			h_PotionBuff[client] = null;
			DataPack pack;
			h_PotionBuff[client] = CreateDataTimer(0.2, Timer_Management_BuffPotion, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BUFFPOTION)   //9 Is for Passanger
	{
		DataPack pack;
		h_PotionBuff[client] = CreateDataTimer(0.2, Timer_Management_BuffPotion, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

#define SMELLY_SNIPPER_RANGE_BUFFICON 1000.0

public Action Timer_Management_BuffPotion(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_PotionBuff[client] = null;
		return Plugin_Stop;
	}	
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding != weapon) //Only show if the weapon is actually in your hand right now.
		return Plugin_Continue;


	float posme[3];
	float pos2[3];

	float ang[3];
	GetClientEyeAngles(client, ang);

	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", posme);
	for(int clientloop = 1; clientloop <= MaxClients; clientloop++)
	{
		if(!IsClientInGame(clientloop))
			continue;

		if(!IsPlayerAlive(clientloop))
			continue;

		if(client == clientloop)
			continue;

		if(TeutonType[client] != TEUTON_NONE) //annoyin
			continue;

		GetEntPropVector(clientloop, Prop_Data, "m_vecAbsOrigin", pos2);
		if(GetVectorDistance(posme, pos2, true) > (SMELLY_SNIPPER_RANGE_BUFFICON * SMELLY_SNIPPER_RANGE_BUFFICON))
			continue;

		bool HasAnyBuff = false;
		if(HasSpecificBuff(clientloop, "Mystery Beer"))
			HasAnyBuff = true;

		if(HasSpecificBuff(clientloop, "Mystery Brew"))
			HasAnyBuff = true;

		static float PosOffset[3];
		PosOffset = pos2;
		pos2[2] += 90.0;
		PosOffset[2] += 110.0;

		if(HasAnyBuff)
		{
			TE_SetupBeamPoints(pos2, PosOffset, Shared_BEAM_Laser, Shared_BEAM_Glow, 0, 0, 0.21, 10.0, 2.0, 0, 0.0, {0, 255, 0, 255}, 0);
			TE_SendToClient(client);
			continue;
		}
		

	//	TE_SetupBeamLaser(client, clientloop, Shared_BEAM_Laser, Shared_BEAM_Glow, 0, 0, 1.0, 
	//			4.0, 2.0, 0, 2.0, {175, 200, 100, 255}, 0);
	//	TE_SendToClient(client);

		TE_SetupBeamPoints(pos2, PosOffset, Shared_BEAM_Laser, Shared_BEAM_Glow, 0, 0, 0.21, 2.0, 2.0, 0, 0.0, {175, 200, 100, 255}, 0);
		TE_SendToClient(client);
		static float PosOffset1[3];
		PosOffset1 = PosOffset;
		PosOffset1[2] -= 13.0;
		GetBeamDrawStartPoint_Stock(client, PosOffset1, {0.0,5.0,0.0}, ang);
		TE_SetupBeamPoints(pos2, PosOffset1, Shared_BEAM_Laser, Shared_BEAM_Glow, 0, 0, 0.21, 2.0, 2.0, 0, 0.0, {175, 200, 100, 255}, 0);
		TE_SendToClient(client);
		static float PosOffset2[3];
		PosOffset2 = PosOffset;
		PosOffset2[2] -= 13.0;
		GetBeamDrawStartPoint_Stock(client, PosOffset2, {0.0,-5.0,0.0}, ang);
		TE_SetupBeamPoints(pos2, PosOffset2, Shared_BEAM_Laser, Shared_BEAM_Glow, 0, 0, 0.2, 2.0, 2.0, 0, 0.0, {175, 200, 100, 255}, 0);
		TE_SendToClient(client);

	}
	return Plugin_Continue;
}

void Wand_Potions_Precache()
{
	PrecacheSound(SOUND_JAREXPLODE);
	PrecacheSound(SOUND_TRANSFORM1);
	PrecacheSound(SOUND_TRANSFORM2);
	PrecacheSound(SOUND_SHRINK);

	Zero(TonicBuff_CD);
	Zero(TonicBuff);
}

public void Weapon_Wand_PotionBasicM1(int client, int weapon, bool &crit, int slot)
{
	PotionM1(client, weapon, Weapon_Wand_PotionBasicTouch);
}

public void Weapon_Wand_PotionBasicM2(int client, int weapon, bool &crit, int slot)
{
	PotionM2(client, weapon, slot, 3.0, Weapon_Wand_PotionBasicTouch);
}

public void Weapon_Wand_PotionBuffM2(int client, int weapon, bool &crit, int slot)
{
	PotionM2(client, weapon, slot, 4.5, Weapon_Wand_PotionBuffTouch, 150);
}

public void Weapon_Wand_PotionBuffAllM2(int client, int weapon, bool &crit, int slot)
{
	PotionM2(client, weapon, slot, 6.0, Weapon_Wand_PotionBuffAllTouch, 200);
}

public void Weapon_Wand_PotionBuffPermaM2(int client, int weapon, bool &crit, int slot)
{
	PotionM2(client, weapon, slot, 6.0, Weapon_Wand_PotionBuffPermaTouch, 300);
}

public void Weapon_Wand_PotionUnstableM1(int client, int weapon, bool &crit, int slot)
{
	PotionM1(client, weapon, Weapon_Wand_PotionUnstableTouch);
}

public void Weapon_Wand_PotionUnstableM2(int client, int weapon, bool &crit, int slot)
{
	PotionM2(client, weapon, slot, 3.0, Weapon_Wand_PotionUnstableTouch);
}

public void Weapon_Wand_PotionLeadM1(int client, int weapon, bool &crit, int slot)
{
	PotionM1(client, weapon, Weapon_Wand_PotionLeadTouch);
}

public void Weapon_Wand_PotionLeadM2(int client, int weapon, bool &crit, int slot)
{
	PotionM2(client, weapon, slot, 3.0, Weapon_Wand_PotionLeadTouch);
}

public void Weapon_Wand_PotionGoldM1(int client, int weapon, bool &crit, int slot)
{
	PotionM1(client, weapon, Weapon_Wand_PotionGoldTouch);
}

public void Weapon_Wand_PotionGoldM2(int client, int weapon, bool &crit, int slot)
{
	PotionM2(client, weapon, slot, 3.0, Weapon_Wand_PotionGoldTouch);
}

public void Weapon_Wand_PotionShrinkM2(int client, int weapon, bool &crit, int slot)
{
	PotionM2(client, weapon, slot, 20.0, Weapon_Wand_PotionShrinkTouch);
}

static void PotionM2(int client, int weapon, int slot, float cooldown, SDKHookCB touch, int extra = 0)
{
	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	if(PotionM1(client, weapon, touch, extra))
	{
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, cooldown);
	}
}

static bool PotionM1(int client, int weapon, SDKHookCB touch, int extra = 0)
{
	int mana_cost = extra;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	
	if(Current_Mana[client] < mana_cost)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.5);
		return false;
	}

	SDKhooks_SetManaRegenDelayTime(client, 1.0);

	
	Mana_Hud_Delay[client] = 0.0;
	Current_Mana[client] -= mana_cost;
	delay_hud[client] = 0.0;

	float damage = 32.5;
	damage *= Attributes_Get(weapon, 410, 1.0);
	
	float speed = 1000.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	
	float ang[3];
	GetClientEyeAngles(client, ang);
	ang[0] -= 10.0;

	int entity = Wand_Projectile_Spawn(client, speed, 20.0, damage, 0, weapon, NULL_STRING, ang, true);
	if(entity > MaxClients)
	{
		SetEntityGravity(entity, 1.5);
		SetEntityMoveType(entity, MOVETYPE_FLYGRAVITY);
		
		char buffer[256];
		ModelIndexToString(i_WeaponModelIndexOverride[weapon], buffer, sizeof(buffer));
		int ModelApply = ApplyCustomModelToWandProjectile(entity, buffer, 1.0, "");
		SetEntProp(ModelApply, Prop_Send, "m_nBody", i_WeaponBodygroup[weapon]);

		SDKHook(entity, SDKHook_StartTouchPost, touch);
	}

	entity = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	if(entity != -1)
		RequestFrame(Weapon_Wand_PotionAnim, EntIndexToEntRef(entity));
	

	return true;
}

public void Weapon_Wand_PotionAnim(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity != -1)
		SetEntProp(entity, Prop_Send, "m_nSequence", 18);
}

public void Weapon_Wand_PotionBasicTouch(int entity, int target)
{
	if(target)
	{
		if(target <= MaxClients)
			return;
		
		if(GetTeam(target) == 2)
			return;
	}

	SDKUnhook(entity, SDKHook_StartTouchPost, Weapon_Wand_PotionBasicTouch);

	float pos1[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
	ParticleEffectAt(pos1, PARTICLE_JARATE, 2.0);
	EmitSoundToAll(SOUND_JAREXPLODE, entity, _, _, _, _, _, _, pos1);
	
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

	i_ExplosiveProjectileHexArray[entity] = EP_DEALS_PLASMA_DAMAGE;
	Explode_Logic_Custom(f_WandDamage[entity],
	owner,
	entity,
	weapon,
	_,
	_,
	_,
	_,
	_,
	6,
	_,
	_,
	WandPotion_DoTrueDamageBleed,
	_,
	_);

	RemoveEntity(entity);
}

public void WandPotion_DoTrueDamageBleed(int entity, int enemy, float damage, int weapon)
{
	if (!IsValidEntity(enemy))
		return;

	int owner = EntRefToEntIndex(i_WandOwner[entity]);

	if (!IsValidEntity(owner))
		return;

	StartBleedingTimer(enemy, owner, f_WandDamage[entity] / 32.0, 5, weapon, DMG_BULLET);
}


public void Weapon_Wand_PotionBuffTouch(int entity, int target)
{
	int owner = EntRefToEntIndex(i_WandOwner[entity]);

	if(target)
	{
		if(target == owner || GetTeam(target) != 2)
			return;
	}

	SDKUnhook(entity, SDKHook_StartTouchPost, Weapon_Wand_PotionBuffTouch);

	float pos1[3], pos2[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
	ParticleEffectAt(pos1, PARTICLE_MADMILK, 2.0);
	EmitSoundToAll(SOUND_JAREXPLODE, entity, _, _, _, _, _, _, pos1);
	
	if(target > 0 && target <= MaxClients)
	{
		i_ExtraPlayerPoints[owner] += 10;
		
		ApplyStatusEffect(owner, target, "Mystery Beer", 11.0);
	}
	else
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && IsPlayerAlive(client))
			{
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos2);
				if(GetVectorDistance(pos1, pos2, true) < (EXPLOSION_RADIUS * EXPLOSION_RADIUS))
				{
					i_ExtraPlayerPoints[owner] += 10;

					ApplyStatusEffect(client, client, "Mystery Beer", 11.0);
					break;
				}
			}
		}
		int a, entity1;
		while((entity1 = FindEntityByNPC(a)) != -1)
		{
			if(GetTeam(entity1) == GetTeam(owner))
			{
				GetEntPropVector(entity1, Prop_Data, "m_vecAbsOrigin", pos2);
				if(GetVectorDistance(pos1, pos2, true) < (EXPLOSION_RADIUS * EXPLOSION_RADIUS))
				{
					i_ExtraPlayerPoints[owner] += 10;

					ApplyStatusEffect(entity1, entity1, "Mystery Beer",11.0);
					break;
				}
			}
		}
	}
	
	RemoveEntity(entity);
}

public void Weapon_Wand_PotionBuffAllTouch(int entity, int target)
{
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	
	if(target)
	{
		if(target == owner || GetTeam(target) != 2)
			return;
	}

	SDKUnhook(entity, SDKHook_StartTouchPost, Weapon_Wand_PotionBuffAllTouch);

	float pos1[3], pos2[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
	ParticleEffectAt(pos1, PARTICLE_MADMILK, 2.0);
	EmitSoundToAll(SOUND_JAREXPLODE, entity, _, _, _, _, _, _, pos1);
	
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < (EXPLOSION_RADIUS * EXPLOSION_RADIUS))
			{
				i_ExtraPlayerPoints[owner] += 12;
				ApplyStatusEffect(client, client, "Mystery Beer", 15.0);
			}
		}
	}
	int a, entity1;
	while((entity1 = FindEntityByNPC(a)) != -1)
	{
		if(GetTeam(entity1) == GetTeam(owner))
		{
			GetEntPropVector(entity1, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < (EXPLOSION_RADIUS * EXPLOSION_RADIUS))
			{
				i_ExtraPlayerPoints[owner] += 20;

				ApplyStatusEffect(entity1, entity1, "Mystery Beer", 15.0);
			}
		}
	}


	RemoveEntity(entity);
}

public void Weapon_Wand_PotionBuffPermaTouch(int entity, int target)
{
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	
	if(target)
	{
		if(target == owner || GetTeam(target) != 2)
			return;
	}

	SDKUnhook(entity, SDKHook_StartTouchPost, Weapon_Wand_PotionBuffPermaTouch);

	float pos1[3], pos2[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
	ParticleEffectAt(pos1, PARTICLE_MADMILK, 2.0);
	EmitSoundToAll(SOUND_JAREXPLODE, entity, _, _, _, _, _, _, pos1);
	
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < (EXPLOSION_RADIUS * EXPLOSION_RADIUS))
			{
				int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon != -1)
				{
					i_ExtraPlayerPoints[owner] += 20;

					ApplyStatusEffect(client, client, "Mystery Brew", 300.0);
				}
			}
		}
	}
	int a, entity1;
	while((entity1 = FindEntityByNPC(a)) != -1)
	{
		if(GetTeam(entity1) == GetTeam(owner))
		{
			GetEntPropVector(entity1, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < (EXPLOSION_RADIUS * EXPLOSION_RADIUS))
			{
				i_ExtraPlayerPoints[owner] += 20;

				ApplyStatusEffect(entity1, entity1, "Mystery Brew", 300.0);
			}
		}
	}

	RemoveEntity(entity);
}


public void Weapon_Wand_PotionUnstableTouch(int entity, int target)
{
	if(target)
	{
		if(target <= MaxClients)
			return;
		
		if(GetTeam(target) == 2)
			return;
	}

	SDKUnhook(entity, SDKHook_StartTouchPost, Weapon_Wand_PotionUnstableTouch);

	float pos1[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
	ParticleEffectAt(pos1, PARTICLE_JARATE, 2.0);
	EmitSoundToAll(SOUND_JAREXPLODE, entity, _, _, _, _, _, _, pos1);
	
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	
	i_ExplosiveProjectileHexArray[entity] = EP_DEALS_PLASMA_DAMAGE;
	Explode_Logic_Custom(f_WandDamage[entity],
	owner,
	entity,
	weapon,
	_,
	_,
	_,
	_,
	_,
	6,
	_,
	_,
	WandPotion_UnstableTouchDo,
	_,
	_);

	RemoveEntity(entity);
}

public void WandPotion_UnstableTouchDo(int entity, int enemy, float damage_Dontuse, int weapon)
{
	if (!IsValidEntity(enemy))
		return;

	int owner = EntRefToEntIndex(i_WandOwner[entity]);

	if (!IsValidEntity(owner))
		return;

	char npc_classname[60];
	float damage = f_WandDamage[entity];
	
	StartBleedingTimer(enemy, owner, damage / 16.0, 8, weapon, DMG_BULLET);
	NPC_GetPluginById(i_NpcInternalId[enemy], npc_classname, sizeof(npc_classname));
	if(StrEqual(npc_classname, "npc_bloon"))
	{
		if(view_as<Bloon>(enemy).m_bFortified && (view_as<Bloon>(enemy).m_iType == Bloon_Ceramic || view_as<Bloon>(enemy).m_iType == Bloon_Lead))
		{
			view_as<Bloon>(enemy).m_bFortified = false;
			float ratio = Bloon_HPRatio(false, view_as<Bloon>(enemy).m_iOriginalType) / Bloon_HPRatio(true, view_as<Bloon>(enemy).m_iOriginalType);

			int maxhealth = GetEntProp(enemy, Prop_Data, "m_iMaxHealth");
			SetEntProp(enemy, Prop_Data, "m_iMaxHealth", RoundFloat(maxhealth * ratio));

			int health = GetEntProp(enemy, Prop_Data, "m_iHealth");
			
			int bonus = health - RoundFloat(health * ratio);
			SDKHooks_TakeDamage(enemy, owner, entity, float(bonus), DMG_BULLET, weapon);
		}
	}
	else
	{
		if(!b_NpcIsInvulnerable[enemy])
		{
			f_BombEntityWeaponDamageApplied[enemy][owner] += damage / 12.0;
			i_HowManyBombsOnThisEntity[enemy][owner] += 1;
			i_HowManyBombsHud[enemy] += 1;
			Apply_Particle_Teroriser_Indicator(enemy);
		}
	}
}

public void Weapon_Wand_PotionTransM2(int client, int weapon, bool &crit, int slot)
{
	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}
	if(TonicBuff_CD[client] > GetGameTime())
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", TonicBuff_CD[client] - GetGameTime());
		return;
	}
	
	TonicBuff_CD[client] = GetGameTime() + 10.0;
	SDKhooks_SetManaRegenDelayTime(client, 10.0);
	Mana_Hud_Delay[client] = 0.0;
	delay_hud[client] = 0.0;

	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 45.0);

	EmitSoundToClient(client, SOUND_TRANSFORM1);

	ApplyStatusEffect(client, client, "Tonic Affliction", 10.0);
	ApplyStatusEffect(client, client, "Tonic Affliction Hide", 10.0);
}

public void Weapon_Wand_PotionTransBuffM2(int client, int weapon, bool &crit, int slot)
{
	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}
	if(TonicBuff_CD[client] > GetGameTime())
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", TonicBuff_CD[client] - GetGameTime());
		return;
	}
	
	TonicBuff_CD[client] = GetGameTime() + 10.0;
	SDKhooks_SetManaRegenDelayTime(client, 10.0);
	TonicBuff_CD[client] = Mana_Regen_Delay[client];
	Mana_Hud_Delay[client] = 0.0;
	delay_hud[client] = 0.0;
	
	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 45.0);

	EmitSoundToClient(client, SOUND_TRANSFORM2);

	ApplyStatusEffect(client, client, "Tonic Affliction", 10.0);
	ApplyStatusEffect(client, client, "Tonic Affliction Hide", 10.0);

	float pos1[3], pos2[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos1);
	
	int count;
	for(int target = 1; target <= MaxClients; target++)
	{
		if(client != target && IsClientInGame(target) && IsPlayerAlive(target))
		{
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < 40000 && TonicBuff[target] < GetGameTime()) // 200 HU
			{
				i_ExtraPlayerPoints[client] += 10;

				int entity = GetEntPropEnt(target, Prop_Send, "m_hActiveWeapon");
				if(entity != -1)
				{
					EmitSoundToClient(target, SOUND_TRANSFORM2);

					TonicBuff[target] = Mana_Regen_Delay[client];
					int BeamIndex = ConnectWithBeam(client, target, 125, 125, 255, 3.0, 3.0, 1.35, "sprites/laserbeam.vmt");
					SetEntityRenderFx(BeamIndex, RENDERFX_FADE_SLOW);
					CreateTimer(2.0, Timer_RemoveEntity, EntIndexToEntRef(BeamIndex), TIMER_FLAG_NO_MAPCHANGE);
					ApplyStatusEffect(client, target, "Tonic Affliction", 10.0);
					ApplyStatusEffect(client, target, "Tonic Affliction Hide", 10.0);
					
					if(++count > 2)
						break;
				}
			}
		}
	}
	count = 0;
	int a, entity1;
	while((entity1 = FindEntityByNPC(a)) != -1)
	{
		if(GetTeam(entity1) == GetTeam(client))
		{
			GetEntPropVector(entity1, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < 40000) // 200 HU
			{
				i_ExtraPlayerPoints[client] += 10;
				int BeamIndex = ConnectWithBeam(client, entity1, 125, 125, 255, 3.0, 3.0, 1.35, "sprites/laserbeam.vmt");
				SetEntityRenderFx(BeamIndex, RENDERFX_FADE_SLOW);
				CreateTimer(2.0, Timer_RemoveEntity, EntIndexToEntRef(BeamIndex), TIMER_FLAG_NO_MAPCHANGE);
				ApplyStatusEffect(client, entity1, "Tonic Affliction", 10.0);
				ApplyStatusEffect(client, entity1, "Tonic Affliction Hide", 10.0);
				if(++count > 2)
					break;
			}
		}
	}
}

public void Weapon_Wand_PotionLeadTouch(int entity, int target)
{
	if(target)
	{
		if(target <= MaxClients)
			return;
		
		if(GetTeam(target) == 2)
			return;
	}

	SDKUnhook(entity, SDKHook_StartTouchPost, Weapon_Wand_PotionLeadTouch);

	float pos1[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
	EmitSoundToAll(SOUND_JAREXPLODE, entity, _, _, _, _, _, _, pos1);

	ParticleEffectAt(pos1, PARTICLE_JARATE, 2.0);

	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	
	i_ExplosiveProjectileHexArray[entity] = EP_DEALS_PLASMA_DAMAGE;
	Explode_Logic_Custom(f_WandDamage[entity],
	owner,
	entity,
	weapon,
	_,
	_,
	_,
	_,
	_,
	6,
	_,
	_,
	WandPotion_PotionLead,
	_,
	_);

	RemoveEntity(entity);
}

public void WandPotion_PotionLead(int entity, int enemy, float damage_Dontuse, int weapon)
{
	if (!IsValidEntity(enemy))
		return;

	int owner = EntRefToEntIndex(i_WandOwner[entity]);

	if (!IsValidEntity(owner))
		return;

	if(view_as<CClotBody>(enemy).m_iBleedType == BLEEDTYPE_METAL)
	{
		StartBleedingTimer(enemy, owner, f_WandDamage[entity] / 8.0, 10, weapon, DMG_BULLET);
	}
	else
	{
		StartBleedingTimer(enemy, owner, f_WandDamage[entity] / 16.0, 8, weapon, DMG_BULLET);
	}
}

public void Weapon_Wand_PotionGoldTouch(int entity, int target)
{
	if(target)
	{
		if(target <= MaxClients)
			return;
		
		if(GetTeam(target) == 2)
			return;
	}

	SDKUnhook(entity, SDKHook_StartTouchPost, Weapon_Wand_PotionGoldTouch);

	float pos1[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
	EmitSoundToAll(SOUND_JAREXPLODE, entity, _, _, _, _, _, _, pos1);
	
	ParticleEffectAt(pos1, PARTICLE_JARATE, 2.0);
	
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	
	i_ExplosiveProjectileHexArray[entity] = EP_DEALS_PLASMA_DAMAGE;
	Explode_Logic_Custom(f_WandDamage[entity],
	owner,
	entity,
	weapon,
	_,
	_,
	_,
	_,
	_,
	6,
	_,
	_,
	WandPotion_PotionGoldDo,
	_,
	_);
	
	RemoveEntity(entity);
}

public void WandPotion_PotionGoldDo(int entity, int enemy, float damage_Dontuse, int weapon)
{
	if (!IsValidEntity(enemy))
		return;

	int owner = EntRefToEntIndex(i_WandOwner[entity]);

	if (!IsValidEntity(owner))
		return;

	if(view_as<CClotBody>(enemy).m_iBleedType == BLEEDTYPE_METAL)
	{
		StartBleedingTimer(enemy, owner, f_WandDamage[entity] / 8.0, 10, weapon, DMG_BULLET);
	}
	else
	{
		StartBleedingTimer(enemy, owner, f_WandDamage[entity] / 16.0, 8, weapon, DMG_BULLET);
	}
	ApplyStatusEffect(owner, enemy, "Golden Curse", 1.5);
}

bool ShrinkOnlyOneTarget = false;
public void Weapon_Wand_PotionShrinkTouch(int entity, int target)
{
	if(target)
	{
		if(target <= MaxClients)
			return;
		
		if(GetTeam(target) == 2)
			return;
	}
	
	SDKUnhook(entity, SDKHook_StartTouchPost, Weapon_Wand_PotionShrinkTouch);

	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	float pos1[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
	ParticleEffectAt(pos1, PARTICLE_SHRINK, 1.0);
	EmitSoundToAll(SOUND_SHRINK, entity, _, _, _, _, _, _, pos1);
	ShrinkOnlyOneTarget = false;
	i_ExplosiveProjectileHexArray[entity] = EP_DEALS_PLASMA_DAMAGE;
	Explode_Logic_Custom(1.0,
	owner,
	entity,
	weapon,
	_,
	EXPLOSION_RADIUS * 2.0,
	1.0,
	1.0,
	_,
	3,
	_,
	_,
	WandPotion_PotionShrinkDo,
	_,
	_);

	RemoveEntity(entity);
}

public void WandPotion_PotionShrinkDo(int entity, int enemy, float damage_Dontuse, int weapon)
{
	if (!IsValidEntity(enemy))
		return;

	int owner = EntRefToEntIndex(i_WandOwner[entity]);

	if (!IsValidEntity(owner))
		return;

	if(enemy)
	{
		if(enemy <= MaxClients)
			return;
		
		if(GetTeam(enemy) == TFTeam_Red)
			return;
	}
	if(HasSpecificBuff(enemy, "Hardened Aura"))
	{
		return;
	}
	if(b_thisNpcIsABoss[enemy] || b_StaticNPC[enemy] || b_thisNpcIsARaid[enemy])
	{
		if(!ShrinkOnlyOneTarget)
		{
			float time = 3.0;
			if(b_thisNpcIsARaid[enemy])
			{
				time = 1.5;
			}
			ShrinkOnlyOneTarget = true;
			
			ApplyStatusEffect(owner, enemy, "Weakening Compound", time);
			
		}
	}
	else
	{
		ApplyStatusEffect(owner, enemy, "Weakening Compound", 999999.0);	
	}
}