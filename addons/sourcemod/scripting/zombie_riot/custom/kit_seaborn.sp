#pragma semicolon 1
#pragma newdecls required

static int MeleeLevel[MAXPLAYERS];

static float SpecialEffectFor[MAXPLAYERS];
static bool SpecialEffect[MAXPLAYERS];
static int ParticleRef[MAXPLAYERS] = {-1, ...};
static Handle EffectTimer[MAXPLAYERS];

static bool b_musicprecached;

public void Seaborn_OnMapStart()
{
	b_musicprecached = false;
}
public void Weapon_SeaMelee_M2(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 90.0);

	EmitSoundToClient(client, "ambient/halloween/thunder_01.wav");

	ApplyTempAttrib(weapon, 2, 0.75, 10.0);
	ApplyTempAttrib(weapon, 6, 0.5, 10.0);
	SpecialEffectFor[client] = GetGameTime() + 10.0;

	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 10.0);
/*
	float pos1[3], pos2[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos1);
	
	for(int target = 1; target <= MaxClients; target++)
	{
		if(client != target && IsClientInGame(target) && IsPlayerAlive(target))
		{
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < 100000) // 316 HU
			{
				i_ExtraPlayerPoints[client] += 10;

				int entity = GetEntPropEnt(target, Prop_Send, "m_hActiveWeapon");
				if(entity != -1)
				{
					ApplyTempAttrib(entity, 2, 0.75, 10.0);
					ApplyTempAttrib(entity, 6, 0.5, 10.0);
					ApplyTempAttrib(entity, 97, 0.5, 10.0);
					ApplyTempAttrib(entity, 410, 0.75, 10.0);
					ApplyTempAttrib(entity, 733, 0.5, 10.0);

					EmitSoundToClient(target, "ambient/halloween/thunder_01.wav");
					EmitSoundToClient(target, "ambient/halloween/thunder_01.wav");
				}
			}
		}
	}*/
}

void SeaBornMusicDo()
{
	if(!b_musicprecached)
	{
		PrecacheSoundCustom("#zombiesurvival/wave_music/bat_rglk2boss1.mp3");
	}
	b_musicprecached = true;
}
void SeaMelee_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SEABORNMELEE || i_CustomWeaponEquipLogic[weapon] == WEAPON_ULPIANUS)
	{

		MeleeLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));

		delete EffectTimer[client];
		EffectTimer[client] = CreateTimer(0.2, SeaMelee_TimerEffect, client, TIMER_REPEAT);
		SeaBornMusicDo();
	}
}

bool SeaMelee_IsSeaborn(int client)
{
	if(EffectTimer[client] == null)
		return false;

	return true;
}

public Action SeaMelee_TimerEffect(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		if(IsPlayerAlive(client))
		{
			int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(weapon != INVALID_ENT_REFERENCE)
			{
				switch(i_CustomWeaponEquipLogic[weapon])
				{
					case WEAPON_SEABORNMELEE, WEAPON_SEABORN_MISC, WEAPON_ULPIANUS:
					{
						if(LastMann)
						{
							float enemypos[3]; 
							GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", enemypos);
							SeaFounder_SpawnNethersea(enemypos);
						}
						b_IsCannibal[client] = true;

						bool special = SpecialEffectFor[client] > GetGameTime();

						if(special ^ SpecialEffect[client])
						{
							if(ParticleRef[client] != -1)
							{
								int entity = EntRefToEntIndex(ParticleRef[client]);
								if(entity > MaxClients)
								{
									TeleportEntity(entity, OFF_THE_MAP);
									RemoveEntity(entity);
								}

								ParticleRef[client] = -1;
							}
						}

						if(MeleeLevel[client] >= 0 && ParticleRef[client] == -1)
						{
							float pos[3]; GetClientAbsOrigin(client, pos);
							pos[2] += 1.0;

							int entity = ParticleEffectAt(pos, special ? "utaunt_hands_floor2_blue" : "utaunt_hands_floor2_blue", -1.0);
							if(entity > MaxClients)
							{
								SetParent(client, entity);
								ParticleRef[client] = EntIndexToEntRef(entity);
								SpecialEffect[client] = special;
							}
						}
					}
				}
				return Plugin_Continue;
			}
		}
	}
		
	if(ParticleRef[client] != -1)
	{
		int entity = EntRefToEntIndex(ParticleRef[client]);
		if(entity > MaxClients)
		{
			TeleportEntity(entity, OFF_THE_MAP);
			RemoveEntity(entity);
		}
		
		ParticleRef[client] = -1;
	}

	EffectTimer[client] = null;
	return Plugin_Stop;
}

void SeaMelee_DoSwingTrace(int client, float &CustomMeleeRange, float &CustomMeleeWide, bool &ignore_walls, int &enemies_hit_aoe)
{
	switch(MeleeLevel[client])
	{
		case -1:
		{
			enemies_hit_aoe = 2;
		}
		case 1:
		{
			CustomMeleeRange = MELEE_RANGE * 1.25;
			CustomMeleeWide = MELEE_BOUNDS * 1.25;
			ignore_walls = true;
			enemies_hit_aoe = 4;
		}
		case 2:
		{
			CustomMeleeRange = MELEE_RANGE * 1.25;
			CustomMeleeWide = MELEE_BOUNDS * 1.25;
			ignore_walls = true;
			enemies_hit_aoe = 5;
		}
		default:
		{
			CustomMeleeRange = MELEE_RANGE * 1.15;
			CustomMeleeWide = MELEE_BOUNDS * 1.15;
			enemies_hit_aoe = 3;
		}
	}
}

public void Weapon_SeaRange_M2(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 60.0);

	ClientCommand(client, "playgamesound ambient/halloween/male_scream_13.wav");

	float pos1[3], ang[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos1);
	GetEntPropVector(client, Prop_Data, "m_angRotation", ang);

	int SpawnMaxEnemies = 2;
	if(LastMann)
		SpawnMaxEnemies = 4;
		
	for(int i; i < SpawnMaxEnemies; i++)
	{
		int entity = NPC_CreateByName("npc_searunner", client, pos1, ang, TFTeam_Red);
		if(entity > MaxClients)
		{
			fl_Extra_Damage[entity] = Attributes_Get(weapon, 2, 1.0);
			CreateTimer(95.0, Seaborn_KillNPC, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
			i_NpcOverrideAttacker[entity] = EntIndexToEntRef(client);
			b_ShowNpcHealthbar[entity] = true;
		}
	}
}

public void Weapon_SeaRangePap_M2(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 75.0);

	ClientCommand(client, "playgamesound ambient/halloween/male_scream_13.wav");

	float pos1[3], ang[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos1);
	GetEntPropVector(client, Prop_Data, "m_angRotation", ang);
	int SpawnMaxEnemies = 2;
	if(LastMann)
		SpawnMaxEnemies = 4;
		
	for(int i; i < SpawnMaxEnemies; i++)
	{
		int entity = NPC_CreateByName("npc_searunner", client, pos1, ang, TFTeam_Red);
		if(entity > MaxClients)
		{
			fl_Extra_Damage[entity] = Attributes_Get(weapon, 2, 1.0);
			CreateTimer(95.0, Seaborn_KillNPC, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
			i_NpcOverrideAttacker[entity] = EntIndexToEntRef(client);
			b_ShowNpcHealthbar[entity] = true;
		}
	}
}

public void Weapon_SeaRangePapFull_M2(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 90.0);

	ClientCommand(client, "playgamesound ambient/halloween/male_scream_13.wav");
	
	ApplyTempAttrib(weapon, 2, 2.0, 10.0);
	ApplyTempAttrib(weapon, 6, 1.333, 10.0);
	ApplyTempAttrib(weapon, 97, 1.333, 10.0);
	SpecialEffectFor[client] = GetGameTime() + 10.0;

	float pos1[3], /*pos2[3], */ang[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos1);
	GetEntPropVector(client, Prop_Data, "m_angRotation", ang);
	
	int SpawnMaxEnemies = 3;
	if(LastMann)
	{
		SpawnMaxEnemies = 6;
		Ability_Apply_Cooldown(client, slot, 30.0);
	}
		
	for(int i; i < SpawnMaxEnemies; i++)
	{
		int entity = NPC_CreateByName("npc_searunner", client, pos1, ang, TFTeam_Red);
		if(entity > MaxClients)
		{
			int maxhealth = SDKCall_GetMaxHealth(client) / 2; //2x health cus no resistance.
			if(LastMann)
				maxhealth *= 2;
			SetEntProp(entity, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", maxhealth);
			fl_Extra_Damage[entity] = Attributes_Get(weapon, 2, 1.0);
			CreateTimer(95.0, Seaborn_KillNPC, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
			i_NpcOverrideAttacker[entity] = EntIndexToEntRef(client);
			b_ShowNpcHealthbar[entity] = true;
		}
	}
	/*
	for(int target = 1; target <= MaxClients; target++)
	{
		if(client != target && IsClientInGame(target) && IsPlayerAlive(target))
		{
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < 100000) // 316 HU
			{
				i_ExtraPlayerPoints[client] += 10;

				int entity = GetEntPropEnt(target, Prop_Send, "m_hActiveWeapon");
				if(entity != -1)
				{
					ApplyTempAttrib(entity, 2, 2.0, 10.0);
					ApplyTempAttrib(entity, 6, 1.333, 10.0);
					ApplyTempAttrib(entity, 97, 1.333, 10.0);
					ApplyTempAttrib(entity, 410, 2.0, 10.0);

					ClientCommand(target, "playgamesound ambient/halloween/male_scream_13.wav");
					ClientCommand(target, "playgamesound ambient/halloween/male_scream_13.wav");
				}
			}
		}
	}*/
}


public void Weapon_SeaHealingPap_M1(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}
	StartPlayerOnlyLagComp(client, true);
	float pos[3];
	int target = GetClientPointVisiblePlayersNPCs(client, 120.0, pos, false);
	EndPlayerOnlyLagComp(client);

	int AllowHealing = 0;
	if(IsValidEntity(target))
	{
		if(IsValidClient(target))
		{
			if(dieingstate[target] == 0)
				AllowHealing = 1;
		}
		else if(Citizen_IsIt(target))
		{
			if(!Citizen_ThatIsDowned(target))
				AllowHealing = 2;
		}
		else if(!b_NpcHasDied[target])
		{
			AllowHealing = 2;
		}
	}
	
	if(AllowHealing > 0)
	{
		SetGlobalTransTarget(client);

		int health = GetEntProp(target, Prop_Data, "m_iHealth");
		int maxHealth = ReturnEntityMaxHealth(target);
		if(health < maxHealth)
		{
			int healing = maxHealth - health;
			if(healing > 75)
				healing = 75;

			healing = RoundToNearest(float(healing) * Attributes_GetOnWeapon(client, weapon, 8, true));

			int Pap = RoundToNearest(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
			if(Pap != 0.0)
			{
				if(Pap == 1)
				{
					healing = 50;
				}
				else
				{
					healing = 100;
				}
			}

			if((health + healing) > maxHealth)
			{
				healing = maxHealth - health;
			}

			HealEntityGlobal(client, target, float(healing), 1.0, 0.5, _);

			if(healing <= 0)
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				return;
			}
			ClientCommand(client, "playgamesound items/smallmedkit1.wav");

			if(AllowHealing == 1)
				ClientCommand(target, "playgamesound items/smallmedkit1.wav");

			float cooldown;
			if(Pap != 0.0)
			{
				cooldown = float(healing) / 5.0;
			}
			else
			{
				cooldown = float(healing) / 10.0;
			}
			
			if(cooldown < 1.0)
				cooldown = 1.0;

			if(cooldown > 15.0)
				cooldown = 15.0;
			
			if(AllowHealing == 1)
				PrintHintText(client, "You Healed %N for %d HP!, you gain a %.0f healing cooldown.", target, healing, cooldown);
			else
				PrintHintText(client, "You Healed %s for %d HP!, you gain a %.0f healing cooldown.", NpcStats_ReturnNpcName(target), healing, cooldown);


			Ability_Apply_Cooldown(client, 1, cooldown);
			Ability_Apply_Cooldown(client, 2, cooldown);

			int BeamIndex = ConnectWithBeam(client, target, 70, 200, 70, 2.0, 2.0, 1.1, "sprites/laserbeam.vmt");
			SetEntityRenderFx(BeamIndex, RENDERFX_FADE_FAST);
			CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(BeamIndex), TIMER_FLAG_NO_MAPCHANGE);

			return;
		}
		if(AllowHealing == 1)
			PrintHintText(client, "%N Is already at full hp.", target);
		else
			PrintHintText(client, "%s Is already at full hp.", NpcStats_ReturnNpcName(target));
	}

	ClientCommand(client, "playgamesound items/medshotno1.wav");
}

public void Weapon_SeaHealingPap_M2(int client, int weapon, bool crit, int slot)
{
	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}
	int health = GetEntProp(client, Prop_Send, "m_iHealth");
	int maxHealth = SDKCall_GetMaxHealth(client);
	
	int healing = maxHealth - health;
	if(healing > 30)
		healing = 30;

	healing = RoundToNearest(float(healing) * Attributes_GetOnWeapon(client, weapon, 8, true));

	int Pap = RoundToNearest(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
	if(Pap != 0.0)
	{
		if(Pap == 1)
		{
			healing = 20;
		}
		else
		{
			healing = 40;
		}
	}

	if((health + healing) > maxHealth)
	{
		healing = maxHealth - health;
	}
	
	if(healing <= 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	
	HealEntityGlobal(client, client, float(healing), 1.0, 0.5, _);
	ClientCommand(client, "playgamesound items/smallmedkit1.wav");

	PrintHintText(client,"You Healed yourself for %d HP!, you gain a 25 healing cooldown.", healing);

	Ability_Apply_Cooldown(client, 1, 25.0);
	Ability_Apply_Cooldown(client, 2, 25.0);

}

public Action Seaborn_KillNPC(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity) && !b_NpcHasDied[entity])
	{
		SmiteNpcToDeath(entity);
	}
	
	return Plugin_Stop;
}