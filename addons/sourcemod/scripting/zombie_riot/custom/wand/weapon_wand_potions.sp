#pragma semicolon 1
#pragma newdecls required

#define PARTICLE_JARATE		"peejar_impact_small"
#define PARTICLE_MADMILK	"peejar_impact_milk"
#define PARTICLE_SHRINK		"utaunt_arcane_green_parent"//"utaunt_merasmus"
#define SOUND_JAREXPLODE	"weapons/jar_explode.wav"
#define SOUND_TRANSFORM1	"ambient/halloween/thunder_04.wav"
#define SOUND_TRANSFORM2	"ambient/halloween/thunder_01.wav"
#define SOUND_SHRINK		"items/powerup_pickup_plague_infected.wav"

static Handle BuffTimer[MAXENTITIES];
static float TonicBuff[MAXTF2PLAYERS];
static float TonicBuff_CD[MAXTF2PLAYERS];
static Handle ShrinkTimer[MAXENTITIES];
static float f_RaidShrinkImmunity[MAXENTITIES];


void Wands_Potions_EntityCreated(int entity)
{
	delete BuffTimer[entity];
	delete ShrinkTimer[entity];
}

void Wand_Potions_Precache()
{
	PrecacheSound(SOUND_JAREXPLODE);
	PrecacheSound(SOUND_TRANSFORM1);
	PrecacheSound(SOUND_TRANSFORM2);
	PrecacheSound(SOUND_SHRINK);
	Zero(f_RaidShrinkImmunity);

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

	int entity = Wand_Projectile_Spawn(client, speed, 20.0, damage, 0, weapon, NULL_STRING, ang, false);
	if(entity > MaxClients)
	{
		SetEntityGravity(entity, 1.5);
		SetEntityMoveType(entity, MOVETYPE_FLYGRAVITY);

		int model = i_WeaponModelIndexOverride[weapon];
		SetEntProp(entity, Prop_Send, "m_nBody", i_WeaponBodygroup[weapon]);
		for(int i; i < 4; i++)
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", model, _, i);
		}

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
	5,
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

	StartBleedingTimer(enemy, owner, f_WandDamage[entity] / 32.0, 5, weapon, DMG_TRUEDAMAGE);
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
		int weapon = GetEntPropEnt(target, Prop_Send, "m_hActiveWeapon");
		if(weapon != -1)
		{
			i_ExtraPlayerPoints[owner] += 10;
			
			if(BuffTimer[weapon])
				TriggerTimer(BuffTimer[weapon]);
			
			float multi = MaxNumBuffValue(0.8, 1.0, PlayerCountBuffAttackspeedScaling);
			
			if(Attributes_Has(weapon,6))
			{
				Attributes_SetMulti(weapon, 6, multi);
			}
			
			ApplyStatusEffect(weapon, weapon, "Mystery Beer", 5.5);

			DataPack pack;
			BuffTimer[weapon] = CreateDataTimer(5.5, Weapon_Wand_PotionBuffRemove, pack);
			pack.WriteCell(weapon);
			pack.WriteFloat(multi);
		}
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
					int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
					if(weapon != -1)
					{
						i_ExtraPlayerPoints[owner] += 10;
						
						if(BuffTimer[weapon])
							TriggerTimer(BuffTimer[weapon]);
						
						float multi = MaxNumBuffValue(0.8, 1.0, PlayerCountBuffAttackspeedScaling);

						if(Attributes_Has(weapon,6))
						{
							Attributes_SetMulti(weapon, 6, multi);
						}

						ApplyStatusEffect(weapon, weapon, "Mystery Beer", 5.5);
						DataPack pack;
						BuffTimer[weapon] = CreateDataTimer(5.5, Weapon_Wand_PotionBuffRemove, pack);
						pack.WriteCell(weapon);
						pack.WriteFloat(multi);
						break;
					}
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
				int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon != -1)
				{
					i_ExtraPlayerPoints[owner] += 12;
					
					if(BuffTimer[weapon])
						TriggerTimer(BuffTimer[weapon]);
					
					float multi = MaxNumBuffValue(0.8, 1.0, PlayerCountBuffAttackspeedScaling);

					if(Attributes_Has(weapon,6))
					{
						Attributes_SetMulti(weapon, 6, multi);
					}

					ApplyStatusEffect(weapon, weapon, "Mystery Beer", 7.5);
					DataPack pack;
					BuffTimer[weapon] = CreateDataTimer(7.5, Weapon_Wand_PotionBuffRemove, pack);
					pack.WriteCell(weapon);
					pack.WriteFloat(multi);
				}
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
					
					if(BuffTimer[weapon])
						TriggerTimer(BuffTimer[weapon]);
					
					float multi = MaxNumBuffValue(0.8, 1.0, PlayerCountBuffAttackspeedScaling);

					if(Attributes_Has(weapon,6))
					{
						Attributes_SetMulti(weapon, 6, multi);
					}

					ApplyStatusEffect(weapon, weapon, "Mystery Beer", 999.9);
					DataPack pack;
					BuffTimer[weapon] = CreateDataTimer(999.9, Weapon_Wand_PotionBuffRemove, pack);
					pack.WriteCell(weapon);
					pack.WriteFloat(multi);
				}
			}
		}
	}

	RemoveEntity(entity);
}

public Action Weapon_Wand_PotionBuffRemove(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = pack.ReadCell();
	if(IsValidEntity(entity))
	{
		if(Attributes_Has(entity,6))
		{
			Attributes_SetMulti(entity, 6, 1.0 / pack.ReadFloat());
		}
	}

	BuffTimer[entity] = null;
	return Plugin_Continue;
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
	5,
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
	StartBleedingTimer(enemy, owner, damage / 16.0, 8, weapon, DMG_TRUEDAMAGE);
	NPC_GetPluginById(i_NpcInternalId[enemy], npc_classname, sizeof(npc_classname));
	if(StrEqual(npc_classname, "npc_bloon"))
	{
		if(view_as<Bloon>(enemy).m_bFortified)
		{
			view_as<Bloon>(enemy).m_bFortified = false;
			SetEntProp(enemy, Prop_Data, "m_iMaxHealth", Bloon_Health(false, view_as<Bloon>(enemy).m_iOriginalType));
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

	if(Waves_InFreeplay())
	{
		ApplyTempAttrib(weapon, 6, 0.4, 10.0);
		ApplyTempAttrib(weapon, 410, 0.8, 10.0);
		ApplyTempAttrib(weapon, 733, 0.5, 10.0);
	}
	else
	{
		ApplyTempAttrib(weapon, 6, 0.2, 10.0);
		ApplyTempAttrib(weapon, 410, 0.5, 10.0);
		ApplyTempAttrib(weapon, 733, 0.2, 10.0);
	}
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

	if(Waves_InFreeplay())
	{
		ApplyTempAttrib(weapon, 6, 0.4, 10.0);
		ApplyTempAttrib(weapon, 410, 0.8, 10.0);
		ApplyTempAttrib(weapon, 733, 0.5, 10.0);
	}
	else
	{
		ApplyTempAttrib(weapon, 6, 0.2, 10.0);
		ApplyTempAttrib(weapon, 410, 0.5, 10.0);
		ApplyTempAttrib(weapon, 733, 0.2, 10.0);
	}

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
					if(Waves_InFreeplay())
					{
						ApplyTempAttrib(entity, 2, 0.75, 10.0);
						ApplyTempAttrib(entity, 6, 0.5, 10.0);
						ApplyTempAttrib(entity, 97, 0.5, 10.0);
						ApplyTempAttrib(entity, 410, 0.75, 10.0);
						ApplyTempAttrib(entity, 733, 0.67, 10.0);
					}
					else
					{
						ApplyTempAttrib(entity, 2, 0.4, 10.0);
						ApplyTempAttrib(entity, 6, 0.333, 10.0);
						ApplyTempAttrib(entity, 97, 0.333, 10.0);
						ApplyTempAttrib(entity, 410, 0.4, 10.0);
						ApplyTempAttrib(entity, 733, 0.333, 10.0);
					}
					
					EmitSoundToClient(target, SOUND_TRANSFORM2);

					TonicBuff[target] = Mana_Regen_Delay[client];
					ApplyStatusEffect(client, target, "Tonic Affliction", 10.0);

					if(++count > 2)
						break;
				}
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
	5,
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
		StartBleedingTimer(enemy, owner, f_WandDamage[entity] / 8.0, 10, weapon, DMG_TRUEDAMAGE);
	}
	else
	{
		StartBleedingTimer(enemy, owner, f_WandDamage[entity] / 16.0, 8, weapon, DMG_TRUEDAMAGE);
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
	5,
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
		StartBleedingTimer(enemy, owner, f_WandDamage[entity] / 8.0, 10, weapon, DMG_TRUEDAMAGE);
	}
	else
	{
		StartBleedingTimer(enemy, owner, f_WandDamage[entity] / 16.0, 8, weapon, DMG_TRUEDAMAGE);
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
	2,
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
		if(!ShrinkOnlyOneTarget && f_RaidShrinkImmunity[enemy] < GetGameTime())
		{
			float time = 3.0;
			if(b_thisNpcIsARaid[enemy])
			{
				time = 1.5;
			}
			f_RaidShrinkImmunity[enemy] = GetGameTime() + (time * 3.0);
			ShrinkOnlyOneTarget = true;
			
			ApplyStatusEffect(owner, enemy, "Shrinking", time);
			
			if(ShrinkTimer[enemy] != null)
				delete ShrinkTimer[enemy];
			else
			{
				//no timer beforehand.
				float scale = GetEntPropFloat(enemy, Prop_Send, "m_flModelScale");
				SetEntPropFloat(enemy, Prop_Send, "m_flModelScale", scale * 0.5);
			}
			DataPack pack_repack;
			ShrinkTimer[enemy] = CreateDataTimer(time, Weapon_Wand_PotionEndShrink, pack_repack, TIMER_FLAG_NO_MAPCHANGE);
			pack_repack.WriteCell(enemy);
			pack_repack.WriteCell(EntIndexToEntRef(enemy));
		}
	}
	else
	{
		if(!NpcStats_IsEnemyShank(enemy))
		{
			float scale = GetEntPropFloat(enemy, Prop_Send, "m_flModelScale");
			SetEntPropFloat(enemy, Prop_Send, "m_flModelScale", scale * 0.5);
		}
		ApplyStatusEffect(owner, enemy, "Shrinking", 999999.0);	
		Stock_TakeDamage(enemy, owner, owner, GetEntProp(enemy, Prop_Data, "m_iHealth") / 2.0, DMG_TRUEDAMAGE, weapon);
	}
}
public Action Weapon_Wand_PotionEndShrink(Handle timer, DataPack pack)
{
	pack.Reset();
	int IndexDefualt = pack.ReadCell();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(entity))
	{
		float scale = GetEntPropFloat(entity, Prop_Send, "m_flModelScale");
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", scale / 0.5);
	}
	ShrinkTimer[IndexDefualt] = null;
	return Plugin_Continue;
}
