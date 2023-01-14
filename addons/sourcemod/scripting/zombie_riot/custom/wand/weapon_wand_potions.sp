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

void Wand_Potions_Precache()
{
	PrecacheSound(SOUND_JAREXPLODE);
	PrecacheSound(SOUND_TRANSFORM1);
	PrecacheSound(SOUND_TRANSFORM2);
	PrecacheSound(SOUND_SHRINK);
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
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	if(PotionM1(client, weapon, touch, extra))
		Ability_Apply_Cooldown(client, slot, cooldown);
}

static bool PotionM1(int client, int weapon, SDKHookCB touch, int extra = 0)
{
	int mana_cost = extra;
	Address address = TF2Attrib_GetByDefIndex(weapon, 733);
	if(address != Address_Null)
		mana_cost += RoundToCeil(TF2Attrib_GetValue(address));
	
	if(Current_Mana[client] < mana_cost)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
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
	address = TF2Attrib_GetByDefIndex(weapon, 410);
	if(address != Address_Null)
		damage *= TF2Attrib_GetValue(address);
	
	float speed = 1000.0;
	address = TF2Attrib_GetByDefIndex(weapon, 103);
	if(address != Address_Null)
		speed *= TF2Attrib_GetValue(address);
	
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
	
	/*int entity = CreateEntityByName("tf_projectile_jar");
	if(entity > MaxClients)
	{
		float pos[3], ang[3], vel[3];
		GetClientEyeAngles(client, ang);
		GetClientEyePosition(client, pos);

		float speed = 1000.0;
		address = TF2Attrib_GetByDefIndex(weapon, 103);
		if(address != Address_Null)
			speed *= TF2Attrib_GetValue(address);
		
		vel[0] = Cosine(DegToRad(ang[0])) * Cosine(DegToRad(ang[1])) * speed;
		vel[1] = Cosine(DegToRad(ang[0])) * Sine(DegToRad(ang[1])) * speed;
		vel[2] = Sine(DegToRad(ang[0])) * -speed;

		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(entity, Prop_Send, "m_iTeamNum", 2);
		SetEntProp(entity, Prop_Send, "m_nSkin", 0);
		SetEntPropEnt(entity, Prop_Send, "m_hThrower", client);
		SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", weapon);
		SetEntPropEnt(entity, Prop_Send, "m_hLauncher", weapon);

		int model = GetEntProp(weapon, Prop_Send, "m_iWorldModelIndex");
		for(int i; i < 4; i++)
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", model, _, i);
		}
		
		DispatchSpawn(entity);
		TeleportEntity(entity, pos, ang, vel);
		//IsCustomTfGrenadeProjectile(entity, 1999999.0);	// Block normal explosion
		SDKHook(entity, SDKHook_StartTouchPost, touch);
	}*/
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
		
		if(GetEntProp(target, Prop_Send, "m_iTeamNum") == 2)
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
	int i = MaxClients + 1;
	while((i = FindEntityByClassname(i, "base_boss")) != -1)
	{
		if(!b_NpcHasDied[i] && GetEntProp(i, Prop_Send, "m_iTeamNum") != 2)
		{
			GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < (EXPLOSION_RADIUS * EXPLOSION_RADIUS))
			{
				SDKHooks_TakeDamage(i, entity, owner, f_WandDamage[entity], DMG_SLASH, weapon, _, pos1);
				StartBleedingTimer(i, owner, f_WandDamage[entity] / 8.0, 8, weapon);
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
		if(target == owner || GetEntProp(target, Prop_Send, "m_iTeamNum") != 2)
			return;
	}

	SDKUnhook(entity, SDKHook_StartTouchPost, Weapon_Wand_PotionBuffTouch);

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
				i_ExtraPlayerPoints[owner] += 10;
				TF2_AddCondition(client, TFCond_Buffed, 5.5, owner);
				break;
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
		if(target == owner || GetEntProp(target, Prop_Send, "m_iTeamNum") != 2)
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
				TF2_AddCondition(client, TFCond_Buffed, 7.5, owner);
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
		if(target == owner || GetEntProp(target, Prop_Send, "m_iTeamNum") != 2)
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
				i_ExtraPlayerPoints[owner] += 20;
				TF2_AddCondition(client, TFCond_Buffed, _, owner);
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
		
		if(GetEntProp(target, Prop_Send, "m_iTeamNum") == 2)
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
	int i = MaxClients + 1;
	while((i = FindEntityByClassname(i, "base_boss")) != -1)
	{
		if(!b_NpcHasDied[i] && GetEntProp(i, Prop_Send, "m_iTeamNum") != 2)
		{
			GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < (EXPLOSION_RADIUS * EXPLOSION_RADIUS))
			{
				float damage = f_WandDamage[entity];
				StartBleedingTimer(i, owner, damage / 8.0, 8, weapon);

				if(i_NpcInternalId[i] == BTD_BLOON)
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
					f_BombEntityWeaponDamageApplied[i][owner] = damage / 8.0;
					i_HowManyBombsOnThisEntity[i][owner] += 2;
					Apply_Particle_Teroriser_Indicator(i);
				}

				SDKHooks_TakeDamage(i, entity, owner, damage, DMG_BLAST, weapon, _, pos1);

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
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	Mana_Regen_Delay[client] = GetGameTime() + 10.0;
	Mana_Hud_Delay[client] = 0.0;
	delay_hud[client] = 0.0;
	Ability_Apply_Cooldown(client, slot, 45.0);

	EmitSoundToClient(client, SOUND_TRANSFORM1);
	i_ClientHasCustomGearEquipped[client] = true;

	ApplyTempAttrib(weapon, 6, 0.2);
	ApplyTempAttrib(weapon, 410, 0.5);
}

public void Weapon_Wand_PotionTransBuffM2(int client, int weapon, bool &crit, int slot)
{
	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	Mana_Regen_Delay[client] = GetGameTime() + 10.0;
	Mana_Hud_Delay[client] = 0.0;
	delay_hud[client] = 0.0;
	Ability_Apply_Cooldown(client, slot, 45.0);

	EmitSoundToClient(client, SOUND_TRANSFORM2);
	i_ClientHasCustomGearEquipped[client] = true;

	ApplyTempAttrib(weapon, 6, 0.2);
	ApplyTempAttrib(weapon, 410, 0.5);

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
					ApplyTempAttrib(entity, 2, 0.666);
					ApplyTempAttrib(entity, 6, 0.333);
					ApplyTempAttrib(entity, 97, 0.333);
					ApplyTempAttrib(entity, 410, 0.666);
					EmitSoundToClient(target, SOUND_TRANSFORM2);

					if(++count > 2)
						break;
				}
			}
		}
	}
}

static void ApplyTempAttrib(int entity, int index, float multi)
{
	Address address = TF2Attrib_GetByDefIndex(entity, index);
	if(address != Address_Null)
	{
		TF2Attrib_SetByDefIndex(entity, index, TF2Attrib_GetValue(address) * multi);

		DataPack pack;
		CreateDataTimer(10.0, StreetFighter_RestoreAttrib, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(entity));
		pack.WriteCell(index);
		pack.WriteFloat(multi);
	}
}

public Action Weapon_Wand_PotionRestoreAttrib(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != INVALID_ENT_REFERENCE)
	{
		int index = pack.ReadCell();
		Address address = TF2Attrib_GetByDefIndex(entity, index);
		if(address != Address_Null)
			TF2Attrib_SetByDefIndex(entity, index, TF2Attrib_GetValue(address) / pack.ReadFloat());
	}
	return Plugin_Stop;
}

public void Weapon_Wand_PotionLeadTouch(int entity, int target)
{
	if(target)
	{
		if(target <= MaxClients)
			return;
		
		if(GetEntProp(target, Prop_Send, "m_iTeamNum") == 2)
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
	int i = MaxClients + 1;
	while((i = FindEntityByClassname(i, "base_boss")) != -1)
	{
		if(!b_NpcHasDied[i] && GetEntProp(i, Prop_Send, "m_iTeamNum") != 2)
		{
			GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < (EXPLOSION_RADIUS * EXPLOSION_RADIUS))
			{
				if(view_as<CClotBody>(i).m_iBleedType == BLEEDTYPE_METAL)
				{
					SDKHooks_TakeDamage(i, entity, owner, f_WandDamage[entity], DMG_SLASH, weapon, _, pos1);
					StartBleedingTimer(i, owner, f_WandDamage[entity] / 2.0, 10, weapon);
				}
				else
				{
					SDKHooks_TakeDamage(i, entity, owner, f_WandDamage[entity], DMG_SLASH, weapon, _, pos1);
					StartBleedingTimer(i, owner, f_WandDamage[entity] / 8.0, 8, weapon);
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
		
		if(GetEntProp(target, Prop_Send, "m_iTeamNum") == 2)
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
	int i = MaxClients + 1;
	while((i = FindEntityByClassname(i, "base_boss")) != -1)
	{
		if(!b_NpcHasDied[i] && GetEntProp(i, Prop_Send, "m_iTeamNum") != 2)
		{
			GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < (EXPLOSION_RADIUS * EXPLOSION_RADIUS))
			{
				if(view_as<CClotBody>(i).m_iBleedType == BLEEDTYPE_METAL)
				{
					SDKHooks_TakeDamage(i, entity, owner, f_WandDamage[entity], DMG_SLASH, weapon, _, pos1);
					StartBleedingTimer(i, owner, f_WandDamage[entity] / 2.0, 10, weapon);
				}
				else
				{
					SDKHooks_TakeDamage(i, entity, owner, f_WandDamage[entity], DMG_SLASH, weapon, _, pos1);
					StartBleedingTimer(i, owner, f_WandDamage[entity] / 8.0, 8, weapon);
				}

				float time = GetGameTime() + 3.0;
				if(f_CrippleDebuff[i] < time)
					f_CrippleDebuff[i] = time;
				
				if(++count > 4)
					break;
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
		
		if(GetEntProp(target, Prop_Send, "m_iTeamNum") == 2)
			return;
	}

	SDKUnhook(entity, SDKHook_StartTouchPost, Weapon_Wand_PotionShrinkTouch);

	float pos1[3], pos2[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
	ParticleEffectAt(pos1, PARTICLE_SHRINK, 1.0);
	EmitSoundToAll(SOUND_SHRINK, entity, _, _, _, _, _, _, pos1);

	bool raid = IsValidEntity(EntRefToEntIndex(RaidBossActive));

	int count;
	int i = MaxClients + 1;
	while((i = FindEntityByClassname(i, "base_boss")) != -1)
	{
		if(!b_NpcHasDied[i] && f_MaimDebuff[i] != FAR_FUTURE && GetEntProp(i, Prop_Send, "m_iTeamNum") != 2)
		{
			GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < (EXPLOSION_RADIUS * EXPLOSION_RADIUS * 2))
			{
				if(raid)
				{
					float time = GetGameTime() + 1.1;
					if(f_MaimDebuff[i] < time)
						f_MaimDebuff[i] = time;
					
					time += 1.9;
					if(f_CrippleDebuff[i] < time)
						f_CrippleDebuff[i] = time;
					
					break;
				}
				
				float scale = GetEntPropFloat(i, Prop_Send, "m_flModelScale");
				SetEntPropFloat(i, Prop_Send, "m_flModelScale", scale * 0.35);

				if(b_thisNpcIsABoss[i])
				{
					if(!count)
					{
						float time = GetGameTime() + 1.1;
						if(f_MaimDebuff[i] < time)
							f_MaimDebuff[i] = time;
						
						time += 1.9;
						if(f_CrippleDebuff[i] < time)
							f_CrippleDebuff[i] = time;
						
						CreateTimer(1.0, Weapon_Wand_PotionEndShrink, EntIndexToEntRef(i), TIMER_FLAG_NO_MAPCHANGE);
						break;
					}
				}
				else
				{
					f_MaimDebuff[i] = FAR_FUTURE;
					f_CrippleDebuff[i] = FAR_FUTURE;
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
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", scale / 0.35);
	}
	return Plugin_Continue;
}