#pragma semicolon 1
#pragma newdecls required

enum
{
	Ritualist_None = 0,
	Ritualist_Necrosis,
	Ritualist_Nervous
}

static const char g_GongSound[][] = {
	")items/japan_fundraiser/TF_zen_prayer_bowl_01.wav",
	")items/japan_fundraiser/TF_zen_prayer_bowl_02.wav",
	")items/japan_fundraiser/TF_zen_prayer_bowl_03.wav",
};
static int WeaponType[MAXPLAYERS];
static int WeaponRef[MAXPLAYERS] = {-1, ...};
static Handle WeaponTimer[MAXPLAYERS];
static int NpcRef[MAXPLAYERS] = {-1, ...};
static float GiveBuffDurationFor[MAXPLAYERS] = {-1.0, ...};

void Ritualist_MapStart()
{
	for (int i = 0; i < (sizeof(g_GongSound));	   i++) { PrecacheSound(g_GongSound[i]);	   }
}
void Ritualist_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_RITUALIST)
	{
		WeaponRef[client] = EntIndexToEntRef(weapon);
		WeaponType[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));

		if(!WeaponTimer[client])
			WeaponTimer[client] = CreateTimer(0.5, RitualistTimer, client, TIMER_REPEAT);
	}
}
public void RitualistCancelTauntDo(int client)
{
	int NpcTry = EntRefToEntIndex(NpcRef[client]);
	if(!IsValidEntity(NpcTry))
		return;
	RitualistInternalCancel(NpcTry);
}
public void Weapon_Ritualist_M1(int client, int weapon, bool &result, int slot)
{
	int cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(Current_Mana[client] < cost)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", cost);
	}
	else
	{
		float damage = 65.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
		
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= cost;
		delay_hud[client] = 0.0;
			
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		speed *= Attributes_Get(weapon, 104, 1.0);
		speed *= Attributes_Get(weapon, 475, 1.0);

		float time = 750.0 / speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		time *= Attributes_Get(weapon, 102, 1.0);
		
		switch(WeaponType[client])
		{
			case Ritualist_Necrosis:
			{
				EmitGameSoundToClient(client, "Player.HitSoundNotes", client);
			}
			case Ritualist_Nervous:
			{
				EmitSoundToAll("misc/halloween/spell_teleport.wav", client, _, 65, _, 0.45);
			}
			default:
			{
				EmitGameSoundToAll("xmas.jingle", client);
			}
		}

		Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_RITUALIST, weapon, WeaponType[client] ? "eyeboss_projectile" : "drg_cow_rockettrail_normal");
	}
}

void Weapon_Ritualist_ProjectileTouch(int entity, int target)
{
	if(target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		if(owner != -1)
		{
			int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

			float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);

			SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);
		
			switch(WeaponType[owner])
			{
				case Ritualist_Necrosis:
				{
					EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);
				}
				case Ritualist_Nervous:
				{
					ApplyStatusEffect(owner, target, "Elemental Amplification", 0.5);
					Explode_Logic_Custom(f_WandDamage[entity] * 0.2, owner, entity, weapon, .FunctionToCallBeforeHit = NervousExplodeBefore);
					EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);

					//float pos[3];
					//GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
					//ParticleEffectAt(pos, "halloween_ghost_smoke", 3.0);
				}
				default:
				{
					EmitGameSoundToAll("xmas.jingle", entity);
				}
			}
		}

		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(particle > MaxClients)
			RemoveEntity(particle);
		
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(particle > MaxClients)
			RemoveEntity(particle);
		
		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		if(owner != -1)
		{
			int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
			
			switch(WeaponType[owner])
			{
				case Ritualist_Necrosis:
				{
					EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);
				}
				case Ritualist_Nervous:
				{
					Explode_Logic_Custom(f_WandDamage[entity] * 2.5, owner, owner, weapon, .FunctionToCallBeforeHit = NervousExplodeBefore);
					EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);

					//float pos[3];
					//GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
					//ParticleEffectAt(pos, "halloween_ghost_smoke", 3.0);
				}
				default:
				{
					EmitGameSoundToAll("xmas.jingle", entity);
				}
			}
		}

		RemoveEntity(entity);
	}
}

static Action RitualistTimer(Handle timer, int client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		int weapon = EntRefToEntIndex(WeaponRef[client]);
		if(weapon != -1)
		{
			if(weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
			{
				if(WeaponType[client] == Ritualist_Necrosis)
				{
					float damage = Attributes_Get(weapon, 410, 1.0) * 1.25;
					if(IsValidEntity(NpcRef[client]))
						damage *= 2.1538;
					
					Explode_Logic_Custom(damage, client, client, weapon, _, 600.0, .FunctionToCallBeforeHit = NecrosisExplodeBefore);
				}
			}

			return Plugin_Continue;
		}
		
	}

	WeaponTimer[client] = null;
	return Plugin_Stop;
}

void Ritualist_MinionExplode(int client, int entity)
{
	if(client < 1 || client > MaxClients)
		return;
	
	int weapon = EntRefToEntIndex(WeaponRef[client]);
	if(weapon != -1)
	{
		float damage = 97.5 * Attributes_Get(weapon, 410, 1.0);
		Explode_Logic_Custom(damage, client, entity, weapon, _, 300.0, .FunctionToCallBeforeHit = NecrosisBleedExplodeBefore);
	}
}
void RitualistApplyBuff(int attacker, int victim, float &damage, int weapon)
{
	if(GetTeam(attacker) == GetTeam(victim))
	{
		i_ExtraPlayerPoints[attacker] += 1;

		float DurationGive = GiveBuffDurationFor[attacker] - GetGameTime();
		if(!HasSpecificBuff(victim, "Liberal Tango"))
		{
			int BeamIndex = ConnectWithBeam(attacker, victim, 255, 125, 125, 3.0, 3.0, 1.35, "sprites/laserbeam.vmt");
			SetEntityRenderFx(BeamIndex, RENDERFX_FADE_FAST);
			CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(BeamIndex), TIMER_FLAG_NO_MAPCHANGE);
		}
		ApplyStatusEffect(attacker, victim, "Liberal Tango", DurationGive);
	}
}

static float NervousExplodeBefore(int attacker, int victim, float &damage, int weapon)
{
	Elemental_AddNervousDamage(victim, attacker, RoundFloat(damage * 10.0), .weapon = weapon);
	damage = 0.0;
	return 0.0;
}

static float NecrosisExplodeBefore(int attacker, int victim, float &damage, int weapon)
{
	ApplyStatusEffect(attacker, victim, "Elemental Amplification", 1.1);
	Elemental_AddNecrosisDamage(victim, attacker, RoundFloat(damage * 10.0), weapon);
	damage = 0.0;
	return 0.0;
}

static float NecrosisBleedExplodeBefore(int attacker, int victim, float &damage, int weapon)
{
	ApplyStatusEffect(attacker, victim, "Maimed", 3.0);
	
	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(victim));
	pack.WriteCell(EntIndexToEntRef(attacker));
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteFloat(damage);
	CreateTimer(0.5, Timer_NecrosisBleed, pack, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(1.0, Timer_NecrosisBleed, pack, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(1.5, Timer_NecrosisBleed, pack, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(2.0, Timer_NecrosisBleed, pack, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(2.5, Timer_NecrosisBleed, pack, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(3.0, Timer_NecrosisBleed, pack, TIMER_DATA_HNDL_CLOSE);

	damage = 0.0;
	return 0.0;
}

static Action Timer_NecrosisBleed(Handle timer, DataPack pack)
{
	pack.Reset();
	int victim = EntRefToEntIndex(pack.ReadCell());
	if(victim != -1)
	{
		int attacker = EntRefToEntIndex(pack.ReadCell());
		if(attacker != -1)
		{
			int weapon = EntRefToEntIndex(pack.ReadCell());
			if(weapon != -1)
			{
				float damage = pack.ReadFloat();
				SDKHooks_TakeDamage(victim, attacker, attacker, damage, DMG_PLASMA, weapon);
				Elemental_AddNecrosisDamage(victim, attacker, RoundFloat(damage * 2.083333), weapon);
			}
		}
	}
	return Plugin_Continue;
}

public void Weapon_RitualistNecrosis_Dance(int client, int weapon, bool &result, int slot)
{
	float cooldown = Ability_Check_Cooldown(client, slot);
	if(cooldown > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);
		return;
	}
	if(dieingstate[client] != 0 || (GetEntityFlags(client) & FL_ONGROUND) == 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	DoSpecialActionRitualist(client, 0);
	Ability_Apply_Cooldown(client, slot, 10.0);
	Rogue_OnAbilityUse(client, weapon);
}
public void Weapon_RitualistNecrosis_R(int client, int weapon, bool &result, int slot)
{
	
	float cooldown = Ability_Check_Cooldown(client, slot);
	if(cooldown > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);
		return;
	}
	if(Ability_Check_Cooldown(client, slot) < 0.0 && !(GetClientButtons(client) & IN_DUCK) && NeedCrouchAbility(client))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Crouch for ability");	
		return;
	}
	if(dieingstate[client] != 0 || (GetEntityFlags(client) & FL_ONGROUND) == 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	Rogue_OnAbilityUse(client, weapon);

	Ability_Apply_Cooldown(client, slot, 100.0);
	EmitSoundToAll(g_GongSound[GetRandomInt(0, sizeof(g_GongSound) - 1)], client, _, 75, _, 0.65);

//	ApplyTempAttrib(weapon, 410, 1.75, 25.0);
	ApplyTempAttrib(weapon, 6, 0.5, 25.0);
	ApplyStatusEffect(client, client, "Liberal Tango", 25.0);
	GiveBuffDurationFor[client] = GetGameTime() + 25.0;
	DoSpecialActionRitualist(client, 1);

}

public void Weapon_RitualistNervous_M2(int client, int weapon, bool &result, int slot)
{
	float cooldown = Ability_Check_Cooldown(client, slot);
	if(cooldown > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);
	}
	else
	{
		Rogue_OnAbilityUse(client, weapon);

		Ability_Apply_Cooldown(client, slot, 70.0);
		ClientCommand(client, "playgamesound ambient/halloween/male_scream_06.wav");
		
		float pos1[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos1);

		int entity = NPC_CreateByName("npc_ritualist", client, pos1, {0.0, 0.0, 0.0}, TFTeam_Red);
		if(entity > MaxClients)
		{
			CreateTimer(65.0, Seaborn_KillNPC, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
			i_NpcOverrideAttacker[entity] = EntIndexToEntRef(client);
			b_ShowNpcHealthbar[entity] = false;
		}
	}
}

void StatusEffects_Ritualist()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Liberal Tango");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "♬");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= 0.8;	// +20% res
	data.DamageDealMulti			= 0.3;	// +30% dmg
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	data.AttackspeedBuff			= -1.0;
	StatusEffect_AddGlobal(data);
}



static void DoSpecialActionRitualist(int client, int DanceMode)
{
	float vabsAngles[3];
	float vabsOrigin[3];
	GetClientAbsOrigin(client, vabsOrigin);
	GetClientEyeAngles(client, vabsAngles);
	vabsAngles[0] = 0.0;

	int spawn_index;
	switch(DanceMode)
	{
		case 0:
		{
			spawn_index = NPC_CreateByName("npc_allied_ritualist_afterimage", client, vabsOrigin, vabsAngles, GetTeam(client), "");
		}
		case 1:
		{
			spawn_index = NPC_CreateByName("npc_allied_ritualist_afterimage", client, vabsOrigin, vabsAngles, GetTeam(client), "longdance");
		}
	} 
	NpcRef[client] = EntIndexToEntRef(spawn_index);
	SetVariantInt(1);
	AcceptEntityInput(client, "SetForcedTauntCam");

	/*
		Todo: Prevent movement gain from moving, i.e. speed 0.
		no jumping either

	*/
//	TF2_AddCondition(client, TFCond_FreezeInput, -1.0);

//	SetEntityMoveType(client, MOVETYPE_NONE);
//	SetEntProp(client, Prop_Send, "m_bIsPlayerSimulated", 0);
//	SetEntProp(client, Prop_Send, "m_bSimulatedEveryTick", 0);
//	SetEntProp(client, Prop_Send, "m_bAnimatedEveryTick", 0);
//	SetEntProp(client, Prop_Send, "m_bClientSideAnimation", 0);
//	SetEntProp(client, Prop_Send, "m_bClientSideFrameReset", 1);
//	SetEntProp(client, Prop_Send, "m_bForceLocalPlayerDraw", 1);

	int entity, i;
	while(TF2U_GetWearable(client, entity, i))
	{
		SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") | EF_NODRAW);
	}
}