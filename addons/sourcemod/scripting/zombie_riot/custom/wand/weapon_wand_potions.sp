#pragma semicolon 1
#pragma newdecls required

#define PARTICLE_JARATE		"peejar_impact_small"
#define PARTICLE_MADMILK	"peejar_impact_milk"
#define PARTICLE_ACIDPOOL	"utaunt_bubbles_glow_orange_parent"
#define PARTICLE_SHRINK		"utaunt_arcane_green_parent"//"utaunt_merasmus"
#define SOUND_JAREXPLODE	"weapons/jar_explode.wav"
#define SOUND_TRANSFORM1	"ambient/halloween/thunder_04.wav"
#define SOUND_TRANSFORM2	"ambient/halloween/thunder_01.wav"
#define SOUND_SHRINK		"items/powerup_pickup_plague_infected.wav"

static Handle BuffTimer[MAXENTITIES];
static float TonicBuff[MAXTF2PLAYERS];
static float TonicBuff_CD[MAXTF2PLAYERS];

bool Wands_Potions_HasBuff(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon != -1)
		return view_as<bool>(BuffTimer[weapon]);
	
	return false;
}

bool Wands_Potions_HasTonicBuff(int client)
{
	return TonicBuff[client] > GetGameTime();
}

void Wands_Potions_EntityCreated(int entity)
{
	delete BuffTimer[entity];
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
		Rogue_OnAbilityUse(weapon);
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	if(PotionM1(client, weapon, touch, extra))
	{
		Rogue_OnAbilityUse(weapon);
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

	float time = GetGameTime() + 1.0;
	if(Mana_Regen_Delay[client] < time)
		Mana_Regen_Delay[client] = time;
	
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

		int model = GetEntProp(weapon, Prop_Send, "m_iWorldModelIndex");
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

	float pos1[3], pos2[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
	ParticleEffectAt(pos1, PARTICLE_JARATE, 2.0);
	EmitSoundToAll(SOUND_JAREXPLODE, entity, _, _, _, _, _, _, pos1);
	
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

	int count;
	for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpcTotal; entitycount_again_2++) //Check for npcs
	{
		int i = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount_again_2]);
		if(IsValidEntity(i) && !b_NpcHasDied[i] && GetTeam(i) != TFTeam_Red)
		{
			GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < (EXPLOSION_RADIUS * EXPLOSION_RADIUS))
			{
				SDKHooks_TakeDamage(i, entity, owner, f_WandDamage[entity], DMG_SLASH, weapon, _, pos1);
				StartBleedingTimer(i, owner, f_WandDamage[entity] / 8.0, 8, weapon, DMG_SLASH);
				if(++count > 4)
					break;
			}
		}
	}

	RemoveEntity(entity);
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
			{
				delete BuffTimer[weapon];
			}
			else
			{
				if(Attributes_Has(weapon,6))
				{
					Attributes_Set(weapon, 6, Attributes_Get(weapon, 6, 1.0) * 0.8);
				}
			}

			BuffTimer[weapon] = CreateTimer(5.5, Weapon_Wand_PotionBuffRemove, weapon);
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
						{
							delete BuffTimer[weapon];
						}
						else
						{
							if(Attributes_Has(weapon,6))
							{
								Attributes_Set(weapon, 6, Attributes_Get(weapon, 6, 1.0) * 0.8);
							}
						}

						BuffTimer[weapon] = CreateTimer(5.5, Weapon_Wand_PotionBuffRemove, weapon);
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
					{
						delete BuffTimer[weapon];
					}
					else
					{
					
						if(Attributes_Has(weapon,6))
						{
							Attributes_Set(weapon, 6, Attributes_Get(weapon, 6, 1.0) * 0.8);
						}
					}

					BuffTimer[weapon] = CreateTimer(7.5, Weapon_Wand_PotionBuffRemove, weapon);
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
					{
						delete BuffTimer[weapon];
					}
					else
					{
						if(Attributes_Has(weapon,6))
						{
							Attributes_Set(weapon, 6, Attributes_Get(weapon, 6, 1.0) * 0.8);
						}
					}

					BuffTimer[weapon] = CreateTimer(999.9, Weapon_Wand_PotionBuffRemove, weapon);
				}
			}
		}
	}

	RemoveEntity(entity);
}

public Action Weapon_Wand_PotionBuffRemove(Handle timer, int entity)
{
	if(IsValidEntity(entity))
	{
		if(Attributes_Has(entity,6))
		{
			Attributes_Set(entity, 6, Attributes_Get(entity, 6, 1.0) / 0.8);
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

	float pos1[3], pos2[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
	ParticleEffectAt(pos1, PARTICLE_JARATE, 2.0);
	EmitSoundToAll(SOUND_JAREXPLODE, entity, _, _, _, _, _, _, pos1);
	
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	
	int count;
	char npc_classname[60];
	for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpcTotal; entitycount_again_2++) //Check for npcs
	{
		int i = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount_again_2]);
		if(IsValidEntity(i) && !b_NpcHasDied[i] && GetTeam(i) != TFTeam_Red && !b_NpcIsInvulnerable[i])
		{
			GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < (EXPLOSION_RADIUS * EXPLOSION_RADIUS))
			{
				float damage = f_WandDamage[entity];
				StartBleedingTimer(i, owner, damage / 8.0, 8, weapon, DMG_SLASH);
				NPC_GetPluginById(i_NpcInternalId[i], npc_classname, sizeof(npc_classname));
				if(StrEqual(npc_classname, "npc_bloon"))
				{
					if(view_as<Bloon>(i).m_bFortified)
					{
						view_as<Bloon>(i).m_bFortified = false;
						SetEntProp(i, Prop_Data, "m_iMaxHealth", Bloon_Health(false, view_as<Bloon>(i).m_iOriginalType));

						damage = float(GetEntProp(i, Prop_Data, "m_iHealth") - Bloon_Health(false, view_as<Bloon>(i).m_iType));
						if(f_WandDamage[entity] > damage)
							damage = f_WandDamage[entity];
					}
				}
				else
				{
					f_BombEntityWeaponDamageApplied[i][owner] = damage / 2.0;
					i_HowManyBombsOnThisEntity[i][owner] += 1;
					i_HowManyBombsHud[i] += 1;
					Apply_Particle_Teroriser_Indicator(i);
				}

				SDKHooks_TakeDamage(i, entity, owner, damage, DMG_SLASH, weapon, _, pos1);

				if(++count > 4)
					break;
			}
		}
	}

	RemoveEntity(entity);
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
	Mana_Regen_Delay[client] = GetGameTime() + 10.0;
	Mana_Hud_Delay[client] = 0.0;
	delay_hud[client] = 0.0;

	Rogue_OnAbilityUse(weapon);
	Ability_Apply_Cooldown(client, slot, 45.0);

	EmitSoundToClient(client, SOUND_TRANSFORM1);

	ApplyTempAttrib(weapon, 6, 0.2, 10.0);
	ApplyTempAttrib(weapon, 410, 0.5, 10.0);
	ApplyTempAttrib(weapon, 733, 0.2, 10.0);
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
	Mana_Regen_Delay[client] = GetGameTime() + 10.0;
	Mana_Hud_Delay[client] = 0.0;
	delay_hud[client] = 0.0;
	
	Rogue_OnAbilityUse(weapon);
	Ability_Apply_Cooldown(client, slot, 45.0);

	EmitSoundToClient(client, SOUND_TRANSFORM2);

	ApplyTempAttrib(weapon, 6, 0.2, 10.0);
	ApplyTempAttrib(weapon, 410, 0.5, 10.0);
	ApplyTempAttrib(weapon, 733, 0.2, 10.0);

	float pos1[3], pos2[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos1);
	
	int count;
	for(int target = 1; target <= MaxClients; target++)
	{
		if(client != target && IsClientInGame(target) && IsPlayerAlive(target))
		{
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < 40000) // 200 HU
			{
				i_ExtraPlayerPoints[client] += 10;

				int entity = GetEntPropEnt(target, Prop_Send, "m_hActiveWeapon");
				if(entity != -1)
				{
					ApplyTempAttrib(entity, 2, 0.4, 10.0);
					ApplyTempAttrib(entity, 6, 0.333, 10.0);
					ApplyTempAttrib(entity, 97, 0.333, 10.0);
					ApplyTempAttrib(entity, 410, 0.4, 10.0);
					ApplyTempAttrib(entity, 733, 0.333, 10.0);
					EmitSoundToClient(target, SOUND_TRANSFORM2);

					TonicBuff[target] = Mana_Regen_Delay[client];

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

	float pos1[3], pos2[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
	EmitSoundToAll(SOUND_JAREXPLODE, entity, _, _, _, _, _, _, pos1);

	if(target)
	{
		ParticleEffectAt(pos1, PARTICLE_JARATE, 2.0);
	}
	else
	{
		ParticleEffectAt(pos1, PARTICLE_ACIDPOOL, 0.5);
	}
	
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	
	int count;
	for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpcTotal; entitycount_again_2++) //Check for npcs
	{
		int i = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount_again_2]);
		if(IsValidEntity(i) && !b_NpcHasDied[i] && GetTeam(i) != TFTeam_Red)
		{
			GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < (EXPLOSION_RADIUS * EXPLOSION_RADIUS))
			{
				if(view_as<CClotBody>(i).m_iBleedType == BLEEDTYPE_METAL)
				{
					SDKHooks_TakeDamage(i, entity, owner, f_WandDamage[entity], DMG_SLASH, weapon, _, pos1);
					StartBleedingTimer(i, owner, f_WandDamage[entity] / 2.0, 10, weapon, DMG_SLASH);
				}
				else
				{
					SDKHooks_TakeDamage(i, entity, owner, f_WandDamage[entity], DMG_SLASH, weapon, _, pos1);
					StartBleedingTimer(i, owner, f_WandDamage[entity] / 8.0, 8, weapon, DMG_SLASH);
				}

				if(++count > 4)
					break;
			}
		}
	}

	RemoveEntity(entity);
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

	float pos1[3], pos2[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
	EmitSoundToAll(SOUND_JAREXPLODE, entity, _, _, _, _, _, _, pos1);
	
	if(target)
	{
		ParticleEffectAt(pos1, PARTICLE_JARATE, 2.0);
	}
	else
	{
		ParticleEffectAt(pos1, PARTICLE_ACIDPOOL, 0.5);
	}
	
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	
	int count;
	if(IsValidEntity(weapon))
	{
		for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpcTotal; entitycount_again_2++) //Check for npcs
		{
			int i = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount_again_2]);
			if(IsValidEntity(i) && !b_NpcHasDied[i] && GetTeam(i) != TFTeam_Red)
			{
				GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", pos2);
				if(GetVectorDistance(pos1, pos2, true) < (EXPLOSION_RADIUS * EXPLOSION_RADIUS))
				{
					if(view_as<CClotBody>(i).m_iBleedType == BLEEDTYPE_METAL)
					{
						SDKHooks_TakeDamage(i, entity, owner, f_WandDamage[entity], DMG_SLASH, weapon, _, pos1);
						StartBleedingTimer(i, owner, f_WandDamage[entity] / 2.0, 10, weapon, DMG_SLASH);
					}
					else
					{
						SDKHooks_TakeDamage(i, entity, owner, f_WandDamage[entity], DMG_SLASH, weapon, _, pos1);
						StartBleedingTimer(i, owner, f_WandDamage[entity] / 8.0, 8, weapon, DMG_SLASH);
					}

					float time = GetGameTime() + 1.5;
					if(f_CrippleDebuff[i] < time)
						f_CrippleDebuff[i] = time;
					
					if(++count > 4)
						break;
				}
			}
		}
	}

	RemoveEntity(entity);
}

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

	float pos1[3], pos2[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
	ParticleEffectAt(pos1, PARTICLE_SHRINK, 1.0);
	EmitSoundToAll(SOUND_SHRINK, entity, _, _, _, _, _, _, pos1);

	int count;
	for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpcTotal; entitycount_again_2++) //Check for npcs
	{
		int i = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount_again_2]);
		if(IsValidEntity(i) && !b_NpcHasDied[i] && f_MaimDebuff[i] != FAR_FUTURE && GetTeam(i) != TFTeam_Red)
		{
			GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < (EXPLOSION_RADIUS * EXPLOSION_RADIUS * 2))
			{
				float scale = GetEntPropFloat(i, Prop_Send, "m_flModelScale");
				SetEntPropFloat(i, Prop_Send, "m_flModelScale", scale * 0.5);

				if(b_thisNpcIsABoss[i] || b_StaticNPC[i] || b_thisNpcIsARaid[i])
				{
					if(!count)
					{
						float time = 4.0;
						if(b_thisNpcIsARaid[i])
						{
							time = 3.0;
						}
						if(f_PotionShrinkEffect[i] < (GetGameTime() + time))
							f_PotionShrinkEffect[i] =  (GetGameTime() + time);
						
						CreateTimer(time, Weapon_Wand_PotionEndShrink, EntIndexToEntRef(i), TIMER_FLAG_NO_MAPCHANGE);
						break;
					}
				}
				else
				{
					f_PotionShrinkEffect[i] = FAR_FUTURE;
				}
				
				if(++count > 1)
					break;
			}
		}
	}

	RemoveEntity(entity);
}


public Action Weapon_Wand_PotionEndShrink(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity != -1)
	{
		float scale = GetEntPropFloat(entity, Prop_Send, "m_flModelScale");
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", scale / 0.5);
	}
	return Plugin_Continue;
}