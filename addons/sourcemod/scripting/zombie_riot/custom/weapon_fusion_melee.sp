#pragma semicolon 1
#pragma newdecls required

#define EMPOWER_RANGE 200.0

#define NEARL_ACTIVE_SOUND "mvm/mvm_tele_activate.wav"
#define NEARL_EXTRA_DAMAGE_SOUND "misc/ks_tier_04_kill_01.wav"
#define NEARL_STUN_RANGE 200.0

static float Duration[MAXTF2PLAYERS];
static int Weapon_Id[MAXTF2PLAYERS];

static float f_NearlDurationCheckApply[MAXTF2PLAYERS];
static float f_NearlThinkDelay[MAXTF2PLAYERS];
static int i_NearlWeaponUsedWith[MAXTF2PLAYERS];

static float f_SpeedFistsOfSpeed[MAXTF2PLAYERS];
static int i_SpeedFistsOfSpeedHit[MAXTF2PLAYERS];

public void Fusion_Melee_OnMapStart()
{
	Zero(Duration);
	Zero(Weapon_Id);
	PrecacheSound(EMPOWER_SOUND);
	PrecacheSound(NEARL_ACTIVE_SOUND);
	PrecacheSound(NEARL_EXTRA_DAMAGE_SOUND);
	Zero(f_NearlDurationCheckApply);
	Zero(f_NearlThinkDelay);
	Zero(f_SpeedFistsOfSpeed);
}

public float Npc_OnTakeDamage_Fusion(int victim, float damage, int weapon)
{
	
	return damage;
}

public float Npc_OnTakeDamage_PaP_Fusion(int attacker, int victim, float damage, int weapon)
{
	CClotBody npc = view_as<CClotBody>(victim);
	
	if(IsValidEntity(npc.m_iTarget))
	{
		if(i_NpcInternalId[npc.m_iTarget] == NEARL_SWORD)
		{
			damage *= 2.0;
			DisplayCritAboveNpc(victim, attacker, false); //Display crit above head, false for no sound
			EmitSoundToClient(attacker,NEARL_EXTRA_DAMAGE_SOUND, victim, SNDCHAN_AUTO, 90, _, 0.8);
			EmitSoundToClient(attacker,NEARL_EXTRA_DAMAGE_SOUND, victim, SNDCHAN_AUTO, 90, _, 0.8);
		}
	}
	return damage;
}

public void Fusion_Melee_Empower_State(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, 60.0); //Semi long cooldown, this is a strong buff.

		Duration[client] = GetGameTime() + 10.0; //Just a test.

		EmitSoundToAll(EMPOWER_SOUND, client, SNDCHAN_STATIC, 90, _, 0.6);
		Weapon_Id[client] = EntIndexToEntRef(weapon);
		CreateTimer(0.1, Empower_ringTracker, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.5, Empower_ringTracker_effect, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.0, Empower_ringTracker_effect, client, TIMER_FLAG_NO_MAPCHANGE); //Make it happen atleast once instantly
		f_EmpowerStateSelf[client] = GetGameTime() + 0.6;
		spawnRing(client, EMPOWER_RANGE * 2.0, 0.0, 0.0, EMPOWER_HIGHT_OFFSET, EMPOWER_MATERIAL, 231, 181, 59, 125, 30, 0.51, EMPOWER_WIDTH, 6.0, 10);
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


static Action Empower_ringTracker(Handle ringTracker, int client)
{
	if (IsValidClient(client) && Duration[client] > GetGameTime())
	{
		int ActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		if(EntRefToEntIndex(Weapon_Id[client]) == ActiveWeapon)
		{
			spawnRing(client, EMPOWER_RANGE * 2.0, 0.0, 0.0, EMPOWER_HIGHT_OFFSET, EMPOWER_MATERIAL, 231, 181, 59, 125, 10, 0.11, EMPOWER_WIDTH, 6.0, 10);
			
			f_EmpowerStateSelf[client] = GetGameTime() + 0.6;

			float chargerPos[3];
			float targPos[3];
			GetClientAbsOrigin(client, chargerPos);
			for (int targ = 1; targ <= MaxClients; targ++)
			{
				if (IsValidClient(targ) && IsValidClient(client))
				{
					GetClientAbsOrigin(targ, targPos);
					if (targ != client && GetVectorDistance(chargerPos, targPos, true) <= (EMPOWER_RANGE * EMPOWER_RANGE))
					{
						f_EmpowerStateOther[targ] = GetGameTime() + 0.6;
					}
				}
			}

			//Buff allied npcs too! Is cool!
			for(int entitycount_again; entitycount_again<i_MaxcountNpc_Allied; entitycount_again++)
			{
				int baseboss_index_allied = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount_again]);
				if (IsValidEntity(baseboss_index_allied))
				{
					GetEntPropVector(baseboss_index_allied, Prop_Data, "m_vecAbsOrigin", chargerPos);
					if (GetVectorDistance(chargerPos, targPos, true) <= (EMPOWER_RANGE * EMPOWER_RANGE))
					{
						f_EmpowerStateOther[baseboss_index_allied] = GetGameTime() + 0.6;
					}
				}
			}
		}
		else
		{
			KillTimer(ringTracker, false);
		}

	}
	else
	{
		KillTimer(ringTracker, false);
	}

	return Plugin_Continue;
}

static Action Empower_ringTracker_effect(Handle ringTracker, int client)
{
	if (IsValidClient(client) && Duration[client] > GetGameTime() && IsValidEntity(EntRefToEntIndex(Weapon_Id[client])))
	{
		int ActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		if(EntRefToEntIndex(Weapon_Id[client]) == ActiveWeapon)
		{
			//	spawnRing(client, EMPOWER_RANGE * 2.0, 0.0, 0.0, EMPOWER_HIGHT_OFFSET, EMPOWER_MATERIAL, 231, 181, 59, 125, 30, 0.5, EMPOWER_WIDTH, 6.0, 10);
			spawnRing(client, 0.0, 0.0, 0.0, EMPOWER_HIGHT_OFFSET, EMPOWER_MATERIAL, 231, 181, 59, 125, 1, 0.51, EMPOWER_WIDTH, 6.1, 1, EMPOWER_RANGE * 2.0);
		}
		else
		{
			KillTimer(ringTracker, false);
		}
	}
	else
	{
		KillTimer(ringTracker, false);
	}

	return Plugin_Continue;
}


public void Fusion_Melee_Nearl_Radiant_Knight(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		i_NearlWeaponUsedWith[client] = EntIndexToEntRef(weapon);
		if(f_NearlDurationCheckApply[client] > GetGameTime())
		{
			float fPos[3];
			float fAng[3];
			bool validpos = NearlCheckIfValidPos(client, 0.12,fPos,fAng);
			SDKUnhook(client, SDKHook_PostThink, NearlRadiantKnightCheck);
			f_NearlDurationCheckApply[client] = 0.0;

			if(validpos)
			{
				Rogue_OnAbilityUse(weapon);
				Ability_Apply_Cooldown(client, slot, 60.0); //Semi long cooldown, this is a strong buff.
				float damage = 500.0;
				damage *= Attributes_Get(weapon, 2, 1.0);

				i_ExplosiveProjectileHexArray[weapon] = 0;
				i_ExplosiveProjectileHexArray[weapon] |= EP_DEALS_CLUB_DAMAGE;

				Explode_Logic_Custom(damage, client, client, weapon, fPos, NEARL_STUN_RANGE, _, _, _, 15);

				bool RaidActive = false;

				if(IsValidEntity(EntRefToEntIndex(RaidBossActive)))
					RaidActive = true;

				int maxhealth = SDKCall_GetMaxHealth(client);
				maxhealth *= 2; //2x health cus no resistance.

				if(Items_HasNamedItem(client, "Cured Silvester"))
				{
					SetDefaultHudPosition(client, 255, 215, 0, 2.0);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Silvester Shares His Power");	
					float flPos[3];
					float flAng[3];
					GetAttachment(client, "head", flPos, flAng);
					flPos[2] += 10.0;
					int particle_halo = ParticleEffectAt(flPos, "unusual_symbols_parent_lightning", 10.0);
					SetParent(client, particle_halo, "head");
					maxhealth = RoundToCeil(float(maxhealth) * 1.05);
					ApplyTempAttrib(weapon, 2, 2.6, 10.0); //way higher damage.
					ApplyTempAttrib(weapon, 6, 1.70, 10.0); //slower attack speed
					ApplyTempAttrib(weapon, 412, 0.58, 10.0); //Less damage taken from all sources decreaced by 40%
				}
				else
				{
					ApplyTempAttrib(weapon, 2, 2.5, 10.0); //way higher damage.
					ApplyTempAttrib(weapon, 6, 1.75, 10.0); //slower attack speed
					ApplyTempAttrib(weapon, 412, 0.60, 10.0); //Less damage taken from all sources decreaced by 40%
				}

				int spawn_index = Npc_Create(NEARL_SWORD, -1, fPos, fAng, GetEntProp(client, Prop_Send, "m_iTeamNum") == 2);
				if(spawn_index > MaxClients)
				{

					float Duration_Stun = 1.2;
					float Duration_Stun_Boss = 0.6;
					b_LagCompNPC_No_Layers = true;
					StartLagCompensation_Base_Boss(client);
					float EnemyPos[3];
					for(int entitycount_again; entitycount_again<i_MaxcountNpc; entitycount_again++)
					{
						int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs[entitycount_again]);
						if (IsValidEntity(baseboss_index))
						{
							GetEntPropVector(baseboss_index, Prop_Data, "m_vecAbsOrigin", EnemyPos);
							if (GetVectorDistance(EnemyPos, fPos, true) <= (NEARL_STUN_RANGE * NEARL_STUN_RANGE))
							{
								if(!b_thisNpcIsABoss[baseboss_index] && !RaidActive)
								{
									FreezeNpcInTime(baseboss_index,Duration_Stun);
								}
								else
								{
									FreezeNpcInTime(baseboss_index,Duration_Stun_Boss);
								}
								CClotBody npc_set_aggro = view_as<CClotBody>(baseboss_index);
								npc_set_aggro.m_iTarget = spawn_index;
								npc_set_aggro.m_flGetClosestTargetTime = GetGameTime(npc_set_aggro.index) + 1.0;
							}
						}
					}
					FinishLagCompensation_Base_boss();

					fPos[2] += 40.0;
					ParticleEffectAt(fPos, "asplode_hoodoo_embers", 1.0);
					fPos[2] -= 40.0;
					CClotBody npc = view_as<CClotBody>(spawn_index);
					npc.m_iWearable4 =	ParticleEffectAt(fPos, "powerup_supernova_ready", 10.0);
					fPos[2] += 50.0;
					npc.m_iWearable5 =	ParticleEffectAt(fPos, "powerup_supernova_ready", 10.0);
					fPos[2] += 3000.0;
					int particle = ParticleEffectAt(fPos, "kartimpacttrail", 1.0);
					SetEdictFlags(particle, (GetEdictFlags(particle) | FL_EDICT_ALWAYS));	
					EmitSoundToAll(NEARL_ACTIVE_SOUND, client, SNDCHAN_STATIC, 90, _, 0.6);
					CreateTimer(0.1, Nearl_Falling_Shot, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
					SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
					SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
					CreateTimer(10.0, Timer_SlayNearlSword, EntIndexToEntRef(spawn_index), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
		else
		{
			SDKUnhook(client, SDKHook_PostThink, NearlRadiantKnightCheck);
			SDKHook(client, SDKHook_PostThink, NearlRadiantKnightCheck);
			f_NearlDurationCheckApply[client] = GetGameTime() + 2.0;
		}
		/*

		*/
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

public void NearlRadiantKnightCheck(int client)
{
	if(f_NearlDurationCheckApply[client] < GetGameTime())
	{
		SDKUnhook(client, SDKHook_PostThink, NearlRadiantKnightCheck);
		return;
	}
	if(f_NearlThinkDelay[client] > GetGameTime())
	{
		return;
	}
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int Weapon_Was = EntRefToEntIndex(i_NearlWeaponUsedWith[client]);
	if(weapon_holding == Weapon_Was)
	{
		f_NearlThinkDelay[client] = GetGameTime() + 0.1;
		float fPos[3];
		float fAng[3];
		NearlCheckIfValidPos(client, 0.12,fPos,fAng);
	}
	else
	{
		SDKUnhook(client, SDKHook_PostThink, NearlRadiantKnightCheck);
		return;		
	}
}


public bool NearlCheckIfValidPos(int client, float duration, float fPos[3], float fAng[3])
{
	GetClientEyeAngles(client, fAng);
	GetClientAbsOrigin(client, fPos);
	fPos[2] += 120.0; //Default is on average 70. so lets keep it like that.
	fAng[0] = 0.0; //We dont care about them looking down or up
	fAng[2] = 0.0; //This shoulddnt be accounted for!

	float tmp[3];
	float actualBeamOffset[3];
	float BEAM_BeamOffset[3];
	BEAM_BeamOffset[0] = 120.0;
	BEAM_BeamOffset[1] = 0.0;
	BEAM_BeamOffset[2] = 0.0;
	
	tmp[0] = BEAM_BeamOffset[0];
	tmp[1] = BEAM_BeamOffset[1];
	tmp[2] = 0.0;
	VectorRotate(tmp, fAng, actualBeamOffset);
	actualBeamOffset[2] = BEAM_BeamOffset[2];
	fPos[0] += actualBeamOffset[0];
	fPos[1] += actualBeamOffset[1];
	fPos[2] += actualBeamOffset[2];

	static float m_vecMaxs[3];
	static float m_vecMins[3];
	m_vecMaxs = view_as<float>( { 10.0, 10.0, 70.0 } );
	m_vecMins = view_as<float>( { -10.0, -10.0, 0.0 } );	

	Handle hTrace;
	static float m_vecLookdown[3];
	m_vecLookdown = view_as<float>( { 90.0, 0.0, 0.0 } );
	hTrace = TR_TraceRayFilterEx(fPos, m_vecLookdown, ( MASK_ALL ), RayType_Infinite, HitOnlyWorld, client);	
	TR_GetEndPosition(fPos, hTrace);
	delete hTrace;
	fPos[2] += 4.0;
	int HitWorld = IsSpaceOccupiedIgnorePlayers(fPos, m_vecMins, m_vecMaxs, client);
	if (HitWorld) //The boss will start to merge with player, STOP!
	{
		TE_DrawBox(client, fPos, m_vecMins, m_vecMaxs, duration, view_as<int>({255, 0, 0, 255}));
		return false;
	}
	if(IsPointHazard(fPos)) //Retry.
	{
		TE_DrawBox(client, fPos, m_vecMins, m_vecMaxs, duration, view_as<int>({255, 0, 0, 255}));
		return false;
	}
	TE_DrawBox(client, fPos, m_vecMins, m_vecMaxs, duration, view_as<int>({255, 215, 0, 255}));
	return true;
}

public Action Timer_SlayNearlSword(Handle cut_timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity)) //Dont do this in a think pls.
	{
		SDKHooks_TakeDamage(entity, 0, 0, 99999999.9);
	}
	return Plugin_Handled;
}

public Action Nearl_Falling_Shot(Handle timer, int ref)
{
	int particle = EntRefToEntIndex(ref);
	if(particle>MaxClients && IsValidEntity(particle))
	{
		float position[3];
		GetEntPropVector(particle, Prop_Send, "m_vecOrigin", position);
		position[2] -= 3700.0;
		TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
	}
	return Plugin_Handled;
}


void Npc_OnTakeDamage_SpeedFists(int attacker, int victim, float &damage)
{
	if(b_thisNpcIsARaid[victim])
	{
		damage *= 1.10;
	}
	if(f_SpeedFistsOfSpeed[attacker] > GetGameTime())
	{
		i_SpeedFistsOfSpeedHit[attacker] += 1;
		if(i_SpeedFistsOfSpeedHit[attacker] > 10)
		{
			TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 1.0);
		}
	}
	else
	{
		i_SpeedFistsOfSpeedHit[attacker] = 1;
	}
	f_SpeedFistsOfSpeed[attacker] = GetGameTime() + 0.5;
}